---
title: Fix schedule day row overflow in the create-item form
status: done
date: 2026-08-04
type: fix
severity: M
references: [ai_specs/029-adaptive-design-for-shedule-screen.md, ai_specs/archive/043-fix-section-header-overflow-spec.md]
---

## Symptom

In the create-item form the weekly schedule editor rendered each weekday as a row that
ran off the right edge of the screen, marked with the yellow-and-black overflow stripe.
It happened on every phone size, not just narrow ones: measured at 156px past the edge
on a 320px screen, 101px on 375px, and still 46px on a 430px "Pro Max" class device.
The end-time fields were the part pushed out of view.

## Root cause

`lib/src/features/items/presentation/common/schedule_day_row.dart:103` laid the day out
as a single flat `Row`: a `SizedBox(width: 100)` day name, a `Switch`, a `Spacer`, and
four `_TimeField(width: 36)` widgets separated by text. Every child is non-flex with a
fixed width, so the row demands a constant 412px of content width regardless of the
viewport. The create-item form (`item_create/create_item_screen.dart:147`) wraps the
whole page in `EdgeInsets.symmetric(horizontal: Sizes.p32)`, leaving 256–366px on phone
widths. The `Spacer` cannot help — with the children already over budget there is no
free space to distribute. The widget never had a breakpoint; it was written against
desktop-width assumptions, and the sibling `DayRow` on the item screen had since gained
a compact layout while this one did not.

## Fix

- **Files changed:** `lib/src/features/items/presentation/common/schedule_day_row.dart`
- **Failing test that catches the regression:**
  `test/src/features/items/presentation/common/schedule_day_row_test.dart` —
  `ScheduleDayRow fits the screen` (verified RED at 320/375/430px with overflows of
  156/101/46 pixels)
- **`ai_toolkit/` rules applied:** `code-style.md` (responsive branching on
  `Breakpoints.compact` via `MediaQuery.sizeOf` rather than pixel tuning; no
  `Widget _buildX()` — the time block is a local variable, mirroring how `DayRow`
  handles `salesWindow`; `gapH8` instead of a raw number), `testing.md` (regression test
  required)
- **Toolkit deviations:** none

The four time fields and their separators moved into a single `timeRange` row built once
per `build`. On a compact window it renders on its own line beneath the day name and
switch; at every other size it stays inline in the original row. This is the same pattern
`DayRow` (`item_screen/weekly_schedule_card.dart:79`) already uses for its sales window,
so the two schedule widgets now behave consistently. A fourth test pins the wide-window
layout — day name and time fields must stay vertically centred on one band — so the
inline case cannot regress unnoticed.

## Known limitation — large system fonts

The time block is 251.75px wide at the default text scale, against 256px of content on a
320px screen: 4.25px of slack. `_TimeField` has a hardcoded `width: 36` that does not
scale, while the `' : '` and `'–'` separators do, so the block grows with the user's font
setting and overflows again:

| Screen | ×1.0 | ×1.3 | ×1.6 |
|--------|------|------|------|
| 320    | OK   | 25px | 55px |
| 360    | OK   | OK   | 15px |
| 375    | OK   | OK   | OK   |

This predates the fix and is out of scope here: closing it means deciding how time entry
should behave under accessibility scaling — shrink the fields, let them wrap, or put the
block behind a horizontal scroll — which is a product decision, not a layout bug. It
needs its own spec.

## Relation to 029

`ai_specs/029-adaptive-design-for-shedule-screen.md` asked for an adaptive schedule
widget. Its two halves are now both done: `DayRow` on the item screen was already
adaptive, and this fix covers `ScheduleDayRow` in the create-item form. 029 stays
`draft` — the large-font case above is the part of "convenient on a phone" it does not
yet cover.
