---
title: Missing composite index shows as 1-second loading↔data retry loop
date: 2026-07-12
work_type: bug
tags: [firestore, composite-index, riverpod-3, auto-retry, orders, emulator]
confidence: high
references: [ai_specs/archive/024-fix-flickering-reservations-spec.md]
---

## Summary
The Reservations section on the Item screen Overview tab cycled loading → data → loading every ~1 second and eventually settled on "Operation failed. Try again" — but only against production Firestore, never on the emulator. Root cause: `watchOrdersListForItem` (`lib/src/features/orders/data/orders_repository.dart:33`) queries `where storeId == X` + `where itemId == Y` + `orderBy createdAt desc`, and `firestore.indexes.json` had no `(storeId ASC, itemId ASC, createdAt DESC)` composite index. The server rejected the query with `failed-precondition`; Riverpod 3's default automatic retry (exponential backoff) resubscribed the stream, the SDK emitted cached results first each time, then the server error again — producing the visible flicker. Fixed by adding the composite index and deploying `firebase deploy --only firestore:indexes`.

## Reusable Insights
- **Loading↔data cycle that ends in an error = provider retry loop, not a lifetime bug** — Riverpod 3 auto-retries failed providers with exponential backoff (~200ms doubling). Each retry on a Firestore stream re-emits cached data before the server error arrives, so the UI alternates data/loading before settling on the error. When you see this pattern, check for a server-side query rejection (missing index, security rules) FIRST, before suspecting auto-dispose/keepAlive lifetimes. _We initially misdiagnosed this as a regression of the 024 keepAlive fix; the commented-out keepAlive was an unrelated experiment._
- **"Operation failed. Try again" = `failed-precondition`** — the app's error mapper (`lib/src/utils/async_value_ui.dart:92`) translates Firestore `failed-precondition` to exactly this string. For Firestore queries, `failed-precondition` almost always means a missing composite index. The full index-creation link is in the raw error, visible in the browser console / `debugPrint` of the stack trace in `AsyncValueWidget`.
- **The Firestore emulator does not enforce composite indexes** — any compound query works locally and fails only in production. Green emulator runs prove nothing about index coverage; audit `firestore.indexes.json` against every `where` + `where`/`orderBy` combination in the repositories.
- **Every compound query needs an index entry in the same PR** — `watchOrdersListForStore` had its `(storeId, createdAt DESC)` index, and `hasActiveOrdersForItem` had `(storeId, itemId, status)`, but the `+ itemId` variant of the orders list query shipped without one. Adding a `where` clause to an existing indexed query silently invalidates the old index coverage.

## Pitfalls
- **Cached results mask the error during triage** — the list genuinely renders (from SDK cache) between retries, so the bug looks like a state-management flicker rather than a failing query. Screenshots of "data showing fine" do not prove the query succeeds server-side.
- **A prior fix for the same widget can anchor the diagnosis wrongly** — spec 024 fixed a *tab-switch* flicker in the same Reservations section via timed keepAlive. Same widget, same visual symptom class, completely different cause. Match the *trigger* (idle vs navigation) and the *terminal state* (error vs stable data), not just the widget.
