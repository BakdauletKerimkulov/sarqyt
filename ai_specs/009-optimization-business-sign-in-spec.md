# Spec: Optimize Business Sign-In Speed

Created: 2026-06-10
Status: refined
Refined: 2026-06-10
Source request: Оптимизировать вход в бизнес аккаунт в приложении. Сейчас вход занимает около 3-4 секунд, а то и больше. Скорее всего причина в редиректе и доп запросах на сервер. Рассмотри варианты, что показывать при загрузке. Также рассмотри метод получения списка storeShips, нужен ли он или только один storeShip?

## Goal

Reduce business sign-in time from 3-4 seconds to under 1.5 seconds by eliminating the redundant duplicate storeShips Firestore query, reusing already-loaded data, and replacing the "frozen login screen" with an immediate full-screen loading transition. The storeShips list stays (partners can have multiple stores), but the duplicate fetch is removed so `fetchBusinessInfo` is the only remaining async step in `storeStartup`.

## Background

**Stack & conventions:** Riverpod codegen (`@riverpod`), feature-first architecture, GoRouter with sync redirect callback, AsyncValue for loading states, freezed models. Per `ai_toolkit/riverpod.md`: controllers auto-dispose, repositories are `keepAlive: true`. Per `ai_toolkit/gorouter.md`: navigate by name, centralize redirect in router's top-level `redirect`. Per `ai_toolkit/architecture.md`: no Firebase imports in domain layer, repositories return domain models.

**Project context:** Sarqyt is a two-app codebase (`main.dart` = business, `main_client.dart` = client). After sign-in, the business app uses an 8-layer redirect system in `businessRedirect()` (`lib/src/routing/business_router.dart:77-138`) that waits for `userRole` and `storeShips` before navigating. The `businessRedirectStateProvider` (`lib/src/routing/business_redirect_state.dart:28-58`) aggregates auth, role, and storeShips into a synchronous state.

**Current bottleneck analysis (timing):**

| Step | Time | File |
|------|------|------|
| `signInWithEmailAndPassword()` | ~500-1000ms | `sign_in_business_controller.dart:13` |
| `userRoleProvider` (`idTokenChanges` → `getRole()`) | ~50-200ms | `auth_repository.dart:47-53`, `firebase_app_user.dart:57-67` |
| `currentPartnerStoreShips` stream (Firestore) | **~500-2000ms** | `store_ship_repository.dart:125-131` |
| Debounce timer in router refresh | **100ms** | `business_router.dart:147` |
| `storeStartup` redundant storeShips re-fetch | **~500-2000ms** | `store_startup.dart:27-29` |
| `storeStartup` sequential `fetchBusinessInfo()` | **~500-1500ms** | `store_startup.dart:35-37` |
| **Total** | **~3000-4500ms** | |

**Root causes:**
1. **No visual feedback** — user stays on login screen while data loads (redirect layer 6 returns `null`, keeping user on `/login`).
2. **Duplicate storeShips query** — `currentPartnerStoreShipsProvider` loads the list for redirect, then `storeStartupProvider` fetches the exact same list again via `storeShipsListStreamForPartnerProvider`.
3. **Sequential business fetch** — `storeStartup` awaits storeShips, then awaits `fetchBusinessInfo()` sequentially.
4. **100ms debounce** — adds latency on every redirect state change.

**Why now:** Users perceive 3-4 second sign-in as broken. The fix is entirely client-side (no Cloud Functions, security rules, or schema changes needed).

## User Flow

### Happy path
1. User enters email/password on `/login` → taps "Войти".
2. Button shows loading spinner, form fields become disabled (existing behavior).
3. Firebase Auth completes sign-in → screen immediately transitions to full-screen loading indicator (logo + spinner or similar).
4. In background: `userRole` and `storeShips` load in parallel (existing behavior via `businessRedirectStateProvider`). Once storeShips are loaded, redirect fires → `storeStartupProvider` reuses storeShips and fetches only `businessInfo`.
5. All data ready → redirect to `/stores/{storeId}/dashboard` (single store) or `/stores` (multiple stores). Dashboard renders with pre-loaded storeShip data and freshly fetched business info.

### Alternative flows
- Partner with pending welcome: after data loads → redirect to `/onboarding/welcome` (existing layer 7 logic, unchanged).
- Admin user: skip storeShips entirely → redirect to `/stores` (existing layer 5 logic, unchanged).
- Multiple stores with welcome completed: redirect to `/stores` list screen (existing logic, unchanged).

