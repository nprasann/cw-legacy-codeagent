-- ============================================================
-- usp_PostClaimApproval
--
-- Stored procedure called from ApproveClaimAction.execute()
-- (examples/struts/.../ApproveClaimAction.java) when a user
-- clicks "Approve" on the Approve Claim screen.
--
-- LEGACY PATTERNS DEMONSTRATED
-- ----------------------------
--  1. Mutates several tables but has no explicit transaction.
--  2. Reads STATUS_CD without locking, then writes - classic
--     lost-update race.
--  3. Hard-codes magic status codes and routing-flag positions.
--  4. Audit insertion duplicated here AND in trg_ClaimAudit ->
--     double-counted history rows in some flows.
--  5. Side effect: enqueues a row into INVOICE_POSTING that the
--     nightly COBOL batch is expected to pick up.
-- ============================================================

IF OBJECT_ID('BILLING.usp_PostClaimApproval', 'P') IS NOT NULL
    DROP PROCEDURE BILLING.usp_PostClaimApproval;
GO

CREATE PROCEDURE BILLING.usp_PostClaimApproval
    @ClaimId    CHAR(12),
    @ApproverId VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustomerId   CHAR(10),
            @ApprovedAmt  DECIMAL(13,2),
            @OldStatus    CHAR(2),
            @RoutingFlags CHAR(4);

    -- LEGACY: NOLOCK read then write -> lost-update race.
    SELECT  @CustomerId   = CUSTOMER_ID,
            @ApprovedAmt  = APPROVED_AMT,
            @OldStatus    = STATUS_CD,
            @RoutingFlags = ROUTING_FLAGS
      FROM  BILLING.CLAIM WITH (NOLOCK)
     WHERE  CLAIM_ID = @ClaimId;

    IF @CustomerId IS NULL
    BEGIN
        -- LEGACY: silent return instead of RAISERROR / THROW.
        PRINT 'usp_PostClaimApproval: claim not found ' + @ClaimId;
        RETURN;
    END

    -- LEGACY: routing-flag position 1 = 'rush', position 2 = 'audit'.
    -- Documented only in an SME memo.
    DECLARE @IsRush  BIT = CASE WHEN SUBSTRING(@RoutingFlags,1,1) = 'Y'
                                THEN 1 ELSE 0 END;
    DECLARE @NeedsAudit BIT = CASE WHEN SUBSTRING(@RoutingFlags,2,1) = 'Y'
                                   THEN 1 ELSE 0 END;

    -- LEGACY: no BEGIN TRAN around the multi-statement update.
    UPDATE BILLING.CLAIM
       SET STATUS_CD   = 'A',
           APPROVED_BY = @ApproverId,
           APPROVED_DT = GETDATE(),
           UPDATED_BY  = @ApproverId,
           UPDATED_DT  = GETDATE()
     WHERE CLAIM_ID = @ClaimId;

    -- LEGACY: this insert is duplicated by trg_ClaimAudit AFTER UPDATE
    -- on CLAIM - so history gets two rows for the same change.
    INSERT INTO BILLING.CLAIM_HISTORY
        (CLAIM_ID, OLD_STATUS_CD, NEW_STATUS_CD,
         OLD_AMT, NEW_AMT, CHANGED_BY, CHANGE_NOTE)
    VALUES
        (@ClaimId, @OldStatus, 'A',
         @ApprovedAmt, @ApprovedAmt, @ApproverId,
         'Approved via web');

    -- LEGACY: enqueue a row for the nightly COBOL batch.
    -- INVOICE_ID is fabricated from CLAIM_ID + a synthetic suffix -
    -- collision risk if a claim is approved more than once in a day.
    INSERT INTO BILLING.INVOICE_POSTING
        (INVOICE_ID, CUSTOMER_ID, CLAIM_ID,
         AMT_DUE, STATUS_CD, POST_DT,
         SOURCE_SYS, USER_ID, ROUTING_FLAGS)
    VALUES
        (LEFT(@ClaimId, 8) + RIGHT(CONVERT(VARCHAR(8),
            CONVERT(INT, RAND() * 99999999)), 4),
         @CustomerId, @ClaimId,
         @ApprovedAmt, 'A', CAST(GETDATE() AS DATE),
         'WEB ', LEFT(@ApproverId, 8),
         CASE WHEN @IsRush = 1 THEN 'Y' ELSE 'N' END +
         CASE WHEN @NeedsAudit = 1 THEN 'Y' ELSE 'N' END + 'NN');
END
GO
