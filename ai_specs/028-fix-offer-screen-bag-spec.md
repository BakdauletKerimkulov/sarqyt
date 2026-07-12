---
title: Fix offer screen reservations flickering
status: done
date: 2026-07-11
type: fix
---

# Spec: Fix item screen reservations flickering

Source request: Исправить ошибку на экране offer-screen в бизнес приложении. Таб обзор. Раздел reservations. Список заказов то появляется, то появляется загрузка и так бесконечно

## Goal
Eliminate the infinite loading ↔ data flickering of the reservations list on the item overview tab in the business app. After the first load, switching tabs and returning to overview must show data instantly without a loading animation.

## Background
**Stack & conventions:** Riverpod codegen with `@riverpod` for auto-dispose providers and `@Riverpod(keepAlive: true)` for repositories (`ai_toolkit/riverpod.md`). Stream providers auto-dispose by default — when their last watcher unmounts, the Firestore stream subscription is cancelled. `AsyncValueWidget` uses `.when()` without `skipLoadingOnReload`, which correctly shows loading for genuinely new subscriptions (`ai_toolkit/architecture.md`).

**Project context:** The business app's `ItemScreen` (`lib/src/features/items/presentation/item_screen/item_screen.dart`) uses a `TabController` with a `setState` listener (line 48–49). Switching tabs replaces the tab content widget via `_buildTabContent` (line 132–139). The overview tab renders `OverviewContent` (`lib/src/features/items/presentation/item_screen/overview_content.dart`), which watches `ordersListForItemStreamProvider(storeId, item.id)` (line 22–23).

**Why now / why this approach:** Spec 024 fixed the repository provider (`ordersRepositoryProvider`) being auto-dispose instead of `keepAlive`. That fix stabilized the repository, but the dependent stream provider `ordersListForItemStreamProvider` is still auto-dispose (`lib/src/features/orders/data/orders_repository.dart:97`). When `OverviewContent` unmounts on tab switch, the stream provider loses its last watcher → gets disposed → Firestore subscription cancelled. On re-mount, a brand-new subscription starts from `AsyncLoading`. Since there is no cached `AsyncData`, neither `skipLoadingOnReload` nor `skipLoadingOnRefresh` can help — the provider state is genuinely empty.

## User Flow

### Happy path
1. User opens an item screen in the business app → overview tab loads → `ordersListForItemStreamProvider` subscribes to Firestore → loading animation → data appears.
2. User switches to schedule or settings tab → `OverviewContent` unmounts → provider stays alive (cached for 30 s).
3. User switches back to overview within 30 s → `OverviewContent` mounts → watches the still-alive provider → data appears **instantly**, no loading animation.

### Alternative flows
- If user stays away from overview tab for > 30 s, the cache expires, the provider disposes, and on return a normal loading → data sequence plays (one-time, not flickering).

### Error & recovery flows
- If Firestore stream emits an error, `AsyncValueWidget` shows the error widget. On next tab switch and return, a fresh subscription retries automatically.

### Edge cases
- Empty state: no orders exist → provider emits `AsyncData([])` → "no reservations" text shown. Cache behavior is identical.
- Rapid tab switching: provider stays alive throughout because the 30 s timer resets on each re-watch.

## Requirements

### Must Have
- [ ] R1: `ordersListForItemStreamProvider` uses `ref.keepAlive()` + `Timer` to cache its state for 30 seconds after the last watcher unmounts. Verifiable by: switching tabs and returning — no loading animation appears if return is within 30 s.
- [ ] R2: `ordersListStream` (store-level orders, `orders_repository.dart:91`) uses the same cache pattern for consistency. Verifiable by: same tab-switch test on any screen that watches this provider.
- [ ] R3: Regression test verifying `ordersListForItemStreamProvider` retains `AsyncData` when the last watcher is removed and a new watcher is added within the cache window. Verifiable by: test passes in `flutter test`.

### Nice to Have
- [ ] N1: Extract a reusable `cacheFor(Ref ref, Duration duration)` helper if the pattern is needed in ≥ 3 providers.

