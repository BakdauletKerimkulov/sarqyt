# Firestore Gotchas

Non-obvious schema decisions, ID patterns, and denormalization choices that can't be inferred from the code alone. Last verified: 2026-08-02.

## Offers is a top-level collection, not nested under stores

`offers/{offerId}` lives at the root, not `stores/{storeId}/offers/{offerId}`. Reason: geo-queries via `geoflutterfire_plus` require a top-level collection with a `geo` field indexed for `geohash` range queries — collection-group queries across nested subcollections don't support this cleanly. Each offer denormalizes `storeId`, `storeName`, `productId` (the source `Item` id) to avoid joins.

## Order writes are server-only

`orders/{orderId}`: `allow create: if false` — the only way to create an order is `reserveOffer` (a callable, admin SDK). `allow update: if isAdmin()` only (see `firestore.rules`) — status transitions go through `updateOrderStatus`/`cancelOrder` callables, never a direct client write, even for store staff. This was tightened in `ai_specs/archive/012-refactor-booking-flow-plan.md` (previously store staff could write `status` directly).

## StoreShip composite document ID

`storeShips/{storeId}_{userId}` — deterministic, not an auto-ID. Lets `assertStoreAccess(uid, storeId)` (`functions/src/shared/helpers/assert-store-access.ts`) do a direct `.doc(id).get()` instead of a query, and makes "does this user have access to this store" a cheap point read from every callable that needs it.

## reserveOffer idempotency: deterministic order ID

`reserveOffer` (`functions/src/features/payments/functions/reserve-offer.ts`) derives the order document ID as `${uid}_${idempotencyKey}` where `idempotencyKey` is generated client-side once per checkout attempt and resent on retry. If the doc already exists inside the transaction, the function returns success without re-decrementing offer quantity. There is no separate `_processedEvents` collection — event-dedup was needed by the payment webhook that used to exist, and went away with it.

## StoreDraft TTL

`storeDrafts/{draftId}.expiresAt = now + 3 days`, relies on a Firestore native TTL policy on the `expiresAt` field to auto-delete abandoned onboarding drafts. **This must be configured in the Firebase console** — Firestore TTL policies are not part of `firestore.indexes.json` and are not deployed by `firebase deploy`. `TODO: verify TTL policy is actually configured in the sarqyt-1ab95 console.`

## orderCounter / orderNumber

`stores/{storeId}.orderCounter` — an integer counter incremented transactionally by the `onOrderCreated` trigger (`functions/src/features/triggers/orders.ts`) each time an order is created for that store. The returned `nextNumber` is written to `orders/{orderId}.orderNumber` — a short, human-readable, per-store sequential number (not a global one), used in push notification text and the business orders list. Never derive `orderNumber` from the order snapshot inside the trigger — it must come from the transaction's return value to avoid a stale read.

## Denormalized fields

- `offers/{offerId}`: `storeName`, `storeAddress` — copied from the store at sync time, patched by `dailySyncOffers`/`syncItemOffers` when the store profile changes. Avoids a join on every discover-screen render.
- `orders/{orderId}`: `storeName` only (no `storeAddress`) — the order detail screen doesn't need the address once the order exists.

## Geohash precision

Offer geo-queries use geohash precision 4 (~39km × 20km cell size) — coarse enough to cover a Kazakhstan city in one or two cells, fine enough to keep query fan-out small. Do not increase precision without checking `client_offer_repository.dart` query radius logic.

## Legacy `originalPrice` → `estimatedValue` fallback

`Item.fromJson` (`lib/src/features/items/domain/item.dart:108`) reads `json['estimatedValue'] ?? json['originalPrice']` — `originalPrice` was the original field name before a rename; old item documents still have it. Do not remove the fallback without a migration; do not write `originalPrice` on new documents.

## Reviews: deterministic ID enforces ownership + one-per-order

`reviews/{orderId}` — the document ID is the order ID (`ReviewRepository.submitReview`), not an auto-ID. `firestore.rules` requires `id == request.resource.data.orderId` on create, plus `get(/databases/$(database)/documents/orders/$(id)).data.customerId == request.auth.uid` — only the order's actual customer can create that review. Since the ID is deterministic, any second write to the same path is evaluated as `update` (owner-only), not `create` — the same order can never end up with two review documents. `ReviewRepository.hasReviewForOrder()` remains a client-side pre-check for UX only; the rule is the real guard.

`reviews/{orderId}.itemId: string?` — denormalized from the order at review-creation time (`ReviewController.submitReview` reads `order.itemId` via a one-shot `watchOrder(orderId).first`, not threaded through navigation params — correct regardless of whether the reviewer arrived via the order-detail button or a `review_prompt` push deep link, since the latter's payload doesn't carry `itemId`). Absent on reviews created before this field existed — `RatingsContent`/`itemReviewsStreamProvider` only see reviews written after the field was added. Not security-validated in rules (display/query convenience only, not access control). Composite index `reviews (itemId ASC, createdAt DESC)` backs `watchItemReviews`.

## Custom claims in rules: always `token.get(name, default)`

Reading a claim as `request.auth.token.role` does **not** yield `null` or `false` when the claim is absent — it raises `Property role is undefined` and kills the whole expression, including the branches after `||`. Use `request.auth.token.get('role', '')` / `.get('canCreateStore', false)` everywhere.

This already cost one production bug: in `storage.rules` the unsafe form sat in `isAdmin()`, first in an `||` chain, so a store member without a `role` claim could not upload any image at all — the later `hasStoreAccess()` branch never got evaluated (fixed in `ai_specs/archive/046-prepare-region-migration-plan.md`, Phase 3). The same form survived in `firestore.rules` `isPartner()`/`canCreateStore()` and was harmless only by accident of branch order (`ai_specs/archive/048-fix-unsafe-custom-claim-reads-spec.md`).

Both rule files are clean as of 2026-08-16. The regression is not detectable by symptom — grep for `request.auth.token.` without `.get(` instead. Note that a green emulator run does not flag it either: a crashed condition and a legitimate `deny` are the same outcome for `assertFails`.

## See also

- `ai_docs/PROJECT.md` — module overview, general schema tables
- `ai_docs/BUSINESS_RULES.md` — domain state machines and constraints that live on top of this schema
- `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` — the functions that write these documents
