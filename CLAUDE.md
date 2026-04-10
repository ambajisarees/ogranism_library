# Claude Instructions — Ambaji Sarees ERP

---

## SESSION STARTUP — DO THIS EVERY TIME

1. Read `CLAUDE.md` (auto-loaded) — you are reading it now.
2. Read the relevant `external_files/CONTEXT_*.md` for the area being discussed.
3. Invoke the `brainstorming` skill for any new feature request.
4. Invoke the `writing-plans` skill to produce the implementation plan.
5. Update the File Index at the bottom of this file when new files are added.

---

## CLAUDE'S ROLE — PLANNER ONLY

Claude is the **architect and planner**. Claude does NOT write app code.
**Gemini Flash (Antigravity)** builds everything from the plans Claude produces.

Claude's job for every feature:
- Read project context deeply
- Brainstorm with the user → agree on design → write spec to `frontend/docs/superpowers/specs/`
- Write a step-by-step implementation plan to `frontend/docs/superpowers/plans/`
- Plans must be self-contained and detailed enough for Gemini Flash to execute with zero guidance
- Cover ALL layers: Supabase DDL/migrations, Edge Functions, models, services, screens, widgets

Plans must include:
- Exact file paths to create or modify
- **SQL:** Complete, exact, ready-to-run SQL for all Supabase DDL, migrations, and RPC functions
- **Dart:** Logic and guidance only — describe what the code must do, key method signatures, data flow, and edge cases. Do NOT write full Dart implementations. Gemini Flash compiles the code.
- **Frontend UI/UX:** Crisp layout descriptions per screen/widget — what panels exist, how they divide space, what each widget shows, what actions it exposes. Reference existing screens for UX patterns (e.g. "same master-detail layout as `grey_inward_screen.dart`"). Always specify: colors from `AppColors`, icon choices, empty states, loading states, and error states. Goal: uniform UX across all screens.
- Step-by-step task sequence with expected outcomes at each step

**After the plan is written, Claude's job is done. Antigravity takes over.**

---

## Project Overview
Flutter desktop/web ERP for Ambaji Sarees textile business.
Data pipeline: MSSQL (AMAZE/Empire software) → Airbyte → Supabase → Flutter app.
**Design System**: [Ambaji Design Spec](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/design-md/ambaji/DESIGN.md) (Light Mode, Linear/Supabase Hybrid).

---

## Workflow Rules

- **Explain DDL and migrations before executing.** Always show what SQL will run and wait for "go" before calling any migration or execute_sql tool.
- **Single session only.** Do not spawn agent teams. All work happens in one Claude Code session — saves 40–50% tokens.

---

## Airbyte Rules (CRITICAL)

- **Only use `api/public/v1` endpoints.** The `api/v1/scheduler` endpoints return HTTP 500 permanently — never use them.
- **Airbyte UI:** `http://localhost:8000`
- **Connection ID (MSSQL → Supabase):** `5d517918-43bd-4189-998a-f261dfa65359`
- **Workspace ID:** `b88bbf4e-0c22-4107-a300-28bb99e2457a`
- **Source ID:** `8e1c99c3-93a0-4909-af3f-d6acfbf6e4ef`
- **Destination ID:** `16a79232-3fe4-44c5-985c-5e784f1111eb`
- Airbyte runs on `localhost:8000` on the office Windows machine. Other LAN devices reach it via the machine's LAN IP.
- `abctl local install` is the daily start command (not `up`/`down`).

---

## Supabase / Database Rules

- **Schema:** `IMMBE2627` (all app tables live here)
- **Supabase project ID:** `vdprvitkijzxruhcgsin`
- **Edge Functions:** Use `npm:postgres` with `SUPABASE_DB_URL` for direct DB connections — do NOT use supabase-js PostgREST for Edge Function writes (`.schema()` silently drops inserts).
- **SQL constraints:** Use `pg_catalog.pg_constraint` to check PKs and FKs — `information_schema` misses constraints.
- **Dynamic table names in postgres.js:** Use `sql.unsafe()` for COUNT queries with dynamic table names. Use `sql(rows, 'col1', 'col2')` for batch inserts. Use `sql.json()` for JSONB values.

