# Spec: Launch Readiness — Closed Beta

Created: 2026-05-12
Status: refined

## Goal

Bring the sarqyt client and business apps to closed beta readiness — both apps launch simultaneously with Stripe payments enabled, core flows working end-to-end, and no broken stubs visible to users.

## Background

Codebase audit identified gaps across client app, business app, and Cloud Functions. This spec scopes only what's needed for **closed beta** (limited stores, known users). Stripe Connect payouts, real business verification, admin tools, email notifications, and iOS push notifications are deferred.

## Launch Scope Decisions

| Decision | Choice | Implication |
|----------|--------|-------------|
| Launch type | Closed beta | No App Store/Play Store review compliance needed yet |
| Payment model | Stripe payments (enable existing code) | Kaspi Pay deferred |
| Business verification | `fakeVerifyBusiness` (manual onboarding) | No BIN integration needed |
| Stripe Connect | Not needed | Merchant payouts handled outside app |
| Push notifications | Android only (no iOS dev account) | FCM works on Android emulators/devices |
| Apps launching | Client + Business simultaneously | Both must be beta-ready |

---

## Requirements

### Must Have — Critical Fixes

- [ ] **Enable Stripe payment flow**: `CheckoutController.pay()` must call `payWithStripe()` instead of `reserveOffer()`. The `payWithStripe()` method exists as a commented-out block in `checkout_service.dart:64-114` — uncomment and update. Keep `reserveOffer()` available as a fallback for testing without Stripe. Ensure `createPayment` → Stripe PaymentSheet → `stripeWebhook` → order creation works end-to-end.
- [ ] **Handle `payment_intent.payment_failed`** in `stripeWebhook`: restore offer `quantity` when payment fails. Use the same dedup pattern as `payment_intent.canceled` (event ID in `_processedEvents` + `FieldValue.increment`).
- [ ] **Fix `stripeWebhook` order creation**: add missing `updatedAt: serverTimestamp()` field to the order document created in `payment_intent.succeeded` handler (`stripe-webhook.ts:70-89`). Currently only sets `createdAt`.
- [ ] **Fix `expireOrders` to restore offer quantity**: when orders expire, increment `quantity` (not `quantityRemaining` — the field is `quantity`) on the associated offer. Each order must restore quantity in a separate transaction to avoid conflicts. Also fix `updatedAt` to use `serverTimestamp()` instead of `Timestamp.now()`.
- [ ] **Fix `updateOrderStatus` race condition + cancel overlap**: (1) Wrap the read-check-write in `db.runTransaction()` to prevent TOCTOU race on concurrent status updates. (2) Remove `cancelled` from `VALID_TRANSITIONS` — cancellation must go through `cancelOrder` which handles quantity restoration and Stripe refunds. Using `updateOrderStatus` with `cancelled` silently skips both.
- [ ] **Fix `cancelOrder` staff authorization**: currently only checks `ownerId` on store document, not `staffIds`. Staff members who can view orders and update statuses will get `permission-denied` when trying to cancel. Add staff check matching the pattern in `updateOrderStatus`.
- [ ] **Remove hardcoded test credentials** from business `SignInBusinessScreen.initState` (`sigin_in_business_screen.dart:65-66`: `test@test.com` / `12345678`).
- [ ] **Fix Firestore rules for reviews**: add `orderId` validation — only the customer who placed the order can create a review for it. Ensure one review per order at the rules level.
- [ ] **Forgot password flow**: implement for both client and business apps. Add `sendPasswordResetEmail(String email)` method to `AuthRepository` (does not exist yet). Business app currently shows `showNotImplementedAlertDialog` (`sigin_in_business_screen.dart:210`). Client app has no forgot password link at all — add one to the sign-in screen. Show confirmation message after email sent.

### Must Have — Incomplete Features

- [ ] **Push notification deep linking (Android)**: notification taps (`onMessageOpenedApp`, `getInitialMessage`) should navigate to the relevant order detail screen using `orderId` from notification data payload (already sent by `on-order-status-changed` trigger as `data: { orderId, status }`). Foreground notifications (`onMessage`) should show a local notification via `flutter_local_notifications`.
- [ ] **Text search in discovery**: add search bar to `DiscoverAppBar` that filters offers by `storeName` and `name` (item name) fields on the `Offer` model. Client-side filtering on top of existing geo-query stream results — no new Firestore queries needed for beta.
- [ ] **Business Settings — Account tab**: implement profile editing (name, email display, change password, sign out). Reuse patterns from client `AppSettingsScreen`.
- [ ] **Business Settings — Team tab**: display current staff list (from `storeShips`). Invite flow can be deferred, but the tab must show existing team members with their roles.
- [ ] **Item Calendar tab**: show a calendar view of upcoming offers generated from the item's schedule. Read-only is acceptable — uses data from `offers` collection filtered by `itemId`.
- [ ] **Item Ratings tab**: show reviews for this item's offers. **Schema change required**: denormalize `itemId` onto review documents at creation time — the current `Review` model only has `orderId`/`storeId`/`userId`, no `itemId` or `offerId`. Without denormalization, fetching reviews for an item requires a 3-step fan-out (item → offers → orders → reviews). Add `itemId` field to `Review` model and set it when creating reviews. Existing reviews without `itemId` will not appear in this tab (acceptable for beta).
- [ ] **Business-side order cancel**: add cancel button to `_BusinessOrderCard` for orders in `confirmed`/`preparing` status. Must call `cancelOrder` Cloud Function (not `updateOrderStatus` with `cancelled`) — only `cancelOrder` restores offer quantity and triggers Stripe refund.

