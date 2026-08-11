# Architectural Specification — Universal Staging, Extension & Reconciliation Engine

> **System Scope**: Cross-Module Legacy Mirror Coexistence & Modern Workstation Architecture  
> **Schema Context**: `IMMBE2627` in Supabase Postgres 17  
> **Core Guardian Pattern**: `stage_sb_<module>` + `sq_<module>` + `ext_sb_<module>` + `sb_tasks`  

---

## 1. Executive Summary & Vision Statement

This specification defines the **Universal Staging, Extension, and Auto-Reconciliation Engine** for Ambaji Sarees ERP.

By decoupling change requests into an immutable **Staging & Audit Table (`stage_sb_<module>`)**, enriching records via an **Extension Table (`ext_sb_<module>`)**, and executing hands-free auto-reconciliation upon Airbyte mirror refreshes (`sq_<module>`), the system achieves **100% bi-directional co-existence with legacy Empire (AMAZE MSSQL)** without mutating read-only mirrors or blocking frontline sales/production workflows.

---

## 2. The Universal 4-Layer Module Architecture

Every hybrid module (Items, Organizations, Purchase Bills, Job Work) adheres strictly to this 4-layer contract:

```
                               ┌──────────────────────────────────────────────────┐
                               │  SALES / PRODUCTION USER (New Flutter ERP App)   │
                               └────────────────────────┬─────────────────────────┘
                                                        │
                                    ┌───────────────────┴───────────────────┐
                                    │ Creates New Item OR Edits Item Spec   │
                                    └───────────────────┬───────────────────┘
                                                        │
                                                        ▼
                               ┌──────────────────────────────────────────────────┐
                               │ LAYER 1: stage_sb_qual (Staging & Audit Log)    │
                               │ • Stores draft schema matching 14 sq_QUAL cols   │
                               │ • Stores change_type, old_value, new_value, user │
                               │ • sync_status: PENDING_EMPIRE_CREATION           │
                               └────────────────────────┬─────────────────────────┘
                                                        │
                                      ┌─────────────────┴─────────────────┐
                                      │ Triggers Automated Task Creation  │
                                      └─────────────────┬─────────────────┘
                                                        │
                                                        ▼
                               ┌──────────────────────────────────────────────────┐
                               │ LAYER 2: sb_tasks (Accounts Team Task Inbox)     │
                               │ • Title: "Create Item 'Vidhi-31' in Empire"     │
                               │ • Assigned Role: ACCOUNT_HEAD                    │
                               └────────────────────────┬─────────────────────────┘
                                                        │
                                      ┌─────────────────┴─────────────────┐
                                      │ Account Head Enters Record in     │
                                      │ Empire (AMAZE MSSQL)              │
                                      └─────────────────┬─────────────────┘
                                                        │
                                                        ▼
                               ┌──────────────────────────────────────────────────┐
                               │ Airbyte Sync Engine Refreshes sq_QUAL            │
                               │ (Generates official itemsrno: "01017")           │
                               └────────────────────────┬─────────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────────┐
│ LAYER 3: AUTO-RECONCILIATION ENGINE (Postgres Trigger / Edge Function)                           │
│ 1. Matches sq_QUAL.NAME = stage_sb_qual.item_name                                                │
│ 2. Updates stage_sb_qual.sync_status = 'RECONCILED'                                               │
│ 3. Updates ext_sb_qual.itemsrno from DRAFT_TEMP_<UUID> to official "01017"                         │
│ 4. Marks sb_tasks entry as COMPLETED with notification to Accounts Head                           │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────────┐
│ LAYER 4: sbvw_item_master (Unified Calculated View for Flutter App Services)                      │
│ • Seamlessly joins sq_QUAL + ext_sb_qual (or stage_sb_qual if draft pending)                     │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Dynamic Foreign Key Binding Mechanics (`ext_sb_qual`)

To ensure that frontline users can attach media, target costs, and master design definitions to a **Draft Item** before it exists in Empire:

### A. Pending Draft State:
- `ext_sb_qual.itemsrno` = `'DRAFT_TEMP_a8f9c1'` (pointing to `stage_sb_qual.id`).
- `ext_sb_qual.sync_status` = `'PENDING_EMPIRE_CREATION'`.
- Frontline users can create designs (`VIDHI-MAIN`), upload catalog photos, and set target prices immediately!

### B. Auto-Switched Reconciled State:
- When Airbyte syncs `sq_QUAL` with `itemsrno = '01017'`, the Reconciliation Engine executes an atomic update:
  ```sql
  UPDATE "IMMBE2627"."ext_sb_qual"
  SET itemsrno = '01017',
      sync_status = 'SYNCED',
      updated_at = NOW()
  WHERE itemsrno = 'DRAFT_TEMP_a8f9c1';
  ```
- **Zero Broken Links**: All child designs, media arrays, and sales funnel quotes automatically pivot to point to official Empire `itemsrno = '01017'`.

---

## 4. Complete Database DDL Specifications

### A. Universal Staging & Audit Table: `IMMBE2627.stage_sb_qual`

```sql
CREATE TABLE IF NOT EXISTS "IMMBE2627"."stage_sb_qual" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "temp_draft_id" TEXT NOT NULL UNIQUE,          -- DRAFT_TEMP_<UUID>
    "itemsrno" VARCHAR(10),                        -- Official Empire itemsrno once reconciled
    "qcode" TEXT,                                  -- Item code string (e.g. VIDHI)
    
    -- Proposed 14 Legacy Columns Schema Payload
    "item_name" TEXT NOT NULL,                     -- Commercial Catalog Name (sq_QUAL.NAME)
    "category" TEXT,                               -- Brand Collection (SAREES, 2025, etc.)
    "cloth_type" TEXT,                             -- Product Category (SAREE, FINAL, DRESS)
    "sell_price" NUMERIC(10,2) DEFAULT 0.00,       -- Proposed Wholesale Selling Price (SELL1)
    "gst_rate" NUMERIC(5,2) DEFAULT 5.00,          -- Proposed GST % (GSTRATE)
    "hsn_code" TEXT DEFAULT '5407',                -- Proposed HSN Code
    "cut_meters" NUMERIC(5,2) DEFAULT 6.00,        -- Standard Finished Cut (CUT)
    "uom" TEXT DEFAULT 'PCS',                      -- Billing UOM (UNIT)
    "packing_type" TEXT DEFAULT 'CHAINBAG',        -- Packaging Spec (PACKING)
    "pcs_per_set" INTEGER DEFAULT 6,               -- Set Quantity (PCS_PER_SET)
    "is_base_qual" TEXT DEFAULT 'N',               -- Base Fabric Flag (ISBASEQUAL)
    "base_qual_link" TEXT,                         -- Parent Grey Fabric (BASEQUAL)
    
    -- Audit & Change Tracking
    "change_type" TEXT NOT NULL DEFAULT 'NEW_ITEM',-- NEW_ITEM, PRICE_REVISION, NAME_RENAME, SPEC_UPDATE
    "old_values" JSONB DEFAULT '{}'::jsonb,        -- Snapshot of values before change
    "new_values" JSONB DEFAULT '{}'::jsonb,        -- Snapshot of proposed new values
    "request_reason" TEXT,                         -- Reason note from user
    "sync_status" TEXT NOT NULL DEFAULT 'PENDING_EMPIRE_CREATION',
    -- PENDING_EMPIRE_CREATION, RECONCILED, REJECTED, DISCREPANCY
    
    -- Audit Metadata
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "created_by" UUID,
    "updated_by" UUID
);

