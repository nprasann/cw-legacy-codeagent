---
title: "NB_POST: Status Code 'Z9' Special Hold"
type: tribal
subsystem: billing
tags: [cobol, batch, nb-post, magic-code, z9]
sources:
  - "SME interview: J. Doe (Billing Lead), 2024-10-18"
  - "Internal memo: BILL-2014-007 (status code expansion)"
owner: "billing-team"
confidence: high
updated: 2026-04-22
do_not_touch: true
---

# NB_POST: Status Code 'Z9' Special Hold

## Background
The nightly billing posting batch
([examples/cobol/NB_POST.CBL](../../examples/cobol/NB_POST.CBL)) accepts
invoice rows with a 2-char status code in `INV-STATUS-CD`. Most codes are
documented in the original 1998 design (`A`=Approve, `R`=Reject, `H`=Hold).
The code **`Z9`** was added in 2014 and is documented nowhere except this
note.

## Rule
When `INV-STATUS-CD = 'Z9'`:

1. The row is **not** posted to `BILLING.INVOICE_POSTING`.
2. The row is **not** written to the reject file.
3. The row IS counted toward the daily "held" total (`WS-HOLD-CT`).
4. The downstream stored procedure
   ([usp_NightlyPostings](../../examples/sql/usp_NightlyPostings.sql))
   writes a history row tagged `'Z9 hold - posted but not closed'` so the
   audit team can reconcile.

In the COBOL program, this is implemented by `MOVE 'H' TO HV-STATUS-CD` in
paragraph `2100-VALIDATE-INVOICE` immediately when `Z9` is detected.

## Rationale
`Z9` flags accounts under **active legal review**. Posting or rejecting
them would create a discoverable audit event that legal does not want
generated automatically. Compliance signed off on the silent-hold behavior
in memo BILL-2014-007.

## Why this is `do_not_touch: true`
Removing the special-hold behavior would:

- Trigger spurious reject notices to customers under legal review.
- Break the audit reconciliation expected by the Compliance team.
- Violate the documented sign-off in memo BILL-2014-007.

Any change that affects the `Z9` branch in `NB_POST.CBL` paragraph
`2100-VALIDATE-INVOICE` or in `usp_NightlyPostings` requires explicit
sign-off from the Billing Lead AND Compliance.

## Open questions
- The original list of accounts flagged with `Z9` lives in a spreadsheet
  on a retired share. Recovering it would let us add an automated
  sanity-check.
- We have no test fixture for the `Z9` branch. A characterization test
  should be added before any refactor in the area.
