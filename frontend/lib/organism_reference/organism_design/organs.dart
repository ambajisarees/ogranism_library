/// ============================================================
/// ORGANS — Complex Assembled Architecture
/// ============================================================
///
/// Organs are pre-assembled, fully functional layout blocks.
/// They combine Cells + Tissues + Plasma into complete UI regions
/// that handle their own internal state and navigation contracts.
///
/// Unlike Tissues (which are stateless molecules), Organs:
///   • Manage routing or multi-panel state
///   • Handle transitions between UI regions
///   • Are the outermost reusable layer before full System pages
///
/// Hierarchy:  Theme → Plasma → Cells → Tissues → **Organs** → Systems
///
/// Usage: Import via `package:textile_erp/organism_design/index.dart`
/// ============================================================
library;

// ── NAVIGATION SHELL ─────────────────────────────────────────

/// [NavRail] — The consolidated master control rail for the ERP.
///
/// The primary structural organ of the ERP, consolidating both top navigation 
/// and sidebar navigation. 
///   • **Control Layer**: Fixed top section for identity, toggle, search, and profile.
///   • **Modules Section**: Scrollable area for module navigation.
///
/// Features a dynamic width (240px expanded vs 84px collapsed) and 
/// manages the active route index.
export 'organs/nav_boat.dart';
export 'organs/nav_rail.dart';
export 'organs/topbar.dart';
export 'organs/workspace_controller.dart';

// ── MASTERDETAIL REGISTRY ────────────────────────────────────
export 'organs/pane_header.dart';
export 'organs/pane_list.dart';
export 'organs/section_canvas.dart';
export 'organs/add_canvas.dart';

// ── CREATION CANVAS LAYOUTS ───────────────────────────────────
export 'organs/three_pane_canvas.dart';
