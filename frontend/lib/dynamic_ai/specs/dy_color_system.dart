/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC COLOR SYSTEM (dy_color_system.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Authoritative 6-color scale specification for Ambaji Sarees ERP pipeline 
     statuses, stage indicators, badges, and charting visualization.
   - Leverages Tailwind color shades from `shadcn_flutter` (`shad.Colors`).
   - Theme Primary Context: Teal 500 (Light Primary) / Amber 500 (Dark Primary).

2. COLOR SCALE SPECIFICATION (500 = Solid Accent, 100 = Light Surface Container):
   - Red:     `red[500]` / `red[100]` (Danger, Rejected, Overdue)
   - Green:   `emerald[500]` / `emerald[100]` (Success, Paid, Received)
   - Yellow:  `yellow[500]` / `yellow[100]` (Pending Action, Hold)
   - Orange:  `orange[500]` / `orange[100]` (Warning, In Cutting, Partial)
   - Indigo:  `indigo[500]` / `indigo[100]` (Processing, Mill Dispatch, In Transit)
   - Fuchsia: `fuchsia[500]` / `fuchsia[100]` (Special Stage, Custom Audit, Voucher Margin)
================================================================================
*/

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DyColorSystem] — Master ERP 6-Color Scale & Semantic Token System.
abstract class DyColorSystem {
  // =========================================================================
  // 1. BRAND & THEME PRIMARIES
  // =========================================================================
  static Color get primaryTeal => shad.Colors.teal[500]; // Light Theme Primary (#14B8A6)
  static Color get primaryTealSurface => shad.Colors.teal[100];
  static Color get primaryTealText => shad.Colors.teal[700];

  static Color get primaryAmber => shad.Colors.amber[500]; // Dark Theme Primary (#F59E0B)
  static Color get primaryAmberSurface => shad.Colors.amber[100];
  static Color get primaryAmberText => shad.Colors.amber[700];

  // =========================================================================
  // 2. THE 6-COLOR ERP STATUS SCALE (100 = Surface, 500 = Primary Solid)
  // =========================================================================
  
  // SCALE 1: RED (Danger, Cancelled, Overdue, Shortage)
  static Color get red100 => shad.Colors.red[100];
  static Color get red500 => shad.Colors.red[500];
  static Color get red600 => shad.Colors.red[600];

  // SCALE 2: GREEN / EMERALD (Success, Completed, Paid, Received)
  static Color get green100 => shad.Colors.emerald[100];
  static Color get green500 => shad.Colors.emerald[500];
  static Color get green600 => shad.Colors.emerald[600];

  // SCALE 3: YELLOW (Pending Action, Hold, Attention Required)
  static Color get yellow100 => shad.Colors.yellow[100];
  static Color get yellow500 => shad.Colors.yellow[500];
  static Color get yellow600 => shad.Colors.yellow[600];

  // SCALE 4: ORANGE (Warning, In Cutting, Partial Dispatch)
  static Color get orange100 => shad.Colors.orange[100];
  static Color get orange500 => shad.Colors.orange[500];
  static Color get orange600 => shad.Colors.orange[600];

  // SCALE 5: INDIGO (Processing, Mill Dispatch, In Transit)
  static Color get indigo100 => shad.Colors.indigo[100];
  static Color get indigo500 => shad.Colors.indigo[500];
  static Color get indigo600 => shad.Colors.indigo[600];

  // SCALE 6: FUCHSIA (Special Stage, Custom Audit, Voucher Margin)
  static Color get fuchsia100 => shad.Colors.fuchsia[100];
  static Color get fuchsia500 => shad.Colors.fuchsia[500];
  static Color get fuchsia600 => shad.Colors.fuchsia[600];

  // =========================================================================
  // 3. CHARTING & PALETTE ROTATION (5 CATEGORICAL COLORS)
  // =========================================================================
  static List<Color> get chartPalette => [
        shad.Colors.teal[500],
        shad.Colors.indigo[500],
        shad.Colors.amber[500],
        shad.Colors.emerald[500],
        shad.Colors.fuchsia[500],
      ];

  // =========================================================================
  // 4. HELPER RESOLVERS FOR BADGES & STAGE CONTAINERS
  // =========================================================================
  
  /// Resolves transparent background surface for light/dark theme badge chips.
  static Color resolveSurface(Color primary500, bool isDark) {
    if (isDark) {
      return primary500.withAlpha(35);
    }
    return primary500.withAlpha(20);
  }

  /// Resolves border color for stage badges.
  static Color resolveBorder(Color primary500, bool isDark) {
    if (isDark) {
      return primary500.withAlpha(120);
    }
    return primary500.withAlpha(180);
  }
}
