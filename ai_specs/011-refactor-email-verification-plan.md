# Plan: Fix Business Onboarding Navigation

Source: `ai_specs/011-refactor-email-verification-spec.md`
Created: 2026-06-12
Status: complete

## Overview
Fix four compounding defects in business-app registration/onboarding navigation: (1) dead-end for verified guests with missing/expired drafts, (2) incomplete rollback on failed registration, (3) cold-start verify-email flash, (4) unguarded welcome screen for non-owners. Phase 1 fixes the redirect and rollback (the two mutually-dependent critical-path defects). Phase 2 adds the recovery UI on verify-email and the already-signed-in branch on email screen. Phase 3 hardens welcome guard and adds i18n.

**Spec:** `ai_specs/011-refactor-email-verification-spec.md`

## Context
- **Structure:** feature-first (`lib/src/features/*/domain|data|application|presentation`)
- **State management:** Riverpod codegen (`@riverpod` / `@Riverpod(keepAlive: true)`); controllers = auto-dispose AsyncNotifiers with `_mounted` check — `lib/src/features/onboarding/presentation/inbound/verify_email_controller.dart`
- **Reference implementations:** `businessRedirect` pure redirect function at `lib/src/routing/business_router.dart:79-142`; `BusinessRedirectState` aggregation at `lib/src/routing/business_redirect_state.dart`; existing test suite at `test/routing/business_redirect_test.dart` with `_redirect` helper
- **Testing convention:** unit tests mirror `lib/` structure; controllers tested via `ProviderContainer` overrides; pure functions tested directly; fakes in test siblings — `ai_toolkit/riverpod.md` → Testing & Overrides, `ai_toolkit/architecture.md` → Testing
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:**
  - Spec says `AppException` is a `sealed class` but actual code at `lib/src/exceptions/app_exception.dart` shows it as a `sealed class` — confirmed, all subtypes must live in the same file.
  - `AuthRepository.createUserWithEmailAndPassword` returns `Future<void>` (line 29), but test fake returns `Future<AppUser?>`. Plan follows the real signature.
  - `BusinessLoadingScreen` already exists at `lib/src/routing/business_loading_screen.dart` — no new screen needed for the `/loading` route.

## Plan

### Phase 1 — Redirect fixes + rollback (critical path)
**Goal:** Fix defects 2, 3 (incomplete rollback + cold-start flash) in redirect and service. These unblock the recovery path needed by Phase 2.

- [x] TDD: `test/routing/business_redirect_test.dart` — add `roleLoaded` cases: verified user with `roleLoaded: false` on `/login` → `/loading`; on `/stores/x/dashboard` → `/loading`; on `/loading` → stay; `roleLoaded: true` → falls through. Add verified-guest-on-inbound cases: guest on `/onboarding/inbound/create-account` → null; guest on `/onboarding/inbound/review-details` → null; guest on `/onboarding/inbound/email` → null; guest on `/stores` → `/onboarding/inbound/verify-email`
- [x] `lib/src/routing/business_redirect_state.dart` — add `roleLoaded` field (`bool`), derive from `roleAsync.hasValue || roleAsync.hasError`; stop mapping loading role to `guest` — pass the actual `AsyncValue` semantics
- [x] `lib/src/routing/business_router.dart` — insert role-loading layer (new Layer 3) between email-verified and guest layers: hold on `/loading` while `user != null && emailVerified && !roleLoaded`; relax old Layer 3 (now Layer 4) to allow verified guests on any `/onboarding/inbound/*` path; update doc comment layer numbering
- [x] TDD: `test/features/onboarding/merchant_onboarding_service_test.dart` — add rollback cases: draft failure → `deleteAccount()` called, user is null; `deleteAccount()` throws → `signOut()` called; original exception rethrown in both cases
- [x] `lib/src/features/auth/data/auth_repository.dart` — add `Future<void> deleteAccount()` calling `_auth.currentUser?.delete()`
- [x] `lib/src/features/onboarding/application/merchant_onboarding_service.dart` — replace `signOut()` rollback with `deleteAccount()`; if delete throws, fall back to `signOut()`; always rethrow original error
- [x] Verify: `flutter analyze && flutter test`

