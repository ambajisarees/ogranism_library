/// ============================================================
/// TISSUES — Functional Molecules
/// ============================================================
///
/// Tissues compose multiple Cells into higher-level UI molecules.
/// They carry light layout logic, semantic structure decisions, and
/// may hold minimal local UI state (e.g. accordion open/closed).
/// They never perform network calls or hold business data.
///
/// Hierarchy:  Theme → Plasma → Cells → **Tissues** → Organs → Systems
///
/// Usage: Import via `package:textile_erp/organism_design/index.dart`
/// ============================================================

// ── SURFACE / CONTAINERS ─────────────────────────────────────

/// [TissueCard] — Standard ERP surface container.
/// Implements the density standard: consistent internal padding,
/// 1px border, and `borderMd` radius. Accepts a list of `children`
/// laid out in a Column. Compose with TissueCardHeader + TissueCardContent.
export 'tissues/card.dart';

/// [TissueCardHeader] — Title + optional description block for TissueCard.
/// Renders at the top of a TissueCard with standard padding and divider.
export 'tissues/card_header.dart';

/// [TissueCardContent] — Content body section for TissueCard.
/// Applies standard inner padding. Accepts any child widget.
export 'tissues/card_content.dart';

/// [TissuePageHeader] — Full-width page-level title bar.
/// Renders a heading, optional subtitle, and optional trailing actions.
/// Used at the top of ERP module screens.
export 'tissues/page_header.dart';

/// [TissueAccordion] — Z-animated cross-fade layout container.
/// Click to expand/collapse content. Uses AnimatedCrossFade internally.
/// Common use: collapsible filter panels, detail sections.
export 'tissues/accordion.dart';

// ── FORM / DATA ENTRY ────────────────────────────────────────

/// [TissueFormField] — Labeled input wrapper.
/// Marries any Cell input widget (CellInput, CellInputNumber, etc.)
/// with a CellLabel, optional hint text, and validation error track.
/// isRequired adds the asterisk (*) marker.
export 'tissues/form_field.dart';

/// [TissueReadOnlyField] — Visually locked metadata capsule.
/// Renders a label + static value with disabled styling.
/// Use for record detail panels where values cannot be edited.
export 'tissues/read_only_field.dart';

/// [TissueDateField] — Labeled date entry molecule.
/// Wraps TissueFormField + CellDatePicker into a single composable unit.
/// Returns DateTime via onChanged callback.
export 'tissues/date_field.dart';

/// [TissueDropdown] — Labeled dropdown selector molecule.
/// Wraps a CellCombobox or standard popup menu with TissueFormField.
/// Accepts a typed `List<T>` with an `itemLabelBuilder`.
export 'tissues/dropdown.dart';

/// [TissueSelect<T>] — Typed value selector.
/// Standardized choice interface: opens a styled selection sheet.
/// Accepts `items`, `itemLabelBuilder`, `onChanged`, `placeholder`.
/// Variant of TissueDropdown with explicit generic type safety.
export 'tissues/select.dart';

/// [TissueStepper] — Integer quantity adjuster.
/// − / + buttons flanking a display value. Accepts `min`, `max`, `step`.
/// Use for PCS counts, quantity adjustments in production slips.
export 'tissues/stepper.dart';

// ── NAVIGATION / LAYOUT CONTROLS ─────────────────────────────

/// [TissueTabs] — Pill-style section navigation tabs.
/// Horizontal scrollable tab row with animated active indicator.
/// Used for sub-section switching within screens and in the Library header.
/// Variant: `pill` (default) for compact headers, `underline` for full-width.
export 'tissues/tabs.dart';

/// [TissueTabChrome] — Shadcn-styled page-level tab bar (56px).
export 'tissues/tab_chrome.dart';

/// [TissuePagination] — Page-number driven data grid navigator.
/// Renders prev/next + numbered page buttons.
/// Used beneath large list views with server-side pagination.
export 'tissues/pagination.dart';

// ── ACTIONS / MENUS ──────────────────────────────────────────

/// [TissueMenu] — Contextual action dropdown.
/// Wraps a PlasmaPopover with a standardized list of `TissueMenuItemData`.
/// Accepts `child` as the trigger widget (usually a CellButton).
/// `isDestructive` items render in error color.
export 'tissues/menu.dart';

/// [TissueButtonBar] — Horizontal action alignment bar.
/// Forces equal spacing between multiple CellButtons.
/// Use in page headers, table toolbars, and modal footers.
export 'tissues/button_bar.dart';

// ── DATA DISPLAY ─────────────────────────────────────────────

/// [TissueListCard] — Elevated list tile for registry views.
/// Provides a selection state (highlighted border + background).
/// Slots: `title`, `subtitle`, `leading`, `trailing`, `onTap`, `isSelected`.
export 'tissues/list_card.dart';

/// [TissuePipeline] — Horizontal linear production stage stepper.
/// Maps EMPIRE O-series stages (O3 → O4 → O5 → … → O45).
/// `PipelineStageData` → `isCompleted`, `isActive`, `label`.
export 'tissues/pipeline.dart';

// ── STATUS / FEEDBACK ────────────────────────────────────────

/// [TissueAlert] — Semantic callout feedback block.
/// Variants: primary (info), success, warning, error.
/// Accepts `title`, `message`, `icon`, and an optional `action` button.
export 'tissues/alert.dart';

/// [TissueEmptyState] — Standardized no-data placeholder.
/// Renders a centered icon, title, and message.
/// Use when list data is empty or filters return zero results.
export 'tissues/empty.dart';

// ── HEAVYWEIGHTS (ERP Core) ──────────────────────────────────
export 'tissues/data_grid.dart';
export 'tissues/command_palette.dart';
export 'tissues/file_upload.dart';
export 'tissues/image_gallery.dart';

// ── DASHBOARD & DISPLAY (Analytics & Logs) ───────────────────
export 'tissues/kpi_card.dart';
export 'tissues/timeline.dart';
export 'tissues/comments.dart';
export 'tissues/inline_edit.dart';
export 'tissues/date_range_picker.dart';
// ── WORKFLOW & NAVIGATION (NEW) ──────────────────────────────
export 'tissues/filter_bar.dart';
export 'tissues/bulk_action_bar.dart';
export 'tissues/wizard.dart';
export 'tissues/accordion_group.dart';
export 'tissues/breadcrumb.dart';

// ── PRODUCTION SPECIFIC (NEW) ────────────────────────────────
export 'tissues/kanban.dart';
export 'tissues/barcode_scanner.dart';

// ── DESKTOP ERGONOMICS (NEW) ─────────────────────────────────
export 'tissues/menu_group.dart';
