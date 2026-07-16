# Table Documentation: `sq_CITIES` (Transit Hubs)

## Overview
A flat list of cities used for Master address entry and Dispatch routing. Currently contains legacy data that needs standardization as it lacks state and regional markers.

## Business Context & Insights
- **Concentration**: High concentration in the "Maharashtra Corridor" (Mumbai, Bhiwandi, Ichalkaranji).
- **Data Debt**: The `STATE` and `REGION` columns are currently empty. The business logic currently relies on parsing the `CITY` name suffix (e.g., "-MH") for state identification.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 10
- **Row Count**: 772
- **Data Completeness**: 10% (Only the City name is populated)

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **CITY** | character varying | 0% | **PRIMARY KEY** | Unique City Name (contains regional suffix). |
| **STATE** | character varying | 100% | **TODO** | Target for GST/E-Way Bill automation. |
| **REGION** | character varying | 100% | **TODO** | Target for sales grouping (North/South). |
| **COUNTRY** | character varying | 100% | **IRRELEVANT** | Domestic only currently. |
| **city_distance** | numeric | 100% | **TODO** | Needed for auto-calculating KM in E-Way Bills. |
| **MU_PER** | numeric | 100% | **TODO** | Potential for region-based markups. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identity
- `CITY`: Unique location name.

### 2. [TODO] Geography & Logistics (High Priority)
- `STATE`: Essential for GST state-code mapping.
- `REGION`: Useful for Sales Team territory assignment.
- `city_distance`: Crucial for E-Way Bill "Distance" field (saves manual entry).

### 3. [IRRELEVANT] Legacy
- `COUNTRY`: All entries are domestic.
- `MU_PER`: No current business use for this field.

## SQL Audit Snippet
```sql
-- Identify patterns to help automate the TODO 'STATE' field
SELECT 
  "CITY",
  CASE 
    WHEN "CITY" LIKE '%-MH%' THEN 'MAHARASHTRA'
    WHEN "CITY" LIKE '%-GJ%' THEN 'GUJARAT'
    ELSE 'UNKNOWN'
  END as derived_state
FROM "IMMBE2627"."sq_CITIES"
LIMIT 20;
```
