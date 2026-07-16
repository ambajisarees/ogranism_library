# Dev Log — Ambaji Sarees ERP
> **Project**: Textile ERP — Flutter (Web + Windows) + Supabase (Postgres 17)
> **Developer**: Smit · www.ambajisaree.com
> **Convention**: Newest entries at top. Each day is a self-contained section.

---

## 2026-07-16 · Central Media Library Explorer, Inline Scans, Overlay Progress & Popover Fixes

Shipped the central Media Library Explorer module, Supabase Storage integration, Postgres RPC migration, inline photo scan attachment features, unified `'cutting_card'` classification, single-step Link & Auto-Rename storage logic, live progress dialog overlays, context popup unmounted crashes, and git syncing.

### Client-Side Image Compression & Thumbnails
- **App-Side Compression Pipeline**: Added the pure Dart `image` package to pre-process images locally prior to upload. Downscales images exceeding `1600px` (preserving aspect ratio) and outputs `80%` quality JPEGs (typically compressing 5MB raw files to ~250KB).
- **In-App Thumbnailing**: Dynamically generates `200px` thumbnail slices at `70%` quality and uploads them asynchronously to `/thumbnails` paths in Supabase Storage.
- **RPC Param Extension**: Redefined `"IMMBE2627".insert_media` in Postgres to take a backward-compatible `p_thumb_path DEFAULT NULL` argument, linking thumbnails to metadata records automatically.
- **Redundant View Optimizations**: Configured grid views and preview boxes to fetch `thumbPath` objects first, falling back to CDN-resized `200x200` transformations (`TransformOptions`) to save massive egress bandwidth and load screens instantly.

### Central Media Library & Explorer Screen
- **Central Media Screen**: Designed and deployed the Standalone Media Screen (`media_screen.dart`) registered as route case 10 and linked to navigation rails/boats.
- **Three-Pane Workspace**:
  - **Left Pane**: Dynamic selection tree for buckets (`sales`, `production`, `billing`, `general`) displaying reactive item counts, linkage status filters (All/Linked/Unsorted), and sorting order dropdowns.
  - **Middle Pane**: High-density responsive image thumbnail grid with selection hover checkboxes, full bulk-actions float bar (supporting bulk linking and bulk archiving), and pagination.
  - **Right Pane**: Details inspection panel displaying image previews, editable display name inputs with `CellInput` wrapper, metadata badges (file size, category, uploader name), soft delete triggers, and live autocomplete searching (across qualities, cutting batches, and dispatches) to establish entity associations.
- **Drag & Drop Upload**: Integrated drop target detectors mapping binary file reads directly to Supabase storage uploading streams.

### Supabase Storage & Postgres RPC Migration
- **Bucket Configuration**: Set up folder structures inside `ambaji-media` bucket (`sales/`, `production/cutting/`, `production/jobcard/`).
- **Postgres DDL & Triggers**: Applied `sb_media` migrations with automated table constraints, index performance optimizations, and RLS policies.
- **Transactional DB RPCs**: Deployed custom Postgres procedures (`insert_media`, `link_media_to_entity`, `archive_media`, `bulk_link_media_to_entity`, and `bulk_archive_media`) to handle all database operations transactionally from the client.
- **Overload Ambiguity Fix (PGRST203)**: Dropped the legacy 14-parameter `insert_media` overload, keeping only the 15-parameter version with `p_side DEFAULT NULL` to resolve PostgREST candidates routing conflicts.

### CC Code Migration & Unified Classification
- **Generated Columns**: Applied DB migration to add two `GENERATED ALWAYS AS` columns (`cc_no`, `cc_code`) to `sb_cutdet_summary` for zero-padded 4-digit serial formatting (e.g. `CC-0001`).
- **Unified Category**: Merged `cutting_card_front` and `cutting_card_back` into a single `'cutting_card'` category across all DB schemas and upload dialog selections.
- **Front/Back Side Detection**: Autodetects target sides (F/B) during suggestion generation based on filename suffix tags (e.g., `(2)` or `_2` mapped to back `'B'`, and clean serials to front `'F'`).

### Consolidated Link & Auto-Rename Action
- **One-Step Execution**: Removed the separate "Rename to CC Code" header button. Linking now triggers both metadata mapping and storage renaming/relocation atomically.
- **Dynamic Proposed Renames**: Displays the target filename (e.g., `➔ Rename to: CC-0001-F.jpg`) directly below the item matching dropdown inside the row UI.
- **Relocation Pathing**: Pushes the linked files directly to the `'production/cutting/$entityId/'` subdirectory in storage on connection mapping.
- **Bulk Delinking**: Ran database reset query to delink 47 legacy records from `sb_media` metadata tables so they show up under the Smart Linker dashboard for automated rename migration.

### Detailed Progress Overlay Dialogs
- **Dynamic Visual Counters**: Added glassmorphic progress overlay widgets containing linear progress bars and precise status messages (e.g. `Uploading 01.jpg`, `1 of 43 · 3% completed` or `Linking 01.jpg (1 of 43 · 3% completed)`).
- **Callback Integration**: Added progress reporting callback parameters (`onProgress`) inside `bulkLinkSuggestions` to feed current counts and renaming phases back to the UI.

