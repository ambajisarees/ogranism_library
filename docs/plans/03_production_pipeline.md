# Plan 03: Production Pipeline — Complete Module Architecture

> **Status**: 🟡 Draft — Questions embedded for discussion  
> **Priority**: Critical (defines entire app structure for next 1-2 weeks)  
> **Scope**: Full production lifecycle from Grey Purchase → Finished Stock  
> **Created**: 2026-07-17

---

## 1. Current State Inventory

### What Exists Today

| Route | Screen | Files | Data Source | Capabilities |
|-------|--------|-------|-------------|-------------|
| 1 | Parties Master | `parties_screen.dart` | `vwsq_MASTER` | Read registry, search, pagination |
| 2 | Items / Quality | `items_screen.dart` | `vwsq_qual` | 3-tab barrel (Sales/Grey/Others) |
| 5 | Grey Production | `grey_screen.dart` + `grey_deal_dialog.dart` | `sq_BILLS(P1)`, `sq_PINVTRN`, `vwsq_milldispatch_pend`, `sb_vw_pur_ord_summary` | 4-tab: Grey Purchase / Mill Dispatch / Mill Inward / Grey Deals + Deal creation |
| 6 | Cutting Cards | `cutting/cutting_screen.dart` + 4 widgets | `sb_cutdet`, `sb_cutdet_summary`, `sq_MILLREC` | Full CRUD, batch create/edit, realtime sync, timeline, KPIs, media attach |
| 7 | Job Work | `job_work_screen.dart` | `sq_BILLS(O5/O6)`, `sq_BILLDET` | 2-tab: Dispatches / Receives, detail lines, media attach |
| 10 | Media Library | `media/media_screen.dart` | `sb_media`, Supabase Storage | Upload, browse, bulk link, smart rename |

### What's Missing (Your User Flow Mapped)

| # | User Flow Step | Current State | Action Type | Priority |
|---|---------------|---------------|-------------|----------|
| 1 | Grey Deal Entry | ✅ Done (`grey_deal_dialog.dart`) | New App Entry | — |
| 2 | Grey Purchase Registry | ✅ Done (Grey Screen Tab 1) | SQL Fetch | — |
| 3 | Grey Deal Balance Report + Linking | 🔲 Missing | Report View | Week 1 |
| 4 | Mill Dispatch Registry | ✅ Done (Grey Screen Tab 2) | SQL Fetch | — |
| 5 | Mill Program Photo Capture | 🔲 Missing | New App Entry + Media | Week 1 |
| 6 | Mill Programs Report (pending, stock low) | 🔲 Missing | Report View | Week 1 |
| 7 | Pending Stock at Mills Report | 🔲 Missing | Report View | Week 1 |
| 8 | Mill Receive Registry | ✅ Done (Grey Screen Tab 3) | SQL Fetch | — |
| 9 | Cutting Batch Creation | ✅ Done | New App Entry | — |
| 10 | Media Upload + Linking (Cutting Cards) | ✅ Done | Media | — |
| 11 | Uncut Stock Report (Reconciliation) | 🔲 Missing | Report View | Week 1 |
| 12 | Job Dispatch (O5) Registry | ✅ Done (Job Work Tab 1) | SQL Fetch | — |
| 13 | Smart Job Dispatch ↔ Cutting Card Linking | 🟡 Partial (service exists) | Linking | Week 1 |
| 14 | Saree Images + Job Card Media Upload | 🟡 Partial (media attach exists) | Media | Week 1 |
| 15 | Additional Info Capture (O5 dispatches) | 🔲 Missing | New App Supplement | Week 1 |
| 16 | Historical Mill Rate Master | 🔲 Missing (Plan 02 drafted) | New App Entry | Week 1 |
| 17 | Historical Grey Rate Analysis | 🔲 Missing | Report View | Week 2 |
| 18 | Recipe Creation Module | 🔲 Missing (Plan 02 partial) | New App Entry | Week 2 |
| 19 | P&L per Job + Time Analysis | 🔲 Missing | Report View | Week 2 |
| 20 | Purchase Orders (Finish/Lace/Photo) | 🔲 Missing | SQL Fetch OR New App | Week 2 |
| 21 | Job Receive (O6) Registry | ✅ Done (Job Work Tab 2) | SQL Fetch | — |
| 22 | Additional Info Capture (O6 receives) | 🔲 Missing | New App Supplement | Week 1 |
| 23 | Smart Map O6 → Job Card | 🟡 Partial (service exists) | Linking | Week 1 |
| 24 | Pending Job Cards Report | 🔲 Missing | Report View | Week 1 |
| 25 | Convert Job Receive → Stock (O45) | 🔲 Missing | New App Entry | Week 2 |
| 26 | Finish/Lace/Photo Purchase Bills | 🔲 Missing | SQL Fetch | Week 2 |
| 27 | PO ↔ Bill Reconciliation | 🔲 Missing | Linking | Week 2 |
| 28 | Bill Media Capture + Reconciliation | 🔲 Missing | Media | Week 2 |
| 29 | Jobwork Bills & Challans (P26-P29) | 🔲 Missing | SQL Fetch | Week 2 |
| 30 | Bill ↔ Job No Reconciliation | 🔲 Missing | Linking | Week 2 |
| 31 | Job Work Bills/Challans Report | 🔲 Missing | Report View | Week 2 |

---

## 2. Activity Classification

Your user flow breaks down into **5 distinct activity types**. This classification determines how each feature is built:

### Type A: SQL Fetch Registries
**What**: Read-only data fetched from Airbyte-synced `sq_*` tables.  
**Pattern**: Standard `SystemAppMasterLayout` + service query + model  
**Already have**: Grey Purchase (P1), Mill Dispatch, Mill Inward (J1), Job Dispatch (O5), Job Receive (O6)  
**Still need**: Purchase Bills (P2/p11/P6), Jobwork Bills (P26-P29), Purchase Orders (O13/O14)

### Type B: New App Entries (Supabase-native)
**What**: Brand-new data created in the app, stored in `sb_*` tables.  
**Pattern**: Edge Function for writes, `sb_*` tables, form overlays  
**Already have**: Cutting Batch creation, Grey Deal creation  
**Still need**: Mill Program recording, Recipe creation, Stock Conversion (O45), possibly staging Purchase Orders

### Type C: Report Views
**What**: Aggregated views answering specific business questions.  
**Pattern**: Dashboard-style with KPI strips, charts, filtered tables  
**Already have**: None as dedicated reports  
**Still need**: Grey Deal Balances, Mill Programs Pending, Pending Mill Stock, Uncut Stock Reconciliation, Pending Job Cards, Grey Rate Analysis, P&L per Job, Jobwork Bills Summary

### Type D: Linking & Reconciliation
**What**: Connecting records across different stages (O5 → Cutting Card, Bill → PO, O6 → Job Card).  
**Pattern**: Smart matching UI (autocomplete suggestions, bulk link), stored in `sb_*` mapping tables or updated columns  
**Already have**: Media → Entity linking, O5 → Cutting Card (service-level)  
**Still need**: Grey Deal → Purchase linking, O5 → Cutting Card UI, PO → Bill reconciliation, Bill → Job No reconciliation

