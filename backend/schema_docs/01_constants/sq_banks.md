# Table: sq_banks (Bank Account Master)

## Table Overview
The `sq_banks` table stores metadata for the bank accounts owned by each company entity. It maps physical bank accounts to internal ledger codes.

## Column Grouping

### Identification
- `id`: Internal legacy ID.
- `cno`: **Reference Key**. Links to `sq_COMPMST.CNO`.
- `BANK`: Descriptive name of the bank (e.g., "HDFC BANK").
- `ACNO`: The physical bank account number.

### Financials & Reconciliation
- `RECONBALANCE`: The opening or last reconciled balance (stored as numeric/string depending on legacy sync).
- `chqseries`: Metadata for current cheque leaf series.

### System & Dates
- `fromdate` / `todate`: Validity period of the account in the ERP.
- `seriescode`: Internal series used for JV/Voucher generation for this bank.
- `internet_key`: Legacy field for banking integration.

## Column Relevance
- `cno`: Crucial for filtering accounts belonging to a specific firm (e.g., `cno=10` for Ambaji Sarees main accounts).
- `RECONBALANCE`: Used as a starting point for bank reconciliation screens.

## Filters & Identification
- **Active Accounts**: Filter where `todate` is NULL or in the future.
- **Main Account**: Usually identified by `id=14` for `cno=10`.

## SQL Snippets (Postgres)
```sql
-- List all bank accounts for a specific company
SELECT * FROM "IMMBE2627"."sq_banks" WHERE "cno" = 10;

-- Get the reconciliation balance for the main bank
SELECT "BANK", "ACNO", "RECONBALANCE" FROM "IMMBE2627"."sq_banks" WHERE "id" = 14;
```