### Popover Overlay & ListTile Bug Fixes
- **Material Ancestors**: Wrapped `ListTile` options across the navigation sidebar, autocomplete search dialogs, bulk linker dropdowns, and `TissueDropdown` list choices inside proper opaque `Material` widgets to satisfy Flutter ink-ripple requirements.
- **Safe Context Closes**: Swapped unmounted Navigator pops (`Navigator.of(context).pop()`) inside dropdown triggers and `_buildSortPopover` (in `cutting_screen.dart`) for key state controller closes (`_popoverKey.currentState?.close()`) to avoid unmounted context errors and black screens.

### Git Syncing
- **Commit & Remote Push**: Staged all untracked files and changes, creating commit `feat: central media library, smart linker rename automations, auth gate, and job work screens` and pushing it to remote origin master branch.

### Inline Cutting Cards Scan Attachment
- **Inline Scanner Row**: Added a dedicated `CUTTING CARD SCAN` section to the batch details pane inside `cutting_screen.dart`.
- **Two-Way Synchronization**: Attaching or removing card photo scans updates the linked `sb_media` records and automatically propagates the path back into the primary transactional tables (`sb_cutdet_summary` and `sb_cutdet`).

### Inline Job Work Challan Attachment
- **Dispatch & Receive Attachments**: Implemented inline scans display and pickers inside `job_work_screen.dart` details panel for both Stitching Dispatches (`O5`) and Stitching Receives (`O6`).
- **Details Integration**: Loads associated challan scans concurrently with fabric detail lines and provides instant attachment/detachment actions.

### Compile-Time Alignment & Syntax Refinements
- **Generic PostgREST Casting**: Refactored the `MediaService.getMedia` builder variables to use dynamic typing to allow query sorting transformations (`PostgrestTransformBuilder`) to be assigned back safely.
- **API and Syntax Fixes**: Corrected invalid padding `py:` properties, missing closing brackets on `_buildMediaAttachmentsSection`, container constructor constraints, and migrated deprecated toast properties to `PlasmaToastManager`.
- **FilePicker Version Matching**: Replaced `FilePicker.platform.pickFiles` with the correct `FilePicker.pickFiles` static primitive to match project packaging.
- **Status**: The workspace successfully compiles with **zero static compiler errors**.

---

## 2026-07-15 (Evening) · Authentication Gateway, Profile Dropdowns, Windows Export, Concurrency & Audit Trails

Successfully shipped user authentication with profile popovers, Windows release packaging, concurrency control, creation audit tracking, and list view refinements in the Cutting Cards module.

### Cutting Cards List View Refinements
- **Active Filter/Sort Popovers**: Converted `OrganPaneHeader` inside [pane_header.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/organism_design/organs/pane_header.dart) to a `StatefulWidget` to store `GlobalKey` references. Programmed triggers to call popover `toggle()` programmatically on button tap, resolving gesture interception/disabled states.
- **Right-Aligned Footer Layout**: Configured `TissueListCard` inside [cutting_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/cutting_screen.dart) with `isCompact: false` for comfortable height padding. Assigned the piece count (`1347 Pcs`) to the `footer` slot wrapped in a right-aligned `Align` container. This cleanly stacks the piece count directly underneath the trailing voucher chip badge, resolving inline-subtitle spacing issues and ensuring high-fidelity visual grouping.
- **Date Icon Upgrade**: Refined `CellCardAvatar` inside [card_avatar.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/organism_design/cells/card_avatar.dart) to present the day (DD) on top and the 3-letter month shortform (MMM) in uppercase below for higher-fidelity temporal rendering.
- **Sort & Filter popover items**: Extended popovers for mill, fabric, date, and challan sequence operations.

### Legacy Modules Reference Documentation
- **Comprehensive Guide**: Compiled and classified all 73 legacy voucher modules from the Voucher Series Master `sq_SERIES` and `legacy_constants.dart` into [legacy_modules_guide.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/legacy_modules_guide.md).
- **Categorization & Relational Mapping**: Organized modules into 7 functional business groups, detailed the double-entry impact of cash/bank/sales, mapped the production `CARDNO` thread through the O-series, and analyzed the compound relational key rules (`CNO/VNO/TYPE`) and `sq_RECPAY` settlement flows.

### Job Work Management Module (O5 & O6)
- **New Module Shipped**: Developed and registered the new Job Work Management screen ([job_work_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/job_work_screen.dart)) with tabs for **Job Dispatch** (`O5`) and **Job Receive** (`O6`).
- **Relational Linkage**: Implemented models ([model_jobwork.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/models/model_jobwork.dart)) and services ([service_jobwork.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/services/service_jobwork.dart)) that pull active FY 26-27 records from `sq_BILLS` and `sq_BILLDET` (`VNO < 100000`) and establish links between cutting cards (`CUTCARDNO` from `sb_cutdet`), Stitching Dispatches (`orderno = CUTCARDNO` / `ORDTYPE = 'O3'`), and Stitching Receives (`STAGE_VNO = O5_VNO` / `STAGE_TYPE = 'O5'`).
- **Integrated Navigation**: Mapped route index 7 in [home.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/home.dart) to the new screen and added search support via the command palette.

