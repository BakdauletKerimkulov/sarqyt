---
title: Fix missing Firestore composite indexes for item reviews and current offer
status: done
date: 2026-08-03
type: fix
severity: S
references: [ai_specs/archive/043-fix-section-header-overflow-spec.md]
---

## Symptom

The reviews tab of the item screen showed "Operation failed. Try again" instead of the
ratings summary and review list. Separately, the business dashboard logged a
`[cloud_firestore/failed-precondition] The query requires an index` error for the
`offers` collection.

## Root cause

Two Firestore queries had no composite index backing them in the live project.

`ReviewRepository.watchItemReviews` (`lib/src/features/review/data/review_repository.dart:65`)
runs `reviews.where('itemId', isEqualTo: …).orderBy('createdAt', descending: true)`,
which needs `reviews(itemId ASC, createdAt DESC)`. That index had been added to the
working copy of `firestore.indexes.json` but never committed (absent from `HEAD`) and
therefore never deployed. Firestore answered `failed-precondition`, which
`_firestoreErrorMessage` (`lib/src/utils/async_value_ui.dart:92`) maps to the opaque
string `'Operation failed. Try again'` — indistinguishable in the UI from a network
failure. Security rules were not involved: `firestore.rules:153` grants
`allow read: if true`, so a rules problem would have surfaced as "Access denied".

`BusinessOfferRepository.watchCurrentOfferForItem`
(`lib/src/features/offers/data/business_offer_repository.dart:36`) filters on
`storeId`, `productId`, `status` and a range on `pickupEndTime`, needing
`offers(storeId, productId, status, pickupEndTime)`. That index was missing from both
the file and the project.

Diffing `firestore.indexes.json` against `firebase firestore:indexes` on
`sarqyt-1ab95` confirmed exactly one local-but-undeployed entry (the reviews one) and
made the offers gap visible.

## Fix

- **Files changed:** `firestore.indexes.json`
- **Failing test that catches the regression:** none — see below
- **`ai_toolkit/` rules applied:** `firebase.md` (indexes declared in
  `firestore.indexes.json`, equality fields before the range field)
- **Toolkit deviations:** `testing.md` requires a regression test for every bugfix.
  Deliberately skipped: the application code is correct and the defect lives in the
  gap between the committed index config and the deployed project state. The Firestore
  emulator does not require composite indexes, so any such test passes regardless of
  the file's contents and would give false confidence. The real check is diffing local
  indexes against `firebase firestore:indexes`, recorded under Verification below.

Added the missing `offers(storeId, productId, status, pickupEndTime)` index and
normalized a stray dangling comma left in the file next to the reviews entries. The
`reviews(itemId, createdAt)` index was already present in the file and only needed
deploying.

## Deployment

Indexes ship through CI, not by hand: `.github/workflows/deploy.yml` runs
`firebase deploy --only functions,firestore,storage`, and the `firestore` target
covers both rules and `firestore.indexes.json` (see `firebase.json`). That workflow
triggers only on `push` to `main`, so these indexes go live when the branch merges —
plus a few minutes for Firestore to build them. A manual
`firebase deploy --only firestore:indexes` is only needed to verify the fix before
the merge; it is additive and does not conflict with the later CI deploy.

## Verification

Dump the deployed indexes and compare `(collectionGroup, fields minus __name__)`
against `firestore.indexes.json`; the "local but not deployed" set must be empty:

```
firebase firestore:indexes > /tmp/deployed.json
```

Then, once the indexes report `READY` rather than `BUILDING`: the item screen's
reviews tab renders the aggregate and list (or the legitimate empty state "Not enough
reviews to show a rating"), and the `failed-precondition` error for `offers`
disappears from the dashboard logs.

## Known limitation

Reviews written before the `itemId` field existed do not carry it
(`lib/src/features/review/domain/review.dart:28` — "Absent on reviews created before
this field existed"), so they will not appear on an item's reviews tab even with the
index deployed. Backfilling `itemId` from `orders/{orderId}` is a data migration and
was deliberately left out of scope.

## Lesson

Editing `firestore.indexes.json` without deploying produces a `failed-precondition`
that the UI renders as a generic "Operation failed" — the same text a flaky network
produces. When that string appears, diff local indexes against the deployed ones
before reading any application code.
