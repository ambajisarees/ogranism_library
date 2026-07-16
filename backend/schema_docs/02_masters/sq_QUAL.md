# Table Documentation: `sq_QUAL` (Quality/Item Master)

## Overview
The definitive product master. Contains all saree qualities, fabric compositions, pricing rules, and compliance data (GST/HSN).

## Business Context & Insights
- **Taxonomy Strength**: 100% of items are correctly categorized by `CLOTHTYPE` and `UNIT`, ensuring basic sales reporting works immediately.
- **Costing Void**: Core pricing inputs like `COST_PER`, `PACK_COST`, and `pur1` are currently **100% NULL/Zero**. 
- **Compliance Health**: 92% of items have `HSN_CODE` and `GSTRATE` populated, facilitating automated tax calculation.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 37
- **Row Count**: 931
- **Data Completeness**: ~55%

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **qcode** | character varying | 0% | **PRIMARY KEY** | Unique business code for the quality. |
| **NAME** | character varying | 0% | **IDENTITY** | Full display name of the quality. |
| **CLOTHTYPE** | character varying | 0% | **TAXONOMY** | Maps to cloth master list. |
| **category** | character varying | 28.8% | TAXONOMY | Collection or Season grouping. |
| **UNIT** | character varying | 0% | **TAXONOMY** | Measurement unit (PCS/MTS). |
| **HSN_CODE** | character varying | 8.0% | **COMPLIANCE** | GST HSN classification. |
| **GSTRATE** | numeric | 2.7% | **COMPLIANCE** | GST percentage (5/12). |
| **SELL1/2/3** | numeric | 24.0% | **SALES** | General Price Lists for different buyer tiers. |
| **CUT** | numeric | 29.4% | PRODUCTION | Standard production length per piece. |
| **COST_PER** | bigint | 100% | **TODO** | Global index cost. |
| **SUPPLIER** | character varying | 100% | **TODO** | Linked grey supplier. |
| **PCS_PER_SET** | bigint | 93.3% | PRODUCTION | Catalog set volume. |
| **avg_wt** | numeric | 0% | **TODO** | Item weight (likely 0 in current data). |
| **pur1** | numeric | 0% | **TODO** | Purchase price reference (likely 0). |
| **itemsrno** | character varying | 0% | **ID** | Internal system index. |
| **BASEQUAL** | character varying | 94.2% | **IDENTITY** | Parent quality link for variants. |
| **VATRATE** | numeric | 100% | **IRRELEVANT** | Deprecated pre-GST tax rate. |
| **SCREENCOMP** | character varying | 100% | **IRRELEVANT** | Legacy UI metadata. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte synchronization metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identity & Taxonomy
- `qcode` / `NAME`: Core identifiers.
- `CLOTHTYPE` / `category`: Fabric and style classification.
- `UNIT`: Defines piece vs meter inventory logic.
- `BASEQUAL`: Maintains parent/variant relationships.

### 2. [ACTIVE] Sales & Compliance
- **General Price Lists**: `SELL1`, `SELL2`, `SELL3`.
- **Compliance**: `HSN_CODE`, `GSTRATE`.

### 3. [ACTIVE] Production Specifications
- `CUT`: Manufacturing target length.
- `EXPECT_SHORTAGE`: Buffer for fabric shrinkage.
- `PACKING`: Default packing style link.

### 4. [TODO] Financials & Logistics
- `COST_PER` / `pur1`: **TARGET**: Margin and procurement tracking.
- `SUPPLIER`: **TARGET**: Traceability to grey suppliers.
- `avg_wt`: **TARGET**: Automated freight-based transport selection.

### 5. [IRRELEVANT] Legacy
- `ADD_VATRATE` / `VATRATE`: Obsolete tax fields.
- `SCREENCOMP` / `MAINSCREEN`: Legacy UI markers.
- `OLDQCODE`: Legacy cross-reference.

## SQL Audit Snippet
```sql
-- Count qualities by fabric type and unit
SELECT "CLOTHTYPE", "UNIT", COUNT(*) as count 
FROM "IMMBE2627"."sq_QUAL" 
GROUP BY "CLOTHTYPE", "UNIT" 
ORDER BY count DESC;
```

## Filterable Insights & Distributions
To design intuitive product selection and inventory filters, we analyze the concentration and diversity of the quality master's attributes.

