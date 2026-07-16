# Table: sq_CUTDET (Cutting Details)

The `sq_CUTDET` table is the primary registry for **Cutting Cards** within the Production Control Center (PCC). It tracks the transformation of Grey fabric into finished/cut pieces at the mill or processing house.

## Exact Schema (Supabase/Postgres Mirror)

| Column | Type | Default | Context | Description |
| :--- | :--- | :--- | :--- | :--- |
| `CUTCARDNO` | `bigint` | `NULL` | Identity | The unique identifier for the Cutting Card (Primary Key in business logic). |
| `reccardno` | `bigint` | `NULL` | Linking | Link to the receiving card (from Processing). |
| `CARDNO` | `bigint` | `NULL` | Linking | Reference to the Grey Inward/Taka card. |
| `PVNO` | `bigint` | `NULL` | Linking | Purchase Voucher Number. |
| `MILL` | `varchar` | `NULL` | Entity | The Mill or Processing house name. |
| `cutter_name` | `varchar` | `NULL` | Entity | Person responsible for cutting. |
| `DESIGNNO` | `varchar` | `NULL` | Production | Finished design number assigned. |
| `SHADE` | `varchar` | `NULL` | Production | Shade/Color reference. |
| `GREYQUAL` | `varchar` | `NULL` | Production | Quality of the base grey fabric. |
| `RMTS` | `numeric` | `NULL` | Metrics | Received Meters (Input). |
| `RPCS` | `bigint` | `NULL` | Metrics | Received Pieces (Input). |
| `OUTCUT` | `numeric` | `NULL` | Metrics | Primary Finished Cut (Fresh). |
| `SECONDS` | `bigint` | `NULL` | Metrics | Number of "Seconds" or B-grade pieces. |
| `FENT` | `numeric` | `NULL` | Metrics | Weight/Length of Fents (Damaged/Short bits). |
| `TOT_SAREE_WT` | `numeric` | `NULL` | Weights | Total weight of prime sarees. |
| `FENT_WT` | `numeric` | `NULL` | Weights | Total weight of fents. |
| `closed` | `varchar` | `NULL` | Status | 'Y' = Closed, 'N' or NULL = Open. |
| `CREATETIME` | `timestamp` | `NULL` | Audit | Timestamp when record was created in SQL. |
| `UPDATETIME` | `timestamp` | `NULL` | Audit | last modification timestamp. |

---

## Column Grouping by Context

### 1. Identity & Linkage
*   **Primary Keys**: `CUTCARDNO` (Primary), `reccardno` (Reference).
*   **Source Linking**: `CARDNO` (Grey Taka), `PVNO` (Purchase), `CNO` (Company Code), `VNO` (Voucher No).
*   **Multi-Track**: `MULTI_CUTCARDNO`, `MULTI_CNO`, `MULTI_VNO`.

### 2. Production & Specifications
*   **Design**: `DESIGNNO`, `SHADE`, `SCREEN`, `CATEGORY`, `GREYQUAL`.
*   **Logistics**: `GODOWN_NAME`, `GODOWN_TRANSFER` (bool).
*   **Resources**: `MILL`, `WEAVER`, `cutter_name`.

### 3. Quantitative Metrics (The "Math" Layer)
*   **Inputs**: `RMTS` (Received Mts), `RPCS` (Received Pcs).
*   **Fresh Outputs**: `OUTCUT` (Fresh Cut Length), `OUTCUT1-4` (Sub-grades).
*   **Damages/Loss**: `SECONDS` (Pcs), `FENT` (Mts), `FOLD_DIFF_MTS`, `RWASTAGE`.
*   **Audit Pcs**: `CPCS` (Cutting Pcs), `WPCS` (Weaving Pcs?), `CHALTRN_CPCS`.

### 4. Weights & Measures
*   **Finished Goods**: `TOT_SAREE_WT`, `WT_SAREES` (Count), `AVG_WT`.
*   **Waste**: `FENT_WT`.

### 5. Financials & Rate Analysis
*   **Rates**: `RATE`, `JOBRATE` (Processing Charge), `FENT_RATE`, `SECONDS_RATE`, `OUTCUT1_RATE`.
*   **Adjustments**: `GREY_DISC`, `MILL_DISC`, `ADD_OTH1-2`, `PAID` (status).

---

## Additional Tracking Requirements (Planned for `sb_` table)

To modernize the cutting card workstation, we need the following fields in the Supabase-native table:
1.  **`uuid`**: Standard Postgres UUID for front-end stability.
2.  **`app_status`**: Enums for workflow state (`DRAFT`, `AT_MILL`, `CUT_COMPLETE`, `CLOSED`).
3.  **`mill_reconciliation_status`**: Flag to mark if `sq_CUTDET` matches `sq_MILLREC`.
4.  **`attachment_urls`**: Array of URLs for physical cutting card scans or QC photos.
5.  **`qc_remarks`**: Detailed text field for quality control observations.
6.  **`last_sync_id`**: Reference to `sb_sync_log` to track which Airbyte run updated the record.

---

## Supabase Implementation Plan (Phase 2)

### Table Definition Recommendation
We should create `IMMBE2627.sb_cutting_cards` to act as the "Master" for new entries, while keeping `sq_CUTDET` as the "History/Legacy" mirror for Airbyte.

```sql
CREATE TABLE "IMMBE2627".sb_cutting_cards (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    cc_no integer UNIQUE, -- Maps to CUTCARDNO
    entry_date date DEFAULT CURRENT_DATE,
    
    -- Foreign Keys
    mill_id uuid REFERENCES "IMMBE2627".sb_masters(id), -- If we have a masters table
    grey_taka_id bigint, -- Reference to sq_CHALTRN / sq_PINVTRN
    
    -- Core Metrics
    received_mts numeric(10,2),
    fresh_pcs integer,
    seconds_pcs integer,
    fent_mts numeric(10,2),
    
    -- Status
    workflow_status text CHECK (workflow_status IN ('Pending', 'Processing', 'Cut', 'Completed')) DEFAULT 'Pending',
    is_closed boolean DEFAULT false,
    
    -- Metadata
    metadata jsonb DEFAULT '{}'::jsonb, -- Store legacy sq_ fields here if not mapped
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id)
);
```

### Offloading Strategy
1.  **Read Path**: Use a Union View `vw_all_cutting_cards` that merges `sq_CUTDET` (Read-only legacy) and `sb_cutting_cards` (New active).
2.  **Write Path**: All new entries via the Flutter UI go to `sb_cutting_cards`.
3.  **Sync-Back**: Use a Supabase Edge Function to push `sb_` records back to MSSQL (via a bridge API) to keep the legacy system in sync until full decommissioning.