---

## Flutter Rules
- **Design System**: ALWAYS follow [DESIGN.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/design-md/ambaji/DESIGN.md).
    - Font: `Inter Variable` (Labels), `Berkeley Mono` (Data/Numbers).
    - Colors: Use `AppColors` derived from the emerald light-mode spec.
    - Layout: High-density, tight line-heights, 1px borders (Linear style).
- **Colors:** Use `AppColors` constants from `lib/theme/app_colors.dart` — never hardcode hex values inline.
- **Services:** All DB access goes through service classes in `lib/services/`. Pattern: `static final _db = Supabase.instance.client.schema('IMMBE2627')` for reads.
- **Navigation index:** Defined in `lib/main.dart` `_buildCurrentScreen()`. Sidebar items in `lib/widgets/sidebar.dart`.
- **No placeholder screens** for new features — build the real screen.

---

## Known Bugs / Gotchas

| Issue | Rule |
|---|---|
| Airbyte `api/v1/scheduler` → 500 | Never use. Only `api/public/v1`. |
| supabase-js `.schema().insert()` silently fails | Use Edge Function + npm:postgres for writes |
| `information_schema` misses FK/PK constraints | Use `pg_catalog.pg_constraint` |
| Airbyte CDK stdout bug shows "Failed" in UI | Check logs — if logs say success, it worked |
| `abctl local down` doesn't exist | Use `docker restart airbyte-abctl-control-plane` |

---

## External Reference Files
> Read these for deep context on specific areas. Do NOT duplicate their contents here.

| File | What's in it |
|---|---|
| `external_files/CONTEXT_AIRBYTE.md` | All Airbyte IDs, API syntax, stream config for all 26 tables, TLS fix, known bugs |
| `external_files/CONTEXT_SUPABASE.md` | Supabase schema, table definitions, RLS, migrations |
| `external_files/CONTEXT_FRONTEND.md` | Flutter screen-by-screen feature descriptions |
| `external_files/CONTEXT_SQL_MSSQL.md` | MSSQL source database structure, views, Empire software schema |
| `external_files/CONTEXT_QUICKREF.md` | Quick reference for common tasks across the stack |
| `external_files/MASTER_TIMELINE.md` | Project history and what was built when |
| `external_files/cl_SQL_LOGIC.md` | **Claude-authored.** Table groups (A–G), FY VNO prefix system, SERIES workflow decode, native SQL vs new table analysis, column corrections |

---

## File Index
> Updated by Claude when files are added or removed.

### Entry Point & Shell
| File | Purpose |
|---|---|
| `frontend/lib/main.dart` | App entry, `MainLayout`, navigation index (`_buildCurrentScreen`), screen routing |
| `frontend/lib/widgets/app_shell.dart` | Outer shell: sidebar + content area layout, focus/dim mode |
| `frontend/lib/widgets/sidebar.dart` | Left nav sidebar, section headers, nav items with badges |
| `frontend/lib/widgets/top_app_bar.dart` | Top bar widget (shared) |
| `frontend/lib/widgets/shared/item_list_panel.dart` | Reusable list panel used across screens |
| `frontend/lib/widgets/shared/master_detail_widgets.dart` | Shared master/detail layout widgets |

### Theme
| File | Purpose |
|---|---|
| `frontend/lib/theme/app_colors.dart` | All color constants — always use these, never hardcode hex |
| `frontend/lib/theme/app_theme.dart` | MaterialApp theme config |