**Metrics Summary:**
- **Fabric Families (CLOTHTYPE)**: 13 (High-level catalog hierarchy)
- **Unit Types**: 2 (PCS and MTS - 100% data health)
- **Category Tags**: 54 (Season/Collection markers)
- **HSN Codes**: 35 (Tax compliance groups)
- **Packing Styles**: 8 (Logistics & Costing markers)

### Top Column Distributions

#### 1. Fabric Families (`CLOTHTYPE`)
- **SAREES**: 842 items (Primary product)
- **LACE**: 41 items
- **FABRIC**: 21 items
- **UNSTITCHED**: 12 items
- **JOB WORK**: 5 items

#### 2. Compliance & Tax (`GSTRATE`)
- **5.0%**: 878 items (Standard textile rate)
- **12.0%**: 14 items
- **18.0%**: 12 items
- **0.0%**: 2 items
- **NULL/TODO**: 25 items (Critical billing blocks)

#### 3. Standard Lengths (`CUT`)
- **5.50 / 6.30**: Most common saree lengths.
- **9.00 / 18.00**: Standard lace bundle lengths.
- **NULL/TODO**: 274 items (Missing production specs)

#### 4. Operational Logistics (`PACKING`)
- **CHAINBAG**: 615 items (Standard premium packing)
- **NAKED**: 260 items (Loose/Unfinished stock)
- **BOX COMBO**: 8 items
- **POUCH**: 8 items

### Empty/Irrelevant Filter Markers
- **`SUPPLIER`**: 100% NULL. Avoid using in UI for now.
- **`COST_PER`**: 100% NULL/Zero. Use `SELL1` for pricing filters instead.
- **`OLDQCODE`**: Legacy column, ignore for modern search.
- **`VATRATE`**: Obsolete tax field; use `GSTRATE` exclusively.

## Filter Count by ClothType and Category
This distribution identifies the core operational segments within the quality master. 78% of active inventory is concentrated in the `SAREE` and `FINAL` cloth types across four major collections.

| Cloth Type | Category | Item Count | Business Role |
|:---|:---|:---|:---|
| **SAREE** | (null) | 227 | Generic Saree Master |
| **SAREE** | **SAREES** | 226 | Core Saree Inventory |
| **SAREE** | **2025** | 204 | Active 2025 Collection |
| **FINAL** | **SAREES** | 113 | Finished Stock (Standard) |
| **FINAL** | **EMB** | 60 | Finished Stock (Emboidery) |
| **FINAL** | **NAMAMI** | 38 | Premimum Namami Series |
| **DRESS** | GANGA SILK | 1 | Dress Material Variant |
| **TOTAL** | **-** | **931** | **Full Registry Sweep** |

> [!TIP]
> UI Implementation: Use `CLOTHTYPE` as the primary sidebar filter and `category` as a secondary multi-select chip filter to yield the most productive search results.

---

## 4. The Barrel Plan (Categorization)

Based on late-breaking business logic, the quality master is partitioned into three functional barrels:

### BARREL 1: GREY (Raw Materials)
*   **Logic**: `ISBASEQUAL = 'Y'`
*   **Inventory Count**: **99 Records**
*   **Key Entries**: "RENIAL DIAMOND", "60 GRAM PLAIN", "DULL MOSS PLAIN", "WETLESS PLAIN".

### BARREL 2: SALES (Active Saree Designs)
*   **Logic**: `SELL1 >= 180` AND `CLOTHTYPE` in ('SAREE', 'FINAL')
*   **Benchmarks**:
    *   **User Manual Truth**: **317 Primary Sales Entities** (113 Final + 204 Saree 2025).
    *   **Database Raw Truth**: **650 Potential Candidates** identified in `vwsq_qual`.
*   **Insights**:
    *   **The Delta**: There are **333 additional records** in the database that fit the sales criteria but are not in the user's primary manual list.
    *   **Recency Audit**: 535 of these 650 items have been active/updated since 2024, suggesting a broader pool of active secondary designs or specialized jobs beyond the core 2025 collection.
*   **Deduction**: The user's 317 represents the "Premium/Catalog" tier, while the database's 650 represents the "Full Sales Portfolio."

### BARREL 3: OTHERS (Office, Hardware & Misc)
*   **Groups**:
    *   **Hardware/IT**: RAM (8GB/Desk), SSD, HDD, Printers, Mouse.
    *   **Stationery**: Ballpens, Stickers, Cartons, Pouch.
    *   **Non-Material**: Freight, Membership charges, Software.
*   **Logic**: Keywords like `RAM [0-9]GB` or price `< 180` without base-quality status.
