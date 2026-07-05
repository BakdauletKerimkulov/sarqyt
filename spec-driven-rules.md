# Spec-Driven Development Rules (`ai_toolkit/`, `ai_docs/`, `ai_specs/`)

> **This file is the source of truth** for folder structure, file naming, metadata format, and statuses. Slash commands (`/spec`, `/refine`, `/plan`, `/work`, `/bootstrap`) implement the workflow but MUST conform to this file — they reference it instead of duplicating its rules. On conflict, this file wins.
>
> Canonical copy lives in `agentic-coding-toolkit/rules/`. Each project gets a copy in its root (via `/bootstrap`), referenced from `CLAUDE.md` / `AGENTS.md`. Any AI agent working on the project MUST read this file, then the relevant files in `ai_toolkit/` and `ai_docs/`, before planning, editing, or creating anything.

---

## 1. Three folders, three purposes

| Folder | Contains | Changes | Portable to other projects |
|---|---|---|---|
| `ai_toolkit/` | Universal engineering rules (Flutter, Riverpod, Firebase, GoRouter, code style) | Rarely — only when the stack or best practices change | Yes — copy as-is |
| `ai_docs/` | Project-specific knowledge: what THIS app is, its schema, its decisions, lessons learned while working | Grows continuously as the project evolves | No |
| `ai_specs/` | Feature specs and implementation plans | Created per feature, archived when done | No |

Decision rule for any new piece of knowledge:

1. True for ANY Flutter project? → `ai_toolkit/`
2. True for this project and stays true after the current feature ships? → `ai_docs/`
3. Describes a single change? → `ai_specs/`

---

## 2. `ai_toolkit/` — universal foundation (rarely changes)

Flat folder. One file per technology:

```
ai_toolkit/
  architecture.md    # feature-first structure, layers, widget rules
  code-style.md      # naming, formatting, lint, localization
  flutter.md         # framework versions and framework-specific rules
  riverpod.md        # provider patterns, codegen, ephemeral vs app state
  gorouter.md        # navigation patterns
  firebase.md        # universal Firebase patterns (emulators, regions, security-rules philosophy)
```

Rules:

- Nothing project-specific: no route lists, no collection names, no model fields. Each file states this explicitly and points to `ai_docs/` for project details.
- **Dependency direction is one-way.** `ai_docs/` and `ai_specs/` may reference specific `ai_toolkit/` files; `ai_toolkit/` may only reference the `ai_docs/` folder generically ("project-specific details → `ai_docs/`") — never a specific filename. Hard references would break the moment the toolkit is copied to another project. References between files inside `ai_toolkit/` are fine.
- Updated only when the stack changes (new Flutter/Riverpod major version, new package adopted) — never as part of feature work.
- Reused across projects: treat it as a portable asset, keep it generic.

---

## 3. `ai_docs/` — project knowledge (grows over time)

Flat root + one `solutions/` subfolder for accumulated lessons:

```
ai_docs/
  PROJECT.md              # what the app does, stack, feature modules, roles, key domain models
  FIRESTORE_SCHEMA.md     # collections, document shapes, field types, security-rules summary
  CLOUD_FUNCTIONS.md      # functions list, triggers, secrets, idempotency notes
  EXTERNAL_SERVICES.md    # non-obvious service choices (maps, payments) with "AI warning" notes
  TESTING.md              # what must be tested, mocking approach, commands
  solutions/
    bug-fixes/            # root-caused bugs: symptom → cause → fix → regression test
    tooling/              # CI/CD, build, environment lessons
    lessons/              # process/planning lessons (e.g. how to stage removal refactors)
```

Two kinds of content:

- **Fundamentals** (root files) — written once at project setup, edited when architecture/schema/services change. Updated **in the same PR** as the code change that invalidates them.
- **Accumulated knowledge** (`solutions/`) — added after work is done (the "compound" step): every root-caused bug, hard-won CI fix, or planning lesson becomes a short file so it is never re-discovered.

`solutions/` file format: kebab-case descriptive name; content = Symptom → Root cause → Fix (files changed, regression test) → Rule for the future.

Do NOT put here: universal patterns (→ `ai_toolkit/`), feature specs (→ `ai_specs/`), TODOs, secrets/keys, anything already answered by `pubspec.yaml` or the code itself.

---

## 4. `ai_specs/` — specs & plans

### Structure and naming

Flat folder + `archive/`. Two files per feature, sharing the same number and name:

```
ai_specs/
  README.md                    # index (see below)
  019-item-photo-crop-spec.md  # spec: refined requirements
  019-item-photo-crop-plan.md  # plan: phased implementation
  archive/                     # completed features, moved as-is
    001-.....md
```

