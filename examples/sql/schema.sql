-- ============================================================
-- schema.sql
-- Legacy "BILLING" schema for the cw-legacy-codeagent demo.
--
-- Intentionally non-normalized, overloaded, and under-constrained
-- to demonstrate the patterns the assistant is designed to explain
-- and review. DO NOT COPY INTO PRODUCTION.
--
-- LEGACY PATTERNS DEMONSTRATED
-- ----------------------------
--  1. Wide tables with dozens of nullable columns.
--  2. Magic 1-2 character status codes ('A','R','H','Z9') with
--     meaning only documented in tribal notes.
--  3. Overloaded columns: ROUTING_FLAGS used as a 4-char bitfield.
--  4. Repeating groups (PHONE_1..PHONE_3, ADDR_LINE_1..ADDR_LINE_3)
--     instead of child tables.
--  5. Implicit relationships: CUSTOMER_ID is a string in every table
--     but no FOREIGN KEY constraint exists.
--  6. Free-text "NOTES" columns carrying semi-structured business
--     data parsed by downstream batch programs.
--  7. Mix of GETDATE() defaults and externally-supplied date strings
--     causing time-zone and format drift.
--  8. Audit columns repeated on every table instead of a shared
--     audit pattern.
--  9. Stored-procedure-centric architecture: business rules live in
--     usp_* and trg_* objects, not the app.
-- ============================================================

IF SCHEMA_ID(N'BILLING') IS NULL
    EXEC(N'CREATE SCHEMA BILLING');
GO

-- ------------------------------------------------------------
-- BILLING.CUSTOMER
-- Wide, denormalized customer master.
-- ------------------------------------------------------------
IF OBJECT_ID('BILLING.CUSTOMER', 'U') IS NOT NULL
    DROP TABLE BILLING.CUSTOMER;
GO
CREATE TABLE BILLING.CUSTOMER (
    CUSTOMER_ID     CHAR(10)     NOT NULL,        -- PK by convention, no constraint named
    CUST_NAME       VARCHAR(80)  NULL,
    -- LEGACY: repeating address group instead of an ADDRESS child table
    ADDR_LINE_1     VARCHAR(80)  NULL,
    ADDR_LINE_2     VARCHAR(80)  NULL,
    ADDR_LINE_3     VARCHAR(80)  NULL,
    CITY            VARCHAR(40)  NULL,
    STATE_CD        CHAR(2)      NULL,
    ZIP             VARCHAR(10)  NULL,
    -- LEGACY: repeating phone group
    PHONE_1         VARCHAR(20)  NULL,
    PHONE_2         VARCHAR(20)  NULL,
    PHONE_3         VARCHAR(20)  NULL,
    -- LEGACY: bitfield-as-string. Each char is a separate boolean flag.
    -- See knowledge/tribal/cust-flags-bit-layout.md (when added).
    CUST_FLAGS      CHAR(8)      NULL,            -- 'Y/N/Y/N...' per position
    -- LEGACY: 1-char status carries multiple meanings
    -- A=Active, I=Inactive, H=Hold, X=Suspended, Z=Special
    STATUS_CD       CHAR(1)      NULL,
    OPEN_DT         DATETIME     NULL,
    CLOSE_DT        DATETIME     NULL,
    -- LEGACY: free-text NOTES parsed by batch jobs for keywords
    NOTES           VARCHAR(4000) NULL,
    CREATED_BY      VARCHAR(20)  NULL,
    CREATED_DT      DATETIME     NULL DEFAULT GETDATE(),
    UPDATED_BY      VARCHAR(20)  NULL,
    UPDATED_DT      DATETIME     NULL
);
GO
-- LEGACY: PK added separately, name not standardized
ALTER TABLE BILLING.CUSTOMER
    ADD CONSTRAINT PK_CUSTOMER PRIMARY KEY CLUSTERED (CUSTOMER_ID);
GO

-- ------------------------------------------------------------
-- BILLING.CLAIM
-- Wide claim table. Overloaded status code + flags.
-- ------------------------------------------------------------
IF OBJECT_ID('BILLING.CLAIM', 'U') IS NOT NULL
    DROP TABLE BILLING.CLAIM;
GO
CREATE TABLE BILLING.CLAIM (
    CLAIM_ID        CHAR(12)     NOT NULL,
    CUSTOMER_ID     CHAR(10)     NULL,            -- LEGACY: no FK to CUSTOMER
    CLAIM_DT        DATETIME     NULL,
    CLAIM_AMT       DECIMAL(13,2) NULL,
    APPROVED_AMT    DECIMAL(13,2) NULL,
    PAID_AMT        DECIMAL(13,2) NULL,
    -- LEGACY: 2-char status code with magic values
    -- A=Approved, R=Rejected, H=Hold, P=Pending, Z9=Special hold
    STATUS_CD       CHAR(2)      NULL,
    -- LEGACY: ROUTING_FLAGS reused for multiple purposes since 2011.
    -- Each byte is its own meaning - mapping in an SME memo.
    ROUTING_FLAGS   CHAR(4)      NULL,
    APPROVED_BY     VARCHAR(20)  NULL,
    APPROVED_DT     DATETIME     NULL,
    REJECTED_BY     VARCHAR(20)  NULL,
    REJECTED_DT     DATETIME     NULL,
    -- LEGACY: source system stored as 4-char code; mapping nowhere documented
    SOURCE_SYS      CHAR(4)      NULL,
    -- LEGACY: free-text NOTES that downstream jobs grep for keywords
    NOTES           VARCHAR(4000) NULL,
    CREATED_BY      VARCHAR(20)  NULL,
    CREATED_DT      DATETIME     NULL DEFAULT GETDATE(),
    UPDATED_BY      VARCHAR(20)  NULL,
    UPDATED_DT      DATETIME     NULL
);
GO
ALTER TABLE BILLING.CLAIM
    ADD CONSTRAINT PK_CLAIM PRIMARY KEY CLUSTERED (CLAIM_ID);
