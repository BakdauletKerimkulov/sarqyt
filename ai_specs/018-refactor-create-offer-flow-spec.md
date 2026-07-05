# Spec: Refactor Create Item Form UX

Created: 2026-07-04
Status: refined
Refined: 2026-07-04
Source request: ai_specs/018-refactor-create-offer-flow.md

## Goal
Improve the business-facing "Create Item" form to eliminate confusing UX patterns reported by a prospective partner: misleading prefilled-looking fields, a hard-to-use time picker, missing allergen info during creation, and the form staying populated after successful submission (risking duplicate items).

## Background
**Stack & conventions:** Flutter + Riverpod codegen, feature-first structure with domain/data/application/presentation layers (`ai_toolkit/architecture.md`). Local UI state (controllers, form keys) stays in widget state (`ai_toolkit/riverpod.md` — ephemeral state). All user-visible strings go through ARB localization (`ai_toolkit/code-style.md`). No new packages unless the toolkit already includes them; Flutter Material built-ins are preferred. Extracted widget classes only, no `Widget _buildX()` methods (`ai_toolkit/code-style.md`).

**Project context:** The create item form lives at `lib/src/features/items/presentation/item_create/create_item_screen.dart` (382 lines). It uses `CreateItemFormController` (Riverpod AsyncNotifier) at `lib/src/features/items/presentation/item_create/create_item_form_controller.dart` and `ItemsRepository.createItem()` at `lib/src/features/items/data/items_repository.dart:44-67`. The domain model `Item` at `lib/src/features/items/domain/item.dart` already has a `storingAndAllergens` field (line 45, `String?`), but it is only editable on the item edit screen (`item_instructions_settings_section.dart`), not during creation. The time schedule uses `showTimePicker()` (Material dial), and time rows are rendered by `ScheduleDayRow` at `lib/src/features/items/presentation/common/schedule_day_row.dart`.

**Why now:** A prospective partner tested the flow and flagged 4 concrete issues that hurt usability and could cause duplicate item creation. These are low-effort, high-impact UX fixes.

## User Flow

### Happy path
1. Partner taps "+ Create new" on store dashboard → navigates to create item form.
2. Form opens with **empty** description and price fields (clear placeholder text in grey, not dark text that looks filled in).
3. Partner fills in name, description, price, optionally estimated value and image.
4. Partner scrolls to weekly schedule. Each enabled day shows **two pairs of inline text fields** (HH : MM) for start and end time — no pop-up dial.
5. Partner optionally fills in the "Storing and allergens" free-text field below the schedule section.
6. Partner taps "Create" → loading state on button → success → app navigates back to store dashboard.
7. Dashboard shows the newly created item in the items list.

### Alternative flows
- If partner taps back before submitting, form is discarded (no unsaved-changes dialog — current behavior, unchanged).
- If partner submits with validation errors, errors appear inline next to the relevant fields. Form stays open for correction.

### Error & recovery flows
- If image upload fails: error dialog via `showAlertDialogOnError`. Form stays open with all data intact for retry.
- If Firestore write fails after image upload: uploaded image is cleaned up (best-effort, existing behavior). Error dialog shown. Form stays open.
- If network is unavailable: Firestore SDK throws; error surfaces via AsyncValue error → dialog.

### Edge cases
- Empty description: valid (description is optional).
- Empty allergen field: valid (field is optional).
- All days disabled: blocked by validation ("Enable at least one day").
- Invalid time range (start >= end): blocked by `DaySchedule.validationError`.
- Time window > 120 minutes: blocked by `DaySchedule.validationError`.
- Non-numeric input in time fields: blocked by `FilteringTextInputFormatter.digitsOnly` + range validation.
- Hour > 23 or minute > 59: blocked by field-level validation.

## Requirements

