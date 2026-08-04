# Dev Log — Ambaji Sarees ERP
> **Project**: Textile ERP — Flutter (Web + Windows + macOS) + Supabase (Postgres 17)
> **Developer**: Smit · www.ambajisaree.com
> **Convention**: Newest entries at top. Each day is a self-contained section tagged with Machine Agent origin (`[Windows Workstation]` vs `[MacBook Workstation]`).

## 2026-08-04 · [MacBook Workstation] · Add Cutting Card End-to-End Batch Creation Engine, Supabase Historical Data Backfill & Database Formula Audit

Implemented the complete end-to-end **Add Cutting Card** batch creation flow in `MdlCcBatchInput`, `srv_cc.dart`, `sb_cutdet.dart`, `sb_cutdet_summary.dart`, and `scr_cc_form.dart`, joined `sq_PINVTRN` by `DESPNO` for grey rates, and executed a complete database backfill across 3,409 detail rows and 311 summary rows in Supabase (`IMMBE2627` schema).

### Add Cutting Card End-to-End Batch Creation (`mdl_cc.dart`, `srv_cc.dart`, `scr_cc_form.dart`)
- **`MdlCcBatchInput` Engine (`lib/models/production/mdl_cc.dart`)**: Engineered `MdlCcBatchInput` class for pro-rating and calculating batch summary rows (`SbCutdetSummaryModel`) and detail piece rows (`SbCutdetModel`) from selected uncut source cards and user form inputs (`cutLength`, `freshPcs`, `secondPcs`, `avgWtGrams`, `fentWtGrams`). Formula: $\text{TOTAL\_SECOND\_MTS} = \text{TOTAL\_RMTS} - (\text{TOTAL\_FRESH\_PCS} \times \text{CUT\_LENGTH}) - \text{TOTAL\_FENT\_MTS}$, and $\text{SECOND\_CUT} = \frac{\text{TOTAL\_SECOND\_MTS}}{\text{TOTAL\_SECOND\_PCS}}$.
- **Supabase Canonical Models (`sb_cutdet.dart` & `sb_cutdet_summary.dart`)**: Dropped obsolete `sb_cardpic` from detail model; added `secondCut`, `totalSecondMts`, `greyPurchaseDate`, and `stockReceivedDate` to summary model with 2-decimal rounded financial formulas. Fixed schema mismatch error (`PGRST204: Could not find 'sb_updated_by' column`) by removing `sb_updated_by` from `sb_cutdet_summary.toJson()` and adding standard system fields (`CNO: 4`, `TYPE: 'J1'`, `MULTI_CNO: 4`, `MULTI_TYPE: '03'`, `closed: 'Y'`) to `sb_cutdet.toJson()`.
- **Service Layer & `sq_PINVTRN` Join (`lib/services/production/srv_cc.dart`)**: Implemented `getNextMultiVno()` and `getNextCutCardNo()` sequence generators; implemented `getUncutCardMapsByMill(...)` joining `sq_MILLREC` with `sq_PINVTRN` by `DESPNO` (type `P1`) for weaver, dispatch date, and grey purchase rate (`RATE`); implemented `commitCuttingBatch(...)` writing 1 summary row and N detail rows into Supabase while enforcing strict read-only protection on `sq_MILLREC`.
- **Form UI Workstation (`lib/screens/production/cutting/scr_cc_form.dart`)**: Connected form inputs, live `DySummaryBar` metric tiles, and batch save button to `commitCuttingBatch(...)`.

### Supabase Postgres 17 Database Backfill (`IMMBE2627` Schema)
- Executed SQL updates across all **3,409 detail rows in `sb_cutdet`** and **311 summary rows in `sb_cutdet_summary`**:
  1. Re-calculated `TOTAL_SECOND_MTS = GREATEST(0, ROUND(TOTAL_RMTS - (TOTAL_FRESH_PCS * CUT_LENGTH) - TOTAL_FENT_MTS, 2))` for 311 summary rows.
  2. Derived `SECOND_CUT = ROUND(TOTAL_SECOND_MTS / TOTAL_SECOND_PCS, 2)` for 311 summary rows.
  3. Converted `AVG_WT` (Saree Weight) from Kg to **Grams** ($\times 1000$) across 3,409 detail rows and 311 summary rows (Range: 160g – 540g).
  4. Converted `FENT_WT` / `TOTAL_FENT_WT` from Kg to **Grams** ($\times 1000$) across 3,394 detail rows and 308 summary rows (Range: 0g – 5011g).
  5. Re-calculated `total_investment = ROUND((TOTAL_WMTS * GREY_RATE) + (TOTAL_RMTS * JOB_RATE), 2)` and `cost_per_pc` across 311 summary rows.

### Verification & Code Quality
- **`flutter analyze`**: **0 errors, 0 warnings** across the entire codebase.

---

## 2026-08-04 · [Windows Workstation] · PageHeader Title Flexible Fix, DyPageCanvas Auto Progress Loading & DyShlAdd / ScrCcForm Creation

Fixed `PageHeader` title `Flexible` flex competing bug, refactored `DyPageCanvas` with automatic top 2px `PageLoadingNotification` progress loading, refactored `DyShlAdd` to a clean body workspace shell below `PageHeader`, and created `ScrCcForm` for Cutting Cards add workflow.

### PageHeader Title Flex Fix (`lib/dynamic_ai/page/dy_page_header.dart`)
- **Spacer Flex Restored**: Removed `Flexible` wrapper around `Text(titleText)` in `PageHeader`. In a Flutter `Row`, `Flexible(flex: 1)` competed 50/50 with `Spacer()` (`Expanded(flex: 1)`), stealing half of the unallocated horizontal flex space. Removing `Flexible` allows `Spacer()` to claim 100% flex space and align trailing action buttons flush to the far right margin.

### Universal Page & Shell Loading Engine (`lib/dynamic_ai/shells/dy_page_canvas.dart`)
- **Stateful DyPageCanvas & Progress Dispatcher**: Converted `DyPageCanvas` to a `StatefulWidget` equipped with `initState()` and `didUpdateWidget()` listeners. Automatically dispatches `PageLoadingNotification(true)` to `DynamicHeaderTabs` on initial page mount, subpage index switches (`Dash` $\leftrightarrow$ `Details` $\leftrightarrow$ `Reports` $\leftrightarrow$ `Tasks`), layout mode changes (`landing` $\leftrightarrow$ `form`), or `isLoading` updates.
- **Top 2px Teal Progress Bar**: Guarantees zero-boilerplate top 2px progress bar animation across all module page loads, subpage tab switches, and Add/Edit form entries.

### Body Workspace Shell & Form Screen (`lib/dynamic_ai/shells/dy_shl_add.dart` & `lib/screens/production/cutting/scr_cc_form.dart`)
- **`DyShlAdd` Body Shell**: Refactored `DyShlAdd` to be a pure body workspace container shell sitting below `PageHeader` in `DyPageCanvas` (matching `DyShlDetails` and `DyShlDash`).
- **`ScrCcForm` Form Container Screen**: Created `ScrCcForm` rendering `DyPageCanvas(layoutMode: DyPageLayoutMode.form, header: PageHeader(mode: PageHeaderMode.adding, ...), content: const DyShlAdd())`. Wired `ScrCcLanding`'s `+ Add` button to launch `ScrCcForm` with 2px progress loading animation.

### Master Negative Coding Guidelines (`ANTIRULES.md`)
- Added **Row Flex Spacing Rule** and **Git Diff Diagnostic First** guidelines to `ANTIRULES.md`.

### Verification & Code Quality
- **`flutter analyze`**: **0 errors, 0 warnings** across the entire codebase.

---

## 2026-08-03 · [MacBook Workstation] · Cutting Cards (`cc`) Model Enhancement, Native Subpage Canvas Engine & 4-Shell Landing Refactor

Refactored `MdlCcHeader` and `MdlCcLineItem` in `mdl_cc.dart`, added native subpage content switching and 150ms `AnimatedSwitcher` cross-fade transition inside `DyPageCanvas`, refactored `ScrCcLanding` to full 4-Shell Architecture (`Dash`, `Details`, `Reports`, `Tasks`), and deleted legacy `scr_cc_dashboard_pane.dart` & `scr_cc_form_dialog.dart`.

### Cutting Cards Domain Model Overhaul (`lib/models/production/mdl_cc.dart`)
- **`MdlCcHeader` Domain Model**: Added un-wrapped getters for fabric metrics (`totalWmts`, `totalReceivedMeters`, `totalDmts`, `totalReceivedPcs`, `totalFreshPcs`, `totalSecondPcs`, `totalFentMts`, `totalFentWt`), yield ratios (`freshYieldPct`, `secondPct`, `fentPct`, `shortagePct`), landed financials (`greyRate`, `jobRate`, `costPerPc`, `totalInvestment`), process specifications (`jobType`, `valueType`, `cutCardNos`, `reccardNos`), and attachment checks (`cardPicPath`, `hasCardPic`, `freshYieldStatus`).
- **3-Tiered DyTable Row Mapping**: Implemented `toDyDefRowData()` and `toDyChildRowData()` transforming `MdlCcHeader` and `MdlCcLineItem` into 3-tiered table rows (`DyTableRowType.def` and `DyTableRowType.child`) for `DyTable`.

### Native Subpage Switcher Engine (`lib/dynamic_ai/shells/dy_page_canvas.dart`)
- **Native `DyPageCanvas` Subpage Engine**: Updated `DyPageCanvas` to natively support `subpageContents: List<Widget>?` and `subpageIndex: int?` with built-in 150ms `AnimatedSwitcher` + `KeyedSubtree` cross-fade transition, eliminating boilerplate across module landing screens.

### Cutting Cards 4-Shell Landing Screen (`lib/screens/production/cutting/scr_cc_landing.dart`)
- **4-Shell Architecture Integration**: Migrated `ScrCcLanding` to `DyPageCanvas` with 4 subpages: `Dash` (`DyShlDash`), `Details` (`DyShlDetails`), `Reports` (`DyShlReports`), and `Tasks` (`DyShlTasks` 4-column Kanban board).
- **DAB Context Filters & Pagination**: Integrated `CcCategory` submodule selector, search, Mill filter, Quality filter, Status filter, Date Range filter, `DyTable` 3-tiered table mapping, and `ScrCcDetailCanvas`.
- **Legacy Cleanup**: Deleted obsolete `scr_cc_dashboard_pane.dart` and `scr_cc_form_dialog.dart`.

### Verification & Code Quality
- **`flutter analyze`**: **0 errors, 0 warnings** across the entire codebase.

---

## 2026-08-02 · [Windows Workstation] · PageHeader & PageSubpages 36px Engine, DAB 8-Slot Reordering, 4-Shell Architecture & ANTIRULES.md

Refactored `PageHeader` layout, engineered `PageSubpages` segmented toggle bar with exact 36px height & 8px horizontal padding, reordered DynamicActionBar (DAB) pipeline, created 4 modular page shell layouts (`dy_shl_dash`, `dy_shl_details`, `dy_shl_reports`, `dy_shl_tasks`), integrated 150ms `AnimatedSwitcher` cross-fade transition, and authored `ANTIRULES.md`.

### PageHeader & PageSubpages Toggle Engine (`lib/dynamic_ai/page/dy_page_header.dart`)
- **`PageHeader` Refactoring**: Removed legacy `docId` badge and `PageTabs`. Updated back button to `shad.IconButton.outline(size: shad.ButtonSize.normal)`. Enforced exact row sequence: `[ Back Button ] -> [ Title ] -> [ DensityGap(gapXl) ] -> [ Subpages ] -> [ Spacer ] -> [ Trailing Action Buttons ]`.
- **`PageSubpages` Component**: Built icon + label subpage switcher button group locked to exact `36 * theme.scaling` height. Uses `shad.PrimaryButton(size: shad.ButtonSize.normal)` with primary foreground text/icon color for selected subpage item, and `MicroButton` for unselected items. Enforced `8px` horizontal inner padding token (`EdgeInsets.symmetric(horizontal: 8 * theme.scaling)`).

