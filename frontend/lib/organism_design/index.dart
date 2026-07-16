/// ============================================================
/// ORGANISM DESIGN SYSTEM — Master Index
/// ============================================================
///
/// Single import point for the entire Organism Design Language:
///   `import 'package:textile_erp/organism_design/index.dart';`
///
/// Ctrl+Click / Cmd+Click any component name to jump to its file.
///
/// ┌─────────────────────────────────────────────────────┐
/// │  ARCHITECTURE HIERARCHY                             │
/// │                                                     │
/// │  🩸 Theme   — Design tokens & global contracts      │
/// │  ⚡ Plasma  — Physics, Z-axis, overlay primitives   │
/// │  🦠 Cells   — Headless atoms (buttons, inputs…)    │
/// │  🧬 Tissues — Functional molecules (cards, forms…)  │
/// │  🫀 Organs  — Assembled layout blocks (NavRail…)    │
/// │  🧠 Systems — Page-level master layouts (coming)    │
/// └─────────────────────────────────────────────────────┘
///
/// ============================================================

// ── 🩸 THEME ─────────────────────────────────────────────────
// [OrganismTheme]      — Central design token bridge.
//                        Access: OrganismTheme.colorsOf(context)
// [OrganismColors]     — 150-property dynamic color struct.
// [OrganismBreakpoint] — Viewport tier enum (xs/sm/md/lg/xl).
// [OrganismFormat]     — Singleton string formatter (currency, Indian numbers, dates).
export 'theme.dart';

// ── ⚡ PLASMA ──────────────────────────────────────────────────
// [PlasmaPhysics]         — Animation curve & duration registry.
// [TissueZStack]          — Absolute depth positioning engine.
// [TissueZLayer]          — Single depth layer for TissueZStack.
// [PlasmaDialog]          — Focus-stealing blocking modal.
// [PlasmaPopover]         — Anchored contextual float layer.
// [PlasmaToastManager]    — Ephemeral auto-dismiss toast system.
export 'plasma.dart';

// ── 🦠 CELLS ──────────────────────────────────────────────────
//
// INTERACTION / CONTROLS
// [CellButton]       — Action trigger. Variants: primary/secondary/outline/ghost/destructive.
// [CellMultiButton]  — Segmented button group (merged borders).
// [CellInput]        — Naked text field with focus ring, icons, error state.
// [CellInputNumber]  — Numeric entry with Indian Lakhs blur-rounding.
// [CellCheckbox]     — Physical boolean box. Supports indeterminate + disabled.
// [CellSwitch]       — Sliding capsule binary toggle.
// [CellRadio]        — Mutually exclusive scalar option.
// [CellSlider]       — Horizontal dragging track.
// [CellToggleGroup]  — Multi/single selection group controller.
//
// DATA INPUT / SELECTION
// [CellDatePicker]   — Popover calendar. Returns DateTime.
// [CellTimePicker]   — Popover time selector (30-min ERP blocks).
// [CellCombobox]     — Searchable async dropdown for 10k+ item master.
// [CellAutocomplete] — Auto-completing text input search field.
// [CellCalendar]     — Standalone month-grid (used by CellDatePicker).
// [CellInputChip]    — Tokenized tag entry field (multi-label input).
//
// DISPLAY / INDICATORS
// [CellBadge]        — Semantic density pill. Variants: primary/success/warning/error/neutral.
// [CellCountBadge]   — Circular numeric notification counter.
// [CellStatusDot]    — Pulsing live connection/sync state indicator.
// [CellAvatar]       — Initials parser + status dot.
// [CellFilterChip]   — Boolean toggle chip for list filtering.
// [CellTag]          — Removable labeled tag chip.
// [CellProgressBar]  — Linear 0.0–1.0 progress visualizer.
// [CellKbd]          — Keyboard key visualization chip.
// [CellTooltip]      — Z-axis hover semantic pop.
// [CellSkeleton]     — Structural shimmer loading box.
//
// LAYOUT / STRUCTURAL / SPATIAL
// [CellBox]          — Atomic surface: 1px border + standard radius.
// [CellDivider]      — Exact 1px structural membrane.
// [CellListTile]     — Standard row: leading / title / subtitle / trailing.
// [CellLabel]        — Field title with optional required (*) marker.
// [CellPlaceholder]  — Dev skeleton block for layout prototyping.
// [CellAlert]        — Inline semantic banner (info/success/warning/error).
// [CellNavItem]      — Sidebar/Rail navigation entry with selection state.
// [CellLogo]         — Ambaji Sarees brand logotype renderer.
// [CellGap]          — Spatial utility: strict multiple of spacingMd.
// [CellPad]          — Spatial utility: themed padding wrapper.
//
// FOCUS / INTERACTION SYSTEM
// [OrganismFocus]    — Focus ring management and programmatic control.
export 'cells.dart';

