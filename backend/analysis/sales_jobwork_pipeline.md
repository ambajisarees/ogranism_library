# Analysis 1: Sales & Job Work Pipeline
## Overview
This report analyzes the core document flow for Sales and Production Job Work, mapping the lifecycle of an order from cutting card to final invoice.

## 🔄 Business Derived Context

### 1. Document Type Map (The "DocFlow")
The `sq_SERIES` table acts as the router for the entire ERP. Understanding the `SERIESCODE` is the key to identifying the business event:

| Type | Name | Direction | Next Stage |
|---|---|---|---|
| **O3** | Multi-Cutting Card | Entry | O4 |
| **O4** | Work In House Card | Inventory | O5 (Stitching) |
| **O5** | Dispatch Stitching | Outward | O6 (Receive) |
| **O6** | Receive Stitching | Inward | O7/O9/O11 |
| **O7** | Dispatch Diamond | Outward | O8 (Receive) |
| **O8** | Receive Diamond | Inward | P27 (Bills) |
| **O1** | Sales Orders | Intent | S1 (Sales) |

### 2. The "Penal" Logic (Pending Status)
The "Truly Pending" logic for a screen (e.g., "Pending for Stitching") is derived from three fields in `sq_BILLDET`:
*   `CLOSED`: If 'Y', the line is finished.
*   `TPS_PCS`: "Truly Pending Pieces" - calculated pieces remaining in the current stage.
*   `STAGE_CNO/VNO/TYPE`: Link to the upstream dispatch to ensure a Receive doesn't overshoot its Dispatch.

---

## 🛠️ Optimized SQL Snippets

### A. Fetching Pending Job Work (e.g., Stitching Receive O6)
To show a list of items currently at the worker's place waiting to be received back:
```sql
-- Query for "Pending Receive" Screen
SELECT 
    BD.VNO as ChallanNo,
    BD.DATE as DispatchDate,
    M.NAME as TailorName,
    Q.NAME as Quality,
    BD.PCS as SentPcs,
    -- Calculate truly pending
    (BD.PCS - COALESCE(REC.TotalRec, 0)) as PendingPcs
FROM "IMMBE2627"."sq_BILLDET" BD
JOIN "IMMBE2627"."sq_MASTER" M ON M.code = BD.code
JOIN "IMMBE2627"."sq_QUAL" Q ON Q.qcode = BD.qual
-- Subquery to find sum of already received items for this order
LEFT JOIN (
    SELECT ORDVNO, ORDCNO, SUM(PCS) as TotalRec
    FROM "IMMBE2627"."sq_BILLDET"
    WHERE TYPE = 'O6' -- Receive Type
    GROUP BY ORDVNO, ORDCNO
) REC ON REC.ORDVNO = BD.VNO AND REC.ORDCNO = BD.CNO
WHERE BD.TYPE = 'O5' -- Dispatch Type
AND (BD.CLOSED IS NULL OR BD.CLOSED = 'N')
AND (BD.PCS - COALESCE(REC.TotalRec, 0)) > 0;
```

---

## 📱 UI Component Mapping

### 1. `OrganKpiStrip`
*   **Total Outstanding Orders**: `SELECT COUNT(*) FROM sq_BILLS WHERE TYPE = 'O1' AND finalamt > 0`.
*   **Production WIP**: `SELECT SUM(PCS) FROM sq_BILLDET WHERE STAGE_MAIN = 'O4' AND CLOSED = 'N'`.

### 2. `OrganProductionTimeline`
This component uses the `STAGE_MAIN` and `orderno` fields to build the breadcrumb path:
- Start: `O3`
- Step 1: `O4`
- Step 2: `O5` -> `O6`
- Step 3: `O7` -> `O8`

### 3. `OrganPartyCard`
*   **Haste (Agent)**: From `sq_BILLS.haste`.
*   **Last Order Date**: `SELECT MAX(DATE) FROM sq_BILLS WHERE code = :partyCode`.

---

## 💡 Key Insights
1.  **Multiple Join Warning**: Always join `BILLS` and `BILLDET` on `(CNO, VNO, TYPE)`. If you omit `TYPE`, you will get duplicates because voucher numbers (VNO) are reset for each series.
2.  **Meters vs Pieces**: Financial reports (`S1`) use `UNIT` awareness. Always check if `UNIT = 'MTS'` before applying price to `MTS` instead of `PCS`.
