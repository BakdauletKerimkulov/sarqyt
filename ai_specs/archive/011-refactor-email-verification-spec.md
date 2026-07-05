---
title: Refactor Email Verification
status: done
date: 2026-06-11
type: refactor
---

# Spec: Fix Business Onboarding Navigation

Source request: Fix the four business-app registration/onboarding navigation problems found in code review: (1) verified-guest dead-end when store draft is missing/expired, (2) incomplete rollback on failed registration, (3) verify-email screen flash on cold start, (4) welcome-flow not guarded by store role.

## Goal

Make the business-app registration and onboarding navigation resilient. A user whose store draft expired (or was never created due to a failed Cloud Function call) must be able to recover by re-entering store details instead of being permanently trapped on the verify-email screen. A failed registration must fully roll back the just-created Auth account. A signed-in partner must never see a flash of the verify-email screen while role claims load on cold start. The welcome flow must only target owner-role storeShips, protecting against legacy documents and future ship-creation paths.

## Background

**Stack & conventions:** All providers use Riverpod codegen (`@riverpod` / `@Riverpod(keepAlive: true)`) — `ai_toolkit/riverpod.md`. Controllers are auto-dispose AsyncNotifiers with `_mounted` checks after awaits; repositories are `keepAlive` functional providers. Firebase errors are mapped to typed `AppException`s in the data layer via the `FirebaseErrorMapper` pattern — `ai_toolkit/architecture.md` → Error Handling. Redirect guards stay pure and synchronous — `ai_toolkit/architecture.md` → Redirect guards (AppPhase). All user-visible strings go through ARB localization (`context.loc.*`) — `ai_toolkit/architecture.md` → Localization; ARB apostrophe rule in `ai_toolkit/code-style.md`. Tests mirror `lib/` structure; controllers are tested by overriding repository providers — `ai_toolkit/riverpod.md` → Testing & Overrides.

**Project context:** The business app uses a layered pure redirect function `businessRedirect` (`lib/src/routing/business_router.dart:79-145`), driven by the aggregated sync provider `businessRedirectState` (`lib/src/routing/business_redirect_state.dart`). Registration flow: `CreateAccountScreen` → `ReviewDetailsScreen` → `EmailScreen` → `MerchantOnboardingService.register` (`lib/src/features/onboarding/application/merchant_onboarding_service.dart:16-35`) which calls `createUserWithEmailAndPassword` then the `startMerchantOnboardingData` Cloud Function. Email verification is polled by `VerifyEmailController.checkAndComplete` (`lib/src/features/onboarding/presentation/inbound/verify_email_controller.dart:20-48`), which calls the `completeMerchantOnboarding` CF. That CF throws `not-found` when no pending draft exists (`functions/src/features/merchant-onboarding/functions/complete-merchant-onboarding.ts:52`). Drafts expire after 3 days (`functions/src/features/merchant-onboarding/mappers/store-draft-mapper.ts`, `expiresAt`). Partner claims are set **only** inside `completeMerchantOnboarding`, so a verified user without a draft stays `role == guest` forever. `inviteTeamMember` already sets `welcomeCompleted: true` for invited members (`functions/src/features/stores/functions/invite-team-member.ts:93`), so the welcome gap applies only to legacy storeShip documents and future ship-creation paths.

**Four concrete defects:**
1. **Dead-end.** Redirect Layer 3 (`business_router.dart:107-112`) forces every verified `guest` to `/onboarding/inbound/verify-email`. With no pending draft, `completeMerchantOnboarding` fails with `not-found` in an endless retry loop, and the user cannot reach `create-account` to recreate the draft because Layer 3 bounces them back.
2. **Incomplete rollback.** `MerchantOnboardingService.register` signs out on draft-creation failure (`merchant_onboarding_service.dart:30`) but leaves the Auth account alive — producing exactly the orphaned verified-guest accounts that hit defect 1, plus `email-already-in-use` on retry.
3. **Cold-start flash.** `businessRedirectState` maps a *loading* role to `UserRole.guest` (`business_redirect_state.dart:40-44`), so on every cold start a signed-in partner is redirected to verify-email for the duration of the token load, then yanked to `/stores`.
4. **Unguarded welcome.** Layer 7 (`business_router.dart:133-137`) and `StoreShipListX.pendingWelcome` (`lib/src/features/store/domain/store_ship.dart:40-41`) treat any ship with `welcomeCompleted == false` as welcome-pending, regardless of role. Legacy employee ships (created before invite-team-member set the flag) would force employees into the owner-oriented welcome screen.

