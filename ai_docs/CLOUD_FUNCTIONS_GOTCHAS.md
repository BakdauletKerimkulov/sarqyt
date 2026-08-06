# Cloud Functions Gotchas

Non-obvious decisions, schedules, and retry logic behind `functions/src/index.ts`. Last verified: 2026-08-04 — this project has no payment integration; if you find a doc, comment, or dependency implying one, it's stale (see `ai_specs/archive/012-refactor-booking-flow-spec.md` for what was removed and why).

## Order creation: one path only

`reserveOffer` (callable, `functions/src/features/payments/functions/reserve-offer.ts`) is the **only** way an order is created. Payment happens offline at the store counter — there is no online payment integration. Do not reintroduce a second order-creation path without updating this doc and `firestore.rules`.

## Region split

- Scheduled functions and Firestore triggers set `region` explicitly per-function (`asia-south1` for `sendOrderReminders`, `onItemStatusChanged`, `onOrderStatusChanged`).
- Callables (`reserveOffer`, `cancelOrder`, `updateOrderStatus`, `deleteItem`, etc.) use the default region (`us-central1`) — no explicit `region` set.
- **`expireOrders` deploys in `us-central1`** (no explicit region) while `sendOrderReminders` explicitly sets `asia-south1` — a known, accepted region split from `ai_specs/archive/034-order-flow-notifications-plan.md` (G3). Do not add a global `setGlobalOptions({ region: ... })` — it would silently move every unset-region function and has not been evaluated for cost/latency impact.

## Schedules

| Function | Schedule | Why |
|---|---|---|
| `dailySyncOffers` | `every day 00:30` (UTC = 06:30 Almaty) | After midnight, before the morning rush of orders — regenerates upcoming offers from active items |
| `expireOrders` | `every 5 minutes` | Not a Firestore TTL: expiring an order needs a status transition (`expired`) + offer quantity restore + notification — TTL only deletes documents |
| `sendOrderReminders` | `every 5 minutes`, `asia-south1` | Pickup-window reminders (`beforeStart`/`midWindow`/`beforeEnd`) + delayed review prompt; see `ai_docs/solutions/` for the reminder-window logic |
| `cleanupOldData` | `every day 03:00` | Housekeeping for stale offers |

## Offer sync window

`DAYS_AHEAD = 2` (`functions/src/features/offers/services/build-expected-offers.ts`) — `dailySyncOffers`/`syncItemOffers` only materialize offers for today + the next 2 days, not further out. A one-time (non-recurring) item schedule produces a single offer, not a range.

## `visibleFrom` vs `pickupStartTime`

Offers for a future date become visible to customers the day *before* their pickup date (`visibleFrom = startOfDay(pickupDate - 1 day, storeTimeZone)`), computed in `functions/src/features/offers/functions/create-one-time-offer.ts` and `offer-timezone.ts`. `pickupStartTime`/`pickupEndTime` are the actual pickup window and are unrelated to when the offer becomes discoverable.

## `fakeVerifyBusiness`

Dev-only simulation of a government business-verification check. Introduces an artificial delay before marking a `businessDraft` verified. Never wired to a real registry lookup — real verification (BIN/IIN check) is explicitly out of scope for the current launch phase (`ai_specs/002-not-ready-features-plan.md`).

## `updateOrderStatus`: transaction + no-cancel guard

`update-order-status.ts` wraps the read-validate-write in `db.runTransaction()` to prevent TOCTOU races on concurrent status updates, and `VALID_TRANSITIONS` deliberately excludes `cancelled` as a target — cancellation must go through `cancelOrder`, which additionally restores offer quantity and reactivates a `soldOut` offer. Calling `updateOrderStatus` with `status: "cancelled"` is rejected by design, not an oversight.

## `cancelOrder` staff auth

Any signed-in user who is the order's `customerId` can cancel their own order. Otherwise, `assertStoreAccess(uid, storeId)` is used — the same helper `updateOrderStatus` uses — so store staff/owner permissions for cancellation always match staff permissions for status transitions. Do not add a separate `staffIds` check in `cancelOrder` alone; it would drift from `updateOrderStatus`.

## Secrets

None. No Cloud Function in this project uses `defineSecret` — the only secrets that ever existed belonged to the removed payment integration.

## See also

- `ai_docs/PROJECT.md` — full function list with one-line summaries
- `ai_docs/FIRESTORE_GOTCHAS.md` — the documents these functions read/write
- `ai_docs/BUSINESS_RULES.md` — the state machine these functions enforce
