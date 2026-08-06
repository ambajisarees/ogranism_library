# Architectural Specification — Items, Designs, Media & Audit Engine

> **Target Domain**: Items Master (`sq_QUAL` + `sb_item_ext`), Price & Rename Audit (`sb_item_audit`), Designs Master (`sb_designs`), Universal Media Engine (`sb_media_urls`), and Packaging Metadata.  
> **Schema**: `IMMBE2627` in Supabase Postgres 17.

---

## 1. 100% Future-Proof Item & Design Relationship Model

### The Core Design Strategy: Master Design vs Multi-Design Catalog

To accommodate both **Solid/Plain Items** (no design numbers) and **Multi-Design Catalogs** (sequential design numbers `#101`, `#102`, etc.):

```
                          ┌─────────────────────────────────────────┐
                          │     ITEM MASTER (sq_QUAL + sb_item_ext) │
                          │     itemsrno: "00113" (Vidhi-31)        │
                          └────────────────────┬────────────────────┘
                                               │
                                ┌──────────────┴──────────────┐
                                │ 1-to-Many Design Relation   │
                                └──────────────┬──────────────┘
                                               │
        ┌──────────────────────────────────────┴──────────────────────────────────────┐
        ▼                                                                             ▼
┌──────────────────────────────────────────┐                       ┌──────────────────────────────────────────┐
│ DEFAULT MASTER DESIGN (`sb_designs`)      │                       │ CATALOG DESIGN SKUs (`sb_designs`)       │
├──────────────────────────────────────────┤                       ├──────────────────────────────────────────┤
│ • design_code: "VIDHI-MAIN"              │                       │ • design_code: "VIDHI-101"               │
│ • is_master: true                        │                       │ • is_master: false                       │
│ • design_no: "Main"                      │                       │ • design_no: "101"                       │
│ • Used for Plain/Solid items &           │                       │ • Used for specific catalog design SKUs  │
│   global item sales rollup               │                       │                                          │
└──────────────────────────────────────────┘                       └──────────────────────────────────────────┘
```

#### Strategic Contract:
1. **Single Master Design Default**: Every Item created automatically receives a **Master Design Entity** (`is_master = true`, `design_no = 'Main'`). For plain items, production and sales move through this single entity without requiring staff to invent dummy design numbers.
2. **Multi-Design Production**: For catalog items, production can issue sequential Job Cards against specific Design SKUs (`design_no = '101'`).
3. **Sales Rollup**: Sales orders can bill either at the specific Design SKU level or roll up seamlessly to the Master Item.

---

## 2. Table Schema Specifications

### A. Extended Item Master Table: `IMMBE2627.sb_item_ext`

Extends legacy `sq_QUAL` without mutating the read-only mirror table.

| Column Name | Data Type | Default / Constraint | Business & Technical Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | `gen_random_uuid() PRIMARY KEY` | Internal Supabase UUID primary key |
| `itemsrno` | `varchar(10)` | `NOT NULL UNIQUE` | Invariant Primary Key referencing `sq_QUAL.itemsrno` |
| `qcode` | `text` | `NOT NULL` | Active Item Master Code (e.g. `Q-0113`) |
| `name` | `text` | `NOT NULL` | Active Item Catalog Name (e.g. `Vidhi-31`) |
| `item_alias_names` | `jsonb` | `'[]'::jsonb` | Array of historical/alternate names (e.g. `["Vidhi 31 Old", "Vidhi Silk"]`) |
| `target_cost_per_pc` | `numeric(12,2)` | `0.00` | Target estimated cost per saree piece |
| `last_landed_cost_per_pc` | `numeric(12,2)` | `0.00` | Latest calculated landed cost per piece from Cutting Cards |
| `cost_trend_status` | `text` | `'STABLE'` | Calculated cost status (`COST_INCREASED`, `COST_DECREASED`, `STABLE`) |
| `bundle_wt_kg` | `numeric(8,3)` | `0.000` | Default weight per finished bundle in Kg |
| `est_pcs_per_bundle` | `integer` | `0` | Standard saree pieces per bundle (e.g. `10` or `12`) |
| `bale_wt_kg` | `numeric(8,3)` | `0.000` | Default weight per transport bale in Kg |
| `est_pcs_per_bale` | `integer` | `0` | Estimated saree pieces per transport bale (e.g. `120` or `144`) |
| `reorder_threshold_pcs` | `integer` | `100` | Minimum stock threshold triggering `Low on Stock` status |
| `master_design_id` | `uuid` | `NULL` | Foreign key referencing primary `sb_designs.id` |
| `sb_media_urls` | `jsonb` | `'[]'::jsonb` | Array of universal item media URLs |
| `sb_status` | `text` | `'ACTIVE'` | Item lifecycle status (`ACTIVE`, `ARCHIVED`) |
| `sb_created_at` | `timestamptz` | `NOW()` | Record creation timestamp |
| `sb_updated_at` | `timestamptz` | `NOW()` | Record update timestamp |

