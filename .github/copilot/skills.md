# Copilot Skills — Legacy Modernization Copilot

> Reusable, composable skills consumed by the agents defined in
> [`copilot-agents.md`](copilot-agents.md).
>
> Structure follows patterns from [github/awesome-copilot](https://github.com/github/awesome-copilot).
> Each skill is **agent-agnostic** and may be invoked individually or as part
> of a multi-agent workflow.

---

## Skills Registry

| # | Skill | Primary Consumer(s) | Category |
|---|-------|---------------------|----------|
| 1 | [Legacy Code Explanation](#1-legacy-code-explanation) | LegacyCodeAgent | Comprehension |
| 2 | [COBOL Flow Analysis](#2-cobol-flow-analysis) | LegacyCodeAgent | Comprehension |
| 3 | [Struts 1 Request Lifecycle Analysis](#3-struts-1-request-lifecycle-analysis) | LegacyCodeAgent | Comprehension |
| 4 | [Batch Job Analysis](#4-batch-job-analysis) | LegacyCodeAgent, ReviewAgent | Comprehension |
| 5 | [SQL Server Legacy Schema Analysis](#5-sql-server-legacy-schema-analysis) | LegacyCodeAgent, ReviewAgent | Comprehension |
| 6 | [Code Review (Legacy-Focused)](#6-code-review-legacy-focused) | ReviewAgent | Quality |
| 7 | [Knowledge Grounding](#7-knowledge-grounding) | KnowledgeAgent (all) | Retrieval |
| 8 | [Modernization Suggestions](#8-modernization-suggestions) | ReviewAgent | Strategy |

---

## 1. Legacy Code Explanation

### Description
Produce a faithful, plain-language explanation of a legacy source artifact —
Struts Action, COBOL program, stored procedure, JSP, batch script — at a level
appropriate for a modern developer with no prior exposure.

### Input Format
```yaml
artifact_path: string           # repo-relative path
language: java | cobol | tsql | jsp | jcl | xml
scope: file | function | section
depth: summary | walkthrough | line-by-line
audience: junior | mid | senior
include_modern_analogy: true | false
```

### Output Expectations
- **Summary**: 1-3 sentences, no jargon.
- **Inputs / Outputs / Side Effects**.
- **Control flow**: numbered steps or mermaid diagram.
- **Legacy-isms**: deprecated patterns called out with brief rationale.
- **Modern analogy** (if requested): how the same intent would be expressed today.
- **Open questions**: explicit list of things the code alone cannot answer.

---

## 2. COBOL Flow Analysis

### Description
Specialized comprehension skill for COBOL programs. Produces a structured map
of divisions, sections, paragraphs, `PERFORM`/`CALL` graphs, file I/O,
copybook usage, and side effects.

### Input Format
```yaml
program_path: string             # e.g., src/cobol/PROC1234.CBL
copybook_paths: [string]         # optional, auto-discovered if omitted
trace_target: section | paragraph | full
include_call_graph: true | false
flag_goto_density: true | false
```

### Output Expectations
- **Division map**: IDENTIFICATION / ENVIRONMENT / DATA / PROCEDURE summary.
- **Copybook table**: name, purpose, record layout summary.
- **Call graph**: `PERFORM` / `CALL` relationships (mermaid).
- **File I/O table**: file name, mode, record format, lifecycle.
- **GO TO hotspots**: density score, refactor candidates.
- **Side effects**: writes, deletes, external calls, EXEC SQL blocks.
- **Risk callouts**: implicit moves, COMP-3 misuse, EBCDIC pitfalls.

---

## 3. Struts 1 Request Lifecycle Analysis

### Description
Trace a single HTTP request through an Apache Struts 1.0 application —
from the request URI through `struts-config.xml`, `ActionForm` population,
`Action.execute()`, `ActionForward`, and the final JSP/Tile render.

### Input Format
```yaml
entry: uri | action_class | jsp
value: string                    # e.g., "/approveClaim.do" or "ApproveClaimAction"
struts_config_path: string       # e.g., WEB-INF/struts-config.xml
include_validation: true | false
include_tiles: true | false
```

### Output Expectations
- **Request map**: URI -> ActionMapping -> Action -> Forward -> View.
- **Form binding table**: form field -> ActionForm property -> validator.
- **Validation summary**: declarative (validation.xml) + programmatic.
- **Action.execute() walkthrough**: inputs, branches, side effects.
- **Forward graph**: all possible outcomes (success/failure/input).
- **View layer**: JSP/Tile rendered, key tags used (`<bean:write>`, `<logic:iterate>`).
- **Cross-cutting concerns**: interceptors, filters, session usage.

---

## 4. Batch Job Analysis

### Description
Analyze offline batch processing pipelines — scheduler trigger, job steps,
file handoffs, checkpoint/restart behavior, stored-procedure invocations,
and downstream dependencies.

### Input Format
```yaml
job_identifier: string           # e.g., "NB_POST_NIGHTLY"
artifacts: [string]              # JCL, .bat, .ps1, .sql, .cbl paths
schedule_source: string          # cron, control-m export, runbook
include_dependency_graph: true | false
include_failure_modes: true | false
```

### Output Expectations
- **Job overview**: purpose, schedule, owner, SLAs.
- **Step table**: step name, program, inputs, outputs, exit codes.
- **Data flow diagram**: file/table handoffs between steps (mermaid).
- **Checkpoint / restart map**: restartable units, idempotency notes.
- **Stored procedures touched**: name, mode (read/write), row impact.
- **Failure modes**: known failure points, runbook links if available.
- **Upstream / downstream dependencies**: jobs, feeds, consumers.

---

## 5. SQL Server Legacy Schema Analysis

### Description
Make sense of non-normalized Microsoft SQL Server schemas: wide tables,
implicit relationships, overloaded columns, magic codes, and stored-procedure-
centric business logic.

### Input Format
```yaml
target: table | view | stored_procedure | schema
name: string
include_sample_data: true | false  # masked
infer_relationships: true | false
include_usage_map: true | false    # which SPs / jobs read or write this
```

### Output Expectations
- **Object summary**: purpose, owner module, volatility.
- **Column dictionary**: name, type, nullability, inferred meaning,
  example values, magic-code legend.
- **Implicit relationships**: candidate FKs, join paths, evidence.
- **Overloaded columns**: columns carrying multiple meanings (flag).
- **Usage map**: stored procedures, jobs, and apps that read/write.
- **Risk callouts**: NOLOCK hints, cursors, dynamic SQL, missing indexes.
- **Normalization opportunities**: ranked, with blast-radius estimate.

---

## 6. Code Review (Legacy-Focused)

### Description
Legacy-aware code review that distinguishes "bad code" from "load-bearing
legacy." Produces findings, risk hotspots, and required safety nets calibrated
for systems with thin tests and asymmetric blast radius.

### Input Format
```yaml
change_set:
  type: diff | file | module
  ref: string                    # path, PR id, or commit range
context:
  knowledge_paths: [string]      # /knowledge entries to honor
  do_not_touch: [string]         # explicit invariants
review_lens:
  - security
  - correctness
  - performance
  - maintainability
  - backward_compatibility
```

### Output Expectations
- **Findings** — formatted as `[severity] [category] <message>` with
  `file:line` anchors. Severity: `blocker | major | minor | nit`.
- **Risk hotspots** — ranked list with rationale.
- **Behavioral preservation check** — does the change alter observable behavior?
- **Required safety nets** — characterization tests, feature flags, dual-writes,
  shadow runs.
- **Do-not-touch violations** — explicit, with citation to `/knowledge`.
- **Approval recommendation** — `approve | request-changes | block`.

---

## 7. Knowledge Grounding

### Description
Retrieval skill that searches the curated knowledge base — tribal docs, SME
notes, technical topic papers, legacy design documents, operational runbooks —
and returns cited passages suitable for grounding any agent's response.

### Input Format
```yaml
query: string
sources:                         # optional filter
  - tribal
  - sme-notes
  - topic-papers
  - design-docs
  - runbooks
max_passages: integer            # default 5
require_citation: true           # always true in practice
```

### Knowledge Layout
```
knowledge/
├── tribal/          # SME interviews, oral-history notes
├── sme-notes/       # short-form expert annotations
├── topic-papers/    # background on Struts 1, COBOL, SQL Server patterns
├── design-docs/     # original/legacy design documents
├── runbooks/        # operational procedures, incident playbooks
└── do-not-touch/    # invariants that must be preserved
```

### Output Expectations
- **Passages**: array of `{source_path, anchor, excerpt}`.
- **Synthesis**: optional short answer composed from passages.
- **Confidence**: `grounded | partial | inferred`.
- **Gaps**: missing topics or contradictions across sources.
- **Citations**: every factual claim links back to `source_path#anchor`.

---

## 8. Modernization Suggestions

### Description
Propose concrete, incremental modernization steps for a legacy artifact or
module. Optimized for safety: strangler-fig boundaries, anti-corruption
layers, characterization tests first.

### Input Format
```yaml
target:
  type: file | module | subsystem
  ref: string
constraints:
  - "no DB schema changes in phase 1"
  - "must remain compatible with overnight batch"
target_stack:                    # optional desired end-state
  language: java | csharp | python
  framework: spring-boot | aspnet-core | fastapi
risk_appetite: low | medium | high
```

### Output Expectations
- **Current-state summary** (1 paragraph).
- **Target-state sketch** (1 paragraph + optional mermaid).
- **Strangler-fig seams**: where to cut, why, blast radius.
- **Phased plan**: phases with goals, exit criteria, rollback plan.
- **Per-phase scoring**: `value (1-5)`, `blast_radius (1-5)`, `effort (1-5)`.
- **Safety nets required per phase**: tests, flags, dual-writes, shadow runs.
- **Open questions / SME interviews needed**.

---

## Skill Composition Patterns

Skills are designed to chain. Common combinations:

| Goal | Skill Chain |
|------|-------------|
| Onboarding to a legacy module | `5` → `3`/`2` → `1` → `7` |
| Pre-refactor safety brief | `1` → `4` → `7` (do-not-touch) → `6` |
| Modernization roadmap | `1` → `5` → `7` → `8` |
| Incident triage | `7` (runbooks) → `4` → `6` |
| PR review on legacy code | `6` → `1` (for flagged sections) → `7` (intent check) |

---

## Extensibility

To add a new skill:

1. Append a new numbered section in this file using the template below.
2. Add the skill to the **Skills Registry** table at the top.
3. Reference it from the relevant agent(s) in [`copilot-agents.md`](copilot-agents.md).
4. If the skill needs a reusable prompt, add it under
   `.github/prompts/skills/<skill-id>.prompt.md`.
5. If the skill enforces language/domain conventions, add an instructions file
   under `.github/instructions/<domain>.instructions.md`.

### Skill Template
```markdown
## N. <Skill Name>

### Description
<One paragraph.>

### Input Format
```yaml
<structured input contract>
```

### Output Expectations
- <Section 1>
- <Section 2>
```

---

## Conventions

- **Determinism first**: skills prefer structured output (tables, YAML, mermaid)
  over free prose where possible.
- **Citations mandatory**: any claim sourced from `/knowledge` must cite it.
- **Confidence labels**: `grounded | partial | inferred` on every answer.
- **No silent inference**: gaps and open questions are always listed explicitly.
- **Behavior preservation**: skills that touch legacy code default to
  "preserve observable behavior unless told otherwise."
