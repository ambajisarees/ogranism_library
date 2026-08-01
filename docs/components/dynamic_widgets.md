# Dynamic AI Component Engine: Master Reference Guide & Progress Tracker

This document serves as the authoritative, categorized specification, component inventory, and progress log for all files within `frontend/lib/dynamic_ai/` in **Ambaji Sarees ERP**.

> [!NOTE]
> All components follow the unified `dy_` naming convention, strict `shadcn_flutter` color/typography tokens (`colors.border`, `colors.card`, `colors.primary`, `theme.scaling`, `theme.radiusMd`), and zero ad-hoc container wrappers.

---

## 📐 1. Global Grid & Flex Layout Specifications (`specs/`)

* **`dy_grid_system.dart`** — ✅ **DONE**  
  *Authoritative 12-column grid system & viewport ratio constants.*
  * **Table View**: 12-Column Full-Width Data Grid (`flexTableGrid = 12`).
  * **List View**: Fixed 360px Master List (`fixedListMasterWidth = 360.0`) + Flex 8 Detail Inspector (`flexListContentInspector = 8`).
  * **Cards View**: 75% Cards Grid (`flexCardsGrid = 9`) + 25% Detail Inspector (`flexCardsInspector = 3`).
  * **Board View**: 4 Equal Stage Columns (`flexBoard4PaneEqual = 3` each $\rightarrow$ $4 \times 3 = 12$ total flex).
* **`dy_color_system.dart`** — ✅ **DONE**  
  *Master 6-color scale specification (`Red`, `Green`, `Yellow`, `Orange`, `Indigo`, `Fuchsia`) with 500 solid primary tokens, 100 surface tokens, and categorical charting palette.*

---

## 📊 2. Standardization Progress by Category

### 📁 `micro/` — Micro Controls
* **`dy_micro_button.dart`** — ✅ **DONE**  
  *34px height DAB filter button. Zero-shift contract with static labels, semibold badge text (`w600`), and dynamic focus outline.*
* **`dy_pagination_row.dart`** — ✅ **DONE**  
  *Surface-less pagination row outside card container. Uses native `shad.Pagination` buttons with 44px outer height.*
* **`dy_page_tabs.dart`** — ✅ **DONE**  
  *Zero-padding context tab switcher row for page-level navigation (`Details`, `Reports`, `Tasks`).*
* **`dy_nav_rail.dart`** — ⏳ **PENDING**  
  *Slim fallback navigation rail for compact desktop screens.*

---

### 📁 `micro/cards/` — Card & Tile Components
* **`dy_list_item.dart`** — ✅ **DONE**  
  *Interactive item tile card for master list view (`dy_list_pane.dart`). Includes hover state, selection tinting, and primary left accent border.*
* **`dy_grid_card.dart`** — ✅ **DONE**  
  *Visual tile card for Cards View (`dy_card_pane.dart`). Includes thumbnail image header, status chip overlay, voucher metadata, and metric badges.*
* **`dy_kanban_item.dart`** — ✅ **DONE**  
  *Compact interactive card tile for Kanban stage columns (`dy_kanban_pane.dart`). Shows voucher number, weaver title, quality subtitle, and mono quantity/amount metrics.*
* **`dy_report_card.dart`** — ⏳ **PENDING**  
  *KPI metric dashboard card with topic icon, values, and status chip.*

---

### 📁 `micro/dab/` — DAB Micro Widgets & Popovers
* **`dab_submodule_pop.dart`** — ✅ **DONE**  
  *Submodule switcher popover menu with live search.*
* **`dab_party_pop.dart`** — ⏳ **PENDING**  
  *Multi-select party/supplier filter popover.*
* **`dab_filter_pop.dart`** — ⏳ **PENDING**  
  *Searchable multi-select filter popover for Mill and Fabric criteria.*
* **`dab_date_pop.dart`** — ⏳ **PENDING**  
  *Split-pane date range presets & calendar picker popover.*
* **`dab_status_pop.dart`** — ⏳ **PENDING**  
  *Document status checklist popover (`PENDING`, `COMPLETED`).*
* **`dab_overflow_pop.dart`** — ⏳ **PENDING**  
  *Three-Dots action popover (Export, Column Visibility, Density).*

---

