---
description: Generate an implementation plan from a spec. Usage: /plan ai_specs/offer-map/spec.md
---

You are creating a phased implementation plan from a feature spec.

## Step 1: Read context
Read ALL files in:
- `ai_toolkit/guidelines/`
- All `ai_docs/` files referenced in the spec
- The spec file: $ARGUMENTS

## Step 2: Generate the plan
Save the plan next to the spec file, using the same numeric prefix:
`ai_specs/{NNN}-{feature-name}-plan.md`

**Naming rule:** Extract the numeric prefix and feature name from the spec file path (e.g. `ai_specs/001-foo-spec.md` → `ai_specs/001-foo-plan.md`).

Use this format:

```markdown
# Plan: {Feature Name}

Source: {spec file path}
Created: {date}

## Overview
One paragraph: what will be built and how.

## Stages

### Stage 1: {Name}
**Goal:** What this stage achieves
**Files to create/modify:**
- `path/to/file.dart` — what it does
**Steps:**
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
**Verification:** How to confirm this stage works

### Stage 2: {Name}
...

## Firestore Changes
New collections, fields, indexes, or security rules needed.
(Skip if none)

## Cloud Functions
New or modified functions.
(Skip if none)

## Test Coverage
What should be tested and how.

## Risks
Anything uncertain or potentially problematic.

## Out of Scope
Carried from spec — do NOT implement these.
```

## Rules
- 3–7 steps per stage, small enough to review in one sitting
- Each stage must be independently verifiable
- Do NOT write code — only the plan
- Do NOT add anything marked Out of Scope in the spec
- Do NOT exceed the spec — if something isn't in the spec, don't plan it
- Order stages so earlier stages don't depend on later ones