### Type E: Supplementary Data Capture
**What**: Additional metadata attached to SQL-fetched records (notes, extra fields, photos) stored in Supabase.  
**Pattern**: `sb_supplements` overlay table that extends `sq_*` records without modifying them  
**Already have**: Media attachments on O5/O6  
**Still need**: Structured supplementary data fields on O5 dispatches, O6 receives

---

## 3. Confirmed App Navigation Structure

### Sidebar Hierarchy (keep current indexing for now, restructure later)

```
SIDEBAR
├── ── MASTERS ──
├── 1.  Parties                      [✅ shipped]
├── 2.  Items & Quality              [✅ shipped]
├── ── PRODUCTION ──                 ← 6 pages, the core of this plan
├── ●   Dashboard                    [🔲 new — route TBD]
├── ●   Pipeline                     [🔄 refactor from grey/cutting/jobwork]
├── ●   Recipes                      [🔲 new — Plan 02]
├── ●   Bills                        [🔲 new]
├── ●   Media                        [✅ shipped — extend]
├── ●   Reports                      [🔲 new]
├── ── ADMIN ──
├── ●   System Sync                  [✅ shipped]
├── ●   Design System Library        [✅ shipped]
```

> [!NOTE]
> Route index reassignment deferred to later. For now, new pages get the next available indices.

---

## 4. The 6 Production Pages — Deep Architecture

---

### PAGE 1: DASHBOARD
> **Route**: Next available index  
> **UX Pattern**: `KPI_DASHBOARD` + `STATUS_PIPELINE`  
> **Priority**: Week 2+ (needs data from other pages first)

**Purpose**: High-level data summary and actionable task queue for users. The "morning briefing" screen.

#### Layout