### PostgREST Limits & Available Takas RPC Refactoring
- **Bypassing Server Limits**: Refactored the `getAvailableTakas` query inside [service_cutting.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/services/service_cutting.dart) to use a custom database RPC `get_available_takas`.
- **The Issue**: Previously, the app fetched a client-side filter array of all cut cards to exclude them, which got truncated silently at PostgREST's default max-rows cap of 1,000, allowing "trailing cut cards" (already cut cards) to bleed into the UI.
- **The Solution**: Moving the join logic into PostgreSQL via a native SQL `NOT EXISTS` query ensures that only genuine uncut rolls are fetched, bypassing API row limitations entirely.

### User Audit Trail Tracking
- **JWT Header Decode**: Upgraded the `create-cutting-batch` Edge Function to extract the authorization header, decode the base64 JWT payload, and resolve the authenticated `userId` and `userEmail` on the fly.
- **Dynamic Username Resolution**: Enhanced Deno Edge Function transaction logic to resolve the explicit profile `username` (e.g., `SUBHAM`, `JATIN`) from the `sb_APP_PROFILES` database table, falling back to email local-parts only if a profile doesn't exist.
- **Audit Columns Populated**: Writes to `sb_cutdet` and `sb_cutdet_summary` now record `sb_created_by` (UUID), `CREATOR` (user email prefix or profile username), and `CREATETIME` (timestamp).
- **Edit Tracking**: Modifications to batches set `UPDATER` and `UPDATETIME` to track edits.
- **UI Creator Badge**: Updated [cutting_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/cutting_screen.dart) detail canvas footer to display the `Creator` username next to the batch status badge for active reviews/edits.

### Cutting Cards Concurrency & Realtime Sync
- **Unique Roll Constraint**: Deployed a partial unique index `sb_cutdet_unique_reccardno` to block the double-cutting of the same roll (`reccardno`) by concurrent users.
- **VNO Serialization**: Added an exclusive table lock statement `LOCK TABLE sb_cutdet_summary IN EXCLUSIVE MODE` within the `create-cutting-batch` Edge Function transaction block to prevent race conditions during sequential `MULTI_VNO` generation.
- **Friendly Database Error Intercepts**: Configured the Edge Function to catch Postgres constraint violations and return user-friendly, clean error messages.
- **Supabase Realtime Sync**: Subscribed to database mutation events on the `sb_cutdet` table inside [cutting_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/production/cutting_screen.dart). MUTATION updates automatically trigger hot-reload of available rolls and summary lists across active instances.

### Windows Release Compilation & Packaging
- **Production Build**: Executed `flutter build windows --release` to compile the optimized Windows binary (`textile_erp.exe`) in the runner release directory.
- **Distribution Package**: Generated `textile_erp_windows_release.zip` at the workspace root, containing the compiled executable and all required runtime dependency DLLs for quick sharing.

### Core Authentication & Session Routing
- **AuthGate Engine**: Deployed [auth_gate.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/auth/auth_gate.dart) to listen reactively to Supabase `onAuthStateChange` streams. Transitions smoothly from loader animations to either the `LoginScreen` or `HomeScreen` based on session validity.
- **Auth Services**: Introduced [service_auth.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/services/service_auth.dart) for clean encapsulation of standard Supabase signIn / signOut actions.

### Premium Login User Interface
- **Layout**: Implemented the premium login card interface in [login_screen.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/screens/auth/login_screen.dart). Restored form fields using `CellInput` and actions using `CellButton`.
- **Keyboard Mechanics**: Enabled fluid keyboard navigation (`Tab` transitions and `Enter` key form submission).
- **Error Feedback**: Added live visual feedback with error flags to report incorrect credentials dynamically.

---

## 2026-07-15 · Cutting Cards Architecture Refactoring, Multi-Select Chips & Transactional Edits

Shipped major workflow enhancements, design system updates, and database transactional logic for the Cutting Cards module.

### Refactoring to Supabase Native Tables
- **Exclusion of sq_CUTDET**: Removed all legacy sync-table read/write lookups referencing the read-only mirror table `sq_CUTDET`. The registry list pane now retrieves records exclusively from the Supabase transactional summary view `sb_cutdet_summary` and the detail view from `sb_cutdet`.

### Batch Sequencing & Card Labeling
- **MULTI CARD NO & MULTI_VNO**: Renamed the input label `CUT CARD NO` to `MULTI CARD NO` on the Add Page.
- **Sequence Generator**: Repurposed the sequence finder to query the max `MULTI_VNO` in the current fiscal context (`VNO < 100000`) from `sb_cutdet` and display/increment it.
- **Sequence Overrides**: Deployed support to allow manual overrides of `MULTI_VNO` to any customized value (including unused/blank values like `12` or `13`) in both Create and Edit flows.

### Design System: Multi-Select Chip Autocomplete
- **CellAutocomplete Upgrade**: Refactored the core design system widget `CellAutocomplete` to natively support multi-select (`isMultiSelect: true`). It embeds selected options as dismissible, auto-wrapping inline chips (`CellInputChip`) inside the input container itself, matching the high-density keyboard-friendly design language.
- **Grey Quality Selector**: Integrated the updated multi-select autocomplete inside the step bar, replacing the popover dropdown. The save payload joins the selected qualities with a comma (`DANI, GEORGETTE`), while the backend database stores individual rolls with their specific quality.

