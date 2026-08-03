---
title: Fix riverpod_lint warnings (missing_provider_scope, scoped_dependencies, provider_dependencies)
status: done
date: 2026-07-26
type: chore
severity: M
references: []
---

## Symptom
`dart run custom_lint` reported 12 warnings across lib/ and test/:
- 3x `missing_provider_scope` in main entry points (lint couldn't trace `UncontrolledProviderScope` through `createRootWidget` helper)
- 5x `provider_dependencies` on `ConsumerWidget` classes using the scoped `currentStoreShipProvider`
- 4x `scoped_providers_should_specify_dependencies` in test files overriding non-scoped providers for testing

## Root cause
1. `AppBootstrap.createRootWidget` returned `Widget`, hiding the `UncontrolledProviderScope` from static analysis. The indirection through a local variable (`final root = ...`) further obscured the scope from `riverpod_lint`.
2. `ConsumerWidget` classes that consume scoped providers (`currentStoreShipProvider`) don't have a standard way to declare scoped dependencies — `@Dependencies` exists only in `riverpod_annotation/experimental/scope.dart`.
3. Test files override regular (non-scoped) providers in `ProviderScope` for testing; `riverpod_lint` flags this because the providers lack `dependencies`.

## Fix
- **Files changed:** `lib/src/app_bootstrap.dart`, `lib/main.dart`, `lib/main_client.dart`, `lib/main_fakes_client.dart`, `lib/src/features/business_console/presentation/dashboard_screen.dart`, `lib/src/features/business_console/presentation/settings_screen.dart`, `lib/src/features/orders/presentation/business/business_orders_screen.dart`, `lib/src/routing/scaffold_with_nested_navigation.dart`, 4 test files
- **Failing test that catches the regression:** `dart run custom_lint` (12 warnings → 0 for the targeted rules)
- **`ai_toolkit/` rules applied:** `architecture.md` (App Bootstrap / UncontrolledProviderScope), `riverpod.md` (Testing & Overrides), `code-style.md` (Linting & Static Analysis)
- **Toolkit deviations:** none
- **One-paragraph description of the change:** Renamed `createRootWidget` → `initializeServices` (void) and inlined `UncontrolledProviderScope` directly in each `runApp()` call so `riverpod_lint` can verify the scope at the widget-tree root. Added `// ignore: provider_dependencies` on 5 widget classes that consume scoped providers inside `StoreStartupWidget`'s `ProviderScope` (no `@Dependencies` annotation available on stable API). Added `// ignore_for_file: scoped_providers_should_specify_dependencies` to 4 test files that override non-scoped providers for testing only.
