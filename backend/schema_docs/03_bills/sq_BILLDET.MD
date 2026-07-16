# Table Documentation: `sq_BILLDET` (Transaction Details)

## Overview
`sq_BILLDET` is the line-item level of the ERP database. It tracks every specific piece, meter, and quality involved in a transaction. This table is the source of truth for **Pending Stock** and **Job Work Status**.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 86
- **Row Count**: 5,365
- **Data Completeness**: ~68% (Strong on quantity and quality, sparse on tracking notes)

### Completion Distribution (`CLOSED`)
| Status | Description | Count | % of Total | Business Action |
|:---|:---|:---|:---|:---|
| **N / NULL** | **PENDING** | 5,269 | 98.2% | Outstanding for Job Work / Sales |
| **Y** | **CLOSED** | 96 | 1.8% | Processed / Archived |

> [!IMPORTANT]
> **Production Pulse**: The extremely high ratio of "Pending" items is normal for an active production cycle. All legacy historical data (IMMBE2526) has been purged to focus strictly on this active ledger.

## Schema Categorization & Relevance

### 1. [ACTIVE] Identity & Linkage
- `CNO` / `VNO` / `TYPE`: Primary link to `sq_BILLS`.
- `SRNO`: Line identifier (0% null).
- `qual`: Foreign Key to `sq_QUAL.qcode`.
- `orderno` / `ORDTYPE`: Links back to the source order/slip.

### 2. [ACTIVE] Item Specifications
- `PCS`: Quantity in pieces.
- `MTS`: Quantity in meters.
- `RATE`: Unit price for this specific line.
- `AMT`: Total value (`PCS/MTS * RATE`).
- `UNIT`: Defines measure (PCS/MTS).
- `CUT`: Manufacturing standard length.

### 3. [ACTIVE] Production & Status
- **CLOSED**: ('Y' = Done, 'N' = Open). The single most important filter for "Next Step" logic.
- `STAGE_FINAL`: Boolean indicating if the item has reached the "Ready to Ship" warehouse.
- `STAGE_VNO` / `STAGE_TYPE`: Tracks which production stage the item is currently in.

### 4. [ACTIVE] Special Calculations
- `WT_LESS`: Deductions for fabric waste or cleaning.
- `DETRD`: Line-level discount.
- `DETVATAMT`: Line-level tax component.
- `SAREE_RATE`: Job-work cost per piece.

### 5. [TODO] Tracking & Traceability
- `TRACK_VNO` / `TRACK_TYPE`: Forward tracking to subsequent dispatches.
- `DET_CASENO`: Physical packing case identifier.
- `MTSDETAILS`: Planned expansion for roll-by-roll ledger.

## Fiscal Year Breakdown: Line-Item Carry Forward
Based on the **Threshold Logic** (Active entries have `VNO < 100,000`), we have identified the following line-item distribution.

| Series | Description | Active FY 26-27 | Carried Forward (Pending) | Total Lines |
|:---|:---|:---:|:---:|:---:|
| **S1** | FINISH SALES | 2,127 | 0 | 2,127 |
| **O6** | WORK REC STITCHING | 82 | 673 | 755 |
| **P26** | WORK REC STITCHING BILLS | 0 | 570 | 570 |
| **O5** | WORK DESP STITCHING | 25 | 461 | 486 |
| **O4** | WORK IN HOUSE CARD | 0 | 357 | 357 |
| **Others** | Minor Series (O13, P2, etc) | 171 | 900 | 1,071 |
| **Total** | | **2,405** | **2,961** | **5,366** |

> [!IMPORTANT]
> **Definitive Boundary**: Active FY 26-27 records are strictly defined as `VNO < 100,000`. This resolves the multi-year carry-forward issues and aligns the line-item counts with the EMPIRE app dashboards.

## SQL Audit Snippet
```sql
-- Join Header and Detail (Correct Way)
SELECT B."DATE", BD."qual", BD."PCS"
FROM "IMMBE2627"."sq_BILLS" B
INNER JOIN "IMMBE2627"."sq_BILLDET" BD 
  ON B."CNO" = BD."CNO" 
  AND B."VNO" = BD."VNO" 
  AND B."TYPE" = BD."TYPE"
WHERE B."TYPE" = 'S1' AND B."VNO" = 101;
```

> [!WARNING]
> **Join Integrity**: Never join `sq_BILLS` to `sq_BILLDET` using only `VNO`. You MUST include `CNO` and `TYPE` or you will experience row explosion due to voucher number collisions across series.
