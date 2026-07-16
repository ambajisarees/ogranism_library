# Table Documentation: `sq_HASTE` (Agent/Broker Master)

## Overview
This table defines the Brokers and Agents involved in the textile trade. They facilitate sales and production movement, and their data is critical for commission calculations and delivery coordination.

## Business Context & Insights
- **Territory-BASED Logistics**: Analysis shows that agents are heavily linked to specific "Places" (e.g., Bhiwandi, Ichalkaranji). The `PLACE` and `TRANSPORT` columns are nearly 100% populated.
- **Adatiya Mapping**: The `ADATIYA` column links agents to local commission agents, essential for bill settlement routing.
- **Communication Gap**: 98.7% of agents lack mobile numbers in the current database. This is a critical hurdle for the "Direct WhatsApp Notification" feature planned for the app.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 26
- **Row Count**: 911
- **Data Completeness**: ~45%

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **HASTE** | character varying | 0% | **PRIMARY KEY** | Agent/Broker unique name. |
| **ADATIYA** | character varying | 0% | **KEY** | Link to Adatiya network. |
| **PLACE** | character varying | 0.7% | LOGISTICS | Target city/market for this agent. |
| **TRANSPORT** | character varying | 3.3% | LOGISTICS | Preferred transport partner for this agent. |
| **MOBILE** | character varying | 98.1% | **TODO** | Target for WhatsApp/SMS notifications. |
| **ADDRESS1** / **2** | character varying | 74% / 82% | CONTACT | Agent's office location. |
| **CONTACT** | character varying | 94.3% | CONTACT | Focal contact person at the agency. |
| **DISTANCE** | bigint | 91.7% | **TODO** | Transit distance from Surat (E-Way Bill aid). |
| **FLASH_RMK** | character varying | 99.2% | OPS | Priority alert message for the broker. |
| **EMAIL** | character varying | 100% | **IRRELEVANT** | Placeholder - No entries. |
| **EXCISEREG** | character varying | 79.7% | LEGACY | Obsolete registration info. |
| **FAX1** | character varying | 100% | **IRRELEVANT** | Placeholder - No entries. |
| **PHONE1** / **2** | character varying | 99% / 100% | CONTACT | Office landlines. |
| **PINNO** | character varying | 91.9% | LOGISTICS | Registered PIN code. |
| **SCREENCOMP** | character varying | 100% | **IRRELEVANT** | Legacy UI metadata. |
| **CREATOR** / **UPDATER** | (various) | 0% | **IRRELEVANT** | Legacy row logs. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identity & Location
- `HASTE`: Primary Agent Name.
- `ADATIYA`: Associated Adatiya link.
- `PLACE`: The broker's primary market territory.
- `ADDRESS1` / `ADDRESS2`: Registered office address.

### 2. [ACTIVE] Logistics & Movement
- `TRANSPORT`: Default transport link for parties under this broker.
- `DISTANCE`: Numerical distance for E-Way Bill calculation.
- `PINNO`: Pincode for logistics/tax routing.

### 3. [TODO] Digital Outreach (High Priority)
- `MOBILE`: **TARGET**: WhatsApp number for real-time dispatch alerts.

### 4. [TODO] Financial Rules (Normal Priority)
- `commission` / `commtype`: **TARGET**: Define the default commission % for this broker's sales.

### 5. [IRRELEVANT] Legacy & System
- `EMAIL` / `FAX1`: 100% empty legacy fields.
- `SCREENCOMP`: Legacy UI metadata.
- `CREATOR` / `UPDATER`: Handled by new system audit.

## SQL Audit Snippet
```sql
-- Analyze top Adatiyas by Agent volume
SELECT "ADATIYA", COUNT(*) as agent_count 
FROM "IMMBE2627"."sq_HASTE" 
GROUP BY "ADATIYA" 
ORDER BY agent_count DESC;
```
