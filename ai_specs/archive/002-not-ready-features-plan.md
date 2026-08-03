---
title: Not Ready Features
status: done
date: 2026-05-12
type: feature
---

# Plan: Launch Readiness — Closed Beta

Source: ai_specs/002-not-ready-features-spec.md

## Overview

Bring both sarqyt apps (client + business) to closed beta readiness across 8 stages. Work starts with Cloud Function fixes (payment flow, order lifecycle, security) since they are foundational, then moves to Firestore rules, Flutter auth flows, push notifications, business app UI, client discovery search, and finally the review schema change + item ratings tab. Each stage is independently deployable and verifiable.

## Stages

### Stage 1: Cloud Functions — Payment & Order Fixes

**Goal:** Fix the server-side payment and order lifecycle: webhook gaps, expireOrders quantity restore, updateOrderStatus transaction + cancel overlap, cancelOrder staff auth.

**Files to modify:**
- `functions/src/features/payments/functions/stripe-webhook.ts` — add `updatedAt` to order creation, add `payment_intent.payment_failed` handler
- `functions/src/features/orders/functions/expire-orders.ts` — restore offer quantity per order, use `serverTimestamp()` for `updatedAt`, add `.limit(500)` safety
- `functions/src/features/orders/functions/update-order-status.ts` — wrap in transaction, remove `cancelled` from `VALID_TRANSITIONS`
- `functions/src/features/orders/functions/cancel-order.ts` — add `staffIds` check matching `updateOrderStatus` pattern

**Steps:**
- [x] ~~In `stripe-webhook.ts`: add `updatedAt`...~~ moot — `stripe-webhook.ts` deleted entirely (Stripe removed, `ai_specs/archive/012-refactor-booking-flow-plan.md`)
- [x] ~~`payment_intent.payment_failed` handler~~ moot — same reason
- [x] `expire-orders.ts` — per-order transaction, quantity restore, `.limit(500)` — done via `ai_specs/archive/036-expire-orders-transaction-order-spec.md`
- [x] `update-order-status.ts` — wrapped in `db.runTransaction()`, `cancelled` excluded from `VALID_TRANSITIONS` — done via `ai_specs/archive/012-refactor-booking-flow-plan.md`
- [x] `cancel-order.ts` staff auth — uses `assertStoreAccess(uid, storeId)` (storeShips-based, superset of a `staffIds` check) — done via `ai_specs/archive/037-cancel-order-transaction-order-spec.md`

**Verification:** covered by `functions/src/features/orders/functions/expire-orders.test.ts`, `cancel-order.test.ts`, `update-order-status.test.ts` (vitest + Firestore emulator). `payment_failed` verification is moot — no payment webhook exists anymore.

---

### Stage 2: Enable Stripe Payment Flow (Flutter + Webhook) — OBSOLETE

**Superseded 2026-08-02:** `ai_specs/archive/012-refactor-booking-flow-plan.md` made the opposite decision — Stripe was fully removed, payment is offline at the store counter. `payWithStripe`, `createPayment`, `stripe-webhook.ts`, `flutter_stripe` no longer exist in this codebase. Do not implement this stage.

**Goal (historical):** Switch client checkout from `reserveOffer()` to `payWithStripe()` so real Stripe payments work end-to-end.

**Files to modify:**
- `lib/src/features/checkout/application/checkout_service.dart` — uncomment `payWithStripe()`, update `pay()` to call it, keep `reserveOffer()` as fallback method
- `lib/src/features/checkout/presentation/payment_page.dart` — verify it calls the updated `pay()` flow correctly

**Steps:**
- [ ] In `checkout_service.dart`: uncomment the `payWithStripe()` method (lines 64-114). Verify it uses `paymentRepositoryProvider` to call `createPayment`, then opens Stripe PaymentSheet, then confirms order via `clientOrdersRepositoryProvider`
- [ ] Rename current `pay()` to `payWithReservation()` (keep for testing). Create new `pay()` that calls `payWithStripe()` flow
- [ ] Verify `payment_page.dart` calls `pay()` correctly and handles loading/error states
- [ ] Test end-to-end with Stripe test keys: select offer → pay → PaymentSheet opens → confirm → webhook fires → order appears in Firestore

**Verification:**
- Run client app with Stripe test mode. Complete a purchase. Verify order document created in Firestore with `paymentIntentId`. Verify offer quantity decremented. Cancel a payment in PaymentSheet — verify quantity restored via webhook.

---

### Stage 3: Firestore Rules — Review Validation

**Goal:** Secure review creation: only the order's customer can review, one review per order.

