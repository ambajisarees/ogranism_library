# Table Documentation: `sq_PACKING` (Packing Styles)

## Overview
Small master table defining the standard ways sarees are packaged (Loose, Box, Full Box, etc.). Directly impacts the final billable amount and job work deductions.

## Business Context & Insights
- **High Data Health**: Unlike most master tables, this is 100% populated. 
- **Costing Accuracy**: The `BOXRATE` and `packadd` columns are the primary inputs for calculating total "Packing Charges" in the Sales Invoice.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 8
- **Row Count**: 5
- **Data Completeness**: 100% (All core fields contain data)

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **PACKING** | character varying | 0% | **PRIMARY KEY** | Style name (e.g., LOOSE PCS, BOX PACKING). |
| **BOXRATE** | numeric | 0% | **RULES** | Standard per-unit charge for this style. |
| **packadd** | numeric | 0% | **RULES** | Extra/Special charge for premium styles. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identity
- `PACKING`: Unique identifier for the style.

### 2. [ACTIVE] Financial Rules
- `BOXRATE`: Base cost for the packaging.
- `packadd`: Supplementary cost (e.g., handles, premium labels).

## SQL Audit Snippet
```sql
-- View all packing styles and their associated costs
SELECT "PACKING", "BOXRATE", "packadd" FROM "IMMBE2627"."sq_PACKING";
```
