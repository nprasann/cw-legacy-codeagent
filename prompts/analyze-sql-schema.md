# Prompt — Analyze a SQL Server Legacy Schema

> Agent: `@legacy-code` (primary), `@knowledge` (grounding), `@review` (risk + normalization)
> Skill: SQL Server Legacy Schema Analysis, Code Review (Legacy-Focused)
> Use for non-normalized MS SQL Server schemas, wide tables, overloaded
> columns, magic codes, cursor-heavy stored procedures.

---

## Copy-paste prompt

```
@legacy-code Analyze the SQL Server object(s) below. The schema is
known to be non-normalized; do not "correct" it - explain it as it
is and flag risks separately.

TARGET
- Type:  <table | view | stored procedure | trigger | schema>
- Name:  <BILLING.CLAIM | BILLING.usp_NightlyPostings | ...>
- DDL / source files: <path/to/schema.sql, path/to/usp_*.sql>
- Sample data (masked): <path/to/sample_data.sql> (optional)

GROUNDING (use /knowledge first, then code)
- /knowledge/tribal/**            magic codes, bitfield layouts,
                                  "why this column means three things".
- /knowledge/design-docs/**       original schema intent.
- /knowledge/runbooks/**          ops behavior for any SP / job that
                                  touches this object.
- /knowledge/technical-papers/**  SQL Server / T-SQL background.
- Cite every grounded claim as [knowledge/<folder>/<file>.md#<anchor>].

OUTPUT CONTRACT (use these exact section headers)
1. Object Summary
   - 1-3 sentences. Business purpose, owner module, volatility
     (high-write, mostly-read, append-only, audit-only).

2. Column Dictionary  (for tables / views)
   - Table: Column / Type / Nullable / PK/FK / Inferred meaning /
     Example values / Magic-code legend / Source citation.
   - Mark overloaded columns explicitly (one column, multiple meanings).

3. Implicit Relationships
   - Candidate foreign keys (no constraint, but used as a join key).
   - Table: From / Column / To / Column / Evidence
     (naming, join in SP, sample data) / Confidence.

4. Overloaded / Bitfield Columns
   - Table: Column / Position or substring / Documented meaning /
     Source citation. Flag any without documentation.

5. Magic Codes
   - Table: Column / Value / Documented meaning / Source citation.
   - Flag unknown values; suggest where in /knowledge they belong.

6. Stored Procedure / Trigger Analysis (when target is an SP / trigger)
   - Phases (numbered).
   - Side effects table: Statement / Tables touched / Mode
     (read | write | both) / Transaction boundary.
   - Anti-patterns called out:
     - Cursors (when set-based would do).
     - WITH (NOLOCK) usage and dirty-read risk.
     - Dynamic SQL by string concatenation.
     - SET ROWCOUNT for DML (deprecated).
     - Silent error handling (PRINT instead of THROW).
     - Single-row trigger assumptions.
     - Missing transactions across multi-statement work.

7. Usage Map
   - Table: Caller (SP / job / app / trigger) / Mode (read | write) /
     Frequency (real-time | batch) / Coupling notes.
   - Pull the batch wiring from /knowledge/runbooks where available.

8. Risk Callouts
   - Ranked list with rationale: concurrency, performance, data
     integrity, audit gaps. Include blast radius
     (online | batch | downstream).

9. Normalization Opportunities (advisory)
   - Table: Opportunity / Value (1-5) / Blast radius (1-5) /
     Effort (1-5) / Recommended sequencing / Safety nets required.
   - Respect /knowledge/do-not-touch/**.

10. Open Questions
    - Things only an SME can answer. Suggest where in /knowledge
      each answer should live.

11. Confidence
    - grounded | partial | inferred.

12. Gaps
    - Missing /knowledge files that SHOULD exist for this object,
      with proposed paths under /knowledge/tribal or /knowledge/design-docs.
```

---

## Notes for the requester

- For schema-wide analysis, target `Type: schema` and let the assistant
  produce one **Object Summary** per major table.
- For stored procedures, attach the `.sql` file AND the DDL of every
  table the SP touches so the analysis is grounded in real shapes.
- To produce a normalization plan you can act on, follow up with:
  `Expand Section 9 into a phased plan with exit criteria, rollback,
  and required characterization tests per phase.`
