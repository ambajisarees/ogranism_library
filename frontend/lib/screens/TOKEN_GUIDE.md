# Ambaji Sarees ERP: Master System Token Guide

This guide documents the native **`shadcn_flutter`** design tokens used throughout the **Ambaji Sarees ERP** frontend codebase. It serves as an authoritative reference for both human developers and AI pair programming agents.

---

## 1. Color System Tokens (`shad.Theme.of(context).colorScheme`)

Always access colors dynamically via `colors = theme.colorScheme` to ensure 100% Light / Dark theme responsiveness. Never hardcode raw hex colors or Material colors.

### Core Semantic Colors

| Token Name | Light Mode Value | Dark Mode Value | Semantic Role & UI Application |
| :--- | :--- | :--- | :--- |
| **`colors.background`** | `#FFFFFF` | `#020817` | Main scaffold page background behind all content containers. |
| **`colors.foreground`** | `#020817` | `#F8FAFC` | Primary text color, main titles, headings, and high-contrast icons. |
| **`colors.card`** | `#FFFFFF` | `#020817` | Background surface for `shad.Card`, `shad.Button.card`, and floating panels. |
| **`colors.cardForeground`** | `#020817` | `#F8FAFC` | Primary body text rendered inside card containers. |
| **`colors.popover`** | `#FFFFFF` | `#020817` | Background for floating popover menus, tooltips, and select dropdowns. |
| **`colors.popoverForeground`** | `#020817` | `#F8FAFC` | Text color inside floating popovers and dropdown popups. |
| **`colors.primary`** | `#0F172A` | `#F8FAFC` | Brand primary color (primary action buttons, active tab indicators, primary badges). |
| **`colors.primaryForeground`** | `#F8FAFC` | `#0F172A` | High-contrast text & icon color rendered ON TOP of `primary` background. |
| **`colors.secondary`** | `#F1F5F9` | `#1E293B` | Secondary action button background, secondary chips, and inactive tabs. |
| **`colors.secondaryForeground`** | `#0F172A` | `#F8FAFC` | Text & icon color rendered ON TOP of `secondary` background. |
| **`colors.muted`** | `#F1F5F9` | `#1E293B` | Neutral background for table headers, disabled fields, and neutral chips. |
| **`colors.mutedForeground`** | `#64748B` | `#94A3B8` | Subtitles, helper text, placeholders, table column labels, and inactive icons. |
| **`colors.accent`** | `#F1F5F9` | `#1E293B` | Interactive hover highlights on table rows and list pane selections. |
| **`colors.accentForeground`** | `#0F172A` | `#F8FAFC` | Foreground text on interactive hover/focus states. |
| **`colors.destructive`** | `#EF4444` | `#7F1D1D` | Error badges, delete buttons, and critical warning alerts. |
| **`colors.destructiveForeground`** | `#F8FAFC` | `#F8FAFC` | Text & icon color ON TOP of `destructive` background. |
| **`colors.border`** | `#E2E8F0` | `#1E293B` | 1px border stroke for card containers, module buttons, and table gridlines. |
| **`colors.input`** | `#E2E8F0` | `#1E293B` | Border stroke color for text entry fields (`shad.TextField`). |
| **`colors.ring`** | `#020817` | `#CBD5E1` | Focus ring indicator outline when focused via keyboard navigation. |

### Static Palette Tokens (`shad.Colors`)
- **`shad.Colors.transparent`**: `#00000000` (Used for ghost buttons, clean padding overlays).
- **Tailwind Color Swatches**: `shad.Colors.slate`, `gray`, `zinc`, `stone`, `amber`, `emerald`, `blue`, `indigo`, `rose` (shades `50` to `950`).

---

## 2. Typography Tokens (`shad.Theme.of(context).typography`)

Typography tokens scale dynamically with `theme.scaling`.

| Typography Token | Font Size (at scaling=1.0) | Default Weight | Common ERP Use Case |
| :--- | :--- | :--- | :--- |
| **`typography.h1`** | $32\text{px}$ / $36\text{px}$ | `FontWeight.bold` ($700$) | Dashboard main title / Hero banner. |
| **`typography.h2`** | $24\text{px}$ / $28\text{px}$ | `FontWeight.bold` ($700$) | Module Landing Page Titles (`Cutting`, `Purchase Bills`). |
| **`typography.h3`** | $20\text{px}$ | `FontWeight.w600` ($600$) | Section Headers, Side Card Titles. |
| **`typography.h4`** | $16\text{px}$ | `FontWeight.w600` ($600$) | Sub-section headers, Dialog titles. |
| **`typography.p`** | $14\text{px}$ | `FontWeight.normal` ($400$) | Standard paragraph body text. |
| **`typography.textSmall` / `small`**| $14\text{px}$ | `FontWeight.w500` ($500$) | Button text, table row cell text, form labels. |
| **`typography.textMuted`** | $14\text{px}$ | `FontWeight.normal` ($400$) | Secondary table columns, muted captions. |
| **`typography.xSmall`** | $10\text{px}$ – $12\text{px}$ | `FontWeight.bold` ($700$) | Status pills, count badges, micro data tags. |
| **`typography.mono`** | $13\text{px}$ Monospace | `FontWeight.normal` ($400$) | Voucher Numbers (`VNO`), CNO, Amounts, Code IDs. |

