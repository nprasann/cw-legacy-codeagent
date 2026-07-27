-- ============================================================
-- sample_data.sql
-- Small, masked sample rows so demos have something to query.
-- ============================================================

DELETE FROM BILLING.CLAIM_HISTORY;
DELETE FROM BILLING.INVOICE_POSTING;
DELETE FROM BILLING.CLAIM;
DELETE FROM BILLING.CUSTOMER;
GO

INSERT INTO BILLING.CUSTOMER
    (CUSTOMER_ID, CUST_NAME, ADDR_LINE_1, CITY, STATE_CD, ZIP,
     PHONE_1, CUST_FLAGS, STATUS_CD, OPEN_DT, NOTES, CREATED_BY)
VALUES
    ('C000000001','ACME RETAIL CO','100 MAIN ST','SEATTLE','WA','98101',
     '206-555-0100','YNNNNNNN','A','2008-04-12','VIP - net 30',
     'legacy-load'),
    ('C000000002','BETA HOSPITALITY','22 PIKE PL','SEATTLE','WA','98101',
     '206-555-0200','NNNNNNNN','H','2014-09-01','On hold pending audit',
     'legacy-load'),
    ('C000000003','GAMMA LOGISTICS','9 BROADWAY','PORTLAND','OR','97201',
     '503-555-0300','NYNNNNNN','A','2003-01-30','delinquent flag set',
     'legacy-load');
GO

INSERT INTO BILLING.CLAIM
    (CLAIM_ID, CUSTOMER_ID, CLAIM_DT, CLAIM_AMT, APPROVED_AMT,
     STATUS_CD, ROUTING_FLAGS, SOURCE_SYS, NOTES, CREATED_BY)
VALUES
    ('CLM000000001','C000000001','2026-06-01',  1250.00,  1250.00,
     'P','YNNN','WEB ','rush approval requested','legacy-load'),
    ('CLM000000002','C000000002','2026-06-02', 17800.00,     0.00,
     'H','NNNN','BTCH','customer on hold','legacy-load'),
    ('CLM000000003','C000000003','2026-06-03',   430.55,   430.55,
     'A','NYNN','WEB ','needs post-audit','legacy-load'),
    ('CLM000000004','C000000001','2026-06-04',     0.00,     0.00,
     'Z9','NNNN','BTCH','special hold per SME','legacy-load');
GO

INSERT INTO BILLING.INVOICE_POSTING
    (INVOICE_ID, CUSTOMER_ID, CLAIM_ID, AMT_DUE, AMT_PAID,
     STATUS_CD, POST_DT, SOURCE_SYS, USER_ID, ROUTING_FLAGS)
VALUES
    ('INV000000001','C000000001','CLM000000001', 1250.00,    0.00,
     'A', CAST(GETDATE() AS DATE), 'WEB ','jdoe','YNNN'),
    ('INV000000003','C000000003','CLM000000003',  430.55,    0.00,
     'A', CAST(GETDATE() AS DATE), 'WEB ','asmith','NYNN'),
    ('INV000000004','C000000001','CLM000000004',    0.00,    0.00,
     'Z9',CAST(GETDATE() AS DATE), 'BTCH','batchusr','NNNN');
GO
