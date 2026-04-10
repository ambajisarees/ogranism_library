import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// ORGANISM DESIGN SYSTEM: MIGRATION PATH & ARCHITECTURE
/// ============================================================================
/// 
/// We are currently in the "Bridge Phase" of the design system refactor.
/// 
/// OLD PATTERN (Static): 
///   Container(color: OrganismTheme.primary)
/// 
/// NEW PATTERN (Context-aware - Preferred): 
///   Container(color: OrganismTheme.colorsOf(context).primary)
/// 
/// The existing static getters in [OrganismTheme] now resolve dynamically via 
/// a top-level ValueNotifier [_activeColors]. This allows existing code to 
/// work with Dark Mode immediately, but moving to `colorsOf(context)` is 
/// recommended for better performance and alignment with Flutter's theme engine.
/// ============================================================================

/// Dynamic Color tokens for the Organism Design Language.
class OrganismColors extends ThemeExtension<OrganismColors> {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primarySubtle;

  final Color stone50;
  final Color stone100;
  final Color stone200;
  final Color stone300;
  final Color stone400;
  final Color stone500;
  final Color stone600;
  final Color stone700;
  final Color stone800;
  final Color stone900;

  final Color success;
  final Color successSubtle;
  final Color error;
  final Color errorSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color info;
  final Color infoSubtle;

  final Color background;
  final Color surface;
  final Color surfaceHover;
  final Color surfaceActive;
  final Color border;
  final Color borderSubtle;

  final Color focusRing;
  final Color overlay;
  final Color skeletonBase;
  final Color skeletonHighlight;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const OrganismColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primarySubtle,
    required this.stone50,
    required this.stone100,
    required this.stone200,
    required this.stone300,
    required this.stone400,
    required this.stone500,
    required this.stone600,
    required this.stone700,
    required this.stone800,
    required this.stone900,
    required this.success,
    required this.successSubtle,
    required this.error,
    required this.errorSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.info,
    required this.infoSubtle,
    required this.background,
    required this.surface,
    required this.surfaceHover,
    required this.surfaceActive,
    required this.border,
    required this.borderSubtle,
    required this.focusRing,
    required this.overlay,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  factory OrganismColors.light() => const OrganismColors(
        primary: Color(0xFF722F37),
        primaryLight: Color(0xFF9E4E58),
        primaryDark: Color(0xFF4A1C21),
        primarySubtle: Color(0xFFFDEBEC),
        stone50: Color(0xFFFAFAF9),
        stone100: Color(0xFFF5F5F4),
        stone200: Color(0xFFE7E5E4),
        stone300: Color(0xFFD6D3D1),
        stone400: Color(0xFFA8A29E),
        stone500: Color(0xFF78716C),
        stone600: Color(0xFF57534E),
        stone700: Color(0xFF44403C),
        stone800: Color(0xFF292524),
        stone900: Color(0xFF1C1917),
        success: Color(0xFF059669),
        successSubtle: Color(0xFFF0FDF4),
        error: Color(0xFFDC2626),
        errorSubtle: Color(0xFFFEF2F2),
        warning: Color(0xFFD97706),
        warningSubtle: Color(0xFFFFFBEB),
        info: Color(0xFF9333EA),
        infoSubtle: Color(0xFFEFF6FF),
        background: Color(0xFFFAFAF9), // stone50
        surface: Colors.white,
        surfaceHover: Color(0xFFFAFAF9), // stone50
        surfaceActive: Color(0xFFF5F5F4), // stone100
        border: Color(0xFFE7E5E4), // stone200
        borderSubtle: Color(0xFFF5F5F4), // stone100
        focusRing: Color(0xFF9E4E58), // primaryLight
        overlay: Color(0x991C1917), // stone900 w/ alpha
        skeletonBase: Color(0xFFE7E5E4), // stone200
        skeletonHighlight: Color(0xFFF5F5F4), // stone100
        textPrimary: Color(0xFF1C1917), // stone900
        textSecondary: Color(0xFF57534E), // stone600
        textMuted: Color(0xFFA8A29E), // stone400
      );

