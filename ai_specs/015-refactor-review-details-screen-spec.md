# Spec: Edit Store Draft Dialog on ReviewDetailsScreen

Created: 2026-06-27
Status: refined
Refined: 2026-06-27
Source request: ai_specs/015-refactor-review-details-screen.md

## Goal

Add an edit dialog to `ReviewDetailsScreen` so the user can modify all store draft fields (name, type, address, postal code, city, country, phone) without navigating back to `CreateAccountScreen`. After saving, the card and map preview update automatically, with geocoding re-triggered if address fields changed.

## Background

**Stack & conventions:** Flutter + Riverpod codegen (`@riverpod`), Freezed models, GoRouter navigation, feature-first structure. AlertDialog pattern with local `StatefulWidget` state for form controllers and `GlobalKey<FormState>` for validation (per `ai_toolkit/riverpod.md`, `ai_toolkit/code-style.md`). UI-only state (form fields, loading flag) stays local in widget state — no new provider needed.

**Project context:** The onboarding flow is a 4-step wizard: CreateAccountScreen → ReviewDetailsScreen → EmailScreen → VerifyEmailScreen. `CreateAccountScreen` uses `StoreFormContent` (a reusable `StatefulWidget` form) that collects 7 fields into a `StoreDraft` model. `ReviewDetailsScreen` displays the collected data in a card with a map preview and an edit button that currently calls `showNotImplementedAlertDialog`. The `StoreDraftController` (keepAlive) manages the draft across steps, and its `saveStepOne()` method automatically resets `location` to `null` when address fields change — enabling automatic geocoding re-trigger.

**Why now / why this approach:** The edit button placeholder already exists on `ReviewDetailsScreen` (lines 105–109). Implementing it as an AlertDialog avoids adding a new route and keeps the user in context. `StoreFormContent` can be reused inside the dialog with a small modification (see Technical Constraints).

## User Flow

### Happy path

1. User is on `ReviewDetailsScreen`, sees the store details card with map preview, name, type, address, phone.
2. User taps the "Edit" button on the card.
3. An `AlertDialog` opens with a scrollable form pre-filled with the current `StoreDraft` values (all 7 fields editable).
4. User modifies one or more fields, taps "Save".
5. Form validates. On success: `StoreDraftController.saveStepOne()` is called, dialog closes.
6. If address fields changed, `saveStepOne()` resets `location` to `null`, and `_geocodeIfNeeded()` (on `_ReviewDetailsContentState`) re-triggers geocoding — map preview shows loading, then updates.
7. If only non-address fields changed (name, phone, storeType), card text updates immediately, map stays unchanged.

### Alternative flows

- User taps "Cancel" or taps outside the dialog → dialog closes, no changes applied.
- User taps back button (Android) while dialog is open → dialog closes, no changes applied.

### Error & recovery flows

- Validation fails (empty required field, invalid phone) → inline error messages under fields, dialog stays open, user corrects and retries.
- Geocoding fails after save → `storeLocationProvider` emits `AsyncError`, existing `ref.listen` on `ReviewDetailsScreen` shows alert dialog. User can re-edit address or go back.

### Edge cases

- All fields unchanged → `saveStepOne()` is called (idempotent), `addressChanged` is `false`, location preserved, no geocoding re-trigger.
- User edits address, saves, then immediately taps Edit again before geocoding finishes → dialog opens with current draft (location is `null`), geocoding continues in background.
- Dialog on small screen → scrollable content prevents overflow.

## Requirements

### Must Have

- [ ] R1: Tapping "Edit" on `ReviewDetailsScreen` opens an `AlertDialog` with `StoreFormContent` inside a scrollable container. Verifiable by: tapping the edit button shows a dialog with all 7 form fields.
- [ ] R2: Form is pre-filled with the current `StoreDraft` values from `storeDraftControllerProvider`. Verifiable by: all fields match the data shown on the card behind the dialog.
- [ ] R3: "Save" validates all fields (same validators as `CreateAccountScreen`), calls `StoreDraftController.saveStepOne()`, and closes the dialog. Verifiable by: saving with valid data updates the card text; saving with invalid data shows inline errors.
- [ ] R4: "Cancel" closes the dialog without modifying the draft. Verifiable by: cancel → card data unchanged.
- [ ] R5: If address fields changed, geocoding re-triggers after dialog closes and the map preview updates. Verifiable by: change address → save → map shows loading → new location appears.
- [ ] R6: If only non-address fields changed, map/location is preserved. Verifiable by: change name → save → map stays the same.
- [ ] R7: Replace the existing `showNotImplementedAlertDialog` call with the new edit dialog. Verifiable by: no "not implemented" dialog shown anywhere.

### Nice to Have

- [ ] N1: Localize dialog title and button labels via `context.loc`. Verifiable by: switching locale shows translated strings.

### Non-functional

- Accessibility: dialog uses standard `AlertDialog` with `autofocus` on first field; form fields have labels.
- i18n: dialog title and button labels should use ARB keys (if new keys are needed, add to `app_en.arb`, `app_ru.arb`, `app_kk.arb`).

## Technical Constraints

**Files to create:**

- `lib/src/features/onboarding/presentation/inbound/edit_store_draft_dialog.dart` — `StatefulWidget` wrapping `AlertDialog` with `StoreFormContent` inside. ~60–80 lines.

**Files to modify:**