CREATE INDEX IF NOT EXISTS "idx_stage_qual_temp" ON "IMMBE2627"."stage_sb_qual" ("temp_draft_id");
CREATE INDEX IF NOT EXISTS "idx_stage_qual_sync" ON "IMMBE2627"."stage_sb_qual" ("sync_status");
```

---

### B. Native Extension Table: `IMMBE2627.ext_sb_qual`

```sql
CREATE TABLE IF NOT EXISTS "IMMBE2627"."ext_sb_qual" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "itemsrno" VARCHAR(50) NOT NULL UNIQUE,        -- DRAFT_TEMP_<UUID> initially, updated to "01017" upon sync
    "qcode" TEXT,
    
    -- Enhanced Financial & Margin Specs
    "target_selling_price" NUMERIC(10,2) DEFAULT 0.00,
    "last_landed_cost_per_pc" NUMERIC(10,2) DEFAULT 0.00,
    "target_margin_pct" NUMERIC(5,2) DEFAULT 0.00,
    
    -- Reorder & Design Links
    "reorder_threshold_pcs" INTEGER DEFAULT 100,
    "master_design_code" TEXT,                     -- Links to default master design (VIDHI-MAIN)
    
    -- Universal Media & Catalog Assets
    "media_urls" JSONB DEFAULT '[]'::jsonb,
    "pdf_paths" JSONB DEFAULT '[]'::jsonb,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS "idx_ext_qual_itemsrno" ON "IMMBE2627"."ext_sb_qual" ("itemsrno");
