# Master Schema & Domain Analysis: `sq_QUAL` (Item Master Engine)

> **Database Schema Context**: `IMMBE2627.sq_QUAL` (Legacy Empire Item Master)  
> **Total Active Records Analyzed**: **1,016 Rows** (100% Database Row Audit)  
> **Purpose**: Deep architectural breakdown of `sq_QUAL` columns, data distributions, null/zero rates, and sales/financial behavior to design the next-generation Item domain.

---

## 1. Executive Summary & Domain Concept

In legacy Empire (AMAZE ERP), **`sq_QUAL`** acts as the central **Item Master**.

### Key Sales & Financial Characteristics:
1. **High-Level Sales Entity**:
   - Stock is held and dispatched at the Item level (`qcode` / `NAME`).
   - Sales returns, wholesale invoice billing, GST tax line calculations, and sales analytics all dereference `sq_QUAL`.
2. **Legacy Architectural Gaps**:
   - **No Sub-Level Batch/Lot Stock Tracking**: Empire tracks global item stock quantity without sub-piece/lot level lineage.
   - **No Price History / Audit Logging**: `SELL1` stores only a single mutable float value. Price changes overwrite previous prices without an audit log or effective date ranges.
   - **No Renaming Audit Trail**: Renaming an item mutates `NAME` globally, breaking historical invoice search context.

---

## 2. Full Column Analysis (47 Total Columns Profiled)

Below is the complete profile of all 47 columns in `IMMBE2627.sq_QUAL`, categorized by business domain.

### A. Primary Identification & Catalog Specs

| Column Name | Postgres Type | Non-Null Count | Null / Zero / Empty | Distinct Values | Business & Sales Domain Description |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **`qcode`** | `varchar` | **1,016** | 0 (0%) | **1,016** | **Primary Key / Item Master Code**: Unique internal code string assigned to every item/quality (e.g. `Q-001`, `Q-1045`). |
| **`NAME`** | `varchar` | **1,016** | 0 (0%) | **1,016** | **Item Catalog Name**: Full commercial name of the saree/fabric (e.g. `Geetanjali-01`, `Vidhi-31`, `Pashmina Silk-02`, `Star Brasso-17`). |
| **`itemsrno`** | `varchar` | **1,016** | 0 (0%) | **1,016** | **Item Serial Sequence**: Internal numerical sequence string matching `qcode`. |
| **`category`** | `varchar` | **722** | 294 (28.9%) | **8** | **Catalog Collection / Brand Group**: Major catalog groupings (`SAREES`: 393, `2025`: 174, `NAMAMI`: 80, `EMB`: 61, `SECOND`: 8, `PACKING`: 4). |
| **`CLOTHTYPE`** | `varchar` | **1,016** | 0 (0%) | **5** | **Product Category Classification**: Top-level product category (`SAREE`: 613, `FINAL`: 313, `-`: 51, `DRESS`: 38, `material`: 1). |

---

### B. Pricing, Financial & Tax Specifications

| Column Name | Postgres Type | Non-Null Count | Null / Zero / Empty | Distinct Values | Business & Sales Domain Description |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **`SELL1`** | `numeric` | **1,016** | 242 zeroes (23.8%) | **212** | **Primary Wholesale Selling Price (₹/Pc)**: Active selling price used in sales billing (Range: ₹0.00 to ₹15,500.00; Average: ₹345.66). |
| **`SELL2`** | `numeric` | 925 | 925 zeroes (100%) | 1 | *Unused Legacy Tier 2 Price*: Reserved in legacy schema for secondary dealer price tiers. |
| **`SELL3`** | `numeric` | 925 | 925 zeroes (100%) | 1 | *Unused Legacy Tier 3 Price*: Reserved in legacy schema for tertiary price tiers. |
| **`pur1`** | `numeric` | 1,016 | 1,013 zeroes (99.7%) | 4 | *Legacy Purchase Price*: Rarely populated; true purchase costs are derived dynamically from grey purchase bills & mill job rates. |
| **`GSTRATE`** | `numeric` | **991** | 205 zeroes (20.2%) | **4** | **GST Tax Percentage Rate**: Standard GST rate applied on sales invoices (`5%`: 693 items, `0%`: 205 items, `18%`: 85 items, `12%`: 8 items). |
| **`HSN_CODE`** | `varchar` | **940** | 76 nulls (7.5%) | **76** | **HSN Tax Code**: Statutory HSN code for GST compliance (e.g., `5407` for synthetic woven fabric, `5208` for cotton, `9988` for job work). |