### PostgREST Pagination Limit Bug Fix
- **The Issue**: Once the total number of closed rolls in `sb_cutdet` exceeded 1,000, Supabase/PostgREST's default query page size limit (1,000 rows) capped the returned cut card numbers. This caused any cut rolls from newer batches (such as batches 81, 82, etc.) to not be fetched in the exclusion list, resulting in already cut rolls incorrectly showing up as available in the UI.
- **The Fix**: Added `.limit(100000)` to the closed card query in `getAvailableTakas()` inside `service_cutting.dart` to bypass the default limit and ensure all closed rolls are fetched for client-side exclusion.

### Transactional Edit Support
- **Edge Function Upgrades**: Modified the `create-cutting-batch` Edge Function to support `edit_multi_vno`. If passed, the transaction deletes the old batch records and re-inserts the updated batch under the targeted number. Deployed **Version 8** successfully.
- **Pre-population & Auto-Selection**: Clicking "Edit Batch" in the detail header card pre-populates all inputs (Fresh/Second counts, average saree weight, screen references), loads uncut rolls + the batch's own cut rolls, and automatically pre-selects the cards in the batch.
- **Save & Selection Auto-Refresh**: Modified `_saveBatch()` success callback to clear stale selected state, hide the overlay, trigger a reload of list cards, and automatically highlight and load details for the updated batch ID.
- **Date Picker State Lifecyle Bugfix**: Added a `didUpdateWidget` lifecycle handler to the `CellCalendar` widget to fix a bug where the date picker month view always defaulted to today (July 2026). The picker calendar now correctly shifts to show the pre-populated date (e.g. April 2026) when editing.

---

## 2026-04-15 (Evening) · Advanced Registry Systems & Production Kanban Workstation

Successfully shipped two major workflow modernizations: the unified Masters Registry and the Grey Production nested Kanban board.

### Masters Registry Modernization
- **High-Density Split Pane**: Rewrote the `PartiesScreen` to utilize `vwsq_MASTER` with live, server-side pagination and search.
- **Global Business Role Topology**: Established a 12-color categorical mapping system (`OrganismTheme` chart colors) inside `LegacyConstants`.
- **Badge API Enhancements**: Upgraded `CellBadge` to support `customColor` overrides with automatic text contrast (black/white) based on luminance. This allows parties (e.g. "Weavers", "Customers") to be instantly recognizable at a glance via color.
- **Precision Subtitles**: Implemented logic to dynamically display "STATION x CITY" for robust geographical tracking on registry cards.

### Grey Production Workflow
- **The "Data Bridge"**: Mapped the complex three-tier relationship of textile production: `sq_BILLS (P1 Header)` → `sq_PINVTRN (Job Cards)` → `sq_CHALTRN (Rolls / Takas)`.
- **Registry View Optimization**: Deployed `vwsq_GREY_REGISTRY` to aggregate total job cards and meters efficiently at the database level.
- **UI Architecture — Process Kanban**:
  - Left Pane: Scrollable registry of Grey Purchase headers.
  - Right Pane: A horizontally scrolling Kanban layout where each column represents an active dispatch batch (`PINVTRN`).
  - Taka Grids: Inside each batch column, dense numeric lists display roll-level actual metrics (`PMTS` / `TAKA_WT`).
- **Fiscal Isolation**: Hard-enforced the `VNO < 1,000,000` carry-forward rule securely at the service layer.
- **Syntax Remediation**: Fixed lingering `postgrest-2.6.0` syntax errors (swapped `.select('*', count:...)` for the chained `.count(CountOption.exact)` method) inside `GreyService`.

---

## 2026-04-14–15 · Quality Masters Registry — Schema Connectivity & Debug

Successfully resolved persistent **PGRST002 (Schema Not Found)** errors blocking the entire `IMMBE2627` data access layer and shipped the Quality Master registry UI with functional tabs.

### Root Cause — Triple Compounding Issue
Three independent problems combined to produce the `PGRST002` errors:

1. **`IMMBE2627` not exposed via Data API**: Schema was present in the DB but never checked in Supabase Dashboard → **Integrations → Data API → Exposed Schemas**. Checking it (and clicking **Save**) tells PostgREST to serve that schema.
2. **Wrong `anonKey` format**: A modern `sb_publishable_…` key had been substituted into `supabase_config.dart`. The project requires the legacy **JWT-based anon key** (format: `eyJ...`). Restored to correct value.
3. **`postgrest-2.6.0` syntax mismatch**: `.select('*', count: CountOption.exact)` is invalid in `postgrest-2.6.0`. The count must be chained as a separate terminal call: `.select('*')…order()…range()…count(CountOption.exact)`.

### Resolution Steps (Chronological)
| Step | Action | Outcome |
|---|---|---|
| 1 | Audited `pubspec.lock` → confirmed `postgrest-2.6.0` | Identified count syntax root cause |
| 2 | Inspected `postgrest_query_builder.dart` + `postgrest_transform_builder.dart` source | Confirmed `.select()` has no `count:` param; `.count()` is terminal only |
| 3 | Fixed query chain order in `MastersService` | Compilation errors eliminated |
| 4 | Restored JWT `anonKey` in `supabase_config.dart` | Authentication reconnected |
| 5 | User exposed `IMMBE2627` in Supabase Dashboard and clicked **Save** | `PGRST002` resolved |
| 6 | Removed `Extra search path` from Dashboard | Reverted; explicit `.schema('IMMBE2627')` used instead |
| 7 | Diagnostic: switched Quality service to raw `sq_QUAL` table | Confirmed data was reachable |
| 8 | Restored `vwsq_qual` as the production view | Full registry operational |

