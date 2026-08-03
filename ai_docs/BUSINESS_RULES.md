# Business Rules

Domain rules, state machines, and known enforcement gaps. Last verified: 2026-08-02.

## Order status state machine

```
confirmed → preparing → readyForPickup → completed   (terminal)
   |             |              |
   └─────────────┴──────────────┴──────────→ cancelled  (terminal, via cancelOrder only)
   (any of the three, past pickupEndTime) ──→ expired    (terminal, via expireOrders)
```

- Forward transitions (`confirmed→preparing→readyForPickup→completed`) go through `updateOrderStatus`; its `VALID_TRANSITIONS` map deliberately excludes `cancelled` as a target — see `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md`.
- `readyForPickup` and `completed` are pickup-window-gated: `updateOrderStatus` refuses to move an order into either status before `pickupStartTime` or after `pickupEndTime` (`PICKUP_WINDOW_GATED_STATUSES`, `ai_specs/archive/042-enforce-pickup-window-status-transitions-spec.md`).
- `cancelled` is reachable from `confirmed`, `preparing`, or `readyForPickup` only, via `cancelOrder`, which also restores offer quantity and conditionally reactivates a `soldOut` offer if the pickup window is still open.
- `expired` is set only by the `expireOrders` scheduled function for orders whose `pickupEndTime` has passed while still in an active status.
- `completed` and `cancelled` and `expired` are all terminal — no function transitions an order out of them.

## Review-per-order: enforced via deterministic document ID

Exactly one review per order. `ReviewRepository.submitReview` writes to `reviews/{orderId}` (not an auto-ID); `firestore.rules` requires the doc id to equal `orderId` and verifies via `get()` on the order that `customerId == request.auth.uid`. A second write to the same order is evaluated as `update` (owner-only), never as a new `create` — see `ai_docs/FIRESTORE_GOTCHAS.md`.

## Item schedule constraints

`WeeklySchedule` (`lib/src/features/items/domain/weekly_schedule.dart`): `maxQuantity = 30` items per day-schedule entry, `maxWindowMinutes = 120` (a single pickup window cannot exceed 2 hours), and start time must be strictly before end time. Enforced client-side at the form-validation boundary; there is no server-side re-validation of these specific bounds (Cloud Functions trust the schedule shape but not these numeric limits).

## Offer visibility vs. pickup window

`offer.visibleFrom` (when the offer starts appearing to customers) is computed as the start of the day *before* the pickup date, in the store's local timezone — not the same as `offer.pickupStartTime` (when pickup actually opens). See `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` for the exact computation.

## Price model

`Item`/`Offer` carry both `price` (what the customer pays) and `estimatedValue` (the original, pre-discount value, used to compute `discountPercent` for display). `estimatedValue` falls back to the legacy field name `originalPrice` on old documents that predate the rename (`Item.fromJson`, see `ai_docs/FIRESTORE_GOTCHAS.md`) — never write `originalPrice` on new documents.

## Store verification flow

`storeDraft` (partner in-progress signup) → `fakeVerifyBusiness` (dev-only simulated check; see `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md`) or a future real verification → `completeMerchantOnboarding` writes `Store` + `Business` + `StoreShip` documents and restores the partner custom claim in one pass (`ai_specs/archive/039-fix-onboarding-idempotency-claims-spec.md`). There is no intermediate "pending review" state exposed to the partner today — verification either hasn't started, is in the draft, or is done.

## Partner roles & permissions

`StoreRole` enum: `owner`, `operator`, `employer` (`lib/src/features/store/domain/store_ship.dart`). `owner` has full access; `operator` is meant to exclude financials; `employer` is defined in the enum but has no distinct enforcement anywhere yet — treat it as reserved, not implemented. **Server-side authorization does not check `StoreRole` at all** — `assertStoreAccess` only checks whether a `storeShips/{storeId}_{uid}` document exists (or, as a legacy fallback, `stores/{storeId}.ownerId == uid`), granting the same access regardless of role. Role-based restriction, if it exists at all, is UI-only (hiding tabs/buttons) — do not rely on `StoreRole` for a security boundary in new server code.

## See also

- `ai_docs/FIRESTORE_GOTCHAS.md` — the documents these rules read/write
- `ai_docs/CLOUD_FUNCTIONS_GOTCHAS.md` — the functions enforcing these transitions
- `ai_docs/ROUTING_DECISIONS.md` — how partner/admin roles gate navigation