**Files to modify:**
- `firestore.rules` — update `reviews` match block (lines 121-125)

**Steps:**
- [x] Update review `create` rule: require `id == request.resource.data.orderId`, fetch the order document via `get()`, verify `request.auth.uid == orderDoc.data.customerId` (`firestore.rules:155-165`)
- [x] Add one-review-per-order guard: deterministic review document ID = `orderId` itself (`ReviewRepository.submitReview`, `lib/src/features/review/data/review_repository.dart`) — a second create at the same path is evaluated as `update` (owner-only), not `create`, so Firestore's own path uniqueness prevents duplicates without a separate query
- [x] Keep `allow read: if true` (reviews are public) — unchanged
- [x] Keep `allow update, delete` restricted to review owner — unchanged
- [x] Test rules with Firebase emulator: verify customer can review their order, cannot review someone else's order, cannot create duplicate review for same order — `functions/test/firestore-rules.test.ts` `describe("reviews")`, 3 new cases added (own-order create, someone-else's-order deny, second-write routes to update)

**Verification:**
- `firebase emulators:exec --only firestore "npx vitest run test/firestore-rules.test.ts"` — 43/43 passed. `flutter analyze` clean. `cd functions && npm run lint && npm run build` clean.

---

### Stage 4: Auth Flows — Forgot Password + Remove Test Credentials

**Goal:** Implement forgot password for both apps, remove hardcoded test credentials from business sign-in.

**Files to modify:**
- `lib/src/features/auth/data/auth_repository.dart` — add `sendPasswordResetEmail()` method
- `lib/src/features/auth/presentation/sign_in_business/sigin_in_business_screen.dart` — remove hardcoded credentials from `initState`, wire forgot password to real flow
- `lib/src/features/auth/presentation/sign_in_client/email_password_sign_in_screen.dart` — add forgot password link

**Files to create:**
- `lib/src/features/auth/presentation/forgot_password/forgot_password_dialog.dart` — reusable dialog with email input + send reset email

**Steps:**
- [x] `auth_repository.dart` — `sendPasswordResetEmail(String email)` calling `_auth.sendPasswordResetEmail(email: email)`; also added to `FakeAuthRepository` (throws `UserNotFoundException` for unknown emails, matching real Firebase Auth behavior) and the `_FakeAuthRepo` test double in `verify_email_controller_test.dart`
- [x] `ForgotPasswordDialog` (`lib/src/features/auth/presentation/forgot_password/forgot_password_dialog.dart`) — email field, validation reusing `EmailPasswordValidators`, "Send reset link" / success state, backed by a new `ForgotPasswordController` (`AsyncValue.guard` pattern, same as `SignInBusinessController`). Reusable by both apps via `showForgotPasswordDialog(context, initialEmail: ...)`
- [x] `sigin_in_business_screen.dart` — removed the hardcoded `test@test.com`/`12345678` `initState` entirely; "Forgot password?" now opens `ForgotPasswordDialog` (was `showNotImplementedAlertDialog`); also dropped an incidental `!_submitted` gate that had made the link untappable until the first failed login attempt
- [x] `email_password_sign_in_screen.dart` — "Forgot password?" link added below the password field, shown only for the `signIn` form type (hidden during registration)
- [x] Dialog pre-fills from whatever the user already typed in the sign-in email field
- [x] New unit tests: `test/src/features/auth/presentation/forgot_password/forgot_password_controller_test.dart` (known email → reset sent + `true`; unknown email → `false`)

**Verification:** `flutter analyze`, `dart run custom_lint`, `flutter test --exclude-tags golden` (242/242 passed, incl. 2 new) — all clean. Manual QA (real Firebase Auth reset email delivery) not run — no device/emulator Auth UI check performed this session.

---

### Stage 5: Push Notification Deep Linking (Android)

**Goal:** Notification taps navigate to order detail screen. Foreground notifications display via `flutter_local_notifications`.

**Files to modify:**
- `pubspec.yaml` — add `flutter_local_notifications` dependency
- `lib/src/features/notifications/data/push_notification_service.dart` — implement deep linking and foreground notification display
- `android/app/src/main/AndroidManifest.xml` — add notification channel metadata if needed

**Steps:**
- [x] ~~Add `flutter_local_notifications`~~ — deliberately not adopted; see G1 in `ai_specs/archive/034-order-flow-notifications-plan.md` (Android channel declared via `AndroidManifest.xml` meta-data instead)
- [ ] Foreground notification display via `flutter_local_notifications` — explicitly out of scope in 034 ("`onMessage` остаётся логированием"), genuinely still not implemented if a foreground banner is wanted
- [x] Deep linking (background + terminated taps → order detail / dashboard) — done via `ai_specs/archive/034-order-flow-notifications-plan.md` Phase 5: `push_deep_link.dart`, `push_notification_bootstrap.dart`, `deep_link_applier.dart`
- [x] `getInitialMessage` navigation timing — done, `DeepLinkApplier` polls the router every 300ms until ready or a 30s timeout

