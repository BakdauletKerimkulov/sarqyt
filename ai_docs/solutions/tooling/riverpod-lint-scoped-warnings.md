---
title: Resolving riverpod_lint scoped provider warnings
date: 2026-07-26
work_type: tooling
tags: [riverpod, lint, riverpod_lint, scoped-providers, bootstrap]
confidence: medium
references: [ai_specs/032-riverpod-lint-cleanup-spec.md]
---

## Summary
Fixed 12 `riverpod_lint` v3 warnings across three rules: `missing_provider_scope`, `provider_dependencies`, and `scoped_providers_should_specify_dependencies`. The key lesson is that riverpod_lint does static type analysis — it cannot trace `UncontrolledProviderScope` through helper methods or variables, and it cannot verify scoped-provider dependencies on `ConsumerWidget` classes without an experimental annotation.

## Reusable Insights

- **`runApp()` must receive `ProviderScope`/`UncontrolledProviderScope` as a direct constructor call** — wrapping the scope inside a helper method that returns `Widget` hides the type from `riverpod_lint`'s `missing_provider_scope` rule. Split bootstrap into `initializeServices(container)` + inline scope in `runApp()`. _Example: `app_bootstrap.dart` → `createRootWidget` renamed to `initializeServices`._

- **Test-only provider overrides trigger `scoped_providers_should_specify_dependencies`** — when a test `ProviderScope` overrides a non-scoped provider (no `dependencies` declared), the lint fires. Adding `dependencies: []` to silence it would break production (provider throws when not overridden). Use `// ignore_for_file: scoped_providers_should_specify_dependencies` in test files instead.

- **`@Dependencies` for widgets exists but is experimental** — `riverpod_annotation/experimental/scope.dart` exports a `@Dependencies([...])` annotation for `ConsumerWidget` classes that consume scoped providers. It is NOT in the main barrel export. Until it graduates to stable, prefer `// ignore: provider_dependencies` on widget classes that are architecturally guaranteed to live inside the overriding `ProviderScope`.

- **`dart run custom_lint` is the authoritative source for riverpod_lint warnings** — IDE lint results may lag or differ from CLI output. Always verify with the CLI before and after a fix pass.

## Pitfalls

- **Helper method hiding the provider scope** — symptom: `missing_provider_scope` warning on `runApp(root)` even though `root` is an `UncontrolledProviderScope`. Cause: riverpod_lint checks the static type of the argument to `runApp()`, not the runtime type; a `Widget`-typed variable or function return hides it. Fix: inline the `UncontrolledProviderScope(...)` constructor directly in `runApp()`. Avoid by: never wrapping the root scope in a helper that returns `Widget`.
