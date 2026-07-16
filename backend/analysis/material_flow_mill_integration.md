# Analysis 2: Material Flow & Mill Integration
## Overview
This report analyzes the grey fabric lifecycle and processing mill integration, focusing on the `CARDNO` tracking system.

## 🔄 Business Derived Context

### 1. The `CARDNO` Thread
The `CARDNO` is the most critical identifier in the production system. It is generated when grey fabric is purchased (`sq_PINVTRN`) and flows through every subsequent transformation.
- **Entry**: `sq_PINVTRN` (Purchase Invoice).
- **Movement**: `sq_CHALTRN` (Challan Transaction).
- **Processing**: `sq_MILLREC` (Mill Receipt).

### 2. Shrinkage & Wastage Calculation
In textile manufacturing, fabric "shrinks" during processing (dyeing/printing). 
- **Sent to Mill**: `CMTS` in `sq_CHALTRN`.
- **Received from Mill**: `RMTS` in `sq_MILLREC`.
- **Shrinkage %**: `(1 - (RMTS / CMTS)) * 100`.
- **Wastage (Fent)**: `WMTS` in `sq_MILLREC` captures the scrap pieces that are too short to be sarees.

### 3. Saree Design Inventory (`sq_SAREEDES`)
This table is a "Live Snapshot" of design-level availability.
- `STOCK`: Finished pieces ready to sell.
- `PENDING`: Pieces currently at various Job Work stages (Stitching, EMB, etc.).
- `SAREEDES_CUT`: Pieces that have been cut but not yet dispatched to workers.

---

## 🛠️ Optimized SQL Snippets

### A. Tracking a Specific Fabric Lot (Lot Hierarchy)
To see where a specific batch of fabric is:
```sql
SELECT 
    'PURCHASE' as Stage, P.DATE, P.RMTS as Balance, P.MILL as Party
FROM "IMMBE2627"."sq_PINVTRN" P WHERE P.CARDNO = :targetCard
UNION ALL
SELECT 
    'MILL_SEND' as Stage, C.UPDATETIME, C.CMTS as Balance, NULL as Party
FROM "IMMBE2627"."sq_CHALTRN" C WHERE C.CARDNO = :targetCard
UNION ALL
SELECT 
    'MILL_REC' as Stage, M.UPDATETIME, M.RMTS as Balance, M.MILL_CODE as Party
FROM "IMMBE2627"."sq_MILLREC" M WHERE M.CARDNO = :targetCard;
```

### B. Mill Performance Audit
```sql
SELECT 
    M.MILL_CODE,
    SUM(C.CMTS) as TotalSent,
    SUM(M.RMTS) as TotalRec,
    SUM(M.WMTS) as TotalWastage,
    ROUND((1 - (SUM(M.RMTS) / SUM(C.CMTS))) * 100, 2) as ShrinkagePct
FROM "IMMBE2627"."sq_MILLREC" M
JOIN "IMMBE2627"."sq_CHALTRN" C ON C.RECCARDNO = M.RECCARDNO
GROUP BY M.MILL_CODE
HAVING SUM(C.CMTS) > 0;
```

---

## 📱 UI Component Mapping

### 1. `OrganKpiStrip` (Production View)
*   **Fabric at Mill**: `SELECT SUM(CMTS - RMTS) FROM sq_CHALTRN WHERE RECCARDNO IS NULL`.
*   **Wastage Alert**: Highlight mills where `ShrinkagePct > 5%`.

### 2. `OrganDesignCard`
Maps directly to `sq_SAREEDES`:
*   `title`: `DESIGNNO`.
*   `subTitle`: `STOCK` + " Pcs available".
*   `badge`: If `PENDING > 100` then "Hot Seller".

---

## 💡 Key Insights
1.  **Card De-normalization**: A single `CARDNO` in `PINVTRN` might split into multiple `TAKASRNO` (Roll Serial Numbers) in `CHALTRN`. Always check if you need to track by "Entire Lot" or "Specific Roll".
2.  **Zero-Row Tables**: `sq_CUTDET` is currently empty. This implies cutting instructions might be handled in `CHALTRN` under `CUTCARDNO` instead of the dedicated detail table for this fiscal year, or they haven't started cutting yet.
