---
title: Toolkit compliance refactoring
status: done
date: 2026-07-12
type: refactor
---

# Spec: Toolkit compliance refactoring

Source request: `ai_specs/031-toolkit-compliance-refactoring.md`

## Goal

Align the codebase with the updated `ai_toolkit/` conventions: strict linting, the `NotifierMounted` mixin, an injectable clock, robot-test infrastructure, and golden tests. After this refactoring every new controller and test can follow a single documented pattern instead of ad-hoc solutions.

## Background

**Stack & conventions:** Flutter 3.41 + Riverpod 3 (codegen) + Freezed + Firebase. Key rules come from:

- `ai_toolkit/code-style.md` — `custom_lint` + `riverpod_lint` required; M3 `Breakpoints` class with `compact=600`, `expanded=840`; `WindowSize` enum.
- `ai_toolkit/riverpod.md` — `NotifierMounted` mixin in `lib/src/utils/notifier_mounted.dart`; `AsyncValue.guard` over try/catch; `currentDateBuilderProvider`; `AsyncErrorLogger` observer; robot pattern; golden tests.
- `ai_toolkit/architecture.md` — robot pattern in `test/src/`, `dart_test.yaml` with `golden` tag.

**Project context:**

- `analysis_options.yaml` (root) — stock `flutter_lints` include, no `custom_lint` plugin, no generated-file excludes.
- `pubspec.yaml` lines 97-116 — `custom_lint`, `riverpod_lint`, `mocktail` all missing from `dev_dependencies`.
- `lib/src/features/items/presentation/item_screen/settings_content_controller.dart:82-89` — manual `_mounted` getter via try/catch on `state`. Only controller with this hack.
- `lib/src/features/onboarding/presentation/inbound/create_account_controller.dart:28` — uses Riverpod's `ref.mounted` instead of the mixin.
- `lib/src/features/checkout/presentation/payment_button_controller.dart:21-42` — try/catch that branches on checkout state (legitimate; not a candidate for `AsyncValue.guard`).
- `lib/src/features/items/presentation/item_create/create_item_form_controller.dart:53-76` — nested try/catch for best-effort cleanup (legitimate; rethrows outer error).
- `DateTime.now()` appears in 9 `lib/src/` files (~20 call sites). Non-presentation usages in: `client_offer_repository.dart` (lines 52, 76, 103, 114), `fake_client_offer_repository.dart`, `order.dart` (lines 58, 63), `discover_filter.dart` (line 79).
- `lib/src/exceptions/async_error_logger.dart` — exists and is registered in both `app_bootstrap_firebase.dart:36` and `app_bootstrap_fakes.dart:41`.
- `lib/src/constants/breakpoints.dart` — class `Breakpoint` (singular) with `desktop=900, tablet=600, mobile=300`; does not match M3 window size classes.
- `lib/src/common_widgets/responsive_center.dart:15` — defaults to `Breakpoint.desktop` (900).
- No `test/src/robot.dart`, no `dart_test.yaml`, no golden-test infrastructure.

**Why now:** spec 012 (Refactor booking flow) is blocked by missing test infra (noted in `ai_specs/README.md`). This work unblocks it and prevents further ad-hoc patterns.

## User Flow

Not applicable — this is an internal refactoring with no user-facing changes.

## Requirements

### Must Have

