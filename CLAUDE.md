# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Ambaji Sarees ERP** — a textile manufacturing ERP replacing a legacy MSSQL system (AMAZE/Empire). It is a single-developer, desktop-first app for factory floor managers and accountants.

- **`/frontend`**: Flutter app (Windows Desktop primary target, Web secondary). All active development happens here.
- **`/backend`**: Supabase (Postgres 17) schema definitions, schema audit docs, and Edge Functions (Deno/TypeScript). No standalone Python server is run day-to-day — `backend/app/sync_engine.py` and the FastAPI mentions in `README.md` are legacy/future scaffolding, not the current data path.
- **Data pipeline**: Legacy MSSQL → Airbyte → Supabase (`sq_*` tables), one-way sync only.

## Commands

All frontend commands run from `frontend/`.

```powershell
flutter pub get                # install dependencies
flutter run -d windows          # run as Windows desktop app (primary dev target)
flutter run -d chrome           # run in browser
flutter analyze                 # static analysis / lint (uses flutter_lints via analysis_options.yaml)
flutter build windows           # production Windows build
```

There is no automated test suite (`frontend/test/` is empty) — verification is manual, by running the app.

Backend/Edge Functions live in `backend/supabase/functions/*/index.ts` (Deno). There is no local `supabase/config.toml` — functions are deployed via the Supabase dashboard/CLI directly against the project, not run locally.

## Architecture

### Two-schema Supabase model
- **`IMMBE2627`** is the only schema new work targets (current fiscal year, 2026-27). A frozen `IMMBE2526` mirror exists for read-only legacy-year lookups.
- **`sq_*` tables** are Airbyte-managed mirrors of the legacy MSSQL system — **never insert/update/add FK constraints on them**, they get overwritten by sync.
- **`sb_*` tables** are Supabase-native (app-owned) tables for new features (e.g. media library, cutting cards).
- **Views**: prefer `vwsq_`/`sq_vw_` (SQL mirror views) and `sb_vw_` (Supabase-native views) over querying raw `sq_` tables directly.
- **Writes**: all mutations go through **Edge Functions** (`backend/supabase/functions/`) called via `_db.client.functions.invoke(...)`, never direct `.insert()`/`.update()` from Flutter, since business writes are batch/transactional across multiple legacy tables.

### The legacy voucher system
The business domain is built around ~73 legacy "voucher module" codes (e.g. `P1` Grey Purchase, `O5` Job Work Dispatch, `S1` Finish Sales) defined in `frontend/lib/constants/legacy_constants.dart` and fully documented in [docs/history/legacy_modules_guide.md](docs/history/legacy_modules_guide.md). Key rules that apply everywhere this data is touched:
- **Join rule**: header/detail joins must always include all three of `CNO = DETAIL.CNO AND VNO = DETAIL.VNO AND TYPE = DETAIL.TYPE` — omitting `TYPE` causes row explosions (fan-out) since `VNO` resets per series per fiscal year.
- **Pendency rule**: a record is "pending"/open when `CLOSED IS NULL OR CLOSED = '' OR CLOSED = 'N'`.
- **Settlement**: `sq_RECPAY` links receipts to invoices via `BILLVNO/BILLTYPE` ↔ `RECVNO/RECTYPE`; a bill is outstanding if summed `sq_RECPAY` payments < `sq_BILLS.finalamt`.
- **Fiscal year VNO prefixes**: carried-forward records use `VNO` prefixes (`10` = FY26-27 carry, `20` = FY27-28); filter current-year-only queries with e.g. `VNO < 1000000`.
- Before building against any `sq_*`/`sb_*` table, check its audit doc in `backend/schema_docs/` (organized `01_constants` → `06_media`) for null rates and type mappings — this is the mandatory "Audit-First" workflow (see [docs/architecture/architecture_pattern_guide.md](docs/architecture/architecture_pattern_guide.md)).

### Frontend structure
- `lib/config/` — Supabase client config.
- `lib/constants/legacy_constants.dart` — voucher/series code maps.
- `lib/models/model_*.dart` — immutable data classes (`final` fields, `@immutable`), always with a defensive `fromJson` (numeric fields parsed via `num?`/`tryParse`, never a raw `as double`/`as int` cast — Postgres/legacy data is inconsistently typed).
- `lib/services/service_*.dart` — one singleton per domain (`factory X() => _instance`), wrapping `SupabaseService.client`. Reads use `.schema('IMMBE2627')` + `PaginatedResult`; writes call Edge Functions.
- `lib/screens/` — page-level `StatefulWidget`s, organized by domain subfolder (`masters/`, `production/`, `media/`, `admin/`, `auth/`). Screens import only the design-system barrel: `import '../../organism_design/index.dart';`.
- **Registry Screen Modularization (large screens >1,000 lines)**: Do not write monolithic screen files if complexity exceeds 1,000 lines. Instead, split the screen into a nested package folder under `lib/screens/<domain>/<feature>/` containing:
  - `[feature]_screen.dart` — main registry list and split-pane orchestrator.
  - `widgets/` folder containing:
    - `[feature]_form_state.dart` — local `ChangeNotifier` state class and concrete `[Feature]FormStateProvider` (`InheritedNotifier`) wrapper containing overlay inputs, text controllers, loaders, and real-time calculations. Access via `[Feature]FormState.of(context)`.
    - `[feature]_detail_canvas.dart` — read-only detail view showing timelines, metric tiles, and rolls list.
    - `[feature]_form_overlay.dart` — the create/edit composite dialog overlay.
    - `[feature]_lot_group.dart` / other helpers — sub-components supporting selection views.
