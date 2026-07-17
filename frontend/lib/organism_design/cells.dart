/// ============================================================
/// CELLS — Indivisible Headless Atoms
/// ============================================================
///
/// Cells are the smallest renderable units in the Organism Design Language.
/// They carry NO business logic, NO state (usually), and NO layout opinions.
/// They exist purely to provide perfectly styled, theme-aware primitives.
///
/// Hierarchy:  Theme → Plasma → **Cells** → Tissues → Organs → Systems
///
/// Usage: Import via `package:textile_erp/organism_design/index.dart`
/// ============================================================
library;

// ── INTERACTION / CONTROLS ──────────────────────────────────

/// [CellButton] — Primary interactable action trigger.
/// Variants: primary, secondary, outline, ghost, destructive.
/// Sizes: standard (40px), compact (32px). Supports leading/trailing icons.
export 'cells/button.dart';

/// [CellMultiButton] — Segmented horizontal button group.
/// Eliminates internal borders between adjacent CellButtons.
/// Use for toggle groups (e.g. alignment, view mode switchers).
export 'cells/multi_button.dart';

/// [CellInput] — Universal naked text field.
/// Handles focus ring, prefix/suffix icons, search mode, multiline, error state.
/// Compact mode (32px) for high-density ERP grids.
export 'cells/input.dart';

/// [CellInputNumber] — Numeric precision text entry.
/// Blur-rounds to Indian number system (Lakhs/Crores).
/// Accepts min/max, step, suffix (e.g. "MTS", "PCS").
export 'cells/input_number.dart';

/// [CellCheckbox] — Physical boolean box.
/// Supports indeterminate state. isDisabled support included.
export 'cells/checkbox.dart';

/// [CellSwitch] — Sliding capsule binary toggle.
/// Animated thumb movement. Accepts onChanged callback.
export 'cells/switch.dart';

/// [CellRadio] — Standard mutually-exclusive scalar.
/// Use within a group sharing the same `groupValue`.
export 'cells/radio.dart';

/// [CellSlider] — Horizontal dragging track.
/// Bounded to primary theme accent. Supports min/max/divisions.
export 'cells/slider.dart';

/// [CellToggleGroup] — Grouped selection state controller.
/// Multi or single select mode. Used for filter bars and option sets.
export 'cells/toggle_group.dart';

// ── DATA INPUT / SELECTION ───────────────────────────────────

/// [CellDatePicker] — Popover-wrapped calendar for date selection.
/// Returns a `DateTime`. Renders a `CellCalendar` inside a `PlasmaPopover`.
export 'cells/date_picker.dart';

/// [CellTimePicker] — Popover-wrapped time selector.
/// Virtualizes 30-minute ERP standard jump blocks.
export 'cells/time_picker.dart';

/// [CellCombobox] — Searchable async dropdown for large datasets.
/// Designed for 10,000+ item master lookups.
/// Opens a PlasmaPopover wrapping a filtered `ListView.builder`.
export 'cells/combobox.dart';

/// [CellAutocomplete] — Auto-completing text input search field.
export 'cells/autocomplete.dart';

/// [CellCalendar] — Standalone month-grid calendar widget.
/// Used headlessly by CellDatePicker; can be embedded directly.
export 'cells/calendar.dart';

/// [CellInputChip] — Tokenized tag entry field.
/// Allows adding/removing labels as visual chips inside an input area.
export 'cells/input_chip.dart';

// ── DISPLAY / INDICATORS ─────────────────────────────────────

/// [CellBadge] — Non-interactive semantic density pill.
/// Variants: primary, success, warning, error, neutral.
/// Optional `onDismiss` to render an × close glyph.
export 'cells/badge.dart';

/// [CellCountBadge] — Numeric notification counter overlay.
/// Renders a circular badge with a count. Used on nav items or avatars.
export 'cells/count_badge.dart';

/// [CellStatusDot] — Pulsing live connection/sync state indicator.
/// Variants: active (green pulse), idle, error, warning, syncing (primary pulse).
/// Animated for `active` and `syncing`; static for others.
export 'cells/status_dot.dart';

