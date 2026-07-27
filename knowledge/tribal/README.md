---
title: "Tribal Knowledge — Index"
type: index
tags: [index, tribal]
owner: "legacy-modernization"
confidence: high
updated: 2026-06-09
---

# Tribal Knowledge

SME interviews, oral-history notes, undocumented business rules, and "why we
did it this way" context. Treated as authoritative when no design doc exists.

## What belongs here
- SME interview transcripts / summaries
- Hallway answers that explain non-obvious behavior
- Historical rationale for design decisions
- Subsystem folklore that affects engineering choices

## What does NOT belong here
- Step-by-step operations → [`../runbooks/`](../runbooks/)
- Technology background → [`../technical-papers/`](../technical-papers/)
- Speculative refactor ideas → put them in PRs or issues, not here

## Conventions
- Filenames: kebab-case, prefixed by subsystem.
  Example: `billing-rounding-rules.md`.
- Every file MUST start with the YAML metadata header from
  [docs/grounding.md §3](../../docs/grounding.md#3-metadata-header-required).
- Always include at least one entry in `sources:` (interview, memo, ticket).

## Starter template
```markdown
---
title: "<Topic>"
type: tribal
subsystem: <billing|claims|...>
tags: [<tag1>, <tag2>]
sources:
  - "SME interview: <name>, <YYYY-MM-DD>"
owner: "<team>"
confidence: medium
updated: <YYYY-MM-DD>
do_not_touch: false
---

# <Topic>

## Background

## Rule / Behavior

## Rationale

## Open questions
```
