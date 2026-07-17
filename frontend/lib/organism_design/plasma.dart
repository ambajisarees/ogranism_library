/// ============================================================
/// PLASMA — Physics, Overlays & Mathematical Foundations
/// ============================================================
///
/// Plasma provides the invisible architectural forces that govern
/// how elements stack, float, and animate in the Z-axis.
/// It also houses Overlay primitives (dialogs, popovers, toasts)
/// that break out of the standard Widget tree.
///
/// Plasma is stateless physics — it defines motion rules, depth
/// laws, and overlay contracts. No business logic lives here.
///
/// Hierarchy:  Theme → **Plasma** → Cells → Tissues → Organs → Systems
///
/// Usage: Import via `package:textile_erp/organism_design/index.dart`
/// ============================================================
library;

// ── PHYSICS ENGINE ───────────────────────────────────────────

/// [PlasmaPhysics] — Animation curve and duration registry.
/// Defines canonical easing curves (easeOutExpo, spring, snappy)
/// and standardized durations (fast: 150ms, base: 250ms, slow: 400ms).
/// All component transitions must derive from these constants.
export 'plasma/physics.dart';

// ── Z-AXIS / DEPTH SYSTEM ────────────────────────────────────

/// [TissueZStack] / [TissueZLayer] — Absolute positioning bounds engine.
/// Handles semantic depth by rendering children at explicit z-index values.
/// `TissueZLayer` wraps each child with a positional offset and `zIndex`.
/// Use for overlay compositions, kinetic card stacks, and collision guards.
export 'plasma/z_stack.dart';

// ── OVERLAY PRIMITIVES ───────────────────────────────────────

/// [PlasmaDialog] — Focus-stealing blocking modal.
/// Renders as a centered surface above a dim scrim.
/// Accepts: `title`, `description`, `content` widget, `actions` buttons.
/// Uses scale-in + fade physics on entry/exit.
/// `PlasmaDialog.show(context: ...)` is the canonical call pattern.
export 'plasma/dialog.dart';

/// [PlasmaPopover] — Anchored contextual floating layer.
/// Renders its `content` in an Overlay positioned relative to `trigger`.
/// Dismisses on outside tap. Used by CellCombobox, TissueMenu, and TissueSelect.
/// zIndex: OrganismTheme.zIndexPopover (600).
export 'plasma/popover.dart';

/// [PlasmaToastManager] — Ephemeral status feedback system.
/// Singleton: `PlasmaToastManager.instance.show(context, message, variant: ...)`.
/// Auto-dismisses after 3s. Stacks in bottom-right corner.
/// zIndex: OrganismTheme.zIndexToast (700).
export 'plasma/toast.dart';
export 'plasma/drawer.dart';

/// [PlasmaContextMenu] — Right-click desktop context menu system.
export 'plasma/context_menu.dart';

/// [PlasmaHoverCard] — Delay-aware hover overlay system.
export 'plasma/hover_card.dart';
