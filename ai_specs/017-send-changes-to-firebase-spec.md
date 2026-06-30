# Spec: Send All Changes to Firebase

Created: 2026-06-28
Status: refined
Refined: 2026-06-28
Source request: ai_specs/017-send-changes-to-firebase.md

## Goal

Fix the `deploy.yml` workflow to include Firestore indexes deployment, then merge the current branch (`feat/reviews-data-aggregation`, 28 commits ahead of `main`) into `main` via a single PR — triggering all CI/CD workflows to deploy accumulated changes (Cloud Functions, Firestore rules + indexes, Storage rules, web hosting) to Firebase production.

## Background

**Stack & conventions:** CI/CD uses GitHub Actions. Firebase deployment is split across two workflows: `deploy.yml` (functions, Firestore rules, storage) and `firebase-hosting-merge.yml` (Flutter web build → Firebase Hosting). Both trigger on push to `main`. Per `ai_toolkit/firebase.md`, every Firestore collection must have proper indexes and security rules deployed.

**Project context:** The project has two entry points — business web app deployed to Firebase Hosting, and mobile apps. Firebase Hosting serves `build/web` (business app by convention, per `ai_docs/EXTERNAL_SERVICES.md`). Cloud Functions are in `functions/src/` (TypeScript). The last deploy to Firebase was at commit `ce42117` (feat/routing phase 3). Since then, 28 commits added: reviews feature, onboarding refactor, security hardening, orders improvements, booking fix, dev-menu, and the CI/CD workflows themselves.

**Why now:** Firebase production is running stale code. The CI/CD pipeline was added in commit `38e1fb6` but never triggered because nothing has been merged to `main` since. All new features (reviews, hardened security rules, new Cloud Functions like `onReviewWritten`, `syncItemOffers` rename, rate limits on `reserveOffer`) are unreachable by users.

## User Flow

### Happy path

1. Developer fixes `deploy.yml` on current branch: `--only functions,firestore:rules,storage` → `--only functions,firestore,storage`.
2. Developer fixes CI `.env` / codegen issue (see R0 below).
3. Developer adds `build_runner` step to hosting workflows so `env.g.dart` is generated before `flutter build web`.
4. Developer runs `dart run build_runner build --delete-conflicting-outputs` locally and commits any changed `.g.dart` files (stale hashes from prior edits).
5. Developer commits all fixes.
6. Developer creates a single PR: `feat/reviews-data-aggregation` → `main`.
7. CI workflow (`ci.yml`) runs: Flutter analyze + test, Functions lint + build — all pass.
8. Firebase Hosting preview deploy (`firebase-hosting-pull-request.yml`) runs — preview URL posted as PR comment.
9. Developer merges the PR.
10. Three workflows trigger on push to `main`:
    - `deploy.yml` → deploys Cloud Functions, Firestore rules, Firestore indexes, Storage rules.
    - `firebase-hosting-merge.yml` → builds Flutter web, deploys to live hosting channel.
    - `ci.yml` → runs validation again (push trigger).
11. Firebase production is now up-to-date.

### Error & recovery flows

- If CI fails (analyze/test/lint): fix issues on the branch, push again, CI re-runs.
- If deploy workflow fails (auth error): verify `FIREBASE_SERVICE_ACCOUNT_SARQYT_1AB95` secret in GitHub repo settings → Actions secrets. Re-run the failed workflow from GitHub Actions UI.
- If Firestore index deployment fails (quota/conflict): check Firebase Console → Firestore → Indexes for conflicting indexes. Remove stale ones, re-run workflow.
- If hosting deploy fails (Flutter build error): check build logs, fix on a new branch, merge fix to `main`.

### Edge cases

- Merge conflicts with `main`: currently `main` has no divergent commits — fast-forward merge expected. If somehow diverged, resolve conflicts before merge.
- Partial deploy success: if `deploy.yml` succeeds but `firebase-hosting-merge.yml` fails (or vice versa), re-run the failed workflow independently from GitHub Actions UI. They are independent jobs.

## Requirements

### Must Have

- [ ] R0: CI and hosting workflows can generate `env.g.dart` during build. Problem: `lib/env.dart` uses `@Envied` which reads `.env` at codegen time, but `.env` is gitignored and `env.g.dart` was removed from tracking (commit `8807986`). Fix: add a CI step that creates a dummy `.env` with `STADIA_MAPS_API_KEY=placeholder` before `build_runner`, OR re-commit `env.g.dart` to version control (XOR obfuscation of a map tile key is not a real secret). This affects `ci.yml`, `firebase-hosting-merge.yml`, and `firebase-hosting-pull-request.yml`. Verifiable by: all three workflows complete the build/codegen step without errors.
- [ ] R0b: Hosting workflows (`firebase-hosting-merge.yml`, `firebase-hosting-pull-request.yml`) must add a `build_runner` step before `flutter build web`, since `env.g.dart` is not committed. Without this, compilation fails on `part 'env.g.dart'` in `lib/env.dart`. Verifiable by: workflow YAML includes `dart run build_runner build --delete-conflicting-outputs` before `flutter build web`.
- [ ] R0c: Commit regenerated `.g.dart` files. Working tree has stale codegen hashes in `store_location_controller.g.dart` and `business_router.g.dart`. Run `build_runner` and commit results before creating the PR. Verifiable by: `git status` shows no modified `.g.dart` files.
- [ ] R1: `deploy.yml` deploys Firestore indexes alongside rules. Verifiable by: `args` line reads `deploy --only functions,firestore,storage` (not `firestore:rules`).
- [ ] R2: All 28 commits from `feat/reviews-data-aggregation` are merged into `main` via a single PR. Verifiable by: PR is merged, `main` HEAD matches branch HEAD.
- [ ] R3: CI workflow passes before merge. Verifiable by: green check on PR for `analyze-and-test` and `functions-lint` jobs.
- [ ] R4: After merge, `deploy.yml` succeeds (functions + firestore rules + indexes + storage). Verifiable by: green workflow run in GitHub Actions.
- [ ] R5: After merge, `firebase-hosting-merge.yml` succeeds (web app deployed to live channel). Verifiable by: green workflow run + live site updated.

