# Table: sq_FAS (Financial Accounting System)

## Table Overview
`sq_FAS` is the core general ledger table. Every accounting transaction (Journal Vouchers, Cash/Bank entries, Billing effects) results in one or more rows here.

## Column Grouping

### Identification
- `CNO` / `VNO` / `TYPE`: Join keys to the source transaction (e.g., `sq_BILLS`).
- `SRNO`: Serial number for multiple effects in one voucher.
- `code`: **Foreign Key**. The specific ledger being affected (links to `sq_MASTER.code`).

### Financials
- `DRAMT`: Debit amount.
- `CRAMT`: Credit amount.
- `RUNBAL`: The running balance of the account *at the time of the transaction*.
- `ACTAMT`: The actual currency amount if different from the ledger value (commissions, etc.).

### Context
- `RMK`: Transaction narrative/narration.
- `BILLNO` / `BILLDATE`: Original bill details for reference.
- `DOCNO`: Physical document number (e.g., Cheque No).
- `PAGENO`: Legacy manual ledger page reference.

### System & Audit
- `RECDATE`: Recording date in the system.
- `UPDATETIME`: User audit timestamp.

## Column Relevance
- `ISGR`: Flag indicating a "Grey" module transaction.
- `int_dispute`: Flag for interest calculation disputes.
- `CLEARSTATUS`: Banking clearance status.

## SQL Snippets (Postgres)
```sql
-- Get the detailed ledger for a specific party
SELECT "DATE", "RMK", "DRAMT", "CRAMT", "RUNBAL"
FROM "IMMBE2627"."sq_FAS"
WHERE "code" = 'A001'
ORDER BY "DATE" ASC, "SRNO" ASC;
```