/// [CellAvatar] — Shape encapsulating initials parser.
/// Accepts `name` (auto-generates initials) or `imageProvider`.
/// Optional `statusColor` dot anchored to bottom-right.
export 'cells/avatar.dart';

/// [CellFilterChip] — Toggle metadata chip for grid filtering.
/// Visually selected/deselected; no dropdown — pure boolean toggle.
export 'cells/filter_chip.dart';

/// [CellTag] — Removable labeled tag chip.
/// Distinct from CellFilterChip (toggle) and CellBadge (non-interactive status).
/// Variants: neutral, accent, success, warning, error.
/// Optional `onRemove` renders a × button. Optional `onTap` for tappable tags.
/// Use for applied filter values, multi-select results, and account type chips.
export 'cells/tag.dart';

/// [CellProgressBar] — Linear mathematical progress visualizer.
/// Accepts `value` as 0.0–1.0. Animates on change.
export 'cells/progress_bar.dart';

/// [CellKbd] — Hard-edge styled keyboard key visualization.
/// Renders a key label (e.g. 'ESC', '⌘K') in monospace in a bordered chip.
export 'cells/kbd.dart';

/// [CellTooltip] — Z-axis hovering semantic pop.
/// Dark dropshadow overlay appearing on hover/long-press.
export 'cells/tooltip.dart';

/// [CellSkeleton] — Structural loading shimmer box.
/// Renders an animated shimmer overlay for async loading states.
export 'cells/skeleton.dart';

/// [CellImage] — Network image primitive bounded by skeleton loading limits.
export 'cells/image.dart';

/// [CellIcon] — Explicit sizing tokens matching the OrganismTheme icon definitions.
export 'cells/icon.dart';

/// [CellCurrencyDisplay] — Stripped ₹ string mapping tabular digit logic.
export 'cells/currency_display.dart';

/// [CellEmptyValue] — Strict em-dash primitive to avoid arbitrary null mapping.
export 'cells/empty_value.dart';

/// [CellMenuItem] — Interactive row atom for menus and list groups.
export 'cells/menu_item.dart';

// ── LAYOUT / STRUCTURAL ──────────────────────────────────────

/// [CellBox] — Atomic surface container.
/// Implements 1px border + standardized `borderMd` radius.
/// Use as the base card shell. Accepts padding and decoration overrides.
export 'cells/box.dart';

/// [CellDivider] — Exact 1px structural membrane.
/// Respects theme `border` color. Horizontal by default. Accepts margins.
export 'cells/divider.dart';

/// [CellListTile] — Standard row element for list views.
/// Maps leading widget, title, subtitle, and trailing widget.
/// Handles `onTap` with inkwell ripple bounded to theme.
export 'cells/list_tile.dart';

/// [CellLabel] — Field title enforcing text requirements.
/// Renders label text + optional required asterisk (*).
export 'cells/label.dart';

/// [CellPlaceholder] — Development skeleton block.
/// Renders a colored placeholder box for layout prototyping.
export 'cells/placeholder.dart';

/// [CellAlert] — Inline feedback banner.
/// Semantic variants: info, success, warning, error.
export 'cells/alert.dart';

/// [CellNavItem] — Sidebar/Rail navigation entry.
/// Handles selected/unselected state with icon + label.
export 'cells/nav_item.dart';

/// [CellLogo] — Ambaji Sarees brand logotype renderer.
/// Renders the branded wordmark or icon per given mode.
export 'cells/logo.dart';

/// [CellTabItem] — Interactive tab element for page-level navigation.
export 'cells/tab_item.dart';
export 'cells/card_avatar.dart';

/// [CellGap] — Spatial utility cell.
/// Enforces strict multiples of OrganismTheme.spacingMd.
export 'cells/spatial.dart';

// ── FOCUS / INTERACTION SYSTEM ───────────────────────────────

/// [OrganismFocus] — Focus ring management system.
/// Provides programmatic focus control and ring rendering.
/// Used internally by CellInput, CellButton, and other interactive cells.
export 'cells/focus.dart';
