---
title: Toolkit compliance refactoring
status: in-progress
date: 2026-07-12
type: refactor
---

# Plan: Toolkit compliance refactoring

Source: `ai_specs/031-toolkit-compliance-refactoring-spec.md`

## Overview

Align codebase with `ai_toolkit/` conventions in six phases: linting infra → NotifierMounted mixin → injectable clock → M3 breakpoints → robot-test scaffold → golden tests. Each phase is a thin vertical slice that compiles and passes analysis independently.

**Spec:** `ai_specs/031-toolkit-compliance-refactoring-spec.md`

## Context

- **Structure:** feature-first (`lib/src/features/{name}/{domain,data,application,presentation}/`)
- **State management:** Riverpod 3 codegen (`@riverpod` classes), e.g. `lib/src/features/onboarding/presentation/inbound/create_account_controller.dart`
- **Reference implementations:** `SettingsContentController` (manual `_mounted` hack to replace), `CreateAccountController` (try/catch + `ref.mounted` to replace)
- **Testing convention:** `test/src/features/` mirrors `lib/src/features/`; `mocktail` not yet in deps; no robot infra, no `dart_test.yaml`. See `ai_toolkit/architecture.md` lines 662–757
- **Lint + test command:** `flutter analyze && flutter test`
- **Assumptions / Gaps:**
  - `order_detail_screen.dart:238` currently uses `order.isPickupExpired` as a getter — will become `order.isPickupExpired(DateTime.now())`. Only one call site found
  - `logAppExcaption` typo exists in both `error_logger.dart:14` and `async_error_logger.dart:16` — N1 nice-to-have
  - `test/src/` has no `robot.dart`, `mocks.dart`, or `dart_test.yaml` — all created from scratch
  - Golden test baselines are platform-sensitive — will need regeneration per CI OS

## Plan

### Phase 1 — Linting infrastructure (R1, R2, R3)

**Goal:** `custom_lint` + `riverpod_lint` + `mocktail` in deps; `analysis_options.yaml` updated; `flutter analyze` and `dart run custom_lint` pass on touched files.

- [x] `pubspec.yaml` — add `custom_lint`, `riverpod_lint`, `mocktail` to `dev_dependencies`
- [x] `analysis_options.yaml` — add `custom_lint` plugin under `analyzer:plugins:`, add `exclude` for `**/*.g.dart` and `**/*.freezed.dart`
- [x] Run `flutter pub get` — verify no resolution errors
- [x] Audit `dart run custom_lint` output on files touched by this spec — fix issues in those files; log untouched-file issues for PR description
- [x] Verify: `flutter analyze && dart run custom_lint` (zero issues in touched files)

### Phase 2 — NotifierMounted mixin + controller fixes (R4, R5, R6, R7, N1)

**Goal:** Shared `NotifierMounted` mixin replaces ad-hoc mounted hacks in two controllers; `CreateAccountController` uses `AsyncValue.guard`.

- [x] `lib/src/utils/notifier_mounted.dart` — create `NotifierMounted` mixin (3 members: `_mounted`, `setUnmounted()`, `mounted` getter) per `riverpod.md` lines 68–78
- [x] `lib/src/features/items/presentation/item_screen/settings_content_controller.dart` — add `with NotifierMounted`, add `ref.onDispose(setUnmounted)` in `build()`, remove manual `_mounted` getter (lines 82–89), update `if (_mounted)` → `if (mounted)`
- [x] `lib/src/features/onboarding/presentation/inbound/create_account_controller.dart` — add `with NotifierMounted`, add `ref.onDispose(setUnmounted)` in `build()`, replace try/catch with `AsyncValue.guard` + `if (mounted) state = newState`, keep pre-async `ref.read` capture
- [x] `lib/src/exceptions/error_logger.dart` — rename `logAppExcaption` → `logAppException` (N1)
- [x] `lib/src/exceptions/async_error_logger.dart` — update call site `logAppExcaption` → `logAppException` (N1)
- [x] Verify: `flutter analyze && flutter test`

### Phase 3 — Injectable clock (R8, R9, R10)

**Goal:** `currentDateBuilderProvider` replaces `DateTime.now()` in domain/data/application layer; presentation-layer calls stay.