- `lib/organism_design/` — the in-house component library (see below). Files inside it must **never** import `index.dart` — use direct relative imports (`../theme.dart`, `../cells.dart`) to avoid circular barrel imports.

Full patterns and copy-paste templates for models/services (including the "select all in A not in B" RPC pattern for bypassing PostgREST's 1000-row limit) are in [docs/architecture/architecture_pattern_guide.md](docs/architecture/architecture_pattern_guide.md).

### Organism Design System
A 6-layer atomic hierarchy in `lib/organism_design/` — compose from these, never raw `Container`/`Column` scaffolding when a component exists:

1. **Theme** — design tokens, accessed via `OrganismTheme.colorsOf(context)` (never hardcode colors), `OrganismTheme.spacingXs/Sm/Md/Lg/Xl`, and typography helpers (`.titleLarge(context)`, `.numericLarge(context)`, `.codeTabular(context)`).
2. **Plasma** — motion/overlays (`PlasmaDialog`, `PlasmaPopover`, `PlasmaToastManager`).
3. **Cells** — ~33 headless atoms (`CellButton`, `CellInput`, `CellInputNumber`, `CellBadge`, `CellCombobox`, `CellCheckbox`/`CellSwitch`, `CellStatusDot`, `CellFilterChip`, `CellListTile`, `CellGap`/`CellPad`).
4. **Tissues** — ~19 molecules (`TissueCard`(+`Header`/`Content`), `TissueFormField`, `TissueReadOnlyField`, `TissueListCard`, `TissueTabs`, `TissuePagination`, `TissueEmptyState`, `TissueMenu`, `TissueButtonBar`).
5. **Organs** — assembled blocks (`OrganPaneHeader`, `OrganPaneList`, `OrganSectionCanvas`, `NavBoat`).
6. **Systems** — page blueprints (`SystemAppMasterLayout` — the standard split-pane registry/detail workstation; `OrganAppShell` — top-level scaffold).

Every registry screen (list + detail split pane) follows one standard composition: a service singleton feeds `_items`/`_selected`/pagination state into `SystemAppMasterLayout(paneHeader:, paneList:, sectionCanvas:, ...)`. See the full template in [docs/architecture/architecture_pattern_guide.md](docs/architecture/architecture_pattern_guide.md) or `claude_skills/ambaji-erp-builder/SKILL.md`.

### File naming (mandatory)
- `model_*.dart`, `service_*.dart`, `screen_*.dart` — no standalone/ad-hoc widget files; domain-specific visual components belong in `organism_design/domain/`.

### Conventions
- Always check `if (!mounted) return;` after every `await` in a `StatefulWidget`.
- State management is plain `StatefulWidget` + service singletons — no Riverpod/Bloc.
- Keyboard shortcuts: `Ctrl+K` (command palette), `/` (search), `Esc`, `Ctrl+S` (save), `Alt+[1-9]` (tabs) are fair game. Never intercept `Ctrl+T/W/N/R`, `F5`, `Ctrl+F` (reserved OS/browser shortcuts).
- Icons are `lucide_icons_flutter` only — never Material Icons — in application UI.

### Where to look for more context
- [docs/history/legacy_modules_guide.md](docs/history/legacy_modules_guide.md) — full 73-module voucher reference, relational flow diagram, financial settlement logic.
- [docs/architecture/architecture_pattern_guide.md](docs/architecture/architecture_pattern_guide.md) — model/service/RPC code templates.
- `backend/schema_docs/` — per-table audit docs (null rates, distributions) — read before writing any query against a new table.
- `backend/analysis/*.md` — deeper narrative write-ups of the financial, material-flow, sales/jobwork, and operational pipelines.
- `docs/history/dev_log.md` — running changelog; also holds the canonical "Conventions & Rules" section at the bottom.
- `docs/plans/` — task briefs written by a planning pass (Claude) for build execution (Gemini/Antigravity IDE); check `docs/plans/README.md` for status of in-flight features.
- `claude_skills/ambaji-erp-builder/SKILL.md` and `.agents/workflows/flutter.md` — same content as this file's architecture section, packaged as an invokable skill/workflow.
