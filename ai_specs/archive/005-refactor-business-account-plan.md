---
title: Refactor Business Account
status: done
date: 2026-05-23
type: refactor
---

# Plan: Remove one-time mode from Item

Source: ai_specs/005-refactor-business-account-spec.md

## Overview

Strip the `ItemType` enum and all `oneTime*` fields from the Dart and TypeScript domain models, simplify the daily sync cron to a single scheduled-item code path, remove the type toggle and one-time UI from the create-item form, and clean up navigation/routing that passes the `type` query param. Flash offers remain untouched — they use the independent `createOneTimeOffer` callable.

## Stages

### Stage 1: Domain model cleanup (Dart + TypeScript)

**Goal:** Remove `ItemType` enum and all `oneTime*` fields from the domain layer so downstream code is forced to update.

**Files to create/modify:**
- `lib/src/features/items/domain/item.dart` — delete `ItemType` enum, `type` field, all `oneTime*` fields
- `functions/src/features/offers/types/item-doc.ts` — delete `type` and `oneTime*` fields from `ItemDoc` interface

**Steps:**
- [x] Delete `enum ItemType { scheduled, oneTime }` from `item.dart`
- [x] Remove `type` field (line 47) from `Item` freezed class
- [x] Remove all `oneTime*` fields (lines 49–54) from `Item` freezed class
- [x] Remove `type` and `oneTime*` fields from `ItemDoc` in `item-doc.ts`

**Verification:** `dart run build_runner build --delete-conflicting-outputs` regenerates `.freezed.dart` and `.g.dart` without errors. `npm run build` in `functions/` passes.

---

### Stage 2: Data layer cleanup (repository + controller)

**Goal:** Remove `oneTime*` params from `createItem()` in the repository and the form controller.

**Files to create/modify:**
- `lib/src/features/items/data/items_repository.dart` — remove `type`, `oneTime*` params and their Firestore writes
- `lib/src/features/items/presentation/item_create/create_item_form_controller.dart` — remove `type`, `oneTime*` params from `submit()`

**Steps:**
- [x] In `items_repository.dart`: remove `type`, `oneTimeDate`, `oneTimeStartHour`, `oneTimeStartMinute`, `oneTimeEndHour`, `oneTimeEndMinute`, `oneTimeQuantity` params from `createItem()` signature
- [x] Remove the `'type': type` unconditional write and all conditional `oneTime*` writes from the Firestore `set()` map
- [x] In `create_item_form_controller.dart`: remove `type` and all `oneTime*` params from `submit()` signature and the `createItem()` call

**Verification:** `flutter analyze` passes. No compile errors in data/presentation layers.

---

### Stage 3: Presentation cleanup (create item screen)

**Goal:** Remove the scheduled-vs-oneTime toggle and one-time section from the create-item form.

**Files to create/modify:**
- `lib/src/features/items/presentation/item_create/create_item_screen.dart` — remove type state, toggle, one-time section, one-time validation

**Steps:**
- [x] Remove `ItemType _type` state variable and all references to `ItemType`
- [x] Remove `_oneTimeDate`, `_oneTimeStart`, `_oneTimeEnd`, `_oneTimeQuantity` state variables
- [x] Remove `_validateExtras()` one-time branch (keep schedule validation)
- [x] Remove the `SegmentedButton<ItemType>` widget and its surrounding divider/label
- [x] Remove `_buildOneTimeSection()` method entirely
- [x] Remove `_pickDate()`, `_pickStartTime()`, `_pickEndTime()` methods
- [x] Update `_submit()` to not pass `type` or `oneTime*` params; always pass schedule
- [x] Remove `if (_type == ItemType.oneTime)` conditional around the schedule section — always show `_buildScheduleSection()`
- [x] Remove `intl` import if no longer used after date formatting removal

**Verification:** `flutter analyze` passes. Form builds with only the schedule section visible.

---

### Stage 4: Navigation & item screen cleanup

**Goal:** Remove `itemType` from `ItemScreen`, delete `tabsForItemType()`, and clean up routing.

**Files to create/modify:**
- `lib/src/features/items/presentation/item_tab.dart` — delete `tabsForItemType()` function
- `lib/src/features/items/presentation/item_screen/item_screen.dart` — remove `itemType` constructor param, always use `ItemTab.values`
- `lib/src/features/items/presentation/items_list/item_action_dialog.dart` — remove `tabsForItemType` call, remove `'type'` from query params
- `lib/src/routing/business_router.dart` — remove `type` query param parsing and `ItemType` import

