# Dynamic AI Component Engine: Master Reference Guide & Progress Tracker

This document serves as the authoritative, carbon-copy master specification and progress log for all **21 component files** within the `frontend/lib/dynamic_ai/` engine in **Ambaji Sarees ERP**.

---

## 📊 Standardization Progress Log

| Component # | File Path | Status | Standardized Specs Summary |
| :--- | :--- | :---: | :--- |
| **01** | [`micro_level/micro_button.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/micro_level/micro_button.dart) | ✅ **DONE** | Zero-shift contract, 34px DAB height, static label, semibold (`w600`) badge chip text in all states, 1.0px `colors.primary.withAlpha(153)` focus border. |
| **02** | [`page_level/page_header.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/page_header.dart) | ✅ **DONE** | Lean 1-row layout: `[onBack]` + `[Title + DocID Badge]` + `Spacer` + `[Trailing Actions]`. Module switcher and tabs removed to DAB/Context rows. |
| **03** | [`page_level/dynamic_action_bar.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dynamic_action_bar.dart) | ✅ **DONE** | 8-slot pipeline (`ViewSwitcher` → `ModuleSwitcher` → `Search` → `Filters` → `Date` → `Sort` → `Clear` → `3-Dots`). Left-aligned popovers (`bottomLeft`/`topLeft`), static labels, `"Fabric"` rename. |
| **04** | [`page_level/dynamic_dense_table.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dynamic_dense_table.dart) | ✅ **DONE** | Sticky Summary Row (`_buildSummaryRow`) matching Header specs 100%, dynamic compact height for <10 rows (`MainAxisSize.min`), 14px vertical summary padding. |
| **05** | [`micro_level/dynamic_pagination.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/micro_level/dynamic_pagination.dart) | ✅ **DONE** | Standalone surface-less row outside table card surface (`12px horizontal / 8px vertical padding`). Uses pure native `shad.Pagination` widget (`< Prev [1] 2 3 ... Next >`). |
| **06** | [`page_level/page_form_canvas.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/page_form_canvas.dart) | ⏳ **IN REVIEW** | 2-pane form surface container (68% main / 340px side pane, max 1400px width, bounded/unbounded scroll options). |
| **07** | [`page_level/dynamic_content_pane.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dynamic_content_pane.dart) | ⏳ **PENDING** | Surface card container with sticky header, flexible child body area, and optional sticky summary footer. |
| **08** | [`page_level/dynamic_list.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dynamic_list.dart) | ⏳ **PENDING** | Searchable sidebar master list pane with paginated list cards. |
| **09** | [`page_level/dynamic_list_card.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dynamic_list_card.dart) | ⏳ **PENDING** | Interactive item tile with hover effects and selection tinting. |
| **10** | [`page_level/report_card.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/report_card.dart) | ⏳ **PENDING** | KPI metric dashboard card with topic icon, values, and status chip. |
| **11** | [`page_level/create_page_layout.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/create_page_layout.dart) | ⏳ **PENDING** | Reference 2-column creation form layout (68% form / 32% side summary). |
| **12** | [`dab_widgets/dab_submodule_popover.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dab_widgets/dab_submodule_popover.dart) | ⏳ **PENDING** | Submodule switcher popover menu with live search. |
| **13** | [`dab_widgets/dab_party_popover.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dab_widgets/dab_party_popover.dart) | ⏳ **PENDING** | Multi-select supplier/party filter popover. |
| **14** | [`dab_widgets/dab_date_popover.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dab_widgets/dab_date_popover.dart) | ⏳ **PENDING** | Split-pane date range presets & calendar picker popover. |
| **15** | [`dab_widgets/dab_status_popover.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dab_widgets/dab_status_popover.dart) | ⏳ **PENDING** | Document status checklist popover (`PENDING`, `COMPLETED`). |
| **16** | [`dab_widgets/dab_filter_popover.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dab_widgets/dab_filter_popover.dart) | ⏳ **PENDING** | Searchable multi-select popover for Mill and Fabric criteria. |
| **17** | [`dab_widgets/dab_overflow_popover.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/dab_widgets/dab_overflow_popover.dart) | ⏳ **PENDING** | Three-Dots action popover (Export, Column Visibility, Density). |
| **18** | [`root_level/dynamic_shell.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/root_level/dynamic_shell.dart) | ⏳ **PENDING** | App scaffold framing Level 0 sidebar and Level 1 content surface. |
| **19** | [`root_level/header_tabs.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/root_level/header_tabs.dart) | ⏳ **PENDING** | Workspace tabs (48px height) with 2px progress bar & Ctrl+K search. |
| **20** | [`root_level/sidebar_nav.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/root_level/sidebar_nav.dart) | ⏳ **PENDING** | Native `shad.NavigationSidebar` wrapper with collapsible states. |
| **21** | [`demo/nav_rail.dart`](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/demo/nav_rail.dart) | ⏳ **PENDING** | Slim fallback navigation rail for compact screen sizes. |

