---
title: Stream race unmounts widget before async pop
date: 2026-07-08
work_type: bug
tags: [riverpod, gorouter, stream, navigation, async, widget-lifecycle]
confidence: medium
references: [ai_specs/025-fix-item-delete-nav-spec.md, 6edeeb2]
---

## Summary
Deleting a Firestore document while a stream provider watches it causes the stream to emit null before the Cloud Function call returns. If the navigation callback (`context.pop`) lives in a child widget that depends on the stream data, the child is unmounted by the rebuild and the pop never executes. Fix: move the navigation side-effect to the nearest stable ancestor via `ref.listen`.

## Reusable Insights

- **Never place post-mutation navigation in a widget that the mutation's side-effects can unmount.** When a Firestore stream watches a document and a CF deletes it, the stream fires before the CF future completes. Any widget rendered conditionally on that stream's data will be gone by the time `await` resumes. _Example: `_DeleteItemButton` was removed from the tree because `ItemScreen` switched to "No item found" text._

- **Use `ref.listen` at the nearest stable ancestor for deletion-triggered navigation.** The ancestor stays mounted regardless of which child content is shown. Listen for the data transition (non-null → null with `hasValue`) and pop there. _Example: `ItemScreen.build()` listens to `itemStreamProvider` and pops when `prev.value != null && next.value == null`._

- **Guard stream-to-null transitions with both `hasValue` and previous-value checks.** A bare `value == null` check would also fire during loading (no data yet). The correct guard is: `prev != null && prev.hasValue && prev.value != null` (had data) AND `next.hasValue && next.value == null` (data confirmed gone, not just loading).

## Pitfalls

- **`mounted` check silently swallows the navigation.** Symptom: user stuck on "No item found" after delete. Cause: `if (!mounted) return` exits before `context.pop()` because the stream-driven rebuild unmounted the widget during `await deleteItem()`. Fix: move the pop responsibility up to a stable ancestor. Avoid by: any time an async method in a child widget triggers a mutation whose side-effects can rebuild the parent, the post-mutation navigation belongs in the parent, not the child.

- **Lottie animations prevent `pumpAndSettle` in widget tests.** Symptom: test hangs indefinitely. Cause: `AsyncValueWidget` uses a Lottie animation for loading state, which never completes. Fix: pre-emit data via the stream controller so the provider skips the loading state, or use `pump()` with explicit durations instead of `pumpAndSettle`.
