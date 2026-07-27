-- ============================================================
-- usp_NightlyPostings
--
-- Stored procedure invoked by the nightly batch (NB_POST_NIGHTLY)
-- after the COBOL program (NB_POST.CBL) finishes loading
-- INVOICE_POSTING. Its job is to:
--
--   1. Recompute customer balances.
--   2. Roll-up postings into CLAIM aggregates.
--   3. Update CLAIM.STATUS_CD based on payment thresholds.
--
-- LEGACY PATTERNS DEMONSTRATED
-- ----------------------------
--  1. Cursor-driven row-at-a-time processing.
--  2. NOLOCK hints everywhere "for performance" -> dirty reads.
--  3. Dynamic SQL built by string concatenation.
--  4. No explicit transaction boundary around multi-statement work.
--  5. Magic status codes ('A','R','H','Z9') hard-coded.
--  6. SET ROWCOUNT used instead of TOP - deprecated for DML.
--  7. Silent error handling: errors are PRINT'ed, not raised.
--  8. Implicit conversions on join keys (CHAR vs VARCHAR).
--  9. PRINT-based "logging" with no correlation id.
-- 10. Side effects mixed with reads - hard to test.
-- ============================================================

IF OBJECT_ID('BILLING.usp_NightlyPostings', 'P') IS NOT NULL
    DROP PROCEDURE BILLING.usp_NightlyPostings;
GO

CREATE PROCEDURE BILLING.usp_NightlyPostings
    @RunDt DATETIME = NULL          -- LEGACY: defaults to GETDATE() inside body
AS
BEGIN
    SET NOCOUNT ON;

    IF @RunDt IS NULL
        SET @RunDt = GETDATE();

    PRINT '--- usp_NightlyPostings start ' + CONVERT(VARCHAR(30), @RunDt, 121);

    -- LEGACY: cursor over today's postings.
    DECLARE @InvoiceId   CHAR(12),
            @ClaimId     CHAR(12),
            @CustomerId  CHAR(10),
            @AmtDue      DECIMAL(13,2),
            @StatusCd    CHAR(2);

    DECLARE post_cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT  ip.INVOICE_ID,
                ip.CLAIM_ID,
                ip.CUSTOMER_ID,
                ip.AMT_DUE,
                ip.STATUS_CD
          FROM  BILLING.INVOICE_POSTING ip WITH (NOLOCK)
         WHERE  CAST(ip.POST_DT AS DATE) = CAST(@RunDt AS DATE);

    OPEN post_cur;
    FETCH NEXT FROM post_cur
        INTO @InvoiceId, @ClaimId, @CustomerId, @AmtDue, @StatusCd;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- LEGACY: dynamic SQL by concatenation - SQL injection if
            -- any input had been untrusted. Also forces re-parse.
            DECLARE @sql NVARCHAR(MAX);
            SET @sql =
                N'UPDATE BILLING.CLAIM ' +
                N'   SET PAID_AMT = ISNULL(PAID_AMT,0) + ' +
                        CONVERT(NVARCHAR(20), @AmtDue) + N', ' +
                N'       UPDATED_DT = GETDATE() ' +
                N' WHERE CLAIM_ID = ''' + @ClaimId + N'''';
            EXEC sp_executesql @sql;

            -- LEGACY: branching on magic codes; 'Z9' is the special-hold
            -- documented only in tribal notes.
            IF @StatusCd = 'A'
            BEGIN
                UPDATE BILLING.CLAIM
                   SET STATUS_CD = 'C'              -- 'C' = closed-paid
                 WHERE CLAIM_ID = @ClaimId
                   AND ISNULL(PAID_AMT,0) >= ISNULL(APPROVED_AMT,0);
            END
            ELSE IF @StatusCd = 'Z9'
            BEGIN
                -- LEGACY: do not touch the row, but still log to history.
                INSERT INTO BILLING.CLAIM_HISTORY
                    (CLAIM_ID, OLD_STATUS_CD, NEW_STATUS_CD,
                     CHANGED_BY, CHANGE_NOTE)
                VALUES
                    (@ClaimId, @StatusCd, @StatusCd,
                     SUSER_SNAME(),
                     'Z9 hold - posted but not closed');
            END

            -- LEGACY: implicit conversion CHAR(10) vs VARCHAR can suppress
            -- index usage on CUSTOMER lookups.
            IF EXISTS (
                SELECT 1
                  FROM BILLING.CUSTOMER c WITH (NOLOCK)
                 WHERE c.CUSTOMER_ID = @CustomerId
                   AND c.STATUS_CD   = 'H'
            )
            BEGIN
                -- LEGACY: SET ROWCOUNT instead of TOP for DML (deprecated).
                SET ROWCOUNT 1;
                UPDATE BILLING.CLAIM
                   SET STATUS_CD = 'H',
                       NOTES = ISNULL(NOTES,'') +
                               CHAR(10) +
                               'Auto-hold (customer on hold) ' +
                               CONVERT(VARCHAR(30), GETDATE(), 121)
                 WHERE CLAIM_ID = @ClaimId;
                SET ROWCOUNT 0;
            END
        END TRY
        BEGIN CATCH
            -- LEGACY: swallow and print, do not raise. Batch keeps going.
            PRINT 'ERROR on invoice ' + @InvoiceId +
                  ': ' + ERROR_MESSAGE();
        END CATCH

        FETCH NEXT FROM post_cur
            INTO @InvoiceId, @ClaimId, @CustomerId, @AmtDue, @StatusCd;
    END

    CLOSE post_cur;
    DEALLOCATE post_cur;

    PRINT '--- usp_NightlyPostings end ' +
          CONVERT(VARCHAR(30), GETDATE(), 121);
END
GO
