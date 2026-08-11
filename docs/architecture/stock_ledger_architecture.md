# Architectural Specification — Finished Saree Stock Ledger Engine

> **Domain**: Finished Saree Inventory, 2-Tier Commercial Orderability & Design Pipeline Engine  
> **Schema Context**: `IMMBE2627` in Supabase Postgres 17  
> **Table**: `sb_stock_ledger`  
> **View**: `vw_stock_summary`  

---

## 1. Core Table Schema: `IMMBE2627.sb_stock_ledger`

The central immutable audit ledger recording every finished saree inventory event.

| Column Name | Data Type | Default / Constraint | Business & Technical Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | `gen_random_uuid() PRIMARY KEY` | Internal UUID primary key |
| `idempotency_hash` | `text` | `NOT NULL UNIQUE` | Idempotency hash: `md5(ref_type + ref_vno + design_code + event_type)` |
| `design_code` | `text` | `NOT NULL` | Design SKU key (`itemqcode-design_no`, e.g., `VIDHI-101` or `VIDHI-MAIN`) |
| `itemsrno` | `varchar(10)` | `NOT NULL` | Foreign key referencing `sq_QUAL.itemsrno` |
| `event_type` | `text` | `NOT NULL` | Event type identifier |
| `event_date` | `timestamptz` | `NOW() NOT NULL` | Date/time when the event occurred |
| `qty_in` | `integer` | `0` | Physical stock received/packed on shelf |
| `qty_out` | `integer` | `0` | Physical stock leaving shelf (Dispatches + Transfers Out) |
| `qty_ordered` | `integer` | `0` | Firm Sales Order booked (10–14 day delivery window) |
| `qty_delivered` | `integer` | `0` | **Sales Order delivered/fulfilled** (Customer Dispatches ONLY; NOT Stock Transfers) |
| `qty_funnel` | `integer` | `0` | Sales Funnel pre-order booked (30–40 day advance reservation) |
| `qty_converted` | `integer` | `0` | Funnel reservation converted to Firm Sales Order |
| `qty_at_mill` | `integer` | `0` | Expected saree pieces at Mill Program weaving/dyeing (~40 days out) |
| `qty_at_job` | `integer` | `0` | Expected saree pieces in Job Work processing (~10 days out) |
| `ref_vno` | `text` | `NULL` | Voucher / document number reference |
| `ref_cno` | `bigint` | `NULL` | Company number reference |
| `ref_type` | `text` | `NULL` | Source transaction series type |
| `created_at` | `timestamptz` | `NOW()` | Record creation timestamp |
| `created_by` | `uuid` | `NULL` | User UUID who initiated event |

---

## 2. Event Types & Quantity Delta Mapping Rules

| Event Type (`event_type`) | Operational Action | Quantity Delta Rules |
| :--- | :--- | :--- |
| **`AT_MILL`** | Mill Program created | `+qty_at_mill` |
| **`PROG_CANCELLED`** | Mill Program archived/cancelled | `-qty_at_mill` |
| **`JOB_ISSUED`** | Job Card issued to job work | `+qty_at_job`, `-qty_at_mill` (Replaces mill estimate with actual cut pcs) |
| **`JOB_RECEIVED`** | Job work received/inwarded | `-qty_at_job` |
| **`PACKED`** | Sarees folded, boxed & shelved | `+qty_in` |
| **`FUNNEL_ORDER`** | Advance pre-order booked | `+qty_funnel` *(Can occur even before Mill Program is created)* |
| **`FUNNEL_CONVERTED`** | Funnel promoted to Firm Order | `+qty_converted`, `+qty_ordered` |
| **`SALES_ORDER`** | Direct Firm Sales Order booked | `+qty_ordered` |
| **`DISPATCHED`** | Sarees shipped to buyer | `+qty_out`, `+qty_delivered` |
| **`STOCK_TRANSFER`** | Re-tag stock between designs | Transferrer: `+qty_out` (qty_delivered remains 0). Transferee: `+qty_in` |
| **`SALES_RETURN`** | Customer return received & QC approved | `+qty_in`, `-qty_delivered` |

---

## 3. Real-Time View Specifications: `IMMBE2627.vw_stock_summary`

### Summary View Metrics & Formulas:

#### A. Physical Stock Metrics:
- **`stock_in`** = `COALESCE(SUM(qty_in), 0)` $\rightarrow$ Total physical sarees received/packed on shelf.
- **`stock_out`** = `COALESCE(SUM(qty_out), 0)` $\rightarrow$ Total physical sarees leaving shelf (Dispatches + Transfers Out).
- **`current_stock`** = $\mathbf{stock\_in - stock\_out}$ $\rightarrow$ **Physical On-Hand Stock sitting on shelf right now.**

#### B. Pipeline Production Stocks:
- **`stock_at_mill`** = `COALESCE(SUM(qty_at_mill), 0)` $\rightarrow$ Expected saree pieces at Mill Program (~40 days out).
- **`stock_at_job`** = `COALESCE(SUM(qty_at_job), 0)` $\rightarrow$ Expected saree pieces in Job Work (~10 days out).

#### C. Sales Funnel Metrics (30–40 Day Advance Horizon):
- **`fl_booked`** = `COALESCE(SUM(qty_funnel), 0)` $\rightarrow$ Total cumulative sales funnel pre-orders taken.
- **`fl_converted`** = `COALESCE(SUM(qty_converted), 0)` $\rightarrow$ Total cumulative funnel pre-orders converted to firm orders.
- **`fl_pending`** = $\mathbf{fl\_booked - fl\_converted}$ $\rightarrow$ **Active unconverted Sales Funnel pre-orders.**
- **`fl_orderable`** (Sales Funnel Pre-Order Capacity):
  $$\mathbf{fl\_orderable = \max(0, so\_orderable + stock\_at\_mill - fl\_pending)}$$