**Why now / why this approach:** Defects 1+2 compound: 2 produces the accounts that 1 traps. The fix order is dictated by that coupling — unblocking inbound routes (1) turns the rollback fallback path (2) from a catastrophe into a recoverable state. Recovery UX decision (confirmed with maintainer): user re-enters store details on `create-account`; no server-side draft resurrection. Rollback decision (confirmed): `user.delete()` with `signOut()` fallback — delete is safe immediately after account creation (fresh token, no `requires-recent-login`).

## User Flow

### Happy path
1. User taps "Sign up your business" on `/login` → `create-account` form → fills store details → `review-details` (geocode preview) → `email` screen.
2. User submits email + password → `register()` creates Auth user, then calls `startMerchantOnboardingData` CF (draft created server-side).
3. Redirect sends user to `/onboarding/inbound/verify-email`; verification email is sent; polling starts.
4. User verifies email → next poll: `completeMerchantOnboarding` creates business/store/storeShip, sets partner claims → token refresh → redirect.
5. Owner ship has `welcomeCompleted == false` → redirect → `/onboarding/welcome` → user taps Continue → `/stores` → single-store auto-forward to `/stores/{id}/dashboard`.

### Alternative flows
- **Recovery from missing/expired draft (new):** verified guest lands on `/onboarding/inbound/verify-email` → poll calls `completeMerchantOnboarding` → CF returns `not-found` → screen replaces the generic error with a "registration session expired" state and a primary button → button navigates to `/onboarding/inbound/create-account` (redirect now permits this) → user re-fills the form → `review-details` → on `email` step the user is **already signed in**, so the flow calls only `startMerchantOnboardingData` (no `createUserWithEmailAndPassword`) → redirect returns user to verify-email → email already verified → next poll completes onboarding → welcome.
- **Cold start, signed-in partner:** role claims still loading → user is held on `/loading` (BusinessLoadingScreen) instead of verify-email → claims arrive → redirect proceeds to Layer 4+.
- **Owner creates an additional store:** `createAdditionalStore` sets `welcomeCompleted: false` on the new owner ship → Layer 7 still routes to welcome. Unchanged, intentional.

### Error & recovery flows
- **Draft CF fails during registration:** `register()` attempts `user.delete()`; on success user stays signed out on `/login` and sees the mapped error dialog; retry re-creates the account cleanly. If `delete()` itself throws, fall back to `signOut()` — the orphaned account is now recoverable via the missing-draft flow above.
- **`completeMerchantOnboarding` fails with a non-`not-found` error (network, internal):** existing behavior preserved — error dialog with Retry button; polling continues.
- **`user.reload()` fails inside polling:** existing behavior preserved (silent, retried on next tick).

### Edge cases
- **Verified guest deep-links to `/onboarding/inbound/email`:** allowed by the relaxed Layer 3; `EmailScreen` detects an existing signed-in user and submits draft-only (no account creation).
- **Unauthenticated user:** unchanged — Layer 1 allows `/login` and `/onboarding/inbound/*` only.
- **Legacy employee ship with `welcomeCompleted == false`:** Layer 7 ignores non-owner ships → employee goes straight to `/stores`.
- **Partner with zero ships (all loaded):** `pendingWelcome` (owner-filtered) is null → Layer 8 → `/stores` empty list. Unchanged.
- **Role stream emits error:** treat as `roleLoaded == true` with `guest` value — user proceeds to inbound recovery rather than being stuck on `/loading` forever.
- **Race: user verifies email before draft CF returns:** unchanged risk window, but now self-healing — a `not-found` from `completeMerchantOnboarding` lands in the recovery state instead of a dead loop.

