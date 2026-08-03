---
title: Fully built feature left with no UI entry point
date: 2026-07-31
work_type: bug
tags: [flutter, widgets, dashboard, offers, testing, gate]
confidence: medium
references: [ai_specs/038-wire-flash-offer-entry-point-spec.md, 6efdc41]
---

## Summary
"Can we do X in the app?" for the one-time/flash-offer flow turned out to be
yes at every layer (dialog, controller, repository call, Cloud Function) except
the last one: nothing in the app ever constructed `CreateOneTimeOfferDialog`.
Confirmed by grepping for the constructor call, not just the class file's
existence. Fixed by adding one small standalone widget and wiring it next to
an existing sibling entry point.

## Reusable Insights
- **Before reporting "not implemented," check for an orphaned widget** — when a class/dialog/controller exists but the user-visible feature seems missing, grep for `ClassName(` (the constructor call), not just the class declaration. A hit only in its own file means it was built but never wired into any screen. _Example: `grep -rn "CreateOneTimeOfferDialog(" lib/` returned only the declaration._
- **Mirror the sibling entry point instead of inventing UI** — when wiring an orphaned feature into an existing screen, look for a structurally similar action already on that screen (same section, same trigger pattern) and match its placement/style rather than designing new UI. _Example: mirrored the existing "+ Create new" button next to the new "Flash offer" button in `dashboard_screen.dart`'s "Your surprise bags" header._
- **Extract a tiny standalone widget to keep the test cheap** — when a fix is "add one button that opens an existing dialog" on a screen with heavy provider setup (auth, business, store streams), extract the trigger into its own small public widget class in its own file. It can be pumped and tested in isolation (`ProviderScope` + `MaterialApp`, no screen-level Robot needed) instead of standing up the whole host screen's fixtures. _Example: `FlashOfferButton` tested alone in `flash_offer_button_test.dart`, never touching `DashboardScreen`'s providers._
- **`gate.sh` approval is tied to the exact working-tree sha, not just "tests passed once"** — any tree change after a green gate run (staging, branch switch, even just `git add`) invalidates the approval; `git commit` and `git push` both re-check it. Re-run `./scripts/gate.sh` immediately before each git-mutating step, not only after code edits. _Example: hit the guard twice in one session — once before commit, once before push, despite no code changes in between._

## Pitfalls
- **Two similarly-named domain concepts look like duplicates but aren't** — symptom: "one-time item" (existing, `Item` with no `WeeklySchedule`) and "flash offer" (this fix, an `Offer` created directly via `createOneTimeOffer`, bypassing `Item` and `daily-sync-offers`) sound like the same feature. Cause: no glossary entry existed for either the moment it was needed. Fix: added a `Flash offer` entry to `ai_docs/GLOSSARY.md` with an explicit `NOT` pointing at "one-time item". Avoid by: when a new UI-only term surfaces, write the glossary entry in the same change, before it gets reused elsewhere with a slightly different name.
