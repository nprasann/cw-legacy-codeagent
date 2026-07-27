# Demo Script — Legacy Code AI Assistant (3 minutes)

> **Audience:** judges, engineering leaders, developers familiar with modern
> stacks but not COBOL / Struts 1 / legacy SQL Server.
> **Goal:** show that a Copilot-powered multi-agent assistant turns
> impenetrable legacy code + tribal knowledge into clear, grounded,
> review-ready insight in real time.
> **Total runtime:** 3:00.

---

## 0. Pre-flight checklist (do this *before* you walk on stage)

- VS Code open on the cloned repo `cw-legacy-codeagent`.
- Copilot Chat panel open, workspace context **enabled**.
- These tabs already open and pinned:
  1. [examples/cobol/NB_POST.CBL](../examples/cobol/NB_POST.CBL)
  2. [knowledge/tribal/nb-post-z9-special-hold.md](../knowledge/tribal/nb-post-z9-special-hold.md)
  3. [examples/sql/usp_NightlyPostings.sql](../examples/sql/usp_NightlyPostings.sql)
  4. [prompts/explain-cobol.md](../prompts/explain-cobol.md) (for reference)
- Browser zoom ~125%, font size in editor bumped for the room.
- Stopwatch / timer visible to you.
- One-line elevator pitch loaded in your head (see Section 1).

---

## 1. Hook — 0:00–0:20 (20s)

**SAY (verbatim, optional):**
> "Every enterprise has a billion lines of code nobody alive fully
> understands. Today I'll show you a Copilot-powered assistant that reads
> COBOL, Struts 1, and legacy SQL Server — and *grounds* its answers in
> the tribal knowledge that usually walks out the door at retirement.
> Three minutes, three demos."

**SHOW:** the repo root in the file tree. Briefly point at:

- `.github/copilot/` — agents + skills
- `knowledge/` — tribal docs, runbooks, technical papers
- `examples/` — realistic legacy artifacts
- `prompts/` — copy-paste templates

**Talking point:** *"Multi-agent, grounded, awesome-copilot conventions."*

---

## 2. Demo 1 — Explain legacy COBOL with grounded tribal knowledge — 0:20–1:30 (70s)

**Input files:**
- [examples/cobol/NB_POST.CBL](../examples/cobol/NB_POST.CBL) (nightly billing batch)
- [knowledge/tribal/nb-post-z9-special-hold.md](../knowledge/tribal/nb-post-z9-special-hold.md)
  (SME-documented magic code)

**ACTION:** open `NB_POST.CBL`. Highlight paragraph `2100-VALIDATE-INVOICE`
and the `Z9` branch. Say: *"This is a 28-year-old batch. Nobody on the
team has read it. Watch."*

**PROMPT (paste into Copilot Chat):**
```
@legacy-code Explain examples/cobol/NB_POST.CBL end-to-end for a
developer with no mainframe background.

Use prompts/explain-cobol.md as the output contract.
Pull tribal context from /knowledge/tribal for any magic status codes
('A','R','H','Z9') and for the preserved GO TO branch in
2200-POST-INVOICE. Cite every grounded claim.
```

**EXPECTED OUTPUT (point to these as Copilot streams):**