  factory OrganismColors.dark() => const OrganismColors(
        primary: Color(0xFF8E3E47), // Slightly lightened Bordeaux for contrast on dark
        primaryLight: Color(0xFFA55A62),
        primaryDark: Color(0xFF5E272D),
        primarySubtle: Color(0xFF2A1517),
        // Inverted Stone Scale: 50 is dark, 900 is light
        stone50: Color(0xFF1C1917),
        stone100: Color(0xFF292524),
        stone200: Color(0xFF44403C),
        stone300: Color(0xFF57534E),
        stone400: Color(0xFF78716C),
        stone500: Color(0xFFA8A29E),
        stone600: Color(0xFFD6D3D1),
        stone700: Color(0xFFE7E5E4),
        stone800: Color(0xFFF5F5F4),
        stone900: Color(0xFFFAFAF9),
        success: Color(0xFF10B981), // Emerald 500
        successSubtle: Color(0xFF064E3B),
        error: Color(0xFFEF4444), // Red 500
        errorSubtle: Color(0xFF450A0A),
        warning: Color(0xFFF59E0B), // Amber 500
        warningSubtle: Color(0xFF451A03),
        info: Color(0xFFA855F7), // Purple 500
        infoSubtle: Color(0xFF1E1B4B),
        background: Color(0xFF0C0A09), // Custom Black
        surface: Color(0xFF1C1917), // stone50 (inverted)
        surfaceHover: Color(0xFF292524), // stone100 (inverted)
        surfaceActive: Color(0xFF44403C), // stone200 (inverted)
        border: Color(0xFF44403C), // stone200 (inverted)
        borderSubtle: Color(0xFF292524), // stone100 (inverted)
        focusRing: Color(0xFFA55A62),
        overlay: Color(0xCC000000),
        skeletonBase: Color(0xFF292524),
        skeletonHighlight: Color(0xFF44403C),
        textPrimary: Color(0xFFFAFAF9), // stone900 (inverted)
        textSecondary: Color(0xFFD6D3D1), // stone600 (inverted)
        textMuted: Color(0xFF78716C), // stone400 (inverted)
      );

