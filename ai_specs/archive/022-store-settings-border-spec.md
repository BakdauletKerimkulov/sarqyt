---
title: Fix store settings border stretching full tab height
status: done
date: 2026-07-06
type: fix
severity: S
references: []
---

## Symptom
On the Settings screen, the "Store information" section border stretches to fill the entire TabBarView height, leaving large empty space below the actual content ("Contact details").

## Root cause
`TabBarView` passes tight height constraints to its children. The `Padding` → `Container` (in `OutlinedSectionWidgetWithHeader`) fills the full constrained height, so the border decoration covers the entire area instead of wrapping just the content. `settings_screen.dart:125`.

## Fix
- **Files changed:** `lib/src/features/business_console/presentation/settings_screen.dart`
- **Failing test that catches the regression:** `test/features/business_console/store_settings_border_test.dart::StoreSettingsContent border wraps content (uses SingleChildScrollView)`
- **`ai_toolkit/` rules applied:** `code-style.md` (minimal change)
- **Toolkit deviations:** none
- **One-paragraph description of the change:** Wrapped the `Padding` + `OutlinedSectionWidgetWithHeader` in a `SingleChildScrollView`, which loosens tight height constraints and allows the container to shrink to its natural content size. This also makes the tab scrollable if content grows.
