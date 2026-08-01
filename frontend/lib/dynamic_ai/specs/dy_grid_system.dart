/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC AI GRID SYSTEM SPECS (dy_grid_system.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized layout specification & Base-12 grid system for Dynamic AI Engine.
   - Defines flex ratios, fixed pane dimensions, breakpoint boundaries, and 
     layout constants across all 2-pane, 3-pane, and 4-pane ERP module views.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Base-12 Grid System: Total flex = 12.
   - Table Mode (DVT): Flex 12 full width & column span divider.
   - List Mode (DL + DCP): Fixed 360px Master List + Flex 8 Content Inspector.
   - Cards Mode (DVC + DDP): Flex 9 Cards Grid (75%) + Flex 3 Details Pane (25%).
   - Board Mode (Kanban): 3-Pane Equal (flex 4 each) or 4-Pane Equal (flex 3 each).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Always multiply fixed metrics by `theme.scaling` for HiDPI/Density responsiveness.
================================================================================
*/

abstract class DyGridSystem {
  // =========================================================================
  // 1. SIDEBAR WIDTHS & VIEWPORT BREAKPOINTS (TOP DEFINITIONS)
  // =========================================================================
  static const double sidebarExpandedWidth = 240.0;
  static const double sidebarCollapsedWidth = 56.0;

  // Viewport Breakpoint Boundaries
  static const double breakpointMobile = 768.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;
  static const double breakpointDesktopXl = 1920.0;

  // =========================================================================
  // DAB POPOVER WIDTH MULTIPLIER STANDARDS
  // =========================================================================
  static const double popWidthStandard = 200.0; // 200px (Submodule, Slider, Select, Overflow)
  static const double popWidthLarge = 400.0;    // 400px (Split Date Range Popover: 140px + 260px)

  // =========================================================================
  // 2. ACTIVE ERP VIEW MODE SPLIT RATIOS (BY USE CASE & DYNAMIC COMPONENT)
  // =========================================================================
  static const int flexBase = 12;

  // A. Table View Mode (DVT - DynamicDenseTable)
  // Uses full 12-column grid system to neatly organize column width spans
  static const int flexTableFull = 12;

  // B. List View Mode (DL + DCP / DDP - DynamicList + DynamicContentPane)
  // Left Master List is fixed at 360px; right Detail Inspector uses internal flex 8
  static const double fixedListMasterWidth = 360.0;
  static const int flexListContentInspector = 8;

  // C. Cards View Mode (DVC + DDP - DyViewCard + DyDetailsPane)
  // Left Grid takes flex 9 (75%); Right Inspector takes flex 3 (25%)
  static const int flexCardsGrid = 9;         // 75% (1224px on 1920px)
  static const int flexCardsInspector = 3;    // 25% (408px on 1920px)

  // D. Board View Mode (Kanban Pipeline 4-Stage Columns)
  static const int flexBoard4PaneEqual = 3;   // 4 Stage Panes x Flex 3 = 12 (25.0% each)

  // =========================================================================
  // 3. SECONDARY & UNUSED EXAMPLE LAYOUT PATTERNS (REFERENCE GALLERY)
  // =========================================================================
  // Golden Ratio Splits
  static const int flexGoldenMaster = 8;      // 66.6% (1088px on 1920px)
  static const int flexGoldenDetail = 4;      // 33.3% (544px on 1920px)
  static const int flexGoldenInvertedMaster = 4; // 33.3%
  static const int flexGoldenInvertedDetail = 8; // 66.6%

  // Equal 2-Pane Split
  static const int flexEqualSplit = 6;        // 50% / 50% (816px each)

  // 3-Pane Standard Splits (Sum = 12)
  static const int flex3PaneStandardLeft = 2; // 16.6% (272px)
  static const int flex3PaneStandardCenter = 7;// 58.4% (952px)
  static const int flex3PaneStandardRight = 3; // 25.0% (408px)

  static const int flex3PaneStandardInvertedLeft = 3;  // 25.0% (408px)
  static const int flex3PaneStandardInvertedCenter = 7;// 58.4% (952px)
  static const int flex3PaneStandardInvertedRight = 2; // 16.6% (272px)

  // 3-Pane Focus Workspace (Sum = 12)
  static const int flex3PaneFocusLeft = 2;    // 16.6% (272px)
  static const int flex3PaneFocusCenter = 8;  // 66.6% (1088px)
  static const int flex3PaneFocusRight = 2;   // 16.6% (272px)
}