```
┌──────────────────────────────────────────────────────────────┐
│  PRODUCTION DASHBOARD                                        │
│                                                              │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌──────────────┐ │
│  │ At Mill   │ │ Cut Today │ │ Pending   │ │ Bills Due    │ │
│  │ 2,450 mts │ │ 340 pcs   │ │ 87 jobs   │ │ ₹4.2L       │ │
│  │ 34 mills  │ │ 6 batches │ │ 12 cards  │ │ 18 pending   │ │
│  └───────────┘ └───────────┘ └───────────┘ └──────────────┘ │
│                                                              │
│  ── PIPELINE OVERVIEW ─────────────────────────────────────  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ AT MILL  │→│  UNCUT   │→│ AT TAILOR│→│ STOCKED  │       │
│  │  34 lots │ │  12 lots │ │  87 jobs │ │  240 pcs │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                              │
│  ── TASKS ─────────────────────────────────────────────────  │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ ⚠ 14 unlinked media files awaiting sorting           │    │
│  │ ⚠ 3 job dispatches without cutting card links        │    │
│  │ ⚠ 2 mill receives pending cutting batch creation     │    │
│  │ ● 8 bills awaiting media attachment                   │    │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

#### Data Sources
- KPI tiles: aggregated from `vw_mill_pending_stock`, `sb_cutdet_summary`, `sq_BILLS(O5/O6)`, `sq_BILLS(P26-P29)`
- Pipeline overview: composite counts per stage
- Task queue: query unlinked/unsorted records across `sb_media`, `sb_job_supplements`, etc.

#### Files
| File | Type | Notes |
|------|------|-------|
| `screens/production/dashboard_screen.dart` | New Screen | Single scrollable page, no list-detail split |
| `service_dashboard.dart` (or extend existing) | Service | Aggregation RPCs |

> [!NOTE]
> **Q12 — Dashboard scope**: Is the Dashboard purely read-only metrics + clickable task links? Or does it need inline actions (e.g., "Link now" button that navigates to the relevant screen)?

---

### PAGE 2: PIPELINE
> **Route**: Consolidates current routes 5 (Grey), 6 (Cutting), 7 (Job Work)  
> **UX Pattern**: `TABBED_REGISTRY` — each tab is a `REGISTRY`, `REGISTRY+FORM`, or `SMART_LINKER`  
> **Priority**: Week 1 (critical path)

**Purpose**: All creation, supplementary data capture, and stage-tracking activities. This is where goods move through the production chain.

#### Tab Structure

```
┌────────────────────────────────────────────────────────────────────────────┐
│  PRODUCTION PIPELINE                                              [Search]│
│  [Deals] [Programs] [Cutting] [Job Work ▾] [Inward] [Orders ▾]          │
│                                                                          │
│  Where [Job Work ▾] expands to:                                          │
│    ● Stitching (O5/O6)   ← primary                                      │
│    ○ Embroidery (O9/O10) ← nested secondary                             │
│    ○ Diamond (O7/O8)     ← nested secondary                             │
│    ○ Charak (O11/O12)    ← nested secondary                             │
│                                                                          │
│  Where [Orders ▾] expands to:                                            │
│    ● Finish Orders (O13)                                                 │
│    ○ Lace Orders (O14)                                                   │
│    ○ Photo Orders (O15)                                                  │
└────────────────────────────────────────────────────────────────────────────┘
```

#### Tabs Detail

| Tab | Name | UX Pattern | Data Source | Activity | Status |
|-----|------|-----------|-------------|----------|--------|
| 1 | **Deals** | `REGISTRY+FORM` | `sb_vw_pur_ord_summary` | Create grey deals, view checker inputs | ✅ Done (move from grey_screen) |
| 2 | **Programs** | `REGISTRY+FORM` | `sb_mill_programs` (new) | Record mill visits, attach photos, track design/shade | 🔲 New |
| 3 | **Cutting** | `REGISTRY+FORM` | `sb_cutdet`, `sb_cutdet_summary` | Create batches, edit, timeline, KPIs, media | ✅ Done (move from cutting/) |
| 4 | **Job Work** | `REGISTRY` + `SUPPLEMENT_PANEL` | `sq_BILLS(O5/O6)`, `sq_BILLDET` | View dispatches/receives, add supplements, link to cutting | ✅ Partial (move from job_work_screen) |
| 4a | — Stitching | ↑ Primary | `TYPE IN ('O5','O6')` | ↑ | ✅ Done |
| 4b | — Embroidery | ↑ Secondary | `TYPE IN ('O9','O10')` | ↑ | 🔲 New (same pattern) |
| 4c | — Diamond | ↑ Secondary | `TYPE IN ('O7','O8')` | ↑ | 🔲 New (same pattern) |
| 4d | — Charak | ↑ Secondary | `TYPE IN ('O11','O12')` | ↑ | 🔲 New (same pattern) |
| 5 | **Inward** | `REGISTRY` | `sq_BILLS(J1)`, `sq_MILLREC` | Mill receive registry, grey purchase registry | ✅ Done (move from grey_screen tabs) |
| 6 | **Orders** | `REGISTRY` or `REGISTRY+FORM` | `sq_BILLS(O13/O14/O15)` or `sb_purchase_orders` | View/create purchase orders | 🔲 New |
| 6a | — Finish (O13) | ↑ | ↑ | ↑ | 🔲 |
| 6b | — Lace (O14) | ↑ | ↑ | ↑ | 🔲 |
| 6c | — Photo (O15) | ↑ | ↑ | ↑ | 🔲 |

> [!IMPORTANT]
> **Q13 — Pipeline consolidation**: This page merges 3 existing screens (`grey_screen.dart`, `cutting/cutting_screen.dart`, `job_work_screen.dart`) under one tabbed shell. Two approaches:
>
> **Approach A — New composite screen**: Create a new `pipeline_screen.dart` that imports existing screens as tab bodies. Each old screen becomes a "tab widget" rather than a standalone screen. The old route entries in `home.dart` redirect to the Pipeline page with the right tab active.
>
> **Approach B — Keep existing screens, unified navigation**: Don't merge the files. Instead, the sidebar "Pipeline" entry opens a tab-selector that navigates to the existing separate screens. Simpler refactor but less cohesive UX.
>
> Approach A is cleaner long-term. Which do you prefer?

> [!NOTE]
> **Q14 — Job Work dropdown vs. sub-tabs**: For the secondary job types (Embroidery, Diamond, Charak), should the "Job Work" tab have a dropdown menu to switch between them, or should they appear as sub-pills below the main tab bar? Sub-pills example:
> ```
> [Deals] [Programs] [Cutting] [● Job Work] [Inward] [Orders]
>                               [Stitch] [EMB] [Diamond] [Charak]
> ```

> [!WARNING]
> **Q15 — Orders tab staging (revisiting Q8)**: For the Orders tab, you mentioned "between option B and refined option C". Let me propose a **refined Option C**:
>
> 1. During job work stage, user creates a "PO Intent" in app — just: type (Finish/Lace/Photo), linked job card, estimated quantity, target vendor, notes
> 2. PO Intents stored in `sb_po_intents` table (lightweight, ~5 fields)
> 3. When real PO appears via Airbyte sync, the system suggests matching intent → real PO
> 4. Matched intents are archived, unmatched intents stay visible as "pending creation in Empire"
>
> This is much simpler than full staging (no Edge Function needed, no reconciliation/deletion of staging records) but gives visibility. Does this work?

#### Files Needed

| File | Type | Status |
|------|------|--------|
| `screens/production/pipeline_screen.dart` | New shell | 🔲 Creates the tab container |
| `screens/production/cutting/` (5 files) | Existing | ✅ Move as-is, becomes tab body |
| `screens/production/grey_screen.dart` | Refactor | 🔄 Split: Deals/Programs tabs → Pipeline, Purchase/Inward → Bills or Pipeline |
| `screens/production/grey_deal_dialog.dart` | Existing | ✅ Stays linked to Deals tab |
| `screens/production/job_work_screen.dart` | Refactor | 🔄 Becomes Job Work tab body, add supplement panel |
| `screens/production/programs_tab.dart` | New | 🔲 Mill programs REGISTRY+FORM |
| `screens/production/orders_tab.dart` | New | 🔲 Purchase orders registry |
| `models/model_program.dart` | New | 🔲 Mill program model |
| `models/model_purchase_order.dart` | New | 🔲 PO + PO Intent models |
| `services/service_pipeline.dart` | New or extend | 🔲 Programs + Orders service methods |

---

### PAGE 3: RECIPES
> **Route**: Next available index  
> **UX Pattern**: `TABBED_REGISTRY` — Tab 1 is `REGISTRY` + `INLINE_EDIT_TABLE`  
> **Priority**: Week 1 Day 1 (Plan 02 ready to execute)

**Purpose**: Central repository for all rate-related things. Mill job rates, stitching rates, value addition catalogs.

#### Tab Structure

```
[● Mill Job Rates] [Stitching Rates] [Value Additions] [Finish Purchase]
```

| Tab | Name | UX Pattern | Status | Priority |
|-----|------|-----------|--------|----------|
| 1 | Mill Job Rates | `REGISTRY` (mill list) + `INLINE_EDIT_TABLE` (rate card) | 🔲 Plan 02 | Week 1 |
| 2 | Stitching Rates | Same pattern (tailor list + rates) | 🔲 | Week 2 |
| 3 | Value Additions | Catalog view — `REGISTRY` (type list) + `INLINE_EDIT_TABLE` (vendor rates) | 🔲 | Week 2 |
| 4 | Finish Purchase Rates | `KPI_DASHBOARD` (rate trends) + `INLINE_EDIT_TABLE` | 🔲 | Week 2+ |

#### Files
Defined in Plan 02: `model_recipe.dart`, `service_recipe.dart`, `recipes_screen.dart` + SQL migrations.

---

### PAGE 4: BILLS
> **Route**: Next available index  
> **UX Pattern**: `TABBED_REGISTRY` — each tab is a `REGISTRY` (list of bills + detail with line items)  
> **Priority**: Week 2

**Purpose**: All billing registries — both material purchases and job work processing bills. All SQL-fetched, read-only data with media attachment and reconciliation overlays.

#### Tab Structure

```
[Grey Purchase] [Mill Inward] [Finish] [Lace] [Photo] [Stitch Bills] [Diamond Bills] [EMB Bills] [Charak Bills]
```

Grouped logically:

```
── MATERIAL ──           ── JOBWORK ──
Grey Purchase (P1)       Stitching Bills (P26)
Mill Inward (J1)         Diamond Bills (P27)
Finish Purchase (P2)     Embroidery Bills (P28)
Lace Purchase (p11)      Charak Bills (P29)
Photo Materials (P6)
```

| Tab | Name | Source | UX Pattern | Status |
|-----|------|--------|-----------|--------|
| 1 | Grey Purchase (P1) | `sq_BILLS(P1)` + `sq_PINVTRN` | `REGISTRY` | ✅ Exists in grey_screen (move) |
| 2 | Mill Inward (J1) | `sq_BILLS(J1)` + `sq_MILLREC` | `REGISTRY` | ✅ Exists in grey_screen (move) |
| 3 | Finish Purchase (P2) | `sq_BILLS(P2)` + `sq_BILLDET` | `REGISTRY` | 🔲 New |
| 4 | Lace Purchase (p11) | `sq_BILLS(p11)` + `sq_BILLDET` | `REGISTRY` | 🔲 New |
| 5 | Photo Materials (P6) | `sq_BILLS(P6)` + `sq_BILLDET` | `REGISTRY` | 🔲 New |
| 6 | Stitching Bills (P26) | `sq_BILLS(P26)` + `sq_BILLDET` | `REGISTRY` + `RECONCILIATION` | 🔲 New |
| 7 | Diamond Bills (P27) | `sq_BILLS(P27)` + `sq_BILLDET` | `REGISTRY` + `RECONCILIATION` | 🔲 New |
| 8 | EMB Bills (P28) | `sq_BILLS(P28)` + `sq_BILLDET` | `REGISTRY` + `RECONCILIATION` | 🔲 New |
| 9 | Charak Bills (P29) | `sq_BILLS(P29)` + `sq_BILLDET` | `REGISTRY` + `RECONCILIATION` | 🔲 New |

> [!NOTE]
> **Q16 — Bills generic model**: Since all 9 bill types share the same `sq_BILLS` + `sq_BILLDET` schema, we can build ONE generic `BillRegistryTab` widget parameterized by `TYPE` string. Each tab passes its TYPE code and gets the same list-detail layout with type-specific column visibility. This means:
> - 1 model file (`model_bill.dart`) with `BillHeaderModel` + `BillDetailModel`
> - 1 service file (`service_bills.dart`) with `getBills(type)` + `getBillDetails(cno, vno, type)`
> - 1 generic tab widget (`bill_registry_tab.dart`)
> - The screen file (`bills_screen.dart`) just wraps 9 instances of this tab
>
> Agree with this approach?

> [!NOTE]
> **Q17 — Bill detail enrichment**: For jobwork bills (P26-P29), the detail canvas should show which Job Card the bill is linked to (via `orderno`/`ORDTYPE`). Should the Reconciliation pattern show a "Link to Job" action for unreconciled bills, or is that linkage already reliable from SQL data?

#### Files Needed

| File | Type | Notes |
|------|------|-------|
| `screens/billing/bills_screen.dart` | New screen | Tab shell for all 9 bill types |
| `screens/billing/bill_registry_tab.dart` | New widget | Generic reusable bill tab (parameterized by TYPE) |
| `models/model_bill.dart` | New | `BillHeaderModel`, `BillDetailModel` — generic for all types |
| `services/service_bills.dart` | New | `getBills(type, ...)`, `getBillDetails(cno, vno, type)`, media linking |

---

### PAGE 5: MEDIA
> **Route**: 10 (current)  
> **UX Pattern**: `BULK_ACTION_GRID` + `SMART_LINKER`  
> **Status**: ✅ Shipped — extend with new tools tabs

**Purpose**: Central upload, linking, and media management hub.

#### Current Capabilities (Done)
- Three-pane explorer (bucket tree, thumbnail grid, detail panel)
- Drag & drop bulk upload with progress
- Smart Linker (auto-suggest entity, auto-rename, auto-relocate)
- Client-side image compression + thumbnail generation
- Inline attachment in Cutting Cards and Job Work

#### Future Tabs

```
[● Library] [Upload Station] [Link Tools] [QC Review]
```

| Tab | Name | UX Pattern | Purpose | Priority |
|-----|------|-----------|---------|----------|
| 1 | Library | `BULK_ACTION_GRID` | Current media explorer | ✅ Done |
| 2 | Upload Station | `BULK_ACTION_GRID` | Dedicated bulk upload with category pre-selection | 🟡 Extend |
| 3 | Link Tools | `SMART_LINKER` | Smart linking dashboard for unsorted media | 🟡 Extend |
| 4 | QC Review | `COMPARISON_CARD` | Side-by-side photo review for quality control | 🔲 V2+ |

> [!NOTE]
> **Q18 — Media tabs vs. single view**: Current Media Library is a single view with all features. Should we add tabs (Upload Station, Link Tools) or keep it as one unified view? The current single view already has upload + linking inline.

#### Files
Existing: `media_screen.dart`, `model_media.dart`, `model_media_suggestion.dart`, `service_media.dart`

---

### PAGE 6: REPORTS
> **Route**: Next available index  
> **UX Pattern**: `TABBED_REGISTRY` → each tab is `KPI_DASHBOARD`  
> **Priority**: Week 2

**Purpose**: Centralized reporting hub. Each tab is a focused dashboard answering one business question.

#### Tab Structure

```
[Deal Balances] [Mill Stock] [Uncut Stock] [Job Cards] [Rate Analysis] [Job P&L] [Bills Summary]
```

| Tab | Name | UX Pattern | Business Question | Data Source |
|-----|------|-----------|-------------------|-------------|
| 1 | Deal Balances | `KPI_DASHBOARD` | How much grey per deal is remaining? | `sb_vw_pur_ord_summary` + `sq_BILLDET(P1)` |
| 2 | Mill Stock | `KPI_DASHBOARD` | What fabric is at which mill? | `sq_CHALTRN` - `sq_MILLREC` aggregate |
| 3 | Uncut Stock | `KPI_DASHBOARD` | What received fabric hasn't been cut? | `sq_MILLREC` - `sb_cutdet` aggregate |
| 4 | Pending Job Cards | `KPI_DASHBOARD` | What's at tailors/processors (partial receive logic)? | `sq_BILLDET(O5)` - partial `sq_BILLDET(O6)` |
| 5 | Rate Analysis | `KPI_DASHBOARD` | Grey price trends by quality/weaver | `sq_PINVTRN` + `sq_BILLS(P1)` |
| 6 | Job P&L | `COMPARISON_CARD` + `KPI_DASHBOARD` | Total cost & margin per job | Composite across all tables |
| 7 | Bills Summary | `KPI_DASHBOARD` | Outstanding payments to processors | `sq_BILLS(P26-P29)` aggregate |

#### Layout Pattern (same for every report tab)

```
┌────────────────────────────────────────────────────────────────┐
│  REPORT: Mill Pending Stock                  [Date Range ▾]    │
│                                                                │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌──────────────┐   │
│  │ 2,450 mts │ │ 34 mills  │ │ 12.3%     │ │ 7 overdue    │   │
│  │ Total Pend│ │ Active    │ │ Avg Shrink│ │ > 30 days    │   │
│  └───────────┘ └───────────┘ └───────────┘ └──────────────┘   │
│                                                                │
│  [All Mills ▾] [All Qualities ▾] [Status ▾]     [Export CSV]   │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ Mill         │ Quality │ Sent    │ Rec    │ Pending │ Days ││
│  │ SHREE BALAJI │ DANI    │ 450 mts │ 380 mts│ 70 mts  │ 12  ││
│  │ JAY AMBE     │ GEOR    │ 320 mts │ 320 mts│ 0       │ —   ││
│  │ ...          │         │         │        │         │     ││
│  └────────────────────────────────────────────────────────────┘│
│  [Pagination: 1 2 3 ... 5]                                    │
└────────────────────────────────────────────────────────────────┘
```

#### Files Needed

| File | Type | Notes |
|------|------|-------|
| `screens/reports/reports_screen.dart` | New screen | Tab shell with 7 report tabs |
| `screens/reports/report_tab.dart` | New widget | Generic report layout (KPI strip + filter bar + data table) |
| `models/model_report.dart` | New | `KpiMetric`, `ReportRow` — generic structures |
| `services/service_reports.dart` | New | One method per report, each calling an RPC or view |

> [!NOTE]
> **Q19 — Report interactivity**: Should clicking a row in a report table navigate to the entity in its home page (e.g., clicking a mill row in "Mill Stock" opens that mill in the Pipeline > Inward tab)? This cross-page navigation would be very useful but requires a global navigation controller.

> [!NOTE]
> **Q20 — Export**: Should reports support CSV/Excel export from Day 1? Flutter has `csv` package for CSV generation and `file_saver` for download. Easy to add if needed.

---

## 5. Consolidated File Inventory

### New Files

| # | File | Page | Type |
|---|------|------|------|
| 1 | `screens/production/pipeline_screen.dart` | Pipeline | Tab shell |
| 2 | `screens/production/programs_tab.dart` | Pipeline | REGISTRY+FORM tab |
| 3 | `screens/production/orders_tab.dart` | Pipeline | REGISTRY tab |
| 4 | `screens/production/recipes_screen.dart` | Recipes | Tab shell + rate card |
| 5 | `screens/production/dashboard_screen.dart` | Dashboard | KPI page |
| 6 | `screens/billing/bills_screen.dart` | Bills | Tab shell |
| 7 | `screens/billing/bill_registry_tab.dart` | Bills | Generic tab widget |
| 8 | `screens/reports/reports_screen.dart` | Reports | Tab shell |
| 9 | `screens/reports/report_tab.dart` | Reports | Generic report layout |
| 10 | `models/model_recipe.dart` | Recipes | Rate models |
| 11 | `models/model_bill.dart` | Bills | Generic bill models |
| 12 | `models/model_program.dart` | Pipeline | Mill program model |
| 13 | `models/model_purchase_order.dart` | Pipeline | PO + intent models |
| 14 | `models/model_report.dart` | Reports | KPI/report row models |
| 15 | `services/service_recipe.dart` | Recipes | Rate CRUD |
| 16 | `services/service_bills.dart` | Bills | Generic bill queries |
| 17 | `services/service_reports.dart` | Reports | Aggregation RPCs |

### Modified Files

| # | File | Change |
|---|------|--------|
| 1 | `screens/home.dart` | Add new routes, restructure switch |
| 2 | `screens/production/grey_screen.dart` | Refactor — Deals tab → Pipeline, Purchase/Inward → Bills |
| 3 | `screens/production/job_work_screen.dart` | Add supplement panel, secondary process tabs |
| 4 | `services/service_grey.dart` | Add programs methods, report queries |
| 5 | `services/service_jobwork.dart` | Add secondary processes, supplements |
| 6 | `models/model_jobwork.dart` | Add supplement model, secondary process models |
| 7 | `models/model_grey.dart` | Add program model if not separate |

### Database Objects

| # | Object | Type | Page |
|---|--------|------|------|
| 1 | `sb_mill_rates` | Table | Recipes |
| 2 | `sb_rate_history` | Table | Recipes |
| 3 | `sb_job_types` | Table + Seed | Recipes |
| 4 | `sb_mill_programs` | Table | Pipeline |
| 5 | `sb_job_supplements` | Table | Pipeline |
| 6 | `sb_po_intents` | Table | Pipeline |
| 7 | `vw_mill_volume_ranking` | View | Recipes |
| 8 | `vw_mill_pending_stock` | View | Reports |
| 9 | `vw_uncut_stock` | View | Reports |
| 10 | `vw_pending_job_cards` | View | Reports |
| 11 | `upsert_mill_rate` | RPC | Recipes |
| 12 | `save_mill_program` | RPC | Pipeline |

---

## 6. Execution Phases (Refined)

### Week 1: Core Pipeline + Recipes

| Day | Focus | Deliverables |
|-----|-------|-------------|
| **Day 1** | Recipes Tab 1 | `recipes_screen.dart`, `model_recipe.dart`, `service_recipe.dart`, SQL (3 tables + view + RPC) |
| **Day 2** | Bills Page (Generic) | `bills_screen.dart`, `bill_registry_tab.dart`, `model_bill.dart`, `service_bills.dart` — all 9 types working |
| **Day 3** | Pipeline Shell + Job Work Expansion | `pipeline_screen.dart` consolidating existing screens, add O7/O8/O9/O10/O11/O12 to job work |
| **Day 4** | Supplement System + Smart Linking | `sb_job_supplements` table, supplement panel on O5/O6, O5 ↔ Cutting Card smart linker |
| **Day 5** | Orders Tab + Media Polish | Orders tab (O13/O14/O15) or PO Intent system, media inline improvements |

### Week 2: Reports + Dashboard + Advanced

| Day | Focus | Deliverables |
|-----|-------|-------------|
| **Day 6** | Reports Page (3 report tabs) | `reports_screen.dart`, `report_tab.dart`, Mill Stock + Uncut Stock + Pending Jobs |
| **Day 7** | Reports Page (remaining) | Deal Balances, Rate Analysis, Bills Summary, Job P&L |
| **Day 8** | Dashboard Page | `dashboard_screen.dart` — KPIs, pipeline overview, task queue |
| **Day 9** | Recipes Expansion | Stitching rates tab, Value Addition catalog |
| **Day 10** | Polish + Navigation Restructure | Sidebar reindexing, command palette updates, cross-page navigation |

---

## 7. Supplementary Data Architecture

### `sb_job_supplements` — App metadata overlay on SQL records

```sql
CREATE TABLE "IMMBE2627".sb_job_supplements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Links to sq_BILLS record
    bill_vno INT NOT NULL,
    bill_type TEXT NOT NULL,
    bill_cno INT NOT NULL DEFAULT 4,
    
    -- Supplementary fields
    expected_return_date DATE,
    priority TEXT CHECK (priority IN ('low', 'normal', 'high', 'urgent')) DEFAULT 'normal',
    special_instructions TEXT,
    assigned_worker TEXT,
    custom_notes TEXT,
    tags TEXT[] DEFAULT '{}',
    
    -- Linking
    linked_cutting_batch TEXT,   -- CC code reference
    linked_job_card TEXT,        -- For secondary processes
    
    -- Audit
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(bill_vno, bill_type, bill_cno)
);
```

### `sb_po_intents` — Lightweight PO intent tracking

```sql
CREATE TABLE "IMMBE2627".sb_po_intents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Intent details
    po_type TEXT NOT NULL CHECK (po_type IN ('finish', 'lace', 'photo')),
    linked_job_vno INT,            -- Which job card triggered this
    linked_job_type TEXT,
    target_vendor_code TEXT,        -- From sq_MASTER
    target_vendor_name TEXT,
    estimated_quantity INT,
    estimated_rate NUMERIC(10,2),
    notes TEXT,
    
    -- Resolution
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'created_in_empire', 'matched', 'cancelled')),
    matched_po_vno INT,            -- Once Empire PO syncs and is matched
    matched_po_type TEXT,
    matched_at TIMESTAMPTZ,
    
    -- Audit
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```
---

## 8. Resolved Architectural Decisions


> [!NOTE]
> **Q12 — Dashboard scope**: Replaced open question. Dashboard holds high-level data summary and task feeds for actionable user alerts/links.
>
> **Q13 — Pipeline consolidation**: Replaced open question. Consolidated Pipeline page (Approach A) will contain Deals, Programs, Cutting, Job Work, Inward, and Orders in one tabbed view.
>
> **Q14 — Job Work Hierarchy**: Replaced open question. Stitching (O5/O6) is the primary process; Embroidery, Diamond, and Charak are nested as secondary sub-pills or sub-tabs.
>
> **Q15 — Orders Staging**: Replaced open question. Staging is resolved using a combination of Option B (Supabase PO tables) and refined Option C (hybrid PO intent system matching real POs when synced).
>
> **Q16 — Bills generic model**: Replaced open question. Reusable `BillRegistryTab` widget parameterized by `TYPE` handles all 9 material and jobwork bill categories.
>
> **Q17 — Bill reconciliation**: Replaced open question. Reconciliations for P26-P29 bills will use matching job number anchors.
>
> **Q18 — Media tabs**: Replaced open question. Media Screen will contain Library, Upload Station, and Link Tools tabs.
>
> **Q19 — Report cross-navigation**: Replaced open question. Centralized reports will support navigation clicking.
>
> **Q20 — CSV Export**: Replaced open question. CSV Export will be supported from Day 1 on all Report tabs.

---

## 9. Execution Priority

```
CRITICAL PATH (Week 1):
  Recipes (Plan 02) → Bills Generic → Pipeline Consolidation → Supplements → Orders