GO
-- LEGACY: only one non-PK index, on a column most queries do NOT filter by
CREATE NONCLUSTERED INDEX IX_CLAIM_CREATED_DT
    ON BILLING.CLAIM (CREATED_DT);
GO

-- ------------------------------------------------------------
-- BILLING.INVOICE_POSTING
-- Target of the nightly NB_POST batch (see examples/cobol/NB_POST.CBL).
-- ------------------------------------------------------------
IF OBJECT_ID('BILLING.INVOICE_POSTING', 'U') IS NOT NULL
    DROP TABLE BILLING.INVOICE_POSTING;
GO
CREATE TABLE BILLING.INVOICE_POSTING (
    INVOICE_ID      CHAR(12)     NOT NULL,
    CUSTOMER_ID     CHAR(10)     NULL,            -- LEGACY: no FK
    CLAIM_ID        CHAR(12)     NULL,            -- LEGACY: no FK
    AMT_DUE         DECIMAL(13,2) NULL,
    AMT_PAID        DECIMAL(13,2) NULL,
    STATUS_CD       CHAR(2)      NULL,            -- mirrors CLAIM.STATUS_CD
    POST_DT         DATE         NULL,            -- LEGACY: DATE here, DATETIME elsewhere
    SOURCE_SYS      CHAR(4)      NULL,
    USER_ID         VARCHAR(8)   NULL,
    ROUTING_FLAGS   CHAR(4)      NULL,
    CREATED_DT      DATETIME     NULL DEFAULT GETDATE()
);
GO
ALTER TABLE BILLING.INVOICE_POSTING
    ADD CONSTRAINT PK_INVOICE_POSTING PRIMARY KEY CLUSTERED (INVOICE_ID);
GO

-- ------------------------------------------------------------
-- BILLING.CLAIM_HISTORY
-- "Audit" table populated by a trigger - shape drifts from CLAIM.
-- ------------------------------------------------------------
IF OBJECT_ID('BILLING.CLAIM_HISTORY', 'U') IS NOT NULL
    DROP TABLE BILLING.CLAIM_HISTORY;
GO
CREATE TABLE BILLING.CLAIM_HISTORY (
    HIST_ID         BIGINT       IDENTITY(1,1) NOT NULL,
    CLAIM_ID        CHAR(12)     NULL,            -- LEGACY: no FK
    OLD_STATUS_CD   CHAR(2)      NULL,
    NEW_STATUS_CD   CHAR(2)      NULL,
    OLD_AMT         DECIMAL(13,2) NULL,
    NEW_AMT         DECIMAL(13,2) NULL,
    CHANGED_BY      VARCHAR(20)  NULL,
    CHANGED_DT      DATETIME     NULL DEFAULT GETDATE(),
    -- LEGACY: rationale captured as free text; consumers parse it.
    CHANGE_NOTE     VARCHAR(2000) NULL
);
GO
ALTER TABLE BILLING.CLAIM_HISTORY
    ADD CONSTRAINT PK_CLAIM_HISTORY PRIMARY KEY CLUSTERED (HIST_ID);
GO

-- ------------------------------------------------------------
-- trg_ClaimAudit
-- Trigger that mirrors CLAIM changes into CLAIM_HISTORY.
-- LEGACY: only watches STATUS_CD and APPROVED_AMT; silently ignores
-- other column changes - a known source of audit gaps.
-- ------------------------------------------------------------
IF OBJECT_ID('BILLING.trg_ClaimAudit', 'TR') IS NOT NULL
    DROP TRIGGER BILLING.trg_ClaimAudit;
GO
CREATE TRIGGER BILLING.trg_ClaimAudit
ON BILLING.CLAIM
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- LEGACY: assumes single-row updates; multi-row updates corrupt audit.
    INSERT INTO BILLING.CLAIM_HISTORY
        (CLAIM_ID, OLD_STATUS_CD, NEW_STATUS_CD,
         OLD_AMT, NEW_AMT, CHANGED_BY, CHANGE_NOTE)
    SELECT  i.CLAIM_ID,
            d.STATUS_CD,
            i.STATUS_CD,
            d.APPROVED_AMT,
            i.APPROVED_AMT,
            SUSER_SNAME(),
            'auto-audit'
      FROM inserted i
      JOIN deleted  d ON d.CLAIM_ID = i.CLAIM_ID;
END
GO
