# Plan: Admin Dev Menu

Source: `ai_specs/013-admin-dev-menu-spec.md`
Created: 2026-06-26
Status: in-progress

## Overview
Add a floating debug menu for admin users in the business app. A FAB (bug icon) on all store-scoped screens opens a full-screen `/dev` route listing every `BusinessRoute` with category grouping and parameter inputs. Admin redirect bypass via `devMenu=true` query param allows navigating to onboarding screens that Layer 6 normally blocks.

**Spec:** `ai_specs/013-admin-dev-menu-spec.md`

## Context
- **Structure:** Feature-first (`features/{name}/domain|data|application|presentation`)
- **State management:** Riverpod codegen (`@riverpod`) — e.g. `lib/src/routing/business_redirect_state.dart:34`
- **Reference implementations:** `lib/src/routing/business_router.dart` (route enum + redirect), `lib/src/routing/scaffold_with_nested_navigation.dart` (scaffold with sidebar + FAB target)
- **Testing convention:** Unit tests mirror `lib/` structure, `group()` + `test()`, test pure functions directly — `test/routing/business_redirect_test.dart:9` (helper `_redirect()`)
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:** none — spec is detailed and refined

## Plan

### Phase 1 — Thin vertical slice: route, redirect bypass, basic screen
**Goal:** Admin can navigate to `/dev`, see a flat list of routes, and tap one to navigate. Partner is blocked from `/dev`. Admin can reach onboarding screens via `devMenu=true`.

- [x] TDD: `test/routing/business_redirect_test.dart` — admin at `/dev` → stay (null); partner at `/dev` → `/stores`; admin at `/onboarding/inbound/review-details` with `uri.queryParameters['devMenu'] == 'true'` → null (bypass Layer 6)
- [x] `lib/src/routing/business_router.dart` — add `dev` to `BusinessRoute` enum; change `businessRedirect()` signature to accept `Uri uri` instead of `String path` (derive `path` from `uri.path` internally); add admin-only `/dev` guard before Layer 6; in Layer 6, when `uri.queryParameters['devMenu'] == 'true'` and role is admin, return `null`; update GoRouter `redirect` callback to pass `state.uri`
- [x] `test/routing/business_redirect_test.dart` — update `_redirect()` helper to accept `Uri uri` instead of `String path`; fix all existing calls
- [x] `lib/src/features/dev_menu/presentation/dev_menu_screen.dart` — create screen with flat `ListView` of all `BusinessRoute.values`, each as `ListTile` showing route name and path; `onTap` navigates via `context.go(path)`
- [x] `lib/src/routing/business_router.dart` — add top-level `GoRoute(path: '/dev', name: BusinessRoute.dev.name, builder: → DevMenuScreen)`
- [x] Verify: `flutter analyze && flutter test`

### Phase 2 — FAB + category grouping + parameter inputs
**Goal:** Admin sees bug FAB on all store-scoped screens. Dev menu groups routes by category with editable path parameter fields.

- [x] `lib/src/routing/scaffold_with_nested_navigation.dart` — add `floatingActionButton` to `Scaffold` in narrow layout (line 117) and inner `Scaffold` in wide layout (line 144); gate visibility on `ref.watch(userRoleProvider)` matching `UserRole.admin`; convert `ScaffoldWithNestedNavigation` to `ConsumerWidget`; FAB icon `Icons.bug_report`, onTap → `context.go('/dev')`
- [x] `lib/src/features/dev_menu/presentation/dev_menu_screen.dart` — group routes into categories (Onboarding, Store/Dashboard, Settings, Other); show section headers; for routes with `:paramName` segments, show `TextField` per param; pre-fill `:storeId` from current context if available; append `?devMenu=true` to generated path for onboarding routes; navigate with entered values on tap
- [x] TDD: partner on dashboard → FAB not visible; admin on dashboard → FAB visible (manual QA only — widget test not feasible without mocking StatefulNavigationShell; per architecture.md: "No widget tests required unless UI is complex/critical")
- [x] Verify: `flutter analyze && flutter test`

### Phase 3 — Nice-to-haves (search + copy)
**Goal:** Search/filter bar and copy-path button.

- [ ] `lib/src/features/dev_menu/presentation/dev_menu_screen.dart` — add `TextField` at top for filtering routes by name; add copy-path `IconButton` per route item using `Clipboard.setData`
- [ ] Verify: `flutter analyze && flutter test`

## Data layer changes
_None._

## External integrations
_None._

## Risks
- Changing `businessRedirect()` signature from `String path` to `Uri uri` touches every call site (router callback + all tests). Mitigated by keeping `path` derived from `uri.path` internally — behavior is identical for all non-devMenu callers.
- FAB in `ScaffoldWithNestedNavigation` requires converting it to `ConsumerWidget` to access `userRoleProvider`. Low risk — widget is already stateless and the change is additive.

## Out of scope
- Mock/fake data for screens
- Client app dev menu
- Automated screen testing (golden/screenshot)
- Editing redirect logic for partners
- Feature flags