### DynamicActionBar (DAB) Slot Reordering (`lib/dynamic_ai/page/dy_action_bar.dart`)
- **8-Slot Pipeline**: Reordered DAB layout slots into Left scrollable pipeline (`Module Selector MB` $\rightarrow$ `Search Component` $\rightarrow$ `Action & Filter MBs`) and Pinned Right area (`View Switcher ButtonGroup` $\rightarrow$ `Trailing 3-Dots MicroButton`).

### 4-Shell Architecture Strategy (`lib/dynamic_ai/shells/`)
- **Modular Page Shells**: Created `dy_shl_dash.dart` (Dashboard Analytics & KPI cards), `dy_shl_details.dart` (Main table/list/cards view), `dy_shl_reports.dart` (Audit & pendency summary reports), and `dy_shl_tasks.dart` (4-column Kanban board pipeline).
- **150ms `AnimatedSwitcher` Cross-Fade**: Integrated 150ms `AnimatedSwitcher` cross-fade transition between subpages without lag or layout snapping in `scr_po_landing.dart` and `demo_screen.dart`.

### Master Negative Coding Guidelines (`ANTIRULES.md`)
- **`ANTIRULES.md`**: Formulated master negative coding directives covering UI container strictness, vertical height capping, native token usage, database read-only constraints, composite join rules, and zero artificial sleep latency requirements.

### Verification & Code Quality
- **`flutter analyze`**: **0 errors, 0 warnings** across the entire codebase.

---

## 2026-08-01 · [MacBook Workstation] · Master DyTable 3-Tiered Row Engine, PageHeader Full-Width Fix & Purchase Orders Landing Integration

Rebuilt the master table engine into `DyTable` with a full 3-tiered row system (`group_row`, `def_row`, `child_row`, `footer`), thumbnail lightbox modal (`DyTableGalleryModal`), fixed `PageHeader` full-width layout and `Spacer()` 100% free space allocation, updated trailing button sizing to match Cutting Cards (`shad.OutlineButton`), and integrated Purchase Orders landing screen (`scr_po_landing.dart`) with `PageTabs` content switching (`Details`, `Reports`, `Links`).

### Master 3-Tiered `DyTable` Engine (`lib/dynamic_ai/micro/table/` & `page/dy_table.dart`)
- **`DyTable` (`dy_table.dart`)**: Master table coordinator supporting full-width scrolling, sticky header/footer, standalone pagination, and dynamic compact height (`shrinkWrap`) for small result sets.
- **`DyTableHeader` (`dy_table_header.dart`)**: Sticky header with top rounded corners, exact 6px horizontal cell padding matching row text start alignment, ghost header buttons, interactive sort chevrons (`arrowUp`/`arrowDown`/`arrowUpDown`), and disabled sort styling (`isSortable: false`).
- **`DyTableGroupRow` (`dy_table_group_row.dart`)**: Tier 1 Group summary row (`group_row`). Uses exact module tab surface canvas background (`#FCFDFE` light / `#141210` dark), `w600` text, expand chevron, and full-width bottom divider.
- **`DyTableDefRow` (`dy_table_def_row.dart`)**: Tier 2 Document header row (`def_row`). Crisp white card background, fabric thumbnail lightbox trigger button (`DyTableGalleryModal`), foreground text, and full-width bottom divider.
- **`DyTableChildRow` (`dy_table_child_row.dart`)**: Tier 3 Detail line item row (`child_row`). Muted foreground typography (`colors.mutedForeground`), empty expand icon offset, and **Right-Aligned Indented Divider** stretching from table right edge to Column 1 offset.
- **`DyTableFooter` (`dy_table_footer.dart`)**: Crisp white sticky summary totals footer. Blank Col 0 & Col Last, bold `"TOTALS"` label at Column 2, and right-aligned monospace metric totals.
- **`DyTableGalleryModal` (`dy_table_gallery_modal.dart`)**: Integrated fabric design thumbnail lightbox popup modal.

### PageHeader & PageTabs Specifications (`lib/dynamic_ai/page/dy_page_header.dart`)
- **Full-Width Layout**: Wrapped `PageHeader` in `SizedBox(width: double.infinity)` constraint.
- **Spacer Flex Fix**: Removed unnecessary `Flexible` wrapper on `titleText`, allowing `Spacer()` to consume 100% of available free horizontal space and pushing `Print` & `Export` actions flush to the far right window margin.
- **Button Styling Parity**: Standardized trailing actions using `shad.OutlineButton` for `Print` and `Export` to match Cutting Cards button height and padding.
- **Embedded `PageTabs`**: Supported context tab switcher bar (`Details (Def)`, `Reports`, `Links`).

### Purchase Orders Landing Screen Integration (`lib/screens/production/purchase_orders/scr_po_landing.dart`)
- Integrated `PageHeader` (Details, Reports, Links tabs + Print/Export outline buttons), `gapLg` (24px gap token), DAB filters (Submodule, Search, Mill, Status, Date Range, Clear), and 3-tiered grouping logic.
- Implemented `PageTabs` content switching: Tab 0 (`Details`) renders complete `DyShlDetails` master shell, Tab 1 (`Reports`) & Tab 2 (`Links`) render clean placeholder content cards.

### Verification & Code Quality
- **`flutter analyze`**: 0 errors, 0 warnings across the entire codebase.

---

## 2026-08-01 · [Windows Workstation] · DyGridSystem, DyColorSystem, 4-Column Board View, dy_page_header Consolidation & Modular Table Architecture Plan

Architected the `DyGridSystem` 12-column grid and viewport flex scaling rules, authored `DyColorSystem` 6-color status & charting scale, launched `DyKanbanPane` & `DyKanbanItem` 4-column Board View in `DyShlDetails`, consolidated `dy_page_header.dart` while removing redundant tabs micro, standardized `DyPaginationRow`, and formulated the 7-component Modular ERP Table System Architecture Plan (`docs/plans/04_modular_table_system_plan.md`).

### Grid & Color System Specifications (`lib/dynamic_ai/specs/`)
- **`DyGridSystem` (`dy_grid_system.dart`)**: Formulated 12-column flex grid ratio metrics (`Standard 3-Pane` 2:7:3, `Focus Workspace` 2:8:2, `Equal 3-Column` 4:4:4, `Board 4-Pane Equal` 3:3:3:3, `List Master` fixed 360px + flex 8 inspector, `Cards Grid` flex 9 + flex 3 inspector). Defined desktop XL breakpoint at 1920px (`desktopXlBreakpoint = 1920.0`).
- **`DyColorSystem` (`dy_color_system.dart`)**: Defined master 6-color scale (`Red`, `Green`, `Yellow`, `Orange`, `Indigo`, `Fuchsia`) with 500 solid primary tokens and 100 surface container tokens. Mapped `primaryTeal` (`#14B8A6`) as Light Mode primary and `primaryAmber` (`#F59E0B`) as Dark Mode primary. Added 5-color categorical charting palette rotation.

### 4-Column Kanban Board View Engine (`lib/dynamic_ai/page/` & `micro/cards/`)
- **`DyKanbanPane` (`dy_kanban_pane.dart`)**: Built sticky column header and footer container for multi-stage board columns.
- **`DyKanbanItem` (`dy_kanban_item.dart`)**: Standardized kanban card tile with metric tags, status badges, and party details.
- **`DyShlDetails` Board Integration**: Integrated 4 equal board columns (`3:3:3:3` flex allocation totaling 12 flex units) for `Uncut`, `In Cutting`, `Mill Dispatch`, and `Completed`. Updated mock dataset with 4 active status records.

### Micro Control Consolidation & Renaming (`lib/dynamic_ai/`)
- **`dy_page_header.dart`**: Renamed `page_header.dart` to `dy_page_header.dart` for uniform `dy_` component prefix naming. Embedded `ContextTabs` logic directly inside `dy_page_header.dart` and retired redundant `dy_page_tabs.dart`. Updated imports across `scr_po_landing.dart`, `scr_pb_landing.dart`, `scr_cc_landing.dart`, and `demo_screen.dart`.
- **`DyPaginationRow` (`dy_pagination_row.dart`)**: Enforced space-dash-space formatting (`1 - 50 of 250 Records`) and `colors.foreground` text color in both normal and selected states (`Selected X • Showing 1 - 50 of 250 Records`).

### Modular ERP Table System Architecture Plan (`docs/plans/`)
- **Table Plan (`04_modular_table_system_plan.md`)**: Authored master plan to decompose `dy_table_pane.dart` (1,584 LOC) into a 7-component micro suite under `frontend/lib/dynamic_ai/micro/table/` (`dy_table_models.dart`, `dy_table_header.dart`, `dy_table_row.dart`, `dy_table_group_row.dart`, `dy_table_expand_row.dart`, `dy_table_summary_row.dart`, `dy_table_gallery_modal.dart`). Defined frozen left/right column pinning spec with 1px elevation shadows.
- **Documentation**: Updated `docs/components/dynamic_widgets.md` to reflect `dy_color_system.dart` and `dy_kanban_pane.dart` specifications.
- **Analyzer Verification**: `flutter analyze` completed in **2.7s** with **No issues found!** (0 warnings or errors).

---

## 2026-07-31 · [MacBook Workstation] · Dynamic AI Component Engine Standardization, DynamicPagination, Master Architecture Roadmap & Multi-Agent Domain SOP

Standardized `DynamicDenseTable`, `DynamicPagination`, and `MicroButton` zero-shift contracts, registered Master Orchestrator ID (`f930e306-3b6b-43c2-ac2b-ddb8915f484b`) with multi-agent domain scoping SOPs, authored master architecture & 21-component specification tracker docs, and added mandatory LLM note header blocks across dynamic AI components.

### Dynamic AI Engine & UI Standardization (`lib/dynamic_ai/`)
- **`DynamicDenseTable` (`dynamic_dense_table.dart`)**: Integrated sticky summary row (`_buildSummaryRow`) matching table header specifications 100% (surface bg, 1px border, 16px horizontal / 14px vertical padding, column-aligned totals). Enforced dynamic compact minimum height (`MainAxisSize.min`) for `<10` rows and full expanded scrolling height for `10+` rows.
- **`DynamicPagination` (`dynamic_pagination.dart`)**: Extracted standalone surface-less pagination control framing dynamic record selection count on the left and native `shad.Pagination` control (`< Prev [1] 2 3 ... Next >`) on the right.
- **`MicroButton` (`micro_button.dart`)**: Enforced Zero-Shift contract with static labels, semibold (`FontWeight.w600`) badge chip typography in all states, and single 1.0px outer card focus border (`colors.primary.withAlpha(153)`).
- **LLM Context Header Blocks**: Added mandatory LLM Context & Query Space header comment blocks to all 20+ dynamic AI UI components.

### Master Architecture Roadmap & Specification Tracker (`docs/`)
- **Master Architecture Plan (`dynamic_ai_master_architecture.md`)**: Formulated 4-tier page composition hierarchy (`PageHeader` $\rightarrow$ `ContextTabs` $\rightarrow$ `DynamicActionBar` $\rightarrow$ `DynamicContentArea`), 4-subfolder lean directory model (`root/`, `shells/`, `page/`, `micro/`), animation state machine, and phased execution roadmap.
- **21-Component Specification Tracker (`dynamic_widgets.md`)**: Created carbon-copy master specification tracker logging implementation and review progress across all 21 `dynamic_ai` component files.
- **LLM Review Presentation Protocol (`dynamic_widgets_review_guide.md`)**: Defined step-by-step markdown presentation layout for interactive LLM component reviews.

### Multi-Agent Domain Scoping SOP & Core Escalation Protocol
- **Master Orchestrator Channel**: Registered Conversation ID `f930e306-3b6b-43c2-ac2b-ddb8915f484b` as system architect and core guardian.
- **Domain Boundaries & Core Escalation**: Defined strict domain write permissions for module chat tabs (`screens/production/<module>/`, `mdl_<mns>.dart`, `srv_<mns>.dart`) and read-only policy for core models/services/dynamic_ai layers, requiring core mutation escalation requests via `send_message`. Updated `GEMINI.md` Section 10.

---

## 2026-07-30 · [Windows Workstation] · Cutting Cards & Purchase Bills MNS Overhaul, Table Source Routing, Flexible MicroButton & Legacy Cleanup

Completed full MNS architecture standardization across all three core Production sub-domains (`po`, `cc`, `pb`), implemented line-item source table routing (`sq_PINVTRN` for Grey, `sq_MILLREC` for Mill, `sq_BILLDET` for all others), resolved `MicroButton` flex overflows, and retired all 11 legacy production files.

