# Table: sq_DELETEDITEMS (Deletions Audit Log)

## Table Overview
`sq_DELETEDITEMS` serves as a "Recycle Bin" and audit trail for every transaction deleted from the legacy system. It preserves the original transaction data with extra metadata about when and who deleted it.

## Column Grouping

### Original Identification
- `CNO`, `VNO`, `TYPE`, `SRNO`: **Composite Key (Legacy)**. The original coordinates of the deleted record.
- `BILLNO` / `BILLTYPE`: Original billing references.

### Financial Data (Preserved)
- `DRAMT` / `CRAMT`: Original Debit/Credit amounts.
- `RUNBAL`: The running balance at the time of deletion.
- `OTHERAMT`: Miscellaneous adjustments.

### Audit Metadata
- `DELETER`: **Main Identifier**. The legacy user who performed the deletion.
- `DELETETIME`: Exactly when the record was removed.
- `RMK`: The reason for deletion (if provided).
- `CREATOR` / `UPDATER`: Original authors of the record before it was deleted.

## Column Relevance
- `type`: Crucial for filtering deletions by transaction category (e.g., 'S1' for sales).
- `ISGR`: Flag indicating if the deletion happened in the legacy "Grey" module.

## Filters & Identification
- **Recent Deletions**: Filter by `DELETETIME DESC`.
- **User Activity**: Filter by `DELETER`.

## SQL Snippets (Postgres)
```sql
-- List the last 5 deleted sales invoices
SELECT "VNO", "DRAMT", "DELETER", "DELETETIME" 
FROM "IMMBE2627"."sq_DELETEDITEMS" 
WHERE "TYPE" = 'S1' 
ORDER BY "DELETETIME" DESC 
LIMIT 5;
```
