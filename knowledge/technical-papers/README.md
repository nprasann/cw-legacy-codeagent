---
title: "Technical Papers — Index"
type: index
tags: [index, technical-paper]
owner: "legacy-modernization"
confidence: high
updated: 2026-06-09
---

# Technical Papers

Durable, technology-level background material. Reference content that does
not change with each release: framework lifecycles, language quirks,
database engine behaviors, batch patterns.

## Recommended starter topics
- `struts1-action-lifecycle.md` — request flow through Struts 1.0.
- `struts1-actionform-pitfalls.md` — common bugs and anti-patterns.
- `cobol-comp3-primer.md` — packed-decimal representation gotchas.
- `cobol-goto-vs-perform.md` — refactoring guidance.
- `sqlserver-non-normalized-patterns.md` — wide-table conventions and risks.
- `sqlserver-cursor-vs-set-based.md` — when cursors are unavoidable.
- `offline-batch-checkpoint-restart.md` — idempotency and restartability.
- `ebcdic-ascii-pitfalls.md` — cross-platform encoding hazards.

## Conventions
- Filenames: kebab-case, technology-prefixed.
- Every file MUST start with the YAML metadata header from
  [docs/grounding.md §3](../../docs/grounding.md#3-metadata-header-required).
- Keep papers **vendor-neutral** where possible; cite primary sources.

## Starter template
```markdown
---
title: "<Topic>"
type: technical-paper
subsystem: n/a
tags: [<tech-tags>]
sources:
  - "<spec / book / vendor doc>"
owner: "<team>"
confidence: high
updated: <YYYY-MM-DD>
do_not_touch: false
---

# <Topic>

## Overview

## Key concepts

## Common pitfalls

## References
```
