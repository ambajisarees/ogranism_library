import 'package:flutter/material.dart';

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

  // --- DATA VISUALIZATION TOKENS (Categorical 12) ---
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;
  final Color chart6;
  final Color chart7;
  final Color chart8;
  final Color chart9;
  final Color chart10;
  final Color chart11;
  final Color chart12;

  final Color inputBackground;
  final Color inputBackgroundDisabled;
  final Color inputBorder;
  final Color inputBorderHover;
  final Color textSelection;

  final Color surfaceSubtle;
  final Color surfaceMuted;
  final Color trackInactive;
  final Color tooltipBackground;
  final Color tooltipText;

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
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.chart6,
    required this.chart7,
    required this.chart8,
    required this.chart9,
    required this.chart10,
    required this.chart11,
    required this.chart12,
    required this.inputBackground,
    required this.inputBackgroundDisabled,
    required this.inputBorder,
    required this.inputBorderHover,
    required this.textSelection,
    required this.surfaceSubtle,
    required this.surfaceMuted,
    required this.trackInactive,
    required this.tooltipBackground,
    required this.tooltipText,
  });

  factory OrganismColors.light() => OrganismColors(
        primary: Color(0xFFC20E6E), // Fuschia
        primaryLight: Color(0xFFD63D8C),
        primaryDark: Color(0xFF8E0A51),
        primarySubtle: Color(0xFFFDF2F8),
        stone50: Color(0xFFF8FAFC), stone100: Color(0xFFF1F5F9),
        stone200: Color(0xFFE2E8F0), stone300: Color(0xFFCBD5E1),
        stone400: Color(0xFF94A3B8), stone500: Color(0xFF64748B),
        stone600: Color(0xFF475569), stone700: Color(0xFF334155),
        stone800: Color(0xFF1E293B), stone900: Color(0xFF0F172A),
        success: Color(0xFF059669),
        successSubtle: Color(0xFFF0FDF4),
        error: Color(0xFFDC2626),
        errorSubtle: Color(0xFFFEF2F2),
        warning: Color(0xFFD97706),
        warningSubtle: Color(0xFFFFFBEB),
        info: Color(0xFF6366F1), // Indigo Info Swatch
        infoSubtle: Color(0xFFEEF2FF),
        background: Color(0xFFF8FAFC), // slate50
        surface: Colors.white,
        surfaceHover: Color(0xFFF1F5F9), // slate100
        surfaceActive: Color(0xFFE2E8F0), // slate200
        border: Color(0xFFE2E8F0), // slate200
        borderSubtle: Color(0xFFF1F5F9), // slate100
        focusRing: Color(0xFFD63D8C), // primaryLight
        overlay: Color(0x990F172A), // slate900 w/ alpha
        skeletonBase: Color(0xFFE2E8F0), // slate200
        skeletonHighlight: Color(0xFFF1F5F9), // slate100
        textPrimary: Color(0xFF0F172A), // slate900
        textSecondary: Color(0xFF475569), // slate600
        textMuted: Color(0xFF94A3B8), // slate400
        chart1: Color(0xFF6366F1), // Indigo
        chart2: Color(0xFFF43F5E), // Rose
        chart3: Color(0xFF10B981), // Green
        chart4: Color(0xFFF59E0B), // Amber
        chart5: Color(0xFF0EA5E9), // Sky
        chart6: Color(0xFF8B5CF6), // Violet
        chart7: Color(0xFFD946EF), // Fuchsia
        chart8: Color(0xFFF97316), // Orange
        chart9: Color(0xFF14B8A6), // Teal
        chart10: Color(0xFF06B6D4), // Cyan
        chart11: Color(0xFF84CC16), // Lime
        chart12: Color(0xFF475569), // Slate (Neutral)
        inputBackground: Colors.white,
        inputBackgroundDisabled: Color(0xFFF8FAFC), // slate50
        inputBorder: Color(0xFFE2E8F0), // slate200
        inputBorderHover: Color(0xFF94A3B8), // slate400
        textSelection:
            Color(0xFFC20E6E).withValues(alpha: 0.15), // light primary accent
        surfaceSubtle: Color(0xFFF1F5F9), // slate100
        surfaceMuted: Color(0xFFF8FAFC), // slate50
        trackInactive: Color(0xFFE2E8F0), // slate200
        tooltipBackground: Color(0xFF0F172A), // slate900
        tooltipText: Color(0xFFF8FAFC), // slate50
      );

  factory OrganismColors.dark() => OrganismColors(
        primary: Color(0xFFEC880D), // Sunset
        primaryLight: Color(0xFFF5A623),
        primaryDark: Color(0xFFB46500),
        primarySubtle: Color(0xFF2D1902),
        // Inverted Slate Scale
        // Inverted Slate Scale - Refined for depth
        stone50: Color(0xFF020617), // Slate 950 (Deep inset)
        stone100: Color(0xFF1E293B), // Slate 800
        stone200: Color(0xFF334155), // Slate 700
        stone300: Color(0xFF475569), // Slate 600
        stone400: Color(0xFF64748B), // Slate 500
        stone500: Color(0xFF94A3B8), // Slate 400
        stone600: Color(0xFFCBD5E1), // Slate 300
        stone700: Color(0xFFE2E8F0), // Slate 200
        stone800: Color(0xFFF1F5F9), // Slate 100
        stone900: Color(0xFFF8FAFC), // Slate 50
        success: Color(0xFF10B981), // Success Green
        successSubtle: Color(0xFF064E3B),
        error: Color(0xFFEF4444), // Red 500
        errorSubtle: Color(0xFF450A0A),
        warning: Color(0xFFF59E0B), // Amber 500
        warningSubtle: Color(0xFF451A03),
        info: Color(0xFF818CF8), // Indigo Info Swatch (Dark Mode)
        infoSubtle: Color(0xFF1E1B4B),
        background: Color(0xFF020617), // Slate-black
        surface: Color(0xFF0F172A), // slate50 (inverted)
        surfaceHover: Color(0xFF1E293B), // slate100 (inverted)
        surfaceActive: Color(0xFF334155), // slate200 (inverted)
        border: Color(0xFF1E293B), // slate800
        borderSubtle: Color(0xFF0F172A), // slate900
        focusRing: Color(0xFFF5A623),
        overlay: Color(0xCC000000),
        skeletonBase: Color(0xFF1E293B),
        skeletonHighlight: Color(0xFF334155),
        textPrimary: Color(0xFFF8FAFC), // slate900 (inverted)
        textSecondary: Color(0xFFCBD5E1), // slate600 (inverted)
        textMuted: Color(0xFF64748B), // slate400 (inverted)
        chart1: Color(0xFF818CF8), // Desaturated Indigo
        chart2: Color(0xFFFB7185), // Desaturated Rose
        chart3: Color(0xFF34D399), // Desaturated Green
        chart4: Color(0xFFFBBF24), // Desaturated Amber
        chart5: Color(0xFF38BDF8), // Desaturated Sky
        chart6: Color(0xFFA78BFA), // Desaturated Violet
        chart7: Color(0xFFE879F9), // Desaturated Fuchsia
        chart8: Color(0xFFFB923C), // Desaturated Orange
        chart9: Color(0xFF2DD4BF), // Desaturated Teal
        chart10: Color(0xFF22D3EE), // Desaturated Cyan
        chart11: Color(0xFFA3E635), // Desaturated Lime
        chart12: Color(0xFF94A3B8), // Slate (Neutral)
        inputBackground: Color(0xFF0F172A), // slate50 (inverted)
        inputBackgroundDisabled: Color(0xFF020617), // slate950
        inputBorder: Color(0xFF1E293B), // slate800
        inputBorderHover: Color(0xFF475569), // slate600
        textSelection:
            Color(0xFFEC880D).withValues(alpha: 0.25), // dark primary accent
        surfaceSubtle: Color(0xFF1E293B), // slate800
        surfaceMuted: Color(0xFF020617), // slate950
        trackInactive: Color(0xFF334155), // slate700
        tooltipBackground: Color(0xFFF8FAFC), // slate50
        tooltipText: Color(0xFF0F172A), // slate900
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
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? chart6,
    Color? chart7,
    Color? chart8,
    Color? chart9,
    Color? chart10,
    Color? chart11,
    Color? chart12,
    Color? inputBackground,
    Color? inputBackgroundDisabled,
    Color? inputBorder,
    Color? inputBorderHover,
    Color? textSelection,
    Color? surfaceSubtle,
    Color? surfaceMuted,
    Color? trackInactive,
    Color? tooltipBackground,
    Color? tooltipText,
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
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
      chart6: chart6 ?? this.chart6,
      chart7: chart7 ?? this.chart7,
      chart8: chart8 ?? this.chart8,
      chart9: chart9 ?? this.chart9,
      chart10: chart10 ?? this.chart10,
      chart11: chart11 ?? this.chart11,
      chart12: chart12 ?? this.chart12,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBackgroundDisabled:
          inputBackgroundDisabled ?? this.inputBackgroundDisabled,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderHover: inputBorderHover ?? this.inputBorderHover,
      textSelection: textSelection ?? this.textSelection,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      trackInactive: trackInactive ?? this.trackInactive,
      tooltipBackground: tooltipBackground ?? this.tooltipBackground,
      tooltipText: tooltipText ?? this.tooltipText,
    );
  }

  @override
  ThemeExtension<OrganismColors> lerp(
      ThemeExtension<OrganismColors>? other, double t) {
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
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
      chart4: Color.lerp(chart4, other.chart4, t)!,
      chart5: Color.lerp(chart5, other.chart5, t)!,
      chart6: Color.lerp(chart6, other.chart6, t)!,
      chart7: Color.lerp(chart7, other.chart7, t)!,
      chart8: Color.lerp(chart8, other.chart8, t)!,
      chart9: Color.lerp(chart9, other.chart9, t)!,
      chart10: Color.lerp(chart10, other.chart10, t)!,
      chart11: Color.lerp(chart11, other.chart11, t)!,
      chart12: Color.lerp(chart12, other.chart12, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBackgroundDisabled: Color.lerp(
          inputBackgroundDisabled, other.inputBackgroundDisabled, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputBorderHover:
          Color.lerp(inputBorderHover, other.inputBorderHover, t)!,
      textSelection: Color.lerp(textSelection, other.textSelection, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      trackInactive: Color.lerp(trackInactive, other.trackInactive, t)!,
      tooltipBackground:
          Color.lerp(tooltipBackground, other.tooltipBackground, t)!,
      tooltipText: Color.lerp(tooltipText, other.tooltipText, t)!,
    );
  }
}
