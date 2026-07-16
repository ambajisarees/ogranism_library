# Table Documentation: `sq_TRANSPORTS` (Logistics Master)

## Overview
A comprehensive list of transport agencies used for goods dispatch. This table is critical for automated E-Way Bill (EWB) generation and driver coordination.

## Business Context & Insights
- **Compliance Strength**: ~77% of agencies have their `TRANSPORTID_EWB` (GSTIN/Trans-ID) populated, making them ready for instant E-Way Bill generation.
- **Communication Gap**: Over 80% of rows are missing mobile or phone numbers, which will require manual data entry to enable the "Click-to-Call" feature in the app.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 11
- **Row Count**: 230
- **Data Completeness**: 55% (Strong on compliance IDs, weak on contact details)

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **TRANSPORT** | character varying | 0% | **PRIMARY KEY** | Unique agency name. |
| **TRANSPORTID_EWB** | character varying | 23.0% | **COMPLIANCE** | GSTIN/Trans-ID for E-Way Bills. |
| **TRANSPORT_MODE** | character varying | 23.9% | **LOGISTICS** | Road vs Rail (Default: 1 for Road). |
| **MOBILE** | character varying | 81.7% | **CONTACT** | Primary driver/booking mobile. |
| **PHONE1** / **PHONE2** | character varying | 80% / 92% | **CONTACT** | Office landlines. |
| **CONTACT** | character varying | 75.2% | **CONTACT** | Focal booking person name. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identity & Identification
- `TRANSPORT`: The unique name of the service provider.

### 2. [ACTIVE] E-Way Bill Compliance
- `TRANSPORTID_EWB`: Essential for digital freight manifest submission.
- `TRANSPORT_MODE`: Required for compliance (1=Road, 2=Rail, 3=Air, 4=Ship).

### 3. [ACTIVE] Operational Contacts
- `MOBILE`: Target for WhatsApp dispatch notifications.
- `CONTACT`: The person to coordinate loading with.
- `PHONE1` / `PHONE2`: Secondary office contacts.

## SQL Audit Snippet
```sql
-- Ranking transport agencies by availability of contact data
SELECT 
  "TRANSPORT",
  (CASE WHEN "MOBILE" IS NOT NULL THEN 1 ELSE 0 END + 
   CASE WHEN "CONTACT" IS NOT NULL THEN 1 ELSE 0 END) as contact_score
FROM "IMMBE2627"."sq_TRANSPORTS"
ORDER BY contact_score DESC, "TRANSPORT" ASC;
```
