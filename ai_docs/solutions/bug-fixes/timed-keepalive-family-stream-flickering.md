---
title: Timed keepAlive prevents family stream provider flickering
date: 2026-07-12
work_type: bug
tags: [riverpod, stream, keepAlive, auto-dispose, firestore, tab-navigation]
confidence: medium
references: [ai_specs/archive/028-fix-offer-screen-bag-spec.md, df76ae5]
---

## Summary
Family stream providers parameterized by ID (`ordersListForItemStreamProvider(storeId, itemId)`) flicker infinitely when the watching widget unmounts and remounts (e.g. tab switches). Pure auto-dispose cancels the Firestore subscription on unmount; remount creates a fresh subscription starting from `AsyncLoading`. Fixed by adding `ref.keepAlive()` with a 30-second timer — the provider survives brief absence and serves cached data instantly on re-watch.

## Reusable Insights

- **Use timed keepAlive on family stream providers watched from tab content.** Tab switches unmount the watcher → auto-dispose kills the provider → remount starts from loading. A 30s `ref.keepAlive()` + `Timer` bridges the gap. Each re-watch resets the timer so rapid switching never disposes. _Example: `orders_repository.dart:ordersListForItemStreamProvider`._

- **Never use permanent `keepAlive: true` on family providers.** Each unique parameter set (storeId, itemId) creates a separate instance. Permanent retention leaks memory for every item the user has viewed. The timed pattern auto-cleans after inactivity.

- **`skipLoadingOnReload` / `skipLoadingOnRefresh` cannot help a fully disposed provider.** These flags suppress loading indicators only when the provider already has cached `AsyncData`. A disposed provider has no state at all — the next `build()` returns genuine `AsyncLoading`. The fix must prevent disposal, not suppress the indicator.

- **Redirect-on-null is a variant of the pop-on-null pattern (see `stream-race-unmounts-widget-before-pop.md`).** When a detail screen watches a stream and the document is deleted, use `ref.listen` at the screen level to detect `prev.value != null && next.value == null && !next.isLoading`, then navigate away. Use `context.pop()` for pushed screens, `context.goNamed(home)` for screens at tab root. _Example: `offer_screen.dart:63-67`._

## Pitfalls

- **Infinite loading ↔ data cycle looks like a provider bug but is a lifecycle issue.** Symptom: list flickers between loading animation and data every ~1s on tab switch. Cause: `setState` in `TabController` listener rebuilds the parent → child unmounts → provider disposes → child remounts → fresh subscription. Fix: timed keepAlive. Avoid by: always auditing family stream providers watched from tab content for disposal behavior.

- **`TabController` listener with `setState` triggers a full subtree rebuild.** Using `setState(() => _currentTab = tabController.index)` replaces the entire tab content widget on every switch. This unmounts the previous tab's watchers. If switching to a `StatefulWidget`-based tab controller, consider `IndexedStack` to keep all tabs mounted — but timed keepAlive is lighter for most cases.
