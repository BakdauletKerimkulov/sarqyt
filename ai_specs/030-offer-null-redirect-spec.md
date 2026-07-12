---
title: Redirect to home when offer is deleted (null)
status: done
date: 2026-07-12
type: fix
severity: S
references: []
---

## Symptom
When an offer is deleted while the user is viewing the OfferScreen, the Firestore stream emits `null` and the user sees a dead-end "Offer not found" screen with no automatic navigation away.

## Root cause
`offer_screen.dart:72-80` — the `data` callback in `AsyncValueWidget` renders a static "not found" widget when offer is `null`, with no reactive redirect. The screen has no `ref.listen` to detect the transition from a valid offer to null and trigger navigation.

## Fix
- **Files changed:** `lib/src/features/offers/presentation/offer_screen/offer_screen.dart`
- **Failing test that catches the regression:** `test/features/offers/offer_screen_redirect_test.dart::navigates to home when offer stream emits null`
- **`ai_toolkit/` rules applied:** `riverpod.md` (ref.listen for side effects), `gorouter.md` (navigate by name)
- **Toolkit deviations:** none
- **One-paragraph description of the change** Added `ref.listen` on `offerStreamProvider(offerId)` in `OfferScreen.build()`. When the previous value was non-null and the next value is `null` (and not loading), the screen navigates to `ClientRoute.home` via `context.goNamed`. The existing null-check fallback widget is kept as a safety net.