## Requirements

### Must Have
- [ ] R1: `businessRedirect` Layer 3 allows a verified `guest` to remain on any `/onboarding/inbound/*` path; any other path still redirects to `/onboarding/inbound/verify-email`. Verifiable by unit tests in `test/routing/business_redirect_test.dart` (cases: verified guest on `create-account`, `review-details`, `email`, `verify-email` → null; on `/stores`, `/login`, `/onboarding/welcome` → verify-email).
- [ ] R2: `BusinessRedirectState` gains a `roleLoaded` flag (`roleAsync.hasValue || roleAsync.hasError`); a new redirect layer between current Layers 2 and 3 holds the user on `/loading` while `user != null && emailVerified && !roleLoaded` (redirecting from any other path, staying put if already on `/loading`). Verifiable by unit tests (signed-in verified user, `roleLoaded: false`, path `/login` → `/loading`; path `/stores/x/dashboard` → `/loading`; `roleLoaded: true` → falls through to existing layers).
- [ ] R3: `VerifyEmailController.checkAndComplete` maps the CF `not-found` failure to a typed exception (e.g. `DraftNotFoundException extends AppException`) via an error mapper in the data layer (`onboarding_repository.dart`), per `ai_toolkit/architecture.md` Firebase error mapping. Verifiable by a controller unit test with a mocked repository throwing `FirebaseFunctionsException(code: 'not-found')`.
- [ ] R4: `VerifyEmailScreen` renders a dedicated recovery state when the controller error is `DraftNotFoundException`: localized explanation + primary button navigating to `BusinessRoute.createAccount`. Polling stops while in this state. The existing `ref.listen` error-dialog wiring must filter out `DraftNotFoundException` (e.g. `error is! DraftNotFoundException`) so the alert dialog does not pop over the recovery UI. Verifiable manually (QA scenario 2) and by widget test if added.
- [ ] R5: `EmailScreen` / `CreateAccountController.register` handles the already-signed-in case: if `currentUser != null`, skip `createUserWithEmailAndPassword` and call draft creation only. `EmailScreen` adapts its UI when the user is already signed in: pre-fill and disable the email field (from `currentUser.email`), hide the password field, hide the privacy-policy checkbox (already accepted during initial registration). The CTA label changes from "Continue" to a draft-submission label (e.g. `context.loc.submitDetails`). Verifiable by controller unit test with a fake signed-in auth repository.
- [ ] R6: `MerchantOnboardingService.register` rollback: on draft-creation failure after user creation, call new `AuthRepository.deleteAccount()`; if delete throws, fall back to `signOut()`; always rethrow the original error. Verifiable by service unit tests (delete succeeds → no current user; delete throws → signOut called; original exception propagates in both cases).
- [ ] R7: `AuthRepository` exposes `Future<void> deleteAccount()` calling `_auth.currentUser?.delete()` (accessing the underlying `FirebaseAuth` instance directly, matching the `signOut()` pattern at `auth_repository.dart:25`). Verifiable by existing fake-auth test infrastructure.
- [ ] R8: `StoreShipListX.pendingWelcome` returns only ships with `role == StoreRole.owner && !welcomeCompleted`. Verifiable by unit test on the extension (owner pending → returned; employee/operator pending → null).
- [ ] R9: `WelcomeScreen` guards content: if the resolved ship role is not `owner`, immediately mark welcome completed (or render nothing and let redirect proceed) instead of showing owner CTAs. Verifiable manually (QA scenario 4).
- [ ] R10: All redirect changes keep `businessRedirect` pure and synchronous (no `ref`, no async). Verifiable by signature review — function inputs remain `BusinessRedirectState` + `path`.