### Cutting Cards (`cc`) MNS Standardization & DB Fix
- **Module Architecture**: Standardized Cutting Cards into `mdl_cc.dart`, `srv_cc.dart`, `scr_cc_landing.dart`, `scr_cc_detail_canvas.dart`, `scr_cc_form_dialog.dart`, and `scr_cc_dashboard_pane.dart`.
- **Database Join Fix**: Fixed eager-loading PostgREST join on `MULTI_VNO` (`.inFilter('MULTI_VNO', vnos)`), resolving Postgres 42703 column error.
- **Legacy Cleanup**: Retired and deleted original 4 legacy Cutting Card files.

### Purchase Bills (`pb`) MNS Overhaul & Table Routing
- **Table Source Routing**: Configured `srv_pb.dart` and `mdl_pb.dart` to dynamically route detail line items based on category series code (`TYPE`):
  - `Grey` (`P1`): Line items from `sq_PINVTRN` (`CNO`, `VNO`, `TYPE`)
  - `Mill` (`J1`): Line items from `sq_MILLREC` (`CNO`, `VNO`, `TYPE`)
  - All other 8 submodules (`p11` Lace, `P2` Finish, `P6` Modelling, `P26` Stitching, `P27` Diamond, `P28` Embroidery, `P29` Charak, `P4` Packing): Line items from `sq_BILLDET` (`CNO`, `VNO`, `TYPE`)
- **Landing Workstation**: Built `scr_pb_landing.dart` featuring `PageHeader` (`Purchase Bills`, `+ New Bill` button), Context Tabs (`Dashboard`, `Details`, `Tasks`), `DynamicActionBar` with 10-category `submoduleWidget` popover overlay using native Lucide icons (`package`, `factory`, `scissors`, `sparkles`, `camera`, `shirt`, `gem`, `flower`, `waves`, `box`), and `ScrPbDetailCanvas`.

### MicroButton Text Overflow Prevention
- **Flexible Truncation**: Wrapped Text label in `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))` inside `micro_button.dart` to prevent flex layout overflows when displaying longer submodule labels (e.g. `Packing Material`).

### Complete Legacy Production File Retirement
- **11 Legacy Files Removed**: Deleted legacy files for Purchase Bills (4 files + widgets folder), Mill Programs (3 files), and Printing Recipes (4 files).
- **Clean Analyzer Output**: `flutter analyze` completed with **No issues found!** (ran in 8.1s).

---

Shipped 7 canonical 1-to-1 core Supabase data models, 7 singleton table services, 3-way card linkage engine (`reccardno` ➔ `sq_MILLREC` ➔ `sq_PINVTRN`), `ReportCard` AI component, Mill Programs screen (`screen_mill_programs.dart`), Section 9 Master Architecture Strategy in `GEMINI.md`, and cleaned up legacy organism reference directories.

### 7 Canonical Core Data Models (`lib/models/core/sq/` & `sb/`)
- **Models**: Built `sq_bills.dart`, `sq_pinvtrn.dart`, `sq_millrec.dart`, `sq_chaltrn.dart`, `sq_billdet.dart`, `sb_cutdet.dart`, and `sb_cutdet_summary.dart`.
- **Defensive Factories**: Strict `fromJson` defensive parsers handling mixed Postgres types (`num`, `String`, `double`), 3-4 word domain logic header comments, and 0-count column statistics documentation.
- **3-Way Cutting Card Linkage Engine**: Connected `reccardno` in `sb_cutdet` to `sq_MILLREC` and `sq_PINVTRN` for full supply chain lot traceability.

### 7 Core Canonical Services (`lib/services/core/sq/` & `sb/`)
- **Services**: Created `sq_bills_service.dart`, `sq_pinvtrn_service.dart`, `sq_millrec_service.dart`, `sq_chaltrn_service.dart`, `sq_billdet_service.dart`, `sb_cutdet_service.dart`, and `sb_cutdet_summary_service.dart`.
- **IMMBE2627 Schema Scoping**: Enforced explicit `.schema('IMMBE2627')` scoping and terminal PostgREST `.count(CountOption.exact)` queries.

### Mill Programs Module & AI ReportCard
- **`screen_mill_programs.dart`**: Built dedicated Mill Programs workflow landing view connected to `service_programs.dart` and `model_mill_program.dart`.
- **`ReportCard` Widget** (`report_card.dart`): Created modular report card container for dynamic analytics widgets.
- **`GEMINI.md` Section 9**: Updated master developer rules with Section 9 defining Core Layer Architecture, Dynamic AI Component Engine, and `mns` abbreviation mapping (`po`, `pb`, `mp`, `mr`, `cc`, `so`).
- **Legacy Cleanup**: Removed 200+ deprecated legacy files from `organism_reference` and old service wrappers.

---

## 2026-07-29 · [Windows Workstation] · Standardized 12px / 8px / 8px Vertical Gap System, DAB 34px Height, Autocompletes & DDT Grouping Refinements

Shipped standardized vertical spacing tokens, enhanced `DynamicActionBar` (DAB) with optional Autocomplete slots and tooltipped Grouping view switcher, refined `DynamicDenseTable` (DDT) row grouping with column-aligned summary metrics, and resolved double-border artifacts.

### Standardized Master Vertical Gap System
- **PH ➔ CT (Page Header to Context Tabs / Main Canvas)**: Standardized to `const shad.DensityGap(shad.gapMd)` (`12.0px` native gap token) to provide optimal visual breathing room below page title text descenders (lower bounds like 'g', 'p', 'y').
- **CT ➔ DAB (Context Tabs to Dynamic Action Bar)**: Standardized to `const shad.DensityGap(shad.gapSm)` (`8.0px` native gap token).
- **DAB ➔ CONTENT (Dynamic Action Bar to Content View)**: Standardized to `const shad.DensityGap(shad.gapSm)` (`8.0px` native gap token).

### DynamicActionBar (DAB) 34px Height & Controls
- **View Switcher 34px Height Alignment**: Applied `density: shad.ButtonDensity.normal` directly to `shad.IconButton.outline` in `_buildViewButton`, locking View Switcher icon buttons (`table`, `list`, `grid`, `board`) to exact `34.0px` height matching `MicroButtons` and `shad.TextField`.
- **Search & Autocomplete Vertical Padding**: Fine-tuned `shad.TextField` vertical padding to `7.0 * theme.scaling` with crisp white `colors.card` surface.
- **Grouping Row & Tooltips**: Added leading `Group by:` label (`Text('Group by:', style: theme.typography.xSmall...)`) and tooltipped `shad.IconButton.outline` buttons (`None`, `Date`, `Rate`, `Design No`) with hover tooltips (`"Group by None"`, etc.).

### DynamicDenseTable (DDT) Border & Grouping Fixes
- **Footer Border**: Removed redundant `shad.Divider` before `_buildTableFooterRow` to eliminate double-thick borders above table footer.
- **Group Header Row Standardization**: Standardized height (`vertical: 10`), chevron in `24px` box, checkbox in `32px` box, single border divider, and added `Flexible` truncation to `groupTitle` preventing flex overflows.
- **Column-Aligned Group Summaries**: Mapped `_buildGroupHeaderCell` to position Group Name + count badge under Column 1 and Total Mts aggregate under Quantity column.

---

## 2026-07-28 · [MacBook Workstation] · 3-State PageHeader, Zero-Overhead PageFormCanvas, 2-Column Form Canvas & Symmetric 12px TabPane Token Padding

Shipped 3-state `PageHeader` architecture (`standard`, `adding`, `editing`), reusable zero-overhead `PageFormCanvas` with pixel-perfect 1200px max-width alignment, dedicated 2-column form layout, dynamic list/content pane skeleton loading states, and symmetric 12px (`shad.padMd` token) `HeaderTabs` child padding.

### 3-State PageHeader System (`page_header.dart`)
- **Operational Modes**: Upgraded `PageHeader` to support `PageHeaderMode.standard`, `PageHeaderMode.adding`, and `PageHeaderMode.editing`.
- **Title Formatting & Back Arrow**: Automatically prepends `←` back arrow icon button (`shad.IconButton.ghost`) in `adding`/`editing` modes and formats titles to `Add {moduleName}` (e.g. `Add Purchase Bill`) or `{docId}` (e.g. `PB-10485`).
- **Auto-Configured Action Bars**:
  - `adding`: `Discard` (Outline) + `Save Draft` (Outline) + `Confirm` (Primary).
  - `editing`: `Discard` (Outline) + `Confirm` (Primary) (*No draft state on existing records*).
- **Uniform Button Specs**: 100% uniform typography, density, and button sizing matching standard mode button specs 1:1.

### Zero-Overhead Centered PageFormCanvas (`page_form_canvas.dart`)
- **Pixel-Perfect Alignment**: Constrains both `PageHeader` and form cards (`CreatePageLayout`) inside the exact same `maxWidth` boundary (default `1200.0`).
- **Top Flush Alignment**: Uses `Align(alignment: Alignment.topCenter)` to prevent vertical centering offset, aligning the header flush to the top of the tab content area.
- **Zero Overhead**: Zero internal padding (`EdgeInsets.zero`) and zero surface tinting, sitting cleanly directly on top of the parent surface background.

### Dedicated 2-Column Form Canvas (`create_page_layout.dart`)
- **2-Column Grid**: `68%` primary form entries (supplier info, invoice no, dates, line items, remarks, file dropzone) + `32%` right status & voucher computation card stack.
- **Unbounded Height Safety**: Streamlined 2-column layout to prevent nested scrollview flex conflicts.

### Dynamic Skeletons & Cutting Card Updates
- **Skeleton Placeholders**: Added animated `isLoading` skeleton placeholders to `DynamicList` and `DynamicContentPane`.
- **Cutting Card Row Specs**: Updated row 2 to CC No (`#10481`) and row 3 to Pcs (`1,074 Pcs`). Cleaned up unused filter bar & side panel files.

### Symmetric 12px TabPane Token Padding (`header_tabs.dart`)
- **Symmetric PadMd Token**: Set `HeaderTabs` child screen padding to native `shad.padMd` token (12px) for both horizontal and vertical dimensions (`theme.density.baseContainerPadding * theme.scaling * shad.padMd`).

---

## 2026-07-27 · [Windows Workstation] · 3-Area Table Footer, Dark Mode Surface Tokens & Fabric Image Gallery Overlay

Shipped the 3-area `DynamicDenseTable` footer row, dynamic dark theme surface canvas tokens (`Stone 980` 2% tint), clickable row fabric image thumbnails with 8px gaps, and interactive image gallery overlay modal.

### 3-Area Table Footer Row
- **Area 1 (Start / Selection Counter)**: Displays dynamic record counter (`1 of 11,000 Records`) that updates reactively to `X of 11,000 Selected` upon checking row checkboxes. Uses comma-formatted number scaling for 50,000+ record datasets.
- **Area 2 (Middle / Numerical Computations)**: Computes column-aligned totals for numerical fields (`QUANTITY`: `Total: 5,050 Mtr`, `AMOUNT`: `Total: ₹10,40,000`).
- **Area 3 (End / Pagination)**: Native `shadcn_flutter` pagination controls (`<  Page 1 of 50  >`).

### Dual-Theme Surface Canvas Token Engine
- **Light Theme**: `Slate 10` (`#FCFDFE`) token sitting 0.4% above pure white (`#FFFFFF`).
- **Dark Theme**: `Stone 980` (`#141210`) token providing a clean 2% surface lift above base dark ground (`#0C0A09` / `#000000`).
- **Dynamic Resolution**: `DynamicDenseTable` and `DynamicHeaderTabs` resolve surface colors dynamically based on active theme brightness.

### Fabric Image Thumbnail & On-Click Overlay
- **Row Thumbnail**: Added a 30x30px rounded image thumbnail preceding `VNO #10481` with an exact `8px` gap.
- **Gallery Dialog Overlay**: Tapping any thumbnail triggers `_FabricImageGalleryDialog` with a main featured preview, horizontal thumbnail selector carousel, and metadata badges (`Quantity`, `Value`, `Status`).

---

## 2026-07-26 · [Windows Workstation] · Header Tabs Slate 10 Token, Sidenav Palette & Focus State Machine

