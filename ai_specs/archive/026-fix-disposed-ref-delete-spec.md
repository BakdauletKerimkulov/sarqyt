---
title: Fix disposed Ref in SettingsContentController
status: done
date: 2026-07-10
type: fix
severity: S
references: []
---

## Symptom
When deleting an item, the app throws `Cannot use the Ref of settingsContentControllerProvider after it has been disposed` — the Cloud Function `deleteItem` completes after the auto-dispose controller's widget unmounts (due to navigation or stream-driven rebuild), and the `state = await AsyncValue.guard(...)` assignment writes to a disposed Ref.

## Root cause
All three async methods in `SettingsContentController` (`updateItem`, `updateItemImage`, `deleteItem`) assign `state` directly from `AsyncValue.guard()` without a `_mounted` check after the async gap. This violates the Riverpod toolkit convention (`riverpod.md → _mounted check after await`). When the screen navigates away before the future resolves, the auto-dispose provider is disposed and the post-await `state =` throws.

Root location: `settings_content_controller.dart:72` (deleteItem), same pattern at lines 26 and 38.

## Fix
- **Files changed:** `lib/src/features/items/presentation/item_screen/settings_content_controller.dart`
- **Failing test that catches the regression:** `test/features/items/settings_content_controller_test.dart::deleteItem does not throw when provider is disposed before future completes`
- **`ai_toolkit/` rules applied:** `riverpod.md` — `_mounted` guard pattern for auto-dispose AsyncNotifier controllers
- **Toolkit deviations:** none
- Added `_mounted` getter per toolkit pattern. Changed all three async methods to capture `AsyncValue.guard()` result in a local variable and only assign to `state` if `_mounted` is true.
