# Table Documentation: `sq_SAREEDES` (Design Master)

## Overview
The heart of the stock system. Defines every unique saree design number and tracks piece-level and meter-level availability.

## Business Context & Insights
- **Active Designs**: Only ~31% of designs in the master currently have `STOCK` or `ACTPCS` entries, showing the difference between the "Catalogue" and "Live Stock".
- **Production Visibility**: The `PENDING` column is currently 100% empty, which indicates that Job Work in progress is not currently being rolled up into this summary table.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 30
- **Row Count**: 96
- **Data Completeness**: 40% (Strong on identification, weak on production tracking)

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **DESIGNNO** | character varying | 0% | **PRIMARY KEY** | Unique design identifier. |
| **TYPE** | character varying | 0% | **IDENTITY** | Series type (Maps to [sq_SERIES](file:///C:/Users/smitt/.gemini/antigravity/scratch/textile_erp/backend/schema_docs/01_constants/sq_SERIES.md)). |
| **vno** / **srno** | bigint | 0% | **ID** | Composite coordinate for unique row tracking. |
| **pcs** | bigint | 0% | **INVENTORY** | Total pieces linked to this design. |
| **STOCK** | numeric | 68.8% | **INVENTORY** | Ready pieces available for sale. |
| **PENDING** | bigint | 100% | **TODO** | Quantity currently in the Job Work pipeline. |
| **NO_COLOURS** | bigint | 31.2% | **DETAILED** | Number of active colorways for this design. |
| **SAREEDES_CUT** | numeric | 68.8% | **RULES** | Standard cut length (meters) per piece. |
| **STOCK_MTS** | numeric | 73.0% | **INVENTORY** | Total meterage of ready stock. |
| **ACTPCS** | numeric | 68.8% | **AUDIT** | Physical piece count from last manual audit. |
| **ACTDESIGNNO1** | character varying | 100% | **IRRELEVANT** | Legacy EMPIRE naming artifact. |
| **MTSDETAILS** | character varying | 100% | **TODO** | Target field for piece-by-piece meterage breakdown. |
| **SETS** | bigint | 100% | **TODO** | Target for catalog Set management (Combo packs). |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identification & Core
- `DESIGNNO`: The public-facing code.
- `TYPE`: Linking the design to its production series.
- `vno` / `srno` / `cno`: Internal system coordinates.

### 2. [ACTIVE] Ready Inventory
- `STOCK`: Real-time piece count for the sales team.
- `STOCK_MTS`: Calculated meterage for logistics.
- `pcs`: Historical total pieces reference.

### 3. [TODO] Production & Detailed Tracking
- `PENDING`: **TARGET**: Aggregate data from `sq_CHALTRN` for "Live Pipeline" visibility.
- `MTSDETAILS`: **TARGET**: Detailed breakdown of individual roll lengths.
- `SETS`: **TARGET**: Manage items sold as multi-piece catalogs.

### 4. [AUDIT] Physical Verification
- `ACTPCS`: Compare this against `STOCK` to identify shrinkage or data entry errors.

### 5. [IRRELEVANT] Legacy
- `ACTDESIGNNO1` / `ORD_DESIGNNO`: Legacy cross-reference fields.
- `AUTOSRNO`: No longer used (Supabase handles indexing).
- `details`: 100% empty, replaced by quality-specific notes elsewhere.

## SQL Audit Snippet
```sql
-- Identify "Zombie" designs (Master exists but no stock or production)
SELECT "DESIGNNO" 
FROM "IMMBE2627"."sq_SAREEDES" 
WHERE "STOCK" = 0 AND "PENDING" IS NULL;

## Comprehensive Series & Inventory Analysis
Following the deep-dive audit of the `IMMBE2627` schema, we have identified the following production and inventory concentrations.

### 1. Series Concentration (`TYPE`)
The design master is heavily weighted towards the `O45` series, though it currently lacks ready stock.

| Series Type | Design Count | Total Stock (Ready) | Business Role |
|:---|:---|:---|:---|
| **O45** | 66 | **NULL** | Primary Catalog Scaffolding |
| **S1** | 16 | -7,044 | Secondary Pipeline (Anomaly observed) |
| **O1** | 14 | -23,260 | Legacy/Negative Stock Clearing |

> [!WARNING]
> **Negative Stock Anomaly**: The `S1` and `O1` series show high negative stock values. This suggests either a lack of opening stock entry or that sales are being booked against future production. The UI should likely display `0` if stock is negative to avoid confusing sales agents.

### 2. Colorway Diversity (`NO_COLOURS`)
Design diversity follows a rigid binary pattern, reflecting standard industry "Set" sizes.
- **Standard Catalog Set (4 Colors)**: 60 Designs (62.5% of master).
- **Single/Utility Item (0 Colors)**: 6 Designs.
- **TBD/Legacy**: 30 Designs (Missing color metadata).

### 3. Inventory Health Distribution
- **Ready to Ship (>10 Pcs)**: 1 Design (Extremely thin live catalog).
- **Zombie Designs (Zero/Negative/Null)**: 95 Designs (Potential "Legacy Noise").

> [!TIP]
> **UI Design Tip**: When building the Item Master sidebar, provide a "Live Only" toggle that filters out designs where `STOCK <= 0` to help users focus on what's actually in the warehouse.
