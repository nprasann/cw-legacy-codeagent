# COBOL Example — `NB_POST`

Realistic-but-synthetic nightly billing posting batch.

## Files

| File | Purpose |
|------|---------|
| [`NB_POST.CBL`](./NB_POST.CBL) | Main COBOL program: reads invoices, posts via EXEC SQL, writes rejects. |
| [`INVREC.cpy`](./INVREC.cpy)   | Copybook: input invoice record layout (200 bytes, COMP-3 money). |
| [`CUSTREC.cpy`](./CUSTREC.cpy) | Copybook: customer master record (wide, bitfield `CUST-FLAGS`). |
| [`NB_POST.JCL`](./NB_POST.JCL) | JCL: 3-step job (PRESTEP, RUNPOST, RPTSTEP) with `COND=` chaining. |

## Legacy patterns to demo

- Mixed `PERFORM` (structured) and `GO TO` (legacy) control flow.
- COMP-3 packed-decimal signed money fields.
- Copybook-driven record layouts; `FILLER` repurposed as bitfields.
- Embedded `EXEC SQL` with implicit transaction boundaries.
- Magic status codes (`A`, `R`, `H`, `Z9`) documented only in tribal notes.
- No structured checkpoint/restart — relies on operator runbook.
- JCL with hard-coded DSNs and `COND=(0,NE,...)` step chaining.

## Suggested prompts

```
@legacy-code Explain examples/cobol/NB_POST.CBL end-to-end. Produce a
division map, PERFORM/CALL graph, file I/O table, and a list of GO TO
hotspots.

@legacy-code Walk me through examples/cobol/NB_POST.JCL step by step.
What happens if RUNPOST fails partway through?

@review Review NB_POST.CBL. Focus on: restartability, transaction
boundaries around EXEC SQL, and the GO TO branch in 2200-POST-INVOICE.

@knowledge What does status code 'Z9' mean? Cite tribal sources.
```
