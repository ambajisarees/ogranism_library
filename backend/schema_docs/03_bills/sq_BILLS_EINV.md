# Table: sq_BILLS_EINV (E-Invoicing Metadata)

## Table Overview
`sq_BILLS_EINV` stores the specific government-mandated tokens and dates for GST E-Invoices.

## Column Grouping
- `CNO` / `VNO` / `TYPE`: Link keys to `sq_BILLS`.
- `irn`: The 64-character Invoice Reference Number.
- `ack_no` / `ack_DATE`: Acknowledgement number and timestamp from the GST portal.
- `ewb_no` / `ewb_date`: E-Way Bill details if generated via E-Invoice.
- `qrcode1` - `qrcode6`: Segmented QR code data (used to reconstruct the image in reports).

## SQL Snippets (Postgres)
```sql
-- Join with bill to show E-Invoice status
SELECT B."VNO", E."irn", E."ack_no"
FROM "IMMBE2627"."sq_BILLS" B
LEFT JOIN "IMMBE2627"."sq_BILLS_EINV" E 
  ON B."CNO" = E."CNO" AND B."VNO" = E."VNO" AND B."TYPE" = E."TYPE"
WHERE B."TYPE" = 'S1';
```
