# Plan: Refactor Create Item Form UX

Source: `ai_specs/018-refactor-create-offer-flow-spec.md`
Created: 2026-07-05
Status: draft

## Overview
Fix 4 UX issues in the create item form: ensure placeholder hints are visually distinct from filled values (R1–R2), replace the Material time-picker dial with inline HH:MM text fields (R3–R5), add the allergen field to the create form (R6–R7), and navigate back to dashboard on success with snackbar (R8–R9). The file exceeds 300 lines — extract schedule section into its own widget.

**Spec:** `ai_specs/018-refactor-create-offer-flow-spec.md`

## Context
- **Structure:** feature-first — `lib/src/features/items/{domain,data,application,presentation}`
- **State management:** Riverpod codegen — e.g. `CreateItemFormController` at `lib/src/features/items/presentation/item_create/create_item_form_controller.dart`
- **Reference implementations:** allergen field on edit screen — `item_instructions_settings_section.dart:213-242`; `ScheduleDayRow` at `presentation/common/schedule_day_row.dart`
- **Testing convention:** mirrors `lib/` in `test/src/`; group-based; no existing item tests
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:**
  - Dashboard uses `context.goNamed` to navigate to create item — must change to `pushNamed` so `context.pop(true)` returns a result. The router has `new-item` as a child of the dashboard route, so push/pop should work.
  - `WeeklySchedule.validationError` returns only the first error string. For per-day inline errors (R5), need a new method returning `Map<int, String?>` (per-day errors).
  - Description field (`_descCtl`) is already empty but uses `TextField` (not `TextFormField`). The `hintText` value `loc.rescueSurpriseBag` ("Rescue a surprise bag...") may look like pre-filled content — the spec wants a shorter placeholder like "Describe your product". Unclear if the hint text is the issue or the style. Will add a dedicated `descriptionHint` ARB key.
  - Price field hint is `'1500'` — already looks like a placeholder. Spec says "grey hintText" which is default behavior. Confirm no styling override makes it dark.

## Plan

### Phase 1 — Thin vertical slice: inline time fields + schedule extraction
**Goal:** Replace time picker dial with inline HH:MM text fields and extract the schedule section to bring `create_item_screen.dart` under 300 lines.

- [x] `lib/src/features/items/domain/weekly_schedule.dart` — add `Map<int, String?> get dayErrors` method on `WeeklySchedule` returning per-day `validationError` entries (keep existing `validationError` for backward compat)
- [x] `lib/src/features/items/presentation/common/schedule_day_row.dart` — replace `TextButton` time displays with 4 inline `TextFormField` widgets (startHour, startMinute, endHour, endMinute). Use `FilteringTextInputFormatter.digitsOnly`, `SizedBox` width constraints, semantic labels. Change callbacks from `VoidCallback? onPickStart/onPickEnd` to `ValueChanged<int>` for `onStartHourChanged`, `onStartMinuteChanged`, `onEndHourChanged`, `onEndMinuteChanged`. Add field-level validation (hour 0–23, minute 0–59).
- [x] `lib/src/features/items/presentation/common/weekly_schedule_editor.dart` — update callback signatures to match new `ScheduleDayRow` API. Add `Map<int, String?>? dayErrors` parameter, forward `dayErrors?[day]` as `errorText` to each `ScheduleDayRow`.
- [x] `lib/src/features/items/presentation/item_create/schedule_form_section.dart` — **new file**: extracted widget from `_buildScheduleSection`. Contains schedule label, description text, `WeeklyScheduleEditor`, manages `TextEditingController`s for time fields via parent callbacks. Receives `Map<int, DaySchedule>` + `dayErrors` + `enabled` + change callbacks.
- [x] `lib/src/features/items/presentation/item_create/create_item_screen.dart` — remove `_buildScheduleSection` method, replace with `ScheduleFormSection` widget. Wire new time-value callbacks (update `_schedule` map with hour/minute ints). In `_validateExtras()`, compute `WeeklySchedule(_schedule).dayErrors` and pass to `ScheduleFormSection` via `setState`. Remove `showTimePicker` imports.
- [x] Verify: `flutter analyze`

