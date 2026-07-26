---
title: Six-phase toolkit compliance refactoring
date: 2026-07-15
work_type: refactor
tags: [riverpod, testing, linting, breakpoints, clock, robot, golden]
confidence: high
references: [ai_specs/031-toolkit-compliance-refactoring-plan.md, ai_specs/031-toolkit-compliance-refactoring-spec.md]
---

## Summary
Aligned the codebase with `ai_toolkit/` conventions across six phases: linting infra, NotifierMounted mixin, injectable clock, M3 breakpoints, robot-test scaffold, and golden tests. All 18 requirements delivered, 8 commits, merged via PR #12. The phased approach kept every commit compilable and reviewable.

## Reusable Insights

- **Phase per concern, not per file** — when a refactoring touches cross-cutting patterns (mixin, clock, breakpoints), scope each phase to one concern across all affected files rather than one file at a time. This keeps each commit self-contained and reviewable. _Example: phase 3 touched 7 files but all for "injectable clock."_
- **CachedNetworkImage blocks widget tests** — `CachedNetworkImage` uses `sqflite` + `path_provider` internally. Widget tests hang or throw `MissingPluginException` unless you (1) init `sqfliteFfiInit()` + `databaseFactoryFfi`, (2) mock the `path_provider` method channel, and (3) drain image exceptions with `tester.takeException()` in a loop. _Example: `test/src/robot.dart:36-101`._
- **Avoid `pumpAndSettle` with network-image widgets** — `pumpAndSettle` loops forever because `CachedNetworkImage` HTTP errors trigger continuous rebuilds. Use a fixed pump loop (`5 × 100ms`) + `runAsync` delay instead. _Example: `test/src/robot.dart:89-91`._
- **Domain models can't access providers — use method parameters** — freezed domain models (`Order`) that need "now" can't inject a provider. Convert getters to methods accepting `DateTime now`; presentation passes `DateTime.now()`, tests pass a fixed value. _Example: `order.isPickupExpired(DateTime.now())` in `order_detail_screen.dart`._
- **Golden baselines are platform-sensitive** — font rendering differs between macOS and Linux CI. Either exclude golden tests from CI (`ci: exclude golden tests`) or regenerate baselines on the CI OS. _Example: `dart_test.yaml` + `.github/workflows/ci.yml` exclusion._
- **Breakpoint changes surface hidden layout bugs** — changing `Breakpoint.desktop=900` → `Breakpoints.expanded=840` exposed a `DayRow` overflow on compact screens that was previously masked by wider thresholds. Always manually test responsive widgets after changing breakpoint constants. _Example: `weekly_schedule_card.dart` DayRow rewrite._

## Decisions

- **NotifierMounted mixin vs. ref.mounted** — chose a dedicated mixin over Riverpod's built-in `ref.mounted`. Rationale: `ref.mounted` requires holding a `Ref` reference across async gaps; the mixin is self-contained with `ref.onDispose(setUnmounted)`. Trade-off: one extra mixin per controller.
- **Exclude goldens from CI vs. regenerate on CI OS** — chose exclusion for now. Rationale: CI runs Linux, dev runs macOS; maintaining dual baselines adds friction with no safety gain until the team stabilizes visual design. Trade-off: golden tests only run locally.
- **Fixed pump loop vs. pumpAndSettle** — chose fixed pump loop in robot. Rationale: `pumpAndSettle` hangs with `CachedNetworkImage` HTTP errors. Trade-off: tests may need the pump count tuned if app startup slows.

## Pitfalls

- **CachedNetworkImage in widget tests** — symptom: `MissingPluginException` on `path_provider` or tests hanging forever. Cause: `CachedNetworkImage` uses `sqflite` + native channels internally. Fix: init `sqfliteFfiInit()`, mock `path_provider` channel, drain exceptions. Avoid by: always including these three steps in the robot's `pumpApp()`.
- **Breakpoint constant rename causes silent overflow** — symptom: `DayRow` overflowed on screens < 600px after changing desktop breakpoint from 900→840. Cause: the old 900px threshold meant compact layouts were rarely tested; lowering to 840 exposed the issue. Fix: made `DayRow` adaptive with `Column`+`Wrap` on compact screens. Avoid by: running the app at phone width after any breakpoint change.