**Steps:**
- [x] Delete `tabsForItemType()` function from `item_tab.dart`
- [x] In `item_screen.dart`: remove `itemType` param, replace `tabsForItemType(widget.itemType)` with `ItemTab.values`
- [x] In `item_action_dialog.dart`: replace `tabsForItemType(item.type)` with `ItemTab.values`, remove `'type': item.type.name` from query params, remove `ItemType` import
- [x] In `business_router.dart`: remove `typeParam`/`itemType` parsing (lines 316–321), remove `itemType: itemType` from `ItemScreen` constructor, remove `ItemType` import

**Verification:** `flutter analyze` passes. Item screen opens with all 5 tabs regardless of deep link params.

---

### Stage 5: Dead code deletion & localization

**Goal:** Delete the unused create-item dialog, remove `oneTime` localization string, and clean up the test.

**Files to create/modify:**
- `lib/src/features/items/presentation/items_list/create_item_dialog.dart` — **delete entirely**
- `lib/l10n/app_en.arb` — remove `"oneTime"` entry
- `lib/l10n/app_kk.arb` — remove `"oneTime"` entry
- `lib/l10n/app_ru.arb` — remove `"oneTime"` entry
- `test/features/items/item_model_test.dart` — remove type-related test

**Steps:**
- [x] Delete `create_item_dialog.dart`
- [x] Remove `"oneTime"` key from all three ARB files (keep `"scheduled"`)
- [x] Regenerate localization (`flutter gen-l10n` or build_runner)
- [x] Remove `"default type is scheduled"` test from `item_model_test.dart`
- [x] Verify no other file imports `create_item_dialog.dart` or references `ItemType`

**Verification:** `flutter analyze` passes. `grep -r "ItemType" lib/` returns no hits. `grep -r "oneTime" lib/` returns no hits (Dart). `grep -r "oneTime" functions/src/` only appears in `create-one-time-offer.ts` (out of scope, expected).

---

### Stage 6: Cloud Functions cron simplification

**Goal:** Remove the `syncOneTimeItem()` function and the type branching from `dailySyncOffers`.

**Files to create/modify:**
- `functions/src/features/offers/functions/daily-sync-offers.ts` — delete `syncOneTimeItem()`, remove `if (itemData.type === "oneTime")` branch

**Steps:**
- [x] Delete the entire `syncOneTimeItem()` function (lines 90–162)
- [x] Remove the `if (itemData.type === "oneTime") { ... } else { ... }` branching in the item loop
- [x] Keep only the `else` body (buildExpectedOffers + diffAndApply) as the single code path for all items
- [x] Remove unused imports if any (e.g., `Timestamp` if only used in `syncOneTimeItem`)
- [x] Update the JSDoc comment at the top to reflect the simplified behavior

**Verification:** `npm run build` in `functions/` passes. No TypeScript errors.

---

### Stage 7: Final verification

**Goal:** End-to-end confirmation that everything compiles and no stale references remain.

**Steps:**
- [x] Run `dart run build_runner build --delete-conflicting-outputs`
- [x] Run `flutter analyze` — must pass with zero issues
- [x] Run `npm run build` in `functions/`
- [x] Search for any remaining `ItemType`, `oneTime`, or `type === "oneTime"` references across the codebase
- [x] Confirm `loc.scheduled` still exists and is used in `item_card.dart`

**Verification:** All checks green. No references to the removed type system remain.

## Cloud Functions

| Function | Change |
|----------|--------|
| `dailySyncOffers` | Delete `syncOneTimeItem()`, remove type branching — single path: `buildExpectedOffers` + `diffAndApply` |
| `createOneTimeOffer` | **No change** (out of scope) |
| `on-item-status-changed` | **No change** (verified clean) |
| `build-expected-offers` | **No change** (verified clean) |

## Test Coverage

- Remove `"default type is scheduled"` unit test (tests deleted field)
- Remaining item model tests should continue to pass with the simplified model
- No new tests needed — this is a pure removal refactor

## Risks

- **Existing Firestore documents with `type: "oneTime"`**: sandbox mode — these documents will be ignored by the cron (no valid `schedule` to process) or fail gracefully. Manual wipe recommended.
- **Deep links with `?type=oneTime`**: after removing param parsing, the router ignores unknown query params — no crash, item screen shows all tabs.
- **`intl` import in create_item_screen**: only used for `DateFormat` in one-time date picker. After removal, verify the import is no longer needed or remove it.

## Out of Scope

- Renaming `Item` to `OfferTemplate`
- Adding `templateId` to `Offer` model
- Splitting `quantity` into total/remaining on Offer
- Expanding `OfferStatus` with `soldOut`, `cancelled`
- Modifying `createOneTimeOffer` callable
- Any payment / Stripe code changes
- Adding `createdAt`/`updatedAt` server timestamps to `createItem()`
