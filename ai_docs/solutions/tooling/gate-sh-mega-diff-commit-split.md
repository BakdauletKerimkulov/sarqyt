---
title: Splitting a mega-diff into commits under the gate.sh approval hook
date: 2026-07-30
work_type: tooling
tags: [git, commit, gate, hooks, dart-format, firestore-rules]
confidence: high
references: [scripts/gate.sh, .claude/hooks/guard-bash.sh, PR #14]
---

## Summary
A working tree had accumulated 142 unrelated changed files (toolkit sync, iOS entitlements, a security-rules fix, and a repo-wide `dart format` reflow) that needed splitting into 6 reviewable commits and pushing under this repo's `gate.sh`-backed commit guard. Two non-obvious mechanics of the guard hook cost retries and are worth recording before the next large-diff session.

## Reusable Insights
- **Before assuming "unrelated diff spans" means bad hygiene, check if it's one mechanical cause** — when a huge diff touches nearly every file with small hunks, diff a sample file and grep `analysis_options.yaml`/lint config changes first; it's often a single formatter/lint config bump fanning out via `dart format`, not many unrelated edits, and belongs in one `style:` commit rather than fine-grained per-directory splitting.
- **A "no-op" reformat is not always no-op — grep for real logic changes hiding in the sweep** — run `git diff -w` per changed file and flag files with non-whitespace residue; in this session that surfaced a genuine security fix (`firestore.rules` `isAdmin()` using `.get('role','')` instead of direct field access, plus a rules-test flip from `assertSucceeds` to `assertFails`) buried inside what looked like a pure formatting pass.
- **`gate.sh`'s approval hash is representation-sensitive, not just content-sensitive** — the hook hashes `git diff HEAD -- .` plus `cat` of untracked files; a brand-new untracked file changes from raw-content hashing to unified-diff hashing the moment it's `git add`-ed, changing the hash even though file content is unchanged. Always **stage the exact fileset for a commit first, then run `./scripts/gate.sh`, then commit immediately** — never stage after gating.
- **`./scripts/gate.sh --fast` does not write `.gate/approved_sha`** — the fast path (tier 0 only: format/analyze/custom_lint/flutter test) exits before reaching the approval-write block at the end of the script; only a full run (including `functions:lint`, `functions:build`, `rules+functions:test` via the Firestore emulator) writes the approval the commit/push hook checks for. Budget for a full gate run before *every* commit and before `git push`, since HEAD moving invalidates the previous approval automatically.
- **`git push` is gated the same as `git commit` in this repo** — `guard-bash.sh` matches `git\s+(commit|push)\b` with the same approved-sha check, so pushing right after the last commit still needs a fresh gate run even if nothing changed since the last commit's gate pass (HEAD moved).

## Decisions
- **Grouped commits by feature/functional intent, not by directory** — iOS entitlements and `Info.plist` push-capability changes went into the `feat(notifications)` commit rather than a generic `chore(ios)` bucket, and the raw feature-request note + spec status flip went into `docs(notifications)`, because they're semantically part of the notifications work already in progress on the branch. Trade-off: required reading each file's diff content instead of doing a fast path-prefix split.
- **Split the firestore.rules security fix into its own `fix(orders)` commit** — separate from both the toolkit-sync chore and the format sweep it was sitting next to, since it's a real behavior/security change (denies store staff direct order-status writes) that deserves independent review and a clean revert point.

## Pitfalls
- **Pitfall:** `git commit` blocked with "Допуск протух" (approval stale) immediately after a green `gate.sh` run, even though only `git add` had run in between. **Cause:** staging a previously-untracked file changes how the guard's hash function represents it (raw `cat` → unified diff), so the stored `approved_sha` no longer matches, despite identical file content. **Fix:** re-run `./scripts/gate.sh` after staging, immediately before committing. **Avoid by:** always finalize the staged set *before* invoking the gate for that commit, not after.
