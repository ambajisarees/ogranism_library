# Table: sq_MILLREC (Mill Receiving Slips)

## Table Overview
`sq_MILLREC` tracks the reception of processed fabric back from the mills.

## Column Grouping
- `CCUT`: The standard cut length received.
- `RPCS`: Number of pieces received (Finished).
- `WPCS`: Number of seconds/damaged pieces (Waste).
- `JOBRATE`: The rate charged by the mill for processing.
- `lot`: The mill's lot reference.
- `fold_rmts`: Meterage after folding/shrinking process.

## SQL Snippets (Postgres)
```sql
SELECT "lot", "RPCS", "WPCS" FROM "IMMBE2627"."sq_MILLREC" WHERE "lot" = 'M101';
```

## Fiscal Carry-Forward Audit: Active vs. Carried Forward
Using the **VNO < 100,000** threshold logic for Active FY 26-27 records:

| Type | Category | Row Count | Logic |
| :--- | :--- | :--- | :--- |
| **J1** | **Active FY 26-27** | 464 | `VNO < 100,000` |
| **J1** | **Carried Forward** | 10,439 | `VNO >= 100,000` |
| **Total** | | **10,903** | |

> [!IMPORTANT]
> **Audit Correction**: The previous count (9,133) incorrectly included legacy records from 2+ years ago (multi-year carry). This refined threshold confirmed exactly **464** new receipts for this year.
