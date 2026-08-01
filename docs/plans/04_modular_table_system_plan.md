# Plan: Modular ERP Table System Architecture & Frozen Column Blueprint

> **Status**: APPROVED ARCHITECTURE PLAN  
> **Author**: Ambaji Sarees ERP Engineering  
> **Date**: 2026-08-01  
> **Target Component Folder**: `frontend/lib/dynamic_ai/micro/table/` & `dy_table_pane.dart`

---

## 🎯 1. Executive Summary & Purpose

This plan specifies the refactoring of our core Data Table engine (`dy_table_pane.dart`) from a single 1,584-line monolithic file into a modular, high-performance 7-component suite under `frontend/lib/dynamic_ai/micro/table/`.

It introduces:
1. **Frozen (Pinned) Column System**: Sticky left & right columns during horizontal scroll.
2. **3 Context-Driven Table Modes**: Read-Only View, Accordion Grouped Reports, and Fast Entry Grid.
3. **12-Column Flex Grid Integration**: Unified column allocation specs scaled to available screen width (`flex: 12`, `flex: 9`, `flex: 8`).

---

## 📐 2. Table Use Case Matrix

| Use Case Mode | Primary Flow / Domain | Rendering & Layout Behavior |
| :--- | :--- | :--- |
| **`READ_ONLY_VIEW`** | Master Detail View / Pipeline Screens (`DyShlDetails`) | Single-level table with optional line-item accordion expansion for lower row counts. Frozen left & right columns enabled. |
| **`ACCORDION_GROUPED`** | Reports, Summary Dashboards, Analytics | Grouped accordion rows by Party, Quality, or Status with collapsible section headers and aggregated sub-totals. |
| **`ENTRY_FORM_GRID`** | Form Canvas Add/Edit Lines (`PageFormCanvas`) | High-speed data entry table with focused keyboard navigation (`NumPad Enter`, `Tab`). |

---

## ❄️ 3. Frozen Column & Horizontal Scroll Specification

When total column width exceeds available container width:

```
┌───────────────────────────────┬─────────────────────────────────┬────────────────────────┐
│ FROZEN LEFT STACK (Pinned)    │ SCROLLABLE MIDDLE COLUMNS       │ FROZEN RIGHT (Pinned)  │
│ 1. Checkbox                   │ • Date                          │ • Actions / Status     │
│ 2. Voucher No (#CC-1041)       │ • Quality / Pattern             │                        │
│ 3. Party Name (Ambaji Mills)  │ • Quantity & Rate               │                        │
│ [1px Elevation Shadow Right]  │ (Scrolls Horizontally)          │ [1px Elevation Left]   │
└───────────────────────────────┴─────────────────────────────────┴────────────────────────┘
```

1. **Left Pin Stack**: `isPinnedLeft = true` pins columns 1 to 3 to the left viewport edge with a subtle 1px elevation shadow (`offset: Offset(1, 0)`).
2. **Right Pin Stack**: `isPinnedRight = true` pins the action button or status badge column to the right viewport edge with a subtle 1px elevation shadow (`offset: Offset(-1, 0)`).
3. **Middle Scroll Track**: Unpinned middle columns scroll horizontally inside a constrained `SingleChildScrollView`.

---

## 🏗️ 4. Modular File Directory Architecture (`micro/table/`)

```
frontend/lib/dynamic_ai/
├── page/
│   └── dy_table_pane.dart            [Master Table Controller & Layout Router (~300 LOC)]
│
└── micro/table/                      [NEW Table Sub-Component Suite]
    ├── dy_table_models.dart          [DynamicTableColumnSpec, DynamicTableRowData, PinState]
    ├── dy_table_header.dart          [Sticky Column Header Row & Sorting Triggers]
    ├── dy_table_row.dart             [Standard Data Row & 12-Column Cell Formatters]
    ├── dy_table_group_row.dart       [Grouped Accordion Header Row & Aggregations]
    ├── dy_table_expand_row.dart      [Line-Items Nested Expansion Details]
    ├── dy_table_summary_row.dart     [Sticky Summary Totals Footer]
    └── dy_table_gallery_modal.dart   [Fabric Image Gallery Popup Overlay]
```

---

## 🚀 5. Mac Resume Execution Steps

When resuming work on the MacBook Workstation:
1. Create `micro/table/` folder.
2. Extract models to `dy_table_models.dart`.
3. Extract `_FabricImageGalleryDialog` to `dy_table_gallery_modal.dart`.
4. Extract `_buildSummaryRow` to `dy_table_summary_row.dart`.
5. Extract standard data rows & frozen cells to `dy_table_row.dart`.
6. Extract group header accordion rows to `dy_table_group_row.dart`.
7. Extract sticky header row to `dy_table_header.dart`.
8. Refactor `dy_table_pane.dart` as lean master coordinator (~300 LOC).
9. Run `flutter analyze` to confirm **0 errors**.
