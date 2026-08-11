# Architectural Specification — Items, Designs, Media & Stock Integration

> **Target Domain**: Designs Master (`sb_designs`), Processing Source & Matching Recipes, Design-to-Job Cards 1-to-Many Linkage, Joined Stock View (`vw_designs_with_stock`), Items Extension (`sb_item_ext`)  
> **Schema**: `IMMBE2627` in Supabase Postgres 17  

---

## 1. Core Architecture: Master Design vs Multi-Design Catalog

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
│ • Used for Plain/Solid items             │                       │ • Used for specific catalog design SKUs  │
└──────────────────────────────────────────┘                       └──────────────────────────────────────────┘
```

---

## 2. Designs Master Table Specification: `IMMBE2627.sb_designs`

| Column Name | Data Type | Default / Constraint | Business & Technical Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | `gen_random_uuid() PK` | Internal Supabase UUID |
| `design_code` | `text` | `NOT NULL UNIQUE` | Composite Primary Business Key (`itemqcode-design_no`, e.g. `VIDHI-MAIN`, `VIDHI-101`) |
| `itemsrno` | `varchar(10)` | `NOT NULL` | Foreign key linking to Item Master `sq_QUAL.itemsrno` (e.g. `00113`) |
| `itemqcode` | `text` | `NOT NULL` | Item code string (e.g. `VIDHI`) |
| `design_no` | `text` | `NOT NULL` | Commercial design number (`Main` for single items, `101`, `102` onwards for catalogs) |
| `is_master` | `boolean` | `false` | `true` for `Main` master design only |
| `lifecycle_stage` | `text` | `'MILL_STAGE'` | Stage (`MILL_STAGE`, `IN_PRODUCTION`, `IN_STOCK`, `LOW_STOCK`, `REPEAT_REQ`, `ARCHIVED`) |
| `source_type` | `text` | `NULL` | Processing origin style (`PRINT`, `DYED`, `DIGITAL`, `TOPDYED`) |
| `source_vendor` | `text` | `NULL` | Mill / Vendor code referencing `sq_MASTER.code` (e.g. `M-0012`) |
| `source_desno` | `text` | `NULL` | Processing mill's internal design number (e.g. `MILL-902`) |
| `source_jobtype` | `text` | `NULL` | Processing job type / category (e.g. `MILL_PRINT`, `EMBROIDERY`, `STITCHING`) |
| `final_saree_wt` | `numeric(8,3)` | `0.000` | Finished saree weight in Kg (e.g. `0.650`) |
| `pcs_per_set` | `integer` | `6` | Set matching selection (4, 5, or 6 pcs per color set) |
| `final_bundle_wt` | `numeric(8,3)` | `0.000` | Recorded final bundle weight for `pcs_per_set` quantity |
| `options_matching` | `jsonb` | `'[]'::jsonb` | All available mill matching options (e.g. 8 mill matchings `[M1..M8]`) |
| `final_matching` | `jsonb` | `'[]'::jsonb` | Approved final color set selected at program stage (e.g. 5 or 6 pcs `[M1..M6]`) |
| `reorder_level_pcs` | `integer` | `100` | Low stock threshold triggering `REPEAT_REQ` or `LOW_STOCK` |
| `media_urls` | `jsonb` | `'[]'::jsonb` | Universal media JSON array holding image/video URLs |
| `pdf_paths` | `jsonb` | `'[]'::jsonb` | Universal PDF JSON array holding catalog spec paths |
| `created_at` | `timestamptz` | `NOW()` | Creation timestamp |
| `updated_at` | `timestamptz` | `NOW()` | Update timestamp |
| `created_by` | `uuid` | `NULL` | User UUID who created record |
| `updated_by` | `uuid` | `NULL` | User UUID who updated record |

---

## 3. Key Technical Architecture Specifications

### A. Matching Recipe & Vendor Palette Templates
- **Vendor Recipe Templates**: Processing mills predefine standard 8-matching color recipes.
- **`options_matching` (`jsonb`)**: Stores the full 8-matching options list.
- **`final_matching` (`jsonb`)**: Stores the final 5 or 6 approved color matchings selected at the Mill Program stage for set packaging (`pcs_per_set`).

---

### B. Joined Database View: `IMMBE2627.vw_designs_with_stock`

```sql
CREATE OR REPLACE VIEW "IMMBE2627"."vw_designs_with_stock" AS
SELECT 
    d.id,
    d.design_code,
    d.itemsrno,
    d.itemqcode,
    d.design_no,
    d.is_master,
    d.lifecycle_stage,
    d.source_type,
    d.source_vendor,
    d.source_desno,
    d.source_jobtype,
    d.final_saree_wt,
    d.pcs_per_set,
    d.final_bundle_wt,
    d.options_matching,
    d.final_matching,
    d.reorder_level_pcs,
    d.media_urls,
    d.pdf_paths,
    d.created_at,
    d.updated_at,
    
    -- Joined Live Stock Ledger Metrics
    COALESCE(s.stock_in, 0) AS stock_in,
    COALESCE(s.stock_out, 0) AS stock_out,
    COALESCE(s.current_stock, 0) AS current_stock,
    COALESCE(s.stock_at_mill, 0) AS stock_at_mill,
    COALESCE(s.stock_at_job, 0) AS stock_at_job,
    COALESCE(s.fl_booked, 0) AS fl_booked,
    COALESCE(s.fl_converted, 0) AS fl_converted,
    COALESCE(s.fl_pending, 0) AS fl_pending,
    COALESCE(s.so_booked, 0) AS so_booked,
    COALESCE(s.so_delivered, 0) AS so_delivered,
    COALESCE(s.so_pending, 0) AS so_pending,
    COALESCE(s.so_orderable, 0) AS so_orderable,
    COALESCE(s.fl_orderable, 0) AS fl_orderable

FROM "IMMBE2627"."sb_designs" d
LEFT JOIN "IMMBE2627"."vw_stock_summary" s ON d.design_code = s.design_code;
```