### Phase 2 — Allergen field + data layer
**Goal:** Add storing-and-allergens field to create form and wire it through to Firestore.

- [ ] `lib/src/features/items/data/items_repository.dart` — add `String? storingAndAllergens` parameter to `createItem()`. Include `'storingAndAllergens': storingAndAllergens` in the Firestore document map when non-null.
- [ ] `lib/src/features/items/presentation/item_create/create_item_form_controller.dart` — add `String? storingAndAllergens` parameter to `submit()`, forward to `ItemsRepository.createItem()`.
- [ ] `lib/src/features/items/presentation/item_create/create_item_screen.dart` — add `_storingAndAllergensCtl` TextEditingController. Add allergen text field after schedule section (multi-line, 3 lines, optional, with label and hint). Pass value through `_submit()`. Dispose controller.
- [ ] `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_kk.arb` — add keys: `storingAndAllergensLabel`, `storingAndAllergensHint`, `storingAndAllergensDescription`, `descriptionHint`.
- [ ] Verify: `flutter analyze`

### Phase 3 — Navigation: pop with result + dashboard snackbar
**Goal:** After successful creation, pop back to dashboard and show success snackbar there.

- [ ] `lib/src/features/business_console/presentation/dashboard_screen.dart` — change `context.goNamed(BusinessRoute.newItem.name, ...)` to `context.pushNamed(...)`. Await the push result; if `true`, show `itemCreated` snackbar. Convert to `ConsumerStatefulWidget` if needed for async navigation, or use a helper method.
- [ ] `lib/src/features/items/presentation/item_create/create_item_screen.dart` — in `_submit()`, after successful submit, replace snackbar with `context.pop(true)`. Remove the local snackbar code.
- [ ] `lib/src/features/onboarding/presentation/welcome/welcome_screen.dart` — review `CreateItemFormScreen` usage in bottom sheet. This is a modal — `pop(true)` should work. Verify no changes needed (bottom sheet already pops on close).
- [ ] Verify: `flutter analyze && flutter test`

### Phase 4 — Placeholder hints (R1, R2) + localization
**Goal:** Ensure description and price fields have clearly grey, non-prefilled appearance.

- [ ] `lib/src/features/items/presentation/item_create/create_item_screen.dart` — update description field hint to use `context.loc.descriptionHint` (short placeholder). Verify `hintStyle` is grey (Flutter default). Verify price field hint `'1500'` renders as grey text (confirm `_inputDeco` doesn't override `hintStyle`).
- [ ] `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_kk.arb` — add/update localized `descriptionHint` values if not added in Phase 2.
- [ ] Verify: `flutter analyze`

## Data layer changes
- `ItemsRepository.createItem()` gains optional `String? storingAndAllergens` parameter → included in Firestore doc when non-null. Backward-compatible — field already exists in `Item` domain model and `Item.fromJson()`.

## External integrations
_None._

## Risks
- `ScheduleDayRow` and `WeeklyScheduleEditor` are shared widgets — spec confirms they're only used in the create form, so API changes are safe. Verify with grep before modifying.
- `DashboardScreen` is a `ConsumerWidget` — changing to async `pushNamed` + awaiting result may require converting to `ConsumerStatefulWidget` or using a helper method.
- Welcome screen uses `CreateItemFormScreen` in a bottom sheet — `pop(true)` should work but needs verification.

## Out of scope
- NOT adding a structured allergen checklist (checkboxes for nuts, gluten, etc.) — free-text only.
- NOT changing the item edit screen.
- NOT adding unsaved-changes confirmation dialog.
- NOT changing the `Item` domain model or Freezed/codegen.
- NOT adding quantity-per-day editing to the create form.
- NOT changing Firestore security rules or indexes.
