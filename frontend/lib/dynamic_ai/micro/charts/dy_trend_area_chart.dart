/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC TREND AREA CHART (dy_trend_area_chart.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Reusable multi-series time-series area/line chart card inside `dynamic_ai`.
   - Designed for ERP trajectory tracking (Monthly/Weekly Sales Revenue, Bales
     Dispatched, Invoice Volume, Sales Returns comparison).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Built atop `fl_chart` (`^1.3.0`) and styled 100% with `shad.Theme.of(context)`
     and `DyColorSystem` semantic tokens (zero hardcoded `Color(...)` literals).
   - Supports interactive metric mode tabs via `MicroButton` (`modes` + `selectedModeIndex`),
     primary gradient area curve, optional dashed secondary comparison curve,
     and rich native-styled hover tooltips.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Safely handles 0-point or 1-point series without division-by-zero on Y-axis intervals.
   - Uses `LineTouchTooltipData.tooltipBorderRadius` (`fl_chart 1.3.0` API).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future option: click-on-month point callback to filter sibling tables.
================================================================================
*/

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../specs/dy_color_system.dart';
import '../dy_micro_button.dart';

/// Single X-axis bucket point for [DyTrendAreaChart].
class DyTrendPoint {
  final String label;
  final double primaryValue;
  final double? secondaryValue;
  final String? tooltipExtra;

  const DyTrendPoint({
    required this.label,
    required this.primaryValue,
    this.secondaryValue,
    this.tooltipExtra,
  });
}

/// [DyTrendAreaChart] — Native `shadcn_flutter` + `fl_chart` Area Trajectory Card.
class DyTrendAreaChart extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<DyTrendPoint> points;
  final String primarySeriesLabel;
  final String? secondarySeriesLabel;
  final String Function(double value)? valueFormatter;
  final List<String> modeLabels;
  final int selectedModeIndex;
  final ValueChanged<int>? onModeChanged;
  final double chartHeight;

  const DyTrendAreaChart({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.primarySeriesLabel,
    this.secondarySeriesLabel,
    this.valueFormatter,
    this.modeLabels = const [],
    this.selectedModeIndex = 0,
    this.onModeChanged,
    this.chartHeight = 250,
  });

  String _formatVal(double v) {
    if (valueFormatter != null) return valueFormatter!(v);
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final primaryColor = DyColorSystem.cyan500;
    final secondaryColor = DyColorSystem.indigo500;
    final hasSecondary = secondarySeriesLabel != null &&
        points.any((p) => (p.secondaryValue ?? 0) > 0);

    return shad.Card(
      theme: shad.CardTheme(padding: EdgeInsets.all(pad)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Card Header + Mode Switcher Pills
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.typography.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.foreground,
                      ),
                    ),
                    const shad.DensityGap(shad.gapXs),
                    Text(
                      subtitle,
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (modeLabels.isNotEmpty) ...[
                const shad.DensityGap(shad.gapMd),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6 * theme.scaling,
                    runSpacing: 6 * theme.scaling,
                    children: [
                      for (int i = 0; i < modeLabels.length; i++)
                        MicroButton(
                          label: modeLabels[i],
                          isSelected: i == selectedModeIndex,
                          isGhost: i != selectedModeIndex,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * theme.scaling,
                            vertical: 5 * theme.scaling,
                          ),
                          onPressed: onModeChanged != null
                              ? () => onModeChanged!(i)
                              : null,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const shad.DensityGap(shad.gapSm),

          // 2. Legend Strip
          Row(
            children: [
              _buildLegendDot(theme, colors, primaryColor, primarySeriesLabel),
              if (hasSecondary) ...[
                const shad.DensityGap(shad.gapMd),
                _buildLegendDot(
                  theme,
                  colors,
                  secondaryColor,
                  secondarySeriesLabel!,
                  isDashed: true,
                ),
              ],
            ],
          ),
          const shad.DensityGap(shad.gapMd),

          // 3. Chart Surface
          SizedBox(
            height: chartHeight * theme.scaling,
            child: points.isEmpty
                ? _buildEmptyChart(theme, colors)
                : _buildLineChart(
                    theme,
                    colors,
                    primaryColor,
                    secondaryColor,
                    hasSecondary,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    Color dotColor,
    String label, {
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        shad.OutlinedContainer(
          width: 10 * theme.scaling,
          height: 10 * theme.scaling,
          theme: shad.OutlinedContainerTheme(
            backgroundColor: isDashed ? colors.card : dotColor,
            borderColor: dotColor,
            borderWidth: 2.0,
            borderRadius: BorderRadius.circular(99),
          ),
          child: const SizedBox.shrink(),
        ),
        const shad.DensityGap(shad.gapXs),
        Text(
          label,
          style: theme.typography.xSmall.copyWith(
            color: colors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(shad.ThemeData theme, shad.ColorScheme colors) {
    return shad.OutlinedContainer(
      theme: shad.OutlinedContainerTheme(
        backgroundColor: colors.muted.withAlpha(40),
        borderColor: colors.border,
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Center(
        child: Text(
          'No time-series data for selected period',
          style: theme.typography.textSmall.copyWith(
            color: colors.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    Color primaryColor,
    Color secondaryColor,
    bool hasSecondary,
  ) {
    double maxY = 0;
    for (final p in points) {
      maxY = math.max(maxY, p.primaryValue);
      if (hasSecondary && p.secondaryValue != null) {
        maxY = math.max(maxY, p.secondaryValue!);
      }
    }
    final effectiveMaxY = maxY <= 0 ? 10.0 : maxY * 1.16;
    final yInterval = effectiveMaxY / 4.0;
    final xLabelStride = points.length > 10 ? ((points.length / 8).ceil()) : 1;

    final primarySpots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].primaryValue),
    ];

    final secondarySpots = <FlSpot>[
      if (hasSecondary)
        for (int i = 0; i < points.length; i++)
          FlSpot(i.toDouble(), points[i].secondaryValue ?? 0),
    ];

    return Padding(
      padding: EdgeInsets.only(right: 12 * theme.scaling, top: 6 * theme.scaling),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1.0, (points.length - 1).toDouble()),
          minY: 0,
          maxY: effectiveMaxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.border.withAlpha(150),
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1),
              left: BorderSide(color: colors.border.withAlpha(120), width: 1),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 54 * theme.scaling,
                interval: yInterval,
                getTitlesWidget: (val, meta) {
                  if (val == meta.max) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(right: 6 * theme.scaling),
                    child: Text(
                      _formatVal(val),
                      textAlign: TextAlign.right,
                      style: theme.typography.xSmall.copyWith(
                        fontFamily: theme.typography.mono.fontFamily,
                        color: colors.mutedForeground,
                        fontSize: 10.5 * theme.scaling,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28 * theme.scaling,
                interval: 1,
                getTitlesWidget: (val, meta) {
                  final idx = val.round();
                  if (idx < 0 || idx >= points.length) {
                    return const SizedBox.shrink();
                  }
                  if (idx % xLabelStride != 0 && idx != points.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8 * theme.scaling),
                    child: Text(
                      points[idx].label,
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5 * theme.scaling,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              maxContentWidth: 210 * theme.scaling,
              tooltipBorderRadius: BorderRadius.circular(theme.radiusMd),
              tooltipBorder: BorderSide(color: colors.border, width: 1),
              getTooltipColor: (_) => colors.popover,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.x.round().clamp(0, points.length - 1);
                  final pt = points[idx];
                  final isPrimary = spot.barIndex == 0;
                  final seriesName = isPrimary
                      ? primarySeriesLabel
                      : (secondarySeriesLabel ?? 'Secondary');
                  final extra = (isPrimary && pt.tooltipExtra != null)
                      ? '\n${pt.tooltipExtra}'
                      : '';
                  return LineTooltipItem(
                    isPrimary ? '${pt.label}\n' : '',
                    theme.typography.xSmall.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '$seriesName: ${_formatVal(spot.y)}$extra',
                        style: theme.typography.xSmall.copyWith(
                          fontFamily: theme.typography.mono.fontFamily,
                          color: isPrimary ? primaryColor : secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: primarySpots,
              isCurved: true,
              curveSmoothness: 0.28,
              preventCurveOverShooting: true,
              color: primaryColor,
              barWidth: 2.6,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: points.length <= 16,
                getDotPainter: (spot, pct, bar, index) => FlDotCirclePainter(
                  radius: 3.2,
                  color: primaryColor,
                  strokeWidth: 1.5,
                  strokeColor: colors.card,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withAlpha(65),
                    primaryColor.withAlpha(4),
                  ],
                ),
              ),
            ),
            if (hasSecondary && secondarySpots.isNotEmpty)
              LineChartBarData(
                spots: secondarySpots,
                isCurved: true,
                curveSmoothness: 0.28,
                preventCurveOverShooting: true,
                color: secondaryColor,
                barWidth: 2.0,
                dashArray: const [5, 4],
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }
}