Refactored the application root navigation, tab bar strip, and desktop keyboard shortcut resilience state machine.

### Header Tabs & Sidenav Palette
- **Unified Header Surface**: Set the entire top tab strip and content pane background to `Slate 10` (`#FCFDFE`).
- **Sidenav Surface System**: Base background `Slate 50` (`#F8FAFC`), item hover `Slate 100` (`#F1F5F9`), and active selection item `Slate 200` (`#E2E8F0`).

### Keyboard & Pointer Focus State Machine
- **Shortcut Resilience**: Implemented global pointer listener (`Listener(onPointerDown)`) using a one-shot `_hasActiveKeyboardSelection` state flag to prevent detaching `Alt + 1..9` workspace tab shortcuts on pointer clicks.

---

## 2026-07-25 · [MacBook & Windows Workstations] · DynamicDenseTable, Purchase Orders, Mill Printing Recipes, Google Contacts & Multi-Module SOP

Built reusable table infrastructure, launched the Component Library Showcase, and architected three major production & CRM feature branches concurrently on isolated Git worktrees.

### Reusable DynamicDenseTable Component & Header Sorting
- **Header Sorting Engine**: Built interactive sortable column headers (`isSortable == true`) with hover pill highlight containers (`colors.accent`), dynamic ascending/descending indicators, and pointer cursors.
- **Accordion Row Expansion**: Integrated accordion row expansion drawers (`_expandedIndex`). Registered in `lib/screens/demo_screen.dart`.

### Purchase Orders 5-Module Workflow (`c5eb6a6` · Branch `purorders`)
- **Domain Analysis**: Analyzed legacy voucher codes `O13` to `O16` for Grey (placeholder), Finish (`O13`), Lace (`O14`), Studio (`O15`), and Packing (`O16`).
- **Architecture**: Created models, service singletons, and package directories under `lib/screens/production/purchase_orders/` following the established `purchase_bills` design pattern.

### Mill Printing Job Work Recipes (`3d70f45` · Branch `mill-printing-recipe-module`)
- **Domain & Schema**: Audited `sq_MILLREC` (`J1` vouchers) and created `sb_recipe_mill` SQL migration schema (`backend/schema_docs/04_production/01_sb_recipe_mill.sql`).
- **UX Workstation**: Designed 2-pane split workstation featuring fabric/mill rate matrices by print type (`Overprint`, `Padding`) and value type (`Ink`, `Smoke`, `Zari`, `Foil`), date-versioned rate change histories, and toggleable display/edit content cards.

### Google Contacts Sync Engine & CRM Linker (`ea032b7` · Branch `sync-google-contacts-crm`)
- **Pipeline Architecture**: Formulated a 5-phase Google People API OAuth2 ingestion and CRM normalization pipeline with Deno Edge Function `google-contacts-sync` (`backend/supabase/functions/google-contacts-sync/index.ts`).
- **Master Party Linker**: Implemented parent-child entity relationship (One Master Org -> Many Contacts) allowing WhatsApp CRM webhooks to query contact phone numbers and auto-resolve parent Master Orgs.

### WhatsApp CRM Workstation & Navigation Reconciler (`db45d6a`, `f121c5f`)
- **100%-Width Canvas**: Implemented full-width CRM workspace with ticket headers, super_clipboard native JPEG staging, and navigation route reconciliation.

### Multi-Module Git & Chat Tracking SOP (`73af815`, `b770663`)
- **Workflow Standard**: Established mandatory SOP: `1 Module = 1 Git Feature Branch = 1 Task Plan Brief` in `docs/workflow_multi_branch_guide.md`.
- **Automation Helpers**: Created `tasks/git_checkpoint.sh` & `tasks/merge_feature.sh` for macOS, `tasks/merge_feature.ps1` for Windows, and updated `tasks/git_commit.ps1`.
- **Native System Strictness**: Updated `CLAUDE.md`, `.agents/workflows/flutter.md`, and system plan documents to remove obsolete `organism_design` references and enforce native `shadcn_flutter` rules.

---

## 2026-07-20 · [Windows Workstation] · Collapsible Accordion Sidebar, Generic Sizing Engine & Sidebar Data Density

Refactored the workstation details sidebar into an interactive collapsible accordion, established generic child layout and expansion rules, and expanded sidebar data density.

### Stateful Collapsible Accordion Sidebar
- **Interactive Stack**: Converted `DynamicSidePane` from a static column to a stateful widget managing an active expanded card index (`_expandedIndex`, defaults to 0).
- **Chevron-Controlled Header**: Added click targets on card headers with dynamic chevron indicators (down/right) to toggle expansion, removing all horizontal dividers to preserve modern aesthetic.
- **Scroll & Height Isolation**: Wraps the active card content in `Expanded` and `SingleChildScrollView` so it stretches to fill remaining height and scrolls internally, while collapsed cards shrink to their headers.
- **Lightweight View Refactoring**: Extracted raw timelines and metrics out of card shells into lightweight `TimelineView` and `MetricsView` to avoid double-scrollbar collision bugs.

### Generic Layout & Sizing Rules
- **Automatic Expansion Scaling**: Redesigned the container to accept a list of `DynamicSideCard` structures and automatically scale:
  - If 2 cards: Splits the vertical height 50/50, wrapping both in `Expanded`.
  - If 3+ cards: Wraps only the active `expandedIndex` card in `Expanded`, letting others sit at their intrinsic size.

### Expanded Sidebar Data Density
- **Telemetry Indicators**: Added three more loom metrics to `MetricsView` (Fabric Width `110cm`, Loom Efficiency `94.5%`, Warp Tension `85cN` using `LucideIcons.settings`), bringing total telemetry count to 6.
- **Actions Grid**: Expanded `Quick Actions` to display 12 action buttons using a `Wrap` grid layout for optimal desktop alignment.

### Spacing & Radius Unification
- **Standardized Border Radius**: Configured `ComponentTheme<CardTheme>` globally in `main.dart` to override card border radius to `borderRadiusMd` (`6.0px`), aligning card rounding with buttons and tabs.
- **Layout Spacing**: Unified all horizontal and vertical layout gaps to `gapSm` (`8.0px`) for consistent workspace proportions.

---

## 2026-07-19 · [Windows Workstation] · Reusable PageHeader Widget, Layout Density Refinements & Levitation Client

Implemented a reusable header layout system under the new widget library path, aligned the screen spacing strictly to theme density scales, and launched the background Levitation management client.

### Reusable PageHeader Component
- **New Widget Library**: Created directory `lib/ant_design/widgets/` to host custom reusable widgets.
- **PageHeader Implementation**: Developed `page_header.dart` which builds a title row with dynamic leading icon container, title H3, optional muted subtitle, and a right-aligned row of up to 5 action buttons (asserted programmatically).
- **Theme-Aware Sizing**: Eliminated hardcoded sizes in the header; the leading icon container scales dynamically using `theme.iconTheme.x3Large.size` (default `48px` square) and the inner icon scales using `theme.iconTheme.xLarge.size` (default `32px`).
- **White Surface Backdrop**: Centered the leading icon inside a `shad.Card` with zero padding to create a clean white surface backdrop with a border and subtle shadow.

### Layout Spacing & Density Refinements
- **Density-Compliant Padding**: Replaced absolute padding values on the Scaffold page body and action card wrapper in `demo_screen.dart` with manual runtime resolutions based on the theme's base container padding and spacing multipliers:
  - Scaffold body padding resolves to `32px` under default density (`baseContainerPadding * padLg`).
  - Action card horizontal/vertical paddings are reduced to `8px` (`baseContainerPadding * padXs`) for a sleek, compact toolbar layout.
- **Density-Compliant Gaps**: Migrated all standalone gap widgets to `DensityGap` utilizing theme spacing multiplier tokens (`gap2xl`, `gapLg`, `gapMd`, `gapSm`).

### Lucide Icon System Migration
- **Consistency Refactoring**: Replaced all occurrences of `RadixIcons` with their standard `LucideIcons` equivalents inside `demo_screen.dart` to unify the app's visual system:
  - Header leading icon: `LucideIcons.scissors` (representing cutting patterns).
  - Search bar input indicator: `LucideIcons.search`.
  - Add & Export buttons: `LucideIcons.plus` and `LucideIcons.download`.

### Levitation Client Deployment
- **Global Installation**: Installed `levitation-client` globally via npm.
- **Background Startup**: Executed `levitation-client start` to launch the background connection instance linking to `wss://server.levitation.studio:9999` (PID `51924`) for remote management.

---

## 2026-07-18 · [MacBook Workstation] · Cutting Card Total Investment Calculation Bugfix

Resolved a critical mismatch where the app showed `2.48 Lakhs` (248,492.30 INR) instead of `3.38 Lakhs` (338,480.00 INR) for cutting card batch `CC-0290` (and other batches).

### Cause & Resolution
- **Issue**: The Edge Function `create-cutting-batch` calculated total investment by joining `sq_PINVTRN p ON m.CARDNO = p.CARDNO` and multiplying grey meters by `p.RATE`. However, in the legacy system database, `p.RATE` in `sq_PINVTRN` is often unfinalized/defaulted to `1` for challan dispatches, while the finalized grey rate is stored in `m.RATE` in the `sq_MILLREC` table (e.g. `12.1` or `12.6`).
- **Fix**: Updated Deno Edge Function `create-cutting-batch` to compute total investment as `SUM((m.WMTS * m.RATE) + (m.RMTS * m.JOBRATE))` directly from `sq_MILLREC`, discarding the join on `sq_PINVTRN`. Also saved `JOBRATE` in the `sb_cutdet` detailed rows during batch creation.
- **Backfill**: Executed an SQL migration/recalculation to update all historical summary records in `sb_cutdet_summary` with correct `total_investment` and `cost_per_pc` values. Redeployed version 13 of the Edge Function to Deno Deploy.

---

## 2026-07-17 · [Windows Workstation] · Cutting Card Registry, Stitching Linker & Designs Catalog Dashboard

Shipped major UI redesigns and visual enhancements to the Cutting Cards registry, implemented the Stitching Tasks Reconciliation view, and built the new Designs SKU Catalog Dashboard. All frontend code is re-engineered to be 100% theme-compliant (Light/Dark modes) using native Organism library color tokens and widgets.

### Designs Catalog Dashboard & Media Library
- **Designs Table & RPC**: Created Supabase table `sb_designs` with columns for status constraints, media paths, opening stock balances, and a thread-safe `create_auto_design` Postgres RPC function to calculate next sequential indices per quality (e.g. `ALISHA-09`).
- **Dashboard UI Layout**: Built the Designs page using a high-density, multi-pane layout containing header action buttons, a row of 6 metrics panels using `DomainKpiTile` widgets, a search/filter bar using `CellInput`, `TissueDropdown`, and `CellCheckbox`, a 2/3 width media card grid utilizing `CellBox` containers and `CellBadge` status pills, and a 1/3 width details sidebar utilizing `TissueEmptyState` and themed media picker boxes.
- **Theme Standardization**: Cleaned up all hardcoded colors and typography getters, replacing them with dynamic semantic tokens (`colors.background`, `colors.surface`, `colors.border`, `colors.textPrimary`, `colors.textSecondary`, `colors.warning`, etc.) to resolve contrast regression issues.
- **Static Analysis Compliance**: Resolved all async BuildContext gap warnings, deprecated FormField and Switch parameters, and `.withOpacity` calls to maintain a clean static analyzer output.

### Stitching Tasks Reconciliation & Smart Linker
- **Client-Side Merging**: Created `service_tasks.dart` and `tasks_tab.dart` to reconcile Stitching dispatches with Cutting cards. Merges data in Dart to prevent Postgrest cache relational query exceptions.
- **Array Mapping**: Added `jobCardVnos` array mapper to Cutting Card model to associate many-to-many linkages once approved.