PARALLEL TRACK (Week 2):
  Reports Hub → Dashboard → Recipes Expansion → Nav Restructure

DEFERRED (V2.5+):
  Custom per-job cash discounting
  Recipe composite P&L calculator
  Stock conversion (O45 → SAREEDES)

DEFERRED (V3):
  Packing material orders/bills/stock
  Customer-facing media catalog
```

## 10. ERP UX Pattern Catalog

Every screen in the app should use one of these proven patterns. Each maps to specific Organism components.

---

### Pattern 1: `REGISTRY` — Master-Detail Split Pane ★ Most Common

**When**: Browsing a list of records and viewing one at a time.  
**Layout**: Left list pane (340px) + Right detail canvas  
**Organism**: `SystemAppMasterLayout` → `OrganPaneHeader` + `OrganPaneList` + `OrganSectionCanvas`  
**Already used in**: Parties, Items, Cutting Cards, Job Work, Media

```
┌─────────────┬────────────────────────────────────────┐
│  LIST PANE  │         DETAIL CANVAS                  │
│             │                                        │
│  ┌────────┐ │  Title + Action Buttons                │
│  │ Item 1 │ │  ┌──────────────────────────────────┐  │
│  ├────────┤ │  │ TissueCard: Summary Metrics      │  │
│  │▶Item 2 │ │  ├──────────────────────────────────┤  │
│  ├────────┤ │  │ TissueCard: Detail Table / Lines  │  │
│  │ Item 3 │ │  ├──────────────────────────────────┤  │
│  └────────┘ │  │ TissueCard: History / Timeline    │  │
│  [Page 1/5] │  └──────────────────────────────────┘  │
└─────────────┴────────────────────────────────────────┘
```

**Best for**: Grey Purchase, Mill Dispatch, Mill Receive, O5/O6 registries, Purchase Bills, Jobwork Bills

---

### Pattern 2: `REGISTRY+FORM` — Split Pane with Create/Edit Overlay

**When**: Pattern 1 + user can create/edit records.  
**Layout**: Same as Registry, but with a full-screen overlay form triggered by `[+ New]` button.  
**Organism**: `SystemAppMasterLayout` + `OrganAddCanvas` (or custom `Stack`/`Positioned` overlay)  
**Already used in**: Cutting Cards (form overlay), Grey Deals (dialog)

```
┌──────────────────────────────────────────────────────┐
│  ░░░░░░░░░░ GLASSMORPHIC OVERLAY ░░░░░░░░░░░░░░░░░  │
│  ┌──────────────────────────────────────────────────┐│
│  │ FORM TITLE                        [Cancel] [Save]││
│  │ ┌──────────┐  ┌──────────────────────────────┐   ││
│  │ │ Sidebar  │  │ Form Fields / Steps          │   ││
│  │ │ Steps or │  │ TissueFormField inputs        │   ││
│  │ │ Selection│  │ CellAutocomplete dropdowns    │   ││
│  │ │          │  │ CellInputNumber amounts       │   ││
│  │ └──────────┘  └──────────────────────────────┘   ││
│  └──────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

