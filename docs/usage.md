# Usage Guide — Legacy Code AI Assistant

> How developers use the **cw-legacy-codeagent** assistant from GitHub Copilot
> Chat in VS Code.

---

## 1. Prerequisites

- VS Code with the **GitHub Copilot** and **GitHub Copilot Chat** extensions
  installed and signed in.
- This repository cloned locally and opened as a workspace.
- (Recommended) Workspace context enabled in Copilot Chat so it can read
  [`/.github/copilot`](../.github/copilot/) and [`/knowledge`](../knowledge/).

---

## 2. Agent Handles

| Handle | Agent | When to use |
|--------|-------|-------------|
| `@legacy-code` | LegacyCodeAgent | Explain or trace legacy code. |
| `@knowledge`   | KnowledgeAgent  | Grounded answers from `/knowledge`. |
| `@review`      | ReviewAgent     | Risk-aware code review and modernization advice. |

> If your Copilot environment doesn't support `@handles`, prefix prompts with
> `[LegacyCodeAgent]`, `[KnowledgeAgent]`, or `[ReviewAgent]` — the agent
> definitions in [`.github/copilot/copilot-agents.md`](../.github/copilot/copilot-agents.md)
> are written so Copilot picks up the role from the prefix.

---

## 3. Ask Questions About Legacy Code

### Explain a Struts action
```
@legacy-code Explain what ApproveClaimAction.java does and trace its
flow through struts-config.xml to the JSP response.
```

### Walk through a COBOL program
```
@legacy-code Walk me through PROC1234.CBL section by section. List
copybooks, files opened, and any EXEC SQL blocks.
```

### Untangle a stored procedure
```
@legacy-code usp_NightlyPostings is 1,800 lines. Summarize its phases,
tables it mutates, and any cursors used.
```

### Trace a cross-layer flow
```
@legacy-code Trace the path from clicking "Approve Claim" in the UI
through the Struts action, stored procedure, and overnight COBOL job.
```

---

## 4. Trigger Specific Agents

### Knowledge-grounded answers
```
@knowledge Why are claim amounts rounded down? Cite the tribal note
or design doc.
```

### Operational / runbook
```
@knowledge Job NB_POST failed at step 040. What does the runbook say?
```

### Onboarding brief
```
@knowledge Produce an onboarding brief for the Billing subsystem
using everything under /knowledge.
```

---

## 5. Perform Code Review

### Review a diff
```
@review Review this diff to PaymentAction.java with emphasis on
backward compatibility with the overnight settlement batch.
```

### Pre-refactor safety check
```
@review I want to remove the cursor loop in usp_CalcInterest.
Assess risk, list required characterization tests, and flag any
do-not-touch invariants from /knowledge.
```

### Modernization scoring
```
@review Score modernization opportunities in the Claims module.
Output: value (1-5), blast radius (1-5), recommended sequencing.
```

---

## 6. Analyze COBOL Batch Jobs

### Single-program analysis
```
@legacy-code Analyze NB_POST.CBL. I want:
- Division map
- Copybook table
- PERFORM/CALL graph
- File I/O table
- GO TO hotspots
```

### End-to-end job analysis
```
@legacy-code Analyze the NB_POST_NIGHTLY job end-to-end. Include the
step table, data-flow diagram, stored procedures touched, and known
failure modes from /knowledge/runbooks.
```

### Pre-modernization brief
```
@review Produce a modernization brief for NB_POST_NIGHTLY:
strangler-fig seams, phased plan, safety nets per phase, and open
questions for SMEs.
```

---

## 7. Analyze a SQL Server Schema

```
@legacy-code Analyze the CUST_MASTER table. Produce a column
dictionary, flag overloaded columns, infer implicit relationships,
and list every stored procedure that reads or writes it.
```

```
@review Assess normalization opportunities for the Billing schema.
Rank by value vs. blast radius. Respect do-not-touch entries in
/knowledge.
```

---

## 8. Combine Agents in a Single Prompt

Copilot Chat can orchestrate. Example:

```
First @legacy-code: walk me through PROC1234.CBL.
Then @knowledge: pull any tribal notes or runbooks about it.
Then @review: list risks if I touch the GO TO heavy section.
```

---

## 9. Recommended Output Contracts

Ask for structured output to keep answers reviewable:

```
@legacy-code Explain CustomerSearchAction.java. Respond with:
1. Summary (1-3 sentences)
2. Inputs / Outputs / Side effects
3. Control flow (mermaid)
4. Legacy-isms
5. Modern analogy
6. Open questions
```

```
@review Review this diff. Respond with:
- Findings: [severity] [category] message (file:line)
- Risk hotspots: ranked
- Required safety nets
- Do-not-touch violations (cited)
- Approval: approve | request-changes | block
```