### Models
| File | Purpose |
|---|---|
| `frontend/lib/models/party_model.dart` | Party (customer/supplier) |
| `frontend/lib/models/haste_model.dart` | Haste (broker/agent) |
| `frontend/lib/models/item_model.dart` | Item / quality |
| `frontend/lib/models/sales_order_model.dart` | Sales order + line items |
| `frontend/lib/models/design_model.dart` | Design (saree design) |
| `frontend/lib/models/grey_inward_model.dart` | Grey cloth inward records |
| `frontend/lib/models/mill_receive_model.dart` | Mill receive records |
| `frontend/lib/models/cutting_cards_model.dart` | Cutting card records |
| `frontend/lib/models/packing_slip_model.dart` | Packing slip |
| `frontend/lib/models/production_metrics_model.dart` | KPI metrics for production |
| `frontend/lib/models/account_group_model.dart` | Account group (ACGROUP) |
| `frontend/lib/models/sync_log_entry.dart` | Admin: `SyncLogEntry` + `SyncLogRun` (groups entries by captured_at) |
| `frontend/lib/models/sync_issue.dart` | Admin: `SyncIssue` with ghost/rename/anomaly detection getters |

### Services
| File | Purpose |
|---|---|
| `frontend/lib/services/service_party_v3.dart` | Party + haste queries |
| `frontend/lib/services/service_item.dart` | Item/quality queries |
| `frontend/lib/services/service_sales_orders.dart` | Sales order CRUD |
| `frontend/lib/services/service_design.dart` | Design queries |
| `frontend/lib/services/service_grey_inward.dart` | Grey inward queries |
| `frontend/lib/services/service_mill_receive.dart` | Mill receive queries |
| `frontend/lib/services/service_cutting_cards.dart` | Cutting card queries |
| `frontend/lib/services/service_packing_slips.dart` | Packing slip queries |
| `frontend/lib/services/service_production_metrics.dart` | Production KPI queries |
| `frontend/lib/services/service_admin_sync.dart` | Admin sync monitor: fetch runs, issues, apply fix, dismiss. Airbyte trigger methods to be added here. |
| `frontend/lib/services/mock_party_data.dart` | Mock data (dev only) |

### Screens — Masters
| File | Purpose |
|---|---|
| `frontend/lib/screens/masters/masters_screen.dart` | Masters screen shell (tabs: Parties, Suppliers, Haste, Others) |
| `frontend/lib/screens/masters/widgets/parties/parties_tab_content.dart` | Party list tab |
| `frontend/lib/screens/masters/widgets/parties/master_detail_dashboard.dart` | Party detail panel |
| `frontend/lib/screens/masters/widgets/suppliers/suppliers_tab_content.dart` | Supplier list tab |
| `frontend/lib/screens/masters/widgets/haste/haste_tab_content.dart` | Haste list tab |
| `frontend/lib/screens/masters/widgets/haste/haste_detail_view.dart` | Haste detail panel |
| `frontend/lib/screens/masters/widgets/others/others_tab_content.dart` | Others tab (account groups etc.) |
| `frontend/lib/screens/masters/widgets/shared/party_card_base.dart` | Shared party card widget |

### Screens — Items
| File | Purpose |
|---|---|
| `frontend/lib/screens/items/items_screen.dart` | Items screen (quality/cloth list) |
| `frontend/lib/screens/items/widgets/item_card.dart` | Item list card |
| `frontend/lib/screens/items/widgets/item_detail_view.dart` | Item detail panel |

### Screens — Sales
| File | Purpose |
|---|---|
| `frontend/lib/screens/sales/sales_order_screen.dart` | Sales order screen shell |
| `frontend/lib/screens/sales/packing_line_screen.dart` | Packing line screen |
| `frontend/lib/screens/sales/widgets/sales_order_editor_v4.dart` | Sales order editor (v4 — current) |
| `frontend/lib/screens/sales/widgets/design_entry_grid.dart` | Design entry grid in order editor |
| `frontend/lib/screens/sales/widgets/design_selector.dart` | Design picker dialog |
| `frontend/lib/screens/sales/widgets/multi_party_selector.dart` | Multi-party picker |
| `frontend/lib/screens/sales/widgets/order_details_view.dart` | Order read-only view |
| `frontend/lib/screens/sales/widgets/order_dialogs.dart` | Confirm/discard dialogs |
| `frontend/lib/screens/sales/widgets/order_ui_components.dart` | Shared UI components for order screens |
| `frontend/lib/screens/sales/widgets/packing_slip_editor.dart` | Packing slip editor |
| `frontend/lib/screens/sales/widgets/party_info_selector.dart` | Party info selector widget |

