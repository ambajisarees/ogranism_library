# Table: sq_ATYPE (Account Type Master)

## Table Overview
`sq_ATYPE` defines the grouping logic for all accounts in the general ledger. It determines whether an account belongs to Debtors, Creditors, Assets, Liabilities, or Expenses.

## Column Grouping

### Identification
- `ATYPE`: **Primary Key (Legacy)**. Unique numeric code for the type.
- `NAME`: Descriptive name (e.g., "SUNDRY DEBTORS").
- `LETTER`: A single character identifier (C=Creditor, S=Supplier, E=Expense, etc.).

### Financial Logic
- `MAJORACTYPE`: High-level grouping (e.g., "ASSETS", "LIABILITIES").
- `BALSHEET`: Flag for Balance Sheet placement.
- `PL`: Flag for Profit & Loss statement placement.
- `TRADING`: Flag for Trading account placement.

### Reporting
- `TRIALPOS`: Ordering in the Trial Balance report.
- `TRIALside`: Debit or Credit side in reports.

## Column Relevance
- `LETTER`: Extremely important for quick data entry filters. For example, when searching for a 'Party' in a sales screen, the app filters accounts where `ATYPE.LETTER = 'C'`.
- `ATYPE`: Used as a foreign key in `sq_MASTER` and `sq_ACGROUP`.

## Filters & Identification
- **Debtors**: `ATYPE = 1` or `LETTER = 'S'` (Note: in legacy EMPIRE, S and C are sometimes used interchangeably depending on regional settings).
- **Expenses**: `LETTER = 'E'`.

## SQL Snippets (Postgres)
```sql
-- Get all major account groupings
SELECT DISTINCT "MAJORACTYPE" FROM "IMMBE2627"."sq_ATYPE";

-- Find the letter code for Sundry Debtors
SELECT "NAME", "LETTER" FROM "IMMBE2627"."sq_ATYPE" WHERE "NAME" LIKE '%DEBTORS%';
```