### Must Have
- [ ] R1: Description field (`_descCtl`) is empty by default with a grey `hintText` placeholder (e.g. `loc.descriptionHint` — "Describe your product"). Verifiable by: opening the create form and confirming the field is empty with grey hint text.
- [ ] R2: Price field (`_priceCtl`) is empty by default with a grey `hintText` placeholder (e.g. "1500"). Verifiable by: opening the create form and confirming the field is empty with grey hint text and ₸ suffix.
- [ ] R3: Replace `showTimePicker()` in `ScheduleDayRow` with inline text fields: two `SizedBox`-constrained `TextFormField` widgets per time (hour field, `:` separator, minute field), totalling 4 fields per day row (start HH, start MM, end HH, end MM). Verifiable by: opening the form, seeing inline HH:MM fields instead of TextButton time labels.
- [ ] R4: Inline time fields accept only digits, constrain hour to 0–23 and minute to 0–59. Invalid values show validation error below the row. Verifiable by: entering "25" in an hour field → validation error appears.
- [ ] R5: Wire up `DaySchedule.validationError` (start < end, max 120min) to the create form's validation flow. On submit, check `WeeklySchedule(_schedule).validationError` in `_validateExtras()`. Forward per-day errors through `WeeklyScheduleEditor` → `ScheduleDayRow.errorText` so they appear inline below each row. Verifiable by: setting start=19:00, end=18:00 → error shown below that day's row.
- [ ] R6: Add a "Storing and allergens" free-text field to the create form, placed after the schedule section and before the submit button. Uses the existing `storingAndAllergens` domain field. Multi-line (3 lines), optional, with hint text matching the edit screen (e.g. "e.g. Store in fridge, may contain nuts"). Verifiable by: opening create form, scrolling past schedule, seeing the allergen field.
- [ ] R7: Pass `storingAndAllergens` value through `CreateItemFormController.submit()` → `ItemsRepository.createItem()` → Firestore document. Verifiable by: creating an item with allergen text, then checking the Firestore document contains the `storingAndAllergens` field.
- [ ] R8: After successful item creation, navigate back to the store dashboard via `context.pop(true)` (pop with a `true` result). The dashboard screen should listen for the pop result and show the success snackbar. Remove the current behavior of staying on the form. Verifiable by: creating an item → app is on the dashboard screen, not the create form.
- [ ] R9: Move the success snackbar ("Item created") to the dashboard screen. The dashboard should check the pop result from the create form route; if `true`, show the snackbar. Verifiable by: creating an item → snackbar appears on the dashboard.

### Nice to Have
- [ ] N1: Add a localized label/section header for the allergen field (e.g. "Storing and allergens") consistent with the edit screen's `ItemInstructionsSettingsSection`.
- [ ] N2: Add a helper description text below the label (matching edit screen: "You can add recommendations for storing and handling food...").

### Non-functional
- Performance: no impact — form is a simple single-screen widget.
- Accessibility: inline time fields should have semantic labels (e.g. "Start hour", "Start minute") for screen readers.
- i18n: new strings needed — allergen field label, allergen hint text, allergen description text, description placeholder hint. Add to `app_en.arb`, `app_ru.arb`, `app_kk.arb`.

## Technical Constraints

**Files to modify:**
- `lib/src/features/items/presentation/item_create/create_item_screen.dart` — Remove prefilled description/price hints looking like values (R1, R2). Add `_storingAndAllergensCtl` TextEditingController. Add allergen field to form (R6). Change post-submit to `context.pop(true)` (R8), remove snackbar from this screen (R9). Extract `_buildScheduleSection` into a separate widget file (e.g. `schedule_form_section.dart`) — the file is already 382 lines, exceeding the 300-line max (`code-style.md`). Adding the allergen field would make it worse; extraction is required, not optional. Wire up `WeeklySchedule.validationError` per-day errors in `_validateExtras()` and pass them to the extracted schedule widget (R5).
- `lib/src/features/items/presentation/common/schedule_day_row.dart` — Replace `TextButton` time displays with inline `TextFormField` pairs for HH:MM (R3). Add validation for hour/minute ranges (R4). Change callbacks from `VoidCallback? onPickStart/onPickEnd` to value-changed callbacks that receive hour/minute ints.
- `lib/src/features/items/presentation/common/weekly_schedule_editor.dart` — Update callback signatures to match new `ScheduleDayRow` API (pass hour/minute values instead of triggering time picker). Add `Map<int, String?>? dayErrors` parameter and forward `dayErrors?[day]` as `errorText` to each `ScheduleDayRow` (R5).
- `lib/src/features/items/presentation/item_create/create_item_form_controller.dart` — Add `storingAndAllergens` parameter to `submit()` method (R7).
- `lib/src/features/items/data/items_repository.dart` — Add `String? storingAndAllergens` parameter to `createItem()` and include it in the Firestore document map (R7).
- `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_kk.arb` — Add new localization keys for allergen label, hint, description, and description field placeholder.

