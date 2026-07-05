---
title: Send Changes To Firebase
status: done
date: 2026-06-28
type: feature
---

# Plan: Send All Changes to Firebase

Source: `ai_specs/017-send-changes-to-firebase-spec.md`

## Overview
Fix CI/CD workflow files so they handle `.env`/codegen properly, fix `deploy.yml` to deploy Firestore indexes, regenerate stale `.g.dart` files, then create a PR to merge `feat/reviews-data-aggregation` → `main`.

**Spec:** `ai_specs/017-send-changes-to-firebase-spec.md`

## Context
- **Structure:** feature-first (`lib/src/features/*/`)
- **State management:** Riverpod codegen (`@riverpod`) — e.g. `lib/src/features/map/application/store_location_controller.dart`
- **Reference implementations:** existing CI workflows in `.github/workflows/ci.yml`, `deploy.yml`
- **Testing convention:** `flutter test`, mock repos for controller tests — `ai_toolkit/architecture.md` § Testing
- **Lint + test command:** `flutter analyze && flutter test` (Flutter), `npm run lint && npm run build` (Functions)
- **Assumptions / Gaps:** none — spec is detailed and refined

## Plan

### Phase 1 — Fix CI workflow (`.env` + codegen)
**Goal:** CI can generate `env.g.dart` from a dummy `.env` so `build_runner` and `flutter analyze/test` pass.

- [x] `.github/workflows/ci.yml` — add step before `build_runner`: `echo 'STADIA_MAPS_API_KEY=ci-placeholder' > .env`
- [x] Verify locally: confirm `ci.yml` YAML is valid (manual review of indentation)
- [x] Verify: `flutter analyze`

### Phase 2 — Fix hosting workflows (`.env` + `build_runner`)
**Goal:** Both hosting workflows generate codegen files before `flutter build web`.

- [x] `.github/workflows/firebase-hosting-merge.yml` — add two steps before `flutter build web`: (1) create dummy `.env`, (2) `dart run build_runner build --delete-conflicting-outputs`
- [x] `.github/workflows/firebase-hosting-pull-request.yml` — same two steps as above
- [x] Verify: `flutter analyze`

### Phase 3 — Fix deploy.yml (Firestore indexes + optional workflow_dispatch)
**Goal:** `deploy.yml` deploys Firestore rules AND indexes, and supports manual re-runs.

- [x] `.github/workflows/deploy.yml` line 24 — change `deploy --only functions,firestore:rules,storage` → `deploy --only functions,firestore,storage`
- [x] `.github/workflows/deploy.yml` — add `workflow_dispatch:` trigger (N1 nice-to-have)
- [x] Verify: `flutter analyze`

### Phase 4 — Regenerate stale `.g.dart` files + create PR
**Goal:** Commit all fixes and codegen, create PR `feat/reviews-data-aggregation` → `main`.

- [x] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate stale `store_location_controller.g.dart` and `business_router.g.dart`
- [x] Verify: `flutter analyze && flutter test`
- [x] Commit all changes (workflow fixes + regenerated `.g.dart` files)
- [x] Create PR: `feat/reviews-data-aggregation` → `main` via `gh pr create` (PR #3 already existed, pushed latest commit)

## Data layer changes
_None._ All Firestore schema, rules, indexes already committed — just need deployment.

## External integrations
- GitHub Actions → Firebase via `FIREBASE_SERVICE_ACCOUNT_SARQYT_1AB95` secret (already configured)
- `envied` package reads `.env` at codegen time — CI needs a dummy `.env` since real file is gitignored

## Risks
- `env.g.dart` with placeholder key means web hosting deploy will have a non-functional Stadia Maps key — acceptable since map tiles are not critical for business web app (mobile-only feature per `ai_docs/EXTERNAL_SERVICES.md`)
- Merge to `main` triggers 3 workflows simultaneously; if one fails, re-run independently (idempotent)

## Out of scope
- NOT adding new features or code changes beyond workflow fixes
- NOT setting up multi-site Firebase Hosting
- NOT doing manual `firebase deploy`
- NOT changing Cloud Functions, Firestore rules, or application code
- NOT adding environment-specific deploy targets (staging/production)
