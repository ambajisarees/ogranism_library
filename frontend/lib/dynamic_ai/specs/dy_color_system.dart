/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC COLOR SYSTEM (dy_color_system.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Master ERP color system combining `shadcn_flutter` native ColorScheme tokens,
     custom protected ERP surface canvas tokens, and a 6-color pipeline scale.
   - Theme Mode Mapping (Configured in main.dart):
     * Light Theme: `ColorSchemes.lightSlate` + Teal Accent (`shad.Colors.teal[500]`)
     * Dark Theme: `ColorSchemes.darkStone` + Amber Accent (`shad.Colors.amber[500]`)

2. SURFACE HIERARCHY & CANVAS TOKENS:
   - Light Mode Surface Hierarchy:
     * Level 0 Root Scaffold Ground: Slate 50 (`#F8FAFC`) — `resolveRootBackground(isDark)`
     * Level 1 Canvas Header / Tab Surface: Slate 10 (`#FCFDFE`) — `resolveSurfaceCanvas(isDark)`
     * Level 2 Elevated Cards / Tables: Slate 0 / White (`#FFFFFF`) — `colors.card`
   - Dark Mode Surface Hierarchy:
     * Level 0 Root Scaffold Ground: Stone 900 (`#1C1917`) — `resolveRootBackground(isDark)`
     * Level 1 Canvas Header / Tab Surface: Stone 940 (`#100E0D` micro surface lift) — `resolveSurfaceCanvas(isDark)`
     * Level 2 Elevated Cards / Tables: Stone 950 (`#0C0A09`) — `colors.card`

3. SHADCN COLOR SCHEME TOKEN MAPPINGS & ACTUAL SHADES:
   -----------------------------------------------------------------------------
   TOKEN NAME            | LIGHT SLATE (.teal)       | DARK STONE (.amber)
   -----------------------------------------------------------------------------
   colors.background     | #FFFFFF (White)           | #0C0A09 (Stone 950)
   colors.card           | #FFFFFF (White)           | #0C0A09 (Stone 950)
   colors.popover        | #FFFFFF (White)           | #0C0A09 (Stone 950)
   colors.foreground     | #020817 (Slate 950)       | #FAFAF9 (Stone 50)
   colors.mutedForeground| #64748B (Slate 500)       | #A8A29E (Stone 400)
   colors.primary        | #14B8A6 (Teal 500)        | #F59E0B (Amber 500)
   colors.primaryForegnd | #FFFFFF (White)           | #000000 (Black)
   colors.secondary      | #F1F5F9 (Slate 100)       | #292524 (Stone 800)
   colors.muted          | #F1F5F9 (Slate 100)       | #292524 (Stone 800)
   colors.accent         | #F1F5F9 (Slate 100)       | #292524 (Stone 800)
   colors.border         | #E2E8F0 (Slate 200)       | #292524 (Stone 800)
   colors.input          | #E2E8F0 (Slate 200)       | #292524 (Stone 800)
   colors.ring           | #14B8A6 (Teal 500)        | #F59E0B (Amber 500)
   colors.destructive    | #EF4444 (Red 500)         | #7F1D1D (Red 900)
   -----------------------------------------------------------------------------

4. COMPONENT STATE STYLING RULES:
   - Navigation Hover State:  `colors.accent` (Slate 100 in Light, Stone 800 in Dark)
   - Navigation Selected State: `DyColorSystem.resolveSelectItem(isDark, colors)` (Slate 200 in Light, Accent in Dark)
   - Primary Active Selection: `colors.primary.withAlpha(20)` fill + `colors.primary` 1.5px border
   - Dividers/Borders:        `colors.border` (Slate 200 in Light, Stone 800 in Dark)
   - Secondary Text:          `colors.mutedForeground`

5. THE 6-COLOR ERP PIPELINE SCALE (100 = Light Surface, 500 = Solid Accent):
   - Red:     `red[500]` / `red[100]` (Danger, Cancelled, Overdue)
   - Green:   `emerald[500]` / `emerald[100]` (Success, Completed, Paid, Received)
   - Yellow:  `yellow[500]` / `yellow[100]` (Pending Action, Hold)
   - Orange:  `orange[500]` / `orange[100]` (Warning, In Cutting, Partial)
   - Indigo:  `indigo[500]` / `indigo[100]` (Processing, Mill Dispatch, In Transit)
   - Fuchsia: `fuchsia[500]` / `fuchsia[100]` (Special Stage, Custom Audit, Margin)
================================================================================
*/

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DyColorSystem] — Master ERP 6-Color Scale & Semantic Token System.
abstract class DyColorSystem {
  // =========================================================================
  // 0. CUSTOM BRAND SURFACE CANVAS TOKENS & HIERARCHY
  // =========================================================================
  /// Slate 10 (#FCFDFE) — Light Theme Header & Surface Canvas (Level 1 tint between Slate 50 & White)
  static const Color slate10 = Color(0xFFFCFDFE);

  /// Stone 940 (#100E0D) — Dark Theme Header & Surface Canvas (0.8% micro lift above Stone 950 #0C0A09)
  static const Color stone940 = Color(0xFF100E0D);

  /// Resolves Level 1 ERP Surface Canvas (Slate 10 for Light, Stone 940 for Dark)
  static Color resolveSurfaceCanvas(bool isDark) => isDark ? stone940 : slate10;

  // =========================================================================
  // LEVEL 0 ROOT GROUND TOKENS (SHELL & SIDEBAR BACKGROUND)
  // =========================================================================
  /// Slate 50 (#F8FAFC) — Light Theme Level 0 Root Scaffold Ground
  static Color get slate50 => shad.Colors.slate[50];

  /// Stone 900 (#1C1917) — Dark Theme Level 0 Root Scaffold Ground
  static Color get stone900 => shad.Colors.stone[900];

  /// Resolves Level 0 Root Scaffold & Sidebar Background (Slate 50 for Light, Stone 900 for Dark)
  static Color resolveRootBackground(bool isDark) => isDark ? stone900 : slate50;

  // =========================================================================
  // SELECTION & HOVER STATE TOKENS
  // =========================================================================
  /// Slate 200 (#E2E8F0) — Light Theme Navigation Item Active Selection Surface
  static Color get slate200 => shad.Colors.slate[200];

  /// Resolves Navigation / Sidebar Item Active Selection Surface (Slate 200 for Light, Accent/Stone 800 for Dark)
  static Color resolveSelectItem(bool isDark, shad.ColorScheme colors) =>
      isDark ? colors.accent : slate200;

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
