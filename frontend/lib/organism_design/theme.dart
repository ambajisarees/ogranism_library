import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The comprehensive Organism Design Language System.
/// A sophisticated, premium "Red Wine" aesthetic meticulously crafted for the Textile ERP.
class OrganismTheme {
  // --- COLORS (The Bloodstream) ---
  static const Color primary = Color(0xFF722F37); // Bordeaux Red Wine
  static const Color primaryLight = Color(0xFF9E4E58);
  static const Color primaryDark = Color(0xFF4A1C21);
  static const Color primarySubtle = Color(0xFFFDEBEC); // 5% wash

  // Neutrals (Stone Architecture)
  static const Color stone50 = Color(0xFFFAFAF9);
  static const Color stone100 = Color(0xFFF5F5F4);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone300 = Color(0xFFD6D3D1);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone500 = Color(0xFF78716C);
  static const Color stone600 = Color(0xFF57534E);
  static const Color stone700 = Color(0xFF44403C);
  static const Color stone800 = Color(0xFF292524);
  static const Color stone900 = Color(0xFF1C1917);

  // Semantics
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successSubtle = Color(0xFFF0FDF4);
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorSubtle = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningSubtle = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF9333EA); // Purple 600
  static const Color infoSubtle = Color(0xFFEFF6FF);

  // Surfaces & Backgrounds
  static const Color background = stone50;
  static const Color surface = Colors.white;
  static const Color surfaceHover = stone50;
  static const Color surfaceActive = stone100;
  static const Color border = stone200;
  static const Color borderSubtle = stone100;

  // Global UX Mechanics
  static const Color focusRing = primaryLight;
  static final Color overlay = stone900.withValues(alpha: 0.6);
  static const Color skeletonBase = stone200;
  static const Color skeletonHighlight = stone100;

  // Typography Colors
  static const Color textPrimary = stone900;
  static const Color textSecondary = stone600;
  static const Color textMuted = stone400;

  // --- TYPOGRAPHY (The Skeleton) ---
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      );

  static TextStyle get code => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        color: textPrimary,
      );

  // --- ICONOGRAPHY (The Vision) ---
  static const double iconSizeXs = 12.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 20.0;
  static const double iconSizeLg = 28.0;
  static const double iconSizeXl = 48.0; // KPI/Hero metrics

  static const Color iconPrimary = textPrimary;
  static const Color iconSecondary = textSecondary;
  static const Color iconMuted = textMuted;
  static Color get iconAccent => primary;

  // --- ELEVATION & SHADOWS (Depth & Z-Index) ---
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -1),
    BoxShadow(
        color: Color(0x0F000000),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: -1),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 10),
        blurRadius: 15,
        spreadRadius: -3),
    BoxShadow(
        color: Color(0x0F000000),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -2),
  ];

  static List<BoxShadow> get shadowGlow => [
        BoxShadow(
            color: primary.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2),
      ];

  static List<BoxShadow> get shadowRing => [
        BoxShadow(
            color: focusRing.withValues(alpha: 0.3),
            offset: Offset.zero,
            blurRadius: 0,
            spreadRadius: 2),
      ];

  // --- MOTION & PHYSICS (The Pulse) ---
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationStandard = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveIn = Curves.easeInCubic;
  static const Curve curveOut = Curves.easeOutCubic;

  // --- GEOMETRY & BORDERS (Cellular Membranes) ---
  // Border Radius
  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusPill = 999.0;

  static final BorderRadius borderSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderPill = BorderRadius.circular(radiusPill);

  // --- SPACING & SIZING (Cellular Matrix) ---
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
  static const double sidebarWidthCollapsed = 84.0;

  // --- MATERIAL THEME EXPORT ---
  // The global app theme injected into MaterialApp
  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      visualDensity: const VisualDensity(
          horizontal: -2, vertical: -2), // Dense for Desktop ERP
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        secondary: primaryDark,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        brightness: Brightness.light,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderLg,
          side: const BorderSide(color: border),
        ),
      ),
    );
  }

  // --- LEGACY ALIASES (For backward compatibility with organism_ui.dart) ---
  static TextStyle get textStylePrimary =>
      bodyLarge.copyWith(color: textPrimary);
  static TextStyle get textStyleSecondary =>
      bodyMedium.copyWith(color: textSecondary);
  static TextStyle get textStyleMuted => bodySmall.copyWith(color: textMuted);
  static TextStyle get textStyleAccent =>
      bodyMedium.copyWith(color: primary, fontWeight: FontWeight.w600);
  static TextStyle get textStyleLabel => labelLarge;
  static TextStyle get textStyleMono => code;
  static TextStyle get textStylePageTitle => displayLarge;

  static const double masterPaneWidth = 320.0;
  static const double tabHeightPill = 42.0;
  static const double tabHeightUnderline = 48.0;
}
