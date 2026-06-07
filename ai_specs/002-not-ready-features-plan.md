# Plan: Launch Readiness — Closed Beta

Source: ai_specs/002-not-ready-features-spec.md
Created: 2026-05-12

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
- [ ] In `stripe-webhook.ts`: add `updatedAt: serverTimestamp()` to the order document in the `payment_intent.succeeded` handler (line 70-89)
- [ ] In `stripe-webhook.ts`: add `payment_intent.payment_failed` handler after the `payment_intent.canceled` block. Use identical dedup pattern (event ID in `_processedEvents` + `FieldValue.increment(quantity)` on offer)
- [ ] In `expire-orders.ts`: rewrite to process each order individually in a transaction — read order, read offer (if exists), restore `quantity` via `FieldValue.increment`, set order status to `expired` with `serverTimestamp()` for `updatedAt`. Add `.limit(500)` to each status query. Handle missing/expired offer gracefully (log warning, skip quantity restore)
- [ ] In `update-order-status.ts`: wrap the read-validate-write in `db.runTransaction()`. Remove `cancelled` from `VALID_TRANSITIONS` map (lines 12-17)
- [ ] In `cancel-order.ts`: after the `isCustomer` check (line 60-68), add `staffIds` check — read `storeSnap.data()?.staffIds` and check if `uid` is included, matching the pattern in `updateOrderStatus` (line 56)

**Verification:**
- Deploy to emulator. Test: create order via `reserveOffer`, then `expireOrders` should restore offer quantity. Verify `updateOrderStatus` rejects `cancelled` status. Verify staff can call `cancelOrder`. Verify `payment_failed` webhook restores quantity.

---

### Stage 2: Enable Stripe Payment Flow (Flutter + Webhook)

**Goal:** Switch client checkout from `reserveOffer()` to `payWithStripe()` so real Stripe payments work end-to-end.

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
- [ ] Update review `create` rule: require `request.resource.data.orderId` exists, fetch the order document via `get()`, verify `request.auth.uid == orderDoc.data.customerId`
- [ ] Add one-review-per-order guard: use a deterministic review document ID (e.g., `review_${orderId}`) so Firestore's document-level uniqueness prevents duplicates. Alternatively, if the current ID scheme must stay, add a composite query check in the Cloud Function or rely on client-side `hasReviewForOrder()` (already exists in `ReviewRepository`)
- [ ] Keep `allow read: if true` (reviews are public)
- [ ] Keep `allow update, delete` restricted to review owner
- [ ] Test rules with Firebase emulator: verify customer can review their order, cannot review someone else's order, cannot create duplicate review for same order

**Verification:**
- Run `firebase emulators:exec --only firestore` with rule tests. Verify: (1) customer creates review for own order ✓, (2) customer creates review for other's order ✗, (3) duplicate review for same order ✗, (4) any signed-in user reads reviews ✓.

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
- [ ] In `auth_repository.dart`: add `Future<void> sendPasswordResetEmail(String email)` that calls `_auth.sendPasswordResetEmail(email: email)`
- [ ] Create `ForgotPasswordDialog` — a simple dialog with email `TextField`, "Send Reset Link" button, calls `authRepository.sendPasswordResetEmail()`, shows success/error message. Reusable by both apps
- [ ] In `sigin_in_business_screen.dart`: remove lines 65-66 (hardcoded `test@test.com` / `12345678` in `initState`). Replace `showNotImplementedAlertDialog` (line 210) with `showDialog` → `ForgotPasswordDialog`
- [ ] In `email_password_sign_in_screen.dart`: add a "Forgot password?" `TextButton` below the password field. On tap, show `ForgotPasswordDialog`
- [ ] Pre-fill the dialog email field with whatever the user has already typed in the sign-in email field

**Verification:**
- Launch business app — verify no pre-filled credentials on sign-in screen. Tap "Forgot password" → enter email → verify Firebase sends reset email (check emulator Auth logs). Repeat for client app.

---

### Stage 5: Push Notification Deep Linking (Android)

**Goal:** Notification taps navigate to order detail screen. Foreground notifications display via `flutter_local_notifications`.

**Files to modify:**
- `pubspec.yaml` — add `flutter_local_notifications` dependency
- `lib/src/features/notifications/data/push_notification_service.dart` — implement deep linking and foreground notification display
- `android/app/src/main/AndroidManifest.xml` — add notification channel metadata if needed

