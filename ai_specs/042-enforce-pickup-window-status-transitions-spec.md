---
title: Enforce pickup window on order status transitions
status: done
date: 2026-08-01
type: fix
severity: S
references: []
---

## Symptom
A store employee or owner in the business app could mark an order "Ready for pickup" or "Mark completed" (i.e. hand it over) at any time — including before the order's `pickupStartTime` (handing goods over early) or after `pickupEndTime` had already passed (completing an order that `expireOrders` should instead have expired). No server or client check compared the order status transition against its pickup window.

## Root cause
`functions/src/features/orders/functions/update-order-status.ts` validated only that the requested status transition was structurally allowed (`VALID_TRANSITIONS`), but never read `pickupStartTime` / `pickupEndTime` off the order or compared them against the current time before writing `readyForPickup` or `completed`. Firestore rules correctly block direct client writes to `orders` (`allow update: if isAdmin()`), so this callable was the only write path and the only place the gap could be closed. The business-app UI (`lib/src/features/orders/presentation/business/business_orders_screen.dart`) mirrored this: the "next status" button was always enabled regardless of the pickup window.

## Fix
- **Files changed:**
  - `functions/src/features/orders/functions/update-order-status.ts` — inside the existing transaction, added a check that rejects transitions into `readyForPickup` or `completed` when `now < pickupStartTime` or `now > pickupEndTime`, throwing `failed-precondition`.
  - `functions/src/features/orders/functions/update-order-status.test.ts` (new) — regression tests: reject completing before window opens, reject completing after window closes, allow completing inside the window.
  - `lib/src/features/orders/presentation/business/business_orders_screen.dart` — added `_pickupWindowBlockReason`, mirroring the server gate, to disable the action button and show why when outside the window.
  - `lib/l10n/app_en.arb`, `app_ru.arb`, `app_kk.arb` (+ generated `app_localizations_*.dart`) — added `pickupWindowNotOpenYet` / `pickupWindowAlreadyClosed` strings.
  - `test/src/features/orders/presentation/business/pickup_window_gate_test.dart` (new) — widget tests for the disabled/enabled states and reason text.
- **Failing test that catches the regression:** `functions/src/features/orders/functions/update-order-status.test.ts` → `updateOrderStatus > rejects marking an order completed before the pickup window opens` / `...after the pickup window closes` (both failed before the fix — the call resolved successfully instead of rejecting).
- **`ai_toolkit/` rules applied:** `RULES-backend.md → Transactions & races` (re-read order inside the transaction, guard before write), `testing.md → Backend test minimum: negative test per server-authoritative check`, `RULES.md → docs-sync.md` (no `ai_docs/` contract doc referenced `updateOrderStatus`, so none needed updating).
- **Toolkit deviations:** none.
- The fix closes the gap at the only write path (the `updateOrderStatus` callable) so `readyForPickup` and `completed` can no longer be set outside an order's pickup window, and surfaces the same rule in the business UI so staff see why before they tap rather than only after a failed call.