### Code Splitting & Scoped State Refactoring (Cutting)
- **Modular Directory Structure**: Created package folder structure under `lib/screens/production/cutting/` to organize the workstation.
- **ChangeNotifier Scoped Provider**: Created `widgets/cutting_form_state.dart` containing all creation/edit specs controllers, input values, selection state lists, and live mathematical calculations. Wraps overlays in a native `InheritedNotifier` to eliminate widget parameter prop-drilling.
- **Details Card Viewer**: Created `widgets/cutting_detail_canvas.dart` containing timeline progress bars, KPI tiles, and list grids.
- **specs Form Workspace**: Created `widgets/cutting_form_overlay.dart` containing the left roll selector pane, center inputs form, and right shortage progress metrics panel.
- **Group list Accordions**: Created `widgets/cutting_lot_group.dart` containing selectable taka grids grouped by rate, date, or design number.
- **Backward-Compatible Exports**: Retained a forwarding export in the legacy `screens/production/cutting_screen.dart` file to prevent system compiler breakages, and updated `home.dart` import paths.

### Database Denormalization & Function Choice Fix
- **Overloading Resolved**: Dropped overloaded versions of `get_cutting_batch_timeline` from schema `IMMBE2627` and created a single unified function accepting a `bigint` parameter to eliminate the PostgREST candidate conflict.
- **Table Extension**: Added `grey_purchase_date`, `stock_received_date`, `job_issued_date`, `job_received_date`, `total_investment`, and `cost_per_pc` to `sb_cutdet_summary` to store resolved data at creation time.
- **Historical Backfill**: Executed an update query to calculate and populate these metrics for all historical records in the database.
- **Edge Function Sync**: Updated the `create-cutting-batch` Edge Function to query and save these calculated columns during batch creation or edit transactions.

### Frontend Model & Timeline API Optimization
- Extended `CuttingBatchSummaryModel` in [model_cutting.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/models/model_cutting.dart) to parse the new denormalized database columns.
- Updated `_onCardSelected` in [cutting_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/cutting_screen.dart) to load the timeline stepper directly from the pre-loaded fields, completely eliminating the need for subsequent timeline RPC database calls on selection.

### Detail Canvas Layout & Metric Polishes
- **Matched Investment Value/Unit Format**: Split the investment KPI card into value (e.g. `2.73`) and unit (e.g. `Lakhs`), mirroring the structure of `pcs` and `mtrs` cards to solve layout overlaps.
- **Inlined Header & Footer**: Moved the header divider and footer inside the card container itself so they share the exact white background (`colors.surface`) and stretch edge-to-edge with full-width dividers.
- **All Lot Cards Displayed**: Removed the `take(8)` constraint on the sibling cards builder so that all selected rolls (e.g. all 12 cards in your screenshot) are rendered.
- **Single Saree Weight**: Adjusted the KPI block to display the weight of a **single saree in grams** (`summary.avgWt * 1000`) instead of the total saree weight of all fresh pieces in kg.

### Panelist Cards Style Alignment
- **Zero Card Margins**: Removed all vertical margins between list card rows in the left panel.
- **Divider Separation**: Enabled `showDivider: true` on each `TissueListCard` to show a clean divider line separating items.
- **Typography & Slots**:
  - Quality name rendered in **bold monospace** title slot.
  - Mill name rendered in **monospace** subtitle slot.
  - Left leading slot retains the date icon.
  - **No Trailing slot** elements to match the styling.
  - **Unified Footer Row**: Left-aligned CC-code badge and right-aligned pieces count.

---

## 2026-07-16 · Cutting Card Creation Dialog Visual Refinements & Popover Constraint Fixes

Shipped visual layout, density, and functional enhancements to the Cutting Card creation overlay:

### Dual-Row Lot Selector (Left Pane)
- **Inline Title Layout**: Replaced the compact selector layout with a structured dual-row interface:
  - Row 1: Left-aligned label `Select Quality` next to the full Quality autocomplete field.
  - Row 2: Label `Select Mill` followed by the Mill autocomplete, Search input, and a 3-icon button bar for Group By toggles (ban, calendar, palette).
- **Zero-Padding Accordions**: Set the ListView's vertical padding inside `_buildGroupedLotCards` to `EdgeInsets.zero` to remove all empty spacing.

### Compact Cards & Header Contrast
- **Overflow Fix**: Adjusted the card aspect ratio to `1.05` and set compact padding (`horizontal: 8, vertical: 6`) to eliminate bottom overflows.
- **Pane Headers Contrast**: Refined `_buildPaneHeader` and the inline lot selection header to use `colors.textPrimary` at `FontWeight.w900` for bold, highly readable headers.

### Date Picker Segment Typing & Calendar Popover
- **Visual Spacing**: Increased segment text fields' widths (`36`/`36`/`56`) and added spacing around the `/` dividers.
- **Typing Overwrite Fix**: Modified `didUpdateWidget` so text fields are not overwritten or padded while typing multi-digit dates (e.g. `15`).
- **Popover Width Constraints**: Passed `explicitWidth: 280.0` to `PlasmaPopover` to resolve the calendar `RenderFlex` width constraint propagation overflow.
- **Tap Intercept Fix**: Removed the tap-absorbing `InkWell` wrapper on the calendar icon trigger.

### Full-Width Cut Length Row
- **Unified Layout**: Shifted the Cut Length row into a vertical layout structure: a clean label `CUT LENGTH` on top, with a custom full-width `Row` of `Expanded` segments underneath.

### Trailing Field Suffixes
- **Inline Suffix Text**: Extended `CellInput` and `CellInputNumber` to support inline suffixes. Both **Saree Weight** and **Fent Weight** fields now display `grams` inside the input box.

---

## 2026-07-16 · Central Media Library Explorer, Inline Scans, Overlay Progress & Popover Fixes

Shipped the central Media Library Explorer module, Supabase Storage integration, Postgres RPC migration, inline photo scan attachment features, unified `'cutting_card'` classification, single-step Link & Auto-Rename storage logic, live progress dialog overlays, context popup unmounted crashes, and git syncing.

### Client-Side Image Compression & Thumbnails
- **App-Side Compression Pipeline**: Added the pure Dart `image` package to pre-process images locally prior to upload. Downscales images exceeding `1600px` (preserving aspect ratio) and outputs `80%` quality JPEGs (typically compressing 5MB raw files to ~250KB).
- **In-App Thumbnailing**: Dynamically generates `200px` thumbnail slices at `70%` quality and uploads them asynchronously to `/thumbnails` paths in Supabase Storage.
- **RPC Param Extension**: Redefined `"IMMBE2627".insert_media` in Postgres to take a backward-compatible `p_thumb_path DEFAULT NULL` argument, linking thumbnails to metadata records automatically.
- **Redundant View Optimizations**: Configured grid views and preview boxes to fetch `thumbPath` objects first, falling back to CDN-resized `200x200` transformations (`TransformOptions`) to save massive egress bandwidth and load screens instantly.

### Central Media Library & Explorer Screen
- **Central Media Screen**: Designed and deployed the Standalone Media Screen (`media_screen.dart`) registered as route case 10 and linked to navigation rails/boats.
- **Three-Pane Workspace**:
  - **Left Pane**: Dynamic selection tree for buckets (`sales`, `production`, `billing`, `general`) displaying reactive item counts, linkage status filters (All/Linked/Unsorted), and sorting order dropdowns.
  - **Middle Pane**: High-density responsive image thumbnail grid with selection hover checkboxes, full bulk-actions float bar (supporting bulk linking and bulk archiving), and pagination.
  - **Right Pane**: Details inspection panel displaying image previews, editable display name inputs with `CellInput` wrapper, metadata badges (file size, category, uploader name), soft delete triggers, and live autocomplete searching (across qualities, cutting batches, and dispatches) to establish entity associations.
- **Drag & Drop Upload**: Integrated drop target detectors mapping binary file reads directly to Supabase storage uploading streams.

### Supabase Storage & Postgres RPC Migration
- **Bucket Configuration**: Set up folder structures inside `ambaji-media` bucket (`sales/`, `production/cutting/`, `production/jobcard/`).
- **Postgres DDL & Triggers**: Applied `sb_media` migrations with automated table constraints, index performance optimizations, and RLS policies.
- **Transactional DB RPCs**: Deployed custom Postgres procedures (`insert_media`, `link_media_to_entity`, `archive_media`, `bulk_link_media_to_entity`, and `bulk_archive_media`) to handle all database operations transactionally from the client.
- **Overload Ambiguity Fix (PGRST203)**: Dropped the legacy 14-parameter `insert_media` overload, keeping only the 15-parameter version with `p_side DEFAULT NULL` to resolve PostgREST candidates routing conflicts.

### CC Code Migration & Unified Classification
- **Generated Columns**: Applied DB migration to add two `GENERATED ALWAYS AS` columns (`cc_no`, `cc_code`) to `sb_cutdet_summary` for zero-padded 4-digit serial formatting (e.g. `CC-0001`).
- **Unified Category**: Merged `cutting_card_front` and `cutting_card_back` into a single `'cutting_card'` category across all DB schemas and upload dialog selections.
- **Front/Back Side Detection**: Autodetects target sides (F/B) during suggestion generation based on filename suffix tags (e.g., `(2)` or `_2` mapped to back `'B'`, and clean serials to front `'F'`).

### Consolidated Link & Auto-Rename Action
- **One-Step Execution**: Removed the separate "Rename to CC Code" header button. Linking now triggers both metadata mapping and storage renaming/relocation atomically.
- **Dynamic Proposed Renames**: Displays the target filename (e.g., `➔ Rename to: CC-0001-F.jpg`) directly below the item matching dropdown inside the row UI.
- **Relocation Pathing**: Pushes the linked files directly to the `'production/cutting/$entityId/'` subdirectory in storage on connection mapping.
- **Bulk Delinking**: Ran database reset query to delink 47 legacy records from `sb_media` metadata tables so they show up under the Smart Linker dashboard for automated rename migration.

### Detailed Progress Overlay Dialogs
- **Dynamic Visual Counters**: Added glassmorphic progress overlay widgets containing linear progress bars and precise status messages (e.g. `Uploading 01.jpg`, `1 of 43 · 3% completed` or `Linking 01.jpg (1 of 43 · 3% completed)`).
- **Callback Integration**: Added progress reporting callback parameters (`onProgress`) inside `bulkLinkSuggestions` to feed current counts and renaming phases back to the UI.

### Popover Overlay & ListTile Bug Fixes
- **Material Ancestors**: Wrapped `ListTile` options across the navigation sidebar, autocomplete search dialogs, bulk linker dropdowns, and `TissueDropdown` list choices inside proper opaque `Material` widgets to satisfy Flutter ink-ripple requirements.
- **Safe Context Closes**: Swapped unmounted Navigator pops (`Navigator.of(context).pop()`) inside dropdown triggers and `_buildSortPopover` (in `cutting_screen.dart`) for key state controller closes (`_popoverKey.currentState?.close()`) to avoid unmounted context errors and black screens.

### Git Syncing
- **Commit & Remote Push**: Staged all untracked files and changes, creating commit `feat: central media library, smart linker rename automations, auth gate, and job work screens` and pushing it to remote origin master branch.

### Inline Cutting Cards Scan Attachment
- **Inline Scanner Row**: Added a dedicated `CUTTING CARD SCAN` section to the batch details pane inside `cutting_screen.dart`.
- **Two-Way Synchronization**: Attaching or removing card photo scans updates the linked `sb_media` records and automatically propagates the path back into the primary transactional tables (`sb_cutdet_summary` and `sb_cutdet`).

### Inline Job Work Challan Attachment
- **Dispatch & Receive Attachments**: Implemented inline scans display and pickers inside `job_work_screen.dart` details panel for both Stitching Dispatches (`O5`) and Stitching Receives (`O6`).
- **Details Integration**: Loads associated challan scans concurrently with fabric detail lines and provides instant attachment/detachment actions.

### Compile-Time Alignment & Syntax Refinements
- **Generic PostgREST Casting**: Refactored the `MediaService.getMedia` builder variables to use dynamic typing to allow query sorting transformations (`PostgrestTransformBuilder`) to be assigned back safely.
- **API and Syntax Fixes**: Corrected invalid padding `py:` properties, missing closing brackets on `_buildMediaAttachmentsSection`, container constructor constraints, and migrated deprecated toast properties to `PlasmaToastManager`.
- **FilePicker Version Matching**: Replaced `FilePicker.platform.pickFiles` with the correct `FilePicker.pickFiles` static primitive to match project packaging.
- **Status**: The workspace successfully compiles with **zero static compiler errors**.

---

## 2026-07-15 (Evening) · Authentication Gateway, Profile Dropdowns, Windows Export, Concurrency & Audit Trails

