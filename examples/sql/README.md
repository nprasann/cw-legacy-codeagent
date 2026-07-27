# SQL Server Example — Legacy `BILLING` Schema

A deliberately non-normalized Microsoft SQL Server schema plus two
representative stored procedures. Designed for the assistant to explain,
review, and propose modernization steps against.

## Files

| File | Purpose |
|------|---------|
| [`schema.sql`](./schema.sql) | DDL for `CUSTOMER`, `CLAIM`, `INVOICE_POSTING`, `CLAIM_HISTORY`, and `trg_ClaimAudit`. |
| [`usp_NightlyPostings.sql`](./usp_NightlyPostings.sql) | Cursor-driven nightly roll-up SP invoked after the COBOL batch. |
| [`usp_PostClaimApproval.sql`](./usp_PostClaimApproval.sql) | SP called from the Struts `ApproveClaimAction` when a claim is approved. |
| [`sample_data.sql`](./sample_data.sql) | Small masked sample rows for demos. |

## Legacy patterns to demo

**Schema**
- Wide tables with many nullable columns.
- Repeating groups (`ADDR_LINE_1..3`, `PHONE_1..3`).
- Overloaded `ROUTING_FLAGS` (4-char bitfield, positional meaning).
- `CUST_FLAGS` as Y/N character bitfield.
- Magic status codes (`A/R/H/P/Z9` on `CLAIM`; `A/I/H/X/Z` on `CUSTOMER`).
- No `FOREIGN KEY` constraints; `CUSTOMER_ID`/`CLAIM_ID` are strings linked by convention only.
- Free-text `NOTES` columns parsed by batch programs.
- Inconsistent date types (`DATE` vs `DATETIME`).
- Trigger-based "audit" that mirrors only a couple of columns and assumes single-row updates.

**Stored procedures**
- Cursor row-at-a-time processing.
- `WITH (NOLOCK)` hints everywhere (dirty reads).
- Dynamic SQL by string concatenation.
- No explicit transaction boundary across multi-table writes.
- `SET ROWCOUNT` for DML (deprecated).
- Silent error handling via `PRINT` instead of `THROW`/`RAISERROR`.
- Audit duplication: SP writes to `CLAIM_HISTORY` AND the trigger does too.
- Synthetic `INVOICE_ID` generation via `RAND()` (collision risk).

## Cross-example wiring

```
ApproveClaimAction.java  ── calls ──>  usp_PostClaimApproval
                                            │
                                            └─ INSERT INTO INVOICE_POSTING
                                                    │
                                                    ▼
NB_POST.CBL (nightly)  ── reads/inserts ──>  INVOICE_POSTING
                                                    │
                                                    ▼
usp_NightlyPostings    ── rolls up ──>       CLAIM / CLAIM_HISTORY
```

## Suggested prompts

```
@legacy-code Analyze examples/sql/schema.sql. Produce a column
dictionary, flag overloaded columns, infer implicit relationships,
and list every object (SP/trigger/job) that reads or writes each table.

@legacy-code Walk me through examples/sql/usp_NightlyPostings.sql.
Identify phases, side effects, and risks introduced by NOLOCK and the
cursor.

@review Review examples/sql/usp_PostClaimApproval.sql for security,
correctness, and concurrency. Pay attention to the audit duplication
and the synthetic INVOICE_ID.

@review Score normalization opportunities for the BILLING schema.
Rank by value vs. blast radius and respect any do-not-touch entries
in /knowledge.

@knowledge What does CLAIM.STATUS_CD = 'Z9' mean? Cite tribal sources.
```
