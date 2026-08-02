# ANTIRULES.md — Ambaji Sarees ERP: Anti-Patterns & Negative Coding Directives

> **Project**: Ambaji Sarees ERP (Flutter Windows/Web + Supabase Postgres 17)  
> **Purpose**: Definitive repository guidelines detailing **HOW NOT TO CODE**. Derived from user feedback, architecture decisions, static analysis audits, and UI refactoring lessons.

---

## 🚨 1. UI & `shadcn_flutter` Strictness Anti-Rules

### ❌ NEVER Wrap Native Components in Ad-Hoc Containers
- **ANTI-PATTERN**: Wrapping `shad.Button`, `shad.ButtonGroup`, `shad.Tabs`, or `shad.TextField` inside custom `Container`s with hardcoded `BoxDecoration`, hardcoded offsets, or ad-hoc margins.
- **CORRECT WAY**: Use pure native `shadcn_flutter` properties (`density`, `size`, `padding`) and component theme data (`ComponentThemeData`).

### ❌ NEVER Squeeze Unselected Buttons in Segmented Toggle Bars
- **ANTI-PATTERN**: Leaving `ButtonGroup` items unpadded or using `GhostButton` without background cards, causing icons and labels to collide tightly without clear interactive boundaries.
- **CORRECT WAY**: Use `MicroButton` for unselected items (with `colors.card` background fill and `colors.border` outline) and `shad.PrimaryButton` for the selected item, with an explicit `8px` horizontal inner padding token (`EdgeInsets.symmetric(horizontal: 8 * theme.scaling)`).

### ❌ NEVER Allow Unbounded Vertical Stretching in Headers
- **ANTI-PATTERN**: Placing `shad.ButtonGroup` inside a `Row` without a height cap, causing selected buttons to expand vertically and render tall/blocky.
- **CORRECT WAY**: Cap button groups and header controls with explicit height tokens matching header action baseline: `SizedBox(height: 36 * theme.scaling, child: shad.ButtonGroup(...))`.

### ❌ NEVER Pass Complex Widgets into `NavigationItem.label`
- **ANTI-PATTERN**: Passing `Row`, `Icon`, or complex layout widgets into `shad.NavigationItem(label: ...)`.
- **CORRECT WAY**: `label:` **MUST** be a pure `Text(label)` widget. `shadcn_flutter` invokes `.xSmall()` on `label!`, which throws null-check exceptions if `label` is not a `Text` widget.

### ❌ NEVER Cause Double-Border Overlaps
- **ANTI-PATTERN**: Nesting `shad.OutlinedContainer` inside `shad.ButtonGroup` or rendering `shad.Divider` directly above a card or table footer that already has an top border.
- **CORRECT WAY**: Let `ButtonGroup` handle outer and segmented border outlines natively.

---

## ⚡ 2. UX & Performance Anti-Rules

### ❌ NEVER Add Artificial `Future.delayed` Sleeping Latency
- **ANTI-PATTERN**: Inserting artificial `await Future.delayed(...)` delays during subpage switches (`Dash` $\leftrightarrow$ `Details` $\leftrightarrow$ `Reports` $\leftrightarrow$ `Tasks`) to mimic loading.
- **CORRECT WAY**: Keep execution 100% instant and wrap active subpage content in a 150ms `AnimatedSwitcher` cross-fade transition:
  ```dart
  AnimatedSwitcher(
    duration: const Duration(milliseconds: 150),
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,
    child: KeyedSubtree(
      key: ValueKey<int>(_contextTabIndex),
      child: _buildTabContent(theme),
    ),
  )
  ```

### ❌ NEVER Hardcode Raw Colors or Static Pixels
- **ANTI-PATTERN**: Using `Color(0xFF...)`, `Colors.blue`, or hardcoded static pixel calculations (`+ 12`) in screen layouts.
- **CORRECT WAY**: Always query `shad.Theme.of(context).colorScheme` (`colors.card`, `colors.border`, `colors.primary`, `colors.mutedForeground`) and scale layout metrics using `theme.scaling`.

---

## 🗄️ 3. Database & Fiscal Logic Anti-Rules

### ❌ NEVER Write Directly to `sq_` Tables
- **ANTI-PATTERN**: Adding foreign key constraints, writing `INSERT`/`UPDATE` queries, or modifying Airbyte `sq_` mirror tables.
- **CORRECT WAY**: `sq_` tables are **Strictly Read-Only**. Perform writes exclusively through Supabase Edge Functions (`_db.client.functions.invoke(...)`) targeting transactional `sb_` tables.

### ❌ NEVER Omit `TYPE` in Composite Joins
- **ANTI-PATTERN**: Joining header and detail records with only `CNO` and `VNO` (`CNO = DETAIL.CNO AND VNO = DETAIL.VNO`).
- **CORRECT WAY**: Composite header-detail joins **MUST ALWAYS** include all three keys: `CNO = DETAIL.CNO AND VNO = DETAIL.VNO AND TYPE = DETAIL.TYPE`. Omitting `TYPE` causes row explosion fan-outs across fiscal categories.

### ❌ NEVER Ignore Pendency Rules or Fiscal Prefixes
- **ANTI-PATTERN**: Evaluating pending items with `CLOSED = 'Y'` only, or querying carried records without prefix sequences.
- **CORRECT WAY**: Pending status evaluates to `CLOSED IS NULL OR CLOSED = '' OR CLOSED = 'N'`. Target `IMMBE2627` schema for FY 26-27 queries with `VNO < 100000`.

---

## 🛠️ 4. SDK & Code Architecture Anti-Rules

### ❌ NEVER Run `flutter upgrade`
- **ANTI-PATTERN**: Executing `flutter upgrade` or mutating locked Flutter/Dart SDK dependencies.
- **CORRECT WAY**: Keep SDK dependencies locked to ensure desktop runtime stability across workstations.

### ❌ NEVER Mutate Core Read-Only Layers from Module Tabs
- **ANTI-PATTERN**: Editing shared core layers (`lib/models/core/`, `lib/services/core/`, `lib/dynamic_ai/`) directly inside domain module tasks.
- **CORRECT WAY**: Request core architectural changes via Master Orchestrator channel (`f930e306-3b6b-43c2-ac2b-ddb8915f484b`).

### ❌ NEVER Declare Success Without Running Verification
- **ANTI-PATTERN**: Presenting code as complete right after editing without running static analysis or verifying compilation.
- **CORRECT WAY**: Always execute `flutter analyze` and ensure **0 errors and 0 warnings** before presenting results.
