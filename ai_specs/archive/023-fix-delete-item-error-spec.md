---
title: Fix delete item error
status: done
date: 2026-07-06
type: fix
---

# Spec: Fix delete item error

Source request: Fix deleteItem internal error and improve Cloud Functions error handling. Diagnosis: the deleteItem CF wraps all non-AppError exceptions as HttpsError("internal", "Unexpected server error") via toHttpsError(), hiding the real error. Additionally, the controller calls FirebaseFunctions.instance directly instead of through a repository. Scope: (1) Improve toHttpsError to surface original error messages, (2) move deleteItem call from controller to repository layer, (3) add proper error logging/diagnostics to the deleteItem function, (4) optionally add hasActiveOrders to the server-side before delete logic is robust.

## Goal

Surface real error messages when the `deleteItem` Cloud Function fails, and align the Dart-side delete flow with the project's repository-layer architecture. Currently any non-`AppError` exception (Firestore SDK error, missing index, transient failure) is swallowed into a generic "Unexpected server error" — making bugs impossible to diagnose without CF logs.

## Background

**Stack & conventions:** Repositories are the only layer that touches Firebase/APIs and must accept/return domain models (`architecture.md`). Controllers delegate to repositories via Riverpod providers; they never instantiate `FirebaseFunctions.instance` directly (`riverpod.md`). Errors are mapped to typed `AppException` / `AppError` at boundaries (`architecture.md` → Error Handling). Cloud Functions use `toHttpsError` to convert caught errors to `HttpsError` before rethrowing (`firebase.md`).

**Project context:**
- `functions/src/app/error.ts:14-24` — `toHttpsError` is the shared error mapper for all CFs. Its fallback at line 23 discards the original error: `new HttpsError("internal", "Unexpected server error")`.
- `functions/src/features/items/functions/delete-item.ts` — the `deleteItem` CF. Logic is correct; all explicit error paths throw `AppError`. But native Firestore SDK errors bypass `AppError` and hit the opaque fallback.
- `lib/src/features/items/presentation/item_screen/settings_content_controller.dart:68-78` — calls `FirebaseFunctions.instance.httpsCallable('deleteItem')` directly, violating the repository pattern.
- `lib/src/features/items/data/items_repository.dart` — existing repository. Already has a `deleteItem(StoreID, {required ItemID})` at line 84 that does a direct Firestore `doc.delete()`. This method must be replaced with the CF-calling version.
- `lib/src/features/orders/data/orders_repository.dart:51-60` — `hasActiveOrdersForItem` already lives in the correct layer.
- `lib/src/utils/async_value_ui.dart:37-43` — `humanReadableError` extracts `FirebaseFunctionsException.message`, so surfacing a real message in `toHttpsError` will automatically reach the user.

**Why now:** The "internal" error is actively blocking item deletion in production. Without the real error message, diagnosing the root cause requires manual CF log inspection.

## User Flow

### Happy path
1. Partner opens item settings screen.
2. Taps "Delete item" button.
3. Client queries `hasActiveOrdersForItem` (via `OrdersRepository`) — no active orders found.
4. Confirmation dialog appears.
5. Partner confirms → `ItemsRepository.deleteItem(storeId, itemId)` calls the `deleteItem` CF.
6. CF deletes item, batch-deletes offers, cleans up image.
7. Controller state transitions to `AsyncData(null)` → screen pops.

### Error & recovery flows
- **CF returns a known error** (e.g. `failed-precondition` from active orders race): user sees the CF's message ("Cannot delete: there are active reservations"). User can dismiss and retry later.
- **CF encounters an unexpected Firestore error** (e.g. missing index, transient failure): user sees the **actual** error message (e.g. "The query requires an index...") instead of "Something went wrong. Try again". User can report the message to support or retry.
- **Network failure**: `FirebaseFunctionsException` with code `unavailable` → user sees "Service unavailable. Try later" (existing mapping in `_functionsErrorMessage`).

### Edge cases
- **Item already deleted** (concurrent delete): CF returns `not-found` → user sees "Not found". Screen should still pop since the goal (item gone) is achieved.
- **Item has active orders** (race between client check and CF check): CF returns `failed-precondition` → user sees the message and can retry.

## Requirements

### Must Have
- [ ] R1: `toHttpsError` fallback includes the original error's message. When the caught error is not `AppError` or `HttpsError`, the returned `HttpsError` must contain the original `error.message` (or stringified error) — not a hardcoded generic string. Verifiable by: unit test passing a native `Error("index missing")` and asserting the message appears in the `HttpsError`.
- [ ] R2: Replace the existing direct-Firestore `deleteItem` in `ItemsRepository` with a CF-calling version. The method accepts `(StoreID storeId, ItemID itemId)` and calls `_functions.httpsCallable('deleteItem')`. Add `FirebaseFunctions` as a constructor parameter (use `FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion)` in the provider). Verifiable by: `settings_content_controller.dart` has no `FirebaseFunctions` import; `items_repository.dart`'s `deleteItem` calls `_functions.httpsCallable`.
- [ ] R3: `SettingsContentController.deleteItem` delegates to `ref.read(itemsRepositoryProvider).deleteItem(...)` using `AsyncValue.guard`. Verifiable by: controller method body contains only `ref.read` + repository call, no direct Firebase SDK usage.
- [ ] R4: Unit test for `toHttpsError` covering three cases: (a) `AppError` input → preserves code + message, (b) `HttpsError` input → returned as-is, (c) plain `Error` input → code is `"internal"`, message contains original error text. Verifiable by: `functions/src/app/error.test.ts` exists and passes.