### Code Changes
- **`lib/config/supabase_config.dart`**: Restored legacy JWT `anonKey`.
- **`lib/services/service_masters.dart`**:
  - Fixed `.select('*', count:…)` → `.select('*')…count(CountOption.exact)` for both `getParties` and `getQualities`.
  - Added explicit `.schema('IMMBE2627')` to all query chains.
  - Switched `getQualities` from `vwsq_qual` → `sq_QUAL` for diagnostics, then back to `vwsq_qual`.
  - Added `QualityBarrel.all` (no filters) for diagnostic tab visibility.
- **`lib/screens/items/items_screen.dart`**: Added **All** tab (4th barrel) for zero-filter debugging.
- **`lib/models/model_quality.dart`**: Confirmed column mapping is compatible with both `sq_QUAL` and `vwsq_qual`; `parseDouble()` helper handles mixed `num`/`String` types from Postgres.

### Architecture Lessons Learned
- `.schema()` call in `supabase_flutter` sends a `db-schema` request header to PostgREST. PostgREST will only honour it if the schema is in the **Exposed Schemas** list — a Dashboard setting, not a SQL grant.
- `anon` `GRANT SELECT` on a table is necessary but not sufficient. The schema must also be exposed via the API settings.
- `NOTIFY pgrst, 'reload schema'` (PostgREST schema cache flush) requires the schema to already be in the exposed list — it only refreshes the cache, not the allow-list.
- Auth `storage` and `auth` schemas do not appear in the Exposed Schemas list; they are private system schemas served via dedicated Supabase APIs.

### Status
- ✅ `PGRST002` resolved — all `IMMBE2627` tables/views now accessible via Supabase Data API.
- ✅ Quality Masters compiling and loading data from `vwsq_qual`.
- ✅ Parties loading from `sq_MASTER` with pagination.

---

## 2026-04-14 (Day) · Quality Masters Registry — Implementation

Built the full live 3-tab Quality Master registry connected to `IMMBE2627.vwsq_qual`, and performed the `sq_MASTER` contact data census.

### Quality Registry — 3-Tab Live Feature
- **`vwsq_qual` View**: App now strictly consumes this 14-column curated view (not the raw `sq_QUAL` table), ensuring data quality guards are applied at the DB layer.
- **Barrel Logic** (`MastersService`):
  - **Sales**: `SELL1 >= 180` + `CLOTHTYPE = 'SAREE'` — targets the active textile portfolio.
  - **Grey**: `ISBASEQUAL = 'Y'` — isolates 99 raw fabric base qualities.
  - **Others**: Catch-all for hardware/stationery/misc (RAM, SSD, Stationery, Freight).
- **`QualityModel`** (`model_quality.dart`): Immutable data class with `parseDouble()` helper handling mixed `num`/`String` inputs from Postgres. Maps all 14 key columns from the view.
- **`ItemsScreen`**: 3-tab pill navigation (Sales / Grey / Others) with live pagination (50 items per page via `offset`/`limit`).
- **Detail Pane**: Pulls live HSN codes, GST rates, and standard cut lengths directly from Supabase.

### Contact Data Census — `sq_MASTER`
Performed a quantitative audit of all 4,941 party records to plan a future CRM normalization effort. Findings documented in `organism_audit_report.md`:

| Source Column | Contact Points | Notes |
|---|---|---|
| `MOBILE` | 2,304 | Primary target — clean mobile numbers |
| `CONTACT` | 1,966 | **High Clutter** — mixes names, roles, and numbers |
| `WEB_MOBILE` (1-4) | 540 | Secondary/website-linked mobiles |
| `PHONE1 / PHONE2` | 641 | Mostly landlines |
| `FLASH_RMK` | 467 | Free-form notes with buried numbers |

- **Hidden Contacts via Regex**: 1,571 numbers buried in `CONTACT`, 247 in `FLASH_RMK`, 136 Surat landlines (7-digit format needing `0261` prefix).
- **Total Estimated CRM reach**: ~5,200 unique contact points (vs. 2,304 accessible today).
- **Recommendation**: Create `exsq_master_contacts` normalized table (already exists in schema with 4,273 extracted rows from a prior migration run).

---

## 2026-04-13 · `sq_QUAL` Deep Audit + App Icon Design

### Quality Master Schema Audit (`sq_QUAL`)
Performed a full quantitative audit of the `sq_QUAL` table (931 rows, 37 columns) and documented in `backend/schema_docs/02_masters/sq_QUAL.md`. This became the foundation for the barrel-based Quality registry implementation.

**Key Findings:**
| Metric | Value |
|---|---|
| Total records | 931 |
| Columns | 37 |
| Data completeness | ~55% |
| 100% NULL columns | `COST_PER`, `SUPPLIER`, `VATRATE`, `SCREENCOMP` |
| GST Compliant (HSN + GSTRATE filled) | ~92% |
| Missing `CUT` (production specs) | 274 items |

**Column Classification:**