**Verification:** manual QA-8 passed per user confirmation (see `ai_specs/archive/034-order-flow-notifications-plan.md`). Foreground in-app banner remains unimplemented by design — re-open as a separate spec if needed.

---

### Stage 6: Business App — Settings Tabs + Order Cancel

**Goal:** Implement Account tab, Team tab in business settings, and cancel button on business order cards.

**Files to modify:**
- `lib/src/features/business_console/presentation/settings_screen.dart` — replace "Coming soon" placeholders for Account and Team tabs
- `lib/src/features/orders/presentation/business/business_orders_screen.dart` — add cancel button to `_BusinessOrderCard`

**Files to create:**
- `lib/src/features/business_console/presentation/settings/account_settings_content.dart` — Account tab implementation
- `lib/src/features/business_console/presentation/settings/team_settings_content.dart` — Team tab implementation

**Steps:**
- [x] `AccountSettingsContent` — displays current user email (`authRepositoryProvider.currentUser`), "Change password" (confirm dialog → `sendPasswordResetEmail` to the account's own email, reusing Stage 4's infra) and "Sign out" (confirm dialog → `authRepository.signOut()`) buttons. Built inline in `settings_screen.dart`, matching how `TeamSettingsContent` was actually implemented in 021 — a separate `account_settings_content.dart` file wasn't warranted for this size. Backed by a new `AccountSettingsController` (`lib/src/features/business_console/presentation/settings/account_settings_controller.dart`, `AsyncValue.guard` pattern). Deviated from the original plan's "Change Password" flow (current+new password fields) — reset-email is simpler, has no re-auth requirement, and reuses infra just built in Stage 4
- [x] `TeamSettingsContent` — done via `ai_specs/archive/021-team-settings-content-spec.md`
- [x] `settings_screen.dart` — `AccountSettingsContent` placeholder replaced
- [x] Business order cancel button — done via `ai_specs/archive/012-refactor-booking-flow-plan.md` (`business_orders_screen.dart` `_cancelOrder()`, reason dialog)
- [x] New tests: `test/src/features/business_console/presentation/settings/account_settings_content_test.dart` (shows email; sign-out requires confirmation then calls `signOut`; dismissing confirmation does not sign out)

**Verification:** `flutter analyze`, `dart run custom_lint`, `flutter test --exclude-tags golden` (245/245 passed, incl. 3 new) — all clean. Manual device QA (real password-reset email delivery, sign-out redirect) not run this session.

---

### Stage 7: Client App — Discovery Search

**Goal:** Add search bar to discovery screen that filters offers by store name or item name.

**Files to modify:**
- `lib/src/features/offers/presentation/offer_list/discover_app_bar.dart` — add search TextField

**Files to create:**
- `lib/src/features/offers/application/offer_search_provider.dart` — search query state provider

