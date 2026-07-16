# Table Documentation: `sq_MASTER` (Account Ledger / Party Master)

## Overview
The most critical master table in the ERP. It stores the exhaustive profile for every Party (Suppliers, Customers, Job Workers). Every transaction in the system (Sales, Purchase, Production) is linked to a `code` in this table.

## Business Context & Insights
- **Communication Ready**: ~70% of parties have **Mobile** numbers, enabling instant WhatsApp dispatch alerts as a first-day feature.
- **Logistics Distinction**: The data clearly distinguishes between `CITY1` (Billing/Address city) and `STATION` (The logistics/railway hub for outstation movement).
- **Financial Rigidity**: Accounting fields like `QD`, `BC`, and `Dhara` are 99%+ populated, ensuring that the legacy settlement logic can be perfectly replicated in the new stack.
- **KYC Gaps**: ~38% of parties are missing a `GSTIN`, which is a high-priority "Compliance Debt" for the B2B sales module.

## Comprehensive Data Audit
**Metrics:** 
- **Column Count**: 79
- **Row Count**: 4,941
- **Data Completeness**: ~52% (High on finances, extremely low on KYC/MSME)

| Column | Data Type | % Null/Empty | Role | Business Note |
|:---|:---|:---|:---|:---|
| **code** | character varying | 0% | **PRIMARY KEY** | Unique system code for the party. |
| **NAME** | character varying | 0% | **IDENTITY** | Full legal name of the party. |
| **GCODE** | character varying | 0% | **KEY** | Maps to [sq_ACGROUP](file:///C:/Users/smitt/.gemini/antigravity/scratch/textile_erp/backend/schema_docs/02_masters/sq_ACGROUP.md). |
| **ATYPE** | bigint | 0% | **KEY** | Maps to [sq_ATYPE](file:///C:/Users/smitt/.gemini/antigravity/scratch/textile_erp/backend/schema_docs/01_constants/sq_ATYPE.md). |
| **ADATIYA** | character varying | 21.4% | **KEY** | Associated commission agent link. |
| **CITY1** | character varying | 0.1% | LOGISTICS | General city for the party. |
| **STATION** | character varying | 38.3% | **LOGISTICS** | **Hub**: Primary railway/logistics center. |
| **MOBILE** | character varying | 31.0% | CONTACT | Primary SMS/WhatsApp contact. |
| **GSTIN** | character varying | 38.1% | COMPLIANCE | Required for B2B tax invoicing. |
| **crdays** | bigint | 0.1% | CREDIT | Grace period for payments. |
| **TDSRATE** | numeric | 0.2% | TAX | TDS deduction percentage. |
| **qd** / **bc** | numeric | <0.1% | RULES | Global Discount/Brokerage rates. |
| **dhara** | numeric | 0.2% | RULES | Settlement style multiplier. |
| **ADDRESS1/2** | character varying | ~40% | CONTACT | Primary mailing address. |
| **bank_name/acno** | character varying | 99.8% | **TODO** | Automated bank settlement info. |
| **MSME_NO** | character varying | 99.5% | **TODO** | Essential for MSME-45 day law compliance. |
| **EMAIL** | character varying | 94.8% | **TODO** | Automated statement mailing target. |
| **FLASH_RMK** | character varying | 74.1% | OPS | Priority pop-up alert for users. |
| **GSTNO** | character varying | 99.9% | **IRRELEVANT** | Legacy pre-GST placeholder. |
| **ADDRESS3/4** | character varying | 100% | **IRRELEVANT** | Unused legacy artifacts. |
| **_airbyte_...** | (various) | 0% | **IRRELEVANT** | Airbyte metadata. |

## Reimagined Categorization

### 1. [ACTIVE] Identity & Hierarchy
- `code` / `NAME`: Core party identity.
- `GCODE`: Linked to account groups/silos.
- `ADATIYA`: Used for party-broker-adatiya tri-mapping.

### 2. [ACTIVE] Logistics & Geography
- `CITY1`: Mailing/Identity city.
- `STATION`: **Logistics Hub** for dispatch routing.
- `TRANSPORT` / `DISTANCE`: Defaults for courier/truck movement.

### 3. [ACTIVE] Financial Rules (The "Engine")
- `crdays`: Payment terms enforcement.
- `qd`: Automatic "Quality Discount" at invoice line level.
- `bc` / `SALEBC`: Brokerage calculation triggers.
- `dhara`: Master logic for settlement deductions.
- `TDSRATE`: Withholding tax rate.

### 4. [ACTIVE] Contact & Communication
- `MOBILE`: Primary digital outreach.
- `ADDRESS1` / `ADDRESS2`: Focused mailing address (ignore 3/4).
- `CONTACT`: The specific person to coordinate with.
- `FLASH_RMK`: Critical constraints (e.g., "Cash Only", "Overdue").

### 5. [TODO] Compliance & Automation (Critical)
- `GSTIN`: **TARGET**: Update missing parties for B2B legality.
- `MSME_NO`: **TARGET**: Financial risk prevention (45-day payment rule).
- `bank_name` / `acno`: **TARGET**: Enable automated "One-Click" payouts.

### 6. [IRRELEVANT] Legacy
- `GSTNO`: Use `GSTIN` instead.
- `ADDRESS3 / 4`: No current utility.
- `SCREENCOMP`: Legacy UI metadata.

## SQL Audit Snippet
```sql
-- Identify Outstation Parties missing a Logistics Hub (Station)
SELECT "NAME", "CITY1" 
FROM "IMMBE2627"."sq_MASTER" 
WHERE "CITY1" != 'SURAT' AND "STATION" IS NULL;
```

## Filterable Insights & Distributions
To design efficient search and filter UIs in Flutter, we analyze the cardinality and distribution of the core master columns.

**Metrics Summary:**
- **Unique Cities**: 636 (Highest diversity, requires autocomplete search)
- **Unique Stations**: 500 (Logistics hubs)
- **Unique Groups (GCODE)**: 440 (Highly granular categorization)
- **Unique Brokers (ADATIYA)**: 301 (Agent network mapping)
- **Account Types (ATYPE)**: 31 (Structural silos)

### Top Column Distributions

#### 1. Account Types (`ATYPE`)
- **Type 0**: 2,364 parties (General/Uncategorized)
- **Type 2**: 1,223 parties (Likely Grey Suppliers/Job Workers)
- **Type 1**: 776 parties (Likely Primary Customers)
- **Type 4**: 231 parties
- **Type 17**: 86 parties

#### 2. Key Brokers (`ADATIYA`)
- **SELF**: 1,219 parties (No external broker/Direct deal)
- **HARDIKBHAI SURAT**: 87 parties
- **SELF AMBAJI SAREES**: 53 parties
- **MANISH SURAT**: 32 parties
- **SANDEEP SURAT**: 30 parties

#### 3. Regional Hubs (`CITY1`)
- **SURAT**: 2,018 parties (Local Surat ecosystem)
- **LATUR**: 89 parties (Strongest outside Maharashtra hub)
- **BHIWANDI**: 84 parties
- **MUMBAI**: 78 parties
- **ICHALKARANJI**: 72 parties

### Empty/Irrelevant Filter Markers
- **`market`**: 99.8% NULL (Only 9 parties assigned to a market). Avoid using as a primary filter.
- **`division` / `clothtype`**: 100% NULL in current schema. Remove from UI filters.
- **`custtype`**: Binary distribution (Only 2 types used). Use Toggle/Switch UI.

---
## Account Type Distribution (`ATYPE`)
The registry is categorized by the following business roles based on the `LegacyConstants` mapping:

| Code | Account Type Description | Count | Role |
|:---:|:---|:---:|:---|
| **1** | **SUNDRY DEBTORS** | 2,630 | Customers / Buyers |
| **2** | **CREDITORS FOR GREY** | 739 | Raw Fabric Suppliers |
| **12** | **CREDITORS FOR BROKERAGE** | 482 | Commission Agents / Brokers |
| **119** | **CREDITORS FOR EMB.JOB CHARGE** | 238 | Embroidery Units |
| **106** | **CREDITORS FOR EXPENSES** | 117 | General Overheads |
| **113** | **CREDITORS FOR GOODS** | 107 | General Suppliers |
| **21** | **UNSECURED LOANS** | 97 | Financial Liabilities |
| **14** | **CREDITORS FOR DYEING JOB CHARG** | 94 | Processing Mills |
| **112** | **CREDITORS FOR PACKING MAT.** | 87 | Packaging Suppliers |
| **17** | **STAFF** | 86 | Employees |
| **105** | **CREDITORS FOR OTHERS** | 67 | Misc Payables |
| **4/10** | **P&L / TRADING EXPENSES** | 62 | Indirect/Direct Costs |
| **11/103/104** | **FIXED ASSETS** | 25 | Vehicles/Furniture/Assets |
| **99/120** | **MODELLING / MODELING** | 31 | Photoshoot/Marketing |
| **5/6** | **BANK / CASH** | 10 | Liquid Assets |
| **Others** | Minor Silos (TDS, Capital, etc) | 59 | |
| **Total** | | **4,941** | |

## Functional Data Completeness Audit (Null + 0)
This audit treats `NULL`, empty strings (`''`), and numeric **`0`** as "Incomplete Data" to identify functional fields versus default-heavy columns.

### Tier 1: Functional Core (0% - 10% Incomplete)
These columns contain actual, non-zero payloads for nearly all records.

| Column | Incomplete% | Data Type | Business Use |
|:---|:---:|:---:|:---|
| **code** / **NAME** | 0.00% | string | Primary Identity |
| **ATYPE** | 0.00% | int | Account Type |
| **_sync_time** | 0.00% | metadata | Airbyte Sync Marker |
| **CREATOR** / **TIME** | 4.47% | metadata | Audit Trail |
| **companytype** | 4.94% | enum | Legal Status |
| **CITY1** | 7.95% | string | Geography |
| **custtype** | 8.82% | enum | Category Toggle |
| **STATION** | 9.13% | **CRITICAL** | Logistics Hub |

### Tier 2: Intermittent Data (10% - 50% Incomplete)
Operational fields that are frequently populated but have significant gaps.

| Column | Incomplete% | Use Case |
|:---|:---:|:---|
| **PNRNO** | 14.11% | Legacy Index |
| **DISTANCE** | 16.19% | Freight Math |
| **ADDRESS1** | 24.71% | Mailing |
| **ADATIYA** | 25.68% | Broker Link |
| **UPDATER** / **TIME** | 26.96% | Sync Tracking |
| **ADDRESS2** | 27.97% | Secondary Mailing |
| **GSTIN** | 38.13% | B2B Tax |
| **PINNO** | 43.51% | Courier Accuracy |
| **TRANSPORT** | 47.89% | Preferred Carrier |

### Tier 3: Fragmented / Sparse (50% - 95% Incomplete)
Fields where data is the exception, not the rule.

| Column | Incomplete% | Role |
|:---|:---:|:---|
| **MOBILE** | 53.37% | WhatsApp/SMS |
| **CONTACT** | 60.21% | Specific Person |
| **GCODE** | 78.14% | External Linkage |
| **WEB_MOBILE** | 89.19% | Online Presence |
| **FLASH_RMK** | 90.55% | Operator Alerts |
| **PHONE1** | 90.99% | Landline |
| **ADDRESS3** | 93.73% | Bank/Ext Details |

### Tier 4: Default-Only / Dead Wood (95% - 100% Incomplete)
These fields are **functionally empty** (either NULL or 0) and provide zero unique business intelligence in the current registry.

| Column | Incomplete% | Analysis |
|:---|:---:|:---|
| **dhara** | 95.16% | Defaulted to 0 |
| **TDSRATE** | 96.20% | Defaulted to 0 |
| **EMAIL** | 96.26% | Missing for 96% of parties |
| **DRLIMIT** | 97.77% | Credit control not used |
| **crdays** | 99.74% | Defaulted to 0 |
| **bank_name/acno** | 99.80% | Missing banking data |
| **bc** / **qd** | 100.00% | **FIXED**: Global 0 values |
| **SALEBC** | 100.00% | Fixed at 0 |
| **division / market** | 100.00% | Totally empty |
| **clothtype** | 100.00% | Totally empty |

> [!WARNING]
> **Financial Rule Depletion**: The columns `bc` (brokerage) and `qd` (quality discount) are **100% zero or null**. This suggests that either the data was not imported correctly, or the legacy system handles these rules globally rather than at the party-master level.