### Non-functional
- Performance: no additional Firestore reads — the existing stream stays open during the cache window.
- Memory: cached providers are cleaned up after 30 s of inactivity — no permanent leaks.

## Technical Constraints

**Files to create:**
- `test/src/features/orders/data/orders_stream_cache_test.dart` — regression test for R3.

**Files to modify:**
- `lib/src/features/orders/data/orders_repository.dart` (lines 91–102) — add `ref.keepAlive()` + `Timer` pattern to both stream providers.

**Patterns to follow (with citations):**
- `ref.keepAlive()` + `Timer` + `ref.onDispose` pattern per Riverpod documentation (official `ref.keepAlive()` API). Note: this timed-keepAlive pattern is not yet in `ai_toolkit/riverpod.md` — add it after this fix lands. Example:
  ```dart
  @riverpod
  Stream<List<Order>> ordersListForItemStream(Ref ref, StoreID storeId, ItemID itemId) {
    final link = ref.keepAlive();
    final timer = Timer(const Duration(seconds: 30), link.close);
    ref.onDispose(timer.cancel);
    final repo = ref.watch(ordersRepositoryProvider);
    return repo.watchOrdersListForItem(storeId, itemId);
  }
  ```
- R3 test setup: create a mock `StoreOrdersRepository` that returns a `StreamController<List<Order>>.stream`, override `ordersRepositoryProvider` in a `ProviderContainer`, emit test data, then unsubscribe and re-subscribe within the cache window — assert state is `AsyncData` (not `AsyncLoading`).

**Anti-patterns / avoid:**
- Do not make the stream providers permanently `keepAlive` — they are family providers parameterized by `storeId`/`itemId`; permanent retention leaks memory for each item viewed.
- Do not restructure `ItemScreen` to use `IndexedStack` — heavier change, not needed for this fix.
- Do not modify `AsyncValueWidget` — it correctly shows loading for genuinely initial loads.

**Data layer changes:** none — no schema, collection, or security rule changes.

**External integrations:** none.

## Out of Scope
- NOT restructuring tab content to stay mounted (IndexedStack) — the `ref.keepAlive` + timer approach is lighter and idiomatic Riverpod.
- NOT modifying `AsyncValueWidget` — loading on initial subscription is correct behavior.
- NOT applying the cache pattern to all stream providers project-wide — only the two orders stream providers that cause visible flickering.
- NOT investigating Firestore-level stream instability — the root cause is provider lifecycle, not Firestore behavior.

## Validation

**Automated tests:**
- Unit: `orders_stream_cache_test.dart` — create a `ProviderContainer`, read the provider to subscribe, remove the subscription, re-subscribe within 30 s, assert state is `AsyncData` (not `AsyncLoading`).

**Manual QA scenarios:**
1. Given the business app on the item overview tab with reservations loaded, when switching to schedule tab and back within 5 s, then the reservations list appears instantly with no loading animation.
2. Given the business app on the item overview tab, when switching to settings tab and back within 5 s, then the reservations list appears instantly.
3. Given the business app on the item overview tab, when switching away and waiting > 30 s before returning, then a single loading → data transition occurs (acceptable, not flickering).
4. Given an item with no orders, when switching tabs and returning, then the "no reservations" empty state appears instantly.

**Expected behavior under edge conditions:**
- Offline → Firestore serves cached data; cache timer still works; no flickering.
- Backend error → error widget shown; on tab switch and return, fresh subscription retries.
- Empty data → empty state shown instantly on return (cached `AsyncData([])`).

## Definition of Done
- [ ] All Must Have requirements pass automated tests
- [ ] All Manual QA scenarios pass on web (business app)
- [ ] No new lint warnings; `flutter analyze` clean
- [ ] Matches `ai_toolkit/riverpod.md` patterns
- [ ] Update `ai_toolkit/riverpod.md` Stream Providers section with timed-keepAlive pattern and when to use it (family providers viewed repeatedly but not app-wide)
- [ ] Spec file linked in the PR description