### Nice to Have

- [ ] N1: Add a `workflow_dispatch` trigger to `deploy.yml` for manual re-runs without needing a push to `main`. Verifiable by: "Run workflow" button appears in GitHub Actions UI.

### Non-functional

- Performance: deploy workflows should complete within 10 minutes (current function count: 19).
- Reliability: workflows are idempotent — re-running a deploy produces the same result.

## Technical Constraints

**Files to create:**
- None.

**Files to modify:**

- `.github/workflows/deploy.yml` (line 24) — change `args: deploy --only functions,firestore:rules,storage` to `args: deploy --only functions,firestore,storage`. This makes `firestore` deploy both rules AND indexes.
- `.github/workflows/ci.yml` — add a step before `build_runner` to create a dummy `.env` file: `echo 'STADIA_MAPS_API_KEY=ci-placeholder' > .env`. Without this, `envied` codegen fails because `.env` is gitignored and not available in CI.
- `.github/workflows/firebase-hosting-merge.yml` — add two steps before `flutter build web`: (1) create dummy `.env` (same as above), (2) run `dart run build_runner build --delete-conflicting-outputs` to generate `env.g.dart` and other codegen files.
- `.github/workflows/firebase-hosting-pull-request.yml` — same two steps as `firebase-hosting-merge.yml`.

**Note:** `firebase-hosting-merge.yml:19` runs `flutter build web` without `--target`. This works because `main.dart` is the business app (per `ai_docs/EXTERNAL_SERVICES.md`), but the coupling is implicit. Consider adding `--target lib/main.dart` for explicitness.

**Patterns to follow (with citations):**

- `firebase.json` already references both `firestore.rules` and `firestore.indexes.json` — the deploy command just needs to target `firestore` (not `firestore:rules`) to pick up both.

**Anti-patterns / avoid:**

- Do not run `firebase deploy` manually — let CI/CD handle it after merge.
- Do not split into multiple PRs — user confirmed single merge.
- Do not add `setGlobalOptions({ region: ... })` to Cloud Functions (per `ai_docs/EXTERNAL_SERVICES.md` — would break callable function URLs).

**Data layer changes:** None. All Firestore schema changes, security rules, and indexes already exist in the codebase — they just haven't been deployed.

**External integrations:** GitHub Actions → Firebase (via service account key stored as GitHub secret `FIREBASE_SERVICE_ACCOUNT_SARQYT_1AB95`). Already configured and verified by user.

## Out of Scope

- NOT adding new features or code changes beyond the `deploy.yml` fix — this is a deployment-only task.
- NOT setting up multi-site Firebase Hosting (client web app is mobile-only for now, per `ai_docs/EXTERNAL_SERVICES.md`).
- NOT doing a manual `firebase deploy` — waiting for CI/CD to handle it automatically.
- NOT changing Cloud Functions code, Firestore rules, or any application code — those changes are already committed.
- NOT adding environment-specific deploy targets (staging/production) — single environment for now.

## Validation

**Automated tests:**

- CI workflow (`ci.yml`) runs `flutter analyze`, `flutter test`, `npm run lint`, `npm run build` — all must pass on the PR.

**Manual QA scenarios:**

1. Given the PR is created, when CI completes, then all checks are green (analyze-and-test, functions-lint, hosting preview).
2. Given the PR is merged, when deploy workflows complete, then GitHub Actions shows green for both `deploy.yml` and `firebase-hosting-merge.yml`.
3. Given deploy succeeded, when visiting the Firebase Hosting URL, then the web app reflects the latest build (not the old version from `ce42117`).
4. Given deploy succeeded, when checking Firebase Console → Functions, then all 19 functions are listed including new ones (`onReviewWritten`, renamed `syncItemOffers`).
5. Given deploy succeeded, when checking Firebase Console → Firestore → Indexes, then composite indexes for `reviews`, `storeShips`, etc. are present and status is "Enabled".
6. Given deploy succeeded, when checking Firebase Console → Firestore → Rules, then rules include the hardened security rules (reviews auth, `avgRating`/`reviewCount` protection).

**Expected behavior under edge conditions:**

- Workflow failure → re-run from GitHub Actions UI, deploy is idempotent.
- Partial deploy (one workflow succeeds, other fails) → re-run only the failed workflow.
- Future pushes to `main` → same workflows trigger, deploying only the diff.

## Definition of Done

- [ ] CI and hosting workflows updated to handle `.env` / `env.g.dart` codegen (R0, R0b)
- [ ] Stale `.g.dart` files regenerated and committed (R0c)
- [ ] `deploy.yml` updated to deploy `firestore` (rules + indexes) instead of just `firestore:rules`
- [ ] PR created: `feat/reviews-data-aggregation` → `main`
- [ ] CI passes on the PR
- [ ] PR merged to `main`
- [ ] All deploy workflows complete successfully
- [ ] Firebase Hosting serves updated web app
- [ ] Firebase Functions list includes all 19 functions
- [ ] Firestore indexes are deployed and enabled
- [ ] Firestore security rules are updated
