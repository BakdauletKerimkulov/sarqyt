---
title: Rewrite Orders Screen
status: done
date: 2026-06-09
type: refactor
---

# Spec: Rewrite Orders Screen

Source request: ai_specs/008-rewrite-orders-screen.md

## Goal
Redesign the client-facing orders screen to prioritize active order tracking with a visual status progress line, show a short list of recent orders, and add a dedicated order history screen accessible from the app bar.

## Background
**Stack & conventions:** Flutter + Riverpod codegen (`@riverpod`). Feature-first structure with `domain/data/application/presentation` layers (`ai_toolkit/architecture.md`). Navigation via GoRouter with named routes and `ClientRoute` enum (`ai_toolkit/gorouter.md`). All user-visible strings via ARB l10n (`ai_toolkit/code-style.md`). Widgets must not contain business logic; use `AsyncValueWidget` for async state (`ai_toolkit/riverpod.md`). No raw numbers for spacing — use `Sizes.pX` / `gapHX` (`ai_toolkit/code-style.md`). Extract widgets instead of private `_build` methods (`ai_toolkit/code-style.md`). Local UI state stays in `StatefulWidget`, not Riverpod (`ai_toolkit/riverpod.md`).

**Project context:** The order domain model (`lib/src/features/orders/domain/order.dart:14`) has six statuses: `confirmed`, `preparing`, `readyForPickup`, `completed`, `cancelled`, `expired`. Active statuses are the first three. The existing `OrdersScreen` (`lib/src/features/orders/presentation/client/orders_screen.dart`) is a flat list split into "Current" and "Past" sections with no progress visualization. `OrderDetailScreen` (`lib/src/features/orders/presentation/client/order_detail_screen.dart`) shows a status badge but no progress line. The `ClientOrdersRepository` (`lib/src/features/orders/data/client_orders_repository.dart`) provides `watchOrdersForCustomer(uid)` which streams ALL orders sorted by `createdAt desc` — no separate active/past queries. Routes are defined in `lib/src/routing/client_router.dart:178-213` under the orders `StatefulShellBranch`.

**Why now:** The current orders screen doesn't let users visually track order progress. The redesign improves UX by surfacing active order status at a glance.

## User Flow

### Happy path
1. User taps the "Orders" tab → `OrdersScreen` loads, watches `customerOrdersStreamProvider`.
2. **One active order:** The order is shown inline with store name, item info, a 4-dot progress line (confirmed → preparing → readyForPickup → completed) filled up to the current status in primary color, and pickup window info. Below: "Recent orders" section with up to 3 past orders as compact cards. Tapping the inline active order navigates to `OrderDetailScreen`.
3. **Multiple active orders:** Active orders render as a vertical list of tappable cards (store name, item, status badge, pickup time). Tapping any card → `OrderDetailScreen`. Below: "Recent orders" section (3 items).
4. **Zero active orders:** Empty state message where the active section would be. "Recent orders" section still shows if past orders exist.
5. User taps the history icon button in the AppBar → navigates to `OrderHistoryScreen` showing all orders chronologically.
6. User taps an order in the history list → navigates to `OrderDetailScreen`.
7. On `OrderDetailScreen`, the progress line replaces the current centered `OrderStatusBadge` for active orders.

### Alternative flows
- If user is not authenticated, `customerOrdersStreamProvider` returns empty stream → empty state shown.
- If an active order transitions status while the screen is open, the Firestore stream emits an update and the progress line animates to the new position.
- Deep link to `/orders/:orderId` still works — `OrderDetailScreen` loads independently.

### Error & recovery flows
- If Firestore stream errors, `AsyncValueWidget` shows the error widget with a human-readable message.
- If `OrderHistoryScreen` stream errors, same `AsyncValueWidget` handling.
- Network loss: Firestore offline persistence shows cached data. No special handling needed.

