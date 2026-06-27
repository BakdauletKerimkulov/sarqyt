# Spec: Admin Dev Menu

Created: 2026-06-26
Status: refined
Refined: 2026-06-26
Source request: ai_specs/013-detail-managing-business-ui.md

## Goal
Give admin users a floating debug menu in the business app that lists every screen and allows direct navigation — bypassing redirect guards — so admins can visually inspect any screen, reproduce bugs, and test UI flows without going through the full onboarding/store setup.

## Background
**Stack & conventions:** Flutter + Riverpod codegen + GoRouter. Feature-first structure (`features/{name}/domain|data|application|presentation`). Widgets must not contain business logic. All navigation via GoRouter named routes. Admin role detected via Firebase custom claims (`claims['admin'] == true`). See `ai_toolkit/architecture.md`, `ai_toolkit/gorouter.md`, `ai_toolkit/riverpod.md`.

**Project context:** The business app (`main.dart`) uses a 9-layer redirect in `businessRedirect()` (`lib/src/routing/business_router.dart:80-150`). Layer 6 already gives admin a shortcut: it bypasses welcome and redirects onboarding/login/forbidden paths to `/stores`. However, admin **cannot** navigate to onboarding screens (create-account, review-details, email, verify-email) because the redirect actively blocks them. Screens under `/stores/:storeId/*` require `StoreStartupWidget` to load `storeShip` and `business` data via scoped provider overrides (`lib/src/routing/store_startup.dart:55-101`). There are currently **no dev/debug tools** in either app.

**Why now:** The user has a real bug (continue button on review-details screen) that is hard to reproduce because navigating to onboarding screens requires a specific auth/draft state. An admin dev menu eliminates this friction for all future debugging.

## User Flow

### Happy path
1. Admin signs into the business app → redirected to `/stores/:storeId/dashboard`.
2. A floating action button (bug icon) is visible in the bottom-right corner of the dashboard screen.
3. Admin taps FAB → full-screen Dev Menu opens (`/dev`) listing all routes grouped by category.
4. Admin taps a route (e.g. "Review Details") → app navigates directly to that screen, bypassing redirect guards.
5. Admin presses back → returns to dev menu or dashboard.