**Best for**: Cutting Batch creation, Grey Deal creation, Mill Program entry, Recipe creation, Stock conversion (O45)

---

### Pattern 3: `INLINE_EDIT_TABLE` — Editable Data Grid

**When**: User needs to view and edit multiple values in a dense table format.  
**Layout**: Table rows with click-to-edit cells. Changes save inline (no overlay).  
**Organism**: Custom `Table`/`DataTable` with `CellInputNumber` per cell, wrapped in `TissueCard`  
**Already planned for**: Print Recipes (mill rate card)

```
┌──────────────────────────────────────────────────────┐
│  TABLE HEADER                                        │
│  ┌──────────┬───────────┬────────┬──────┬──────────┐ │
│  │ Job Type │ Rate (₹)  │ Unit   │ Δ%   │ Changed  │ │
│  ├──────────┼───────────┼────────┼──────┼──────────┤ │
│  │ Screen   │ [₹18.50]  │ /meter │ ↑5%  │ 12 Jul   │ │
│  │ Digital  │ [₹32.00]  │ /meter │  —   │ 01 Jul   │ │
│  │ Dyeing   │ [₹12.00]  │ /meter │ ↓3%  │ 15 Jun   │ │
│  ├──────────┼───────────┼────────┼──────┼──────────┤ │
│  │ [+ Add Rate]                                    │ │
│  └─────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

**Best for**: Mill rate cards, Stitching rate cards, Value addition catalogs, any "rate matrix" view

---

### Pattern 4: `KPI_DASHBOARD` — Metric Cards + Filtered Table

**When**: Answering a business question with aggregate numbers at top and drill-down table below.  
**Layout**: KPI strip (4-6 metric cards) → Filter bar → Scrollable data table  
**Organism**: Row of `TissueCard` (KPI tiles) + `CellFilterChip` bar + `DataTable` or `ListView`

```
┌──────────────────────────────────────────────────────┐
│  REPORT TITLE                         [Date Range ▾] │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │ ₹12.4L   │ │ 847 pcs  │ │ 34 mills │ │ 12% ↑   │ │
│  │ Tot.Value │ │ Pending  │ │ Active   │ │ Shrink  │ │
│  └──────────┘ └──────────┘ └──────────┘ └─────────┘ │
│                                                      │
│  [All ▾] [Quality ▾] [Mill ▾]           [Export CSV]  │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Mill         │ Quality │ Sent    │ Rec   │ Pend  │ │
│  │ SHREE BALAJI │ DANI    │ 450 mts │ 380   │ 70    │ │
│  │ JAY AMBE     │ GEOR    │ 320 mts │ 320   │  0    │ │
│  └──────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

