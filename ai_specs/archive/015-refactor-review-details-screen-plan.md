---
title: Refactor Review Details Screen
status: done
date: 2026-06-27
type: refactor
---

# Plan: Edit Store Draft Dialog on ReviewDetailsScreen

Source: `ai_specs/015-refactor-review-details-screen-spec.md`

## Overview
Add an edit dialog to `ReviewDetailsScreen` that reuses `StoreFormContent` inside an `AlertDialog`. Requires: (1) make `StoreFormContent` externally submittable via public state class + `showSubmitButton` param, (2) create `EditStoreDraftDialog` widget, (3) wire it into `ReviewDetailsScreen` replacing the placeholder. Follows `InviteMemberDialog` pattern for dialog structure.

**Spec:** `ai_specs/015-refactor-review-details-screen-spec.md`

## Context
- **Structure:** feature-first — `lib/src/features/{feature}/{layer}/`
- **State management:** Riverpod codegen (`@riverpod`), `StoreDraftController` is `keepAlive: true` — `store_draft_controller.dart:11`
- **Reference implementations:**
  - `invite_member_dialog.dart` — AlertDialog + Form + local state + Cancel/Save actions
  - `create_account_screen.dart:48-67` — `StoreFormContent` usage with `onSubmit` → `saveStepOne()`
- **Testing convention:** mirrors `lib/` structure in `test/`; mock repos for controllers, no widget tests unless UI is complex; `group()` + `test()` — `ai_toolkit/architecture.md:529-567`
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:**
  - No existing tests for `StoreDraftController` — test dir for onboarding/inbound doesn't exist yet
  - Spec says `Navigator.of(context).pop()` is acceptable for dialogs (confirmed by `invite_member_dialog.dart:43`)

## Plan

### Phase 1 — Make StoreFormContent externally submittable
**Goal:** Add `showSubmitButton` param and make state class public so dialog can trigger `submit()` via GlobalKey.

- [x] `lib/src/features/store/presentation/store_form_content.dart` — rename `_StoreFormContentState` → `StoreFormContentState` (make public)
- [x] `lib/src/features/store/presentation/store_form_content.dart` — add `showSubmitButton` param (default `true`); conditionally render `PrimaryWebButton` (lines 264–267)
- [x] Verify: `flutter analyze`

### Phase 2 — Create EditStoreDraftDialog + wire into ReviewDetailsScreen
**Goal:** End-to-end: tapping Edit opens dialog with pre-filled form, Save calls `saveStepOne()` and triggers geocoding if address changed.

- [x] `lib/src/features/onboarding/presentation/inbound/edit_store_draft_dialog.dart` — new `StatefulWidget`: `AlertDialog` with scrollable `StoreFormContent(showSubmitButton: false)`, Cancel/Save actions. Save calls `formKey.currentState!.submit()`, on success calls `saveStepOne()` via `StoreDraftController`, pops with `true`.
- [x] `lib/src/features/onboarding/presentation/inbound/review_details_screen.dart` — replace `showNotImplementedAlertDialog` (line 108) with `showDialog<bool>(child: EditStoreDraftDialog(...))`. On result `true`, call `_geocodeIfNeeded()`.
- [x] `lib/src/features/onboarding/presentation/inbound/review_details_screen.dart` — remove unused `alert_dialogs.dart` import if `showNotImplementedAlertDialog` was the only usage.
- [x] Verify: `flutter analyze`

### Phase 3 — Unit tests for StoreDraftController
**Goal:** Verify `saveStepOne()` address-change detection and location reset logic.

- [x] TDD: `saveStepOne()` resets `location` to `null` when address fields change (already implemented)
- [x] TDD: `saveStepOne()` preserves `location` when only name/phone/storeType change (already implemented)
- [x] `test/features/onboarding/store_draft_controller_test.dart` — implement above tests using `ProviderContainer`
- [x] Verify: `flutter analyze && flutter test`

## Data layer changes
_None._

## External integrations
_None._ Geocoding already handled by `StoreLocationController`.

## Risks
- Making `StoreFormContentState` public exposes internal API — mitigated by only using it via `GlobalKey` in the dialog, no other callers need to know about it.
- `DropdownButtonFormField.initialValue` vs `value` — verify the form pre-fills correctly on dialog open (the existing pattern in `StoreFormContent.initState` handles this via controllers).

## Out of scope
- No new GoRouter route — dialog, not a screen.
- No new Riverpod controller — reuses `StoreDraftController`.
- No `StoreDraft` model changes.
- No map pin editing (manual location adjustment).
- No validation rule changes.
- No localization of existing `StoreFormContent` validator messages.