### Nice to Have (if time permits)

- [ ] Delete account implementation (client + business)
- [ ] Order confirmation screen after successful payment
- [ ] Dedicated favorites screen in client profile section
- [ ] Map marker tap → navigate to offer detail
- [ ] Foreground notification sound/vibration
- [ ] Dashboard stats panel (bags sold today, revenue today)
- [ ] Item delete from UI (repository method exists, no UI)
- [ ] `_processedEvents` cleanup (add TTL or periodic purge)

---

## Technical Constraints

### Packages already available
- `flutter_stripe` / `flutter_stripe_web` — Stripe payment sheet
- `flutter_local_notifications` — needs to be added for foreground notifications
- `firebase_messaging` — already integrated
- `flutter_map` — map already works
- `geoflutterfire_plus` — geo queries already work

### Packages to add
- `flutter_local_notifications` — for foreground push notification display on Android

### Architecture decisions
- All changes follow existing feature-first structure (`domain/`, `data/`, `application/`, `presentation/`)
- Cloud Function fixes follow existing patterns (transactions, idempotency, `defineSecret`)
- New UI follows existing widget patterns (`ConsumerWidget`, `AsyncValueWidget`, `@riverpod` codegen)
- Firestore rule changes must be tested with emulator before deploy

### Data sources
- Reviews filtering by `itemId`: **denormalize `itemId` onto review documents** (current `Review` model has no `itemId`). Without this, it's a 3-step fan-out (item → offers → orders → reviews).
- Calendar tab: query `offers` where `itemId == X` and `pickupDate` within visible month range.
- Team tab: query `storeShips` where `storeId == currentStoreId`. Note: `storeShips` and `store.staffIds` are separate data sources — ensure they stay in sync or pick one as source of truth. `updateOrderStatus` uses `store.staffIds` for auth; Team tab reads `storeShips`.

---

## Edge Cases

### Payment flow
- User closes app during Stripe PaymentSheet → `payment_intent.canceled` fires eventually, quantity restored via existing webhook handler
- User has no internet after PaymentSheet confirms → webhook still fires server-side, order is created
- Double-tap on "Pay" button → existing `AsyncValue.isLoading` guard prevents double submission
- Payment fails (insufficient funds) → new `payment_intent.payment_failed` handler restores quantity

### Order expiry + quantity
- Multiple orders expire in same batch → each must restore quantity independently in separate transactions (not a single batch increment)
- Offer already deleted/expired when order expires → handle gracefully (log warning, skip quantity restore)
- Batch > 500 expired orders → add `.limit(500)` to each status query as a safety net. Current code has no limit and will crash if any single status accumulates >500 expired orders (e.g., scheduler outage)

### Search
- Empty search query → show all offers (no filter)
- No results → show empty state with message
- Special characters in query → sanitize for Firestore/client-side filter

### Push notifications
- FCM token missing → function already handles this (returns silently), acceptable for beta
- Notification tap when app is killed → `getInitialMessage` handles this, navigate after app init completes
- No `flutter_local_notifications` permission on Android 13+ → request notification permission at init

### Reviews
- Customer tries to review an order that already has a review → Firestore rule denies duplicate
- Customer tries to review someone else's order → Firestore rule checks `customerId` match

### Business settings
- Store has no staff besides owner → Team tab shows owner only with "Owner" badge
- Staff member removed while viewing team → stream updates UI automatically

---

## Out of Scope

- Stripe Connect / merchant payouts — handled outside app for beta
- Real business verification (BIN/IIN) — using `fakeVerifyBusiness`
- iOS push notifications — no developer account yet
- Kaspi Pay integration — deferred
- Admin dashboard / tools — manual for beta
- Email/SMS transactional notifications
- Multi-language support (locale switching)
- Offline/connectivity handling
- Avatar upload
- Google/SSO sign-in
- Performance/analytics screen (Coming soon is acceptable for beta)
- Financials screen (Coming soon is acceptable for beta)
- `dailySyncOffers` parallelism optimization (small store count in beta)

---

## Definition of Done

- [ ] All Must Have requirements implemented
- [ ] Stripe payment flow works end-to-end: select offer → pay → order appears in both client and business apps
- [ ] Order lifecycle works: confirmed → preparing → readyForPickup → completed (and cancel via `cancelOrder` at confirmed/preparing, with quantity restore and refund)
- [ ] Push notifications work on Android: new order → merchant sees notification → tap opens order
- [ ] Search works in discovery screen
- [ ] Business settings Account and Team tabs show real data
- [ ] Item Calendar and Ratings tabs show real data
- [ ] Forgot password works on both apps
- [ ] No hardcoded test credentials in any screen
- [ ] Firestore rules tested with emulator (especially review rules)
- [ ] `flutter analyze` passes
- [ ] Manual QA: complete a full order cycle (client purchase → business status updates → completion)
