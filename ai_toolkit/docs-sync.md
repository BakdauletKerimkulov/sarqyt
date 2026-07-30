# Documentation Sync

_Часть общей базы agentic-coding-toolkit. Правь в базе, не в проекте — локальные правки затрёт sync._

Stale docs are worse than no docs — an agent reading them acts on a false picture and produces confidently wrong code.

A task that changes any of the following is **not complete** until the matching doc is updated in the same change:

| Change | Update |
|---|---|
| Table/collection, field, access rule, RPC | `ai_docs/` data model doc |
| Server function added or changed (contract, limits, response shape) | `ai_docs/` backend functions doc |
| Route added or changed | `ai_docs/` routing section |
| New convention or hard-won lesson that holds for any project on this stack | The relevant `ai_toolkit/` file — **in the toolkit base**, not the project copy |
| Root-caused bug, CI fix, or planning lesson worth keeping | `ai_docs/solutions/` via `/compound` |

Review check: does the diff touch the data model, server functions, or routes while `ai_docs/` is untouched? If yes — flag it as a blocking finding.

Which folder a piece of knowledge belongs in is decided by `spec-driven-rules.md` § 1. The short form: true for any project on this stack → `ai_toolkit/`; true for this project after the feature ships → `ai_docs/`; describes one change → `ai_specs/`.