Successfully shipped user authentication with profile popovers, Windows release packaging, concurrency control, creation audit tracking, and list view refinements in the Cutting Cards module.

### Cutting Cards List View Refinements
- **Active Filter/Sort Popovers**: Converted `OrganPaneHeader` inside [pane_header.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/organism_design/organs/pane_header.dart) to a `StatefulWidget` to store `GlobalKey` references. Programmed triggers to call popover `toggle()` programmatically on button tap, resolving gesture interception/disabled states.
- **Right-Aligned Footer Layout**: Configured `TissueListCard` inside [cutting_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/cutting_screen.dart) with `isCompact: false` for comfortable height padding. Assigned the piece count (`1347 Pcs`) to the `footer` slot wrapped in a right-aligned `Align` container. This cleanly stacks the piece count directly underneath the trailing voucher chip badge, resolving inline-subtitle spacing issues and ensuring high-fidelity visual grouping.
- **Date Icon Upgrade**: Refined `CellCardAvatar` inside [card_avatar.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/organism_design/cells/card_avatar.dart) to present the day (DD) on top and the 3-letter month shortform (MMM) in uppercase below for higher-fidelity temporal rendering.
- **Sort & Filter popover items**: Extended popovers for mill, fabric, date, and challan sequence operations.

### Legacy Modules Reference Documentation
- **Comprehensive Guide**: Compiled and classified all 73 legacy voucher modules from the Voucher Series Master `sq_SERIES` and `legacy_constants.dart` into [legacy_modules_guide.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/legacy_modules_guide.md).
- **Categorization & Relational Mapping**: Organized modules into 7 functional business groups, detailed the double-entry impact of cash/bank/sales, mapped the production `CARDNO` thread through the O-series, and analyzed the compound relational key rules (`CNO/VNO/TYPE`) and `sq_RECPAY` settlement flows.

### Job Work Management Module (O5 & O6)
- **New Module Shipped**: Developed and registered the new Job Work Management screen ([job_work_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/job_work_screen.dart)) with tabs for **Job Dispatch** (`O5`) and **Job Receive** (`O6`).
- **Relational Linkage**: Implemented models ([model_jobwork.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/models/model_jobwork.dart)) and services ([service_jobwork.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/services/service_jobwork.dart)) that pull active FY 26-27 records from `sq_BILLS` and `sq_BILLDET` (`VNO < 100000`) and establish links between cutting cards (`CUTCARDNO` from `sb_cutdet`), Stitching Dispatches (`orderno = CUTCARDNO` / `ORDTYPE = 'O3'`), and Stitching Receives (`STAGE_VNO = O5_VNO` / `STAGE_TYPE = 'O5'`).
- **Integrated Navigation**: Mapped route index 7 in [home.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/home.dart) to the new screen and added search support via the command palette.

### PostgREST Limits & Available Takas RPC Refactoring
- **Bypassing Server Limits**: Refactored the `getAvailableTakas` query inside [service_cutting.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/services/service_cutting.dart) to use a custom database RPC `get_available_takas`.
- **The Issue**: Previously, the app fetched a client-side filter array of all cut cards to exclude them, which got truncated silently at PostgREST's default max-rows cap of 1,000, allowing "trailing cut cards" (already cut cards) to bleed into the UI.
- **The Solution**: Moving the join logic into PostgreSQL via a native SQL `NOT EXISTS` query ensures that only genuine uncut rolls are fetched, bypassing API row limitations entirely.

### User Audit Trail Tracking
- **JWT Header Decode**: Upgraded the `create-cutting-batch` Edge Function to extract the authorization header, decode the base64 JWT payload, and resolve the authenticated `userId` and `userEmail` on the fly.
- **Dynamic Username Resolution**: Enhanced Deno Edge Function transaction logic to resolve the explicit profile `username` (e.g., `SUBHAM`, `JATIN`) from the `sb_APP_PROFILES` database table, falling back to email local-parts only if a profile doesn't exist.
- **Audit Columns Populated**: Writes to `sb_cutdet` and `sb_cutdet_summary` now record `sb_created_by` (UUID), `CREATOR` (user email prefix or profile username), and `CREATETIME` (timestamp).
- **Edit Tracking**: Modifications to batches set `UPDATER` and `UPDATETIME` to track edits.
- **UI Creator Badge**: Updated [cutting_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/cutting_screen.dart) detail canvas footer to display the `Creator` username next to the batch status badge for active reviews/edits.

### Cutting Cards Concurrency & Realtime Sync
- **Unique Roll Constraint**: Deployed a partial unique index `sb_cutdet_unique_reccardno` to block the double-cutting of the same roll (`reccardno`) by concurrent users.
- **VNO Serialization**: Added an exclusive table lock statement `LOCK TABLE sb_cutdet_summary IN EXCLUSIVE MODE` within the `create-cutting-batch` Edge Function transaction block to prevent race conditions during sequential `MULTI_VNO` generation.
- **Friendly Database Error Intercepts**: Configured the Edge Function to catch Postgres constraint violations and return user-friendly, clean error messages.
- **Supabase Realtime Sync**: Subscribed to database mutation events on the `sb_cutdet` table inside [cutting_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/cutting_screen.dart). MUTATION updates automatically trigger hot-reload of available rolls and summary lists across active instances.

### Windows Release Compilation & Packaging
- **Production Build**: Executed `flutter build windows --release` to compile the optimized Windows binary (`textile_erp.exe`) in the runner release directory.
- **Distribution Package**: Generated `textile_erp_windows_release.zip` at the workspace root, containing the compiled executable and all required runtime dependency DLLs for quick sharing.

### Core Authentication & Session Routing
- **AuthGate Engine**: Deployed [auth_gate.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/auth/auth_gate.dart) to listen reactively to Supabase `onAuthStateChange` streams. Transitions smoothly from loader animations to either the `LoginScreen` or `HomeScreen` based on session validity.
- **Auth Services**: Introduced [service_auth.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/services/service_auth.dart) for clean encapsulation of standard Supabase signIn / signOut actions.

### Premium Login User Interface
- **Layout**: Implemented the premium login card interface in [login_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/auth/login_screen.dart). Restored form fields using `CellInput` and actions using `CellButton`.
- **Keyboard Mechanics**: Enabled fluid keyboard navigation (`Tab` transitions and `Enter` key form submission).
- **Error Feedback**: Added live visual feedback with error flags to report incorrect credentials dynamically.

---

## 2026-07-15 · Cutting Cards Architecture Refactoring, Multi-Select Chips & Transactional Edits

Shipped major workflow enhancements, design system updates, and database transactional logic for the Cutting Cards module.

### Refactoring to Supabase Native Tables
- **Exclusion of sq_CUTDET**: Removed all legacy sync-table read/write lookups referencing the read-only mirror table `sq_CUTDET`. The registry list pane now retrieves records exclusively from the Supabase transactional summary view `sb_cutdet_summary` and the detail view from `sb_cutdet`.

### Batch Sequencing & Card Labeling
- **MULTI CARD NO & MULTI_VNO**: Renamed the input label `CUT CARD NO` to `MULTI CARD NO` on the Add Page.
- **Sequence Generator**: Repurposed the sequence finder to query the max `MULTI_VNO` in the current fiscal context (`VNO < 100000`) from `sb_cutdet` and display/increment it.
- **Sequence Overrides**: Deployed support to allow manual overrides of `MULTI_VNO` to any customized value (including unused/blank values like `12` or `13`) in both Create and Edit flows.

### Design System: Multi-Select Chip Autocomplete
- **CellAutocomplete Upgrade**: Refactored the core design system widget `CellAutocomplete` to natively support multi-select (`isMultiSelect: true`). It embeds selected options as dismissible, auto-wrapping inline chips (`CellInputChip`) inside the input container itself, matching the high-density keyboard-friendly design language.
- **Grey Quality Selector**: Integrated the updated multi-select autocomplete inside the step bar, replacing the popover dropdown. The save payload joins the selected qualities with a comma (`DANI, GEORGETTE`), while the backend database stores individual rolls with their specific quality.

### PostgREST Pagination Limit Bug Fix
- **The Issue**: Once the total number of closed rolls in `sb_cutdet` exceeded 1,000, Supabase/PostgREST's default query page size limit (1,000 rows) capped the returned cut card numbers. This caused any cut rolls from newer batches (such as batches 81, 82, etc.) to not be fetched in the exclusion list, resulting in already cut rolls incorrectly showing up as available in the UI.
- **The Fix**: Added `.limit(100000)` to the closed card query in `getAvailableTakas()` inside `service_cutting.dart` to bypass the default limit and ensure all closed rolls are fetched for client-side exclusion.

### Transactional Edit Support
- **Edge Function Upgrades**: Modified the `create-cutting-batch` Edge Function to support `edit_multi_vno`. If passed, the transaction deletes the old batch records and re-inserts the updated batch under the targeted number. Deployed **Version 8** successfully.
- **Pre-population & Auto-Selection**: Clicking "Edit Batch" in the detail header card pre-populates all inputs (Fresh/Second counts, average saree weight, screen references), loads uncut rolls + the batch's own cut rolls, and automatically pre-selects the cards in the batch.
- **Save & Selection Auto-Refresh**: Modified `_saveBatch()` success callback to clear stale selected state, hide the overlay, trigger a reload of list cards, and automatically highlight and load details for the updated batch ID.
- **Date Picker State Lifecyle Bugfix**: Added a `didUpdateWidget` lifecycle handler to the `CellCalendar` widget to fix a bug where the date picker month view always defaulted to today (July 2026). The picker calendar now correctly shifts to show the pre-populated date (e.g. April 2026) when editing.

---

## 2026-04-15 (Evening) · Advanced Registry Systems & Production Kanban Workstation

Successfully shipped two major workflow modernizations: the unified Masters Registry and the Grey Production nested Kanban board.

### Masters Registry Modernization
- **High-Density Split Pane**: Rewrote the `PartiesScreen` to utilize `vwsq_MASTER` with live, server-side pagination and search.
- **Global Business Role Topology**: Established a 12-color categorical mapping system (`OrganismTheme` chart colors) inside `LegacyConstants`.
- **Badge API Enhancements**: Upgraded `CellBadge` to support `customColor` overrides with automatic text contrast (black/white) based on luminance. This allows parties (e.g. "Weavers", "Customers") to be instantly recognizable at a glance via color.
- **Precision Subtitles**: Implemented logic to dynamically display "STATION x CITY" for robust geographical tracking on registry cards.

### Grey Production Workflow
- **The "Data Bridge"**: Mapped the complex three-tier relationship of textile production: `sq_BILLS (P1 Header)` → `sq_PINVTRN (Job Cards)` → `sq_CHALTRN (Rolls / Takas)`.
- **Registry View Optimization**: Deployed `vwsq_GREY_REGISTRY` to aggregate total job cards and meters efficiently at the database level.
- **UI Architecture — Process Kanban**:
  - Left Pane: Scrollable registry of Grey Purchase headers.
  - Right Pane: A horizontally scrolling Kanban layout where each column represents an active dispatch batch (`PINVTRN`).
  - Taka Grids: Inside each batch column, dense numeric lists display roll-level actual metrics (`PMTS` / `TAKA_WT`).
- **Fiscal Isolation**: Hard-enforced the `VNO < 1,000,000` carry-forward rule securely at the service layer.
- **Syntax Remediation**: Fixed lingering `postgrest-2.6.0` syntax errors (swapped `.select('*', count:...)` for the chained `.count(CountOption.exact)` method) inside `GreyService`.

---

## 2026-04-14–15 · Quality Masters Registry — Schema Connectivity & Debug

Successfully resolved persistent **PGRST002 (Schema Not Found)** errors blocking the entire `IMMBE2627` data access layer and shipped the Quality Master registry UI with functional tabs.

### Root Cause — Triple Compounding Issue
Three independent problems combined to produce the `PGRST002` errors:

1. **`IMMBE2627` not exposed via Data API**: Schema was present in the DB but never checked in Supabase Dashboard → **Integrations → Data API → Exposed Schemas**. Checking it (and clicking **Save**) tells PostgREST to serve that schema.
2. **Wrong `anonKey` format**: A modern `sb_publishable_…` key had been substituted into `supabase_config.dart`. The project requires the legacy **JWT-based anon key** (format: `eyJ...`). Restored to correct value.
3. **`postgrest-2.6.0` syntax mismatch**: `.select('*', count: CountOption.exact)` is invalid in `postgrest-2.6.0`. The count must be chained as a separate terminal call: `.select('*')…order()…range()…count(CountOption.exact)`.

