---
title: Fix keepAlive lint on geolocatorServiceProvider
status: done
date: 2026-07-26
type: chore
severity: S
references: []
---

## Symptom
`dart run custom_lint` reports `only_use_keep_alive_inside_keep_alive` at `geolocator_service.dart:50` — the keepAlive `positionProvider` reads the auto-dispose `geolocatorServiceProvider`.

## Root cause
`geolocatorServiceProvider` was declared with `@riverpod` (auto-dispose) but is consumed by the keepAlive `positionProvider`. A keepAlive provider must not depend on an auto-dispose provider because the dependency can be disposed while the consumer still exists.

## Fix
- **Files changed:** `lib/src/features/map/application/geolocator_service.dart`, `lib/src/features/map/application/geolocator_service.g.dart` (regenerated)
- **Failing test that catches the regression:** `dart run custom_lint` (1 warning → 0)
- **`ai_toolkit/` rules applied:** `riverpod.md` — services and repositories are `keepAlive: true`
- **Toolkit deviations:** none
- **One-paragraph description of the change:** Changed `@riverpod` to `@Riverpod(keepAlive: true)` on `geolocatorService` provider, since it is a stateless service with no cleanup and is consumed by a keepAlive provider. Regenerated codegen.