| Category | Columns | Status |
|---|---|---|
| Core Identity | `qcode`, `NAME`, `CLOTHTYPE`, `UNIT` | ✅ 100% complete |
| Sales | `SELL1/2/3`, `HSN_CODE`, `GSTRATE` | ✅ ~75% complete |
| Production | `CUT`, `PACKING`, `ISBASEQUAL` | ⚠️ Partial |
| Financials | `COST_PER`, `pur1`, `SUPPLIER` | ❌ 100% NULL — TODO |
| Legacy/Irrelevant | `VATRATE`, `SCREENCOMP`, `OLDQCODE` | 🚫 Ignore |

**Barrel Plan Finalized:**
- **GREY** (99 items): `ISBASEQUAL = 'Y'` — raw grey fabric anchors.
- **SALES** (650 candidates, 317 "core"): `SELL1 >= 180`, SAREE/FINAL cloth types.
- **OTHERS**: Hardware (RAM, SSD), Stationery, and Misc non-textile items.

**CLOTHTYPE Distribution:**
- `SAREE`: 842 items (dominant)
- `LACE`: 41, `FABRIC`: 21, `UNSTITCHED`: 12

**Design Decision**: Use `CLOTHTYPE` as the primary sidebar filter; `category` (54 distinct seasons/collections) as a secondary chip filter.

### App Icon Design Session
Explored and generated multiple Ambaji Sarees app icon options with Burgundy/Gold branding palette:
- Option 1: Embroidered motif style — textured, ornate.
- Option 3: Flat bold monogram style — clean, modern ERP feel.
- Final direction: Retained for future brand identity finalization.

---

## 2026-04-12 · Organism Architectural Standardization — Full System Sweep

Completed the final architectural standardization of the `organism_design` library. Enforced strict relative imports, added comprehensive file summaries, and refactored layout spacing across all 3 directories (Cells, Plasma, Tissues).

### Key Architectural Shifts
- **Strict Relative Imports**: Internal components now import siblings directly (e.g., `import '../cells/button.dart';`) rather than using barrel files. Barrel files are now reserved solely for external exporters.
- **File Summaries**: Added `/// [ComponentName] — Short Description` blocks to every single file (70+ components) to maintain the "Master Index" fidelity.
- **Spatial Governance**: Refactored hardcoded `SizedBox` and `Padding` instances to use the new `CellGap` and `CellPad` spatial utilities, strictly enforcing `OrganismTheme.spacingMd` multiples.

### Standardization Summary
| Layer | Count | Standardization Completed |
|---|---|---|
| **Cells** | 33 | All Atoms (Buttons, Inputs, Toggles, Display, Layout) |
| **Plasma** | 5 | All Primitives (Dialog, Popover, Toast, Physics, ZStack) |
| **Tissues** | 19 | All Molecules (Card, FormField, ListView, Pipeline, Tabs, etc.) |

### Implementation Details
- **`empty.dart`**: Renamed internally and standardized as `TissueEmptyState` molecule.
- **`spatial.dart`**: Introduced `CellGap` (SizedBox replacement) and `CellPad` (Padding replacement) for theme-relative spacing.
- **`index.dart`**: Updated master summary to include spatial utilities and complete component counts.
- **Verification**: All internal imports verified; barrel files updated with full documentation.

---

## 2026-04-11 · cells_view.dart — Full 33-Cell Coverage

Complete rewrite of `cells_view.dart`. Converted from `StatelessWidget` → `StatefulWidget`
so interactive demos (checkbox, switch, radio, slider, combobox, toggle group, input chip)
actually respond to user input.

### Sections (7 total)
| # | Section | Cells Covered |
|---|---|---|
| 1 | Action Dynamics | CellButton (all 5 variants + compact + icons), CellMultiButton |
| 2 | Text & Numeric Entry | CellInput (4 modes), CellInputNumber |
| 3 | Selection Controls | CellCheckbox, CellSwitch, CellRadio, CellSlider, CellToggleGroup |
| 4 | Advanced Data Entry | CellCombobox, CellDatePicker, CellTimePicker, CellCalendar, CellInputChip |
| 5 | Display & Indicators | CellBadge (6 variants), CellCountBadge, CellAvatar, CellFilterChip, CellTag, CellStatusDot, CellProgressBar, CellTooltip, CellSkeleton, CellAlert, CellKbd |
| 6 | Structural DNA | CellBox, CellDivider, CellLabel, CellListTile, CellPlaceholder |
| 7 | Navigation & Brand | CellNavItem (Sidebar + Rail), AmbajiSareeLogo |