- **Summary** — one-paragraph plain-language description.
- **Division Map** + **Control Flow** (mermaid) with `PERFORM` / `GO TO`.
- **Magic Codes & Business Rules** table that includes a row like:

  | Field | Code | Documented meaning | Source |
  |-------|------|--------------------|--------|
  | INV-STATUS-CD | Z9 | Special hold — not posted, not rejected, counted as held. Active legal review per BILL-2014-007. | [knowledge/tribal/nb-post-z9-special-hold.md#rule](../knowledge/tribal/nb-post-z9-special-hold.md#rule) |

- **Confidence:** `grounded`.
- **Gaps:** missing characterization test for `Z9` branch.

**TALKING POINTS (say while it streams):**
1. *"Notice the agent didn't invent the meaning of `Z9` — it pulled the
   SME-authored tribal note and **cited** it."*
2. *"That citation is the difference between 'AI guess' and 'auditable
   answer'. Compliance can follow the link."*
3. *"The Gaps section is the demo within the demo — the assistant tells
   us **what knowledge is missing** and where it should live."*

---

## 3. Demo 2 — Trace a cross-layer flow & catch a risk — 1:30–2:20 (50s)

**Input files:**
- [examples/struts/.../ApproveClaimAction.java](../examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java)
- [examples/sql/usp_PostClaimApproval.sql](../examples/sql/usp_PostClaimApproval.sql)
- [examples/sql/schema.sql](../examples/sql/schema.sql)

**ACTION:** open `ApproveClaimAction.java`. Briefly scroll the
`unsafeSql` block. Say: *"This is the Struts 1 path when a user clicks
'Approve'. It also kicks off a stored procedure that feeds the COBOL
batch we just explained."*

**PROMPT (paste into Copilot Chat):**
```
@review Review examples/struts/.../ApproveClaimAction.java and the SP
it calls, examples/sql/usp_PostClaimApproval.sql.

Use prompts/review-legacy-code.md.
Lenses: security, correctness, backward-compat with the overnight
NB_POST_NIGHTLY batch. Honor any do-not-touch entries in /knowledge.
```

**EXPECTED OUTPUT:**

- **Findings** including:
  - `[blocker] [security] SQL injection via string concat (ApproveClaimAction.java:~80)`
  - `[blocker] [security] Hard-coded JDBC credentials (lines ~33-35)`
  - `[major] [correctness] No transaction boundary around multi-statement update + SP call`
  - `[major] [concurrency] NOLOCK read-then-write race in usp_PostClaimApproval`
  - `[major] [correctness] Audit duplication between SP and trg_ClaimAudit`
- **Do-Not-Touch Violations** — empty (because the `Z9` invariant is
  respected — the agent specifically checked and says so).
- **Approval recommendation:** `request-changes` or `block`.
- **Confidence:** `grounded`.

**TALKING POINTS (say while it streams):**
1. *"Look at the severity ladder — `blocker`, `major`, `minor`. This is
   not a generic linter; it's reasoning about **legacy blast radius**."*
2. *"It explicitly confirms it did NOT touch the `Z9` invariant — because
   it consulted `/knowledge/do-not-touch`. That's the veto rule baked in."*
3. *"Same assistant, different agent — the prompt template made the
   output structured enough to drop into a PR review."*

---

## 4. Demo 3 — Make sense of a non-normalized schema in 20 seconds — 2:20–2:50 (30s)

**Input file:** [examples/sql/schema.sql](../examples/sql/schema.sql)

**ACTION:** open `schema.sql`. Scroll fast through `CLAIM` and
`CUSTOMER`. Say: *"Wide tables, no foreign keys, magic codes, bitfields
hidden in a CHAR column. Classic. One prompt."*

**PROMPT (paste into Copilot Chat):**
```
@legacy-code Analyze examples/sql/schema.sql.
Use prompts/analyze-sql-schema.md.
Focus on BILLING.CLAIM: column dictionary, implicit relationships,
overloaded columns (ROUTING_FLAGS), and a risk-ranked normalization
plan that honors /knowledge/do-not-touch.
```

**EXPECTED OUTPUT:**

- **Column Dictionary** with magic codes annotated.
- **Implicit Relationships** table showing `CLAIM.CUSTOMER_ID ↔ CUSTOMER.CUSTOMER_ID`
  inferred even though no `FOREIGN KEY` exists.
- **Overloaded Columns** entry for `ROUTING_FLAGS` (bitfield).
- **Normalization Opportunities** ranked by value vs. blast radius.

**TALKING POINTS:**
1. *"It inferred a foreign key the DBA never declared — based on
   evidence, not vibes."*
2. *"And it ranked normalization moves so we can sequence a roadmap, not
   propose a big-bang rewrite."*

---

## 5. Close — 2:50–3:00 (10s)

**SAY:**
> "Three agents. Grounded answers with citations. A veto rule that
> respects tribal invariants. And a path from impenetrable legacy code to
> a reviewable PR — in three minutes. That's `cw-legacy-codeagent`.
> Repo's open. Thank you."

**SHOW:** README in the editor, scroll to the **Architecture overview**
mermaid diagram, leave it on screen.

---

## 6. Backup demos (in case of judge questions or extra time)

| If asked… | Run this prompt |
|-----------|-----------------|
| "What if the docs don't exist?" | `@knowledge What does CUST_FLAGS bit 3 mean?` → returns `inferred` confidence and lists the missing file under Gaps. |
| "Can it plan a migration?" | `@review Score modernization opportunities for the Approve Claim flow. Suggest a strangler-fig boundary toward Spring Boot.` |
| "Does it handle batch ops?" | `@knowledge NB_POST failed at step 040 — what does the runbook say?` |
| "Show me the routing logic" | Open [docs/agent-routing.md](./agent-routing.md) and show the mermaid flowchart. |

---

## 7. Recovery playbook (when things go wrong on stage)

| Failure | Fallback |
|---------|----------|
| Copilot slow / hangs | Read aloud the **expected output** sections above and switch to a pre-recorded screenshot in your slides. |
| Wrong agent picks up | Re-prompt with the bracketed prefix: `[ReviewAgent] ...`. |
| Citation looks wrong | Open the cited file in a split — it's the same file in `knowledge/tribal/`. Demo the auditability story. |
| Network down | Open [docs/agent-routing.md](./agent-routing.md) and walk the mermaid diagrams. Same story, no live model. |

---

## 8. Persuasion cheat sheet (one-liners)

- *"Citations turn AI answers into auditable answers."*
- *"Tribal knowledge becomes an asset, not a retirement risk."*
- *"Legacy isn't bad code — it's load-bearing code. Our review agent
  knows the difference."*
- *"Three agents, one workflow, zero hallucinations on the things that
  matter."*
- *"Onboarding to a 28-year-old batch in 90 seconds."*

---

## 9. Asset index (every file used in the demo)

| Asset | Path |
|-------|------|
| COBOL nightly batch | [examples/cobol/NB_POST.CBL](../examples/cobol/NB_POST.CBL) |
| Copybook (invoice record) | [examples/cobol/INVREC.cpy](../examples/cobol/INVREC.cpy) |
| Tribal knowledge (`Z9`) | [knowledge/tribal/nb-post-z9-special-hold.md](../knowledge/tribal/nb-post-z9-special-hold.md) |
| Struts Action | [examples/struts/.../ApproveClaimAction.java](../examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java) |
| Stored proc (called by Action) | [examples/sql/usp_PostClaimApproval.sql](../examples/sql/usp_PostClaimApproval.sql) |
| Nightly SP | [examples/sql/usp_NightlyPostings.sql](../examples/sql/usp_NightlyPostings.sql) |
| Schema | [examples/sql/schema.sql](../examples/sql/schema.sql) |
| Prompt — explain COBOL | [prompts/explain-cobol.md](../prompts/explain-cobol.md) |
| Prompt — review legacy code | [prompts/review-legacy-code.md](../prompts/review-legacy-code.md) |
| Prompt — analyze SQL schema | [prompts/analyze-sql-schema.md](../prompts/analyze-sql-schema.md) |
| Agent routing | [docs/agent-routing.md](./agent-routing.md) |
| Architecture | [docs/architecture.md](./architecture.md) |