**Best for**: Mill Pending Stock, Uncut Stock Reconciliation, Grey Deal Balances, Pending Job Cards, Grey Rate Analysis, Job P&L

---

### Pattern 5: `RECONCILIATION` — Side-by-Side Matcher

**When**: Matching records across two systems or two stages (PO → Bill, O5 → Cutting Card).  
**Layout**: Left source list + Right target list + Match action in between  
**Organism**: Custom dual-pane with drag-and-drop or click-to-link mechanics

```
┌────────────────────┬───┬─────────────────────────────┐
│  UNMATCHED SOURCE  │   │  MATCHED / TARGET           │
│                    │   │                             │
│  ┌──────────────┐  │   │  ┌──────────────┐           │
│  │ O5 Dispatch  │──│ → │──│ CC Batch #84 │ ✅ Linked │
│  │ VNO: 25      │  │   │  └──────────────┘           │
│  └──────────────┘  │   │                             │
│  ┌──────────────┐  │   │  ┌──────────────┐           │
│  │ O5 Dispatch  │  │   │  │ [Suggest]    │           │
│  │ VNO: 26      │  │   │  └──────────────┘           │
│  └──────────────┘  │   │                             │
│                    │   │                             │
│  3 unmatched       │   │  1 matched                  │
└────────────────────┴───┴─────────────────────────────┘
```