### API Fixes Applied
- `CellAlert`: uses `title:` + `icon:` + `variant: CellBadgeVariant` (not `CellAlertVariant` — doesn't exist)
- `CellRadio`: has no `label:` param → wrapped each radio in `_radioRow()` helper (Row + Text)
- `CellSkeleton`: API is `width`, `height`, `borderRadius` (no radius shorthand) ✅

---


### `CellStatusDot` — `cells/status_dot.dart`
- **StatefulWidget** with `SingleTickerProviderStateMixin` for animated pulse.
- 5 variants: `active` (green pulse), `syncing` (primary pulse), `idle`, `warning`, `error` (static).
- `active` and `syncing` auto-animate their glow; all others are static. Override with `pulse:`.
- Renders 8px dot + right-aligned label in `bodySmall/textSecondary`.

### `CellTag` — `cells/tag.dart`
- **StatelessWidget** — distinct from `CellFilterChip` (toggle) and `CellBadge` (unclickable status).
- 5 variants: `neutral`, `accent`, `success`, `warning`, `error` with proper semantic colors.
- Optional `onRemove` callback renders a `×` button with generous hit area (Padding 2px all).
- Optional `onTap` wraps the whole tag in a `GestureDetector`.
- Uses `borderPill` radius for a clean rounded pill shape.

### Library Registration
- Both cells documented in `cells_view.dart` → **Micro UI Mechanics** section with live examples.
- Registered in `cells.dart` barrel with full doc comments.

---


### Barrel Files — Full Doc Comments
Replaced all `// AUTO-GENERATED` stubs across the design system barrel files with rich, structured Dart doc-comments explaining every single exported symbol.

- **`cells.dart`**: All 30 cells documented with description, variants, use-cases, and sizing notes. Grouped into: Interaction/Controls · Data Input/Selection · Display/Indicators · Layout/Structural · Focus System.
- **`tissues.dart`**: All 19 tissues documented. Grouped into: Surface/Containers · Form & Data Entry · Navigation & Layout · Actions/Menus · Data Display · Status/Feedback.
- **`plasma.dart`**: All 5 plasma exports documented — Physics engine, ZStack depth system, Dialog, Popover, and ToastManager with z-index values noted.
- **`organs.dart`**: `NavBoat` fully documented — Sidebar vs Rail mode dimensions, routing contract, Toast overlay anchor.
- **`systems.dart`**: Placeholder with future roadmap (StandardListDetailSystem, DashboardSystem, FormPageSystem).
- **`index.dart`**: Master barrel rewritten as a comprehensive visual reference — full architecture hierarchy diagram, every component with one-line summary, grouped by layer.

### Bug Fixes (Earlier Today)
- **`tissues_view.dart`**: Fixed mismatched closing brackets from `LibraryComponentDoc` refactor on `_buildListCardsSection`.
- **`theme_view.dart`**: Fixed `colors.secondary` → `colors.stone200` and `colors.destructive` → `colors.error` (non-existent getters).

### Dev Log
- Moved `dev_log.md` to `frontend/docs/dev_log.md` (new canonical location).

---

## 2026-04-11 · Organism Library Overhaul & Context-Aware Theme Migration

### Theme Architecture — Final Migration
- **Eliminated Static Anti-Pattern**: Removed all `OrganismTheme.primary` static getter calls across the codebase. Every component now calls `OrganismTheme.colorsOf(context)` inside its `build` method.
- **Theme File Split**: Broke `theme.dart` (1,000+ lines) into semantic modules:
  - `theme/colors.dart` — `OrganismColors` struct with `.light()` / `.dark()` factories.
  - `theme/metrics.dart` — All spacing, radius, breakpoint, z-index, and animation constants.
  - `theme/typography.dart` — All `TextStyle` generator methods.
  - `theme.dart` — Retained as central aggregator / backwards-compatible export barrel.
- **Context Propagation Fix**: Refactored all helper methods (`_buildSection`, `_depthCard`, etc.) across `cells_view.dart`, `plasma_view.dart`, `tissues_view.dart`, `home.dart` to explicitly accept `BuildContext` and `OrganismColors` parameters.
- **Overlay Scope Fix**: Fixed `dialog.dart` and `popover.dart` — colors are now resolved *inside* the `OverlayEntry`/`pageBuilder` callback, not at call site.
- **Lint Cleanup**: Removed `unused_local_variable` in `main.dart`, `unnecessary_import` in `alert.dart` and `badge.dart`.

### Library Screen — Pill Tab Navigation
- **`library_shell.dart`**: Converted to `StatefulWidget`. Added `TissueTabs` (pill variant) to the `AppBar` center, driving 5 sections: **Theme · Plasma · Cells · Tissues · Organs**.
- **New `theme_view.dart`**: Documenting design tokens — Color Palette, Typography System, Metrics & Spacing.

### Library Screen — `LibraryComponentDoc` Widget
- Created `LibraryComponentDoc` in `library_section.dart`: a wrapper that shows the **exact Dart file path** and a semantic description above every live component demo.
- Applied across all 5 views:
  - `cells_view.dart`: Buttons, Inputs, InputNumber / OrganismFormat, Toggles/Badges, Box/ListTile, Chips.
  - `plasma_view.dart`: Z-Index scale, Dialog, Toast, Popover, Depth/ZStack, Shadow/Radii, DataViz palette, Responsivity.
  - `tissues_view.dart`: TissueCard, FormField/DateField, ButtonBar, TissueMenu, Tabs, Stepper/Select, Pipeline, Alert, EmptyState, ListCard.
  - `organs_view.dart`: System Modals, NavBoat shell.

### Bug Fixes (EOD)
- **`tissues_view.dart`**: Fixed unmatched parenthesis in `_buildListCardsSection` — `TissueListCard` closing bracket misaligned after refactor.
- **`theme_view.dart`**: Replaced non-existent `colors.secondary` and `colors.destructive` with valid tokens `colors.stone200` and `colors.error` respectively.

---

## 2026-04-10 · GitHub Actions & CI/CD

- **Deployment Debug**: Investigated `git exit code 128` error in GitHub Actions workflow blocking the `ogranism_library` GitHub Pages deploy.
- **Checkout Fix**: Ensured repository is correctly checked out before Pages deploy step.
- **Node.js Deprecation**: Addressed Node.js 20 deprecation warnings in workflow YAML.
- **Status**: CI/CD pipeline stabilized for GitHub Pages auto-deployment.

---

## 2026-04-09 · ERP Architecture Standardization, DB Migration & Session Cleanup

### UI Architecture
- **`ManagedListViewPane`**: Migrated all list modules (Masters, Items, Production) to use this unified controller-less pane. Centralizes search, tab handling, and pagination.
- **Global Pane Width**: Standardized left pane to **380px** via `AppTheme.masterPaneWidth = 380.0`; removed per-screen overrides.
- **Branding Cleanup**: Renamed "Masters v3" → **Masters**, "Items V3" → **Items**; removed legacy sidebar duplicates.

### Organism Design System — Stabilization
- **Iconography Tokens**: Defined semantic icon size constants (`iconSizeXs` → `iconSizeLg`) and tokenized icon colors.
- **Full Lucide Migration**: All components (`CellButton`, `TissueDatePicker`, etc.) migrated from Material Icons to `LucideIcons`.
- **`NavBoat` Organ**: Implemented collapsible Sidebar/Rail navigation shell.
  - Rail width fixed at 84px with stacked "Icon over Name" layout.
  - Resolved header overflow (116px width collision).
- **Lib Cleanup**: Removed `LibraryPreview` redundancy; registered `NavBoat` in `index.dart`.

### Database — Cutting Cards FY 26-27 Pivot (`IMMBE2627`)
- **Table**: Cloned `sb_CUTTING_CARDS` structure → `IMMBE2627.sb_cuttingcards`.
- **Relational Integrity**: Added `UNIQUE(code)` to `IMMBE2627.sq_MASTER`; FK from `sb_cuttingcards.mill_name` → `sq_MASTER.code`.
- **Aggregated View `vw_cutting_cards`**: Live analytics — `total_cost`, `short_pct`, `pc_pct`, `cost_per_pc`; joins `sq_CUTDET` with new header table.
- **Service Update**: `CuttingCardsService` re-pointed to `IMMBE2627` schema and new view.
- **View Naming Convention**: Instituted `sb_vw_` (Supabase native) and `sq_vw_` (SQL mirror) prefixes for all 12 views in `IMMBE2627`. Renamed 11 views; updated all Flutter services and models.

### Workspace Audit
- **Legacy Tooling Removed**: Deleted `.claude/`, `.superpowers/`, `docs/superpowers/` (old CLI artifacts).
- **Log Relocation**: Moved `frontend_log.md` to `docs/logs/`.
- **`docs/MASTER_REFERENCE.md`**: Created as single source of truth for ATYPE mapping, Production Flow (O-series), and SQL safety rules.

---

## 2026-04-08 · ERP Typography, Navigation, Tissues Architecture

- **Typography Refinement**: Tightened heading scales and numeric font (`JetBrains Mono`) across ERP screens.
- **Tissues Category**: Finalised `OrganismUI` library — added `listHeaderSection`, `pagination`, and `scrollableList` as standard Tissues.
- **`PackingSlipsScreen` Refactor**: Migrated to use new Tissue components for visual consistency.
- **Navigation Work**: Continued `ManagedListViewPane` rollout; resolved tab-state bugs.

---

## 2026-04-06–07 · Authentication, RBAC & Emerald Preview

- **Email Auth Migration**: Replaced phone-based auth with email/username login in `AuthService` and `LoginScreen`.
- **Supabase Schema**: Added `username` field + auto-sync trigger for user profiles.
- **RBAC Foundation**: Set up centralized profile management in Supabase; implemented auth guard protecting all app routes.
- **Emerald Theme Login**: Built high-fidelity "Emerald Light Mode" login UI.
- **`ambaji_preview.html`**: Restored design system HTML documentation page.

---

## 2026-04-05 · Foundation — Schema Migration Setup & Component Catalog

- **Schema Migration**: Initial setup of `IMMBE2627` (FY 26-27) Supabase schema alongside Airbyte `IMMBE2526` mirror.
- **Emerald Refresh Phase 1**:
  - Defined `AppColors` (Emerald/Slate) and `AppTheme` (VisualDensity.compact + JetBrains Mono).
  - Replaced Material Icons with `LucideIcons` in `Sidebar` and `TopAppBar`.
  - **Production Module — Grey Inward**: Updated icons/colors, high-density layout, mono fonts.
- **Component Catalog Expansion**: Initiated 200+ component design system based on Supabase design system audit. Goal: definitive "Ambaji 100" visual source of truth for all textile workflows.
- **Backup Script**: Created `backup_erp.ps1` PowerShell script for timestamped snapshots (~240MB clean).

---

## Conventions & Rules
- **DB Target**: All FY 26-27 work targets `IMMBE2627`; read-only legacy data from `IMMBE2526`.
- **View Naming**: `sb_vw_` = Supabase native, `sq_vw_` = SQL mirror views.
- **SQL Safety**: Always include `TYPE` in BILLS JOINs to avoid fan-out. Pending = `CLOSED IS NULL OR '' OR 'N'`.
- **Theme Access**: Always use `OrganismTheme.colorsOf(context)` — never static getters.
- **State Management**: `StatefulWidget` + Service singletons (no Riverpod/Bloc yet).
