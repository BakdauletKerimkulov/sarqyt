---
title: Refactor Booking Flow
status: in-progress
date: 2026-06-14
type: refactor
---

# Plan: Fix Booking Flow & Remove Online Payment

Source: `ai_specs/012-refactor-booking-flow-spec.md`

## Overview
Fix 6 critical booking-flow defects (broken idempotency, security rules hole, missing store cancellation, no cancel from readyForPickup, no pickup window validation, no soldOut status) and fully remove Stripe integration. Approach: backend-first — fix functions + rules, then Flutter domain/data, then UI. Stripe removal woven into each layer.

**Spec:** `ai_specs/012-refactor-booking-flow-spec.md`

## Context
- **Structure:** feature-first (`features/{name}/domain|data|application|presentation`), Firebase access only in repositories/services
- **State management:** Riverpod codegen (`@riverpod`), AsyncValue + AsyncValueWidget — e.g. `lib/src/features/orders/data/client_orders_repository.dart`
- **Reference implementations:** `cancel-order.ts` (transaction + quantity restore), `expire-orders.ts` (per-order transaction + offer re-read), `business_orders_screen.dart` (status transition button pattern)
- **Testing convention:** `test/` mirrors `lib/`; group/test pattern; mock repos for controller tests; widget tests with localization delegates — `ai_toolkit/architecture.md:529-567`
- **Lint + test command:** `flutter analyze && flutter test` (Flutter); `npm run build` (functions)
- **Assumptions / Gaps:**
  - Spec says `paymentStatus` becomes nullable but `Order.fromJson` uses freezed — must ensure codegen handles `PaymentStatus?` (nullable enum) correctly with existing docs that have string values
  - `CancelledBy` enum parsing for old docs without the field — needs `@Default(null)` or nullable

## Plan

### Phase 1 — Backend fixes: idempotency, pickup validation, soldOut, security rules
**Goal:** Fix all 6 server-side defects and lock down security rules. Prove critical path without Stripe changes yet.

- [x] `functions/src/features/payments/functions/reserve-offer.ts` — R6: add `pickupEndTime > now` check inside transaction after status check; R7: set `status: "soldOut"` on offer when `quantity == 0` after decrement; R11: stop writing `paymentStatus: "paid"`; add `updatedAt: serverTimestamp()` to order creation
- [x] `functions/src/features/orders/functions/cancel-order.ts` — R5: extend allowed statuses to include `readyForPickup` (`:66-70`); R4: accept optional `reason` field, write `cancellationReason` and `cancelledBy: "customer"|"store"` on order; R7: replace `FieldValue.increment(qty)` with `tx.get(offerRef)` + conditional: set offer `status: "active"` only if current status is `soldOut` AND `pickupEndTime > now`
- [x] `functions/src/features/orders/functions/expire-orders.ts` — R7: after restoring quantity, check if offer was `soldOut` and `pickupEndTime > now` → set `active`; otherwise leave status as-is
- [x] `firestore.rules` — R2: change orders update rule (`:172-175`) to `allow update: if isAdmin()` only — remove store-level direct write
- [ ] TDD: `reserve-offer` rejects past `pickupEndTime`; sets `soldOut` at zero quantity; idempotent on existing order; no `paymentStatus` field written _blocked: no Cloud Functions test infrastructure exists (vitest configured but zero test files, no Firestore mocks/helpers)_
- [ ] TDD: `cancel-order` allows `readyForPickup`; writes `cancellationReason`/`cancelledBy`; restores offer to `active` from `soldOut` when window open _blocked: no Cloud Functions test infrastructure exists (vitest configured but zero test files, no Firestore mocks/helpers)_
- [x] Verify: `cd functions && npm run build`

### Phase 2 — Stripe removal (functions + Flutter)
**Goal:** Delete all Stripe code from both sides. No Stripe references remain.

- [x] Delete `functions/src/features/payments/functions/create-payment.ts`, `functions/src/features/payments/functions/stripe-webhook.ts`, `functions/src/shared/helpers/stripe-client.ts`
- [x] `functions/src/index.ts` — remove `createPayment` and `stripeWebhook` exports (`:19-20`); remove `stripe-client` import from `cancel-order.ts` (`:8`) and `{ secrets: [stripeSecretKey] }` from onCall options (`:22-23`); remove all Stripe refund logic from `cancel-order.ts`
- [x] Delete `lib/src/features/checkout/data/payment_sheet_repository.dart` (+`.g.dart`), `lib/src/app_bootstrap_stripe.dart`
- [x] `lib/src/features/checkout/data/payment_repository.dart` — remove `CreatePaymentResult` class, `createPayment` method, `uuid` import; accept `idempotencyKey` as parameter in `reserveOffer` instead of generating internally
- [x] `lib/src/features/checkout/application/checkout_service.dart` — remove commented `payWithStripe` block (`:64-114`); remove unused imports
- [x] `lib/main_client.dart` — remove `setupStripe()` call (`:14`) and import (`:6`); `lib/env.dart` — remove `stripePublishableKey` (`:7-8`); `pubspec.yaml` — remove `flutter_stripe`/`flutter_stripe_web` (`:82-83`)
- [x] Verify: `cd functions && npm run build && cd .. && flutter pub get && flutter analyze`

### Phase 3 — Flutter domain: Order model + Offer status
**Goal:** Update domain models for new fields and nullable paymentStatus.