### Phase 2 — Draft-not-found recovery UI
**Goal:** Verified guest with expired/missing draft sees a recovery state on verify-email and can re-enter store details.

- [x] `lib/src/exceptions/app_exception.dart` — add `DraftNotFoundException extends AppException` to the sealed hierarchy
- [x] `lib/src/features/onboarding/data/onboarding_repository.dart` — wrap `completeMerchantOnboarding` call: catch `FirebaseFunctionsException` with code `not-found`, rethrow as `DraftNotFoundException`
- [x] TDD: `test/features/onboarding/verify_email_controller_test.dart` — add case: `completeMerchantOnboarding` throws `DraftNotFoundException` → controller state has `DraftNotFoundException` error; `completed` remains false
- [x] `lib/src/features/onboarding/presentation/inbound/verify_email_controller.dart` — expose `isDraftNotFound` getter (check `state.error is DraftNotFoundException`); add `stopPolling` flag set when draft-not-found detected
- [x] `lib/src/features/onboarding/presentation/inbound/verify_email_screen.dart` — render recovery state when `isDraftNotFound`: localized title + message + primary button navigating to `BusinessRoute.createAccount`; stop timer when `isDraftNotFound`; filter `DraftNotFoundException` out of `ref.listen` error dialog
- [x] TDD: `test/features/onboarding/merchant_onboarding_service_test.dart` — add case: signed-in user calls `register` with draft-only (no `createUserWithEmailAndPassword`) when `currentUser != null`
- [x] `lib/src/features/onboarding/application/merchant_onboarding_service.dart` — already-signed-in branch: if `currentUser != null`, skip `createUserWithEmailAndPassword`, call `createStoreDraft` only
- [x] `lib/src/features/onboarding/presentation/inbound/email_screen.dart` — detect signed-in user via `authRepository.currentUser`; if signed-in: pre-fill + disable email field, hide password field, hide privacy-policy checkbox, change CTA label
- [x] Verify: `flutter analyze && flutter test`

### Phase 3 — Welcome guard + i18n
**Goal:** Owner-only welcome filter; all new strings localized.

- [x] TDD: `test/features/store/store_ship_extension_test.dart` (new file) — `pendingWelcome` returns owner with `welcomeCompleted: false`; returns null for employee/operator with `welcomeCompleted: false`; returns null when all completed
- [x] `lib/src/features/store/domain/store_ship.dart` — `StoreShipListX.pendingWelcome`: add `role == StoreRole.owner` filter
- [x] `lib/src/features/onboarding/presentation/welcome/welcome_screen.dart` — guard: if resolved ship's role is not `owner`, call `markWelcomeCompleted` immediately (auto-skip)
- [x] `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_kk.arb` — add keys: `draftExpiredTitle`, `draftExpiredMessage`, `fillDetailsAgain`, `submitDetails`
- [x] Verify: `flutter analyze && flutter test`

## Data layer changes
_None._ No schema, security rules, collection paths, or index changes.

## External integrations
- Firebase Auth `User.delete()` — called seconds after account creation (fresh token, no `requires-recent-login` risk). Fallback to `signOut()` covers residual failures.

## Risks
- `User.delete()` may throw `requires-recent-login` if registration is slow and token expires — mitigated by `signOut()` fallback + the new recovery flow unblocking the orphaned account.
- Relaxing Layer 3 (now 4) to allow inbound paths for verified guests opens those routes — acceptable because the only sensitive action (account creation) is already behind `createUserWithEmailAndPassword` which would throw `email-already-in-use`.
- Role-loading layer adds a brief `/loading` screen on cold start — acceptable UX trade-off vs. the verify-email flash.

## Out of scope
- NOT persisting store draft across process death (SharedPreferences mirror)
- NOT cleaning up `StoreRole` enum (`employer` → `employee`, removing `owner`)
- NOT updating stale Stripe payment flow description in `ai_docs/PROJECT.md`
- NOT changing `createAdditionalStore` welcome behavior
- NOT adding polling backoff (spec N1)
- NOT adding structured CF error payload (spec N2)
