---
title: Non-sliver widget inside SliverMainAxisGroup freezes app
date: 2026-07-10
work_type: bug
tags: [flutter, sliver, layout, widget, freeze]
confidence: medium
references: [ai_specs/027-fix-sliver-empty-state-crash-spec.md]
---

## Summary
`SliverBusinessOrders` returned a plain `Center` widget (not a sliver) from the `data` callback of `AsyncValueSliverWidget` when the filtered list was empty. Because this widget lived inside a `SliverMainAxisGroup`, Flutter entered an infinite layout loop and froze. Wrapping in `SliverToBoxAdapter` fixed it.

## Reusable Insights

- **Every code path in a sliver callback must return a sliver** — when writing a `data:` callback for `AsyncValueSliverWidget` (or any widget whose output feeds a sliver parent), ensure all branches — including empty-state — return a sliver. The loading/error paths already used `SliverToBoxAdapter`; the empty-data path was missed. _Example: `business_orders_screen.dart:356`._
- **Infinite layout loop = check sliver/box mismatch** — when a Flutter app freezes (no crash, just hangs) during a layout-triggering interaction (tab switch, filter change), the most common cause is placing a box widget where a sliver is expected. Look for widgets like `Center`, `Padding`, `Container` returned directly inside `SliverMainAxisGroup`, `CustomScrollView.slivers`, or `SliverList` builders.
- **Test filter edge cases that produce empty results** — widget tests that only test "happy path" (data present) miss the empty-filtered-state branch. Always add a test that applies a filter yielding zero results inside a sliver context to catch box-in-sliver bugs. _Example: `sliver_business_orders_test.dart`._

## Pitfalls

- **Non-sliver in SliverMainAxisGroup causes silent freeze, not an assertion** — symptom: app hangs on filter tap, no red error screen. Cause: `Center(...)` returned where `SliverToBoxAdapter(child: Center(...))` was needed. Fix: wrap in `SliverToBoxAdapter`. Avoid by: grep for raw box widgets (`Center`, `Padding`, `Container`, `SizedBox`) returned directly in sliver data callbacks.