- [ ] R1: `pubspec.yaml` adds `custom_lint`, `riverpod_lint`, and `mocktail` to `dev_dependencies`. Verifiable by `flutter pub get` succeeding and `dart run custom_lint` running without "package not found".
- [ ] R2: `analysis_options.yaml` includes the `custom_lint` plugin and excludes `**/*.g.dart` and `**/*.freezed.dart`. Verifiable by `flutter analyze` not warning on generated files.
- [ ] R3: All issues reported by `dart run custom_lint` **in files touched by this spec** are fixed (or explicitly listed for human review if the fix is ambiguous). Issues in untouched files are logged in the PR description and deferred to a follow-up task. Verifiable by `dart run custom_lint` returning zero issues in modified files.
- [ ] R4: `lib/src/utils/notifier_mounted.dart` exists with the `NotifierMounted` mixin per `riverpod.md`. Verifiable by reading the file.
- [ ] R5: `SettingsContentController` uses `NotifierMounted` mixin + `ref.onDispose(setUnmounted)` instead of its manual `_mounted` try/catch getter. Verifiable by the try/catch block at lines 82-89 being removed and `with NotifierMounted` being present.
- [ ] R6: `CreateAccountController` uses `NotifierMounted` mixin instead of `ref.mounted`. The `ref.read` before async (capturing service) stays; the mounted check after `catch` uses the mixin. Verifiable by `ref.mounted` being replaced with `mounted` from the mixin.
- [ ] R7: `CreateAccountController.register` uses `AsyncValue.guard` + `if (mounted) state = newState` instead of try/catch → `AsyncError`. The pre-async `ref.read` capture stays outside the guard closure. Verifiable by the try/catch block being replaced.
- [ ] R8: `currentDateBuilderProvider` exists in `lib/src/utils/current_date_builder.dart`, returning `DateTime Function()` with `DateTime.now` as default. Verifiable by reading the file.
- [ ] R9: All `DateTime.now()` calls in `client_offer_repository.dart` (4 sites), `fake_client_offer_repository.dart`, `order.dart` (2 sites: `timeUntilPickupEnd`, `isPickupExpired`), `discover_filter.dart` (1 site in `applyFilter`), and `test_offer.dart` (1 site) are replaced with the injected clock. The `filteredOffers` provider in `discover_filter.dart:117-124` is updated to read `currentDateBuilderProvider` and pass `now` to `applyFilter`. The call site `order_detail_screen.dart:238` (`order.isPickupExpired`) is updated to pass `DateTime.now()` (presentation layer — acceptable per toolkit rules). Verifiable by `grep -r "DateTime.now()" lib/src/` showing only presentation-layer hits.
- [ ] R10: `DateTime.now()` calls in presentation-only files (`offer_ui_helpers.dart`, `order_ui_helpers.dart`, `item_card.dart`, `sliver_items_grid.dart`, `review_card.dart`, `create_one_time_offer_dialog.dart`, `start_selling_dialog.dart`, `order_detail_screen.dart`) remain unchanged. Verifiable by those files still containing `DateTime.now()`.
- [ ] R11: `lib/src/constants/breakpoints.dart` is updated: class renamed to `Breakpoints` (plural, `abstract final class`), values changed to M3 window size classes (`compact = 600`, `expanded = 840`), and `WindowSize` enum with `fromWidth` factory added per `code-style.md`. Verifiable by reading the file and confirming values match M3.
- [ ] R12: All usages of old `Breakpoint.desktop` / `Breakpoint.tablet` / `Breakpoint.mobile` across the codebase are updated to use the new `Breakpoints` class. `ResponsiveCenter` default becomes `Breakpoints.expanded` (840). Verifiable by `grep -r "Breakpoint\." lib/src/` returning zero hits for the old class name.
- [ ] R13: `test/src/robot.dart` exists as a composite Robot that pumps the app with a fakes `ProviderContainer`. Verifiable by reading the file and seeing the pattern from `architecture.md`.
- [ ] R14: `test/src/mocks.dart` exists with shared mocktail mocks for repositories used in robot tests. Verifiable by reading the file.
- [ ] R15: At least one per-feature robot exists (offers or orders) with methods for the critical flow. Verifiable by reading the feature robot file(s).
- [ ] R16: One widget test exercises the flow: client opens offer → reserves → sees order in list. Verifiable by `flutter test test/src/features/...` passing.
- [ ] R17: `dart_test.yaml` exists at project root with `golden` tag defined. Verifiable by reading the file.
- [ ] R18: One golden test on the discover screen at two sizes — phone (390×844) and tablet (834×1194). Verifiable by `flutter test --update-goldens --tags golden` generating two baseline PNGs and `flutter test --tags golden` passing.

### Nice to Have

- [ ] N1: Fix the typo in `async_error_logger.dart:16` — method name `logAppExcaption` → `logAppException` (if the method name exists in `error_logger.dart` too, rename both).

### Non-functional

- Performance: no regression — this is infrastructure-only, no runtime changes except replacing `DateTime.now()` with a provider call (negligible).
- Accessibility: no changes.
- i18n: no new strings.

## Technical Constraints

**Files to create:**

- `lib/src/utils/notifier_mounted.dart` — `NotifierMounted` mixin (3 members: `_mounted`, `setUnmounted()`, `mounted` getter).
- `lib/src/utils/current_date_builder.dart` — `currentDateBuilderProvider` (`@riverpod DateTime Function()`).
- `test/src/robot.dart` — composite Robot class.
- `test/src/mocks.dart` — shared mocktail mocks.
- `test/src/features/offers/offers_robot.dart` — offers robot.
- `test/src/features/orders/orders_robot.dart` — orders robot.
- `test/src/features/offers/discover_golden_test.dart` — golden test for discover screen.
- `dart_test.yaml` — golden tag configuration.

**Files to modify:**

