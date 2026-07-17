import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';

/// [TissueKpiCard] — Dashboard KPI Metric with Sparklines
class TissueKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String deltaText;
  final bool isPositive;
  final List<double> sparklineData;

  const TissueKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.deltaText,
    required this.isPositive,
    required this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final trendColor = isPositive ? colors.success : colors.error;

    return CellBox(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: OrganismTheme.labelMedium(context),
              ),
              Row(
                children: [
                  Icon(
                    isPositive ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                    size: 14,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deltaText,
                    style: OrganismTheme.labelMedium(context).copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: OrganismTheme.spacingMd),
          Text(
            value,
            style: OrganismTheme.displayLarge(context),
          ),
          const SizedBox(height: OrganismTheme.spacingMd),
          if (sparklineData.isNotEmpty)
            SizedBox(
              height: 48,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (sparklineData.length - 1).toDouble(),
                  minY: sparklineData.reduce((a, b) => a < b ? a : b) * 0.9,
                  maxY: sparklineData.reduce((a, b) => a > b ? a : b) * 1.1,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sparklineData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: colors.primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: const LineTouchData(enabled: false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