---

### C. Physical Manufacturing & Packaging Attributes

| Column Name | Postgres Type | Non-Null Count | Null / Zero / Empty | Distinct Values | Business & Sales Domain Description |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **`CUT`** | `numeric` | **1,016** | 298 zeroes (29.3%) | **13** | **Standard Finished Cut Spec (Mtr)**: Finished length per saree piece (`5.20`: 412, `6.00`: 285, `6.30`: 12, `5.50`: 5; Average: 4.38 Mtr). |
| **`UNIT`** | `varchar` | **1,016** | 0 (0%) | **3** | **Unit of Measurement (UOM)**: Sales billing UOM (`PCS`: 1,005 items / 98.9%, `KG`: 7 items, `MTS`: 4 items). |
| **`PACKING`** | `varchar` | **984** | 32 nulls (3.2%) | **7** | **Packaging Type Specification**: (`CHAINBAG`: 675, `NAKED`: 284, `POUCH`: 8, `BOX COMBO`: 8, `THELI PACK`: 5). |
| **`PCS_PER_SET`** | `bigint` | **717** | 299 nulls (29.4%) | **12** | **Design Set Pack Quantity**: Saree pieces per catalog set/box (e.g. `8`, `10`, `12` pcs per matching design set). |
| **`ISBASEQUAL`** | `varchar` | **1,016** | 0 (0%) | **3** | **Base Fabric Indicator**: (`N`: 870 finished items, `Y`: 111 raw grey fabric qualities, `G`: 35 grey challan masters). |
| **`BASEQUAL`** | `varchar` | **51** | 965 nulls (95.0%) | **28** | **Parent Grey Quality Link**: Connects finished sales item back to raw grey fabric quality (e.g. `MAJOR GEORGETTE PLAIN`). |
| **`MAINSCREEN`** | `varchar` | **878** | 138 nulls (13.6%) | **114** | **Primary Printing Screen Reference**: Design screen group for mill printing execution. |

---

### D. System Audit & Unused Legacy Fields

| Column Name | Postgres Type | Non-Null Count | Null / Zero / Empty | Description / Status |
| :--- | :--- | :---: | :---: | :--- |
| **`CREATOR`** | `varchar` | 849 | 167 nulls | User ID who created the item master record. |
| **`UPDATER`** | `varchar` | 795 | 221 nulls | User ID who last updated the item master record. |
| **`CREATETIME`** | `timestamp` | 849 | 167 nulls | Creation timestamp in database. |
| **`UPDATETIME`** | `timestamp` | 795 | 221 nulls | Last update timestamp in database. |
| **`EXTRA_RMK`** | `varchar` | 709 | 307 nulls | Extra remarks / process notes (`57 confirm`, `47 confirm`, `rose gold 2 rs`). |
| **`EXTRA_CUT`** | `varchar` | 93 | 923 nulls | Extra cut allowance notes. |
| **`all_screens_same`**| `boolean` | 1,016 | 0 nulls | Flag indicating if all colorways use the same screen set (`true`/`false`). |
| **`BLOUSE`**, **`avg_wt`**, **`ACT_CUT`**, **`VATRATE`**, **`COST_PER`**, **`LESSFOLD`**, **`OLDQCODE`**, **`SUPPLIER`**, **`EXTRA_QTY`**, **`EXTRA_QTY2`**, **`SCREENCOMP`**, **`ADD_VATRATE`**, **`EXTRA_SELL1`**, **`EXPECT_SHORTAGE`** | Various | 0 | **100% Null / Zero Unused Legacy Columns**: 14 legacy columns retained from old MSSQL schema that have 0 non-null data. |
