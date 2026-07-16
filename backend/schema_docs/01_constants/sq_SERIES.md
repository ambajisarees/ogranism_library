# Table: sq_SERIES (Voucher Series Master)

## Table Overview
`sq_SERIES` is the heart of the ERP's transactional logic. It configures how different types of vouchers (O4, S1, P1, etc.) behave, including their accounting effects, billing rules, and placement in the production chain.

## Column Grouping

### Identification
- `SERIESCODE`: **Primary Key (Business)**. Internal code (e.g., 'O4', 'S1').
- `SERIES`: Friendly name of the series (e.g., "WORK IN HOUSE", "SALES INVOICE").
- `DOC_TYPE`: Categorization (e.g., Sales, Purchase, Production).

### Production Flow
- `STAGE_MAIN`: Identifies which process stage this series represents (Critical for production chain logic).
- `STAGE_GROUP`: Grouping for production reporting.
- `STAGE_FINAL`: Boolean flag indicating if this is the "Ready Product" stage.
- `STAGE_INCLUDE_COST`: Flag to include processing costs in stock valuation.

### Accounting & Billing
- `BILLING`: Boolean flag. If true, this series generates a financial bill.
- `acCODE`: Ledger code linked to this series for automatic entry.
- `updatefas`: Flag to automatically update the `sq_FAS` table.
- `VATAC` / `TDSAC` / `tcsac`: Ledger codes for tax accounts.
- `VATRATE` / `TDSRATE` / `ADD_VATRATE`: Default tax rates for this series.

### Permissions
- `INSERT_USERS` / `UPDATE_USERS` / `DELETE_USERS`: Access control lists for legacy users.
- `openlevel` / `insertlevel` / `changelevel` / `deletelevel`: Numeric security levels.

## Column Relevance
- `UPDATES_BILLDET`: If true, entries in this series modify the status of rows in the `sq_BILLDET` table.
- `INTYPE` / `OUTTYPE`: Relational markers for inventory direction (Inward vs Outward).
- `ONLINE_ENTRY`: If true, the system allows real-time data entry (not batch).

## Filters & Identification
- **Production Series**: Filter `STAGE_MAIN IS NOT NULL`.
- **Billing Series**: Filter `BILLING = true`.
- **Primary Sales**: Filter `SERIESCODE = 'S1'`.

## SQL Snippets (Postgres)
```sql
-- List all series that affect the production chain
SELECT "SERIESCODE", "SERIES", "STAGE_MAIN" FROM "IMMBE2627"."sq_SERIES" WHERE "STAGE_MAIN" IS NOT NULL;

-- Check if a series is a "Final Stage" process
SELECT "SERIESCODE", "STAGE_FINAL" FROM "IMMBE2627"."sq_SERIES" WHERE "SERIESCODE" = 'O45';
```
