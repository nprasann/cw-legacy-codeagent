# Prompt — Analyze an Offline Batch Job

> Agents: `@legacy-code` (primary), `@knowledge` (runbooks), `@review` (risk)
> Skill: Batch Job Analysis, Knowledge Grounding
> Use when a nightly / scheduled job spans JCL + COBOL + stored procedures + files.

---

## Copy-paste prompt

```
@legacy-code Analyze the offline batch job below end-to-end. Cover the
full pipeline from scheduler trigger through file handoffs to the
final downstream consumers.

TARGET
- Job identifier: <e.g., NB_POST_NIGHTLY>
- Schedule source: <Control-M export | cron | runbook excerpt>
- Artifacts:
  - JCL / scripts: <path/to/*.JCL or *.ps1 or *.bat>
  - Programs:     <path/to/*.CBL>
  - Stored procs: <BILLING.usp_*>
  - Copybooks:    <path/to/*.cpy>

GROUNDING (use /knowledge first, then code)
- /knowledge/runbooks/**           authoritative for ops behavior.
- /knowledge/design-docs/** (opt)  authoritative for intent.
- /knowledge/tribal/**             SME notes on magic codes and overrides.
- /knowledge/technical-papers/**   background on JCL, checkpoint/restart.
- Cite every grounded claim as [knowledge/<folder>/<file>.md#<anchor>].
- If runbook coverage is missing, list the missing file under Gaps.

OUTPUT CONTRACT (use these exact section headers)
1. Job Overview
   - Purpose, owner, business SLA, schedule (cron / Control-M trigger).

2. Step Table
   - Table: Step / Program | SP | Script / Inputs / Outputs / Exit-code
     handling / Estimated runtime / Notes.

3. Data Flow Diagram
   - Mermaid `flowchart LR` showing files and DB tables flowing
     step-to-step. Annotate each edge with the file name or table.

4. Trigger & Dependencies
   - Upstream jobs / feeds that must complete first.
   - Downstream jobs / consumers that depend on this job's outputs.

5. Stored Procedures Touched
   - Table: SP name / Mode (read | write | both) / Tables affected /
     Transaction boundary / Known anti-patterns (cursor, NOLOCK,
     dynamic SQL, no-tran).

6. Checkpoint / Restart Map
   - Per step: is it restartable? Idempotent? What input controls
     skip / re-run (e.g., SKIPCNT override)?

7. Failure Modes
   - Table: Symptom / Likely cause / Runbook reference / Severity.
   - Pull from /knowledge/runbooks where available.

8. Risk Hotspots
   - Ranked list with rationale. Explicitly flag:
     - Non-idempotent steps.
     - Implicit transactions across step boundaries.
     - Tight coupling between batch and online (e.g., shared tables
       updated by both).
     - Magic codes whose meaning is only in tribal knowledge.

9. Modernization Notes (advisory only)
   - Strangler-fig seams (where to cut without breaking ops).
   - Replacement candidates (Spring Batch, event-driven, etc.).
   - Safety nets required before any change.

10. Open Questions
    - Things only an SME can answer; propose new /knowledge files.

11. Confidence
    - grounded | partial | inferred.

12. Gaps
    - Missing /knowledge files that SHOULD exist for this job, with
      proposed paths.
```

---

## Notes for the requester

- For incident triage, lead with `@knowledge` first to pull the runbook,
  then escalate to `@legacy-code` on the specific failing step.
- If you only want a single-step deep dive, replace the **Step Table**
  request with "focus only on step `<NAME>`" and keep the other sections.
