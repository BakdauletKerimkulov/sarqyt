---
title: Fix flickering reservations list
status: done
date: 2026-07-07
type: fix
severity: S
references: [ai_docs/solutions/bug-fixes/auto-dispose-keepalive-desync.md]
---

## Symptom
The reservations list widget on the item/offer overview tab flickers every ~1 second — it appears, shows a loading animation, then shows data, then repeats. The user sees the widget rapidly appearing and disappearing.

## Root cause
`ordersRepositoryProvider` in `lib/src/features/orders/data/orders_repository.dart:83` uses `@riverpod` (auto-dispose) instead of `@Riverpod(keepAlive: true)`. This violates `riverpod.md` which mandates repositories are always `keepAlive: true`. Because the repository auto-disposes, the dependent `ordersListForItemStreamProvider` stream gets invalidated on widget rebuilds (triggered by `TabController` setState), causing the Firestore stream to re-subscribe. Each re-subscription cycles through `AsyncLoading` → `AsyncData`, and `AsyncValueWidget.when()` with `skipLoadingOnReload: false` shows the loading animation during each cycle.

## Fix
- **Files changed:** `lib/src/features/orders/data/orders_repository.dart`, `lib/src/features/orders/data/orders_repository.g.dart` (codegen)
- **Failing test that catches the regression:** `test/src/features/orders/data/orders_repository_provider_test.dart::ordersRepositoryProvider is keepAlive (not auto-dispose)`
- **`ai_toolkit/` rules applied:** `riverpod.md` — repositories are always `@Riverpod(keepAlive: true)`
- **Toolkit deviations:** none
- Changed `@riverpod` annotation on `ordersRepositoryProvider` to `@Riverpod(keepAlive: true)`, then regenerated codegen. This prevents the repository from being disposed during widget rebuilds, keeping the Firestore stream subscription stable.
