---
title: Auto-dispose / keepAlive provider state desync
date: 2026-06-27
work_type: bug
tags: [riverpod, auto-dispose, keepAlive, geocoding, onboarding, state-sync]
confidence: medium
references: [ai_specs/014-review-details-location-fix.md, 85706c8]
---

## Summary
An auto-dispose provider (`storeLocationProvider`) lost geocoded coordinates on screen re-entry while a keepAlive provider (`storeDraftController`) still held them. The guard `if (draft.location != null) return` skipped re-geocoding but never seeded the freshly-created auto-dispose provider, leaving the UI showing "location not found." Fixed by adding a `setLocation` method and calling it when draft already has coordinates.

## Reusable Insights

- **Seed auto-dispose providers from keepAlive truth on re-entry** — when a screen's auto-dispose provider is recreated but a keepAlive provider already holds the data, explicitly seed the new instance (e.g. `notifier.setLocation(draft.location)`) in `initState` / `addPostFrameCallback`. Never assume the auto-dispose provider "remembers" across screen transitions. _Example: `review_details_screen.dart:_geocodeIfNeeded`._

- **Early-return guards must account for provider state, not just data existence** — a guard like `if (data != null) return` may be correct for skipping an API call, but if the UI watches a *different* provider for display, that provider's state must also be updated before returning. Always trace what the widget's `ref.watch` actually renders. _Example: `storeLocationProvider` initial state is `AsyncData(null)` while `storeDraftController.location` is non-null._

- **Auto-dispose + keepAlive boundary is a common desync point** — any time two providers with different lifetimes share overlapping data, treat screen re-entry as a potential desync scenario. Audit `initState`/`build` to confirm the short-lived provider is synchronized with the long-lived one.

## Pitfalls

- **"Location not found" on second visit** — symptom: map preview shows error despite correct address. Cause: auto-dispose provider recreated with `build() => null`; guard skipped geocoding because draft had coordinates; UI watched the provider (null), not the draft. Fix: seed provider from draft. Avoid by: always tracing `ref.watch` → provider state → initial value when an early-return guard fires.
