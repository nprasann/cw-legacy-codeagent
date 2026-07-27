# Examples

Realistic-but-synthetic legacy artifacts used to demo the
**cw-legacy-codeagent** assistant. Designed to be small enough to read in one
sitting, yet packed with the anti-patterns and "load-bearing legacy" quirks
that the agents are built to explain, review, and modernize.

| Folder | Stack | What it demonstrates |
|--------|-------|----------------------|
| [`cobol/`](./cobol/) | COBOL + JCL + copybooks | Nightly batch posting job: file I/O, `PERFORM`, `GO TO`, packed-decimal (COMP-3), EXEC SQL, checkpoint comments |
| [`struts/`](./struts/) | Apache Struts 1.0 (Java + XML + JSP) | Classic Action / ActionForm / struts-config flow with validation, session abuse, and DB call inline |
| [`sql/`](./sql/) | MS SQL Server (T-SQL) | Wide non-normalized schema, overloaded columns, magic codes, cursor-heavy stored procedure |

## Suggested demo prompts

```
@legacy-code Explain examples/cobol/NB_POST.CBL end-to-end. Produce a
division map, PERFORM/CALL graph, and flag GO TO hotspots.

@legacy-code Trace the request flow for examples/struts/ApproveClaimAction.java
from struts-config.xml to the JSP response.

@legacy-code Analyze examples/sql/schema.sql: list overloaded columns,
infer implicit relationships, and rank normalization opportunities.

@review Review examples/sql/usp_NightlyPostings.sql with security,
correctness, and performance lenses.

@review Score modernization opportunities for examples/struts/. Output
value (1-5), blast radius (1-5), and recommended sequencing.
```

> Files here are intentionally **flawed**. They exist to be explained and
> reviewed, not copied into production.
