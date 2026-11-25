/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC KPI METRIC CARD (dy_kpi_metric_card.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Executive KPI metric tile inside the Dynamic AI reusable component engine.
   - Displays primary monospace KPI figure, semantic status/delta badge, secondary
     sub-metric context, optional mini sparkline (`fl_chart`), and optional
     compliance progress bar (`shad.LinearProgressIndicator`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` controls (`shad.Card`, `shad.OutlinedContainer`,
     `shad.Button.card`, `shad.SecondaryBadge`, `shad.LinearProgressIndicator`) and
     `DyColorSystem` semantic tokens (zero hardcoded `Color(...)` values).
   - Enforces Rule 8 Badge Chip Isolation (`Focus(canRequestFocus: false, ...)`).
   - Supports optional click-to-filter (`onTap`) and active selection state (`isSelected`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Sparkline requires at least 2 points to render; falls back gracefully when empty.
   - Progress value is clamped cleanly to `[0.0, 1.0]`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: optional comparison tooltip popover for YoY / MoM variance.
================================================================================
*/

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../specs/dy_color_system.dart';

/// Semantic accent tone for [DyKpiMetricCard].
enum DyKpiTone {
  primary,
  success,
  warning,
  danger,
  cyan,
  indigo,
  pink,
  fuchsia,
}

/// [DyKpiMetricCard] — Native `shadcn_flutter` Executive KPI Metric Tile.
class DyKpiMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String? badgeText;
  final IconData icon;
  final DyKpiTone tone;
  final List<double>? sparklineValues;
  final double? progress;
  final bool isSelected;
  final VoidCallback? onTap;

  const DyKpiMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.badgeText,
    this.tone = DyKpiTone.primary,
    this.sparklineValues,
    this.progress,
    this.isSelected = false,
    this.onTap,
  });

  Color _resolveToneColor(shad.ColorScheme colors) {
    switch (tone) {
      case DyKpiTone.primary:
      case DyKpiTone.cyan:
        return DyColorSystem.cyan500;
      case DyKpiTone.success:
        return DyColorSystem.emerald500;
      case DyKpiTone.warning:
        return DyColorSystem.orange500;
      case DyKpiTone.danger:
        return DyColorSystem.red500;
      case DyKpiTone.indigo:
        return DyColorSystem.indigo500;
      case DyKpiTone.pink:
      case DyKpiTone.fuchsia:
        return DyColorSystem.pink500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _resolveToneColor(colors);
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.85;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Header Row: Label + Tinted Icon Container
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            shad.OutlinedContainer(
              theme: shad.OutlinedContainerTheme(
                backgroundColor: DyColorSystem.resolveSurface(accent, isDark),
                borderColor: DyColorSystem.resolveBorder(accent, isDark),
                borderRadius: BorderRadius.circular(theme.radiusSm),
                padding: EdgeInsets.all(6 * theme.scaling),
              ),
              child: Icon(
                icon,
                size: 15 * theme.scaling,
                color: accent,
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapSm),

        // 2. Primary Metric Value + Uniform 28px Telemetry Slot (No IntrinsicHeight needed!)
        SizedBox(
          height: 32 * theme.scaling,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.h3.copyWith(
                    fontFamily: theme.typography.mono.fontFamily,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? colors.primary : colors.foreground,
                  ),
                ),
              ),
              if (sparklineValues != null && sparklineValues!.length >= 2) ...[
                const shad.DensityGap(shad.gapSm),
                SizedBox(
                  width: 68 * theme.scaling,
                  height: 28 * theme.scaling,
                  child: _buildSparkline(sparklineValues!, accent),
                ),
              ],
            ],
          ),
        ),

        const shad.DensityGap(shad.gapXs),
        SizedBox(
          height: 8 * theme.scaling,
          child: progress != null
              ? Center(
                  child: shad.LinearProgressIndicator(
                    value: progress!.clamp(0.0, 1.0),
                    theme: shad.LinearProgressIndicatorTheme(
                      color: accent,
                      backgroundColor: colors.muted,
                      minHeight: 5 * theme.scaling,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const shad.DensityGap(shad.gapXs),

        // 3. Footer Row: Subtitle + Isolated Status Badge
        Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            if (badgeText != null && badgeText!.isNotEmpty) ...[
              const shad.DensityGap(shad.gapXs),
              Focus(
                canRequestFocus: false,
                skipTraversal: true,
                descendantsAreFocusable: false,
                child: shad.SecondaryBadge(
                  child: Text(
                    badgeText!,
                    style: theme.typography.xSmall.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );

    if (onTap == null) {
      return shad.OutlinedContainer(
        theme: shad.OutlinedContainerTheme(
          backgroundColor: isSelected ? colors.primary.withAlpha(14) : colors.card,
          borderColor: isSelected ? colors.primary : colors.border,
          borderWidth: isSelected ? 1.5 : 1.0,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          padding: EdgeInsets.all(pad),
        ),
        child: content,
      );
    }

    return shad.Button(
      onPressed: onTap,
      disableFocusOutline: true,
      style: const shad.ButtonStyle.card()
          .withBackgroundColor(
            color: isSelected ? colors.primary.withAlpha(14) : colors.card,
            hoverColor: colors.accent.withAlpha(120),
          )
          .withBorder(
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
            focusBorder: Border.all(
              color: colors.primary.withAlpha(153),
              width: 1.5,
            ),
          )
          .withBorderRadius(
            borderRadius: BorderRadius.circular(theme.radiusMd),
          )
          .withPadding(
            padding: EdgeInsets.all(pad),
          ),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: false,
        child: content,
      ),
    );
  }

  Widget _buildSparkline(List<double> points, Color accent) {
    double minVal = points.first;
    double maxVal = points.first;
    for (final v in points) {
      minVal = math.min(minVal, v);
      maxVal = math.max(maxVal, v);
    }
    final range = (maxVal - minVal).abs() < 0.001 ? 1.0 : (maxVal - minVal);

    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i]),
    ];

    return IgnorePointer(
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: minVal - (range * 0.12),
          maxY: maxVal + (range * 0.12),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              color: accent,
              barWidth: 2.0,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withAlpha(65),
                    accent.withAlpha(0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

