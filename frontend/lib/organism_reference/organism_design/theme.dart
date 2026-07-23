import 'package:flutter/material.dart';

import 'theme/colors.dart';
export 'theme/colors.dart';

import 'theme/metrics.dart';
export 'theme/metrics.dart';

import 'theme/typography.dart';
export 'theme/typography.dart';

/// The standard responsiveness tiers for the ERP.
/// Based on standard viewport widths.
enum OrganismBreakpoint {
  sm, // < 768 (Mobile / Small Tablet)
  md, // 768 - 1024 (Tablet Portrait / Warehouse Target)
  lg, // 1024 - 1280 (Laptop)
  xl, // 1280 - 1536 (Desktop)
  xxl, // > 1536 (Wide)
}

class OrganismTheme {
  // Static color getters are intentionally removed.
  // Use OrganismTheme.colorsOf(context) exclusively.

  static OrganismColors colorsOf(BuildContext context) {
    return Theme.of(context).extension<OrganismColors>() ??
        OrganismColors.light();
  }

  // --- TYPOGRAPHY (The Skeleton) ---
  static TextStyle displayLarge(BuildContext context) => OrganismTypography.displayLarge(colorsOf(context).textPrimary);
  static TextStyle titleLarge(BuildContext context) => OrganismTypography.titleLarge(colorsOf(context).textPrimary);
  static TextStyle titleMedium(BuildContext context) => OrganismTypography.titleMedium(colorsOf(context).textPrimary);
  static TextStyle titleSmall(BuildContext context) => OrganismTypography.titleSmall(colorsOf(context).textPrimary);
  static TextStyle bodyLarge(BuildContext context) => OrganismTypography.bodyLarge(colorsOf(context).textPrimary);
  static TextStyle bodyMedium(BuildContext context) => OrganismTypography.bodyMedium(colorsOf(context).textSecondary);
  static TextStyle bodySmall(BuildContext context) => OrganismTypography.bodySmall(colorsOf(context).textSecondary);
  static TextStyle labelLarge(BuildContext context) => OrganismTypography.labelLarge(colorsOf(context).textSecondary);
  static TextStyle labelMedium(BuildContext context) => OrganismTypography.labelMedium(colorsOf(context).textSecondary);
  static TextStyle labelSmall(BuildContext context) => OrganismTypography.labelSmall(colorsOf(context).textSecondary);

  // --- NUMERIC & TABULAR (The Precision) ---
  static TextStyle numericLarge(BuildContext context) => OrganismTypography.numericLarge(colorsOf(context).textPrimary);
  static TextStyle numericMedium(BuildContext context) => OrganismTypography.numericMedium(colorsOf(context).textPrimary);
  static TextStyle numericSmall(BuildContext context) => OrganismTypography.numericSmall(colorsOf(context).textSecondary);
  static TextStyle tabularNumStyle(BuildContext context) => OrganismTypography.tabularNumStyle(colorsOf(context).textPrimary);
  static TextStyle codeTabular(BuildContext context) => OrganismTypography.codeTabular(colorsOf(context).textPrimary);
  static TextStyle monoBody(BuildContext context) => OrganismTypography.monoBody(colorsOf(context).textPrimary);
  static TextStyle monoLabel(BuildContext context) => OrganismTypography.monoLabel(colorsOf(context).textSecondary);
  static TextStyle code(BuildContext context) => OrganismTypography.monoBody(colorsOf(context).textPrimary);

  // --- ICONOGRAPHY (The Vision) ---
  static const double iconSizeXs = OrganismMetrics.iconSizeXs;
  static const double iconSizeSm = OrganismMetrics.iconSizeSm;
  static const double iconSizeMd = OrganismMetrics.iconSizeMd;
  static const double iconSizeLg = OrganismMetrics.iconSizeLg;
  static const double iconSizeXl = OrganismMetrics.iconSizeXl;

  static Color iconPrimary(BuildContext context) => colorsOf(context).textPrimary;
  static Color iconSecondary(BuildContext context) => colorsOf(context).textSecondary;
  static Color iconMuted(BuildContext context) => colorsOf(context).textMuted;
  static Color iconAccent(BuildContext context) => colorsOf(context).primary;