---

## 10. Tips

- **Attach files** to chat for precise scope rather than relying on workspace
  search alone.
- **Cite back**: when an agent infers something useful, promote it to
  `/knowledge` following [grounding.md](./grounding.md) Section 8.
- **Confidence labels**: trust `grounded` answers most, treat `inferred`
  answers as hypotheses.
- **Behavior preservation**: by default, the assistant preserves observable
  behavior. State explicitly if you want it to suggest behavior-changing
  refactors.

---

## 11. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Agent ignores your handle | Workspace context disabled | Enable "Use workspace context" in Copilot Chat. |
| No citations in answers | Knowledge files lack metadata headers | Add YAML headers per [grounding.md](./grounding.md) §3. |
| Review flags everything as `inferred` | `/knowledge` is empty or unmapped | Seed a few `tribal/`, `technical-papers/`, and `runbooks/` files. |
| Conflicting answers | Sources contradict each other | Ask `@knowledge` to reconcile and cite both. Promote a resolution. |

---

## 12. CLI Helper — `scripts/run-analysis.ps1`

A PowerShell CLI that turns any legacy file into a copy-paste-ready
Copilot prompt. It does **not** call a model — it inspects the file,
routes to the right agent, picks the matching template from
[`prompts/`](../prompts/), discovers candidate grounding files under
[`knowledge/`](../knowledge/), prints the prompt, and copies it to your
clipboard.

### 12.1 Quick start

```powershell
# From the repo root
./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL
```

Then open Copilot Chat (Ctrl+Alt+I) and paste (Ctrl+V).

### 12.2 Parameters

| Parameter | Required | Default | Purpose |
|-----------|----------|---------|---------|
| `-Path` | yes | — | Legacy file to analyze (repo-relative or absolute). |
| `-Mode` | no | `auto` | `auto | explain | review | ground | batch | schema | struts` — force a specific analysis mode. |
| `-Question` | no | — | Free-text focus to append (e.g., security lens, perf lens). |
| `-NoCopy` | no | off | Skip copying the prompt to clipboard. |

### 12.3 Mode auto-detection

| File / shape | Resolved mode | Agent | Template |
|--------------|---------------|-------|----------|
| `*.CBL` (with sibling `*.JCL`) | `batch` | `@legacy-code` | [analyze-batch.md](../prompts/analyze-batch.md) |
| `*.CBL`, `*.cpy` | `explain` | `@legacy-code` | [explain-cobol.md](../prompts/explain-cobol.md) |
| `*.JCL` | `batch` | `@legacy-code` | [analyze-batch.md](../prompts/analyze-batch.md) |
| `*.sql` (DDL only) | `schema` | `@legacy-code` | [analyze-sql-schema.md](../prompts/analyze-sql-schema.md) |
| `*.sql` (stored proc / trigger) | `explain` | `@legacy-code` | [review-legacy-code.md](../prompts/review-legacy-code.md) |
| `*Action.java`, `struts-config.xml`, `validation.xml`, `web.xml`, `*.jsp` | `struts` | `@legacy-code` | [explain-struts.md](../prompts/explain-struts.md) |
| `*.diff`, `*.patch` | `review` | `@review` | [review-legacy-code.md](../prompts/review-legacy-code.md) |

### 12.4 Examples

**Auto-detected COBOL + JCL → batch analysis**
```powershell
./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL
```

**Force a review on a Struts Action with a focused question**
```powershell
./scripts/run-analysis.ps1 `
    -Path examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java `
    -Mode review `
    -Question "Focus on SQL injection and backward-compat with NB_POST_NIGHTLY."
```

**Schema sense-making for `BILLING.CLAIM`**
```powershell
./scripts/run-analysis.ps1 -Path examples/sql/schema.sql -Mode schema
```

**Pipe the prompt to a file instead of using the clipboard**
```powershell
./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL -NoCopy `
    > prompt.txt
```

### 12.5 What the script prints

1. A run summary: file, detected kind, resolved mode, agent, template,
   and candidate `knowledge/` files it discovered.
2. A 4-step usage block (open file → open chat → paste → review).
3. The fully-composed Copilot prompt with:
   - Target file + kind + contract.
   - `GROUNDING` section listing `/knowledge/**` and any auto-discovered
     files.
   - `OUTPUT REQUIREMENTS` enforcing the contract, behavior preservation,
     and the mandatory **Confidence** + **Gaps** sections.
   - `ADDITIONAL FOCUS` block when `-Question` is supplied.

### 12.6 Exit codes

| Code | Meaning |
|------|---------|
| `0` | Prompt generated successfully. |
| `2` | Input file not found. |
| Other | PowerShell runtime error — re-run with `-Verbose` for details. |