**Steps:**
- [x] ~~separate `offerSearchQueryProvider`~~ — instead added `searchQuery` directly to the existing `DiscoverFilter` (`lib/src/features/offers/application/discover_filter.dart`), reusing the pure, already-tested `applyFilter` pipeline instead of introducing a second, parallel filtering path. `reset()` deliberately preserves `searchQuery` (it's an app-bar concern, not a "clear filters" bottom-sheet concern); excluded from `hasActiveFilters()`'s badge indicator for the same reason
- [x] `DiscoverAppBar` — converted to `ConsumerStatefulWidget`; search icon toggles the title between `Text` and an autofocused `TextField` (back arrow to close, clear icon while typing), 300ms debounce before calling `setSearchQuery`
- [x] `applyFilter` — matches `offer.storeName` or `offer.name`, case-insensitive `contains`; empty query returns all
- [x] Empty state — already handled generically by `DiscoverScreen`'s existing `context.loc.noOffersFound` when the filtered list is empty; no separate empty-state widget needed
- [x] Map view — `DiscoverMapContent` already renders from the same `filteredOffersProvider` output as the list, so search applies to both without extra wiring

**New tests:** `test/features/offers/discover_filter_test.dart` (+5: empty query, store-name match, item-name match, no-match, combines with other filters); `test/src/features/offers/presentation/offer_list/discover_app_bar_test.dart` (new, 3 cases: search icon opens field, debounced update, back button clears)

**Verification:** `flutter analyze`, `dart run custom_lint`, `flutter test --exclude-tags golden` (254/254 passed, incl. 8 new) — all clean. Manual on-device QA not run this session.

---

### Stage 8: Item Calendar Tab + Item Ratings Tab (with Review Schema Change)

**Goal:** Implement Calendar and Ratings tabs on the business item screen. Requires denormalizing `itemId` onto review documents.

**Files to modify:**
- `lib/src/features/review/domain/review.dart` — add optional `itemId` field
- `lib/src/features/review/domain/review.freezed.dart` — regenerate
- `lib/src/features/review/domain/review.g.dart` — regenerate
- `lib/src/features/review/data/review_repository.dart` — add `itemId` to `submitReview()`, add `watchItemReviews(itemId)` method
- `lib/src/features/items/presentation/item_screen/item_screen.dart` — replace Calendar and Ratings placeholders
- `functions/src/features/payments/functions/stripe-webhook.ts` — include `itemId` in order document (already has `offer?.productId`)
- `functions/src/features/payments/functions/reserve-offer.ts` — already includes `itemId` in order creation

**Files to create:**
- `lib/src/features/items/presentation/item_screen/calendar_content.dart` — Calendar tab widget
- `lib/src/features/items/presentation/item_screen/ratings_content.dart` — Ratings tab widget

**Steps:**
- [x] `Review` model — added `ItemID? itemId` (nullable, absent on pre-existing reviews). Regenerated via `build_runner`
- [x] `review_repository.dart` — `submitReview()` accepts optional `itemId`, writes it only when non-null; added `watchItemReviews(itemId)` + `itemReviewsStreamProvider`, same query/index/converter shape as `watchStoreReviews`
- [x] `ReviewController.submitReview` — reads `itemId` from the order via one-shot `clientOrdersRepository.watchOrder(orderId).first`, **not** threaded through route/query params. This was a deliberate deviation from the plan's original approach ("check the review submission screen and pass itemId through" implied a route param): the `review_prompt` push deep link (`ai_specs/archive/034-order-flow-notifications-plan.md`) only carries `storeId`/`storeName` in its payload, no `itemId` — reading from the order document works identically for both entry points (order-detail button vs. push deep link) without touching the Cloud Function push payload or the router
- [x] `CalendarContent(storeId, itemId)` (new file) — no `table_calendar` dependency added; a grouped-by-date list instead of a month grid, since `dailySyncOffers` only syncs ~2 days ahead (`DAYS_AHEAD = 2`) — a real calendar grid would render mostly-empty cells. Reuses the existing `storeId+productId+pickupStartTime` index via a new `BusinessOfferRepository.watchOffersForItem`
- [x] `RatingsContent(itemId)` (new file) — watches `itemReviewsStreamProvider(itemId)`, shows overall average + review count + individual review tiles (stars, comment, date). Category bars relabeled to **"Store experience"/"Offer quality"** (averages of the two real `Review` fields) instead of the old placeholder's four aspirational categories ("Collection experience", "Food quality", "Variety of contents", "Food quantity") that had no backing data and would have shown "––" forever
- [x] `item_screen.dart` — old inline `CalendarContent`/`CustomerRatingsContent`/`_RatingCategory` placeholder classes deleted (dead code), replaced with imports of the new widgets, passing `storeId`/`itemId`
- [x] `firestore.indexes.json` — new composite index `reviews (itemId ASC, createdAt DESC)`
- [x] `ai_docs/FIRESTORE_GOTCHAS.md` — documented the `itemId` denormalization and why it's read from the order rather than passed through navigation

**New tests:** `test/features/review/review_model_test.dart` (+2: itemId parses, itemId null for old docs); `test/src/features/items/presentation/item_screen/calendar_content_test.dart` (new, 3 cases); `test/src/features/items/presentation/item_screen/ratings_content_test.dart` (new, 3 cases)

**Verification:** `flutter analyze`, `dart run custom_lint`, `flutter test --exclude-tags golden` (261/261 passed, incl. 8 new) — all clean. `firestore.indexes.json` change not yet deployed (`firebase deploy --only firestore:indexes` needs explicit go-ahead per project rules on Firestore changes). Manual on-device QA (real `dailySyncOffers` data, real review submission) not run this session.

---

## Firestore Changes

### Modified fields
| Collection | Field | Change |
|------------|-------|--------|
| `reviews` | `itemId` | New optional field (String). Denormalized from order → offer → item chain. Set at review creation time |

### Security rules
| Collection | Rule change |
|------------|-------------|
| `reviews` | `create`: add `orderId` validation — fetch order, verify `customerId == auth.uid`. Consider deterministic review ID (`review_{orderId}`) for uniqueness |

### Indexes
| Collection | Fields | Type |
|------------|--------|------|
| `reviews` | `itemId` ASC, `createdAt` DESC | Composite |

---

## Cloud Functions

| Function | Change type | Summary |
|----------|-------------|---------|
| `stripeWebhook` | Modified | Add `updatedAt` to order creation. Add `payment_intent.payment_failed` handler |
| `expireOrders` | Rewritten | Per-order transactions for quantity restore. `serverTimestamp()` for `updatedAt`. `.limit(500)` per query |
| `updateOrderStatus` | Modified | Wrap in transaction. Remove `cancelled` from valid transitions |
| `cancelOrder` | Modified | Add `staffIds` auth check |

---

## Test Coverage

| Area | How to test |
|------|-------------|
| `expireOrders` quantity restore | Emulator: create order, advance time past pickup window, trigger `expireOrders`, verify offer quantity incremented |
| `updateOrderStatus` transaction | Emulator: verify concurrent status updates don't corrupt state. Verify `cancelled` is rejected |
| `cancelOrder` staff auth | Emulator: call with staff UID, verify success. Call with random UID, verify denied |
| `payment_failed` webhook | Emulator: simulate failed payment event, verify quantity restored |
| Firestore rules for reviews | `firebase emulators:exec` with rule unit tests: own-order review ✓, other's order ✗, duplicate ✗ |
| Forgot password | Manual: trigger reset email, verify Firebase Auth sends it |
| Push notification deep link | Manual on Android device: receive notification, tap, verify navigation to order detail |
| Discovery search | Manual: type query, verify filtering works on both store name and item name |
| Business cancel button | Manual: tap cancel on confirmed order, verify status + quantity + refund |
| `flutter analyze` | Run after all stages complete — must pass with no errors |

---

## Closing note (2026-08-02)

All 8 stages resolved: Stages 1, 5 (deep-link portion), 6, 12-era transaction fixes were already done by later specs before this session; Stages 3, 4, 6 (Account tab), 7, 8 implemented and tested in this session. Two items remain intentionally unimplemented, not oversights:
- **Stage 2 (Stripe payment flow)** — obsolete, contradicted by `ai_specs/archive/012-refactor-booking-flow-plan.md` which fully removed Stripe. Do not implement.
- **Stage 5's foreground notification banner** (`flutter_local_notifications`) — explicitly out of scope per `ai_specs/archive/034-order-flow-notifications-plan.md`. Deep-link navigation from background/terminated taps works; only the in-app foreground banner is missing, and would need its own spec if wanted.

`firestore.indexes.json` gained a new composite index (`reviews (itemId ASC, createdAt DESC)`) this session — **not yet deployed**. Run `firebase deploy --only firestore:indexes` before the Ratings tab is used against production data, or the query will fail with `failed-precondition`.

## Risks

- **Stripe test mode availability**: PaymentSheet requires valid Stripe publishable key and webhook endpoint. Testing locally needs Stripe CLI for webhook forwarding (`stripe listen --forward-to localhost:5001/...`)
- **`flutter_local_notifications` setup complexity**: Android notification channels, permissions on Android 13+, and interaction with FCM can be finicky. May need `AndroidManifest.xml` changes
- **Calendar tab package choice**: If no calendar package is in dependencies, building a custom month-grid adds scope. Check if `table_calendar` is available or use a simple list-by-date approach
- **Review `itemId` backfill**: Existing reviews won't have `itemId` — Ratings tab will be empty for items with only pre-change reviews. Acceptable for beta per spec
- **`storeShips` vs `staffIds` sync**: Team tab reads `storeShips`, auth checks read `store.staffIds`. If these diverge, staff may see themselves in Team tab but fail auth on order operations. This is a known gap flagged in the spec — not addressed in this plan

## Out of Scope

Carried from spec — do NOT implement:
- Stripe Connect / merchant payouts
- Real business verification (BIN/IIN)
- iOS push notifications
- Kaspi Pay integration
- Admin dashboard / tools
- Email/SMS transactional notifications
- Multi-language support
- Offline/connectivity handling
- Avatar upload
- Google/SSO sign-in
- Performance/analytics screen
- Financials screen
- `dailySyncOffers` parallelism optimization
- Delete account
- Order confirmation screen after payment
- Dedicated favorites screen
- Map marker tap → offer detail
- Foreground notification sound/vibration
- Dashboard stats panel
- Item delete from UI
- `_processedEvents` cleanup