### Edge cases
- Empty state: No orders at all → centered empty message, no "Recent" section, history button in AppBar still accessible (shows empty history screen).
- All orders are active (no past orders) → "Recent orders" section hidden.
- All orders are past (no active) → active section shows empty state, recent section shows up to 3.
- Order transitions from active to past while on screen → order moves from active section to recent section via stream update.
- Cancelled/expired order → progress line is NOT shown. Instead show the existing `OrderStatusBadge` with appropriate color (red/grey). This applies both inline and on detail screen.

## Requirements

### Must Have
- [ ] R1: New `OrderStatusProgressLine` widget with 4 dots (confirmed, preparing, readyForPickup, completed) connected by a horizontal line. Filled dots and line segments up to the current status use `AppColors.primary`; unfilled dots and segments use a neutral theme color (e.g. `theme.colorScheme.outlineVariant`). Do not use per-status colors like the badge — a single primary fill color for the progress line. Verifiable by: widget renders correctly for each of the 4 active statuses.
- [ ] R2: For cancelled/expired orders, `OrderStatusProgressLine` is NOT shown — fall back to `OrderStatusBadge`. Verifiable by: cancelled/expired orders show badge, not progress line, in both orders screen and detail screen.
- [ ] R3: When exactly 1 active order exists, show it inline on `OrdersScreen` with: store name, item name × quantity, `OrderStatusProgressLine`, pickup window (if available), total price. Tapping it navigates to `OrderDetailScreen`. Verifiable by: with 1 active order, screen shows expanded view (not a list), and tapping navigates to detail.
- [ ] R4: When >1 active orders exist, show them as a vertical list of `ActiveOrderCard` widgets with: store name, item, status badge, pickup time, `totalFormatted`. Tapping → `OrderDetailScreen`. Verifiable by: with 2+ active orders, each renders as a card in a list. Note: cards use `OrderStatusBadge` (not progress line) for visual density — the progress line is reserved for the single-order inline view (R3) and detail screen (R10).
- [ ] R5: When 0 active orders, show an empty state placeholder in the active area. Verifiable by: with only past orders, empty state text appears above recent section.
- [ ] R6: "Recent orders" section below active orders shows up to 3 most recent non-active orders as compact cards with: store name, item, `OrderStatusBadge`, date, `totalFormatted`. Completed orders show the badge (not the progress line) on cards. Tapping → `OrderDetailScreen`. Hidden if no past orders exist. Verifiable by: with 5 past orders, only 3 are shown; with 0 past, section is absent.
- [ ] R7: AppBar contains a history icon button (e.g. `Icons.history`) that navigates to `OrderHistoryScreen`. Verifiable by: tapping the icon navigates to the history screen.
- [ ] R8: `OrderHistoryScreen` shows all orders (active and past) in a chronological list (newest first), each as a compact card. Back button returns to `OrdersScreen`. Verifiable by: all orders appear in date-descending order.
- [ ] R9: Add `orderHistory` to `ClientRoute` enum and register the route as a child of `/orders` in `client_router.dart`. Path: `/orders/history`. **Place the `history` route before the `:orderId` route** in the routes array to avoid GoRouter matching `"history"` as an orderId parameter. The `OrderHistoryScreen` renders inside the bottom nav shell (bottom nav stays visible). Verifiable by: navigating to `ClientRoute.orderHistory` shows the history screen; navigating to `/orders/someOrderId` still shows the detail screen.
- [ ] R10: `OrderDetailScreen` shows `OrderStatusProgressLine` instead of the centered `OrderStatusBadge` for active orders (confirmed/preparing/readyForPickup) and completed orders (fully-filled progress line). Cancelled/expired keep `OrderStatusBadge`. Note: only the detail screen shows the progress line for completed orders — on cards (R4, R6) completed orders show the badge. Verifiable by: detail screen for a preparing order shows progress line, completed order shows fully-filled progress line, cancelled order shows badge.
- [ ] R11: All new user-visible strings added to ARB files (`app_en.arb`, `app_ru.arb`, `app_kk.arb`) and accessed via `context.loc`. No hardcoded strings. Verifiable by: `grep` for hardcoded Russian/English strings in new/modified files finds none.
- [ ] R12: Status labels on the progress line dots are localized. Verifiable by: switching locale changes the labels under the dots.

