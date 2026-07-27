# Grounding — Knowledge Conventions

> How the **cw-legacy-codeagent** assistant grounds its answers in curated
> knowledge. Conventions inspired by [github/awesome-copilot](https://github.com/github/awesome-copilot).

The `KnowledgeAgent` and any other agent that needs business / operational
context reads from [`/knowledge`](../knowledge/). This document defines:

1. The folder layout and what belongs where.
2. The file naming convention.
3. The mandatory metadata header on every knowledge file.
4. The tagging vocabulary.
5. Prompt patterns developers should use to invoke grounded answers.

---

## 1. Folder Layout

```
knowledge/
├── tribal/             # SME interviews, oral history, undocumented rules
├── technical-papers/   # technology background (Struts 1, COBOL, SQL Server, batch)
└── runbooks/           # operational procedures, incident playbooks
```

| Folder | What goes here | Examples |
|--------|----------------|----------|
| `tribal/` | Knowledge that lives only in people's heads. SME interviews, hallway answers, "why we did it this way" notes. | `tribal/shadow-ledger-history.md`, `tribal/sme-jdoe-billing-interview.md` |
| `technical-papers/` | Durable, vendor- or technology-level background. Reference material that doesn't change with each release. | `technical-papers/struts1-action-lifecycle.md`, `technical-papers/cobol-comp3-primer.md` |
| `runbooks/` | Operational truth: how to run, restart, recover. Step-numbered, prescriptive. | `runbooks/nb-post-nightly.md`, `runbooks/sql-deadlock-triage.md` |

Optional extensions (add as the program matures):

- `knowledge/design-docs/` — original/legacy design documents.
- `knowledge/sme-notes/` — short-form annotations from SMEs.
- `knowledge/do-not-touch/` — explicit invariants that must be preserved.

---

## 2. File Naming Convention

```
<kebab-case-topic>[.<subtopic>].md
```

Rules:

- Lowercase, kebab-case only.
- No dates in filenames (use `updated` in the metadata header instead).
- Prefix with the **subsystem** when relevant: `billing-`, `claims-`, `nb-post-`.
- One topic per file. Split rather than overload.

Examples:

- `tribal/billing-rounding-rules.md`
- `technical-papers/struts1-actionform-pitfalls.md`
- `runbooks/nb-post-nightly.md`

---

## 3. Metadata Header (Required)

Every knowledge file MUST start with a YAML front-matter header so agents can
filter, prioritize, and cite consistently.

```markdown
---
title: "Billing Rounding Rules"
type: tribal                    # tribal | technical-paper | runbook | design-doc | sme-note | do-not-touch
subsystem: billing              # business subsystem this concerns
tags: [cobol, batch, rounding]  # see Tagging Vocabulary
sources:                        # where this knowledge came from
  - "SME interview: J. Doe, 2025-11-04"
  - "Internal memo: BILL-2003-rounding.pdf"
owner: "billing-team"           # team or person responsible
confidence: high                # high | medium | low
updated: 2026-05-12             # ISO date of last update
do_not_touch: false             # true to flag as invariant
---

# Billing Rounding Rules

<content>
```

Notes:

- `confidence: low` signals to agents that the content is provisional.
- `do_not_touch: true` makes the file authoritative for the ReviewAgent's
  invariant checks.
- `sources` is mandatory — even one informal source is better than none.

---

## 4. Tagging Vocabulary

Use tags from this controlled list (extend deliberately, not casually):

**Technology**
`struts1`, `jsp`, `cobol`, `jcl`, `batch`, `sql-server`, `tsql`,
`stored-procedure`, `cursor`, `dynamic-sql`, `copybook`, `ebcdic`.

**Concern**
`security`, `performance`, `correctness`, `availability`, `compliance`,
`rounding`, `date-handling`, `concurrency`, `idempotency`.

**Subsystem** (extend per repo)
`billing`, `claims`, `customer`, `payments`, `ledger`, `reporting`.

**Lifecycle**
`onboarding`, `incident`, `modernization`, `migration`, `deprecation`.

---

## 5. Citation Format

Agents cite knowledge using a stable anchor format:

```
[knowledge/<folder>/<file>.md#<heading-anchor>]
```

Example:

> Claim amounts are rounded **down** for legacy parity with the COBOL
> batch posting program. [knowledge/tribal/billing-rounding-rules.md#why-round-down]

Authors should therefore:

- Use clear `##` and `###` headings (they become anchors).
- Avoid renaming headings once cited elsewhere.

---

## 6. Grounded Prompt Patterns

Developers should phrase prompts so Copilot prefers grounding over guessing.
Recommended templates:

### 6.1 Explain with grounding
```
Using the tribal knowledge in /knowledge/tribal and any matching
technical papers in /knowledge/technical-papers, explain what this
COBOL batch job does and why it exists.
File: src/cobol/NB_POST.CBL
```

### 6.2 Operational question
```
Using /knowledge/runbooks, tell me how to recover from a failure
of the NB_POST_NIGHTLY job at step 040. Cite the runbook section.
```

### 6.3 Reconcile code vs. intent
```
Compare the behavior of usp_CalcInterest with the documented intent
in /knowledge/design-docs and /knowledge/tribal. Flag any drift.
```

### 6.4 Review with invariants
```
Review the attached diff. Honor any do_not_touch entries in
/knowledge. Cite invariants you relied on.
```

### 6.5 Onboarding brief
```
Produce an onboarding brief for the Billing subsystem using
/knowledge/tribal/billing-*.md and /knowledge/technical-papers.
Include open questions where coverage is thin.
```

---

## 7. Confidence and Gap Reporting

Every grounded answer should end with:

- **Confidence**: `grounded` (fully cited) | `partial` (some citations) |
  `inferred` (no citations available).
- **Gaps**: explicit bullet list of unknowns, contradictions across sources,
  or knowledge files that *should* exist but don't.

This makes missing knowledge visible — and actionable — to SMEs.

---

## 8. Promotion Workflow

When the assistant infers something useful that is **not** yet in
`/knowledge`, the developer should:

1. Validate with an SME.
2. Create a new file under the appropriate `knowledge/` subfolder.
3. Add the metadata header (Section 3).
4. Open a PR; the `ReviewAgent` will sanity-check the metadata.

This converts tribal knowledge into durable, agent-readable knowledge over
time.