**Best for**: O5 ↔ Cutting Card linking, PO ↔ Bill matching, Bill ↔ Job No reconciliation, Media smart linker (already exists)

---

### Pattern 6: `TIMELINE` — Chronological Event Stream

**When**: Showing the lifecycle of a single entity across processing stages.  
**Layout**: Vertical timeline with stage markers, dates, status dots  
**Organism**: Custom timeline widget with `CellStatusDot` + `CellBadge` markers  
**Already used in**: Cutting Card detail canvas

```
┌──────────────────────────────────────────────────────┐
│  BATCH #84 TIMELINE                                  │
│                                                      │
│  ● Grey Purchase (P1)    12 Apr 2026  ✅ Received    │
│  │                                                   │
│  ● Mill Dispatch          15 Apr 2026  ✅ Sent       │
│  │                                                   │
│  ● Mill Receive (J1)     22 Apr 2026  ✅ Returned    │
│  │                                                   │
│  ● Cutting (O3)          25 Apr 2026  ✅ Cut         │
│  │                                                   │
│  ● Stitch Dispatch (O5)  28 Apr 2026  🔵 At Tailor  │
│  │                                                   │
│  ○ Stitch Receive (O6)   — pending —  ⚪ Awaiting   │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Best for**: Cutting Card detail, Job Card lifecycle view, CARDNO traceability, Order tracking

---

### Pattern 7: `SUPPLEMENT_PANEL` — Metadata Overlay on Fetched Records

**When**: Adding app-native data (notes, priority, dates, media) to SQL-fetched records.  
**Layout**: Part of the detail canvas — an expandable section below the fetched data.  
**Organism**: `TissueCard` with `TissueFormField` inputs inside `OrganSectionCanvas`

```
┌──────────────────────────────────────────────────────┐
│  O5 DISPATCH #25 (from SQL)                          │
│  ┌──────────────────────────────────────────────────┐│
│  │ Tailor: RAMESH TEXTILES  │ Date: 28 Apr 2026    ││
│  │ Quality: DANI            │ Pcs: 120             ││
│  │ Status: OPEN             │ Challan: CH-4521     ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  ── APP SUPPLEMENTS (editable) ──────────────────── │
│  ┌──────────────────────────────────────────────────┐│
│  │ Expected Return:  [     15 May 2026     ]       ││
│  │ Priority:         [● High] [Normal] [Low]       ││
│  │ Special Notes:    [Needs extra care - delicate]  ││
│  │ Assigned Worker:  [Ramesh Kumar             ]   ││
│  │ 📎 Attachments:   [challan_scan.jpg] [+ Add]   ││
│  └──────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

**Best for**: O5 dispatch supplements, O6 receive supplements, any SQL-fetched record needing app metadata

---

### Pattern 8: `TABBED_REGISTRY` — Tab Shell wrapping Pattern 1

**When**: Multiple related registries sharing the same domain (e.g., 4 tabs in Grey Pipeline).  
**Layout**: `TissueTabs` pill navigation at top, each tab renders a different `SystemAppMasterLayout`  
**Organism**: `TissueTabs` + state-switched body  
**Already used in**: Grey Screen, Job Work Screen, Items Screen

```
┌──────────────────────────────────────────────────────┐
│  GREY PIPELINE               [Search]                │
│  [● Deals] [Purchase] [Balances] [Dispatch] [Prog]  │
│  ┌─────────────┬────────────────────────────────────┐│
│  │  LIST PANE  │         DETAIL CANVAS              ││
│  │  (per tab)  │         (per tab)                  ││
│  │             │                                    ││
│  └─────────────┴────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

**Best for**: Grey Pipeline (7 tabs), Job Work (5-6 tabs), Purchase Bills (grouped tabs)

---

### Pattern 9: `BULK_ACTION_GRID` — Multi-Select with Floating Actions

**When**: Performing bulk operations on many items (link, archive, tag, assign).  
**Layout**: Grid or list with checkboxes + floating action bar at bottom  
**Organism**: `GridView`/`ListView` with `CellCheckbox` + floating `TissueButtonBar`  
**Already used in**: Media Library

```
┌──────────────────────────────────────────────────────┐
│  ☑ SELECT ALL                    3 of 47 selected    │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │
│  │☑ item1 │ │☐ item2 │ │☑ item3 │ │☐ item4 │        │
│  └────────┘ └────────┘ └────────┘ └────────┘        │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │
│  │☐ item5 │ │☑ item6 │ │☐ item7 │ │☐ item8 │        │
│  └────────┘ └────────┘ └────────┘ └────────┘        │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │ 3 selected  [Link to Entity] [Assign] [Archive] ││
│  └──────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

**Best for**: Media Library (done), Bulk bill reconciliation, Bulk job linking

---

### Pattern 10: `COMPARISON_CARD` — Single Entity Deep View

**When**: Deep-diving into one entity showing all related data across stages.  
**Layout**: Full-width card layout with multiple sections, no list pane  
**Organism**: Scrollable column of `TissueCard` sections