### Error & recovery flows
- Network error during sign-in: existing error handling via `AsyncValue` + alert dialog. User stays on login form and can retry.
- Firestore storeShips fetch fails: loading screen shows error message with "Retry" button. User can tap retry or go back to login.
- Business info fetch fails: same error screen with retry. Fallback: proceed to dashboard without business data (use storeShip name only, load business lazily).

### Edge cases
- Very slow network: loading screen stays visible. No timeout — Firestore handles retry internally.
- User signs out during loading: layer 1 sees unauthenticated + path `/loading` → redirects to `/login`. Verified: `/loading` is not in the allowed-unauthenticated set (`onLogin || onInbound`).
- Partner with storeShips where none have `welcomeCompleted`: redirect to `/onboarding/welcome` (layer 7, `pendingWelcome` check).
- Partner with zero storeShips (empty list): `pendingWelcome` is `null` → layer 8 redirects to `/stores` (empty list screen). Note: this is NOT `/onboarding/welcome`.
- Token refresh needed after sign-in: `idTokenChanges` stream handles this transparently.

## Requirements

### Must Have
- [ ] R1: After successful `signInWithEmailAndPassword`, the app navigates away from the login screen within 200ms (to a loading screen or directly to dashboard). Verifiable by: adding a stopwatch log between sign-in completion and first route transition.
- [ ] R2: Full-screen loading screen shown between sign-in and dashboard, replacing the current "frozen login" experience. Verifiable by: visual inspection — user never sees the login form after successful auth.
- [ ] R3: StoreShips list is fetched exactly once after sign-in (currently fetched twice). Verifiable by: Firestore debug logging shows a single `storeShips` query, not two.
- [ ] R4: After reusing storeShips from redirect (R5), `fetchBusinessInfo` is the only remaining async call in `storeStartupProvider`, eliminating the redundant sequential storeShips wait. Verifiable by: timing logs show `storeStartupProvider` no longer waits for storeShips (they are already loaded).
- [ ] R5: `storeStartupProvider` reuses the already-loaded storeShips data from `currentPartnerStoreShipsProvider` instead of making a new query. Verifiable by: `storeShipsListStreamForPartnerProvider` is no longer called from `storeStartup`.
- [ ] R6: Debounce timer in `_RouterRefreshNotifier` reduced from 100ms to 16ms (single frame). Verifiable by: reading the timer value in `business_router.dart`.
- [ ] R7: Existing redirect layers (1-8) continue to work correctly for all user roles and states. Verifiable by: existing navigation tests pass; manual QA of each layer.
- [ ] R8: Loading screen handles errors gracefully with a retry action and a fallback to login. Verifiable by: simulating network error during storeShips load.

### Nice to Have
- [ ] N1: Loading screen shows app logo or store name (if known from cached data). Verifiable by: visual inspection.
- [ ] N2: Skeleton shimmer on dashboard instead of a separate loading screen (two-phase transition). Verifiable by: visual inspection — dashboard layout appears immediately with shimmer placeholders.

### Non-functional
- Performance: total time from sign-in tap to interactive dashboard < 1.5 seconds on 4G connection.
- Accessibility: loading screen announces state to screen readers (`Semantics(label: 'Loading...')`).
- i18n: loading screen text (if any) uses `context.loc` keys.

## Technical Constraints

**Files to create:**
- `lib/src/routing/business_loading_screen.dart` — full-screen loading widget shown during post-auth data loading. Watches `businessRedirectStateProvider` and shows error/retry if loading fails. Placed in `routing/` following the `StoreStartupWidget` precedent.

**Files to modify:**
- `lib/src/routing/store_startup.dart` (lines 22-43) — rewrite `storeStartupProvider` to read storeShips from `currentPartnerStoreShipsProvider` (already loaded by redirect) instead of fetching via `storeShipsListStreamForPartnerProvider`. This eliminates the duplicate Firestore query; `fetchBusinessInfo()` becomes the only async call.
- `lib/src/routing/business_router.dart` (lines 141-154) — reduce debounce timer from 100ms to 16ms. Add `/loading` route that shows `BusinessLoadingScreen`. **Risk note:** reducing debounce may cause multiple redirect evaluations during sign-in (3 async sources emit independently). Verify via DevTools that no route flickering occurs; if cascading returns, try 32-50ms as compromise.
- `lib/src/routing/business_router.dart` (lines 77-138) — adjust layer 6 to redirect authenticated-but-loading users to `/loading` instead of returning `null` (which keeps them on login). **Critical:** also update layer 8 to include `/loading` in the redirect-away set: `if (onLogin || onOnboarding || onForbidden || onLoading) return '/stores'`. Without this, users will get stuck on `/loading` after data loads.
- `lib/src/routing/business_redirect_state.dart` (lines 28-58) — no structural changes needed, but may need a `isAuthenticated` convenience getter for the loading screen redirect.
- `lib/src/features/auth/presentation/sign_in_business/sign_in_business_controller.dart` — no changes needed. Sign-in controller already returns success, and redirect system handles the rest.