---

## 3. Padding & Layout Density System (`shad.Theme.of(context).density`)

`shadcn_flutter` separates padding into **Container Padding** (cards/dialogs) and **Content Padding** (buttons/fields).

### Base Density Tokens (Default Density)
- **`theme.density.baseContainerPadding`**: $16\text{px}$
- **`theme.density.baseContentPadding`**: $16\text{px}$
- **`theme.density.baseGap`**: $8\text{px}$

### Multiplier Constants
- **`shad.padX2s`**: $0.25 \times \text{base}$ ($~4\text{px}$)
- **`shad.padXs`**: $0.50 \times \text{base}$ ($~8\text{px}$)
- **`shad.padSm`**: $1.00 \times \text{base}$ ($~16\text{px}$)
- **`shad.padMd`**: $1.50 \times \text{base}$ ($~24\text{px}$)
- **`shad.padLg`**: $2.00 \times \text{base}$ ($~32\text{px}$)
- **`shad.padXl`**: $2.50 \times \text{base}$ ($~40\text{px}$)

### Button Size Multipliers
- **`shad.ButtonSize.small`**: $0.75 \times$ content padding.
- **`shad.ButtonSize.normal`**: $1.00 \times$ content padding.
- **`shad.ButtonSize.large`**: $1.25 \times$ content padding.

### Standard Padding Equation in Code:
```dart
EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * shad.padSm)
```

---

## 4. Gaps & Spacing (`shad.DensityGap`)

Always use **`shad.DensityGap(...)`** or `DensityRow` / `DensityColumn` instead of raw `SizedBox` for automatic density scaling.

| Gap Token | Multiplier | Pixel Distance (at scaling=1.0) | Standard Usage |
| :--- | :--- | :--- | :--- |
| **`shad.gapXs`** | $0.5 \times \text{baseGap}$ | $4\text{px}$ | Micro gap between icon and tiny badge text. |
| **`shad.gapSm`** | $1.0 \times \text{baseGap}$ | $8\text{px}$ | Standard gap between button icon and label text. |
| **`shad.gapMd`** | $1.5 \times \text{baseGap}$ | $12\text{px}$ | Medium gap between adjacent buttons in action rows. |
| **`shad.gapLg`** | $2.0 \times \text{baseGap}$ | $16\text{px}$ | Large gap between section headers and metrics cards. |
| **`shad.gapXl`** | $2.5 \times \text{baseGap}$ | $20\text{px}$ | Extra large gap between distinct layout columns. |

---

## 5. Surfaces, Borders & Corner Radii (`shad.Theme.of(context)`)

### Corner Radius Tokens
- **`theme.radiusSm`**: $4\text{px}$ (Small input fields, tooltips).
- **`theme.radiusMd`**: $6\text{px}$ (Standard buttons, dropdown menus).
- **`theme.radiusLg`**: $8\text{px}$ (Standard dialogs, side panels).
- **`theme.radiusXl`**: $16\text{px}$ (Module switcher cards, floating header bars).
- **`theme.radiusFull`**: $9999\text{px}$ (Pill badges, avatar circles).

### Standard Button Render Heights

| Button Control Style | Spec Multipliers | Rendered Height | Notes |
| :--- | :--- | :--- | :--- |
| **Header Standard Button** (`OutlineButton` / `PrimaryButton`) | `EdgeInsets.symmetric(horizontal: 16px, vertical: 8px)` | **$38\text{px}$** | Used for header actions (`Print`, `Export`, `Add`). |
| **Module Switcher Card** (`Button.card`) | `EdgeInsets.symmetric(horizontal: 16px, vertical: 8px)` | **$38\text{px}$** | Matches Export button specs exactly with card surface background (`colors.card`). |
| **Compact Action Button** | `ButtonSize.small` (`padXs`) | **$30\text{px}$** | Used inside dense table row actions. |

---

## 6. Desktop Ergonomics & Layout Architecture

1. **Header Layout Rule**:
   - Title: `PageHeader` title ($24\text{px}$ bold `h2`).
   - Module Switcher: Native `Button.card` controls.
   - Actions Row: Single `PageHeader.actions` array (max 1 Primary, 2 Secondary buttons).
2. **Table Density**:
   - Table Row Height: $36\text{px}$ to $40\text{px}$.
   - Table Column Header: `colors.muted` background with `colors.mutedForeground` text.
3. **Keyboard Focus Ring**:
   - Focus outline: $2\text{px}$ stroke with `colors.ring`.
