//NBPOSTJ  JOB  (ACCT),'NIGHTLY BILLING POST',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*============================================================
//* JOB  : NB_POST_NIGHTLY
//* DESC : Nightly billing posting batch.
//*        Runs NB-POST against the pending invoice file,
//*        producing a reject file and updating the
//*        BILLING.INVOICE_POSTING table.
//*
//* SCHEDULE: Control-M trigger NB_POST_NIGHTLY, daily 02:00.
//*
//* LEGACY PATTERNS DEMONSTRATED
//* ----------------------------
//* - Hard-coded DSN paths (no symbolic resolution).
//* - COND=(0,NE,PRESTEP) chain - any non-zero halts the rest.
//* - No checkpoint/restart; failed runs require operator to
//*   pass a SKIPCNT override (not modeled here).
//* - SYSOUT=* relied on for audit; no SMF or structured logs.
//*============================================================
//PRESTEP  EXEC PGM=IEFBR14
//DD1      DD   DSN=BILLING.NB.INVIN.TODAY,DISP=SHR
//*
//RUNPOST  EXEC PGM=NBPOST,COND=(0,NE,PRESTEP)
//STEPLIB  DD   DSN=BILLING.LOADLIB,DISP=SHR
//INVIN    DD   DSN=BILLING.NB.INVIN.TODAY,DISP=SHR
//REJOUT   DD   DSN=BILLING.NB.REJECTS.TODAY,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(CYL,(5,5),RLSE),
//              DCB=(RECFM=FB,LRECL=200,BLKSIZE=0)
//SYSOUT   DD   SYSOUT=*
//SYSPRINT DD   SYSOUT=*
//*
//RPTSTEP  EXEC PGM=NBRPT,COND=(0,NE,RUNPOST)
//STEPLIB  DD   DSN=BILLING.LOADLIB,DISP=SHR
//REJIN    DD   DSN=BILLING.NB.REJECTS.TODAY,DISP=SHR
//RPTOUT   DD   SYSOUT=*
//SYSOUT   DD   SYSOUT=*
//