### Nice to Have
- [ ] N1: Move the remaining direct `FirebaseFunctions.instance.httpsCallable(...)` calls in `invite_member_dialog.dart`, `add_store_screen.dart`, and `business_repository.dart` to their respective repositories. (Out of scope for this spec — noted for future cleanup.)

### Non-functional
- No performance impact — same number of network calls.
- No i18n changes — error messages come from the CF, not from ARB files.

## Technical Constraints

**Files to modify:**
- `functions/src/app/error.ts` — change fallback in `toHttpsError` to include `error.message`.
- `lib/src/features/items/data/items_repository.dart` — replace existing direct-Firestore `deleteItem` with CF-calling version; add `FirebaseFunctions` constructor parameter. Use `FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion)` in the provider (per `firebase.md`). Note: the constructor change from `ItemsRepository(FirebaseFirestore)` to `ItemsRepository(FirebaseFirestore, FirebaseFunctions)` affects the `itemsRepositoryProvider` and requires codegen re-run, but downstream consumers are unaffected since they access the repo via the provider.
- `lib/src/features/items/presentation/item_screen/settings_content_controller.dart` — replace direct CF call with repository call; remove `cloud_functions` import.
- `lib/src/features/items/data/items_repository.g.dart` — regenerated after adding `FirebaseFunctions` to provider.

**Files to create:**
- `functions/src/app/error.test.ts` — unit tests for `toHttpsError`.

**Patterns to follow (with citations):**
- Repository CF call pattern: `lib/src/features/offers/data/business_offer_repository.dart:27-33` — `_functions.httpsCallable("updateOfferQuantity")`.
- Repository provider with `FirebaseFunctions` injection: `lib/src/features/offers/data/business_offer_repository.dart:98-103` (note: this reference uses `FirebaseFunctions.instance` directly — the new code should use `FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion)` per `firebase.md`).
- Controller delegating to repository: `lib/src/features/items/presentation/item_screen/settings_content_controller.dart:22-31` (the existing `updateItem` method is the model).

**Anti-patterns / avoid:**
- Do not add a new dependency — `cloud_functions` is already available.
- Do not change the `deleteItem` CF's business logic or Firestore queries.
- Do not expose raw Firestore error details in production beyond the message string (no stack traces to client).

**Data layer changes:** None. No schema, index, or security rule changes.

**External integrations:** No new integrations. Existing `deleteItem` CF call is unchanged.

## Out of Scope
- NOT implementing a dedicated "delete individual offer" feature — that is spec 019.
- NOT changing the `deleteItem` CF's business logic (auth check, active orders guard, batch delete, image cleanup).
- NOT adding new Firestore indexes or security rules.
- NOT fixing the other direct `FirebaseFunctions.instance` calls outside the items feature (see N1).
- NOT adding retry logic or offline queue for the delete action.

## Validation

**Automated tests:**
- Unit (`functions/src/app/error.test.ts`): `toHttpsError` with `AppError`, `HttpsError`, plain `Error`, and non-Error object (e.g. string thrown).
- Unit (Dart): no new Dart tests required — the controller change is a mechanical delegation and existing `AsyncValue.guard` behavior is unchanged.

**Manual QA scenarios:**
1. Given an item with no active orders, when partner taps Delete and confirms, then item is deleted and screen pops. (Happy path — unchanged behavior.)
2. Given an item with active orders, when partner taps Delete, then "Cannot delete" dialog appears before confirmation. (Unchanged behavior.)
3. Given a CF that throws a non-AppError (simulate by temporarily adding `throw new Error("test native error")` before the try block), when partner taps Delete, then the error dialog shows a message containing "test native error" instead of "Something went wrong."

**Expected behavior under edge conditions:**
- Offline → `FirebaseFunctionsException` code `unavailable` → "Service unavailable. Try later" (existing mapping).
- Backend transient error → real error message surfaced via improved `toHttpsError`.
- Empty data (item already deleted) → CF returns `not-found` → "Not found" shown.

## Definition of Done
- [ ] All Must Have requirements (R1–R4) implemented
- [ ] `toHttpsError` unit tests pass (`npm test` in `functions/`). Note: no existing `.test.ts` files in `functions/src/` — verify vitest config works before writing tests
- [ ] `flutter analyze` passes with no new warnings
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds (codegen for updated provider)
- [ ] Manual QA scenario 1 (happy path deletion) passes
- [ ] No `FirebaseFunctions` import in `settings_content_controller.dart`
- [ ] Spec file linked in the PR description
