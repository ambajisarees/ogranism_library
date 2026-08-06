# Deprecated Tables & Views Registry — Ambaji Sarees ERP

> **Location**: `docs/legacy/deprecated_tables_registry.md`  
> **Schema Context**: `IMMBE2627` in Supabase Postgres 17  
> **Purpose**: Archive schema definitions, column structures, and historical context for initial prototype tables/views dropped during the production architecture refactor.

---

## 1. Summary of Retired Assets

| Object Name | Type | Historical Purpose | Status | Replacement / Next-Gen Architecture |
| :--- | :--- | :--- | :---: | :--- |
| **`sb_google_auth`** | `BASE TABLE` | Stored OAuth2 access tokens for Google Contacts API sync. | **Retired** | Direct CRM integration via `exsq_master_contacts`. |
| **`sb_google_contacts`** | `BASE TABLE` | Stored raw unsanitized contacts synced from Google API. | **Retired** | Enriched CRM master `exsq_master_contacts`. |
| **`sb_order_packings`** | `BASE TABLE` | Initial prototype table for order packing assignments. | **Retired** | Next-Gen Packing Workstation (`sb_packing_queue`). |
| **`sb_sales_orders`** | `BASE TABLE` | Initial prototype header table for sales orders. | **Retired** | Next-Gen Sales Order Ledger (`sb_sales_orders`). |
| **`sb_sales_order_lines`** | `BASE TABLE` | Initial prototype line items table for sales orders. | **Retired** | Next-Gen Sales Order Lines (`sb_sales_order_lines`). |
| **`sb_vw_order_lines_summary`** | `VIEW` | Prototype view aggregating order line quantities. | **Retired** | Dynamic Flutter DAB/DyTable rollup engine. |
| **`sb_vw_pur_ord_summary`** | `VIEW` | Prototype view aggregating purchase order metrics. | **Retired** | Dynamic Flutter DAB/DyTable rollup engine. |

---

## 2. Schema Specifications & Historical Columns

### A. Google Contacts Integration (`sb_google_auth` & `sb_google_contacts`)

#### `sb_google_auth`
- **`id`** (`uuid`, Primary Key)
- **`user_id`** (`uuid`) — Link to Supabase Auth User ID
- **`access_token`** (`text`) — OAuth2 Bearer Token
- **`refresh_token`** (`text`) — OAuth2 Refresh Token
- **`expires_at`** (`timestamptz`) — Token Expiration Timestamp

#### `sb_google_contacts`
- **`id`** (`uuid`, Primary Key)
- **`resource_name`** (`text`) — Google People API Resource ID (e.g. `people/c12345`)
- **`display_name`** (`text`) — Contact Full Name
- **`phone_number`** (`text`) — Raw Phone Number
- **`email`** (`text`) — Contact Email Address
- **`synced_at`** (`timestamptz`) — Last Sync Timestamp

---

### B. Legacy Sales & Packing Prototypes (`sb_order_packings`, `sb_sales_orders`, `sb_sales_order_lines`)

#### `sb_order_packings`
- **`id`** (`uuid`, Primary Key)
- **`order_id`** (`uuid`) — Link to prototype sales order
- **`qcode`** (`varchar`) — Item Code
- **`packed_pcs`** (`integer`) — Saree pieces packed
- **`packing_type`** (`varchar`) — Packaging spec (`CHAINBAG`, `NAKED`, `POUCH`)
- **`packed_by`** (`uuid`) — User ID

#### `sb_sales_orders`
- **`id`** (`uuid`, Primary Key)
- **`order_no`** (`text`) — Sales Order Serial Number
- **`party_cno`** (`integer`) — Customer Party Code from `sq_MASTER`
- **`order_date`** (`date`) — Order Placement Date
- **`total_pcs`** (`integer`) — Total ordered saree pieces
- **`net_amount`** (`numeric`) — Total monetary value
- **`status`** (`text`) — Order Status (`PENDING`, `DISPATCHED`, `CANCELLED`)

#### `sb_sales_order_lines`
- **`id`** (`uuid`, Primary Key)
- **`order_id`** (`uuid`, Foreign Key to `sb_sales_orders`)
- **`qcode`** (`varchar`) — Item Code
- **`design_no`** (`varchar`) — Design Number
- **`pcs`** (`integer`) — Ordered quantity
- **`rate`** (`numeric`) — Agreed selling price

---

### C. Legacy Views (`sb_vw_order_lines_summary` & `sb_vw_pur_ord_summary`)

#### `sb_vw_order_lines_summary`
- Aggregated `sb_sales_order_lines` grouped by `qcode` and `design_no`, computing total ordered pcs vs packed pcs.

#### `sb_vw_pur_ord_summary`
- Aggregated `sb_pur_ord` grouped by `MILL` and `QUAL`, computing total ordered meters vs received meters.