- `pubspec.yaml` — add `custom_lint`, `riverpod_lint`, `mocktail` to `dev_dependencies`.
- `analysis_options.yaml` — add `custom_lint` plugin + generated-file excludes.
- `lib/src/features/items/presentation/item_screen/settings_content_controller.dart` — replace `_mounted` hack with `NotifierMounted` mixin.
- `lib/src/features/onboarding/presentation/inbound/create_account_controller.dart` — replace `ref.mounted` + try/catch with `NotifierMounted` mixin + `AsyncValue.guard`.
- `lib/src/features/offers/data/client_offer_repository.dart` — inject clock, replace 4 `DateTime.now()` calls.
- `lib/src/features/offers/data/fake_client_offer_repository.dart` — inject clock.
- `lib/src/features/orders/domain/order.dart` — `timeUntilPickupEnd` and `isPickupExpired` need clock injection (these are computed getters on a freezed model — the cleanest approach is to make them methods accepting a `DateTime now` parameter, since domain models cannot access providers). Call site: `order_detail_screen.dart:238` must pass `DateTime.now()` (presentation layer — acceptable).
- `lib/src/features/orders/presentation/client/order_detail_screen.dart` — update `order.isPickupExpired` call to `order.isPickupExpired(DateTime.now())`.
- `lib/src/features/offers/application/discover_filter.dart` — `applyFilter` function takes an additional `DateTime now` parameter instead of calling `DateTime.now()` internally. The `filteredOffers` provider reads `currentDateBuilderProvider` and passes `now` to `applyFilter`.
- `lib/src/testing/test_offer.dart` — replace `DateTime.now()` with injected clock or accept `DateTime` parameter.
- `lib/src/constants/breakpoints.dart` — rename class, update values, add `WindowSize` enum.
- `lib/src/common_widgets/responsive_center.dart` — update default to `Breakpoints.expanded`.
- All files importing old `Breakpoint` class — update import and references.

**Patterns to follow (with citations):**

- `NotifierMounted`: `ai_toolkit/riverpod.md` lines 68-78 (mixin definition) and lines 88-110 (controller pattern).
- `currentDateBuilderProvider`: `ai_toolkit/riverpod.md` lines 370-386. Uses `@riverpod` (auto-dispose). Since repositories `ref.read()` it (not `ref.watch()`), disposal doesn't cause issues. In tests, override at container level.
- Robot pattern: `ai_toolkit/architecture.md` lines 663-723.
- Golden tests: `ai_toolkit/architecture.md` lines 727-757.
- `Breakpoints` + `WindowSize`: `ai_toolkit/code-style.md` lines 148-183.
- `AsyncValue.guard`: `ai_toolkit/riverpod.md` lines 83-86.

**Anti-patterns / avoid:**

- Do not convert `PaymentButtonController`'s try/catch — it legitimately branches on checkout state.
- Do not convert `CreateItemFormController`'s inner try/catch — it does best-effort cleanup and rethrows.
- Do not add `currentDateBuilderProvider` to presentation-only files — `DateTime.now()` in display code is acceptable per `riverpod.md` line 386.
- Do not add new dependencies beyond `custom_lint`, `riverpod_lint`, `mocktail`.

**Data layer changes:** None. No Firestore schema, security rules, or Cloud Functions changes.

**External integrations:** None.

## Out of Scope

- NOT implementing `envied` — no pressing need, few client secrets (per request).
- NOT writing `integration_test/` on real Firebase (per request).
- NOT refactoring controllers that already use `AsyncValue.guard` correctly (majority: 15/16).
- NOT changing `PaymentButtonController` or `CreateItemFormController` try/catch patterns — they are legitimate (branching / cleanup).
- NOT adding l10n keys — no new user-facing strings.
- NOT touching Firestore schema, security rules, Cloud Functions.
- NOT fixing the `cloud_firestore` import in `order.dart` — requires DTO/domain split refactor, separate task.
- NOT covering all flows with robot tests — only the critical reserve-offer flow for now; more will be added incrementally.

## Validation

**Automated tests:**

- Unit: `currentDateBuilderProvider` returns frozen time when overridden — test in `test/src/utils/current_date_builder_test.dart`.
- Unit: `applyFilter` with injected `now` — update existing test or add one in `test/src/features/offers/application/discover_filter_test.dart`.
- Widget / Robot: reserve-offer flow (R16) — `flutter test test/src/features/...`.
- Golden: discover screen at two sizes (R18) — `flutter test --tags golden`.

**Manual QA scenarios:**

1. Given a clean checkout, run `flutter analyze` — zero warnings.
2. Run `dart run custom_lint` — zero issues.
3. Run `flutter test` — all existing tests still pass.
4. Run `flutter test --tags golden` — golden test passes against baselines.
5. Verify the app compiles and runs on a device/simulator — no runtime regressions from clock injection or breakpoint changes.

**Expected behavior under edge conditions:**

- Clock injection: in tests, `ProviderContainer` override freezes time; in production, `DateTime.now` is called as before — no behavior change.
- Breakpoint rename: compile-time break if any import is missed — `flutter analyze` catches it.

## Definition of Done

- [ ] All Must Have requirements (R1–R18) pass automated tests
- [ ] `flutter analyze` reports zero warnings
- [ ] `dart run custom_lint` reports zero issues
- [ ] `flutter test` passes (all existing + new tests)
- [ ] `flutter test --tags golden` passes
- [ ] No new lint warnings; matches `ai_toolkit/` style guide
- [ ] Spec file linked in the PR description