```
┌──────────────────────────────────────────────────────┐
│  JOB CARD #4521 — COMPREHENSIVE VIEW                 │
│                                                      │
│  ┌───────── HEADER ────────────────────────────────┐ │
│  │ Quality: DANI  │ Mill: SHREE BALAJI │ 120 pcs   │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌───────── COST BREAKDOWN ────────────────────────┐ │
│  │ Grey: ₹45/m  │ Mill: ₹18/m │ Stitch: ₹12/pc   │ │
│  │ Emb: ₹25/pc  │ Lace: ₹8/pc │ Total: ₹108/pc   │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌───────── TIMELINE ──────────────────────────────┐ │
│  │ ● P1 → ● Mill → ● Cut → ● O5 → ○ O6          │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌───────── MEDIA ─────────────────────────────────┐ │
│  │ [img1] [img2] [img3] [bill_scan]                │ │
│  └─────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

**Best for**: Job P&L view, Recipe composite cost view, CARDNO full traceability

---

### Pattern 11: `STATUS_PIPELINE` — Horizontal Stage Board

**When**: Visualizing items moving through sequential stages (like a Kanban).  
**Layout**: Horizontal scrolling columns, each column = a stage  
**Organism**: `SingleChildScrollView(scrollDirection: Axis.horizontal)` with column `ListView`s  
**Already used in**: Grey Production (Kanban taka grids)

```
┌──────────────────────────────────────────────────────────────┐
│  ← SCROLL →                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ AT MILL  │ │  CUT     │ │ STITCHED │ │ EMB/DIAM │        │
│  │ (34 pcs) │ │ (120 pcs)│ │ (85 pcs) │ │ (45 pcs) │        │
│  │──────────│ │──────────│ │──────────│ │──────────│        │
│  │ Batch 81 │ │ Batch 79 │ │ Batch 72 │ │ Batch 68 │        │
│  │ Batch 82 │ │ Batch 80 │ │ Batch 74 │ │          │        │
│  │ Batch 84 │ │          │ │          │ │          │        │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
└──────────────────────────────────────────────────────────────┘
```

**Best for**: Dashboard production overview, Job Card stage tracker, future "Production Control Center"

---

### Pattern 12: `SMART_LINKER` — Auto-Suggest Match Panel

**When**: System suggests likely matches between two record sets using heuristics.  
**Layout**: List of unlinked items, each with auto-suggested match + confirm/reject  
**Organism**: `ListView` with inline `CellCombobox` suggestions + `CellButton` confirm  
**Already used in**: Media Smart Linker

```
┌──────────────────────────────────────────────────────┐
│  SMART LINKER — 12 unlinked dispatches               │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │ O5 #25 (DANI, 120 pcs)                          ││
│  │ Suggested: [CC Batch #84 — DANI, 120 pcs] ✅ 98%││
│  │ ➔ Link as: Cutting Card #84     [Confirm] [Skip]││
│  ├──────────────────────────────────────────────────┤│
│  │ O5 #26 (GEORGETTE, 85 pcs)                      ││
│  │ Suggested: [CC Batch #79 — GEOR, 90 pcs]  ⚠ 72%││
│  │ ➔ Link as: [Search manually ▾]   [Confirm] [Skip]│
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [Link All Confirmed (8)] [Skip Remaining]           │
└──────────────────────────────────────────────────────┘
```

**Best for**: O5 ↔ Cutting Card, PO ↔ Bill, Bill ↔ Job No, Grey Deal ↔ Purchase

---

## 11. Activity-to-UX Pattern Mapping

Now mapping every pipeline activity to its optimal pattern:

### Grey Pipeline Activities

| # | Activity | UX Pattern | Wireframe |
|---|----------|-----------|-----------|
| 1 | Grey Deal Entry | `REGISTRY+FORM` | List of deals + dialog overlay for creation |
| 2 | Grey Purchase Registry | `REGISTRY` | List of P1 headers → detail with taka lines |
| 3 | Deal Balance Report | `KPI_DASHBOARD` | KPI strip (total ordered/received/pending) + per-deal balance table |
| 4 | Deal ↔ Purchase Linking | `SMART_LINKER` | Unlinked purchases → auto-suggest matching deal |
| 5 | Mill Dispatch Registry | `REGISTRY` | List of dispatches → detail with roll lines |
| 6 | Mill Programs Entry | `REGISTRY+FORM` | List of programs at mills + creation form (mill, quality, design, shade, photos) |
| 7 | Mill Programs Report | `KPI_DASHBOARD` | KPIs (programs pending, low-stock qualities) + filterable table |
| 8 | Mill Pending Stock | `KPI_DASHBOARD` | KPIs (total at mills, by mill) + per-mill breakdown table |
| 9 | Mill Receive Registry | `REGISTRY` | List of J1 headers → detail with received lines |

### Cutting Activities

| # | Activity | UX Pattern | Wireframe |
|---|----------|-----------|-----------|
| 10 | Cutting Batch Creation | `REGISTRY+FORM` ✅ | Done — form overlay with lot selection |
| 11 | Cutting Card Detail | `REGISTRY` + `TIMELINE` ✅ | Done — detail canvas with KPI tiles + timeline |
| 12 | Media Upload/Link | `BULK_ACTION_GRID` + `SMART_LINKER` ✅ | Done — grid upload + smart rename |
| 13 | Uncut Stock Report | `KPI_DASHBOARD` | KPIs (total uncut meters, by quality) + reconciliation table with marking controls |

### Job Work Activities

| # | Activity | UX Pattern | Wireframe |
|---|----------|-----------|-----------|
| 14 | Stitching Dispatch (O5) | `REGISTRY` + `SUPPLEMENT_PANEL` | List → detail (SQL data + editable app fields below) |
| 15 | Stitching Receive (O6) | `REGISTRY` + `SUPPLEMENT_PANEL` | Same pattern, with "mark as stocked" action |
| 16 | O5 ↔ Cutting Card Linking | `SMART_LINKER` | Auto-suggest cutting batch for each dispatch |
| 17 | Embroidery (O9/O10) | `REGISTRY` | Same list-detail pattern, filtered by TYPE |
| 18 | Diamond (O7/O8) | `REGISTRY` | Same |
| 19 | Charak (O11/O12) | `REGISTRY` | Same |
| 20 | Pending Job Cards Report | `KPI_DASHBOARD` | KPIs (total pending, by process, by contractor) + filterable table |
| 21 | Stock Conversion (O45) | `REGISTRY+FORM` | List of eligible items + form to convert to finished stock |

### Billing Activities

| # | Activity | UX Pattern | Wireframe |
|---|----------|-----------|-----------|
| 22 | Purchase Bills (P2/p11/P6) | `REGISTRY` | List of bills → detail with line items, amounts |
| 23 | Jobwork Bills (P26-P29) | `REGISTRY` + `RECONCILIATION` | List → detail, with linked job card reference + reconciliation status |
| 24 | PO ↔ Bill Matching | `RECONCILIATION` or `SMART_LINKER` | Side-by-side: unmatched POs vs unmatched Bills |
| 25 | Bill Media Capture | `SUPPLEMENT_PANEL` | Photo attachment section in bill detail view |

### Recipes & Analysis Activities

| # | Activity | UX Pattern | Wireframe |
|---|----------|-----------|-----------|
| 26 | Mill Rate Master | `REGISTRY` + `INLINE_EDIT_TABLE` | Mill list → editable rate card table |
| 27 | Grey Rate Analysis | `KPI_DASHBOARD` | KPIs (avg rate, rate trends) + quality/weaver breakdown chart |
| 28 | Recipe Creation | `REGISTRY+FORM` + `COMPARISON_CARD` | Recipe list → form to compose (select grey + mill + stitch + VA) → cost preview card |
| 29 | Job P&L Analysis | `COMPARISON_CARD` + `KPI_DASHBOARD` | Per-job cost breakdown card + aggregate P&L metrics |

---

## 12. New Organism Components Implied

Some patterns require components that don't exist yet. These should be added to `organism_design/domain/`:

| Component | Pattern | Description |
|-----------|---------|-------------|
| `DomainKpiTile` | `KPI_DASHBOARD` | Metric card with value, label, trend indicator (↑↓), sparkline |
| `DomainFilterBar` | `KPI_DASHBOARD` | Horizontal row of `CellFilterChip` + `CellCombobox` filters |
| `DomainTimeline` | `TIMELINE` | Vertical timeline with stage dots, labels, dates (extracted from cutting detail) |
| `DomainSmartLinker` | `SMART_LINKER` | Reusable suggestion-confirm row (extracted from media smart linker) |
| `DomainReconcileView` | `RECONCILIATION` | Dual-pane match interface |
| `DomainSupplementSection` | `SUPPLEMENT_PANEL` | Expandable card with form fields for app-native metadata |

> [!NOTE]
> **Q11 — Component extraction**: Should we extract the Timeline and Smart Linker from their current screens into reusable domain components before building new modules? This would make them available to all screens but adds a refactoring step.

---

**Answer the questions above and I'll refine this into individual day-by-day task plans with Gemini prompts for each.**