### 📁 `page/` — Page View Panes
* **`dy_page_header.dart`** — ✅ **DONE**  
  *Modular page header & context tabs (`PageHeader` & `PageTabs`). Displays `[onBack]` + `[Title + DocID Badge]` + `[PageTabs Switcher]` + `Spacer` + `[Trailing Actions]`.*
* **`dy_action_bar.dart`** — ✅ **DONE**  
  *8-slot pipeline toolbar (`ViewSwitcher` → `ModuleSwitcher` → `Search` → `Filters` → `Date` → `Sort` → `Clear` → `3-Dots`).*
* **`dy_table_pane.dart`** — ✅ **DONE**  
  *High-density table pane component (`DyTablePane` / `DynamicDenseTable`). Sticky headers, expandable child rows, summary calculation row, image gallery modal, and `DynamicPagination`.*
* **`dy_list_pane.dart`** — ✅ **DONE**  
  *Searchable master list pane (`DyListPane` / `DynamicList`). Fixed 360px width with search input header, paginated `DyListCard` items, and compact 2-button pagination footer.*
* **`dy_card_pane.dart`** — ✅ **DONE**  
  *Multi-column Cards View Engine (`DyCardPane` / `DyViewCard`) using `SliverGridDelegateWithMaxCrossAxisExtent(320px)` and standalone `DyPaginationRow` footer.*
* **`dy_kanban_pane.dart`** — ✅ **DONE**  
  *Vertical Kanban Stage Column Pane (`DyKanbanPane`). Framed in `shad.OutlinedContainer` with sticky header (stage title, count badge, status color indicator dot), vertical card list, and sticky footer (+ Add Card CTA).*
* **`dy_details_pane.dart`** — ✅ **DONE**  
  *Surface card inspector pane (`DyDetailsPane`). Displays title, metadata key-value table, status badge, and line-item overview.*

---

### 📁 `shells/` — Form & Master Details Shells
* **`dy_shl_details.dart`** — ✅ **DONE**  
  *Master Details Page Shell (`DyShlDetails`). Frames `PageHeader` $\rightarrow$ 16px $\rightarrow$ `DynamicActionBar` $\rightarrow$ 16px $\rightarrow$ `AnimatedSwitcher` view router across 4 views (`table`, `list`, `cards`, `board`).*
* **`page_form_canvas.dart`** — ✅ **DONE**  
  *2-pane form surface container (68% main form / 340px side pane, max 1400px width, bounded/unbounded scroll options).*

---

### 📁 `root/` — Frame & Shell Layouts
* **`dy_shell.dart`** — ⏳ **PENDING**  
  *App scaffold framing Level 0 sidebar and Level 1 content surface.*
* **`dy_module_tabs.dart`** — ⏳ **PENDING**  
  *Workspace tabs (48px height) with 2px progress bar & Ctrl+K search.*
* **`sidebar_nav.dart`** — ⏳ **PENDING**  
  *Native `shad.NavigationSidebar` wrapper with collapsible states.*

---

## 🧩 Architectural Component Mapping Summary

```
frontend/lib/dynamic_ai/
├── specs/
│   └── dy_grid_system.dart       [12-Column & Viewport Ratio System]
│
├── micro/
│   ├── dy_micro_button.dart      [DAB 34px Filter Button]
│   ├── dy_pagination_row.dart    [Standalone 44px Pagination Footer]
│   ├── dy_page_tabs.dart         [Context Tab Switcher Bar]
│   ├── cards/
│   │   ├── dy_list_item.dart     [List Item Card Tile]
│   │   ├── dy_grid_card.dart     [Grid Card Tile]
│   │   └── dy_kanban_item.dart   [Kanban Card Tile]
│   └── dab/
│       └── dab_submodule_pop.dart [Submodule Popover Menu]
│
├── page/
│   ├── dy_header.dart            [Page Header Bar]
│   ├── dy_action_bar.dart        [Dynamic Action Bar Toolbar]
│   ├── dy_table_pane.dart        [Dense Table View Pane]
│   ├── dy_list_pane.dart         [Master List View Pane]
│   ├── dy_card_pane.dart         [Cards Grid View Pane]
│   ├── dy_kanban_pane.dart       [Kanban Stage Column Pane]
│   └── dy_details_pane.dart      [Detail Surface Card Inspector]
│
└── shells/
    ├── dy_shl_details.dart       [Master Details Shell View Router]
    └── page_form_canvas.dart     [2-Pane Form Surface Shell]
```