### Screens — Production
| File | Purpose |
|---|---|
| `frontend/lib/screens/production/production_metrics_screen.dart` | Production KPI dashboard |
| `frontend/lib/screens/production/grey_inward_screen.dart` | Grey cloth inward screen |
| `frontend/lib/screens/production/mill_receive_screen.dart` | Mill receive screen |
| `frontend/lib/screens/production/cutting_cards_screen.dart` | Cutting cards screen |
| `frontend/lib/screens/production/widgets/production_kpi_strip.dart` | KPI strip at top of production screens |
| `frontend/lib/screens/production/widgets/metrics_report_tab_panel.dart` | Metrics report tab |
| `frontend/lib/screens/production/widgets/mill_pending_report.dart` | Mill pending report panel |
| `frontend/lib/screens/production/widgets/grey_inward_list_panel.dart` | Grey inward list |
| `frontend/lib/screens/production/widgets/grey_inward_detail_panel.dart` | Grey inward detail |
| `frontend/lib/screens/production/widgets/grey_inward_vno_card.dart` | Grey inward VNO card |
| `frontend/lib/screens/production/widgets/mill_receive_list_panel.dart` | Mill receive list |
| `frontend/lib/screens/production/widgets/mill_receive_detail_panel.dart` | Mill receive detail |
| `frontend/lib/screens/production/widgets/mill_receive_vno_card.dart` | Mill receive VNO card |
| `frontend/lib/screens/production/widgets/cutting_cards_list_panel.dart` | Cutting cards list |
| `frontend/lib/screens/production/widgets/cutting_cards_detail_panel.dart` | Cutting cards detail |
| `frontend/lib/screens/production/widgets/cutting_card_list_item.dart` | Cutting card list item widget |

### Screens — Admin (Sync Monitor)
| File | Purpose |
|---|---|
| `frontend/lib/screens/admin/admin_screen.dart` | Sync monitor screen: issues panel, KPI cards, history log |
| `frontend/lib/screens/admin/widgets/issue_card.dart` | Ghost/rename issue card with SQL fix + dismiss |
| `frontend/lib/screens/admin/widgets/kpi_card_group.dart` | KPI card group (expandable, shows per-table row counts) |
| `frontend/lib/screens/admin/widgets/sync_history_tile.dart` | History tile (expandable, shows per-group breakdown) |

### Screens — Party Master V3 (Legacy/WIP)
| File | Purpose |
|---|---|
| `frontend/lib/screens/party_master_v3/` | Older version of party master — may be superseded by masters screen |

### Constants & Utils
| File | Purpose |
|---|---|
| `frontend/lib/constants/atype_data.dart` | ATYPE lookup data (account type codes) |
| `frontend/lib/utils/financial_utils.dart` | Financial calculations (balances, totals) |
| `frontend/lib/utils/utils_parsing.dart` | Parsing helpers (dates, numbers) |

### Backend
| File | Purpose |
|---|---|
| `backend/supabase/functions/sync-snapshot/index.ts` | Edge Function: counts 26 tables, writes sb_sync_log, detects anomalies, records snapshots for 7 FK-parent tables. Uses `npm:postgres` + `SUPABASE_DB_URL`. |
| `backend/schema.sql` | Supabase schema DDL (reference) |
| `backend/app/sync_engine.py` | Python sync engine (legacy/unused — Airbyte replaced this) |

### Docs & Specs
| File | Purpose |
|---|---|
| `frontend/docs/superpowers/specs/2026-04-05-admin-sync-monitor-design.md` | Spec: Admin sync monitor feature |
| `frontend/docs/superpowers/specs/2026-04-05-airbyte-manual-trigger-design.md` | Spec: Airbyte manual trigger button |
