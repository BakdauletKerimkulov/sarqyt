---
title: Status-transition guards need a temporal check, not just topology
date: 2026-08-01
work_type: bug
tags: [firestore, cloud-functions, orders, state-machine, gate-sh, tdd]
confidence: medium
references: [ai_specs/042-enforce-pickup-window-status-transitions-spec.md, 44516b0]
---

## Summary
`updateOrderStatus` validated that `readyForPickup → completed` was a legal
edge in the state graph but never checked whether `now` was inside the
order's `pickupStartTime`/`pickupEndTime`. Staff could hand over or complete
an order arbitrarily early or late. Fixed by adding a window check inside the
existing transaction, mirrored in the business-app UI, with regression tests
on both sides. Session also surfaced a real gotcha in this repo's
`gate.sh`/`guard-bash.sh` commit-approval mechanism.

## Reusable Insights
- **A state machine's transition table only proves topology, not timing** — when a status transition hands a resource to an external actor within a defined window (pickup, delivery, appointment, expiry), `VALID_TRANSITIONS[from].includes(to)` is not a complete guard; add an explicit `now` vs. window check for every status that represents the handoff. _Example: `functions/src/features/orders/functions/update-order-status.ts` — `PICKUP_WINDOW_GATED_STATUSES`._
- **A `firestore.rules` deny-all on a collection's writes (`allow update: if isAdmin()`) collapses the entire root-cause search to the Cloud Functions using the admin SDK** — check the rule before hunting for a client-side write path; if client writes are blocked, the bug is 100% server-side. _Example: `firestore.rules:191` `orders` match block confirmed the only write path was the one callable._
- **Client-side gating should reuse the same domain getters the rest of the app already uses for display, not re-derive the comparison** — kept `business_orders_screen.dart`'s button-disable check on `Order.isPickupExpired()`/`pickupStartTime` (already used by `order_detail_screen.dart` for the countdown), so client and server logic stay conceptually aligned even though Dart and TS can't share code.
- **A core defect gets strict RED→GREEN TDD; a UI affordance that only mirrors a rule the server already enforces can be tested after implementing** — the backend test (`update-order-status.test.ts`) was written first and confirmed failing for the right reason; the widget test for the disabled button was written after, since the server transaction is the actual source of truth and the client check is a UX nicety, not the fix.

## Pitfalls
- **`.gate/approved_sha` is invalidated by the act of committing, not just by editing** — symptom: `git push` blocked with "допуск протух" (approval stale) immediately after a `git commit` that itself followed a green `./scripts/gate.sh`, with zero further edits in between. Cause: the hash in `guard-bash.sh` is computed from `git diff HEAD` + untracked files; committing moves `HEAD`, collapsing the tracked-diff portion to empty and changing the hash even though nothing changed on disk. Fix: re-run `./scripts/gate.sh` a second time after `git commit`, right before `git push`. Avoid by: budgeting two gate runs per fix→commit→push cycle, not one.
- **New files from the `Write` tool aren't pre-formatted, so the first `gate.sh` run after adding one always fails at the `format` tier** — symptom: `dart format` step reports "Changed {file}" and gate exits FAIL even though `analyze`/`test` would have passed. Cause: `Write`-tool output isn't run through `dart format` automatically. Fix: run `dart format <new-file>` (or `git add` then let gate reformat and re-`git add`) before invoking `gate.sh`. Avoid by: formatting new Dart files immediately after writing them, before the first gate run.
