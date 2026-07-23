import 'package:flutter/material.dart';

class OrganismMetrics {
  // --- MOTION & PHYSICS ---
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationStandard = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveIn = Curves.easeInCubic;
  static const Curve curveOut = Curves.easeOutCubic;

  // --- GEOMETRY & BORDERS ---
  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusPill = 999.0;

  static final BorderRadius borderSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderPill = BorderRadius.circular(radiusPill);

  // --- SPACING & SIZING ---
  static const double spacing2Xs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2Xl = 48.0;

  static const double buttonHeightCompact = 32.0;
  static const double buttonHeightStandard = 40.0;
  static const double buttonHeightLarge = 48.0;

  static const double sidebarWidth = 240.0;
  static const double sidebarWidthCollapsed = 56.0;
  static const double masterPaneWidth = 360.0;
  static const double masterPaneWidthCompact = 300.0;
  static const double tabHeightPill = 42.0;

  // --- RESPONSIVE BREAKPOINTS ---
  /// < breakpointSm: single-pane, sidebar force-collapsed
  static const double breakpointSm = 900.0;
  /// breakpointSm..breakpointMd: split-pane compact (masterPaneWidthCompact), sidebar force-collapsed
  static const double breakpointMd = 1280.0;
  /// > breakpointMd: full layout (masterPaneWidth), sidebar toggleable
  static const double breakpointLg = 1600.0;
  static const double tabHeightUnderline = 48.0;
  static const double topbarHeight = 48.0;
  static const double footerBuffer = 120.0;

  // --- ICONOGRAPHY (The Vision) ---
  static const double iconSizeXs = 12.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 20.0;
  static const double iconSizeLg = 28.0;
  static const double iconSizeXl = 48.0;

  // --- Z-INDEX GOVERNANCE ---
  static const int zIndexDropdown = 1000;
  static const int zIndexPopover = 2000;
  static const int zIndexDialog = 3000;
  static const int zIndexToast = 4000;
  static const int zIndexTooltip = 5000;
}