### Nice to Have
- [ ] N1: Exponential backoff for the verify-email polling interval (3s → 5s → 10s, capped), resetting on app resume.
- [ ] N2: `completeMerchantOnboarding` CF returns a structured error payload (`details.reason = 'draft-not-found'`) instead of relying on the generic `not-found` code, future-proofing the client mapping.

### Non-functional
- Performance: no additional Firestore reads in the redirect path; `roleLoaded` derives from the already-watched `userRoleProvider`.
- Accessibility: recovery-state button uses the standard `PrimaryWebButton` with default tap target.
- i18n: new ARB keys in `app_en.arb`, `app_ru.arb`, `app_kk.arb`: `draftExpiredTitle`, `draftExpiredMessage`, `fillDetailsAgain`, `submitDetails` (recovery EmailScreen CTA). Follow the ARB apostrophe rule (`ai_toolkit/code-style.md`).

## Technical Constraints

**Files to create:**
- None. All changes land in existing files (exception type may live in the existing exceptions location, see below).

**Files to modify:**
- `lib/src/routing/business_router.dart` — relax Layer 3 to allow inbound paths for verified guests; insert role-loading layer; update layer-numbering doc comment.
- `lib/src/routing/business_redirect_state.dart` — add `roleLoaded` field, derive from `roleAsync.hasValue || roleAsync.hasError`.
- `lib/src/features/store/domain/store_ship.dart` — owner filter in `pendingWelcome`.
- `lib/src/features/onboarding/data/onboarding_repository.dart` — map `FirebaseFunctionsException(code: 'not-found')` from `completeMerchantOnboarding` to `DraftNotFoundException`.
- `lib/src/exceptions/app_exception.dart` — add `DraftNotFoundException` to the existing sealed hierarchy (all `AppException` subtypes must be in this file because `AppException` is a Dart 3 `sealed class`).
- `lib/src/features/onboarding/presentation/inbound/verify_email_controller.dart` — surface the typed exception; expose state the screen can branch on; stop polling flag.
- `lib/src/features/onboarding/presentation/inbound/verify_email_screen.dart` — recovery UI state + navigation to create-account.
- `lib/src/features/onboarding/presentation/inbound/email_screen.dart` — adapt UI for signed-in recovery user (disable email, hide password + policy, change CTA label).
- `lib/src/features/onboarding/presentation/inbound/create_account_controller.dart` — already-signed-in branch (draft-only submission).
- `lib/src/features/onboarding/application/merchant_onboarding_service.dart` — delete-with-fallback rollback.
- `lib/src/features/auth/data/auth_repository.dart` — `deleteAccount()`.
- `lib/src/features/onboarding/presentation/welcome/welcome_screen.dart` — role guard.
- `lib/l10n/app_en.arb`, `app_ru.arb`, `app_kk.arb` — three new keys.
- `test/routing/business_redirect_test.dart` — new layer cases (reuse the existing `_redirect` helper).
- `test/features/onboarding/merchant_onboarding_service_test.dart` — rollback cases.
- `test/features/onboarding/verify_email_controller_test.dart` — not-found mapping case.
- `test/features/store/` — `pendingWelcome` extension tests (new file `store_ship_extension_test.dart` if no suitable existing file).

**Patterns to follow (with citations):**
- Follow the `storeShipsLoaded` flag pattern in `lib/src/routing/business_redirect_state.dart:14,23,50` for the new `roleLoaded` flag.
- Follow the layered, documented redirect structure in `lib/src/routing/business_router.dart:69-145`; keep the doc comment's layer list in sync.
- Follow the Firebase error mapping pattern from `ai_toolkit/architecture.md` → `FirebaseErrorMapper`; mapping lives in the data layer, not the controller.
- Reuse the `_redirect` test helper in `test/routing/business_redirect_test.dart:9-25`.
- Reuse `AsyncValue.guard` + `ref.listen` error-dialog wiring already present in `verify_email_screen.dart`.

