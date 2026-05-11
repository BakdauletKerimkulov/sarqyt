---
description: Generate a full feature spec from a short description. Usage: /spec add stacked chart to history page
---

You are creating a detailed feature specification.

## Step 1: Read context
Read ALL files in:
- `ai_toolkit/guidelines/`
- `ai_docs/`

## Step 2: Research the codebase
Before asking any questions, explore the existing codebase to understand:
- Current implementation of related features
- Existing conventions, patterns, and data flow
- Packages and dependencies already in use
- What can be reused vs what needs to be built

## Step 3: Ask clarifying questions
Based on your codebase research, ask targeted questions about hidden product decisions.
Focus on decisions that YOU cannot make — UX choices, business rules, scope boundaries.
Ask all questions at once, not one by one.

## Step 4: Generate the spec
After receiving answers, create the spec file at:
`ai_specs/{NNN}-{feature-name}-spec.md`

**Naming rule:** Look at existing files in `ai_specs/` to determine the numeric prefix (`NNN`).
If the user's input references an existing file with a prefix (e.g. `001-foo.md`), reuse that prefix.
Otherwise, use the next available number (e.g. if `003-*` exists, use `004`).

Use this format:

```markdown
# Spec: {Feature Name}

Created: {date}
Status: draft

## Goal
One paragraph: what this feature achieves for the user.

## Background
Current behavior and why this change is needed.

## User Flow
Step-by-step: what the user sees and does.
1. ...
2. ...

## Requirements
### Must Have
- [ ] Requirement 1
- [ ] Requirement 2

### Nice to Have
- [ ] Optional requirement

## Technical Constraints
- Packages to use
- Architecture decisions
- Data sources

## Edge Cases
- What happens when...
- Empty states
- Error states
- Offline behavior

## Out of Scope
- Explicitly NOT doing...

## Definition of Done
- [ ] All Must Have requirements implemented
- [ ] Edge cases handled
- [ ] Tests written
- [ ] Manual QA passed
```

## Rules
- DO research the codebase first, then ask questions
- DO surface hidden decisions the user hasn't considered
- DO NOT make product decisions — ask the user
- DO NOT write code — only the spec
- Feature request: $ARGUMENTS
