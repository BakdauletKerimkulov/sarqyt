# Routing Decisions

App structure, routing patterns, and scoped-provider decisions. Last verified: 2026-10-04.

## Two separate apps, not one app with role switching

`lib/main_business.dart` (business) and `lib/main_client.dart` (client) are two independent entry points with two independent `GoRouter` instances (`business_router.dart`, `client_router.dart`). There is no runtime role switch inside a single app. Reason: the two audiences (store staff vs. customers) have almost no shared screens, and keeping them separate avoids a large conditional-routing surface and lets each app ship independently — on Android as two product flavors with their own `applicationId` (spec 050). Hosting is a single site with no named targets (see `EXTERNAL_SERVICES.md`): only the business console is deployed to web, selected by `-t`, not by a hosting target.

## `businessRedirect()` — synchronous-only, layered

`lib/src/routing/business_router.dart` implements the redirect logic as a sequence of numbered layers evaluated top-to-bottom (`Layer 1` … `Layer 9`, plus `Layer 5.5` for the dev-menu gate). All layers are synchronous — GoRouter's `redirect` callback cannot `await`, so every check reads from an already-resolved Riverpod state (role, storeShips, email-verified) rather than fetching. Current layers (see file for exact logic):

1. Unauthenticated
2. Email not verified
3. Role still loading → hold on `/loading` to avoid a verify-email flash
4. Verified guest (no claims yet) — allow inbound onboarding paths
5. Non-partner / non-admin
5.5. `/dev` is admin-only — partner is redirected away
6. Admin — bypasses the welcome flow entirely
7. Partner — wait for `storeShips` before deciding welcome vs. stores
8. Partner with ≥1 storeShip pending welcome → `/welcome`
9. Partner done

A `devMenu=true` query parameter lets an admin bypass Layer 6's shortcut to reach onboarding screens directly for debugging (`ai_specs/archive/013-admin-dev-menu-spec.md`).

## `StoreStartupWidget` — scoped provider override

Routes under `/stores/:storeId/*` are wrapped in a nested `ProviderScope` (`lib/src/routing/store_startup.dart`) that overrides `currentStoreShipProvider`, `currentBusinessProvider`, `currentBusinessStreamProvider` scoped to the `storeId` path parameter. This means every screen under that path segment reads "the current store" from a scoped provider, not a route argument — avoids threading `storeId` through every widget constructor. If the admin (via dev menu) is not actually a partner at the entered `storeId`, this widget throws `StateError` and renders its own error state with a "Go to login" button.

## Tab / branch counts

- Client app (`client_router.dart`): 3 `StatefulShellBranch`es — Discover, Orders, Profile.
- Business app (`business_router.dart`): 5 `StatefulShellBranch`es — Dashboard, Performance, Financials, Settings, Help Centre.

If a tab is added or removed, update both the router's branch list and `ScaffoldWithNestedNavigation`.

## Admin dev menu (`/dev`)

`BusinessRoute.dev` — a full-screen list of every registered business route, tap-to-navigate, gated to `userRoleProvider == UserRole.admin` (FAB only visible to admins in `scaffold_with_nested_navigation.dart`). Built specifically so bugs on hard-to-reach onboarding screens can be reproduced without manufacturing the exact auth/draft state normally required. See `ai_docs/solutions/` and `ai_specs/archive/013-admin-dev-menu-spec.md`.

## Which app ships to web is a build-command decision, not a router constraint

Only the business console is built for web, and the entry point chosen on the command
line is what decides it: `flutter build web -t lib/main_business.dart`. There is one
hosting site and no named targets in `firebase.json` — nothing in the hosting config
selects an app, and the client stays mobile-only (spec 050, [L4]). The router files
themselves are flavor-agnostic.

## See also

- `ai_docs/PROJECT.md` — module list, general architecture
- `ai_docs/BUSINESS_RULES.md` — partner role/permission definitions referenced by the redirect layers
