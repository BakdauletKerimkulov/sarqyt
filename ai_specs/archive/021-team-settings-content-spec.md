---
title: Wire team list into settings Team tab
status: done
date: 2026-07-06
type: refactor
severity: M
references: []
---

## Symptom
The "Team" tab on the business Settings screen showed a static "Coming soon" placeholder instead of actual team member data. The working team list code already existed in `team_list_screen.dart` but was not connected to the settings tab.

## Root cause
`TeamSettingsContent` was a `StatelessWidget` with hardcoded placeholder UI. It did not watch any providers or display real data, even though `storeShipsByStoreIdProvider` and `InviteMemberDialog` were already available.

## Fix
- **Files changed:** `lib/src/features/business_console/presentation/settings_screen.dart`
- **Failing test that catches the regression:** `test/features/business_console/team_settings_content_test.dart::shows team member names from provider`
- **`ai_toolkit/` rules applied:** `riverpod.md` (ref.watch in build), `code-style.md` (ConsumerWidget, extracted widget class), `architecture.md` (presentation imports data providers)
- **Toolkit deviations:** none
- **One-paragraph description of the change:** Replaced the placeholder `TeamSettingsContent` with a `ConsumerWidget` that watches `storeShipsByStoreIdProvider` via `currentStoreShipProvider.storeId`, renders team members in a `ListView` with `_TeamMemberTile`, and includes an "Invite" button that opens `InviteMemberDialog`.