- [ ] `lib/src/utils/current_date_builder.dart` — create `currentDateBuilderProvider` returning `DateTime Function()` with `DateTime.now` default, per `riverpod.md` lines 370–386
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` for codegen
- [ ] `lib/src/features/offers/data/client_offer_repository.dart` — inject `DateTime Function() currentDateBuilder` via constructor, replace 4 `DateTime.now()` calls; update repository provider to pass `ref.read(currentDateBuilderProvider)`
- [ ] `lib/src/features/offers/data/fake_client_offer_repository.dart` — inject clock, replace `DateTime.now()`
- [ ] `lib/src/features/orders/domain/order.dart` — convert `timeUntilPickupEnd` and `isPickupExpired` from getters to methods accepting `DateTime now` parameter
- [ ] `lib/src/features/orders/presentation/client/order_detail_screen.dart` — update `order.isPickupExpired` → `order.isPickupExpired(DateTime.now())`, update `order.timeUntilPickupEnd` → `order.timeUntilPickupEnd(DateTime.now())`
- [ ] `lib/src/features/offers/application/discover_filter.dart` — add `DateTime now` parameter to `applyFilter`; update `filteredOffers` provider to read `currentDateBuilderProvider` and pass `now()` to `applyFilter`
- [ ] `lib/src/testing/test_offer.dart` — replace `DateTime.now()` with parameter or injected clock
- [ ] Grep all other call sites of `timeUntilPickupEnd` / `isPickupExpired` — update each to pass `DateTime.now()` (presentation) or injected clock (non-presentation)
- [ ] Verify: `flutter analyze && flutter test` — confirm `grep -r "DateTime.now()" lib/src/` shows only presentation-layer hits

### Phase 4 — M3 breakpoints (R11, R12)

**Goal:** `Breakpoint` class → `Breakpoints` (M3 values) + `WindowSize` enum; all usages updated.

- [ ] `lib/src/constants/breakpoints.dart` — rename class `Breakpoint` → `abstract final class Breakpoints`, values to `compact = 600`, `expanded = 840`; add `WindowSize` enum with `fromWidth` factory per `code-style.md` lines 148–183
- [ ] `lib/src/common_widgets/responsive_center.dart` — update `Breakpoint.desktop` → `Breakpoints.expanded` (both `ResponsiveCenter` and `ResponsiveSliverCenter`)
- [ ] Update remaining 6 files importing old `Breakpoint`: `responsive_centered_grid.dart`, `forbidden_page.dart`, `schedule_content.dart`, `item_details.dart`, `auth_layout.dart`, `responsive_scrollable_card.dart` — rename references to `Breakpoints.*`
- [ ] Verify: `flutter analyze` — `grep -r "Breakpoint\." lib/src/` returns zero hits for old class

### Phase 5 — Robot test infrastructure (R13, R14, R15, R16)

**Goal:** Composite Robot, shared mocks, one feature robot, one passing widget test for reserve-offer flow.

- [ ] `test/src/mocks.dart` — create shared mocktail mocks for key repositories (auth, offers, orders)
- [ ] `test/src/robot.dart` — create composite Robot class that pumps app with fakes `ProviderContainer` per `architecture.md` lines 690–706
- [ ] `test/src/features/offers/offers_robot.dart` — create offers robot with methods for discover → reserve flow
- [ ] TDD: client opens offer → reserves → sees order in list — write widget test using robot API
- [ ] `test/src/features/offers/reserve_offer_test.dart` — implement the robot-driven widget test (R16)
- [ ] Verify: `flutter test test/src/`

### Phase 6 — Golden tests + dart_test.yaml (R17, R18)

**Goal:** Golden test infrastructure; one golden test for discover screen at two sizes.

- [ ] `dart_test.yaml` — create at project root with `golden` tag defined
- [ ] `test/src/features/offers/discover_golden_test.dart` — golden test for discover screen at phone (390×844) and tablet (834×1194) per `architecture.md` lines 727–757
- [ ] Run `flutter test --update-goldens --tags golden` — generate baseline PNGs
- [ ] Verify: `flutter test --tags golden` passes against baselines

## Data layer changes

_None._

## External integrations

_None._

## Risks

- **`dart run custom_lint` may surface many issues in untouched files** — spec explicitly defers those to PR description and follow-up. Only fix issues in files touched by this spec.
- **Golden baselines are platform-sensitive** — regenerate on same OS as CI, or exclude goldens from CI initially.
- **`order.dart` getter → method is a breaking change for all call sites** — grep exhaustively; compile will catch misses.
- **Robot test for reserve flow may require significant fake data setup** — scope to the minimum viable fake data; expand incrementally.

## Out of scope

- NOT implementing `envied` — no pressing need, few client secrets.
- NOT writing `integration_test/` on real Firebase.
- NOT refactoring controllers that already use `AsyncValue.guard` correctly.
- NOT changing `PaymentButtonController` or `CreateItemFormController` try/catch patterns — legitimate.
- NOT adding l10n keys — no new user-facing strings.
- NOT touching Firestore schema, security rules, Cloud Functions.
- NOT fixing `cloud_firestore` import in `order.dart` — separate task.
- NOT covering all flows with robot tests — only critical reserve-offer flow.
