---
title: Wire flash offer entry point
status: done
date: 2026-07-31
type: fix
severity: S
references: []
---

## Symptom
Business app has no UI entry point to create a one-time ("flash") offer. `CreateOneTimeOfferDialog`, its controller, and the backend `createOneTimeOffer` callable are fully implemented, but nothing in the app ever constructs the dialog — grepping the codebase for `CreateOneTimeOfferDialog(` returns only the class declaration.

## Root cause
The feature was built end-to-end (dialog, controller, repository call, Cloud Function) but the final wiring step — adding a button that opens the dialog — was never done. `dashboard_screen.dart:60-82` ("Your surprise bags" section) already has one entry-point pattern (`+ Create new` → `newItem` route) but nothing equivalent for the flash-offer flow.

## Fix
- **Files changed:** `lib/src/features/offers/presentation/business/flash_offer_button.dart` (new), `lib/src/features/business_console/presentation/dashboard_screen.dart`, `ai_docs/GLOSSARY.md`
- **Failing test that catches the regression:** `test/src/features/offers/presentation/business/flash_offer_button_test.dart::FlashOfferButton tapping it opens CreateOneTimeOfferDialog`
- **`ai_toolkit/` rules applied:** `gorouter.md` (modal dialogs open via `showDialog`, not routed, matching the existing `StartSellingDialog`/`ItemActionDialog` pattern), `riverpod.md` (no `ref.invalidate` after the mutation — `watchStoreActiveOffers` is a stream and updates on its own), `code-style.md` (reused existing ARB strings, no widget over ~80 lines)
- **Toolkit deviations:** none
- Added `FlashOfferButton`, a small standalone widget that opens `CreateOneTimeOfferDialog` for a given `storeId`, and wired it next to the existing "+ Create new" button in the dashboard's "Your surprise bags" section header. Also added a `Flash offer` entry to `ai_docs/GLOSSARY.md` distinguishing it from the existing "one-time item" concept (an `Item` without a `WeeklySchedule`, which is unrelated).
