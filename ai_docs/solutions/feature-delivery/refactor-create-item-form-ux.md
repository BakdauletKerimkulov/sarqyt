---
title: Refactor create item form UX
date: 2026-07-05
work_type: feature
tags: [forms, navigation, gorouter, schedule, localization, widget-extraction]
confidence: medium
references: [ai_specs/018-refactor-create-offer-flow-plan.md, PR #5]
---

## Summary
Shipped 4 UX improvements to the create item form: replaced Material time-picker dial with inline HH:MM text fields, added allergen/storing field, changed navigation to pop-with-result + dashboard snackbar, and fixed placeholder hint visibility. Decomposed a >300-line screen into extracted widgets along the way.

## Reusable Insights

- **pushNamed + pop(true) for creation flows** — when a screen creates a resource and the caller needs to react (e.g. show a snackbar), use `context.pushNamed<bool>` and `context.pop(true)` instead of `goNamed`. The caller awaits the result. No StatefulWidget conversion needed — async lambda in `onPressed` is sufficient.
- **showModalBottomSheet tolerates pop(true) without changes** — when a screen is opened both as a route (push) and as a modal bottom sheet, `context.pop(true)` works in both contexts. The bottom sheet simply closes; the push caller receives the bool.
- **Default M3 hintStyle is not reliably grey** — Flutter's Material 3 default theme uses `onSurfaceVariant` for hint text, which can appear near-black without a `ColorScheme.fromSeed`. Always set an explicit `hintStyle: TextStyle(color: Colors.grey.shade400)` in `InputDecoration` if grey hints are required.
- **Extract widget sections when a file exceeds 300 lines** — the `ScheduleFormSection` extraction was straightforward: move the method body into a new StatelessWidget, pass data + callbacks as params. Keeps both files under the limit and makes the parent scannable.
- **Per-day validation via Map getter on domain model** — when a domain object (like `WeeklySchedule`) has a single `validationError` string but the UI needs per-field errors, add a `Map<int, String?> get dayErrors` that returns all errors simultaneously. Keeps the old API for backward compat.

## Decisions

- **Async lambda vs ConsumerStatefulWidget** — chose async lambda in `onPressed` over converting `DashboardScreen` from `ConsumerWidget` to `ConsumerStatefulWidget`. Rationale: `onPressed` is `VoidCallback?`, async lambdas satisfy it, and `context.mounted` guard handles the gap. Trade-off: slightly less explicit lifecycle, but avoids unnecessary widget type change for one callback.
- **Shared `_inputDeco` with explicit hintStyle vs per-field** — chose to add `hintStyle` to the shared helper rather than per-field. All fields benefit from consistent grey hints. Trade-off: can't customize hint color per field without `.copyWith()`.

## Pitfalls

- **hintText appearing black** — symptom: placeholder text indistinguishable from user input. Cause: M3 default `onSurfaceVariant` is dark when no seed color is set and no `InputDecorationTheme` exists in the app theme. Fix: explicit `hintStyle` in the shared `_inputDeco` helper. Avoid by: always verify hint visibility on device when the app lacks a custom `InputDecorationTheme`.