- `NNN` — zero-padded sequence number, **never reused**, one number = one feature. Next number = highest existing (including `archive/`) + 1.
- Name — short kebab-case, 2–4 words, noun-based (`item-photo-crop`, not `add-photo-cropping-to-items`).
- Suffixes are fixed: `-spec` and `-plan` only. No other suffixes (`-impl`, `-feature`, `-fix` are not allowed).
- The original request is NOT a separate file — `/spec` records it verbatim in the spec body under `Source request`.
- Small fix may have only `NNN-name-spec.md` (with `type: fix`) and skip the plan.

### YAML frontmatter (mandatory in every spec/plan file)

```yaml
---
title: Item photo crop
status: draft        # draft | refined | approved | in-progress | done
date: 2026-07-05
type: feature        # feature | fix | refactor
---
```

- `status` transitions: `draft` → `refined` (after adversarial review) → `approved` (human sign-off) → `in-progress` → `done`.
- No code changes until the spec is `approved`.
- Statuses live ONLY in frontmatter — never as plain-text lines in the body.

### `archive/`

- When a feature reaches `status: done`: set the status, move all its files to `archive/`, update `README.md`.
- Files in `archive/` are read-only reference — never edit them.
- Active folder should contain only features currently in flight (target: 2–3).

### `README.md` index

A single table, maintained **by the agent as a rule**: whenever a spec is created, changes status, or is archived, the agent MUST update this table in the same session.

```markdown
| # | Feature | Type | Status | Date | Files |
|---|---------|------|--------|------|-------|
| 019 | Item photo crop | feature | in-progress | 2026-07-05 | spec, plan |
| 018 | Refactor create offer flow | refactor | done (archived) | 2026-07-04 | spec, plan |
```

---

## 5. Agent workflow (mandatory)

1. **Read** this file, `ai_specs/README.md`, and the relevant `ai_toolkit/` + `ai_docs/` files (always `PROJECT.md`; plus `FIRESTORE_SCHEMA.md` / `CLOUD_FUNCTIONS.md` if data is involved). Check `ai_docs/solutions/` for lessons matching the task.
2. **Research** the existing code relevant to the request — do not assume.
3. **Spec**: create `NNN-name-spec.md` (`status: draft`). Ask the human about every hidden product decision (UX, persistence, edge cases). Requirements numbered (R1, R2…) with a "Verifiable by" criterion; edge cases numbered (E1, E2…). Do not invent answers.
4. **Refine**: adversarially check the spec against the real codebase — wrong assumptions, package limitations, missing migrations. Fix the spec, set `status: refined`.
5. **Wait for approval** (`status: approved`) before writing the plan or code.
6. **Plan**: phased `NNN-name-plan.md`; each phase compiles, passes tests, and is committable on its own. Removal refactors: model change + consumer fixes = one atomic phase (see `solutions/lessons/`).
7. **Work**: implement phase by phase. After each phase: `flutter analyze`, run tests, commit.
8. **Compound & close**: capture new lessons into `ai_docs/solutions/`, update affected `ai_docs/` root files, set `status: done`, move spec files to `archive/`, update `README.md`.

Agent behavior rules:

- If a request conflicts with `ai_toolkit/` or `ai_docs/`, STOP and ask — do not silently deviate.
- If `ai_docs/` is missing needed information, ask the human, then add the answer to `ai_docs/` so it is never asked again.
- Never edit `ai_specs/archive/` or another feature's spec files.
- Never break a cross-reference: if a file mentioned in `ai_docs/` does not exist, create it or fix the reference — do not leave it dangling. If `ai_toolkit/` references a specific `ai_docs/` filename, that is a violation of the dependency rule — make the reference generic instead.

---

## 6. Flutter / Firebase specifics (every spec must answer)

**Flutter**
- Which providers/notifiers are created or changed (per `ai_toolkit/riverpod.md`); ephemeral state stays in widgets.
- Navigation changes (routes, deep links) per `ai_toolkit/gorouter.md`.
- Loading / error / empty states for every new screen or async operation.
- All user-facing strings through l10n — no hardcoded strings.
- Tests per `ai_docs/TESTING.md`.

**Firebase**
- Exact Firestore document structure with field names and types → also reflected in `FIRESTORE_SCHEMA.md`.
- Security rules reviewed on every schema change.
- Composite indexes and offline behavior.
- Cloud Functions: triggers, idempotency, secrets via `defineSecret` only.
- Data migration plan for existing users when the schema changes.

---

## 7. Bootstrap checklist (new project)

Automated by the `/bootstrap` command; manual fallback:

- [ ] Copy `ai_toolkit/` from the toolkit as-is
- [ ] Copy this file to project root
- [ ] Create `ai_docs/` root files (even if short at first) + empty `solutions/{bug-fixes,tooling,lessons}/`
- [ ] Create `ai_specs/` with `README.md` (empty table) and `archive/`
- [ ] Reference this file in `CLAUDE.md` / `AGENTS.md`: "Read `spec-driven-rules.md` before any task"
