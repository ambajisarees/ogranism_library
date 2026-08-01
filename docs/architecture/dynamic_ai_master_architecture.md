<!--
================================================================================
USER ORIGINAL PROMPT & VISION DIRECTIVE (ARCHIVED REFERENCE)
================================================================================
Let us first understand the intent of every module page
pageheader complusory (primary actions like add page, secondary actions like print export modals etc)
context tabs (optional) (primary subpage navigation intent) - Dashboard, Details, Tasks, Reports etc all having different views and composition of various components
then comes our dab (dashboard and tasks most probably will not have this) (details and reports will have this) 
dab will enable content area and view level changes like filtering, sorting, submodules, searching etc)
our view switcher is also brilliant, it will just change the user preffered view like Tables, List, Cards, Board, Timeline, Calendar etc
we will have this logic plus details page, add/edit page etc. for every page, content area will be customizable.

create an action plan to identify dynamic ai components divide them into subfolders like
shells - all our different page types, all screens like details, add, pages (will be ux placeholders for all our use cases)
root - our shell, sidenav and header tabs live here
page - contains all page level components that are customizable for every page like ddt, dab, dl, dlc, these are all fixed components
cpl and dcp and pfc what are these? where are they used? what i think is that components that have different widgets inside them and are customizable by page, we can define these more concretely once we have built a page end to end)
micro - like mb, or cards like rc, mc etc should all live here
we can use abbreviated subfolder names to house things. with this logic, all dab widgets should fall under micro folder/subfolder
do you agree? lets create a plan for this, imporve it and implement it in phases

for every active state switch on a page, we need to define native loading animation etc.

all subfolders should be inside dynamic ai and remove components subfolders.

we will wipe our demo screen completely, and build it using this logic step by step by fetching data from cc service and models, ergo completing all module functions inside a single home/demo.
================================================================================
-->

# Dynamic AI Master Architecture Plan & Implementation Roadmap

> [!NOTE]
> **User Original Directive**: Archived as HTML comments at the top of this file for reference.

## 🎯 Executive Summary & Philosophy

This document outlines the master architecture, intent hierarchy, directory restructuring, animation state machine, and phased execution strategy for the **Dynamic AI Engine** in **Ambaji Sarees ERP**.

Our core design philosophy balances **Enterprise Gold-Standard UX Patterns** (Linear, Stripe, Shadcn UI) with strict **Native `shadcn_flutter` Design System Tokens**.

---

## 🏛️ Page Intent & Component Composition Hierarchy

Every ERP module landing screen follows a predictable 4-tier intent hierarchy:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ TIER 1: PAGE HEADER (Compulsory)                                            │
│ - Primary Intent: Page Title, Context Badge, Primary CTA ("+ New Entry"),   │
│   Secondary Actions (Export, Print, Help) & Back Navigation.               │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER 2: CONTEXT TABS (Optional - Page Sub-Navigation)                        │
│ - Primary Intent: Navigates operational modes within the same module domain: │
│   [ Dashboard ]  [ Details / Records ]  [ Tasks ]  [ Reports ]               │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER 3: DYNAMIC ACTION BAR (DAB) (Tab-Specific: Details & Reports Tabs)     │
│ - Primary Intent: Content area & view-level queries:                        │
│   - ViewSwitcher (Table, List, Cards, Board, Timeline, Calendar)            │
│   - Submodule Selector, Search, Filter Popovers (Party, Mill, Fabric, Date),│
│     Sort & Trailing 3-Dots.                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER 4: DYNAMIC CONTENT AREA (Customizable View Area)                        │
│ - Primary Intent: Renders active view selection or subpage shell layout:     │
│   - Table Mode    --> DynamicDenseTable (DDT) + DynamicPagination (DP)     │
│   - List Mode     --> DynamicList (DL) + DynamicListCard (DLC)              │
│   - Form Mode     --> PageFormCanvas (PFC)                                  │
│   - Dashboard Mode--> ReportCard (RC) grid + Analytics Panes                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Abbreviated Directory Architecture (`frontend/lib/dynamic_ai/`)

We eliminate the extra `components/` level and reorganize into 4 lean, abbreviated subfolders directly under `dynamic_ai/`:

```
frontend/lib/dynamic_ai/
├── root/                       # App scaffolding & global workspace navigation
│   ├── dynamic_shell.dart       # Level 0 App scaffold framing sidebar & workspace tabs
│   ├── sidebar_nav.dart        # Native shad.NavigationSidebar wrapper
│   └── header_tabs.dart        # Workspace header tabs bar (48px) with Ctrl+K
│
├── shells/                     # Page-level UX shells / layout templates
│   ├── shl_module_landing.dart # Master module landing page shell
│   ├── shl_form_canvas.dart    # 2-pane form surface canvas (Form inputs + 340px summary)
│   ├── shl_detail_page.dart    # Master-detail inspection shell
│   └── shl_report_page.dart    # KPI dashboard & analytics shell
│
├── page/                       # Customizable page-level building block widgets
│   ├── dynamic_action_bar.dart # High-density 34px toolbar (DAB)
│   ├── dynamic_dense_table.dart# High-density desktop data grid (DDT)
│   ├── dynamic_list.dart       # Master list sidebar container (DL)
│   ├── dynamic_list_card.dart  # Interactive list item tile (DLC)
│   ├── page_header.dart        # Clean 1-row page title & action bar
│   └── dynamic_content_pane.dart # Elevated surface card with sticky header/footer (DCP)
│
└── micro/                      # Micro-controls, cards, popovers & triggers
    ├── micro_button.dart       # Zero-shift 34px action & filter button (MB)
    ├── dynamic_pagination.dart # Standalone surface-less native pagination (DP)
    ├── report_card.dart        # KPI metric dashboard card (RC)
    └── dab/                    # DAB-specific filter popovers & triggers
        ├── dab_party_popover.dart
        ├── dab_date_popover.dart
        ├── dab_status_popover.dart
        ├── dab_filter_popover.dart
        ├── dab_submodule_popover.dart
        └── dab_overflow_popover.dart
```