### Nice to Have
- [ ] N1: Subtle animation when the progress line fills (e.g. color transition when status updates via stream). Verifiable by: changing status in Firestore shows a smooth fill animation.
- [ ] N2: Each dot on the progress line shows a small icon (e.g. checkmark for completed steps, circle for current, empty circle for future). Verifiable by: visual inspection of icon states.

### Non-functional
- Performance: orders screen must handle up to 50 orders in the stream without jank. The `customerOrdersStreamProvider` already streams all orders — splitting into active/recent is done in the widget.
- Accessibility: progress line dots have semantic labels describing the status and whether it is current/completed/future. Minimum tap target 48×48 for all tappable elements.
- i18n: New keys needed — `orderHistory`, `recentOrders`, `noActiveOrders`, plus 4 status labels for progress dots (`statusConfirmed`, `statusPreparing`, `statusReady`, `statusCompleted`). RTL: progress line direction should respect `Directionality`.

## Technical Constraints

**Files to create:**
- `lib/src/features/orders/presentation/client/widgets/order_status_progress_line.dart` — the 4-dot progress line widget. Accepts `OrderStatus`, renders dots + connecting line.
- `lib/src/features/orders/presentation/client/widgets/active_order_inline.dart` — expanded inline view for a single active order (used when exactly 1 active).
- `lib/src/features/orders/presentation/client/widgets/active_order_card.dart` — compact card for active orders (used in list when >1 active).
- `lib/src/features/orders/presentation/client/widgets/recent_order_card.dart` — compact card for recent/past orders.
- `lib/src/features/orders/presentation/client/order_history_screen.dart` — full history screen.

**Files to modify:**
- `lib/src/features/orders/presentation/client/orders_screen.dart` — rewrite to implement the new layout (inline active / list active / empty state + recent section + AppBar history button).
- `lib/src/features/orders/presentation/client/order_detail_screen.dart` — replace `OrderStatusBadge` (line 55) with `OrderStatusProgressLine` for non-cancelled/expired orders.
- `lib/src/routing/client_router.dart` — add `orderHistory` to `ClientRoute` enum (line 32-46), add route definition **before** `:orderId` under `/orders` routes list to avoid dynamic segment conflict.
- `lib/l10n/app_en.arb` — add new l10n keys.
- `lib/l10n/app_ru.arb` — add Russian translations.
- `lib/l10n/app_kk.arb` — add Kazakh translations.

**Patterns to follow (with citations):**
- Follow the `AsyncValueWidget` pattern from `lib/src/common_widgets/async_value_widget.dart` for loading/error/data states.
- Follow the existing `_OrderCard` widget structure in `lib/src/features/orders/presentation/client/orders_screen.dart:86-149` for card layout (Card + InkWell + padding pattern).
- Follow the `FavoritesScreen` route registration pattern in `lib/src/routing/client_router.dart:237-239` for adding `orderHistory` route as a child of the orders route.
- Note: the existing `OrderStatusBadge` (`lib/src/features/orders/presentation/client/order_status_badge.dart`) uses hardcoded English labels and Material `Colors.*` — the new progress line should NOT follow this pattern. Use `AppColors.primary` for filled state and localized labels via `context.loc`.

