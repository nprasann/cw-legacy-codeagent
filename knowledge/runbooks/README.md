---
title: "Runbooks — Index"
type: index
tags: [index, runbook]
owner: "legacy-modernization"
confidence: high
updated: 2026-06-09
---

# Runbooks

Operational procedures and incident playbooks. Step-numbered, prescriptive,
and unambiguous. The `KnowledgeAgent` treats runbooks as the **highest
priority** grounding source for operational questions.

## What belongs here
- How to start/stop/restart a job or service.
- Failure-by-failure recovery procedures.
- Triage trees for common incident classes.
- Escalation contacts and on-call expectations.

## Conventions
- Filenames: kebab-case, job/service-prefixed.
  Example: `nb-post-nightly.md`, `sql-deadlock-triage.md`.
- Use numbered steps. Each step must be independently runnable or clearly
  marked as continuation.
- Include explicit **preconditions**, **expected results**, and **rollback**.
- Every file MUST start with the YAML metadata header from
  [docs/grounding.md §3](../../docs/grounding.md#3-metadata-header-required).

## Starter template
```markdown
---
title: "<Job or Procedure>"
type: runbook
subsystem: <billing|claims|...>
tags: [batch, incident]
sources:
  - "<ticket / postmortem / SOP>"
owner: "<on-call team>"
confidence: high
updated: <YYYY-MM-DD>
do_not_touch: false
---

# <Job or Procedure>

## Purpose

## Preconditions

## Steps
1. ...
2. ...

## Expected results

## Failure modes & recovery
| Symptom | Likely cause | Action |
|---------|--------------|--------|

## Rollback

## Escalation
```
