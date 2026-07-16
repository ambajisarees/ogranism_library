# Table Documentation: `sq_CLOTHTYPE` (Fabric Categories)

## Overview
Defines the highest level of fabric classification (e.g., Cotton, Silk, Polyester). Used for top-level sales analysis and setting global costing multipliers.

## Business Context & Insights
- **The "Great Multiplier"**: The `COST_PER` column here is intended to be a global markup factor for all qualities under this cloth type.
- **Data Debt**: Currently, the table is a flat list of names. Costing and Unit definitions are missing, which means the app currently treats all cloth types as "unitless".

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 8
- **Row Count**: 13
- **Data Completeness**: 12.5% (Only naming is present)

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **CLOTHTYPE** | character varying | 0% | **PRIMARY KEY** | Fabric category name (e.g., LACE). |
| **UNIT** | character varying | 100% | **TODO** | Base unit (PCS/MTS). Essential for stock math. |
| **COST_PER** | numeric | 100% | **TODO** | Global profit multiplier for this fabric family. |
| **PACK_COST** | numeric | 100% | **TODO** | Standard packing overhead for this cloth type. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identity
- `CLOTHTYPE`: The unique label.

### 2. [TODO] Costing & Inventory Rules
- `UNIT`: **TARGET**: Specify if the fabric is sold by piece (PCS) or meter (MTS).
- `COST_PER`: **TARGET**: Implement global price indexing for "Cost-Plus" pricing.
- `PACK_COST`: **TARGET**: Default packing deduction for Job Work settlements.

## SQL Audit Snippet
```sql
-- Check list of cloth types that need UNIT assignments
SELECT "CLOTHTYPE" FROM "IMMBE2627"."sq_CLOTHTYPE" WHERE "UNIT" IS NULL;
```
