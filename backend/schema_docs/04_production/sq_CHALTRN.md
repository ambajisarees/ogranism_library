# Table: sq_CHALTRN (Production Movements)

## Table Overview
`sq_CHALTRN` tracks the physical movement of fabric batches (Challans) between different stages of the production chain (e.g., from O5 Dispatch to O6 Receive).

## Column Grouping

### Movement Identification
- `SRNO`: **Primary Key (Line)**. Unique identifier for the movement line.
- `CARDNO` / `CUTCARDNO` / `RECCARDNO`: Links to the physical job card number.
- `PVNO`: **Parent Voucher Number**. Links back to the `sq_BILLS` row for the parent challan.

### Quantities
- `PMTS`: **Planned Meters**. The quantity dispatched.
- `RMTS`: **Received Meters**. The quantity actually received back.
- `WMTS`: **Working/Waste Meters**. Shrinkage or waste during the process.
- `CPCS`: **Cut Pieces**. Physical piece count in this movement.
- `MMTS`: **Mixed/Milling Meters**.
- `FENT`: Meters of "fents" (small waste pieces) generated.

### Process Details
- `WRMK`: Working remark from the job worker.
- `RECRMK`: Receiving remark upon return.
- `TAKA_WT`: Physical weight of the fabric rolls (Takas).
- `RECTAKASRNO`: Serial number mapping for received rolls.

### Tracking
- `INWARD_SRNO`: Links this outward movement to a specific inward receipt.
- `used_in_tp`: Quantity already utilized in the "Through-Pass" process.

## Column Relevance
- `RMTS`: This is the primary field used to update the "Pending" status. If `RMTS < PMTS`, the batch is still partially with the job worker.
- `CARDNO`: The key used by employees on the factory floor to identify physical batches.

## SQL Snippets (Postgres)
```sql
-- Find all partially received challans for a job card
SELECT "CARDNO", "PMTS", "RMTS", ("PMTS" - "RMTS") as "PENDING"
FROM "IMMBE2627"."sq_CHALTRN"
WHERE "RMTS" < "PMTS" AND "CARDNO" = 5051;
```

## Fiscal Carry-Forward Audit: Active vs. Carried Forward
Using the **VNO < 100,000** threshold logic for Active FY 26-27 records:

| Category | Row Count | Logic |
| :--- | :--- | :--- |
| **Active FY 26-27** | 2,811 | `PVNO < 100,000` |
| **Carried Forward** | 0 | `PVNO >= 100,000` |
| **Unnumbered/Null** | 18,653 | `PVNO` is NULL (Pending Floor) |
| **Total Headers** | **21,464** | |

> [!IMPORTANT]
> The high count of **Unnumbered/Null** records (18,653) represents floor movements or line-items that are tracked by `CARDNO` but have not yet been assigned a parent Voucher Number (`PVNO`). All numbered challans in the current schema are **Active**.
