---
title: Rewrite Orders Screen
status: done
date: 2026-06-09
type: refactor
---

# Plan: Rewrite Orders Screen

Source: `ai_specs/008-rewrite-orders-screen-spec.md`

## Overview
Redesign the client orders screen to show active orders with a visual 4-dot progress line, a "Recent orders" section (max 3), and a dedicated order history screen. The existing `_OrderCard` is replaced with three specialized widgets: inline expanded view (1 active), active order cards (>1 active), and recent order cards. `OrderDetailScreen` gets the progress line for active/completed orders while cancelled/expired keep the badge. New `/orders/history` route added to `ClientRoute` enum.

**Spec:** `ai_specs/008-rewrite-orders-screen-spec.md`

## Context
- **Structure:** Feature-first with `domain/data/application/presentation` layers under `lib/src/features/orders/`
- **State management:** Riverpod codegen (`@riverpod`). Stream provider `customerOrdersStreamProvider` in `lib/src/features/orders/data/client_orders_repository.dart` streams all orders. Active/recent split done in widget layer.
- **Reference implementations:** `OrdersScreen` at `lib/src/features/orders/presentation/client/orders_screen.dart` (existing card pattern lines 86–149), `FavoritesScreen` route registration at `lib/src/routing/client_router.dart:236-239`
- **Testing convention:** Mirror `lib/` under `test/src/`. Group-based, mock repositories for controller tests. Widget tests need `AppLocalizations` delegates per `ai_toolkit/flutter.md`. No existing order tests.
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:**
  - N1 (animation) and N2 (icons on dots) are Nice to Have — deferred to later phases if time permits
  - Active/recent splitting in widget layer vs derived providers — spec says implementer's choice; plan uses widget-layer split (simpler, no new providers)
  - RTL direction for progress line — use `Directionality.of(context)` to flip dot order

## Plan

### Phase 1 — Thin vertical slice: progress line widget + orders screen rewrite
**Goal:** `OrderStatusProgressLine` renders correctly, `OrdersScreen` shows inline/list/empty states with recent section, history button present but screen stubbed.

- [x] `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_kk.arb` — add l10n keys: `orderHistory`, `recentOrders`, `noActiveOrders`, `statusConfirmed`, `statusPreparing`, `statusReady`, `statusCompleted`
- [x] TDD: `OrderStatusProgressLine` renders 4 dots; for `preparing` status, dots 1-2 filled, dots 3-4 unfilled; for `cancelled`/`expired` → widget not shown (caller responsibility)
- [x] `lib/src/features/orders/presentation/client/widgets/order_status_progress_line.dart` — create widget: 4 labeled dots connected by line, filled up to current status with `AppColors.primary`, unfilled with `theme.colorScheme.outlineVariant`. Localized labels via `context.loc`. Respect `Directionality`. Semantic labels for accessibility.
- [x] `lib/src/features/orders/presentation/client/widgets/active_order_inline.dart` — expanded inline view for single active order: store name, item×qty, `OrderStatusProgressLine`, pickup window, total. Tappable → `OrderDetailScreen`.
- [x] `lib/src/features/orders/presentation/client/widgets/active_order_card.dart` — compact card for active orders in list mode: store name, item, `OrderStatusBadge`, pickup time, total. Tappable.
- [x] `lib/src/features/orders/presentation/client/widgets/recent_order_card.dart` — compact card for past orders: store name, item, `OrderStatusBadge`, date, total. Tappable.
- [x] `lib/src/features/orders/presentation/client/orders_screen.dart` — rewrite: split orders into active/past in widget. 1 active → `ActiveOrderInline`; >1 active → list of `ActiveOrderCard`; 0 active → empty state text. Below: "Recent orders" header + max 3 `RecentOrderCard`. AppBar history `IconButton` (navigates to `orderHistory` route — added in Phase 2).
- [x] Verify: `flutter analyze && flutter test`

### Phase 2 — Order history screen + routing
**Goal:** `/orders/history` route works, `OrderHistoryScreen` shows all orders chronologically, bottom nav stays visible.

- [x] `lib/src/routing/client_router.dart` — add `orderHistory` to `ClientRoute` enum. Add `GoRoute(path: 'history', name: ClientRoute.orderHistory.name)` as child of `/orders` **before** the `:orderId` route to avoid dynamic segment conflict.
- [x] `lib/src/features/orders/presentation/client/order_history_screen.dart` — create screen: `ConsumerWidget`, watches `customerOrdersStreamProvider`, renders all orders newest-first as compact cards via `AsyncValueWidget`. Empty state if no orders. Back button in AppBar.
- [x] `lib/src/features/orders/presentation/client/orders_screen.dart` — wire AppBar history `IconButton` to `context.pushNamed(ClientRoute.orderHistory.name)`
- [x] TDD: `OrdersScreen` AppBar contains history icon; tapping navigates to `orderHistory` route (already implemented)
- [x] Verify: `flutter analyze && flutter test`

### Phase 3 — Detail screen progress line + final polish
**Goal:** `OrderDetailScreen` shows progress line for active/completed orders, badge for cancelled/expired. All requirements validated.

- [x] `lib/src/features/orders/presentation/client/order_detail_screen.dart` — replace `Center(child: OrderStatusBadge(...))` (line 55) with: if status is confirmed/preparing/readyForPickup/completed → `OrderStatusProgressLine`, else → `OrderStatusBadge`
- [x] TDD: `OrderDetailScreen` for `preparing` order shows progress line, for `completed` shows fully-filled progress line, for `cancelled` shows badge
- [x] TDD: `OrdersScreen` with 1 active order shows inline view; with 2+ shows cards; with 0 active and 5 past shows empty state + 3 recent cards
- [x] Verify: `flutter analyze && flutter test`

## Data layer changes
_None._ Existing `customerOrdersStreamProvider` and `customerOrderStreamProvider` are sufficient.

## External integrations
_None._

## Risks
- GoRouter route ordering: `history` must come before `:orderId` to avoid matching `"history"` as an orderId. Mitigated by explicit ordering in the routes array and a manual navigation test.
- `OrderStatusBadge` uses hardcoded English labels — this is a pre-existing issue, not addressed by this spec. The new `OrderStatusProgressLine` will be localized.
- `Order.pickupLabel` has hardcoded Russian — pre-existing, out of scope.

## Out of scope
- Filters or search on `OrderHistoryScreen`
- Business orders screen modifications
- `Order` domain model or `OrderStatus` enum changes
- `ClientOrdersRepository` changes or new Firestore queries
- Pagination/infinite scroll on history
- Push notification integration for status changes
- Fixing hardcoded Russian in `Order.pickupLabel`
- Localizing existing `OrderStatusBadge` labels
