# Table Documentation: `sq_BILLS` (Transaction Headers)

## Overview
`sq_BILLS` is the primary structural header for all transactions. Every physical slip, invoice, or production record is anchored by a unique `CNO` + `VNO` + `TYPE` triad in this table.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 81
- **Row Count**: 16,871
- **Data Completeness**: 92% (Strong on financials, 100% on identification)

### Distribution by Voucher Series (`TYPE`)
| Series | Description | Count | Current Purpose |
|:---|:---|:---|:---|
| **S1** | Sales Invoice | 7,101 | Revenue / End-user Dispatch |
| **J1** | Journals | 2,853 | Financial Adjustments |
| **XX** | Carry Series | 1,923 | Legacy Stock Migration |
| **O6** | Fab. Receive | 432 | Production Finish Log |
| **O5** | Fab. Issue | 474 | Production Start / Job Work |
| **P26** | Purchase | 742 | Incoming Raw Material |

## Schema Categorization & Relevance

### 1. [ACTIVE] Primary Identification
- `CNO`: Company ID (100% present).
- `VNO`: Voucher Number.
- `TYPE`: Series Code (S1, O7, etc).
- `DATE`: Transaction timestamp.
- **JOIN RULE**: To fetch details, always join on `(CNO, VNO, TYPE)`.

### 2. [ACTIVE] Entities & Mapping
- `BCODE`: Party Ledger Link (FK to `sq_MASTER.code`).
- `haste`: Agent/Broker Link (FK to `sq_HASTE.HASTE`).
- `TRANSPORT`: Delivery provider name.

### 3. [ACTIVE] Financials (High Importance)
- `GROSSAMT`: Value before tax.
- `BILLAMT`: Final payable amount.
- `VATAMT` / `VATRATE`: GST Logic.
- `DISCOUNT` / `DISCAMT`: Trade discount calculations.
- `FREIGHT`: Loaded shipping costs.

### 4. [ACTIVE] Logistics & Compliance
- `PARCELS`: Physical package count (Cartoon/Bags).
- `IRN`: GST E-Invoice reference.
- `EWB_NO`: E-Way bill identifier.
- `VEHICLE_NO`: Transport vehicle number for logs.

### 5. [AUDIT] System Metadata
- `CREATOR` / `UPDATER`: User traceability.
- `CREATETIME` / `UPDATETIME`: Audit trail timestamps.
- `_sync_time`: Airbyte last success marker.

## Fiscal Year Breakdown: Active vs. Carried Forward
Based on the **Threshold Logic** (Active entries have `VNO < 100,000`), we have identified the following distribution across all series.

| Series | Description | Active FY 26-27 | Carried Forward (Pending) | Total Headers |
|:---|:---|:---:|:---:|:---:|
| **S1** | FINISH SALES | 1,108 | 5,994 | 7,102 |
| **J1** | JOB WORK | 67 | 2,786 | 2,853 |
| **XX** | UNADJ PAYMENT (Carry) | 26 | 1,897 | 1,923 |
| **P26** | WORK REC STITCHING BILLS | 0 | 742 | 742 |
| **P1** | GREY PURCHASE | 84 | 517 | 601 |
| **P6** | MODELLING PHOTO | 2 | 544 | 546 |
| **O5** | WORK DESP STITCHING | 25 | 449 | 474 |
| **O6** | WORK REC STITCHING | 68 | 364 | 432 |
| **P2** | FINISH PURCHASE | 32 | 324 | 356 |
| **O4** | WORK IN HOUSE CARD | 0 | 350 | 350 |
| **p5** | WORK REC. BILL (OLD) | 2 | 319 | 321 |
| **P3** | SALES GOODS RETURN | 10 ...
<truncated 143 bytes>
| **P4** | PACKING MATERIAL | 22 | 183 | 205 |
| **P27** | WORK REC DIAMOND | 0 | 151 | 151 |
| **O10** | WORK REC EMB | 0 | 78 | 78 |
| **P28** | WORK REC EMB | 0 | 75 | 75 |
| **O45** | READY PRODUCT | 0 | 67 | 67 |
| **Others** | Minor Series (O13, S3, etc) | 44 | 303 | 347 |
| **Total** | | **1,490** | **15,382** | **16,872** |

> [!IMPORTANT]
> **Verified Baseline**: By applying the `Voucher Number < 100,000` threshold, we have resolved the count discrepancy in **O5** (confirmed exactly **25** active records). This logic accounts for multi-year carry-forwards (prefixes like `20`) which were previously misclassified as new.

## SQL Audit Snippet
```sql
-- Check total revenue for S1 series this year
SELECT SUM("BILLAMT") as revenue 
FROM "IMMBE2627"."sq_BILLS" 
WHERE "TYPE" = 'S1';
```

> [!TIP]
> **Performance Optimization**: When querying for "Pending Shipments", use an `EXISTS` check against `v_parties_active` instead of a full join to keep API response times under 200ms.

## Transaction Type Distribution (All)
| Type | Total Rows | Business Nomenclature (LegacyConstants) |
| :--- | :--- | :--- |
| **S1** | 7,101 | FINISH SALES |
| **J1** | 2,853 | JOB WORK (Audit Required - High Volume) |
| **XX** | 1,923 | UNADJ PAYMENT (Carry-Forward) |
| **P26** | 742 | WORK REC STITCHING BILLS |
| **P1** | 601 | GREY PURCHASE |
| **P6** | 546 | MODELLING PHOTO MATERIALS |
| **O5** | 474 | WORK DESP STITCHING CHALLAN |
| **O6** | 432 | WORK REC STITCHING CHALLAN |
| **P2** | 356 | FINISH PURCHASE |
| **O4** | 350 | WORK IN HOUSE CARD |
| **p5** / **P5** | 321 | WORK REC. BILL (OLD) |
| **P3** | 249 | SALES GOODS RETURN |
| **P4** | 205 | PACKING MATERIAL (Purchase) |
| **P27** | 151 | WORK REC DIAMOND BILLS |
| **O10** | 78 | WORK REC EMB CHALLAN |
| **P28** | 75 | WORK REC EMB BILLS |
| **O45** | 67 | READY PRODUCT (Inspection) |
| **O9** / **O13** | 45 | WORK DESP EMB / FINISH PUR ORD |
| **O7** | 40 | WORK DESP DIAMOND CHALLAN |
| **O14** | 26 | LACE PURCHASE ORDER |
| **p11** | 25 | LACE PURCHASE |
| **S92** / **S77** | 39 | DEBIT NOTE (ON PUR / TCS) |
| **P5-P93** | 50+ | Minor Categories (GST/Credit Notes) |
| **Total** | **16,871** | |