```

---

### C. Unified Calculated View: `IMMBE2627.sbvw_item_master`

```sql
CREATE OR REPLACE VIEW "IMMBE2627"."sbvw_item_master" AS
-- 1. Reconciled Empire Items (sq_QUAL + ext_sb_qual)
SELECT 
    q.itemsrno,
    q.qcode,
    q."NAME" AS item_name,
    q.category,
    q."CLOTHTYPE" AS cloth_type,
    q."SELL1" AS legacy_selling_price,
    q."GSTRATE" AS gst_rate,
    q."HSN_CODE" AS hsn_code,
    q."CUT" AS default_cut_meters,
    q."UNIT" AS uom,
    q."PACKING" AS packing_type,
    q."PCS_PER_SET" AS default_pcs_per_set,
    q."ISBASEQUAL" AS is_base_qual,
    q."BASEQUAL" AS base_qual_link,
    
    COALESCE(e.id, gen_random_uuid()) AS ext_id,
    COALESCE(e.target_selling_price, q."SELL1", 0.00) AS target_selling_price,
    COALESCE(e.last_landed_cost_per_pc, 0.00) AS last_landed_cost_per_pc,
    COALESCE(e.target_margin_pct, 0.00) AS target_margin_pct,
    COALESCE(e.reorder_threshold_pcs, 100) AS reorder_threshold_pcs,
    COALESCE(e.master_design_code, (q.qcode || '-MAIN')) AS master_design_code,
    'SYNCED' AS sync_status,
    COALESCE(e.media_urls, '[]'::jsonb) AS media_urls,
    COALESCE(e.pdf_paths, '[]'::jsonb) AS pdf_paths,
    COALESCE(e.is_active, true) AS is_active,
    false AS is_draft

FROM "IMMBE2627"."sq_QUAL" q
LEFT JOIN "IMMBE2627"."ext_sb_qual" e ON q.itemsrno = e.itemsrno

UNION ALL

-- 2. Pending Draft Staged Items (stage_sb_qual + ext_sb_qual)
SELECT 
    s.temp_draft_id AS itemsrno,
    COALESCE(s.qcode, 'PENDING') AS qcode,
    s.item_name,
    s.category,
    s.cloth_type,
    s.sell_price AS legacy_selling_price,
    s.gst_rate,
    s.hsn_code,
    s.cut_meters AS default_cut_meters,
    s.uom,
    s.packing_type,
    s.pcs_per_set AS default_pcs_per_set,
    s.is_base_qual,
    s.base_qual_link,
    
    COALESCE(e.id, gen_random_uuid()) AS ext_id,
    COALESCE(e.target_selling_price, s.sell_price, 0.00) AS target_selling_price,
    COALESCE(e.last_landed_cost_per_pc, 0.00) AS last_landed_cost_per_pc,
    COALESCE(e.target_margin_pct, 0.00) AS target_margin_pct,
    COALESCE(e.reorder_threshold_pcs, 100) AS reorder_threshold_pcs,
    COALESCE(e.master_design_code, 'PENDING-MAIN') AS master_design_code,
    s.sync_status,
    COALESCE(e.media_urls, '[]'::jsonb) AS media_urls,
    COALESCE(e.pdf_paths, '[]'::jsonb) AS pdf_paths,
    COALESCE(e.is_active, true) AS is_active,
    true AS is_draft

FROM "IMMBE2627"."stage_sb_qual" s
LEFT JOIN "IMMBE2627"."ext_sb_qual" e ON s.temp_draft_id = e.itemsrno
WHERE s.sync_status = 'PENDING_EMPIRE_CREATION';
```

---

## 5. Widespread Blueprint Across All Modules

This architecture scales across every domain in the ERP:

| Domain | Legacy Airbyte Mirror (`sq_`) | Staging & Audit Table (`stage_sb_`) | Native Extension Table (`ext_sb_`) | Reconciled Master View (`sbvw_`) |
| :--- | :--- | :--- | :--- | :--- |
| **Items Master** | `sq_QUAL` | `stage_sb_qual` | `ext_sb_qual` | `sbvw_item_master` |
| **Organizations** | `sq_MASTER` | `stage_sb_org` | `ext_sb_org` | `sbvw_org_master` |
| **Purchase Bills / POs** | `sq_BILLS` / `sq_BILLDET` | `stage_sb_pos` | `ext_sb_pos` | `sbvw_po_master` |
| **Production / Cuttings** | `sq_MILLREC` / `sq_CHALTRN` | `stage_sb_cutting` | `ext_sb_cutting` | `sbvw_cutting_master` |
