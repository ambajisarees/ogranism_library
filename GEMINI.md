# Ambaji Sarees ERP: Master AI Developer Rules

## 1. Environment & Stack
- **Stack**: Flutter (Windows Desktop primary / Web secondary), Supabase (Postgres 17, `IMMBE2627` schema).
- **Core Commands**: `flutter run -d windows`, `flutter analyze`
- **Data Source**: MSSQL (AMAZE) → Airbyte → Supabase (`IMMBE2627` schema).
  - *Gotchas*: `sq_` tables are Airbyte-managed mirrors and **Strictly Read-Only**. Never add foreign key constraints or write directly to `sq_` tables.
- **SDK Stability Rule**: **NEVER run `flutter upgrade`** or mutate locked Flutter/Dart SDK dependencies unless explicitly requested by the user.

## 2. UI Architecture & `shadcn_flutter` System Strictness
- **Native Token Strictness**: WHENEVER WRITING NEW MODULES AND CODE FILES, ALWAYS USE NATIVE SHADCN COLOR TOKENS, NATIVE DENSITY MULTIPLIERS FOR TRUE RESPONSIVENESS, AND NATIVE TYPOGRAPHY TOKENS. also, if a particular dart code is more than 1000 lines of code, its a better strategy to divide them into sub files based on context.
- **Pure Native `shadcn_flutter` First**: Always inspect native `shadcn_flutter` component parameters and use `ComponentThemeData` (e.g., `shad.TabPaneTheme`, `shad.OutlinedContainerTheme`, `shad.NavigationSidebarTheme`).
- **No Ad-Hoc Container Wrappers**: Never wrap native `shadcn_flutter` components in custom Flutter `Container`s, custom `BoxDecoration`s, or hardcoded offsets when native theme tokens exist.
- **NavigationItem Label Strictness**:
  - `label:` MUST be a pure `Text(label)` widget in `shad.NavigationItem` and `shad.NavigationButton`.
  - Never pass `Row` or complex widgets into `label:`—`shadcn_flutter` invokes `.xSmall()` on `label!`, which throws null check exceptions if `label` is not a `Text` widget.
- **Sidebar Sliver Contract**:
  - All children passed to `shad.NavigationSidebar` (`header`, `children`, `footer`) MUST be native `AbstractNavigationButton` instances (`shad.NavigationItem` or `shad.NavigationButton`).
  - Section headers MUST be rendered as disabled `shad.NavigationItem(enabled: false, label: Text(...), child: SizedBox.shrink())`.

## 3. Desktop Ergonomics & Multi-Monitor Rules
- **Window Positioning**: Keep `WindowOptions(center: false)` in `main.dart` with flexible sizes (`Size(1280, 800)` / `minimumSize: Size(1024, 700)`). This prevents the app window from snapping away from the user's laptop screen onto an external monitor during Hot Restarts (`R`).
- **Top Header Line Layout**:
  - House session utilities (Global `Ctrl+K` Search, Notifications Bell, Light/Dark Theme toggle, User Profile Popover) inside `shad.TabPane`'s native `trailing` header row.
  - This keeps the sidebar focused 100% on module navigation (`MASTERS`, `PIPELINE`, `SALES`) and saves vertical real estate for full-height data tables.

## 4. Database Rules & Fiscal Logic
- **Schema Context (FY 26-27)**: Target `IMMBE2627` schema for all current fiscal year queries.
- **Reads vs Writes**: Read from aggregated `vwsq_` views where possible. Use Edge Functions (`_db.client.functions.invoke(...)`) for batch transactional writes.
- **Header-Detail Joins**: Header-detail joins MUST always include all three keys: `CNO = DETAIL.CNO AND VNO = DETAIL.VNO AND TYPE = DETAIL.TYPE`. Omitting `TYPE` causes row explosion fan-outs.
- **Pendency Rule**: Pending status evaluates to `CLOSED IS NULL OR CLOSED = '' OR CLOSED = 'N'`.
- **Fiscal Context (VNO Prefixes)**: Force current year queries with `VNO < 100000`. Carried records use prefix sequences (e.g., `10` or `20`).

## 5. Coding Instructions & Flutter Best Practices
- **Strict Typing**: Minimize `dynamic` variables. Avoid `!` force-unwrapping; use sensible defaults (`?? 0.0`, `?? 'N/A'`).
- **Async Safety**: Always check `if (!mounted) return;` after any `await` call in `StatefulWidget`s before invoking `setState`.
- **File Naming Standards**:
  - Core Canonical Models (`sq/` & `sb/`): `sq_<table_name>.dart` or `sb_<table_name>.dart`
  - Core Canonical Services (`sq/` & `sb/`): `sq_<table_name>_service.dart` or `sb_<table_name>_service.dart`
  - Module Data Models: `mdl_<module_short_name>.dart` (e.g., `mdl_po.dart`)
  - Module Services: `srv_<module_short_name>.dart` (e.g., `srv_po.dart`)
  - Module Screen Containers: `scr_<module_short_name>_landing.dart` (e.g., `scr_po_landing.dart`)
  - Module Sub-Widgets: `scr_<module_short_name>_<widget_name>.dart` (e.g., `scr_po_action_pane.dart`, `scr_po_list_pane.dart`, `scr_po_detail_canvas.dart`)

