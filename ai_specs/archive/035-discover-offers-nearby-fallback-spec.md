---
title: Fix offers list flashing then disappearing after GPS resolves
status: done
date: 2026-07-30
type: fix
severity: S
references: []
---

## Symptom
On Android emulator startup, the Discover screen briefly shows the full list of active offers, then ~2 seconds later the list disappears and is replaced by the "no offers found" empty state.

## Root cause
`offersWithDistanceStream` (`lib/src/features/offers/application/offers_with_distance.dart:44-58`) watches `positionProvider`. While GPS is still resolving, `position` is `null`, so the provider falls back to `repo.watchAllOffers()` (unfiltered) and the full list renders immediately. Once `Geolocator.getCurrentPosition()` resolves (~1-3s on the emulator), the provider rebuilds and switches to `repo.watchNearbyOffers()`, a geohash-prefix query around the resolved position. When the emulator's location doesn't match any seeded offer's geohash tile, the geo-filtered query returns an empty list with no reconciliation against the previously-shown data, so the screen flips to the empty state.

## Fix
- **Files changed:** `lib/src/features/offers/application/offers_with_distance.dart`
- **Failing test that catches the regression:** `test/features/offers/offers_with_distance_test.dart::falls back to all offers when the nearby geo query is empty`
- **`ai_toolkit/` rules applied:** `riverpod.md` (stream provider stays `@riverpod` auto-dispose, no manual subscription management), `testing.md` (repository provider override as the seam, mocktail mock, no backend SDK mock)
- **Toolkit deviations:** none
- **Description:** `offersWithDistanceStream` now uses `switchMap` on the geo-filtered nearby stream — when a nearby snapshot is empty, it falls back to the unfiltered `watchAllOffers()` stream instead of surfacing an empty list, so offers that were already visible don't disappear once a real GPS fix arrives.