**Anti-patterns / avoid:**
- Do not create a separate Firestore query for active vs past orders. The existing `customerOrdersStreamProvider` returns all orders — split them in the widget layer. This avoids an extra Firestore read.
- Active/recent splitting: either keep in the widget (simple, avoids provider proliferation) or use derived providers (`activeOrdersProvider`, `recentOrdersProvider`) — both are valid per `ai_toolkit/riverpod.md`. Implementer's choice. If using derived providers, they should be auto-dispose `@riverpod` functions that `ref.watch(customerOrdersStreamProvider)`.
- Do not use `Navigator.push` — use `context.pushNamed` with `ClientRoute` enum.
- Do not use hardcoded colors — use `AppColors.primary` for filled progress and theme grey for unfilled.
- Do not add pagination to `OrderHistoryScreen` in this spec — the existing stream returns all orders. Pagination is out of scope.

**Data layer changes:** None. Existing `customerOrdersStreamProvider` and `customerOrderStreamProvider` are sufficient.

**External integrations:** None.

## Edge Cases
Cross-referenced from User Flow → Edge cases above.

## Out of Scope
- NOT adding filters or search to `OrderHistoryScreen` — the user chose a simple chronological list. Can be added later if needed.
- NOT modifying the business orders screen (`lib/src/features/orders/presentation/business/business_orders_screen.dart`) — this spec is client-only.
- NOT changing the `Order` domain model or `OrderStatus` enum — no new fields needed. Note: the `Order` model imports `cloud_firestore` directly (violates architecture rule that domain should be pure Dart) — fixing this is a separate cleanup task.
- NOT modifying `ClientOrdersRepository` or adding new Firestore queries — the existing stream is sufficient.
- NOT adding pagination or infinite scroll to history — all orders load via existing stream. If order volume grows, pagination can be a follow-up.
- NOT implementing push notification integration for status changes — out of scope.
- NOT fixing the hardcoded Russian in `Order.pickupLabel` (domain model line 68-78) — that's a pre-existing issue, separate cleanup task.
- NOT localizing existing `OrderStatusBadge` labels (currently hardcoded English) — pre-existing issue, separate cleanup task. The new `OrderStatusProgressLine` labels will be localized (R12).

## Validation

**Automated tests:**
- Unit: test `OrderStatusProgressLine` widget renders correct number of filled/unfilled dots for each `OrderStatus` value (file: `test/src/features/orders/presentation/client/widgets/order_status_progress_line_test.dart`).
- Widget: test `OrdersScreen` shows inline view for 1 active order, list view for 2+ active, empty state for 0 active, and max 3 recent orders (file: `test/src/features/orders/presentation/client/orders_screen_test.dart`).

**Manual QA scenarios:**
1. Given 1 active order (status=preparing), when opening Orders tab, then see inline expanded view with progress line filled to "Preparing" dot + pickup info.
2. Given 3 active orders, when opening Orders tab, then see 3 cards in active section. Tapping one → OrderDetailScreen with progress line.
3. Given 0 active orders and 5 past orders, when opening Orders tab, then see empty state message + 3 recent order cards.
4. Given 0 orders total, when opening Orders tab, then see empty state. Tap history icon → history screen also empty.
5. Given a cancelled order, when viewing its detail screen, then see `OrderStatusBadge` (red "Cancelled"), NOT the progress line.
6. Given an active order (status=confirmed), when business moves it to preparing (Firestore update), then progress line on orders screen animates to fill the "Preparing" dot in real-time.
7. Tap history icon in AppBar → `OrderHistoryScreen` shows all orders newest-first. Tap any → `OrderDetailScreen`. Back → history. Back → orders tab.

**Expected behavior under edge conditions:**
- Offline → Firestore offline cache shows last-known data. Progress line reflects cached status.
- Backend error → `AsyncValueWidget` shows error message with retry option.
- Empty data → Empty state placeholder, history button still accessible.

## Definition of Done
- [ ] All Must Have requirements pass automated tests
- [ ] All Manual QA scenarios pass on iOS and Android
- [ ] No new lint warnings; `flutter analyze` clean
- [ ] No hardcoded strings in new/modified Dart files
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds (for Riverpod codegen if any new providers)
- [ ] Spec file linked in the PR description