### Resolution Steps (Chronological)
| Step | Action | Outcome |
|---|---|---|
| 1 | Audited `pubspec.lock` → confirmed `postgrest-2.6.0` | Identified count syntax root cause |
| 2 | Inspected `postgrest_query_builder.dart` + `postgrest_transform_builder.dart` source | Confirmed `.select()` has no `count:` param; `.count()` is terminal only |
| 3 | Fixed query chain order in `MastersService` | Compilation errors eliminated |
| 4 | Restored JWT `anonKey` in `supabase_config.dart` | Authentication reconnected |
| 5 | User exposed `IMMBE2627` in Supabase Dashboard and clicked **Save** | `PGRST002` resolved |
| 6 | Removed `Extra search path` from Dashboard | Reverted; explicit `.schema('IMMBE2627')` used instead |
| 7 | Diagnostic: switched Quality service to raw `sq_QUAL` table | Confirmed data was reachable |
| 8 | Restored `vwsq_qual` as the production view | Full registry operational |

### Code Changes
- **`lib/config/supabase_config.dart`**: Restored legacy JWT `anonKey`.
- **`lib/services/service_masters.dart`**:
  - Fixed `.select('*', count:…)` → `.select('*')…count(CountOption.exact)` for both `getParties` and `getQualities`.
  - Added explicit `.schema('IMMBE2627')` to all query chains.
  - Switched `getQualities` from `vwsq_qual` → `sq_QUAL` for diagnostics, then back to `vwsq_qual`.
  - Added `QualityBarrel.all` (no filters) for diagnostic tab visibility.
- **`lib/screens/items/items_screen.dart`**: Added **All** tab (4th barrel) for zero-filter debugging.
- **`lib/models/model_quality.dart`**: Confirmed column mapping is compatible with both `sq_QUAL` and `vwsq_qual`; `parseDouble()` helper handles mixed `num`/`String` types from Postgres.

### Architecture Lessons Learned
- `.schema()` call in `supabase_flutter` sends a `db-schema` request header to PostgREST. PostgREST will only honour it if the schema is in the **Exposed Schemas** list — a Dashboard setting, not a SQL grant.
- `anon` `GRANT SELECT` on a table is necessary but not sufficient. The schema must also be exposed via the API settings.
- `NOTIFY pgrst, 'reload schema'` (PostgREST schema cache flush) requires the schema to already be in the exposed list — it only refreshes the cache, not the allow-list.
- Auth `storage` and `auth` schemas do not appear in the Exposed Schemas list; they are private system schemas served via dedicated Supabase APIs.

### Status
- ✅ `PGRST002` resolved — all `IMMBE2627` tables/views now accessible via Supabase Data API.
- ✅ Quality Masters compiling and loading data from `vwsq_qual`.
- ✅ Parties loading from `sq_MASTER` with pagination.

---

## 2026-04-14 (Day) · Quality Masters Registry — Implementation

Built the full live 3-tab Quality Master registry connected to `IMMBE2627.vwsq_qual`, and performed the `sq_MASTER` contact data census.

### Quality Registry — 3-Tab Live Feature
- **`vwsq_qual` View**: App now strictly consumes this 14-column curated view (not the raw `sq_QUAL` table), ensuring data quality guards are applied at the DB layer.
- **Barrel Logic** (`MastersService`):
  - **Sales**: `SELL1 >= 180` + `CLOTHTYPE = 'SAREE'` — targets the active textile portfolio.
  - **Grey**: `ISBASEQUAL = 'Y'` — isolates 99 raw fabric base qualities.
  - **Others**: Catch-all for hardware/stationery/misc (RAM, SSD, Stationery, Freight).
- **`QualityModel`** (`model_quality.dart`): Immutable data class with `parseDouble()` helper handling mixed `num`/`String` inputs from Postgres. Maps all 14 key columns from the view.
- **`ItemsScreen`**: 3-tab pill navigation (Sales / Grey / Others) with live pagination (50 items per page via `offset`/`limit`).
- **Detail Pane**: Pulls live HSN codes, GST rates, and standard cut lengths directly from Supabase.

### Contact Data Census — `sq_MASTER`
Performed a quantitative audit of all 4,941 party records to plan a future CRM normalization effort. Findings documented in `organism_audit_report.md`:

| Source Column | Contact Points | Notes |
|---|---|---|
| `MOBILE` | 2,304 | Primary target — clean mobile numbers |
| `CONTACT` | 1,966 | **High Clutter** — mixes names, roles, and numbers |
| `WEB_MOBILE` (1-4) | 540 | Secondary/website-linked mobiles |
| `PHONE1 / PHONE2` | 641 | Mostly landlines |
| `FLASH_RMK` | 467 | Free-form notes with buried numbers |

- **Hidden Contacts via Regex**: 1,571 numbers buried in `CONTACT`, 247 in `FLASH_RMK`, 136 Surat landlines (7-digit format needing `0261` prefix).
- **Total Estimated CRM reach**: ~5,200 unique contact points (vs. 2,304 accessible today).
- **Recommendation**: Create `exsq_master_contacts` normalized table (already exists in schema with 4,273 extracted rows from a prior migration run).

---

## 2026-04-13 · `sq_QUAL` Deep Audit + App Icon Design

### Quality Master Schema Audit (`sq_QUAL`)
Performed a full quantitative audit of the `sq_QUAL` table (931 rows, 37 columns) and documented in `backend/schema_docs/02_masters/sq_QUAL.md`. This became the foundation for the barrel-based Quality registry implementation.

**Key Findings:**
| Metric | Value |
|---|---|
| Total records | 931 |
| Columns | 37 |
| Data completeness | ~55% |
| 100% NULL columns | `COST_PER`, `SUPPLIER`, `VATRATE`, `SCREENCOMP` |
| GST Compliant (HSN + GSTRATE filled) | ~92% |
| Missing `CUT` (production specs) | 274 items |

**Column Classification:**

| Category | Columns | Status |
|---|---|---|
| Core Identity | `qcode`, `NAME`, `CLOTHTYPE`, `UNIT` | ✅ 100% complete |
| Sales | `SELL1/2/3`, `HSN_CODE`, `GSTRATE` | ✅ ~75% complete |
| Production | `CUT`, `PACKING`, `ISBASEQUAL` | ⚠️ Partial |
| Financials | `COST_PER`, `pur1`, `SUPPLIER` | ❌ 100% NULL — TODO |
| Legacy/Irrelevant | `VATRATE`, `SCREENCOMP`, `OLDQCODE` | 🚫 Ignore |

**Barrel Plan Finalized:**
- **GREY** (99 items): `ISBASEQUAL = 'Y'` — raw grey fabric anchors.
- **SALES** (650 candidates, 317 "core"): `SELL1 >= 180`, SAREE/FINAL cloth types.
- **OTHERS**: Hardware (RAM, SSD), Stationery, and Misc non-textile items.

**CLOTHTYPE Distribution:**
- `SAREE`: 842 items (dominant)
- `LACE`: 41, `FABRIC`: 21, `UNSTITCHED`: 12

**Design Decision**: Use `CLOTHTYPE` as the primary sidebar filter; `category` (54 distinct seasons/collections) as a secondary chip filter.

### App Icon Design Session
Explored and generated multiple Ambaji Sarees app icon options with Burgundy/Gold branding palette:
- Option 1: Embroidered motif style — textured, ornate.
- Option 3: Flat bold monogram style — clean, modern ERP feel.
- Final direction: Retained for future brand identity finalization.

---

## 2026-04-12 · Organism Architectural Standardization — Full System Sweep

Completed the final architectural standardization of the `organism_design` library. Enforced strict relative imports, added comprehensive file summaries, and refactored layout spacing across all 3 directories (Cells, Plasma, Tissues).

### Key Architectural Shifts
- **Strict Relative Imports**: Internal components now import siblings directly (e.g., `import '../cells/button.dart';`) rather than using barrel files. Barrel files are now reserved solely for external exporters.
- **File Summaries**: Added `/// [ComponentName] — Short Description` blocks to every single file (70+ components) to maintain the "Master Index" fidelity.
- **Spatial Governance**: Refactored hardcoded `SizedBox` and `Padding` instances to use the new `CellGap` and `CellPad` spatial utilities, strictly enforcing `OrganismTheme.spacingMd` multiples.

### Standardization Summary
| Layer | Count | Standardization Completed |
|---|---|---|
| **Cells** | 33 | All Atoms (Buttons, Inputs, Toggles, Display, Layout) |
| **Plasma** | 5 | All Primitives (Dialog, Popover, Toast, Physics, ZStack) |
| **Tissues** | 19 | All Molecules (Card, FormField, ListView, Pipeline, Tabs, etc.) |

### Implementation Details
- **`empty.dart`**: Renamed internally and standardized as `TissueEmptyState` molecule.
- **`spatial.dart`**: Introduced `CellGap` (SizedBox replacement) and `CellPad` (Padding replacement) for theme-relative spacing.
- **`index.dart`**: Updated master summary to include spatial utilities and complete component counts.
- **Verification**: All internal imports verified; barrel files updated with full documentation.

---

## 2026-04-11 · cells_view.dart — Full 33-Cell Coverage

Complete rewrite of `cells_view.dart`. Converted from `StatelessWidget` → `StatefulWidget`
so interactive demos (checkbox, switch, radio, slider, combobox, toggle group, input chip)
actually respond to user input.

### Sections (7 total)
| # | Section | Cells Covered |
|---|---|---|
| 1 | Action Dynamics | CellButton (all 5 variants + compact + icons), CellMultiButton |
| 2 | Text & Numeric Entry | CellInput (4 modes), CellInputNumber |
| 3 | Selection Controls | CellCheckbox, CellSwitch, CellRadio, CellSlider, CellToggleGroup |
| 4 | Advanced Data Entry | CellCombobox, CellDatePicker, CellTimePicker, CellCalendar, CellInputChip |
| 5 | Display & Indicators | CellBadge (6 variants), CellCountBadge, CellAvatar, CellFilterChip, CellTag, CellStatusDot, CellProgressBar, CellTooltip, CellSkeleton, CellAlert, CellKbd |
| 6 | Structural DNA | CellBox, CellDivider, CellLabel, CellListTile, CellPlaceholder |
| 7 | Navigation & Brand | CellNavItem (Sidebar + Rail), AmbajiSareeLogo |

