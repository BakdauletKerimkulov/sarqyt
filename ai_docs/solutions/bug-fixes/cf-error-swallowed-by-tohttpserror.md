---
title: CF error swallowed by generic toHttpsError fallback
date: 2026-07-06
work_type: bug
tags: [cloud-functions, error-handling, repository-pattern, toHttpsError, items]
confidence: medium
references: [ai_specs/023-fix-delete-item-error-plan.md, 94dc07f]
---

## Summary
The `toHttpsError` fallback in Cloud Functions discarded the original error message for any non-`AppError` exception, replacing it with "Unexpected server error". This made Firestore SDK errors (missing indexes, permission errors) invisible to users and developers without CF log access. Fixed the fallback to propagate `error.message` and moved the controller's direct `FirebaseFunctions.instance` call into the repository layer.

## Reusable Insights
- **Always propagate the original message in CF error mappers** — when a catch-all maps unknown errors to `HttpsError`, include `error.message` (or `String(error)` for non-Error values). Generic messages destroy debuggability. _Example: `functions/src/app/error.ts:23`._
- **Controllers must never import `cloud_functions` directly** — CF calls belong in repositories per `architecture.md`. If you see `FirebaseFunctions.instance` in a controller or widget, it's a violation. The `updateItem` method in the same controller was already correct — use it as the pattern. _Example: `settings_content_controller.dart:22-31` (correct) vs `:68-78` (was wrong)._
- **Existing `humanReadableError` already extracts `FirebaseFunctionsException.message`** — surfacing a real message in the CF automatically reaches the user without any Dart-side error-mapping changes. Check the error display pipeline before adding new error mapping. _Example: `lib/src/utils/async_value_ui.dart:37-43`._
- **No `kCloudFunctionsRegion` exists yet — all repos use `FirebaseFunctions.instance`** — `firebase.md` says to use `instanceFor(region:)`, but migrating one repo while six others use `.instance` creates inconsistency. Defer to a dedicated cleanup pass. Track as spec N1.

## Pitfalls
- **vitest discovers `src/**/*.test.ts` by default without config** — no `vitest.config.ts` was needed. The risk flagged in the plan (vitest not finding tests) did not materialize. However, the pre-existing `firestore-rules.test.ts` in `test/` always fails without the emulator — `npm test` exit code is always 1. Judge test results by suite, not exit code.
- **Repository method named `id` vs controller using `itemId`** — the `deleteItem` signature uses `{required ItemID id}` but the controller variable is `itemId`. Passing `itemId: itemId` fails; must be `id: itemId`. Always check the target method's parameter names before wiring up delegation.
