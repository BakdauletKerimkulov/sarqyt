---
title: Fix item delete navigation — pop after deletion
status: done
date: 2026-07-08
type: fix
severity: S
references: []
---

## Symptom
After deleting an item from the Settings tab of `ItemScreen`, the user is stuck on a "No item found" screen instead of being navigated back to the previous screen.

## Root cause
The `context.pop()` call lived in `_DeleteItemButton` (`settings_content.dart:139`). When `deleteItem` fires the Cloud Function, Firestore deletes the document and the `itemStreamProvider` stream emits `null` before the CF call returns. This causes `ItemScreen` to rebuild, removing `SettingsContent` and `_DeleteItemButton` from the widget tree. The `mounted` check returns `false`, so `context.pop()` never executes.

## Fix
- **Files changed:** `lib/src/features/items/presentation/item_screen/item_screen.dart`, `lib/src/features/items/presentation/item_screen/settings_content.dart`
- **Failing test that catches the regression:** `test/features/items/item_screen_delete_test.dart::calls context.pop when item stream emits null after data`
- **`ai_toolkit/` rules applied:** `riverpod.md` (ref.listen for side effects), `gorouter.md` (context.pop, never Navigator.pop), `code-style.md` (no BuildContext across async gap)
- **Toolkit deviations:** none
- **Description:** Added `ref.listen` on `itemStreamProvider` in `ItemScreen.build()` to pop when the item transitions from non-null to null (i.e. deleted). Removed the now-redundant `context.pop()` from `_DeleteItemButton._onDeletePressed()`. The listener is at `ItemScreen` level which stays mounted regardless of which tab content is shown.
