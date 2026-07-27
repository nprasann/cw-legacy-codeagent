# Prompt — Explain a COBOL Program

> Agent: `@legacy-code` (LegacyCodeAgent)
> Skill: COBOL Flow Analysis, Legacy Code Explanation
> Default assumption: **preserve observable behavior**.

---

## Copy-paste prompt

```
@legacy-code Explain the COBOL program below end-to-end for a modern
developer with no mainframe background.

TARGET
- Program file: <path/to/PROGRAM.CBL>
- Copybooks:    <path/to/*.cpy> (auto-discover if omitted)
- JCL (optional): <path/to/PROGRAM.JCL>

GROUNDING (use /knowledge first, then code)
- Read /knowledge/runbooks/**          for operational truth.
- Read /knowledge/technical-papers/**  for COBOL/JCL/EXEC SQL background.
- Read /knowledge/tribal/**            for SME notes on magic codes,
                                       "do not touch" sections, history.
- Cite every grounded claim as [knowledge/<folder>/<file>.md#<anchor>].
- If a fact is not in /knowledge, mark it inferred from code.

OUTPUT CONTRACT (use these exact section headers)
1. Summary
   - 1-3 sentences. Plain language. Business purpose first, then mechanics.

2. Division Map
   - Table: Division / Section / Paragraph / Purpose.

3. Copybook Table
   - Table: Copybook / Used in / Record layout summary / Notable fields
     (COMP-3, magic codes, bitfields).

4. Control Flow
   - Numbered steps for the happy path.
   - Mermaid `flowchart` for PERFORM / CALL / GO TO relationships.
   - Explicitly flag GO TO hotspots and label any "preserved-on-purpose"
     branches found in /knowledge/tribal.

5. File I/O Table
   - Table: DDNAME / File / Mode / Record format / Lifecycle / Failure mode.

6. EXEC SQL Inventory
   - Table: Statement / Table(s) touched / Side effects / Transaction
     boundary (explicit or implicit) / Error handling path.

7. Magic Codes & Business Rules
   - Table: Field / Code / Documented meaning / Source citation.
   - Mark unknown codes with confidence: inferred.

8. Legacy-isms
   - Bullet list of dated patterns (COMP-3 misuse, EBCDIC pitfalls,
     unchecked file status, missing checkpoints, etc.) with brief why-it-matters.

9. Modern Analogy
   - One paragraph mapping the program to an equivalent modern design
     (e.g., Spring Batch step, idempotent service + outbox).

10. Open Questions
    - Bullet list of things only an SME can answer; suggest which
      /knowledge file should hold the answer once obtained.

11. Confidence
    - One of: grounded | partial | inferred.

12. Gaps
    - Knowledge files that SHOULD exist for this program but don't,
      with proposed paths under /knowledge/tribal or /knowledge/runbooks.
```

---

## Notes for the requester

- Attach the `.CBL`, `.cpy`, and `.JCL` files to the chat for best results.
- If the program is large, ask for **Section 4 (Control Flow)** first and
  iterate from there.
- To force behavior preservation in any follow-up rewrite, append:
  `Do not change observable behavior. Flag any required behavior changes
  as Open Questions instead.`
