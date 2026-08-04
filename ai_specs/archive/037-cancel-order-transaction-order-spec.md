---
title: cancelOrder fails on order with offerId + itemQuantity
status: done
date: 2026-07-31
type: fix
severity: S
references: [ai_specs/036-expire-orders-transaction-order-spec.md, ai_docs/solutions/bug-fixes/firestore-transaction-read-after-write.md]
---

## Symptom
Cancelling an order (customer or store side) throws and does not commit whenever the order has an `offerId` and `itemQuantity` set — which is every order created via `reserve-offer.ts`. The order stays in its prior status and offer quantity is never restored.

## Root cause
In `functions/src/features/orders/functions/cancel-order.ts:76` (before fix), the transaction called `tx.update(orderRef, orderUpdate)` (a write) before `tx.get(offerRef)` at line 83 (a read). Firestore transactions require all reads before any writes, so this threw `Error: Firestore transactions require all reads to be executed before all writes.` and aborted the whole transaction. Identical bug and root cause to the one fixed in `expireOrders` (`ai_specs/036-...`, commit `6b4f1f6`) — same offer-restore snippet, same ordering mistake. Confirmed live via `firebase functions:log --only cancelOrder`: a real cancellation (`orderId: y8PdwaYDd9PwWnwLjyKBgZ0AXAG2_e3fd3de4-22bd-46f5-8974-8a250aae82eb`) threw this exact error in production.

## Fix
- **Files changed:** `functions/src/features/orders/functions/cancel-order.ts`
- **Failing test that catches the regression:** `functions/src/features/orders/functions/cancel-order.test.ts::cancelOrder > cancels an order and restores offer quantity` (Firestore-emulator smoke test via `.run()`, per `testing.md`'s "never mock the backend SDK client" rule)
- **`ai_toolkit/` rules applied:** `RULES-backend.md → Transactions & races: "Reads before writes"`, `testing.md → Server functions: smoke the handler against the local emulator`
- **Toolkit deviations:** none
- **Description:** Reordered the transaction body so `tx.get(offerRef)` runs before `tx.update(orderRef, ...)`, satisfying Firestore's read-before-write transaction requirement. Order cancellation and offer quantity restoration now both commit correctly.