  // --- ELEVATION & SHADOWS ---
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -1),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 10), blurRadius: 15, spreadRadius: -3),
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -2),
  ];

  static List<BoxShadow> shadowGlow(BuildContext context) => [
        BoxShadow(color: colorsOf(context).primary.withValues(alpha: 0.15), offset: const Offset(0, 4), blurRadius: 12, spreadRadius: 2),
      ];

  static List<BoxShadow> shadowRing(BuildContext context) => [
        BoxShadow(color: colorsOf(context).focusRing.withValues(alpha: 0.3), offset: Offset.zero, blurRadius: 0, spreadRadius: 2),
      ];

  static List<BoxShadow> shadowsOf(BuildContext? context, {double elevation = 1, bool isGlow = false}) {
    if (context == null) return [];
    final colors = colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isGlow) {
      return [
        BoxShadow(
          color: colors.primary.withValues(alpha: isDark ? 0.35 : 0.15),
          blurRadius: isDark ? 16 : 12,
          spreadRadius: isDark ? 2 : 0,
        ),
      ];
    }

    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          offset: Offset(0, elevation * 2),
          blurRadius: elevation * 4,
          spreadRadius: 1,
        ),
      ];
    }

    if (elevation <= 1) return shadowSm;
    if (elevation <= 2) return shadowMd;
    return shadowLg;
  }

  static List<BoxShadow> focusShadows(BuildContext context) {
    final colors = colorsOf(context);
    return [
      BoxShadow(color: colors.surface, spreadRadius: 1, blurRadius: 0),
      BoxShadow(color: colors.focusRing.withValues(alpha: 0.25), spreadRadius: 1, blurRadius: 2),
    ];
  }

  static BorderSide focusBorderSide(BuildContext context) {
    return BorderSide(color: colorsOf(context).focusRing, width: 1.5);
  }

  // --- MOTION & PHYSICS ---
  static const Duration durationFast = OrganismMetrics.durationFast;
  static const Duration durationStandard = OrganismMetrics.durationStandard;
  static const Duration durationSlow = OrganismMetrics.durationSlow;

  static const Curve curveStandard = OrganismMetrics.curveStandard;
  static const Curve curveIn = OrganismMetrics.curveIn;
  static const Curve curveOut = OrganismMetrics.curveOut;

  // --- GEOMETRY & BORDERS ---
  static const double radiusNone = OrganismMetrics.radiusNone;
  static const double radiusSm = OrganismMetrics.radiusSm;
  static const double radiusMd = OrganismMetrics.radiusMd;
  static const double radiusLg = OrganismMetrics.radiusLg;
  static const double radiusXl = OrganismMetrics.radiusXl;
  static const double radiusPill = OrganismMetrics.radiusPill;

  static final BorderRadius borderSm = OrganismMetrics.borderSm;
  static final BorderRadius borderMd = OrganismMetrics.borderMd;
  static final BorderRadius borderLg = OrganismMetrics.borderLg;
  static final BorderRadius borderXl = OrganismMetrics.borderXl;
  static final BorderRadius borderPill = OrganismMetrics.borderPill;

  // --- SPACING & SIZING ---
  static const double spacing2Xs = OrganismMetrics.spacing2Xs;
  static const double spacingXs = OrganismMetrics.spacingXs;
  static const double spacingSm = OrganismMetrics.spacingSm;
  static const double spacingMd = OrganismMetrics.spacingMd;
  static const double spacingLg = OrganismMetrics.spacingLg;
  static const double spacingXl = OrganismMetrics.spacingXl;
  static const double spacing2Xl = OrganismMetrics.spacing2Xl;

  static const double buttonHeightCompact = OrganismMetrics.buttonHeightCompact;
  static const double buttonHeightStandard = OrganismMetrics.buttonHeightStandard;
  static const double buttonHeightLarge = OrganismMetrics.buttonHeightLarge;

  static const double sidebarWidth = OrganismMetrics.sidebarWidth;
  static const double sidebarWidthCollapsed = OrganismMetrics.sidebarWidthCollapsed;
  static const double masterPaneWidth = OrganismMetrics.masterPaneWidth;
  static const double masterPaneWidthCompact = OrganismMetrics.masterPaneWidthCompact;
  static const double tabHeightPill = OrganismMetrics.tabHeightPill;
  static const double tabHeightUnderline = OrganismMetrics.tabHeightUnderline;
  static const double topbarHeight = OrganismMetrics.topbarHeight;
  static const double breakpointSm = OrganismMetrics.breakpointSm;
  static const double breakpointMd = OrganismMetrics.breakpointMd;
  static const double breakpointLg = OrganismMetrics.breakpointLg;

  // --- Z-INDEX GOVERNANCE ---
  static const int zIndexDropdown = OrganismMetrics.zIndexDropdown;
  static const int zIndexPopover = OrganismMetrics.zIndexPopover;
  static const int zIndexDialog = OrganismMetrics.zIndexDialog;
  static const int zIndexToast = OrganismMetrics.zIndexToast;
  static const int zIndexTooltip = OrganismMetrics.zIndexTooltip;

  // --- MATERIAL THEME EXPORT ---
  static ThemeData materialTheme(Brightness brightness) {
    final colors = (brightness == Brightness.dark) ? OrganismColors.dark() : OrganismColors.light();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.primaryDark,
        onSecondary: Colors.white,
        error: colors.error,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: (brightness == Brightness.dark) ? colors.borderSubtle : Colors.white,
        hoverColor: colors.surfaceHover,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: borderSm, borderSide: BorderSide(color: colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: borderSm, borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: borderSm, borderSide: BorderSide(color: colors.primary, width: 2)),
        labelStyle: TextStyle(color: colors.textSecondary, fontFamily: 'Inter'),
        hintStyle: TextStyle(color: colors.textMuted, fontFamily: 'Inter'),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderLg, side: BorderSide(color: colors.border)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colors.textSelection,
        selectionHandleColor: colors.primary,
        cursorColor: colors.primary,
      ),
      extensions: [colors],
    );
  }

  // --- LEGACY ALIASES ---
  static TextStyle textStylePrimary(BuildContext context) => bodyLarge(context).copyWith(color: colorsOf(context).textPrimary);
  static TextStyle textStyleSecondary(BuildContext context) => bodyMedium(context).copyWith(color: colorsOf(context).textSecondary);
  static TextStyle textStyleMuted(BuildContext context) => bodySmall(context).copyWith(color: colorsOf(context).textMuted);
  static TextStyle textStyleAccent(BuildContext context) => bodyMedium(context).copyWith(color: colorsOf(context).primary, fontWeight: FontWeight.w600);
  static TextStyle textStyleLabel(BuildContext context) => labelLarge(context);
  static TextStyle textStyleMono(BuildContext context) => code(context);
  static TextStyle textStylePageTitle(BuildContext context) => displayLarge(context);

  // --- RESPONSIVENESS & BREAKPOINTS ---
  static OrganismBreakpoint breakpointOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1536) return OrganismBreakpoint.xxl;
    if (width >= 1280) return OrganismBreakpoint.xl;
    if (width >= 1024) return OrganismBreakpoint.lg;
    if (width >= 768) return OrganismBreakpoint.md;
    return OrganismBreakpoint.sm;
  }

  static bool isMobile(BuildContext context) => breakpointOf(context) == OrganismBreakpoint.sm;
  static bool isTablet(BuildContext context) => breakpointOf(context) == OrganismBreakpoint.md;
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1024;
  static bool isCompact(BuildContext context) => isMobile(context) || isTablet(context);
}

/// A system-level builder that rebuilds when the screen crosses a breakpoint.
class OrganismResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, OrganismBreakpoint breakpoint) builder;
  const OrganismResponsiveBuilder({super.key, required this.builder});
  @override Widget build(BuildContext context) => builder(context, OrganismTheme.breakpointOf(context));
}

/// A convenience wrapper to show/hide content based on the active breakpoint.
class OrganismResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final List<OrganismBreakpoint> visibleOn;
  const OrganismResponsiveVisibility({super.key, required this.child, required this.visibleOn});
  @override Widget build(BuildContext context) {
    if (visibleOn.contains(OrganismTheme.breakpointOf(context))) return child;
    return const SizedBox.shrink();
  }
}

/// Content boundary mapping to a maximum readable width.
class MaxWidthSystem extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidthSystem({super.key, required this.child, this.maxWidth = 1440});
  @override Widget build(BuildContext context) {
    return Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
  }
}