---

## 🛠️ Comprehensive Component Specifications

### 1. `MicroButton` (`micro_level/micro_button.dart`)
- **Role**: Universal 34px height action card / filter button control across `PageHeader`, `DynamicActionBar` (DAB), and popovers.
- **Zero-Shift Contract**: Label text is static (`"Party"`, `"Fabric"`, `"Mill"`, `"Status"`, `"Date"`). Selection count updates exclusively inside the badge chip.
- **Badge Chip Specs**:
  - Unselected state: Displays `0` with `SecondaryBadge` and `colors.mutedForeground` text (`FontWeight.w600`).
  - Selected state: Displays count (e.g. `2`) with `PrimaryBadge` and `colors.foreground` text (`FontWeight.w600`).
- **Focus Machine**: Focus node wrapped in Focus nullifier (`canRequestFocus: false`) so focus outlines paint exclusively on the 1.0px outer card border (`colors.primary.withAlpha(153)`).

### 2. `PageHeader` (`page_level/page_header.dart`)
- **Role**: Clean 1-row top header container with 3 operational modes (`standard`, `adding`, `editing`).
- **Composition**: `Row` $\rightarrow$ `[onBack]` + `[Title Text + DocID Badge]` + `Spacer` + `[Trailing Actions]`.
- **Specs**: Title uses `theme.typography.h2` (bold, letterSpacing: -0.5), document ID uses `shad.SecondaryBadge` with `theme.typography.mono` (12px).

### 3. `DynamicActionBar` (`page_level/dynamic_action_bar.dart`)
- **Role**: High-density 34px toolbar implementing the 8-Slot Pipeline:
  1. `ViewSwitcher`
  2. `ModuleSwitcher`
  3. `Search` (Mandatory)
  4. `Filters` (`Party`, `Mill`, `Fabric`, `Status`)
  5. `Date`
  6. `Sort`
  7. `Clear All`
  8. `Trailing 3-Dots Menu` (Pinned right)
- **Start Alignment Contract**: All filter popovers use `anchorAlignment: Alignment.bottomLeft` and `alignment: Alignment.topLeft` flush to the trigger left edge.

### 4. `DynamicDenseTable` (`page_level/dynamic_dense_table.dart`)
- **Role**: Desktop data grid component with sticky headers, checkbox selection, expandable sub-rows, and summary calculation footer row.
- **Sticky Summary Row**: Matches Header specs 100% (`defaultHeaderFooterBg`, `1px colors.border`, 16px horizontal / 14px vertical padding, column-by-column totals alignment).
- **Dynamic Height**: When `rows.length < 10`, renders at dynamic compact minimum height (`MainAxisSize.min`). When `rows.length >= 10`, expands to full available height (`Expanded`).

### 5. `DynamicPagination` (`micro_level/dynamic_pagination.dart`)
- **Role**: Standalone surface-less pagination row designed to sit outside table/list card containers.
- **Composition**: `Padding(horizontal: 12, vertical: 8)` $\rightarrow$ `Row` $\rightarrow$ `[Start: Status Text]` + `Spacer` + `[End: Native shad.Pagination]`.
- **Page Control**: Uses official `shadcn_flutter` native `shad.Pagination(page: effectivePage, totalPages: totalPages, maxPages: 3)`.

---

## 💡 Notes for LLM Interactive Reviews
When reviewing components step-by-step with the user:
1. Present **Role & Purpose**, **Widget Hierarchy**, **Native Tokens & Specs**, **Parameters Table**, and **Behavioral States**.
2. Keep component updates aligned with the **Zero-Shift Contract** and **Native Token Strictness**.
3. Execute automatic Hot Restart (`R`) immediately after any code changes.
