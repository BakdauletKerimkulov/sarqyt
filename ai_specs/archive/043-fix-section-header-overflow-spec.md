---
title: Fix section header overflow on compact screens
status: done
date: 2026-08-03
type: fix
severity: M
references: [ai_specs/029-adaptive-design-for-shedule-screen.md, 6efdc41]
---

## Symptom

On the business dashboard opened on a phone (content width 306px, locale ru), the
"Your surprise bags" section header collapsed to zero width and wrapped one letter
per line into a 448px-tall column, with a `RenderFlex overflowed by 23 pixels on the
right` stripe next to it. The section became unreadable and the header actions were
partly off-screen.

## Root cause

`lib/src/common_widgets/outlined_section_widget.dart:97` laid the header out as
`Row(children: [Expanded(Text), trailing])`. In a `Row` the non-flex child is measured
first against unbounded constraints and takes its natural width; the flex child divides
what is left. The dashboard's `trailing` grew to two `TextButton.icon` widgets
(`FlashOfferButton` at 216.4px, added in 6efdc41, plus "create new" at 112.7px = 329.1px)
which exceeds the 306px content width on its own. `Expanded` was therefore laid out with
`w=0.0` and the row still overflowed by 23px. The layout assumed the trailing widget is
always narrow enough to sit beside the title — true until the second button was added.
The identical latent bug existed in the non-sliver twin at line 49.

## Fix

- **Files changed:** `lib/src/common_widgets/outlined_section_widget.dart`,
  `lib/src/features/business_console/presentation/dashboard_screen.dart`
- **Failing test that catches the regression:**
  `test/src/common_widgets/outlined_section_widget_test.dart` —
  `section header on a compact viewport` (both cases; verified RED before the fix with
  `A RenderFlex overflowed by 59/57 pixels on the right`)
- **`ai_toolkit/` rules applied:** `code-style.md` (responsive branching via
  `WindowSize.fromWidth()` + `Breakpoints` rather than pixel tuning; `MediaQuery.sizeOf`;
  widget class instead of a `_buildX()` method; `Sizes`/`gapH8` instead of raw numbers),
  `testing.md` (a bugfix is not done without a regression test)
- **Toolkit deviations:** none

Both header classes now share a private `_SectionHeader` widget. On a compact window
with a trailing widget present it stacks the title above the trailing widget in a
`Column`; at every other size it keeps the previous `Row`. Stacking alone is not enough
when the actions are wider than the whole content width, so the dashboard's trailing
changed from a `Row` to a `Wrap`, letting the two buttons break onto a second run when
the line runs out. On wide windows the `Wrap` receives unbounded width and renders as a
single line exactly as before.

## Follow-up (not done here)

`dashboard_screen.dart` pads every section with `Sizes.p32` horizontally, which costs
64px of a 375px phone and aggravates any narrow-screen layout. Left untouched as out of
scope; belongs with the adaptive-design work tracked in 029.