### Alternative flows
- **Route with path parameters** (e.g. `/stores/:storeId/item/:itemId`): Dev menu shows the route with a text field for each parameter. Admin can type a real storeId/itemId or leave the placeholder value. Navigation uses whatever value is entered.
- **Route under StoreStartupWidget** (dashboard, item, settings, etc.): If the admin already has a store (is also a partner), the current storeId is pre-filled. If the admin is not a partner at the entered store, `storeStartupProvider` will throw `StateError` because it queries `currentPartnerStoreShipsProvider` (only the user's own storeShips). The StoreStartupWidget error state will render with a "Go to login" button. This is a known limitation — store-scoped routes are only fully debuggable for stores where the admin is also a partner.
- **Admin navigates to an onboarding screen** (create-account, review-details): The screen renders with whatever state exists (e.g. empty draft). Error/empty states are expected and useful for debugging.

### Error & recovery flows
- If admin enters an invalid storeId or itemId → StoreStartupWidget or the screen's provider shows its standard error state. Admin can go back.
- If navigation fails (unknown route) → GoRouter's errorBuilder shows "Page not found" with a "Go to login" button.

### Edge cases
- **Non-admin user**: FAB is not visible. `/dev` route redirects to `/stores` — requires explicit admin check (see R7), because existing redirect layers do not block `/dev` for partners (Layer 9 only checks `/login`, `/onboarding`, `/forbidden`, `/loading`).
- **Admin with no stores**: FAB still visible. Routes under `/stores/:storeId/*` require manual storeId input in dev menu.
- **Deep link to /dev**: Works for admin, redirected away for non-admin.

## Requirements

### Must Have
- [ ] R1: New `BusinessRoute.dev` enum value and `/dev` route in the business router. Verifiable by: navigating to `/dev` as admin shows the dev menu screen.
- [ ] R2: Dev menu screen lists all `BusinessRoute` values grouped into categories (Onboarding, Store/Dashboard, Settings, Other). Each item shows the route name and its path. Verifiable by: all 20+ routes are listed.
- [ ] R3: Tapping a route in the dev menu navigates to that screen. Verifiable by: tapping "Review Details" shows the ReviewDetailsScreen.
- [ ] R4: Admin redirect bypass: add a `Uri uri` parameter (or `Map<String, String> queryParameters`) to `businessRedirect()` and update the GoRouter callback to pass `state.uri` instead of just `state.uri.path`. In Layer 6, when `uri.queryParameters['devMenu'] == 'true'` and role is admin, return `null` (allow navigation) instead of redirecting to `/stores`. Verifiable by: admin can navigate to `/onboarding/inbound/review-details?devMenu=true` without being redirected to `/stores`.
- [ ] R5: FAB with bug icon visible only to admin. Place in `ScaffoldWithNestedNavigation` (not just `DashboardScreen`) so the FAB is accessible from all store-scoped screens. Gate visibility on `userRoleProvider == UserRole.admin`. Verifiable by: FAB appears for admin on dashboard, performance, settings, etc.; does not appear for partner.
- [ ] R6: Routes with path parameters show editable text fields in the dev menu. Pre-fill `:storeId` with the current store if available. Verifiable by: `/stores/:storeId/item/:itemId` shows two text fields.
- [ ] R7: The `/dev` route is admin-only. **Existing redirect logic does NOT block `/dev` for partners** (Layer 9 only catches `/login`, `/onboarding`, `/forbidden`, `/loading`). Add an explicit check: either (a) add `if (path.startsWith('/dev') && role != UserRole.admin) return '/stores';` to `businessRedirect()` before Layer 6, or (b) add a route-level `redirect` on the `/dev` GoRoute. Verifiable by: partner navigating to `/dev` is redirected to `/stores`.

### Nice to Have
- [ ] N1: Search/filter bar at the top of the dev menu to quickly find a route by name.
- [ ] N2: "Copy path" button next to each route for sharing with other developers.
- [ ] N3: Show route metadata (which navigator key, parent route) as subtitle text.

### Non-functional
- Performance: dev menu is a simple ListView — no performance concern.
- Accessibility: standard Material list tiles, no special requirements.
- i18n: dev menu is English-only (developer tool, not user-facing). No ARB keys needed.

## Technical Constraints

**Files to create:**
- `lib/src/features/dev_menu/presentation/dev_menu_screen.dart` — full-screen list of all routes with category grouping and parameter input fields. ~150-200 lines.

**Files to modify:**
- `lib/src/routing/business_router.dart` — add `dev` to `BusinessRoute` enum; add `/dev` GoRoute at the top level (no `parentNavigatorKey` needed — top-level routes use root navigator by default); change `businessRedirect()` signature to accept `Uri uri` (or add `queryParameters`); add admin-only guard for `/dev` path; modify Layer 6 to check `devMenu=true` query param.
- `lib/src/routing/scaffold_with_nested_navigation.dart` — add conditional FAB (visible only for admin via `userRoleProvider`) to the `Scaffold` in both narrow and wide layouts. This avoids nested-Scaffold issues that would arise from adding the FAB inside `DashboardScreen` (which returns a raw `CustomScrollView`).

**Patterns to follow (with citations):**
- Route definition: follow existing GoRoute pattern in `business_router.dart:207-408`.
- Admin role check: use `userRoleProvider` from `lib/src/features/auth/data/auth_repository.dart` (same pattern as `businessRedirectStateProvider`).
- FAB placement: add `floatingActionButton` to the `Scaffold` in `ScaffoldWithNestedNavigation` (both narrow layout at line 117 and wide layout at line 144). Gate on `userRoleProvider`. This avoids a nested-Scaffold pattern — `DashboardScreen` returns a raw `CustomScrollView`, so wrapping it in a second `Scaffold` just for a FAB would be fragile.

**Anti-patterns / avoid:**
- Do not create a separate `main_dev.dart` entry point — the dev menu is admin-gated, not build-gated.
- Do not create fake/mock data infrastructure — out of scope.
- Do not modify StoreStartupWidget — screens under it will show loading/error naturally if data is missing.
- Do not add new dependencies — everything is achievable with existing packages.

**Data layer changes:** None. No Firestore changes, no security rules, no indexes.

**External integrations:** None.

## Out of Scope
- **Mock/fake data for screens** — screens will render with real data or show error/empty states. Adding mock infrastructure is a separate effort.
- **Client app dev menu** — this spec covers only the business app. Client app can be added later with the same pattern.
- **Automated screen testing** — no screenshot or golden tests. This is a manual debugging tool.
- **Editing redirect logic for partners** — only admin gets the bypass. Partner redirect remains unchanged.
- **Feature flags** — no feature flag infrastructure. Admin role is the gate.

## Validation

**Automated tests:**
- Unit: test `businessRedirect()` with `devMenu=true` query param — admin should not be redirected away from onboarding paths. Also test that partner navigating to `/dev` is redirected to `/stores` (admin-only guard). File: `test/routing/business_redirect_test.dart` (new or extend existing).

**Manual QA scenarios:**
1. Given admin is signed in and on any store-scoped screen (dashboard, performance, settings, etc.), when they tap the bug FAB, then dev menu opens with all routes listed.
2. Given admin is on dev menu, when they tap "Review Details", then ReviewDetailsScreen renders (may show empty draft state).
3. Given admin is on dev menu, when they tap "Dashboard" and enter a valid storeId, then dashboard renders with that store's data.
4. Given admin is on dev menu, when they tap "Dashboard" and enter an invalid storeId, then error state is shown.
5. Given partner is signed in and on any store-scoped screen, then no bug FAB is visible.
6. Given partner navigates to `/dev` via URL, then they are redirected to `/stores`.

**Expected behavior under edge conditions:**
- Admin with no stores → FAB visible, store-scoped routes require manual storeId input.
- Invalid path parameters → standard error/loading states from existing widgets.
- Non-admin at `/dev` → redirect to appropriate page per existing redirect logic.

## Definition of Done
- [ ] All Must Have requirements pass manual QA scenarios
- [ ] `businessRedirect()` unit test covers devMenu=true bypass for admin
- [ ] No new lint warnings; matches `ai_toolkit/` style guide
- [ ] `flutter analyze` passes
- [ ] Spec file linked in the PR description
