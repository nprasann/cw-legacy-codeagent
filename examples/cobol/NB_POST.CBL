      *> ============================================================
      *> Program : NB_POST
      *> Purpose : Nightly Billing Posting batch.
      *>           Reads pending invoice transactions from a flat file,
      *>           validates them, posts approved rows to the
      *>           BILLING.INVOICE table via EXEC SQL, and writes
      *>           rejects to a reject file for manual review.
      *>
      *> Author  : (unknown - originally 1998, modified many times)
      *> Schedule: Control-M job NB_POST_NIGHTLY, runs 02:00 daily
      *>
      *> LEGACY PATTERNS DEMONSTRATED
      *> ----------------------------
      *> 1. Mixed PERFORM and GO TO control flow (PROCEDURE DIVISION).
      *> 2. COMP-3 (packed-decimal) money fields - watch sign handling.
      *> 3. Copybook-driven record layouts (see CUSTREC, INVREC).
      *> 4. Embedded EXEC SQL with implicit transaction boundaries.
      *> 5. Single-letter status codes ('A','R','H','Z9') with meaning
      *>    only documented in tribal knowledge.
      *> 6. No structured checkpoint / restart - relies on operator to
      *>    re-run with a "skip count" parameter.
      *> ============================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID.    NB-POST.
       AUTHOR.        LEGACY-TEAM.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INVOICE-IN  ASSIGN TO 'INVIN'
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-INVIN-STATUS.

           SELECT REJECT-OUT  ASSIGN TO 'REJOUT'
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REJOUT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  INVOICE-IN
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           LABEL RECORDS ARE STANDARD.
       01  INVOICE-REC.
           COPY INVREC.

       FD  REJECT-OUT
           RECORDING MODE IS F.
       01  REJECT-REC PIC X(200).

       WORKING-STORAGE SECTION.
      *> -- File status fields --
       01  WS-INVIN-STATUS    PIC XX VALUE '00'.
       01  WS-REJOUT-STATUS   PIC XX VALUE '00'.

      *> -- Counters --
       01  WS-COUNTERS.
           05 WS-READ-CT      PIC 9(7) COMP-3 VALUE 0.
           05 WS-POST-CT      PIC 9(7) COMP-3 VALUE 0.
           05 WS-REJECT-CT    PIC 9(7) COMP-3 VALUE 0.
           05 WS-HOLD-CT      PIC 9(7) COMP-3 VALUE 0.

      *> -- Money work fields (COMP-3, signed) --
       01  WS-MONEY.
           05 WS-AMT-DUE      PIC S9(9)V99 COMP-3 VALUE 0.
           05 WS-AMT-PAID     PIC S9(9)V99 COMP-3 VALUE 0.
           05 WS-AMT-DELTA    PIC S9(9)V99 COMP-3 VALUE 0.

      *> -- Flags & switches --
       01  WS-EOF-FLAG        PIC X VALUE 'N'.
           88 END-OF-INVOICES         VALUE 'Y'.
           88 NOT-END-OF-INVOICES     VALUE 'N'.

      *> -- SQL host variables --
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-INVOICE-ID      PIC X(12).
       01  HV-CUSTOMER-ID     PIC X(10).
       01  HV-AMT-DUE         PIC S9(9)V99 COMP-3.
       01  HV-STATUS-CD       PIC X(2).
       01  HV-POST-DT         PIC X(10).
           EXEC SQL END DECLARE SECTION END-EXEC.

           EXEC SQL INCLUDE SQLCA END-EXEC.

       PROCEDURE DIVISION.
      *> ------------------------------------------------------------
      *> Main control flow. Mixes PERFORM (structured) with one
      *> legacy GO TO branch around the EXEC SQL block - kept because
      *> the rewrite in 2007 reportedly broke nightly posting.
      *> See knowledge/tribal/nb-post-goto.md (if it exists).
      *> ------------------------------------------------------------
       0000-MAIN.
           PERFORM 1000-OPEN-FILES
           PERFORM 2000-PROCESS-INVOICES UNTIL END-OF-INVOICES
           PERFORM 9000-CLOSE-FILES
           PERFORM 9100-WRITE-TOTALS
           STOP RUN.

       1000-OPEN-FILES.
           OPEN INPUT  INVOICE-IN
           OPEN OUTPUT REJECT-OUT
           IF WS-INVIN-STATUS NOT = '00'
               DISPLAY 'NB-POST: INVIN OPEN FAILED ' WS-INVIN-STATUS
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF.

       2000-PROCESS-INVOICES.
           READ INVOICE-IN
               AT END
                   MOVE 'Y' TO WS-EOF-FLAG
                   GO TO 2000-EXIT
           END-READ
           ADD 1 TO WS-READ-CT
           PERFORM 2100-VALIDATE-INVOICE
           IF HV-STATUS-CD = 'A'
               PERFORM 2200-POST-INVOICE
           ELSE IF HV-STATUS-CD = 'H'
               ADD 1 TO WS-HOLD-CT
           ELSE
               PERFORM 2300-WRITE-REJECT
           END-IF.
       2000-EXIT.
           EXIT.

       2100-VALIDATE-INVOICE.
      *> Copy fields from the input record (see copybook INVREC).
           MOVE INV-INVOICE-ID  TO HV-INVOICE-ID
           MOVE INV-CUSTOMER-ID TO HV-CUSTOMER-ID
           MOVE INV-AMT-DUE     TO HV-AMT-DUE
           MOVE INV-STATUS-CD   TO HV-STATUS-CD
      *> Legacy rule: status 'Z9' means "do not post, do not reject" -
      *> just count as held. Documented only in SME interview notes.
           IF HV-STATUS-CD = 'Z9'
               MOVE 'H' TO HV-STATUS-CD
           END-IF.

       2200-POST-INVOICE.
      *> ---- LEGACY GO TO: intentionally preserved ----
      *> If amount is zero, skip the INSERT but still count as posted
      *> to keep parity with the 1998 ledger reconciliation report.
           IF HV-AMT-DUE = 0
               GO TO 2200-SKIP-INSERT
           END-IF.

           EXEC SQL
               INSERT INTO BILLING.INVOICE_POSTING
                   (INVOICE_ID, CUSTOMER_ID, AMT_DUE,
                    STATUS_CD, POST_DT)
               VALUES
                   (:HV-INVOICE-ID, :HV-CUSTOMER-ID, :HV-AMT-DUE,
                    :HV-STATUS-CD, CURRENT DATE)
           END-EXEC.

           IF SQLCODE NOT = 0
               DISPLAY 'NB-POST: INSERT FAILED SQLCODE=' SQLCODE
                       ' INV=' HV-INVOICE-ID
               PERFORM 2300-WRITE-REJECT
               GO TO 2200-EXIT
           END-IF.

       2200-SKIP-INSERT.
           ADD 1 TO WS-POST-CT.
       2200-EXIT.
           EXIT.

       2300-WRITE-REJECT.
           STRING 'REJ '   DELIMITED BY SIZE
                  HV-INVOICE-ID DELIMITED BY SIZE
                  ' '      DELIMITED BY SIZE
                  HV-STATUS-CD  DELIMITED BY SIZE
               INTO REJECT-REC
           WRITE REJECT-REC
           ADD 1 TO WS-REJECT-CT.

       9000-CLOSE-FILES.
           CLOSE INVOICE-IN
           CLOSE REJECT-OUT.

       9100-WRITE-TOTALS.
           DISPLAY '================ NB-POST TOTALS ================'
           DISPLAY 'READ    : ' WS-READ-CT
           DISPLAY 'POSTED  : ' WS-POST-CT
           DISPLAY 'HELD    : ' WS-HOLD-CT
           DISPLAY 'REJECTED: ' WS-REJECT-CT
           DISPLAY '================================================'.
