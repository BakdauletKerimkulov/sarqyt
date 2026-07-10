---
title: AsyncValue.guard hides disposal-unsafe async gap
date: 2026-07-10
work_type: bug
tags: [riverpod, async, auto-dispose, guard, mounted, testing]
confidence: medium
references: [ai_specs/026-fix-disposed-ref-delete-spec.md, 378bfac]
---

## Summary
`state = await AsyncValue.guard(...)` in an auto-dispose controller threw "Cannot use Ref after disposal" when a Cloud Function completed after the screen navigated away. The `await` before the `state =` assignment is an async gap where the provider can be disposed, but `AsyncValue.guard()` visually obscures this because the guard-and-assign looks like one atomic expression. Fixed by capturing the result in a local variable and gating the assignment with `_mounted`.

## Reusable Insights

- **`state = await AsyncValue.guard(...)` is NOT disposal-safe** — the `await` is an async gap where the provider can be disposed, but the pattern *reads* like a single atomic assignment. Always split it: `final result = await AsyncValue.guard(...); if (_mounted) state = result;`. The toolkit's `_mounted` examples use explicit try/catch, but the same rule applies to `guard()`. _Example: `settings_content_controller.dart:deleteItem`._

- **Test disposal races with a Completer-backed fake** — to reproduce "Ref used after disposal", create a fake repository whose async method returns a `Completer.future`, start the controller method, `container.dispose()`, then `completer.complete()`. The `expectLater(future, completes)` assertion catches the regression. _Example: `test/features/items/settings_content_controller_test.dart`._

## Pitfalls

- **`AsyncValue.guard` looks safe but isn't** — symptom: `Cannot use Ref after disposal` on the `state =` line. Cause: `guard()` wraps the inner future in a try/catch and returns an `AsyncValue`, but the *assignment* to `state` happens after `await` — outside the guard's protection. Fix: local variable + `_mounted` check. Avoid by: never writing `state = await ...` in an auto-dispose controller without a mounted guard between the await and the assignment.
