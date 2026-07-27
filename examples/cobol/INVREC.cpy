      *> ============================================================
      *> Copybook : INVREC
      *> Purpose  : Layout for the nightly invoice input file (INVIN).
      *>
      *> LEGACY PATTERNS DEMONSTRATED
      *> ----------------------------
      *> - Fixed-width sequential record (200 bytes).
      *> - COMP-3 (packed-decimal) money field with sign.
      *> - Filler used as "future growth" space, sometimes repurposed
      *>   without updating downstream consumers.
      *> - Status code is a 2-char field with magic values documented
      *>   only in tribal knowledge (A=Approved, R=Reject, H=Hold,
      *>   Z9=Special hold, see knowledge/tribal).
      *> ============================================================
       01  INVOICE-REC-LAYOUT.
           05 INV-INVOICE-ID        PIC X(12).
           05 INV-CUSTOMER-ID       PIC X(10).
           05 INV-INVOICE-DT        PIC X(10).
           05 INV-AMT-DUE           PIC S9(9)V99 COMP-3.
           05 INV-AMT-PAID          PIC S9(9)V99 COMP-3.
           05 INV-STATUS-CD         PIC X(02).
           05 INV-SOURCE-SYS        PIC X(04).
           05 INV-USER-ID           PIC X(08).
      *> The next field was originally "branch code" but has been
      *> reused as a bitfield for routing flags since 2011. The
      *> documented mapping lives in an SME memo.
           05 INV-ROUTING-FLAGS     PIC X(04).
           05 FILLER                PIC X(141).
