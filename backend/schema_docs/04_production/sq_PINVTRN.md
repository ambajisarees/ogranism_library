# Table: sq_PINVTRN (Purchase Inward Transactions)

## Table Overview
`sq_PINVTRN` stores the line-item details for Grey (raw fabric) and Finished good purchases.

## Column Grouping
- `CARDNO`: Primary tracking card for the purchased batch.
- `MASTER`: The quality/fabric master link.
- `PURRATE`: The actual purchase price per unit.
- `RATE`: The landed cost including taxes/expenses.
- `PMTS` / `RMTS`: Ordered vs Received quantity.
- `LOT`: Mill lot number for quality tracking.
- `CENVATAMT`: Excise/Input tax credit amount.

## SQL Snippets (Postgres)
```sql
-- Find total grey purchase for a specific lot
SELECT SUM("RMTS") FROM "IMMBE2627"."sq_PINVTRN" WHERE "LOT" = 'LOT-A';
```

## Fiscal Carry-Forward Audit: Active vs. Carried Forward
Using the **VNO < 100,000** threshold logic for Active FY 26-27 records:

| Category | Row Count | Logic |
| :--- | :--- | :--- |
| **Active FY 26-27** | 431 | `VNO < 100,000` |
| **Carried Forward** | 0 | `VNO >= 100,000` |
| **Unnumbered/Null** | 2,618 | `VNO` is NULL (Pending) |
| **Total Headers** | **3,049** | |

> [!NOTE]
> Purchase Inward Transactions (`P1`) show a high count of **Unnumbered/Null** records (2,591). These represent raw fabric received into the warehouse (Inward) for which the final supplier invoice (Vouchered PINV) has not yet been processed.
