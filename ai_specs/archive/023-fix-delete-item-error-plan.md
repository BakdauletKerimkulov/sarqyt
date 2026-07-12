---
title: Fix delete item error
status: done
date: 2026-07-06
type: fix
---

# Plan: Fix delete item error

Source: `ai_specs/023-fix-delete-item-error-spec.md`

## Overview
Surface real error messages from the `deleteItem` Cloud Function by fixing the `toHttpsError` fallback, and align the Dart-side delete flow with the repository pattern by moving the CF call from the controller into `ItemsRepository`.

**Spec:** `ai_specs/023-fix-delete-item-error-spec.md`

## Context
- **Structure:** feature-first (`lib/src/features/{name}/{domain,data,application,presentation}`)
- **State management:** Riverpod codegen (`@riverpod`); controllers are `AsyncNotifier`, auto-dispose. Ref: `settings_content_controller.dart`
- **Reference implementations:**
  - CF-calling repository: `lib/src/features/offers/data/business_offer_repository.dart:11-13` (constructor with `FirebaseFunctions`)
  - Controller delegating to repo: `settings_content_controller.dart:22-31` (`updateItem` method)
- **Testing convention:** vitest for TS (`npm test` / `vitest run` in `functions/`); `flutter test` for Dart; structure mirrors `lib/` (`architecture.md` → Testing)
- **Lint + test command:** `flutter analyze` (Dart); `npm test` in `functions/` (TS)
- **Assumptions / Gaps:**
  - No `kCloudFunctionsRegion` constant exists — all current code uses `FirebaseFunctions.instance` directly. Creating the constant + migrating all providers is out of scope (spec N1). For consistency with existing code, this fix will also use `FirebaseFunctions.instance` for now. Spec says to use `instanceFor(region:)` per `firebase.md`, but doing so only for `ItemsRepository` while all other repos use `.instance` creates inconsistency. **Decision needed from user** or proceed with `.instance` to match existing patterns.
  - No existing `.test.ts` files under `functions/src/` — only `functions/test/firestore-rules.test.ts`. Vitest is installed (`vitest ^4.1.8`), scripts configured (`npm test` → `vitest run`). Need to verify vitest resolves `functions/src/**/*.test.ts` (no vitest config file found — vitest defaults should pick up `src/**/*.test.ts`).

## Plan

### Phase 1 — CF error fix + unit test (backend)
**Goal:** `toHttpsError` surfaces original error message for non-`AppError` exceptions. Prove with vitest tests.

- [x] TDD: `toHttpsError` with `AppError` → preserves code + message; with `HttpsError` → returned as-is; with plain `Error` → code `"internal"`, message contains original text; with non-Error (string) → code `"internal"`, message contains stringified value
- [x] `functions/src/app/error.test.ts` — create vitest tests for the four cases above
- [x] `functions/src/app/error.ts:23` — change fallback to include original error message: `new HttpsError("internal", error instanceof Error ? error.message : String(error))`
- [x] Verify: `cd functions && npm test`

### Phase 2 — Dart repository + controller refactor
**Goal:** `deleteItem` CF call moves to `ItemsRepository`; controller delegates to repo; no `FirebaseFunctions` import in controller.

- [x] `lib/src/features/items/data/items_repository.dart` — add `FirebaseFunctions _functions` as second constructor parameter; replace `deleteItem` body with `_functions.httpsCallable('deleteItem').call({'storeId': storeId, 'itemId': id})`
- [x] `lib/src/features/items/data/items_repository.dart` — update `itemsRepositoryProvider` to pass `FirebaseFunctions.instance` as second argument
- [x] `dart run build_runner build --delete-conflicting-outputs` — regenerate `items_repository.g.dart`
- [x] `lib/src/features/items/presentation/item_screen/settings_content_controller.dart` — replace `deleteItem` body with `ref.read(itemsRepositoryProvider).deleteItem(storeId, itemId: itemId)`; remove `cloud_functions` import
- [x] Verify: `flutter analyze`

## Data layer changes
_None._

## External integrations
_None._

## Risks
- Vitest may not auto-discover `src/**/*.test.ts` without explicit config — verify in Phase 1; add `vitest.config.ts` if needed.
- Surfacing raw error messages to the client could leak internal details (e.g. Firestore index URLs). Mitigation: the error message is a string, no stack traces; Firestore index errors are diagnostic, not secret. Acceptable per spec.

## Out of scope
- NOT changing the `deleteItem` CF's business logic (auth check, active orders guard, batch delete, image cleanup).
- NOT adding new Firestore indexes or security rules.
- NOT fixing other direct `FirebaseFunctions.instance` calls outside the items feature (spec N1).
- NOT adding retry logic or offline queue for the delete action.
- NOT implementing a "delete individual offer" feature (spec 019).
- NOT creating `kCloudFunctionsRegion` constant or migrating all repos to `instanceFor(region:)`.
