# Table Documentation: `sq_ACGROUP` (Account Groups)

## Overview
This table defines the "Production Silos" and "Accounting Categories" for all parties (Masters). It is the backbone of the filtering system for Grey Purchase, Job Work, and Sales Ledger modules.

## Business Context & Insights
- **Production Routing**: Accounts are primarily grouped by their role in the textile chain (e.g., `ATYPE = 2` for Grey Suppliers).
- **Naming Pattern**: Most groups follow the `[Person] + [Quality Name]` convention (e.g., "Smit Cotton").
- **Financial Enforcement**: Fields like `CRLIMIT` and `DHARA` here set the defaults for all parties created under the group.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 62
- **Row Count**: 445
- **Data Completeness**: ~65% (High density in financial/identity, low in contact/logistics)

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **gcode** | character varying | 0% | **PRIMARY KEY** | Unique business identifier. |
| **NAME** | character varying | 0% | **IDENTITY** | Full display name of the group. |
| **ATYPE** | bigint | 0% | **FOREIGN KEY** | Maps to [sq_ATYPE](file:///C:/Users/smitt/.gemini/antigravity/scratch/textile_erp/backend/schema_docs/01_constants/sq_ATYPE.md). |
| **groupno** | bigint | 0% | **ID** | Internal sequence number. |
| **ADDRESS1** | character varying | 50.1% | CONTACT | Primary address line. |
| **ADDRESS2** | character varying | 27.2% | CONTACT | Secondary address line. |
| **ADDRESS3** | character varying | 100% | **TODO** | Tertiary address - Placeholder. |
| **CITY1** | character varying | 5.8% | LOGISTICS | Critical for regional sorting. |
| **CONTACT** | character varying | 32.1% | CONTACT | Focal contact person name. |
| **MOBILE** | character varying | 64.0% | CONTACT | Primary mobile (WhatsApp target). |
| **EMAIL** | character varying | 95.7% | CONTACT | Rarely used in current data. |
| **CRDAYS** | bigint | 0.2% | CREDIT | Default credit days allowed. |
| **CRLIMIT** | numeric | 0% | CREDIT | Default credit limit amount. |
| **DHARA** | numeric | 0.2% | RULES | Payment term deduction logic. |
| **BC** | numeric | 0.4% | RULES | Brokerage percentage. |
| **qd** | numeric | 0% | RULES | Global discount percentage. |
| **TDSRATE** | numeric | 0% | TAX | TDS percentage for payments. |
| **commission** | numeric | 32.3% | RULES | Agent commission rate. |
| **TRANSPORT** | character varying | 97.3% | **TODO** | Preferred transport link. |
| **STATION** | character varying | 100% | **TODO** | Logistic destination (surat/outstation). |
| **FLASH_RMK** | character varying | 88.7% | OPS | High-priority pop-up note for users. |
| **OLDNAME** | character varying | 100% | **IRRELEVANT** | Legacy EMPIRE naming artifacts. |
| **SCREENCOMP** | character varying | 100% | **IRRELEVANT** | Legacy UI component markers. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata (Sync only). |

## Reimagined Categorization

### 1. [ACTIVE] Identity & Hierarchy
- `gcode`: Unique Group Code.
- `NAME`: Full Group Name.
- `ATYPE`: Functional category (Maps to Account Types).
- `custtype`: Customer classification.

### 2. [ACTIVE] Financials & Credit Rules
- `CRLIMIT` / `DRLIMIT`: Credit/Debit safety boundaries.
- `CRDAYS` / `DRLIMIT_DAYS`: Grace periods for payments.
- `qd`: Global "Quality Discount" percentage applied to invoices.
- `BC` / `SALEBC`: Brokerage rates for inward/outward movement.
- `DHARA` / `PURDHARA`: Deduction styles for local vs outstation payments.
- `TDSRATE`: TDS compliance setting.

### 3. [ACTIVE] Contact & Communication
- `MOBILE`: SMS/WhatsApp target.
- `CONTACT`: Person to call.
- `ADDRESS[1-2]`: Physical location.
- `CITY1`: The city where the group is based.

### 4. [TODO] Logistics Master Data
- `STATION`: **TARGET**: Define outstation hubs for dispatch logic.
- `TRANSPORT`: **TARGET**: Link to master transport agencies.
- `STDCODE` / `PINNO`: **TARGET**: Clean up for E-Way Bill accuracy.

### 5. [IRRELEVANT] Legacy & System Internals
- `OLDNAME`: Not needed in new stack.
- `SCREENCOMP`: Legacy UI metadata.
- `INCENTMODE` / `PARTY_GRADE`: 100% empty, likely unused legacy features.
- `CREATOR` / `UPDATER`: Legacy audit logs (Supabase tracks this via `auth.users`).

## SQL Audit Snippet
```sql
-- Analyze data gaps in crucial logistics fields
SELECT 
  COUNT(*) as total,
  COUNT("STATION") as filled_station,
  COUNT("TRANSPORT") as filled_transport
FROM "IMMBE2627"."sq_ACGROUP";
```
