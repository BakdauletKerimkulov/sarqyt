---
title: Firestore transaction read-after-write silently kills status transitions
date: 2026-07-30
work_type: bug
tags: [firestore, cloud-functions, transactions, orders, testing]
confidence: high
references: [functions/src/features/orders/functions/expire-orders.ts, functions/src/features/orders/functions/cancel-order.ts, ai_specs/036-expire-orders-transaction-order-spec.md, ai_specs/037-cancel-order-transaction-order-spec.md, 6b4f1f6]
---

## Summary
`expireOrders` (scheduled every 5 min) never flipped orders to `expired`, and `cancelOrder` threw on every order with an `offerId` + `itemQuantity`, both because their Firestore transactions called `tx.update()` on the order before `tx.get()` on the offer — Firestore requires all reads before any writes, so every real invocation threw and the whole transaction rolled back, including the write that looked unrelated to the failing read. The bug was invisible to code review, `tsc`, and eslint; only production logs (`firebase functions:log`) surfaced it. Both functions share the same offer-restore snippet and were fixed with the identical reorder.

## Reusable Insights
- **Firestore transaction ordering is a runtime-only invariant** — when a `db.runTransaction(tx => ...)` callback mixes `tx.get()` and `tx.update()`/`tx.set()`/`tx.delete()`, do all `tx.get()` calls first, unconditionally, before any write call, even ones that look independent (e.g. reading a related doc to restore its quantity). The compiler and linter accept the wrong order silently; it only throws at runtime with `Error: Firestore transactions require all reads to be executed before all writes.` _Example: `functions/src/features/orders/functions/expire-orders.ts:36-51` and `functions/src/features/orders/functions/cancel-order.ts:47-101` (both fixed)._
- **When code review can't confirm or deny a hypothesis, check production logs before concluding "looks correct."** `firebase functions:log --only <functionName>` gave a definitive, timestamped repro (`expireOrders` throwing every 5 minutes) after ~20 minutes of careful-but-inconclusive source reading found nothing wrong. For scheduled/background functions with no user-facing error surface, logs are the only real reproduction available. _Example: this session — logic looked correct in `expire-orders.ts` until `firebase functions:log` showed the actual thrown error._
- **Once one instance of a transaction-ordering bug is found, grep siblings for the same shape before closing the fix.** The pattern (`tx.update(orderRef, ...)` immediately followed later by `tx.get(offerRef)`) was copy-pasted between `cancel-order.ts` and `expire-orders.ts` — both do "update the order, then conditionally restore offer quantity." This is exactly what happened: `expireOrders` was fixed first, `cancel-order.ts` was found via this same insight and fixed as a same-session follow-up (`ai_specs/037-...`). Any function reusing that offer-restore snippet is a suspect.
- **`onSchedule(...)`-wrapped Cloud Functions expose `.run(event)` for direct invocation in tests** — no need for the `firebase-functions-test` wrapper library; call `myScheduledFn.run({} as never)` directly against a Firestore-emulator-backed `db` for a true smoke test, per `testing.md`'s "never mock the backend SDK client" rule. _Example: `functions/src/features/orders/functions/expire-orders.test.ts`._

## Pitfalls
- **Silent transaction rollback on error inside a `for` loop over `snap.docs`** — symptom: no orders ever expire, no error visible anywhere except function logs. Cause: `await db.runTransaction(...)` throwing per-document does not stop the outer scheduled function from completing "successfully" from Cloud Scheduler's point of view in many configurations, and nothing in the app surfaces the failure to users. Fix: reorder reads before writes. Avoid by: treat any `tx.get()` appearing after a `tx.update()`/`tx.set()` in the same transaction body as a bug on sight during review.