---

## 🔍 Clarifying CPL, DCP, and PFC

- **`PFC` (`shl_form_canvas.dart`)**: Form surface canvas framing primary inputs (68%) alongside a fixed 340px right summary/actions pane. Used in `.adding` / `.editing` modes.
- **`DCP` (`dynamic_content_pane.dart`)**: Surface card container framing a sticky header bar, scrollable body area, and optional sticky summary footer. Used for section containers and embedded panels.
- **`CPL` (`create_page_layout.dart`)**: Legacy form layout $\rightarrow$ Consolidated into `shl_form_canvas.dart`.

---

## ⚡ Native Animation & Loading State Architecture Guide

### 1. Intent & Action Loading Hierarchy

Different user interactions trigger distinct, non-conflicting visual loading indicators:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. TOP PROGRESS INDICATOR (shad.LinearProgressIndicator)                     │
│    - Trigger: Initial Module Page Load (Sidenav navigation),                │
│      PageTabs context tab switch (Details -> Reports), and Add/Edit mode.  │
│    - Status: [Future Work / Initial Module Load Handler]                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 2. IN-PLACE CONTENT SKELETON LOADING (Native shad.Skeleton)                 │
│    - Trigger: DAB Actions (Submodule switch, Search query input, Mill/Fabric│
│      filter changes, Status filter changes, Date range picker).             │
│    - Behavior: Content area stays in place; active view switches `isLoading` │
│      to true, replacing data rows/cards with native skeleton shimmer tiles. │
├─────────────────────────────────────────────────────────────────────────────┤
│ 3. VIEW MODE SWITCH TRANSITION (AnimatedSwitcher)                           │
│    - Trigger: DAB View Switcher (Table <-> List <-> Cards).                  │
│    - Behavior: 150ms `Curves.easeInOut` FadeTransition. Zero layout shift.   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 2. View-Specific Skeleton Loading Specifications

When DAB filters or search queries change, the active view mode renders in-place skeleton placeholders matching the exact geometry of live data:

#### A. Table View Mode (`DyViewTable`)
- **Skeleton Component**: `_buildSkeletonRow(context, theme, colors)`
- **Quantity**: 6 skeleton rows framed inside `shad.OutlinedContainer`.
- **Anatomy**: Animated `shad.Skeleton` rectangular bars with varying widths (`80px` for Voucher No, `160px` for Party Name, `120px` for Quality).

#### B. Cards View Mode (`DyViewCard`)
- **Skeleton Component**: `_buildSkeletonGrid(theme, colors)`
- **Quantity**: 6 skeleton cards arranged in identical `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320px)`.
- **Anatomy**: `Container` filled with `colors.muted.withAlpha(80)` and `colors.border` matching card surface bounds.

#### C. List View Mode (`DynamicList`)
- **Skeleton Component**: `_buildSkeletonList(theme, colors)`
- **Quantity**: 6 skeleton list item tiles (`340px` width).
- **Anatomy**: Compact rectangular tile placeholders matching `DynamicListItem` vertical geometry.

---

### 3. Execution Pattern for DAB Actions

```dart
void _onDabFilterChanged() {
  // 1. Trigger in-place content skeleton
  setState(() => _isContentLoading = true);

  // 2. Fetch or filter data asynchronously
  Future.delayed(const Duration(milliseconds: 300), () {
    if (!mounted) return;
    setState(() {
      _applyFilters();
      _isContentLoading = false; // 3. Cross-fade back to live content
    });
  });
}
```

---

## 🚀 Phased Implementation Roadmap

### **Phase 1: Folder Migration & Import Refactoring**
- Create `root/`, `shells/`, `page/`, `micro/` directories.
- Move component files into target subfolders and update all internal imports.
- Run `flutter analyze` to ensure **0 issues found**.

### **Phase 2: Modular Page Shells Standardization**
- Refactor `shl_module_landing.dart` as the unified master landing shell for all 30 ERP modules.
- Standardize Context Tabs routing and DAB integration contract.

### **Phase 3: Cutting Cards (`CC`) End-to-End Demo Reset**
- Wipe `demo_screen.dart` completely.
- Rebuild `demo_screen.dart` step-by-step using live Supabase data from Cutting Cards (`sq_cc` / `vwsq_cc`) service & data models.