- [x] `lib/src/features/orders/domain/order.dart` — make `paymentStatus` nullable (`PaymentStatus?`); add `String? cancellationReason`; add `CancelledBy? cancelledBy` (new enum `enum CancelledBy { customer, store }`); update `_readStatus`-style parser if needed for `CancelledBy`
- [x] `lib/src/features/offers/domain/offer.dart` — add `soldOut` to `OfferStatus` enum; update `_readStatus` to parse `"soldOut"` (`:142-158`)
- [x] TDD: `Order.fromJson` handles null `paymentStatus` (backward-compat); `Order.fromJson` reads `cancellationReason`/`cancelledBy`; `Offer._readStatus` parses `"soldOut"`
- [x] Run codegen: `dart run build_runner build --delete-conflicting-outputs`
- [x] Verify: `flutter analyze && flutter test`

### Phase 4 — Flutter data: idempotency fix + store cancel
**Goal:** Fix client-side idempotency key generation and add store cancellation callable.

- [x] `lib/src/features/checkout/application/checkout_service.dart` — generate `idempotencyKey` in `CheckoutController`; regenerate on quantity change; pass to `pay()` → `paymentRepo.reserveOffer(idempotencyKey: key)` (already implemented in Phase 2)
- [x] `lib/src/features/orders/data/orders_repository.dart` — add `cancelOrder(OrderID orderId, {String? reason})` to `StoreOrdersRepository`; calls callable `cancelOrder` with `{orderId, reason}`
- [x] `lib/src/features/orders/data/client_orders_repository.dart` — (optional) add `reason` parameter to `cancelOrder` for client-side reason if needed
- [ ] TDD: `PaymentRepository.reserveOffer` passes through the provided `idempotencyKey`; `StoreOrdersRepository.cancelOrder` passes `reason` _blocked: no Flutter test infrastructure for mocking FirebaseFunctions/httpsCallable exists in this project_
- [x] Verify: `flutter analyze && flutter test`

### Phase 5 — Flutter UI: payment page, order detail, business orders
**Goal:** Update all screens for new flow: "pay on pickup" text, cancel from readyForPickup, store cancel with reason dialog, cancellation reason display.

- [x] `lib/src/features/checkout/presentation/payment_page.dart` — update `_PaymentMethodCard` to show "Оплата при получении" text; remove credit card icon/references
- [x] `lib/src/features/orders/presentation/client/order_detail_screen.dart` — R5: show cancel button for `readyForPickup` (`:168-171`); R4: show `cancellationReason` when `cancelledBy == CancelledBy.store`; R11: replace `paymentStatus` switch (`:154-159`) with static "Оплата при получении" text; handle null `paymentStatus` for old orders
- [x] `lib/src/features/orders/presentation/business/business_orders_screen.dart` — R3: add cancel button for active orders (`confirmed`/`preparing`/`readyForPickup`); cancel opens dialog with required reason field; calls `StoreOrdersRepository.cancelOrder(orderId, reason: reason)`
- [x] Add i18n strings to `app_en.arb`, `app_ru.arb`, `app_kk.arb`: "Оплата при получении", "Отменить заказ" (store), "Причина отмены", "Укажите причину", "Заказ отменён магазином", soldOut label
- [x] TDD: widget test — `OrderDetailScreen` shows cancel for `readyForPickup`; shows cancellation reason; `business_orders_screen` cancel button visible for active statuses, empty reason blocks confirm
- [x] Verify: `flutter analyze && flutter test`

### Phase 6 — Firestore rules tests + final validation
**Goal:** Emulator-based rules test and full build verification.

- [ ] TDD: rules test — store cannot write `orders.status` via client SDK → `PERMISSION_DENIED`; `updateOrderStatus`/`cancelOrder` callables still work _blocked: no Firebase emulator test infrastructure exists (vitest configured, @firebase/rules-unit-testing installed, but zero test files and no helpers)_
- [x] Run full validation: `flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test`
- [x] Run functions validation: `cd functions && npm run build`
- [x] Verify: `grep -ri stripe lib functions/src` returns empty

## Data layer changes
- `orders`: new optional fields `cancellationReason: string`, `cancelledBy: "customer"|"store"`; `paymentStatus` becomes optional (not written on new orders, backward-compatible)
- `offers`: new `status: "soldOut"` value; transition `active → soldOut` when `quantity == 0`; reverse when quantity restored and window still open
- `firestore.rules`: orders update → `isAdmin()` only
- Cloud Functions secrets: `STRIPE_WEBHOOK_SECRET`, `stripeSecretKey` removed

## External integrations
Stripe integration fully removed (callable, webhook, payment sheet, flutter_stripe packages). No external payment calls remain. Payment is offline at the store's terminal.

## Risks
- **Backward compatibility of nullable `paymentStatus`:** old orders have `paymentStatus: "paid"` — freezed `PaymentStatus?` with `@JsonKey` must parse both string and null; verify with unit test on real doc shape
- **Security rules deployment:** changing orders update to `isAdmin()` blocks store direct writes — must deploy rules **after** confirming all status changes go through Cloud Functions; coordinate with any other pending rules changes
- **`soldOut` → `active` race:** cancel and expire both may try to restore offer — both use transactions, so only one succeeds; verify no double-restore in concurrent scenario

## Out of scope
- Any online payment (Stripe/Kaspi/other) — removed now, future re-integration is separate
- Partial cancellation / per-item refund — cancel is order-level only
- Offline payment tracking in store dashboard — payment is outside the app
- Pagination/limits in `customerOrdersStream` and `watchOrdersListForStore`
- Reserve timeout for held quantity — was Stripe-only, now removed
- "Order confirmed" push on creation — separate notification improvement
