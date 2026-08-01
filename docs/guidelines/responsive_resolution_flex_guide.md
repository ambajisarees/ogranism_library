# Ambaji Sarees ERP: Master Resolution, Flex, & Responsive Layout Guide

---

## 1. Executive Summary & Core Concepts

This guide defines the universal responsive layout rules, viewport resolution handling, and **Flutter `Flex` architecture** for the Ambaji Sarees ERP system across Windows Desktops, Laptops, Mac displays, and High-DPI Workstations & Tablets.

---

## 2. Logical Pixels vs Physical Pixels & OS Display Scaling

Flutter calculates layout strictly in **Logical Pixels** (`dp`), not physical hardware pixels:

$$\text{Logical Width} = \frac{\text{Physical Hardware Resolution}}{\text{Device Pixel Ratio (DPR) / OS DPI Scale}}$$

### 🖥️ Target Hardware Reference Matrix:

| Device Category | Physical Hardware | OS Scaling / DPR | Logical Viewport Width | Columns Fitted in 60% Grid Pane |
| :--- | :--- | :--- | :--- | :--- |
| **Standard Windows Desktop** | `1920 x 1080` (FHD) | 100% (1.0x) | **`1920px`** | **3 Columns** (320px cards) |
| **Windows Desktop (Scaled)** | `1920 x 1080` (FHD) | 125% (1.25x) | **`1536px`** | **2 Columns** (320px cards) |
| **Laptop Display** | `1920 x 1200` (FHD+) | 125% (1.25x) | **`1536px`** | **2 Columns** (320px cards) |
| **Mac Mini / 2K Monitor** | `2560 x 1440` (QHD) | 100% (1.0x) / 2.0x HiDPI | **`2560px` / `1280px`** | **4 Columns** (`2560px`) / **2 Columns** (`1280px`) |
| **High-Res Tablet (Landscape)**| `2944 x 1840` | 2.0x DPR | **`1472px`** | **2 Columns** (320px cards) |
| **High-Res Tablet (Portrait)** | `1840 x 2944` | 2.0x DPR | **`920px`** | *Collapses to Single Pane (< 1024px Rule)* |

---

## 3. The Mechanics of `Flex` in Flutter (`Expanded(flex: N)`)

Inside a horizontal `Row`, `Expanded(flex: N)` divides total available width proportionally:

$$\text{Child Width} = \left( \frac{\text{Child Flex}}{\sum \text{Flex}} \right) \times \text{Available Row Width}$$

### Example: Split View (`flex: 3` vs `flex: 2`)
Total Flex Sum = $3 + 2 = 5$

- **Left Grid Pane (`flex: 3`)**: Takes $\frac{3}{5} = 60\%$ of remaining screen width.
- **Right Details Pane (`flex: 2`)**: Takes $\frac{2}{5} = 40\%$ of remaining screen width.

---

## 4. Behaviour Breakdown Across Target Resolutions

### A. 1920px Logical Width (Standard Windows Desktop / Chrome)
- **Total Available Row Width**: `~1880px` (after sidebar & outer padding).
- **Left Grid Pane (`60%`)**: `~1128px`
  - Cards Grid (`maxCrossAxisExtent: 320px`): Fits **3 columns of 320px cards** (`3 x 320 = 960px` + 32px gaps + 136px extra margin).
- **Right Details Pane (`40%`)**: `~752px`
  - Generous width for 3-column metadata tiles, hero image, and line-item tables.

### B. 2560px Logical Width (Mac Mini 2K Monitor)
- **Total Available Row Width**: `~2520px`.
- **Left Grid Pane (`60%`)**: `~1512px`
  - Cards Grid (`maxCrossAxisExtent: 320px`): Fits **4 columns of 320px cards** (`4 x 320 = 1280px` + gaps).
- **Right Details Pane (`40%`)**: `~1008px`
  - Full desktop inspector view.

### C. High-Res Tablet (`2944 x 1840` @ 2.0x DPR = `1472 x 920` Logical)
- **Landscape Mode (`1472px` Wide)**:
  - **Left Grid Pane (`60%`)**: `~860px` $\rightarrow$ Fits **2 columns** of `320px` cards.
  - **Right Details Pane (`40%`)**: `~570px` $\rightarrow$ Touch-friendly inspection pane.
- **Portrait Mode (`920px` Wide)**:
  - Total width is $< 1024px$.
  - Split view ratio becomes cramped (`60%` = `550px`, `40%` = `360px`).
  - **Responsive Breakpoint Rule**: Automatically collapse split view into single pane!

---

## 5. Master Breakpoint & Responsive Rules

```
Viewport Width (Logical)
│
├── ≥ 1440px (Ultra-Wide / Desktop FHD):
│   └── Split View Ratio: 3:2 (60% Grid / 40% Details) -> 3-4 Grid Columns
│
├── 1024px – 1439px (Laptop / High-Res Tablet Landscape):
│   └── Fixed Master or 1:1 Split (660px Fixed Grid / Expanded Details) -> 2 Grid Columns
│
└── < 1024px (Tablet Portrait / Small Displays):
    └── Single Pane Mode (Full Grid View -> Tap card opens Full-Screen / Sheet Detail Pane)
```

---

## 6. Guidelines for Developer Implementation

1. **Never Hardcode Rigid Widths for Both Panes**:
   Always keep at least one pane `Expanded` so the layout reflows dynamically during window resizing.
2. **Combine Flex with `maxCrossAxisExtent`**:
   `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320 * theme.scaling)` inside `DyViewCard` ensures cards never stretch unnaturally—they seamlessly reflow from 2 to 3 to 4 columns as the flex pane widens.
3. **Obey Density Scaling**:
   Always multiply flex gap tokens and padding by `theme.scaling` (`16 * theme.scaling`).
