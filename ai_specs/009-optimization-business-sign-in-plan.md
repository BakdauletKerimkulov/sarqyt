# Plan: Optimize Business Sign-In Speed

Source: `ai_specs/009-optimization-business-sign-in-spec.md`
Created: 2026-06-10
Status: draft

## Overview
Eliminate the duplicate storeShips Firestore query, add a `/loading` route with a full-screen loading screen between sign-in and dashboard, reduce the router debounce timer, and make `storeStartupProvider` reuse the already-loaded storeShips from `currentPartnerStoreShipsProvider`. No backend or schema changes.

**Spec:** `ai_specs/009-optimization-business-sign-in-spec.md`

## Context
- **Structure:** feature-first (`lib/src/features/*/domain|data|application|presentation`)
- **State management:** Riverpod codegen (`@riverpod`), controllers auto-dispose, repos `keepAlive: true` — cited: `lib/src/routing/business_redirect_state.dart:28`
- **Reference implementations:** `StoreStartupWidget` (`lib/src/routing/store_startup.dart:59-105`) for loading/error/data via `AsyncValue.when()`. `businessRedirect()` (`lib/src/routing/business_router.dart:77-138`) for layered redirect logic.
- **Testing convention:** unit tests in `test/` mirroring `lib/` structure, `group()` for related tests, mock repos for controller tests — cited: `ai_toolkit/architecture.md` (Testing section). Existing: `test/routing/business_redirect_test.dart`.
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:**
  - Spec says "logo + spinner or similar" for loading screen — no design provided; will use simple `CircularProgressIndicator` centered on `Scaffold` with optional logo.
  - l10n keys for loading screen text ("Loading...", "Retry", error messages) may not exist yet — will need to add to ARB files.
  - Debounce reduction from 100ms to 16ms may cause route flickering if 3 async sources emit independently — spec acknowledges this risk and suggests 32-50ms as fallback.

## Plan

### Phase 1 — Thin vertical slice: loading route + redirect change
**Goal:** After sign-in, user immediately sees `/loading` instead of frozen login. Redirect layers updated. No storeShips optimization yet.

- [x] TDD: `test/routing/business_redirect_test.dart` — partner authenticated + `storeShipsLoaded: false` + path `/login` → returns `/loading` (not `null`)
- [x] TDD: `test/routing/business_redirect_test.dart` — partner authenticated + `storeShipsLoaded: true` + path `/loading` → returns `/stores` (layer 8 redirects away from `/loading`)
- [x] `lib/src/routing/business_loading_screen.dart` — new full-screen loading widget: `Scaffold` with centered `CircularProgressIndicator`, watches `businessRedirectStateProvider` for error state, shows error + retry + "Go to login" button on failure. Uses `context.loc` for all strings.
- [x] `lib/l10n/app_en.arb`, `app_ru.arb`, `app_kk.arb` — add l10n keys: `loadingPleaseWait`, `retry`, `somethingWentWrong` (if not already present)
- [x] `lib/src/routing/business_router.dart` — (1) add `loading` to `BusinessRoute` enum; (2) add `GoRoute(path: '/loading', ...)` rendering `BusinessLoadingScreen`; (3) layer 6: change `return null` → `return onLogin ? '/loading' : null` so authenticated partner on `/login` navigates to `/loading`; (4) layer 8: add `onLoading` to the redirect-away set (`if (onLogin || onOnboarding || onForbidden || onLoading) return '/stores'`)
- [x] Verify: `flutter analyze && flutter test`

### Phase 2 — Eliminate duplicate storeShips fetch + reduce debounce
**Goal:** `storeStartupProvider` reuses storeShips from redirect; debounce reduced. Total sign-in time drops to ~1.5s.

- [ ] TDD: `test/routing/store_startup_test.dart` — `storeStartupProvider` returns `StoreStartupData` when given a storeId matching an already-loaded storeShip from `currentPartnerStoreShipsProvider`, without subscribing to `storeShipsListStreamForPartnerProvider`
- [ ] `lib/src/routing/store_startup.dart` — rewrite `storeStartupProvider`: read storeShips from `ref.watch(currentPartnerStoreShipsProvider)` instead of `storeShipsListStreamForPartnerProvider`. Extract matching ship by `storeId`. Only `fetchBusinessInfo()` remains as async call.
- [ ] `lib/src/routing/business_router.dart` — reduce `_RouterRefreshNotifier` debounce from `100ms` to `16ms`. If testing reveals flickering, increase to `32ms`.
- [ ] Verify: `flutter analyze && flutter test`

### Phase 3 — Error handling polish + manual QA
**Goal:** Loading screen handles all error/edge cases from the spec.

- [ ] `lib/src/routing/business_loading_screen.dart` — add error state handling: watch `currentPartnerStoreShipsProvider` for `AsyncError`, display error message + retry button (`ref.invalidate`), "Go to login" navigates to `/login`
- [ ] TDD: `test/routing/business_redirect_test.dart` — admin user + path `/loading` → returns `/stores` (layer 5 includes `/loading` in redirect-away set)
- [ ] TDD: `test/routing/business_redirect_test.dart` — unauthenticated + path `/loading` → returns `/login` (layer 1 doesn't allow `/loading`)
- [ ] Verify: `flutter analyze && flutter test`

## Data layer changes
_None._

## External integrations
_None._

## Risks
- Reducing debounce from 100ms to 16ms may cause rapid redirect evaluations during sign-in (3 async sources emit independently). Mitigation: test with DevTools, fallback to 32-50ms if flickering occurs.
- Layer 6 change (redirecting to `/loading` instead of `null`) changes behavior for partners already on non-login pages when storeShips haven't loaded. Mitigation: only redirect to `/loading` when on `/login`, otherwise keep current `null` behavior.
- `currentPartnerStoreShipsProvider` is a stream — `storeStartupProvider` reading from it assumes data is already loaded by redirect. If somehow entered without redirect (deep link), the stream may not have emitted yet. Mitigation: `storeStartupProvider` should handle `AsyncLoading` state gracefully (it will propagate as loading via the `AsyncValue`).

## Out of scope
- Caching `lastStoreId` in local storage for instant repeat sign-in — deferred to future iteration.
- Changing Firestore storeShips query (index, collection path, document structure).
- Offline sign-in support.
- Cloud Functions, security rules, backend changes.
- Client app sign-in flow (`main_client.dart`).
- Onboarding flow modifications.