#### D. Firm Sales Order Metrics (10–14 Day Near-Term Horizon):
- **`so_booked`** = `COALESCE(SUM(qty_ordered), 0)` $\rightarrow$ Total cumulative firm sales orders taken (direct + converted).
- **`so_delivered`** = `COALESCE(SUM(qty_delivered), 0)` $\rightarrow$ Total cumulative firm orders shipped to buyers.
- **`so_pending`** = $\mathbf{so\_booked - so\_delivered}$ $\rightarrow$ **Unfulfilled Firm Sales Orders waiting for dispatch.**
- **`so_orderable`** (Firm Sales Order Capacity - Near Term 10–14 Days):
  $$\mathbf{so\_orderable = \max(0, current\_stock + stock\_at\_job - so\_pending)}$$

---

## 4. Full Multi-Event Scenario Trace (`VIDHI-101` and `VIDHI-102`)

### Event Timeline:
1. **`PACKED`**: 1,000 Pcs packed for `VIDHI-101` $\rightarrow$ `qty_in = 1000`.
2. **`SALES_ORDER`**: 300 Pcs firm order booked for `VIDHI-101` $\rightarrow$ `qty_ordered = 300`.
3. **`DISPATCHED`**: 200 Pcs shipped to buyer $\rightarrow$ `qty_out = 200`, `qty_delivered = 200`.
4. **`STOCK_TRANSFER`**: 100 Pcs transferred from `VIDHI-101` to `VIDHI-102` $\rightarrow$ `VIDHI-101` emits `qty_out = 100` (`qty_delivered = 0`). `VIDHI-102` emits `qty_in = 100`.

### Summary Output for `VIDHI-101`:
- `stock_in`: **1,000 Pcs**
- `stock_out`: $200 + 100 =$ **300 Pcs**
- **`current_stock`**: $1000 - 300 =$ **700 Pcs** (Shelf inventory accurately reduced by transfer)
- `so_booked`: **300 Pcs**
- **`so_delivered`**: **200 Pcs** (Customer dispatches ONLY; stock transfer does NOT corrupt delivery count)
- **`so_pending`**: $300 - 200 =$ **100 Pcs** (Firm customer orders waiting for dispatch still exactly 100 Pcs)
- **`so_orderable`**: $700 + 0 - 100 =$ **600 Pcs** (Firm order capacity accurately updated to 600 Pcs)

### Summary Output for `VIDHI-102`:
- `stock_in`: **100 Pcs**
- `stock_out`: **0 Pcs**
- **`current_stock`**: **100 Pcs** (Shelf inventory accurately increased by transfer)
- `so_booked`: 0 Pcs, `so_delivered`: 0 Pcs, `so_pending`: 0 Pcs
- **`so_orderable`**: $100 + 0 - 0 =$ **100 Pcs**

---

## 5. Complete SQL View Definition

```sql
CREATE OR REPLACE VIEW "IMMBE2627"."vw_stock_summary" AS
SELECT 
    design_code,
    itemsrno,
    -- Physical Stock On-Hand
    COALESCE(SUM(qty_in), 0) AS stock_in,
    COALESCE(SUM(qty_out), 0) AS stock_out,
    (COALESCE(SUM(qty_in), 0) - COALESCE(SUM(qty_out), 0)) AS current_stock,
    
    -- Pipeline Production Stocks
    GREATEST(0, COALESCE(SUM(qty_at_mill), 0)) AS stock_at_mill,
    GREATEST(0, COALESCE(SUM(qty_at_job), 0)) AS stock_at_job,
    
    -- Sales Funnel Metrics (30-40 Days Horizon)
    COALESCE(SUM(qty_funnel), 0) AS fl_booked,
    COALESCE(SUM(qty_converted), 0) AS fl_converted,
    (COALESCE(SUM(qty_funnel), 0) - COALESCE(SUM(qty_converted), 0)) AS fl_pending,
    
    -- Firm Sales Order Metrics (10-14 Days Horizon)
    COALESCE(SUM(qty_ordered), 0) AS so_booked,
    COALESCE(SUM(qty_delivered), 0) AS so_delivered,
    (COALESCE(SUM(qty_ordered), 0) - COALESCE(SUM(qty_delivered), 0)) AS so_pending,
    
    -- Horizon A: Firm Sales Order Capacity (10-14 Days Max Delivery)
    GREATEST(0, 
        (COALESCE(SUM(qty_in), 0) - COALESCE(SUM(qty_out), 0))
        + GREATEST(0, COALESCE(SUM(qty_at_job), 0))
        - (COALESCE(SUM(qty_ordered), 0) - COALESCE(SUM(qty_delivered), 0))
    ) AS so_orderable,
    
    -- Horizon B: Sales Funnel Advance Pre-Order Capacity (30-40 Days Lead Time)
    GREATEST(0,
        GREATEST(0, 
            (COALESCE(SUM(qty_in), 0) - COALESCE(SUM(qty_out), 0))
            + GREATEST(0, COALESCE(SUM(qty_at_job), 0))
            - (COALESCE(SUM(qty_ordered), 0) - COALESCE(SUM(qty_delivered), 0))
        )
        + GREATEST(0, COALESCE(SUM(qty_at_mill), 0))
        - (COALESCE(SUM(qty_funnel), 0) - COALESCE(SUM(qty_converted), 0))
    ) AS fl_orderable

FROM "IMMBE2627"."sb_stock_ledger"
GROUP BY design_code, itemsrno;
```