**Anti-patterns / avoid:**
- Do not make the redirect async or read providers inside it beyond the existing single `ref.read(businessRedirectStateProvider)` (`ai_toolkit/architecture.md` redirect guards are sync).
- Do not interpret a *loading* role as `guest` anywhere in redirect logic — that conflation is the root cause of defect 3.
- Do not resurrect drafts server-side or extend TTL — recovery decision is client re-entry (maintainer-confirmed).
- Do not add new strings inline in Dart — ARB only (`ai_toolkit/architecture.md` Localization).
- Do not modify Firestore security rules, collection paths, or CF exports — none of these changes require it (CLAUDE.md hard rule).

**Data layer changes:** None. No schema, rules, or index changes. CF behavior unchanged (N2 optional).

**External integrations:** Firebase Auth `User.delete()` — may throw `requires-recent-login` only if called long after sign-in; in this flow it is called seconds after account creation, so the token is fresh. Fallback to `signOut()` covers residual failures.

## Edge Cases
(Covered above in User Flow → Edge cases. Cross-reference here if reviewer expects this section.)

## Out of Scope
- NOT persisting the in-memory store draft across process death (SharedPreferences mirror) — separate feature; current keepAlive provider behavior stands.
- NOT cleaning up the `StoreRole` enum (`employer` → `employee`, removing `owner`) — separate removal refactor per `ai_docs/REMOVAL_REFACTOR_PLANNING.md`; this spec only *reads* `StoreRole.owner`.
- NOT updating the stale Stripe payment flow description in `ai_docs/PROJECT.md` — separate documentation fix.
- NOT changing `createAdditionalStore` welcome behavior — intentional that owners see welcome for a new store.
- NOT adding polling backoff beyond N1 — deferred if N1 is skipped.

## Validation

**Automated tests:**
- Unit: `businessRedirect` — verified guest on each inbound path → null; on non-inbound paths → verify-email; `roleLoaded: false` cases → `/loading`; admin/partner layers unaffected (regression). File: `test/routing/business_redirect_test.dart`.
- Unit: `pendingWelcome` owner filter. File: `test/features/store/store_ship_extension_test.dart`.
- Unit: `MerchantOnboardingService.register` — rollback via delete; delete-failure fallback to signOut; error rethrown. File: `test/features/onboarding/merchant_onboarding_service_test.dart`.
- Unit: `VerifyEmailController` — `not-found` → `DraftNotFoundException` in state; polling-stop flag set. File: `test/features/onboarding/verify_email_controller_test.dart`.
- Unit: `CreateAccountController.register` with signed-in user → draft-only path. Same test file family.

**Manual QA scenarios:**
1. Given a fresh install, when completing the full happy-path registration, then the user lands on welcome → dashboard with no intermediate wrong screens.
2. Given a verified account whose draft was deleted (delete it manually in the emulator), when opening the app, then the verify-email screen shows the "session expired" state, the button leads to create-account, and re-submitting details completes onboarding without re-verification.
3. Given airplane mode enabled right after the email/password submit (draft CF fails), when the error appears, then the account no longer exists in the Auth emulator, and retrying registration with the same email succeeds.
4. Given a legacy employee storeShip with `welcomeCompleted: false` (create manually in the emulator), when the employee signs in, then they land on `/stores`, never on `/onboarding/welcome`.
5. Given a signed-in partner, when cold-starting the app, then only the loading screen is visible before the dashboard — no verify-email flash (verify with slow-network throttling).

**Expected behavior under edge conditions:**
- Offline → registration error dialog; account rolled back; no orphan in Auth.
- Backend error (non-`not-found`) on completeMerchantOnboarding → existing retry dialog; polling continues.
- Empty data (partner, zero ships) → `/stores` list, no welcome redirect.

## Definition of Done
- [ ] All Must Have requirements pass automated tests
- [ ] All Manual QA scenarios pass on target platforms
- [ ] No new lint warnings; matches `ai_toolkit/` style guide
- [ ] Reviewed against `ai_toolkit/` breaking-change notes
- [ ] Spec file linked in the PR description