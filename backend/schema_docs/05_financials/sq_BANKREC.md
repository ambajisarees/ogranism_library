# Table: sq_BANKREC (Bank Reconciliation)

## Table Overview
`sq_BANKREC` tracks the reconciliation status of bank entries. It maps entries in the ERP to actual bank statement dates.

## Column Grouping
- `CNO` / `VNO` / `TYPE`: Link keys to the original `sq_FAS` or `sq_BILLS` entry.
- `RECEIPT` / `PAYMENT`: The cash values.
- `recondate`: **Crucial Field**. The date on which the entry appeared in the bank statement. If NULL, the entry is "Uncleared".
- `DOCNO`: Cheque or Reference number.
- `SLIPNO`: Deposit slip number.
- `CODE`: The bank ledger code.

## SQL Snippets (Postgres)
```sql
-- Find all uncleared cheques for a specific bank
SELECT * FROM "IMMBE2627"."sq_BANKREC" 
WHERE "recondate" IS NULL AND "CODE" = 'B001';
```
