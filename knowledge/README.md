---
title: "Knowledge Base — Index"
type: index
tags: [index]
owner: "legacy-modernization"
confidence: high
updated: 2026-06-09
---

# Knowledge Base

This folder is the **system of record for intent and operational truth**
consumed by the `KnowledgeAgent` (see
[`/.github/copilot/copilot-agents.md`](../.github/copilot/copilot-agents.md)).

Conventions, metadata headers, naming rules, and prompt patterns are defined
in [docs/grounding.md](../docs/grounding.md).

## Layout

| Folder | Purpose |
|--------|---------|
| [`tribal/`](./tribal/)                       | SME interviews, oral history, undocumented rules. |
| [`technical-papers/`](./technical-papers/)   | Durable technology background (Struts 1, COBOL, SQL Server, batch). |
| [`runbooks/`](./runbooks/)                   | Operational procedures, incident playbooks. |

Every file in this tree MUST start with the YAML metadata header described in
[docs/grounding.md §3](../docs/grounding.md#3-metadata-header-required).