**Steps:**
- [ ] Add `flutter_local_notifications` to `pubspec.yaml`, run `flutter pub get`
- [ ] In `push_notification_service.dart`: initialize `FlutterLocalNotificationsPlugin` in `initialize()`. Create a default Android notification channel. Request notification permission on Android 13+ (`_messaging.requestPermission()` already called, verify it handles POST_NOTIFICATIONS)
- [ ] Implement foreground notification display: in the `onMessage` listener (currently just logs), call `flutterLocalNotificationsPlugin.show()` with the notification title/body from the FCM message. Pass `orderId` as notification payload
- [ ] Implement deep linking: add a navigation callback that receives `orderId` and navigates to order detail. For `onMessageOpenedApp` and `getInitialMessage`, extract `orderId` from `message.data['orderId']` and navigate using GoRouter. The callback needs access to the router — pass `GoRouter` instance or use a global navigator key
- [ ] Handle `onSelectNotification` callback from `flutter_local_notifications` (when user taps foreground notification) — same navigation logic using `orderId` from payload
- [ ] Ensure `getInitialMessage` navigation happens after app bootstrap completes (use `WidgetsBinding.instance.addPostFrameCallback` or similar)

**Verification:**
- Run on Android device/emulator. Create an order. Update order status from business app. Verify: (1) foreground notification appears as a banner, (2) tapping notification in background opens order detail, (3) tapping notification when app is killed opens order detail after boot.

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
- [ ] Create `AccountSettingsContent`: display current user name, email (from `FirebaseAuth.instance.currentUser`), "Change Password" button (sends password reset email to current user's email), "Sign Out" button (calls `authRepository.signOut()`). Reuse patterns from client `AppSettingsScreen`
- [ ] Create `TeamSettingsContent`: watch `storeShips` collection where `storeId == currentStoreId` (use `currentStoreShipProvider` to get storeId). Display list of team members with name, role badge (Owner/Operator/Employer from `StoreRole` enum). Handle empty state (owner only)
- [ ] Update `settings_screen.dart`: replace `AccountSettingsContent` and `TeamSettingsContent` placeholder classes with imports of the new widgets
- [ ] In `_BusinessOrderCard`: add a cancel button (e.g., outlined "Cancel" button or icon button) visible when order status is `confirmed` or `preparing`. On tap, show confirmation dialog, then call `cancelOrder` Cloud Function via the orders repository. Show loading state during cancellation

**Verification:**
- Launch business app. Navigate to Settings → Account tab shows user info, sign out works. Team tab shows store members with roles. Navigate to Orders → confirmed order shows cancel button → tap cancel → order status changes to cancelled, offer quantity restored.

---

### Stage 7: Client App — Discovery Search

**Goal:** Add search bar to discovery screen that filters offers by store name or item name.

**Files to modify:**
- `lib/src/features/offers/presentation/offer_list/discover_app_bar.dart` — add search TextField

**Files to create:**
- `lib/src/features/offers/application/offer_search_provider.dart` — search query state provider

**Steps:**
- [ ] Create a simple `offerSearchQueryProvider` (StateProvider<String>) to hold the current search text
- [ ] In `DiscoverAppBar`: add a search bar — either a `TextField` in the AppBar bottom, or toggle between title and search field using a search icon button. Debounce input (300ms) before updating the search provider
- [ ] In the offer list widget (wherever offers are rendered from the geo-query stream): filter the offer list by matching `offer.storeName` or `offer.name` against the search query (case-insensitive `contains`). When query is empty, show all offers
- [ ] Handle empty results: show an empty state widget with a "No offers found" message
- [ ] Ensure search works in both list and map views (if map view exists alongside list view)

**Verification:**
- Launch client app. Type a store name in search → only matching offers appear. Type an item name → matching offers appear. Clear search → all offers return. Type nonsense → empty state shown.

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
- [ ] Add `String? itemId` field to `Review` model in `review.dart`. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate
- [ ] In `review_repository.dart`: update `submitReview()` to accept and store `itemId`. Add `Stream<List<Review>> watchItemReviews(String itemId)` that queries reviews where `itemId == itemId`, ordered by `createdAt` descending
- [ ] Verify that order documents already contain `itemId` (stripe-webhook uses `offer?.productId`, reserve-offer uses offer's productId). The review creation flow needs to read `itemId` from the order when submitting a review — check the review submission screen and pass `itemId` through
- [ ] Create `CalendarContent(itemId)`: query `offers` where `productId == itemId` (note: offers use `productId` not `itemId`) for the visible month range. Display in a simple calendar grid or list grouped by date. Read-only. Use `table_calendar` if already in dependencies, otherwise a simple custom grid
- [ ] Create `RatingsContent(itemId)`: watch reviews via `watchItemReviews(itemId)`. Show aggregate average rating at top, then list of individual reviews with rating stars, comment, and date. Handle empty state
- [ ] In `item_screen.dart`: replace `CalendarContent` and `CustomerRatingsContent` placeholder classes with imports of the new widgets, passing `itemId` from the current item
- [ ] Add Firestore composite index for `reviews` collection: `itemId` ASC + `createdAt` DESC (add to `firestore.indexes.json`)

**Verification:**
- Create an item with a schedule, let `dailySyncOffers` generate offers. Calendar tab shows upcoming offers on correct dates. Submit a review for an order of this item (with `itemId` included). Ratings tab shows the review. Run `flutter analyze` — passes.

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