### API Fixes Applied
- `CellAlert`: uses `title:` + `icon:` + `variant: CellBadgeVariant` (not `CellAlertVariant` — doesn't exist)
- `CellRadio`: has no `label:` param → wrapped each radio in `_radioRow()` helper (Row + Text)
- `CellSkeleton`: API is `width`, `height`, `borderRadius` (no radius shorthand) ✅

---


### `CellStatusDot` — `cells/status_dot.dart`
- **StatefulWidget** with `SingleTickerProviderStateMixin` for animated pulse.
- 5 variants: `active` (green pulse), `syncing` (primary pulse), `idle`, `warning`, `error` (static).
- `active` and `syncing` auto-animate their glow; all others are static. Override with `pulse:`.
- Renders 8px dot + right-aligned label in `bodySmall/textSecondary`.

### `CellTag` — `cells/tag.dart`
- **StatelessWidget** — distinct from `CellFilterChip` (toggle) and `CellBadge` (unclickable status).
- 5 variants: `neutral`, `accent`, `success`, `warning`, `error` with proper semantic colors.
- Optional `onRemove` callback renders a `×` button with generous hit area (Padding 2px all).
- Optional `onTap` wraps the whole tag in a `GestureDetector`.
- Uses `borderPill` radius for a clean rounded pill shape.

### Library Registration
- Both cells documented in `cells_view.dart` → **Micro UI Mechanics** section with live examples.
- Registered in `cells.dart` barrel with full doc comments.

---


### Barrel Files — Full Doc Comments
Replaced all `// AUTO-GENERATED` stubs across the design system barrel files with rich, structured Dart doc-comments explaining every single exported symbol.

- **`cells.dart`**: All 30 cells documented with description, variants, use-cases, and sizing notes. Grouped into: Interaction/Controls · Data Input/Selection · Display/Indicators · Layout/Structural · Focus System.
- **`tissues.dart`**: All 19 tissues documented. Grouped into: Surface/Containers · Form & Data Entry · Navigation & Layout · Actions/Menus · Data Display · Status/Feedback.
- **`plasma.dart`**: All 5 plasma exports documented — Physics engine, ZStack depth system, Dialog, Popover, and ToastManager with z-index values noted.
- **`organs.dart`**: `NavBoat` fully documented — Sidebar vs Rail mode dimensions, routing contract, Toast overlay anchor.
- **`systems.dart`**: Placeholder with future roadmap (StandardListDetailSystem, DashboardSystem, FormPageSystem).
- **`index.dart`**: Master barrel rewritten as a comprehensive visual reference — full architecture hierarchy diagram, every component with one-line summary, grouped by layer.

### Bug Fixes (Earlier Today)
- **`tissues_view.dart`**: Fixed mismatched closing brackets from `LibraryComponentDoc` refactor on `_buildListCardsSection`.
- **`theme_view.dart`**: Fixed `colors.secondary` → `colors.stone200` and `colors.destructive` → `colors.error` (non-existent getters).

### Dev Log
- Moved `dev_log.md` to `frontend/docs/dev_log.md` (new canonical location).

---

## 2026-04-11 · Organism Library Overhaul & Context-Aware Theme Migration

### Theme Architecture — Final Migration
- **Eliminated Static Anti-Pattern**: Removed all `OrganismTheme.primary` static getter calls across the codebase. Every component now calls `OrganismTheme.colorsOf(context)` inside its `build` method.
- **Theme File Split**: Broke `theme.dart` (1,000+ lines) into semantic modules:
  - `theme/colors.dart` — `OrganismColors` struct with `.light()` / `.dark()` factories.
  - `theme/metrics.dart` — All spacing, radius, breakpoint, z-index, and animation constants.
  - `theme/typography.dart` — All `TextStyle` generator methods.
  - `theme.dart` — Retained as central aggregator / backwards-compatible export barrel.
- **Context Propagation Fix**: Refactored all helper methods (`_buildSection`, `_depthCard`, etc.) across `cells_view.dart`, `plasma_view.dart`, `tissues_view.dart`, `home.dart` to explicitly accept `BuildContext` and `OrganismColors` parameters.
- **Overlay Scope Fix**: Fixed `dialog.dart` and `popover.dart` — colors are now resolved *inside* the `OverlayEntry`/`pageBuilder` callback, not at call site.
- **Lint Cleanup**: Removed `unused_local_variable` in `main.dart`, `unnecessary_import` in `alert.dart` and `badge.dart`.

### Library Screen — Pill Tab Navigation
- **`library_shell.dart`**: Converted to `StatefulWidget`. Added `TissueTabs` (pill variant) to the `AppBar` center, driving 5 sections: **Theme · Plasma · Cells · Tissues · Organs**.
- **New `theme_view.dart`**: Documenting design tokens — Color Palette, Typography System, Metrics & Spacing.

### Library Screen — `LibraryComponentDoc` Widget
- Created `LibraryComponentDoc` in `library_section.dart`: a wrapper that shows the **exact Dart file path** and a semantic description above every live component demo.
- Applied across all 5 views:
  - `cells_view.dart`: Buttons, Inputs, InputNumber / OrganismFormat, Toggles/Badges, Box/ListTile, Chips.
  - `plasma_view.dart`: Z-Index scale, Dialog, Toast, Popover, Depth/ZStack, Shadow/Radii, DataViz palette, Responsivity.
  - `tissues_view.dart`: TissueCard, FormField/DateField, ButtonBar, TissueMenu, Tabs, Stepper/Select, Pipeline, Alert, EmptyState, ListCard.
  - `organs_view.dart`: System Modals, NavBoat shell.

### Bug Fixes (EOD)
- **`tissues_view.dart`**: Fixed unmatched parenthesis in `_buildListCardsSection` — `TissueListCard` closing bracket misaligned after refactor.
- **`theme_view.dart`**: Replaced non-existent `colors.secondary` and `colors.destructive` with valid tokens `colors.stone200` and `colors.error` respectively.

---

## 2026-04-10 · GitHub Actions & CI/CD

- **Deployment Debug**: Investigated `git exit code 128` error in GitHub Actions workflow blocking the `ogranism_library` GitHub Pages deploy.
- **Checkout Fix**: Ensured repository is correctly checked out before Pages deploy step.
- **Node.js Deprecation**: Addressed Node.js 20 deprecation warnings in workflow YAML.
- **Status**: CI/CD pipeline stabilized for GitHub Pages auto-deployment.

---

## 2026-04-09 · ERP Architecture Standardization, DB Migration & Session Cleanup

### UI Architecture
- **`ManagedListViewPane`**: Migrated all list modules (Masters, Items, Production) to use this unified controller-less pane. Centralizes search, tab handling, and pagination.
- **Global Pane Width**: Standardized left pane to **380px** via `AppTheme.masterPaneWidth = 380.0`; removed per-screen overrides.
- **Branding Cleanup**: Renamed "Masters v3" → **Masters**, "Items V3" → **Items**; removed legacy sidebar duplicates.

### Organism Design System — Stabilization
- **Iconography Tokens**: Defined semantic icon size constants (`iconSizeXs` → `iconSizeLg`) and tokenized icon colors.
- **Full Lucide Migration**: All components (`CellButton`, `TissueDatePicker`, etc.) migrated from Material Icons to `LucideIcons`.
- **`NavBoat` Organ**: Implemented collapsible Sidebar/Rail navigation shell.
  - Rail width fixed at 84px with stacked "Icon over Name" layout.
  - Resolved header overflow (116px width collision).
- **Lib Cleanup**: Removed `LibraryPreview` redundancy; registered `NavBoat` in `index.dart`.

### Database — Cutting Cards FY 26-27 Pivot (`IMMBE2627`)
- **Table**: Cloned `sb_CUTTING_CARDS` structure → `IMMBE2627.sb_cuttingcards`.
- **Relational Integrity**: Added `UNIQUE(code)` to `IMMBE2627.sq_MASTER`; FK from `sb_cuttingcards.mill_name` → `sq_MASTER.code`.
- **Aggregated View `vw_cutting_cards`**: Live analytics — `total_cost`, `short_pct`, `pc_pct`, `cost_per_pc`; joins `sq_CUTDET` with new header table.
- **Service Update**: `CuttingCardsService` re-pointed to `IMMBE2627` schema and new view.
- **View Naming Convention**: Instituted `sb_vw_` (Supabase native) and `sq_vw_` (SQL mirror) prefixes for all 12 views in `IMMBE2627`. Renamed 11 views; updated all Flutter services and models.

### Workspace Audit
- **Legacy Tooling Removed**: Deleted `.claude/`, `.superpowers/`, `docs/superpowers/` (old CLI artifacts).
- **Log Relocation**: Moved `frontend_log.md` to `docs/logs/`.
- **`docs/MASTER_REFERENCE.md`**: Created as single source of truth for ATYPE mapping, Production Flow (O-series), and SQL safety rules.

---

## 2026-04-08 · ERP Typography, Navigation, Tissues Architecture

- **Typography Refinement**: Tightened heading scales and numeric font (`JetBrains Mono`) across ERP screens.
- **Tissues Category**: Finalised `OrganismUI` library — added `listHeaderSection`, `pagination`, and `scrollableList` as standard Tissues.
- **`PackingSlipsScreen` Refactor**: Migrated to use new Tissue components for visual consistency.
- **Navigation Work**: Continued `ManagedListViewPane` rollout; resolved tab-state bugs.

---

## 2026-04-06–07 · Authentication, RBAC & Emerald Preview

- **Email Auth Migration**: Replaced phone-based auth with email/username login in `AuthService` and `LoginScreen`.
- **Supabase Schema**: Added `username` field + auto-sync trigger for user profiles.
- **RBAC Foundation**: Set up centralized profile management in Supabase; implemented auth guard protecting all app routes.
- **Emerald Theme Login**: Built high-fidelity "Emerald Light Mode" login UI.
- **`ambaji_preview.html`**: Restored design system HTML documentation page.

---

## 2026-04-05 · Foundation — Schema Migration Setup & Component Catalog

- **Schema Migration**: Initial setup of `IMMBE2627` (FY 26-27) Supabase schema alongside Airbyte `IMMBE2526` mirror.
- **Emerald Refresh Phase 1**:
  - Defined `AppColors` (Emerald/Slate) and `AppTheme` (VisualDensity.compact + JetBrains Mono).
  - Replaced Material Icons with `LucideIcons` in `Sidebar` and `TopAppBar`.
  - **Production Module — Grey Inward**: Updated icons/colors, high-density layout, mono fonts.
- **Component Catalog Expansion**: Initiated 200+ component design system based on Supabase design system audit. Goal: definitive "Ambaji 100" visual source of truth for all textile workflows.
- **Backup Script**: Created `backup_erp.ps1` PowerShell script for timestamped snapshots (~240MB clean).

---

## 2026-07-21 · Dynamic AI Design System, Native Shadcn Refactoring & Layout Architecture

### Native `shadcn_flutter` Theme & Root Workspace Polish
- **Teal Light Theme Palette**: Re-pointed default light theme to `shad.ColorSchemes.lightSlate.teal` in `main.dart`.
- **Window Tabs Dark Mode Fix**: Resolved white background bleed in dark mode by wrapping `DynamicTabWorkspace` inside `shad.Scaffold(backgroundColor: theme.colorScheme.background)`.
- **Window Tab Bar Sidebar Toggle**: Integrated `panelLeftClose` / `panelLeftOpen` toggle icon button into `DynamicTabWorkspace` (`leading` list of `shad.TabPane`). Placed on the exact same horizontal line as workspace tabs (`Home x`, `Orgs x`), smoothly expanding `DynamicNavRail` (64px icon-only rail to 180px expanded sidebar).

### Page-Level Data Components
- **`DynamicTable<T>` Native Data Grid**: Built standalone, generic data grid component in `lib/dynamic_ai/components/page_level/dynamic_table.dart` using native `shad.Table`, `shad.TableHeader`, `shad.TableRow`, and `shad.TableFooter` primitives.
  - **Full-Height Workspace Canvas Expansion**: Applied `LayoutBuilder` + `ConstrainedBox(minHeight: maxHeight)` to force 100% vertical canvas stretching regardless of row count.
  - **Aligned TableFooter**: Standardized 1:1 table cell alignment under data columns for sticky totals rows.
  - **Native Pagination**: Integrated `shad.Pagination` control strip with row selection counters in table footer utility bar.
- **`DynamicMetricCard` & `DynamicMetricRow`**: Built KPI metric row in `lib/dynamic_ai/components/page_level/dynamic_metric_row.dart` using native `shad.Card`.
  - Positioned KPI summary bar directly above `DynamicActionBar` (DAB) on `DemoScreen`.
  - Applied explicit `borderColor: colors.border` to achieve sharp 1px outlines matching form controls (`Select`, `TextField`).

### Architectural Strategy — Scaling to 25+ ERP Pages
- **Evaluation of `shadcn_flutter` Primitives**: Profiled `NavigationRail` vs `NavigationSidebar` and `Card` vs `SurfaceCard`. Preserved `NavigationRail` to retain native hover tooltips in collapsed state.
- **Direct Native Composition Architecture**: Established layout policy for scaling 25+ ERP screens—moving away from monolithic wrapper blueprints toward direct native `shad.*` component composition paired with micro-utility helpers.

---

## Conventions & Rules
- **DB Target**: All FY 26-27 work targets `IMMBE2627`; read-only legacy data from `IMMBE2526`.
- **View Naming**: `sb_vw_` = Supabase native, `sq_vw_` = SQL mirror views.
- **SQL Safety**: Always include `TYPE` in BILLS JOINs to avoid fan-out. Pending = `CLOSED IS NULL OR '' OR 'N'`.
- **Theme Access**: Always use `OrganismTheme.colorsOf(context)` — never static getters.
- **State Management**: `StatefulWidget` + Service singletons (no Riverpod/Bloc yet).