  @override
  ThemeExtension<OrganismColors> copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? primarySubtle,
    Color? stone50,
    Color? stone100,
    Color? stone200,
    Color? stone300,
    Color? stone400,
    Color? stone500,
    Color? stone600,
    Color? stone700,
    Color? stone800,
    Color? stone900,
    Color? success,
    Color? successSubtle,
    Color? error,
    Color? errorSubtle,
    Color? warning,
    Color? warningSubtle,
    Color? info,
    Color? infoSubtle,
    Color? background,
    Color? surface,
    Color? surfaceHover,
    Color? surfaceActive,
    Color? border,
    Color? borderSubtle,
    Color? focusRing,
    Color? overlay,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
  }) {
    return OrganismColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      stone50: stone50 ?? this.stone50,
      stone100: stone100 ?? this.stone100,
      stone200: stone200 ?? this.stone200,
      stone300: stone300 ?? this.stone300,
      stone400: stone400 ?? this.stone400,
      stone500: stone500 ?? this.stone500,
      stone600: stone600 ?? this.stone600,
      stone700: stone700 ?? this.stone700,
      stone800: stone800 ?? this.stone800,
      stone900: stone900 ?? this.stone900,
      success: success ?? this.success,
      successSubtle: successSubtle ?? this.successSubtle,
      error: error ?? this.error,
      errorSubtle: errorSubtle ?? this.errorSubtle,
      warning: warning ?? this.warning,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      info: info ?? this.info,
      infoSubtle: infoSubtle ?? this.infoSubtle,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceActive: surfaceActive ?? this.surfaceActive,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      focusRing: focusRing ?? this.focusRing,
      overlay: overlay ?? this.overlay,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  ThemeExtension<OrganismColors> lerp(ThemeExtension<OrganismColors>? other, double t) {
    if (other is! OrganismColors) return this;
    return OrganismColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      stone50: Color.lerp(stone50, other.stone50, t)!,
      stone100: Color.lerp(stone100, other.stone100, t)!,
      stone200: Color.lerp(stone200, other.stone200, t)!,
      stone300: Color.lerp(stone300, other.stone300, t)!,
      stone400: Color.lerp(stone400, other.stone400, t)!,
      stone500: Color.lerp(stone500, other.stone500, t)!,
      stone600: Color.lerp(stone600, other.stone600, t)!,
      stone700: Color.lerp(stone700, other.stone700, t)!,
      stone800: Color.lerp(stone800, other.stone800, t)!,
      stone900: Color.lerp(stone900, other.stone900, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSubtle: Color.lerp(successSubtle, other.successSubtle, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorSubtle: Color.lerp(errorSubtle, other.errorSubtle, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSubtle: Color.lerp(warningSubtle, other.warningSubtle, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSubtle: Color.lerp(infoSubtle, other.infoSubtle, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceActive: Color.lerp(surfaceActive, other.surfaceActive, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

/// Internal bridge to allow static getters to remain reactive.
final ValueNotifier<OrganismColors> _activeColors = ValueNotifier(OrganismColors.light());

/// The comprehensive Organism Design Language System.
class OrganismTheme {
  // --- COLOR BRIDGE (LEGACY STATIC ACCESS) ---
  static Color get primary => _activeColors.value.primary;
  static Color get primaryLight => _activeColors.value.primaryLight;
  static Color get primaryDark => _activeColors.value.primaryDark;
  static Color get primarySubtle => _activeColors.value.primarySubtle;

  static Color get stone50 => _activeColors.value.stone50;
  static Color get stone100 => _activeColors.value.stone100;
  static Color get stone200 => _activeColors.value.stone200;
  static Color get stone300 => _activeColors.value.stone300;
  static Color get stone400 => _activeColors.value.stone400;
  static Color get stone500 => _activeColors.value.stone500;
  static Color get stone600 => _activeColors.value.stone600;
  static Color get stone700 => _activeColors.value.stone700;
  static Color get stone800 => _activeColors.value.stone800;
  static Color get stone900 => _activeColors.value.stone900;

  static Color get success => _activeColors.value.success;
  static Color get successSubtle => _activeColors.value.successSubtle;
  static Color get error => _activeColors.value.error;
  static Color get errorSubtle => _activeColors.value.errorSubtle;
  static Color get warning => _activeColors.value.warning;
  static Color get warningSubtle => _activeColors.value.warningSubtle;
  static Color get info => _activeColors.value.info;
  static Color get infoSubtle => _activeColors.value.infoSubtle;

  static Color get background => _activeColors.value.background;
  static Color get surface => _activeColors.value.surface;
  static Color get surfaceHover => _activeColors.value.surfaceHover;
  static Color get surfaceActive => _activeColors.value.surfaceActive;
  static Color get border => _activeColors.value.border;
  static Color get borderSubtle => _activeColors.value.borderSubtle;

  static Color get focusRing => _activeColors.value.focusRing;
  static Color get overlay => _activeColors.value.overlay;
  static Color get skeletonBase => _activeColors.value.skeletonBase;
  static Color get skeletonHighlight => _activeColors.value.skeletonHighlight;

  static Color get textPrimary => _activeColors.value.textPrimary;
  static Color get textSecondary => _activeColors.value.textSecondary;
  static Color get textMuted => _activeColors.value.textMuted;

  // --- THEME UTILITIES ---
  
  static OrganismColors colorsOf(BuildContext context) {
    return Theme.of(context).extension<OrganismColors>() ?? OrganismColors.light();
  }

  static void setMode(ThemeMode mode) {
    _activeColors.value = (mode == ThemeMode.dark) ? OrganismColors.dark() : OrganismColors.light();
  }

  // --- TYPOGRAPHY (The Skeleton) ---
  // Note: These still use static color getters, so they stay reactive via _activeColors.
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
  static const double iconSizeXl = 48.0;

  static Color get iconPrimary => textPrimary;
  static Color get iconSecondary => textSecondary;
  static Color get iconMuted => textMuted;
  static Color get iconAccent => primary;

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
  static final BorderRadius borderPill = BorderRadius.circular(radiusPill);

  // --- SPACING & SIZING ---
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
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderLg,
          side: BorderSide(color: colors.border),
        ),
      ),
      extensions: [colors],
    );
  }

  // --- LEGACY ALIASES ---
  static TextStyle get textStylePrimary => bodyLarge.copyWith(color: textPrimary);
  static TextStyle get textStyleSecondary => bodyMedium.copyWith(color: textSecondary);
  static TextStyle get textStyleMuted => bodySmall.copyWith(color: textMuted);
  static TextStyle get textStyleAccent => bodyMedium.copyWith(color: primary, fontWeight: FontWeight.w600);
  static TextStyle get textStyleLabel => labelLarge;
  static TextStyle get textStyleMono => code;
  static TextStyle get textStylePageTitle => displayLarge;

  static const double masterPaneWidth = 320.0;
  static const double tabHeightPill = 42.0;
  static const double tabHeightUnderline = 48.0;
}
