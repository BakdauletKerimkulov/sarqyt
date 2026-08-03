---
title: Measure a Row's required width before fixing an overflow
date: 2026-08-04
work_type: bug
tags: [flutter, layout, overflow, responsive, breakpoints, testing]
confidence: medium
references: [ai_specs/archive/043-fix-section-header-overflow-spec.md,
  ai_specs/archive/045-fix-schedule-day-row-overflow-spec.md,
  ai_specs/archive/029-adaptive-design-for-shedule-screen.md]
---

## Summary
Two `RenderFlex overflowed` bugs in one session — the dashboard section header
and the create-item schedule row — both came from a `Row` whose children are
all non-flex with fixed widths. Both were initially misjudged as "breaks on
narrow screens"; measuring showed one broke on *every* phone and the other
could not be fixed by a breakpoint alone. The transferable part is the method:
probe the widget's constant required width first, then pick the layout fix.

## Reusable Insights
- **`Expanded` does not protect a `Row` from overflowing** — when the situation
  is a flex child beside fixed-width siblings, expect the siblings to win:
  non-flex children are measured first against unbounded constraints and take
  their natural width, and the flex child divides only the remainder, possibly
  `w=0.0`. Symptom is distinctive: the text collapses to zero width and wraps
  one letter per line, *and* the row still overflows.
  _Example: `outlined_section_widget.dart:97` before 043._
- **Probe the required width with a throwaway widget test before choosing a
  fix** — when a layout overflows, pump it at 320/360/375/393/430 and print
  `takeException()`, because the constant it needs tells you which fixes are
  even possible. _`ScheduleDayRow` needed 412px on every screen, so reducing
  the form's `p32` padding could never have worked; that was invisible from
  reading the code._
- **Moving a block to its own line only helps if it fits the full width** —
  after a compact-window stack, check the block against the whole content
  width, not the leftover. _In 043 the trailing was 329px against 306px of
  content, so the caller's `Row` also had to become a `Wrap`; the breakpoint
  alone left the overflow untouched._
- **Verify a layout regression test by disabling the fix, not by writing it
  first** — RED before GREEN is not enough for overflow tests because a wrong
  fixture fails for the wrong reason. _Flipping `stacked` to `false` proved the
  043 test caught the real bug; two earlier fixtures had not._
- **Probe `TextScaler`, not just viewport width** — when fixed-width children
  sit beside text that scales, the block grows with the user's font setting and
  the overflow returns. _`ScheduleDayRow` is clean at ×1.0 everywhere but
  overflows at ×1.3 on 320px and ×1.6 on 360px; `_TimeField(width: 36)` does
  not scale while the `' : '` separators do._
- **`firestore.indexes.json` is not the deployed state** — before reading app
  code for a `failed-precondition`, diff the file against
  `firebase firestore:indexes`, because an index can sit in the file
  uncommitted and undeployed for weeks. _CI (`deploy.yml`) only deploys on push
  to `main`. See `missing-composite-index-retry-loop.md` for the rest of this
  failure mode._

## Decisions
- **Compact-window `Column` over `Wrap` for the schedule row** — chose an
  explicit breakpoint over content-driven wrapping. Rationale: the row is four
  time fields plus two separators rendering `10 : 00 – 18 : 30`; `Wrap` would
  break that range at an arbitrary point. Trade-off accepted: a hard cutoff at
  600px rather than a fit-driven one.
- **`Wrap` over a breakpoint for the dashboard header actions** — the opposite
  choice, same session. Rationale: the trailing is a caller-supplied set of
  buttons with no fixed count, and it exceeded the full content width, so it
  had to break within itself. Criterion: breakpoint when the block is a
  semantic unit that must stay intact, `Wrap` when it is a list of peers.

## Pitfalls
- **A test that fails is not automatically a regression test** — symptom: the
  first 043 fixture (400px trailing) failed both before and after the fix;
  the second (300px) would not have overflowed at all, because `Expanded` just
  squeezes the title when the sibling fits. Cause: overflow needs the non-flex
  child to exceed the *whole* line, not merely the remainder. Fix: compute what
  actually triggers it, then confirm by disabling the fix. Avoid by: treating
  "RED" as "fails for the stated reason", not "fails".
- **`./scripts/gate.sh --fast` does not write the commit token** — symptom:
  green `--fast` run, then the pre-commit hook still rejects with "допуск
  протух". Cause: the script exits before the approve block when `FAST=1`.
  Fix: run the full gate before every git mutation, including after each
  commit in a series. Avoid by: budgeting one full gate run per commit.
  _(Tooling-adjacent; belongs with `tooling/gate-sh-mega-diff-commit-split.md`
  if that file is ever extended.)_
