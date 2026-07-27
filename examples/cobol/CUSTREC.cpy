      *> ============================================================
      *> Copybook : CUSTREC
      *> Purpose  : Customer master record layout, used by lookup
      *>            programs that join against INVOICE_POSTING.
      *>
      *> LEGACY PATTERNS DEMONSTRATED
      *> ----------------------------
      *> - Wide record (300 bytes) with multiple "flag" fields whose
      *>   meaning is positional (each byte is its own boolean).
      *> - Date stored as YYYYMMDD numeric - prone to comparison bugs
      *>   when joined against character dates from INVREC.
      *> ============================================================
       01  CUSTOMER-REC-LAYOUT.
           05 CUST-CUSTOMER-ID      PIC X(10).
           05 CUST-NAME             PIC X(40).
           05 CUST-ADDR-LINE-1      PIC X(40).
           05 CUST-ADDR-LINE-2      PIC X(40).
           05 CUST-CITY             PIC X(30).
           05 CUST-STATE            PIC X(02).
           05 CUST-ZIP              PIC X(10).
           05 CUST-OPEN-DT          PIC 9(08).
           05 CUST-CLOSE-DT         PIC 9(08).
      *> Each byte in CUST-FLAGS is a separate boolean. Documented
      *> only in knowledge/tribal/cust-flags-bit-layout.md (if added).
           05 CUST-FLAGS.
               10 CUST-FLAG-VIP        PIC X.
               10 CUST-FLAG-DELINQ     PIC X.
               10 CUST-FLAG-LITIGATION PIC X.
               10 CUST-FLAG-NO-MAIL    PIC X.
               10 CUST-FLAG-RSRVD-1    PIC X.
               10 CUST-FLAG-RSRVD-2    PIC X.
           05 FILLER                PIC X(108).
