---
title: Fix SliverBusinessOrders empty-state crash
status: done
date: 2026-07-10
type: fix
severity: S
references: []
---

## Symptom
On the dashboard screen, switching the Reservations filter to "Active" (or any filter yielding zero results) freezes the app. Flutter enters an infinite layout loop because a non-sliver `Center` widget is placed inside a `SliverMainAxisGroup`.

## Root cause
In `SliverBusinessOrders` (`business_orders_screen.dart:356`), the `data` callback of `AsyncValueSliverWidget` returned a plain `Center(...)` widget when the filtered list was empty. Since `AsyncValueSliverWidget` sits inside `SliverMainAxisGroup`, all returned widgets must be slivers. The loading and error states correctly used `SliverToBoxAdapter`, but the empty-data branch did not.

## Fix
- **Files changed:** `lib/src/features/orders/presentation/business/business_orders_screen.dart`
- **Failing test that catches the regression:** `test/src/features/orders/presentation/business/sliver_business_orders_test.dart::selecting Active filter with no active orders does not crash`
- **`ai_toolkit/` rules applied:** `code-style.md` (small focused changes), `architecture.md` (presentation layer)
- **Toolkit deviations:** none
- Wrapped the empty-state `Center(...)` in `SliverToBoxAdapter(...)` so it is a valid sliver child within `SliverMainAxisGroup`.
