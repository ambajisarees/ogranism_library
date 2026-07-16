# Table: sq_COMPMST (Company Master)

## Table Overview
The `sq_COMPMST` table is the highest level of the ERP hierarchy. It stores legal and contact information for the different companies (partnership firms, HUFs) within the Ambaji Sarees group.

## Column Grouping

### Identification
- `id`: Row identifier (numeric legacy ID).
- `CNO`: **Primary Key (Business)**. Company Number (1=Ambaji Sarees HTC-2, 3=Ambaji Sarees, etc.).
- `SHORTNAME`: 2-3 character abbreviation (e.g., "AS3").
- `FIRM`: Trading name of the firm.
- `NAME`: Legal structure (e.g., "PARTNERSHIP").

### Tax & Compliance
- `COMPANY_GSTIN`: Primary GST identification number.
- `PANNO`: Permanent Account Number for Income Tax.
- `TDS_ACNO`: TAN number for tax deduction.
- `C_MSME_NO`: MSME Registration number.
- `C_MSME_TYPE`: MSME category (Micro, Small, Medium).

### Contact & Location
- `ADDRESS1` - `ADDRESS4`: Segmented address lines.
- `CITY1`, `CPINNO`: City and Postal Pin code.
- `PHONE1` - `PHONE4`, `MOBILE`, `EMAIL`, `FAX1`: Communication channels.

### System & Audit
- `_sync_time`: Airbyte synchronization timestamp.
- `CREATOR` / `UPDATER`: User audit logs.
- `CREATETIME` / `UPDATETIME`: Row-level audit timestamps.
- `lockOLDYEAR`: Flag to prevent edits to finalized financial years.

## Column Relevance
- `CNO`: Critical for joining with almost every other table (`BILLS`, `FAS`, `BANKS`).
- `MULTI_MILL_CHALLAN`: Binary flag determining if the company supports multi-mill batching.
- `tcs_applicable`: "Y" or "N" flag for Tax Collected at Source logic.

## Filters & Identification
- **Primary Company**: Filter by `CNO = 4` or `SHORTNAME = 'AS3'`.
- **Active Entities**: Most queries should filter for `CNO` values present in current year operations.

## SQL Snippets (Postgres)
```sql
-- Get full details of the main firm
SELECT * FROM "IMMBE2627"."sq_COMPMST" WHERE "CNO" = 4;

-- List all firms with their GSTIN
SELECT "CNO", "FIRM", "COMPANY_GSTIN" FROM "IMMBE2627"."sq_COMPMST";
```