**Patterns to follow (with citations):**
- Follow the allergen field pattern from the edit screen at `lib/src/features/items/presentation/item_screen/item_instructions_settings_section.dart:213-242` for label text, hint text, and field layout.
- Follow the existing `_inputDeco()` helper in `create_item_screen.dart:345-363` for consistent field styling.
- Follow `ScheduleDayRow` at `schedule_day_row.dart` for the row layout pattern — keep the day name + switch on the left, replace time buttons on the right with inline fields.

**Files to create:**
- `lib/src/features/items/presentation/item_create/schedule_form_section.dart` — Extracted widget for the weekly schedule section, containing the schedule label, description, and `WeeklyScheduleEditor` with per-day error forwarding.

**Additional files to modify:**
- The **dashboard screen** that navigates to create item — listen for the `context.pop(true)` result and show the success snackbar (R9). Identify the exact file during planning.

**Anti-patterns / avoid:**
- Do not add a new package for time picking — use plain `TextFormField` with `FilteringTextInputFormatter.digitsOnly`.
- `ScheduleDayRow` and `WeeklyScheduleEditor` are only used in the create form (not the edit screen) — API changes are safe.
- Do not change the `Item` domain model — `storingAndAllergens` field already exists.
- Do not change Firestore security rules — the existing rules allow store owners to create items.

**Data layer changes:**
- `ItemsRepository.createItem()` gains an optional `storingAndAllergens` parameter. The Firestore document gets a new optional field `storingAndAllergens` on creation (currently only set on edit). This is backward-compatible — the field is already in the domain model and handled by `Item.fromJson()`.

**External integrations:** None.

## Out of Scope
- NOT adding a structured allergen checklist (checkboxes for nuts, gluten, etc.) — staying with free-text field per user decision. Could be a future enhancement.
- NOT changing the item edit screen — it already has the allergen field and works correctly.
- NOT adding an unsaved-changes confirmation dialog — current behavior (silent discard on back) is unchanged.
- NOT changing the domain model `Item` or its Freezed/codegen — field already exists.
- NOT adding quantity-per-day editing to the create form — out of scope for this spec.
- NOT changing Firestore security rules or indexes.

## Validation

**Automated tests:**
- Unit: `create_item_validators.dart` — existing tests (if any) still pass. No new validator logic needed beyond time field range checks.
- Unit: `DaySchedule.validationError` — existing tests still pass. Add test verifying `_validateExtras()` returns schedule validation errors.
- Unit: `ItemsRepository.createItem()` — verify `storingAndAllergens` is included in the Firestore write when provided, and omitted when null.

**Manual QA scenarios:**
1. Given a clean create form, when opened, then description and price fields are empty with grey hint text (not dark text).
2. Given the create form, when looking at an enabled day's schedule row, then four inline text fields (start HH, start MM, end HH, end MM) are visible instead of time picker buttons.
3. Given an enabled day, when entering hour "25", then a validation error appears below the row.
4. Given an enabled day, when entering start 19:00 and end 18:00, then a validation error "Start time must be before end time" appears.
5. Given the create form, when scrolling past the schedule, then a "Storing and allergens" text field is visible with hint text.
6. Given all fields filled including allergens, when tapping "Create", then item is created in Firestore with `storingAndAllergens` field, and the app navigates to the dashboard with a success snackbar.
7. Given a successful creation, when on the dashboard, then the newly created item appears in the items list.
8. Given a failed creation (e.g. network error), when error dialog is dismissed, then the form is still open with all data intact for retry.

**Expected behavior under edge conditions:**
- Offline → Firestore throws, error dialog shown, form data preserved.
- Backend error → error dialog via AsyncValue, form data preserved.
- Empty allergen field → item created without `storingAndAllergens` in Firestore (or with null).
- Double-tap submit → button is disabled during loading (existing `isLoading` guard).

## Definition of Done
- [ ] All Must Have requirements (R1–R9) implemented and pass manual QA
- [ ] All Manual QA scenarios (1–8) pass on Android and iOS
- [ ] No new lint warnings; `flutter analyze` passes
- [ ] ARB files updated for all 3 locales (en, ru, kk)
- [ ] Existing schedule validation logic (`DaySchedule.validationError`) works with new inline fields
- [ ] Spec file linked in the PR description
