---
title: expireOrders never marks orders expired past pickup window
status: done
date: 2026-07-30
type: fix
severity: S
references: []
---

## Symptom
An order stuck in `confirmed`/`preparing`/`readyForPickup` never flips to `expired` once its pickup window closes, even though the `expireOrders` scheduled function runs every 5 minutes. Reported with a `preparing` order and an 18:00–20:00 pickup window that stayed `preparing` well past 20:00.

## Root cause
In `functions/src/features/orders/functions/expire-orders.ts:36-75` (transaction body), `tx.update(doc.ref, ...)` (a write on the order) ran before `tx.get(offerRef)` (a read on the offer, for quantity restore). Firestore transactions require all reads before any writes; every invocation that reached the offer-restore branch threw `Error: Firestore transactions require all reads to be executed before all writes.`, aborting the transaction so the order's status update never committed. Confirmed live via `firebase functions:log --only expireOrders` — the error fired on every 5-minute run in production. The sibling function `cancel-order.ts` has the identical pattern and is confirmed broken the same way in production logs, but is out of scope for this fix per user decision (reported bug was `expireOrders` only).

## Fix
- **Files changed:** `functions/src/features/orders/functions/expire-orders.ts`
- **Failing test that catches the regression:** `functions/src/features/orders/functions/expire-orders.test.ts::expireOrders > expires a preparing order past its pickup window and restores offer quantity` (Firestore-emulator smoke test, per `testing.md`'s "never mock the backend SDK client" rule)
- **`ai_toolkit/` rules applied:** `testing.md → Server functions: smoke the handler against the local emulator`
- **Toolkit deviations:** none
- **Description:** Reordered the transaction body in `expireOrders` so `tx.get(offerRef)` runs before `tx.update(doc.ref, ...)`, satisfying Firestore's read-before-write transaction requirement. The order's status transition to `expired` and the offer quantity restore now both commit correctly.

## Known follow-up (not fixed here)
`functions/src/features/orders/functions/cancel-order.ts` has the same read-after-write bug (write on the order before `tx.get(offerRef)`) and is confirmed throwing the same error in production logs on real cancellations that hit the offer-restore branch. User chose to scope this fix to `expireOrders` only — file a separate `/fix` for `cancel-order.ts`.
