# Table: sq_PURORD (Purchase Orders)

## Table Overview
`sq_PURORD` stores the initial purchase commitments made to suppliers for raw fabric.

## Column Grouping
- `ORDERNO`: **Primary Key (Business)**. The unique PO number.
- `BCODE`: Supplier code from `sq_MASTER`.
- `QUAL`: Quality code from `sq_QUAL`.
- `PCS` / `MTS`: Ordered quantities.
- `RATE`: Negotiated unit price.
- `LASTDATE`: Expected delivery deadline.
- `cancelled`: Boolean flag for order cancellation.

## SQL Snippets (Postgres)
```sql
-- Find all open (un-cancelled) orders for a specific supplier
SELECT * FROM "IMMBE2627"."sq_PURORD" WHERE "BCODE" = 'S001' AND "cancelled" = false;
```

## Quantitative Audit (FY 26-27)

| Category | Row Count | Status |
| :--- | :--- | :--- |
| **Active FY 26-27** | 0 | Empty |
| **Carried Forward** | 0 | Empty |
| **Total** | **0** | |

> [!NOTE]
> No purchase order records have been synchronized or entered into the `IMMBE2627` schema as of the current audit.
