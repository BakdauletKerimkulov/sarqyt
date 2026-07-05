---
status: done
title: ReviewDetailsScreen shows "location not found" on re-entry
date: 2025-06-27
type: fix
severity: S
references: []
---

## Symptom
When navigating from CreateAccountScreen to ReviewDetailsScreen a second time (without changing address fields), the map preview shows "Местоположение не найдено" instead of displaying the previously geocoded location.

## Root cause
`storeLocationProvider` is auto-dispose (`@riverpod`). After the user presses Continue on ReviewDetailsScreen, coordinates are saved to `storeDraftController` (keepAlive) via `saveLocation()`. On re-entry, the provider is recreated with initial state `AsyncData(null)`. `_geocodeIfNeeded()` checks `draft.location != null` and returns early — but never seeds the freshly-created provider with the known coordinates. The UI watches the provider (still `null`) and `StaticMapPreview` renders the "location not found" fallback.

## Fix
- **Files changed:** `lib/src/features/map/application/store_location_controller.dart`, `lib/src/features/onboarding/presentation/inbound/review_details_screen.dart`
- **Failing test that catches the regression:** `test/features/onboarding/store_location_provider_test.dart::setLocation seeds provider state without API call`
- **`ai_toolkit/` rules applied:** `riverpod.md` (auto-dispose controllers, public methods for state mutation), `architecture.md` (application layer controllers)
- **Toolkit deviations:** none
- **Description:** Added `setLocation(LatLng)` method to `StoreLocation` controller. Updated `_geocodeIfNeeded()` in `ReviewDetailsScreen` to call `setLocation` with `draft.location` when coordinates are already known, instead of silently returning.
