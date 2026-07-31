---
title: Firestore rules block review submission (rating vs storeRating/offerRating)
status: done
date: 2026-07-31
type: fix
severity: S
references: [ai_specs/034-order-flow-notifications-plan.md#G4]
---

## Symptom
`ReviewController.submitReview` → `ReviewRepository.submitReview` writes `storeRating` and `offerRating` to `reviews/{id}`. `firestore.rules` required a single `rating` field (number 1–5) on `create`/`update`. Since the app never sends `rating`, every review submission was denied by the rules engine — the review flow was broken in production, not only for QA-5 in the order-flow-notifications plan.

## Root cause
The `Review` domain model (`lib/src/features/review/domain/review.dart`) was migrated from a single `rating` field to split `storeRating`/`offerRating` (a legacy-fallback reader `_readOfferRating` even exists for old `foodRating` docs), but `firestore.rules:155-166` was never updated to match — it still validated the old single-`rating` schema. `functions/test/firestore-rules.test.ts` also still tested against the old schema, masking the mismatch.

## Fix
- **Files changed:** `firestore.rules`, `functions/test/firestore-rules.test.ts`
- **Failing test that catches the regression:** `functions/test/firestore-rules.test.ts > reviews > allows creating a review with own userId` (and `> allows the author to update their review text`), run via `firebase emulators:exec --only firestore,auth 'cd functions && npx vitest run test/firestore-rules.test.ts -t reviews'`
- **`ai_toolkit/` rules applied:** `testing.md` (rules tested against real emulator, as an ordinary authenticated user, not superuser)
- **Toolkit deviations:** none — security rules change explicitly requested by user via `/fix`
- **Description:** Updated `firestore.rules` reviews `create`/`update` blocks to validate `storeRating` and `offerRating` (both numbers 1–5) instead of the no-longer-written `rating` field, matching the app's actual write shape. Updated `functions/test/firestore-rules.test.ts` fixtures/assertions to the real schema and added boundary tests for both rating fields. No Dart changes needed. Also unblocks the QA-5 verification step for the order-flow-notifications review-prompt feature.
