# Table: sq_updates_billdet (Update Audit Trail)

## Table Overview
`sq_updates_billdet` is a specialized log table that tracks modifications to line items, specifically for synchronization between the main EMPIRE database and the Supabase mirror.

## Column Grouping
- `CNO` / `VNO` / `TYPE` / `srno`: Composite keys identifying the specific line item modified.
- `UPDATETIME`: Timestamp of the last change.
- `UPDATER` / `CREATOR`: User audit trail.
- `FINALAMT` / `BILLAMT`: Preserved financial values after update.
- `table_insert_time`: Specifically tracks when this log entry was created for sync ordering.

## SQL Snippets (Postgres)
```sql
-- Find all items updated in the last 24 hours
SELECT * FROM "IMMBE2627"."sq_updates_billdet" 
WHERE "UPDATETIME" > NOW() - INTERVAL '1 day';
```