**Patterns to follow (with citations):**
- Follow the existing `StoreStartupWidget` pattern (`lib/src/routing/store_startup.dart:59-105`) for loading/error/data states using `AsyncValue.when()`.
- Follow redirect layer pattern in `businessRedirect()` (`lib/src/routing/business_router.dart:77-138`) for the new loading redirect.
- Reuse `currentPartnerStoreShipsProvider` (`lib/src/features/store/data/store_ship_repository.dart:124-131`) instead of creating a new provider.

**Anti-patterns / avoid:**
- Do not create a new Firestore query or provider for storeShips — reuse `currentPartnerStoreShipsProvider`.
- Do not add `keepAlive: true` to `storeStartupProvider` — it should auto-dispose with the screen.
- Do not change the Firestore `storeShips` collection structure, indexes, or security rules.
- Do not add caching of `lastStoreId` to local storage (deferred to next iteration).

**Data layer changes:** None. No schema migrations, no new collections, no security rule updates.

**External integrations:** None. All changes are client-side Flutter code.

## Out of Scope

- **NOT** caching `lastStoreId` in local storage for instant repeat sign-in — deferred to a future iteration per user decision.
- **NOT** changing the Firestore query for storeShips (index, collection path, document structure) — the query itself is fast enough; the problem is duplicate execution.
- **NOT** adding offline sign-in support — Firebase Auth already caches tokens, but Firestore data requires network.
- **NOT** changing Cloud Functions, security rules, or backend logic.
- **NOT** touching the client app sign-in flow (`main_client.dart`) — this spec is business-app only.
- **NOT** modifying the onboarding flow (welcome screen, create account, verify email) — only the post-sign-in loading path.

## Validation

**Automated tests:**
- Unit: test `businessRedirect()` with `storeShipsLoaded: false` returns `/loading` (not `null`). File: `test/routing/business_redirect_test.dart` (existing).
- Unit: test `businessRedirect()` with `storeShipsLoaded: true` and path `/loading` returns `/stores` (layer 8 must redirect away from `/loading`).
- Unit: test that `storeStartupProvider` does not subscribe to `storeShipsListStreamForPartnerProvider` (verify no duplicate query).

**Manual QA scenarios:**
1. Given a partner with one store (welcome completed), when signing in, then: loading screen appears immediately → dashboard renders within 1.5s. Login screen is never visible after auth completes.
2. Given a partner with multiple stores, when signing in, then: loading screen → store list screen. No redundant storeShips queries in Firestore debug logs.
3. Given a partner with pending welcome, when signing in, then: loading screen → welcome screen. Layer 7 redirect still works.
4. Given an admin user, when signing in, then: loading screen → `/stores`. No storeShips query executed (layer 5 bypasses).
5. Given network error during storeShips load, when signing in, then: loading screen shows error with retry button. Tapping retry re-fetches. "Go to login" button returns to `/login`.
6. Given slow network (>2s), when signing in, then: loading screen stays visible with spinner. No timeout, no blank screen.

**Expected behavior under edge conditions:**
- Offline → sign-in fails at Firebase Auth level (existing error handling). Loading screen never reached.
- Backend error (Firestore unavailable) → loading screen shows error with retry.
- Empty storeShips list → redirect to `/stores` (empty list screen). Note: `pendingWelcome` is `null` on empty list, so layer 7 does not trigger.
- Non-empty storeShips with all `welcomeCompleted: false` → redirect to `/onboarding/welcome` (layer 7, `pendingWelcome` check).

## Definition of Done

- [ ] All Must Have requirements pass automated tests
- [ ] All Manual QA scenarios pass on web (primary business platform)
- [ ] Total sign-in to dashboard time < 1.5s on 4G (measured with DevTools)
- [ ] No new lint warnings; `flutter analyze` clean
- [ ] Firestore debug logs show exactly one `storeShips` query per sign-in (not two)
- [ ] Existing redirect behavior preserved for all user roles (guest, partner, admin, non-partner)
- [ ] No regressions in onboarding flow (welcome, verify-email)
- [ ] Spec file linked in the PR description
