import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganismTypography {
  // Using required color parameters allows typography to be entirely independent of Theme singletons.
  
  static TextStyle displayLarge(Color color) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: color,
      );

  static TextStyle titleLarge(Color color) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle titleMedium(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle titleSmall(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle labelLarge(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle labelMedium(Color color) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle labelSmall(Color color) => GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // --- NUMERIC & TABULAR (The Precision) ---
  static TextStyle numericLarge(Color color) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle numericMedium(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle numericSmall(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle tabularNumStyle(Color color) => bodyLarge(color).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // JetBrains Mono is used for immutable technical identifiers (Roll Nos, HSN, IDs).
  static TextStyle monoBody(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        color: color,
        fontWeight: FontWeight.w500,
      );

  static TextStyle monoLabel(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        color: color,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      );

  static TextStyle codeTabular(Color color) => monoBody(color).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