- `lib/src/features/onboarding/presentation/inbound/review_details_screen.dart` — Replace `showNotImplementedAlertDialog` (line 108) with `showDialog(child: EditStoreDraftDialog(...))`. After dialog closes with `true` result, call `_geocodeIfNeeded()` to re-trigger geocoding if address changed.
- `lib/src/features/store/presentation/store_form_content.dart` — Add a `showSubmitButton` parameter (default `true`) to optionally hide the built-in `PrimaryWebButton` (lines 264–267). This is needed because the dialog uses `AlertDialog.actions` for Cancel/Save buttons, and the form's own button would duplicate the Save action. Existing callers (`CreateAccountScreen`, `AddStoreScreen`) are unaffected since the default is `true`. Also expose form submission externally: either make `submit()` callable via a `GlobalKey` parameter or add an `onSubmitButtonBuilder` callback. Recommended approach: accept an optional `GlobalKey<StoreFormContentState>` so the dialog's Save action can call `formKey.currentState!.submit()`.

**Integration detail — how the dialog triggers validation:**

`StoreFormContent.submit()` (line 86) is currently on the private state class `_StoreFormContentState`. To allow the dialog's Save button to trigger validation externally, make the state class public (`StoreFormContentState`) and accept an optional `GlobalKey<StoreFormContentState>` as a parameter. The `onSubmit` callback pattern stays the same — on successful validation, it fires `onSubmit(draft)` which the dialog uses to call `saveStepOne()` and close with `Navigator.of(context).pop(true)`.

Note: `Navigator.of(context).pop()` is acceptable for dialogs — GoRouter's `context.pop()` delegates to `Navigator` for dialogs anyway, and the reference pattern `invite_member_dialog.dart` uses the same approach.

**Patterns to follow (with citations):**

- Follow the `AlertDialog` + `Form` + local state pattern from `lib/src/features/business_console/presentation/team/invite_member_dialog.dart` (lines 60–127) for dialog structure, Cancel/Save actions, and loading state.
- Reuse `StoreFormContent` from `lib/src/features/store/presentation/store_form_content.dart` as the dialog body with `showSubmitButton: false`. Pass current `StoreDraft` as `initialDraft`.
- The dialog's Save action calls `formKey.currentState!.submit()`. On success, the `onSubmit` callback destructures the `StoreDraft` and calls `StoreDraftController.saveStepOne()` (same pattern as `create_account_screen.dart:50–61`), then closes the dialog with `true`.
- Reuse `StoreDraftController.saveStepOne()` from `lib/src/features/onboarding/presentation/inbound/store_draft_controller.dart` for persisting changes (it already handles address-change detection and location reset).

**Anti-patterns / avoid:**

- Do not create a new controller or provider for the dialog — use existing `StoreDraftController`.
- Do not add a new route in `business_router.dart` — this is a simple dialog, not a route.
- Do not duplicate form fields or validation logic — reuse `StoreFormContent`.
- Do not manually manage geocoding logic in the dialog — let `saveStepOne()` reset location and let `_geocodeIfNeeded()` handle re-triggering.

**Data layer changes:** None. No schema, collection, or security rule changes.

**External integrations:** None new. Geocoding is already handled by `StoreLocationController`.

## Edge Cases

(Covered above in User Flow → Edge cases.)

## Out of Scope

- NOT adding a new GoRouter route — the edit UI is a dialog, not a screen.
- NOT creating a new Riverpod controller — `StoreDraftController` already handles all needed mutations.
- NOT changing `StoreDraft` model or its fields — all current fields are sufficient.
- NOT adding map pin editing (manual location adjustment) — only text-based address editing with automatic geocoding.
- NOT changing validation rules — same validators as `CreateAccountScreen` via `StoreFormContent`.
- NOT localizing existing `StoreFormContent` validator messages (currently hardcoded English) — tracked separately.

## Validation

**Automated tests:**

- Unit: verify `StoreDraftController.saveStepOne()` resets location when address changes and preserves it when only name/phone changes (file: `test/src/features/onboarding/presentation/inbound/store_draft_controller_test.dart` — may need to be created).
- Widget: verify `EditStoreDraftDialog` renders all form fields pre-filled, validates on submit, and returns `true` on save / `null` on cancel.

**Manual QA scenarios:**

1. Given ReviewDetailsScreen with filled card, when tap Edit → then dialog opens with all fields pre-filled matching the card.
2. Given dialog open, when change business name and tap Save → then dialog closes, card shows new name, map unchanged.
3. Given dialog open, when change street address and tap Save → then dialog closes, map shows loading, then new location.
4. Given dialog open, when leave required field empty and tap Save → then inline error shown, dialog stays open.
5. Given dialog open, when tap Cancel → then dialog closes, card unchanged.
6. Given dialog open, when tap outside dialog → then dialog closes, card unchanged.

**Expected behavior under edge conditions:**

- Geocoding fails after address edit → alert dialog shown on ReviewDetailsScreen (existing behavior via `ref.listen`).
- No fields changed → save is idempotent, no visual change.
- Small screen → dialog content scrolls.

## Definition of Done

- [ ] All Must Have requirements pass automated tests
- [ ] All Manual QA scenarios pass on target platforms (Android, iOS, Web)
- [ ] No new lint warnings; matches `ai_toolkit/` style guide
- [ ] `flutter analyze` passes with no new warnings
- [ ] Spec file linked in the PR description