---

### B. Item Price & Rename Audit Log: `IMMBE2627.sb_item_audit`

Captures 100% immutable audit history whenever prices, costs, or catalog names change.

| Column Name | Data Type | Default / Constraint | Business & Technical Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | `gen_random_uuid() PRIMARY KEY` | Internal UUID |
| `itemsrno` | `varchar(10)` | `NOT NULL` | Foreign key referencing `sq_QUAL.itemsrno` |
| `qcode` | `text` | `NOT NULL` | Active item code at moment of audit |
| `audit_type` | `text` | `NOT NULL` | Audit event type (`PRICE_CHANGE`, `NAME_CHANGE`, `COST_UPDATE`) |
| `old_value` | `text` | `''` | Previous value (e.g. `SELL1 = 345.00` or `NAME = Vidhi-31`) |
| `new_value` | `text` | `''` | New value (e.g. `SELL1 = 375.00` or `NAME = Vidhi-31 Premium`) |
| `value_delta` | `numeric(12,2)` | `0.00` | Numerical variance (+₹30.00 or -₹15.00) |
| `cost_per_pc_at_event` | `numeric(12,2)` | `0.00` | Landed cost per piece at moment of change |
| `change_reason` | `text` | `''` | User-entered reason for price/name change |
| `sb_created_at` | `timestamptz` | `NOW()` | Immutable timestamp of audit event |
| `sb_created_by` | `uuid` | `NOT NULL` | User UUID who initiated change |

---

### C. Designs Master Table: `IMMBE2627.sb_designs`

Central Design SKU entity linking Production (Job Cards) to Sales (Packing & Orders).

| Column Name | Data Type | Default / Constraint | Business & Technical Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | `gen_random_uuid() PRIMARY KEY` | Internal Supabase UUID |
| `design_code` | `text` | `NOT NULL UNIQUE` | Composite Primary Business Key (`itemqcode-design_no`, e.g. `VIDHI-MAIN`, `VIDHI-101`) |
| `itemsrno` | `varchar(10)` | `NOT NULL` | Foreign key linking to Item Master `itemsrno` (user selects item in UI) |
| `itemqcode` | `text` | `NOT NULL` | Item code string (e.g. `VIDHI`) |
| `design_no` | `text` | `NOT NULL` | Commercial design number (`Main` for single items, `101`, `102` onwards for catalogs) |
| `is_master` | `boolean` | `false` | `true` for `Main` master design only |
| `lifecycle_stage` | `text` | `'PROGRAMMED'` | Stage (`PROGRAMMED`, `IN_PRODUCTION`, `IN_STOCK`, `LOW_STOCK`, `ARCHIVED`) |
| `job_card_vno` | `integer` | `NULL` | Foreign key referencing current production `sq_CHALTRN` / `sb_jobcards` |
| `override_bundle_wt_kg` | `numeric(8,3)` | `NULL` | Optional design-specific bundle weight override |
| `override_est_pcs_per_bundle` | `integer` | `NULL` | Optional design-specific pieces per bundle override |
| `current_finished_pcs` | `integer` | `0` | Current available packed stock pieces |
| `current_in_production_pcs` | `integer` | `0` | Work-in-progress pieces currently in mill/job work |
| `sb_media_urls` | `jsonb` | `'[]'::jsonb` | Universal media array holding all design images |
| `sb_status` | `text` | `'ACTIVE'` | Record status (`ACTIVE`, `ARCHIVED`) |
| `sb_created_at` | `timestamptz` | `NOW()` | Creation timestamp |
| `sb_updated_at` | `timestamptz` | `NOW()` | Update timestamp |

---

## 3. User Notes & Design Key Specification

> **User Design Key Structure & Mapping Contract**:
> - **`uuid`**: Internal unique row ID for Supabase.
> - **`itemsrno`**: Invariant 5-digit Empire serial number (e.g. `00113`). Links directly to the item record selected by the user in the UI dropdown/autocomplete.
> - **`itemqcode`**: The item quality code string (e.g. `VIDHI`).
> - **`design_no`**: Design designation string. Defaults to **`Main`** for single/plain items, or **`101`**, **`102`**, **`103`** onwards for multi-design catalogs.
> - **`design_code`**: Composite unique primary business key constructed as **`itemqcode-design_no`** (e.g. `VIDHI-MAIN` or `VIDHI-101`).
> - **`is_master`**: Boolean flag set to **`true` for `Main` only** (`false` for all secondary catalog designs).
> - **`lifecycle_stage`**: State machine indicator tracking design progression through the pipeline:
>   1. `PROGRAMMED` (Mill Program created)
>   2. `IN_PRODUCTION` (Job Card issued & undergoing mill/job work processing)
>   3. `IN_STOCK` (Finished saree pieces packed & available in warehouse)
>   4. `LOW_STOCK` (Available finished inventory below reorder threshold)
>   5. `ARCHIVED` (Design retired/discontinued)