// ── 🧬 TISSUES ────────────────────────────────────────────────
//
// SURFACE / CONTAINERS
// [TissueCard]           — Density-standard ERP surface. Compose with Header + Content.
// [TissueCardHeader]     — Title + description header for TissueCard.
// [TissueCardContent]    — Padded body section for TissueCard.
// [TissuePageHeader]     — Full-width page title bar with optional trailing actions.
// [TissueAccordion]      — Expand/collapse animated content container.
//
// FORM / DATA ENTRY
// [TissueFormField]      — Label + input wrapper with validation error track.
// [TissueReadOnlyField]  — Locked metadata capsule (disabled styling).
// [TissueDateField]      — Labeled date entry: FormField + CellDatePicker.
// [TissueDropdown]       — Labeled dropdown selector molecule.
// [TissueSelect<T>]      — Typed value selector with generic item list.
// [TissueStepper]        — Integer quantity adjuster (−/+ buttons).
//
// NAVIGATION / LAYOUT CONTROLS
// [TissueTabs]           — Pill-style section navigation tabs.
// [TissuePagination]     — Page-number driven data grid navigator.
//
// ACTIONS / MENUS
// [TissueMenu]           — Contextual PopoverMenu from TissueMenuItemData list.
// [TissueButtonBar]      — Horizontal aligned action bar for multiple CellButtons.
//
// DATA DISPLAY
// [TissueListCard]       — Elevated registry row with selection state.
// [TissuePipeline]       — Linear O-series stage stepper (O3→O4→…→O45).
//
// STATUS / FEEDBACK
// [TissueAlert]          — Semantic callout block: info/success/warning/error.
// [TissueEmptyState]     — Centered no-data placeholder (icon + title + message).
export 'tissues.dart';

// ── 🫀 ORGANS ─────────────────────────────────────────────────
// [NavRail]             — Consolidated control rail with collapse physics.
// [OrganPaneHeader]     — Dual-track registry header (Identity + Search).
// [OrganPaneList]       — Registry list with sticky pagination track.
// [OrganSectionCanvas]  — Unified Detail Canvas with sticky floating header.
export 'organs.dart';

// ── 🧠 SYSTEMS (Level 5) ─────────────────────────────────────
// [SystemAppShell]     — The foundational scaffold for the desktop ERP.
// [SystemMasterLayout] — Split-pane layout for Master registries (List/Detail).
export 'systems.dart';

// ── 🧶 DOMAIN (Level 6) ──────────────────────────────────────
// Textile ERP specific business primitives (Stage Badges, Challan Cards, etc).
export 'domain.dart';

// ── 📚 LIBRARY ────────────────────────────────────────────────
// [OrganismLibraryScreen] — Interactive design system documentation browser.
//                           5-tab PillNav: Theme / Plasma / Cells / Tissues / Organs.
export 'library/library_shell.dart';

// ── 🛠️ UTILITIES ──────────────────────────────────────────────
// [localeUtils] — Indian number locale helpers.
export 'utils/locale_utils.dart';