## 6. Standard Operation Workflow
1. **Data Audit First**: Profile target tables/views (checking null rates in `backend/schema_docs/`) before writing UI code.
2. **Draft Plan**: Outline an `implementation_plan.md` mapping audited SQL/services to the `shadcn_flutter` UI layout.
3. **Layered Execution**: Data Models → Supabase Service Layer → Screen Composition.
4. **Token & Native Component Review**: Audit every new file to ensure native color scheme tokens, density scaling multipliers, typography tokens are used, and zero ad-hoc container wrappers.
5. **Verification**: Run `flutter analyze` to ensure zero compilation or static analysis warnings.

## 7. Keyboard & Desktop Shortcuts
- **ERP Productivity**: Design for keyboard-focused entry: `Ctrl+S` (Save), `Alt+[1-9]` (Quick Workspace Tabs), `NumPad Enter` (Data Entry).
- **Global Shortcuts**: `Ctrl+K` for command palette search.
- **Forbidden Overrides**: Never hijack browser/OS system shortcuts (`Ctrl+T`, `Ctrl+W`, `Ctrl+R`, `F5`, `Ctrl+F`).

## 8. Code Review & Quality Assurance Instruction
- **Mandatory Native Token Audit**: Before presenting code or declaring a task complete, verify that:
  - Color tokens use `shad.Theme.of(context).colorScheme` (`colors.border`, `colors.card`, `colors.primary`, `colors.mutedForeground`, etc.) instead of hardcoded `Color(...)` or raw Material colors.
  - Density multipliers use `theme.density.baseContainerPadding * theme.scaling` and native `shad.DensityGap`.
  - Typography tokens use `theme.typography.h2`, `theme.typography.mono`, `theme.typography.textSmall`, `theme.typography.xSmall`.
  - Only native `shadcn_flutter` controls (`shad.Card`, `shad.OutlinedContainer`, `shad.Button`, `shad.Badge`, `shad.Checkbox`, `shad.TextField`, etc.) are used for building UI scaffolding.

## 9. Master Architecture Strategy & Naming Conventions (`mns`)
- **Core Layer Architecture**:
  - **Canonical Models** (`lib/models/core/sq/` & `lib/models/core/sb/`): 1 file per Supabase table (`sq_<table_name>.dart` or `sb_<table_name>.dart`).
  - **Canonical Services** (`lib/services/core/sq/` & `lib/services/core/sb/`): 1 singleton service per Supabase table (`sq_<table_name>_service.dart` or `sb_<table_name>_service.dart`).
- **Dynamic AI Reusable Component Engine** (`lib/dynamic_ai/components/`):
  - Generic, highly-configurable UI engines (`DynamicDenseTable`, `DynamicActionBar`, `DynamicFilterBar`, `DynamicDetailCanvas`, `DynamicFormModal`) that handle 90% of UI rendering globally.
- **Lean Module File Structure (3–5 Files per Module)**:
  - `scr_<mns>_landing.dart` (Main screen container, active category state, view mode router).
  - `scr_<mns>_detail_canvas.dart` (Detail inspection canvas & line-items table).
  - `scr_<mns>_form_dialog.dart` (Add / Edit entry dialog modal).
- **Module Short Name Abbreviation Mapping (`mns`)**:
  - `po` $\rightarrow$ Purchase Orders
  - `pb` $\rightarrow$ Purchase Bills
  - `mp` $\rightarrow$ Mill Programs
  - `mr` $\rightarrow$ Mill Receipts
  - `cc` $\rightarrow$ Cutting Cards
  - `so` $\rightarrow$ Sales Orders

## 10. Multi-Agent Domain Scoping & Core Escalation Protocol
- **Master Chat Channel (Master Orchestrator)**: Target Conversation ID: **`f930e306-3b6b-43c2-ac2b-ddb8915f484b`** (System Architect & Core Guardian).
- **Domain Boundaries**:
  - Module Chat Windows (Tabs) are **STRICTLY BOUND** to `frontend/lib/screens/production/<module>/`, `frontend/lib/models/production/mdl_<mns>.dart`, and `frontend/lib/services/production/srv_<mns>.dart`.
  - Shared Core Layers (`lib/models/core/`, `lib/services/core/`, `lib/dynamic_ai/`) are **READ-ONLY** for module chat windows.
- **Core Mutation Protocol**:
  - Module chat windows request core updates by sending a message to Master Orchestrator (`f930e306-3b6b-43c2-ac2b-ddb8915f484b`) via `send_message`.
## 11. Graphify Knowledge Graph Rules & Context Search
- **Mandatory Graph-First Context Search**: Before doing raw file greps or asking architectural questions about component relationships, inspect `graphify-out/graph.json` via `graphify query "<question>"` or `graphify explain "<concept>"`.
- **Relationship Tracing**: Use `graphify path "<ConceptA>" "<ConceptB>"` to trace dependencies and call chains between models, services, dynamic AI widgets, and `shadcn_flutter` controls.
- **Keep Graph Current**: Whenever modifying codebase files in a session, WHEN USER SAYS GOODBYE, THEN RUN GRAPHIFY UPDATE
