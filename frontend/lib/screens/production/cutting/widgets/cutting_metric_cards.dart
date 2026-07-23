import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../models/production/model_cutting.dart';

class CuttingMetricCards extends StatelessWidget {
  final CuttingMetricsModel metrics;
  final bool isLoading;

  const CuttingMetricCards({
    super.key,
    required this.metrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final gapSize = theme.density.baseGap * theme.scaling * shad.gapLg;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - (3 * gapSize)) / 4.0;

        return Wrap(
          spacing: gapSize,
          runSpacing: gapSize,
          children: [
            _buildMetricCard(
              context: context,
              width: itemWidth.clamp(200.0 * theme.scaling, 400.0 * theme.scaling),
              title: 'Total Sarees Cut',
              chipLabel: 'All Cards',
              value: isLoading ? '...' : '${metrics.totalSareesCut}',
              unit: 'pcs',
              badgeKind: 1, // PrimaryBadge
            ),
            _buildMetricCard(
              context: context,
              width: itemWidth.clamp(200.0 * theme.scaling, 400.0 * theme.scaling),
              title: 'Average Shortage',
              chipLabel: 'Finish vs Grey',
              value: isLoading ? '...' : metrics.avgShortagePct.toStringAsFixed(1),
              unit: '%',
              badgeKind: 2, // SecondaryBadge
            ),
            _buildMetricCard(
              context: context,
              width: itemWidth.clamp(200.0 * theme.scaling, 400.0 * theme.scaling),
              title: 'Pending Batches',
              chipLabel: 'Uncut Cards',
              value: isLoading ? '...' : '${metrics.pendingBatches}',
              unit: 'cards',
              badgeKind: 3, // OutlineBadge
            ),
            _buildMetricCard(
              context: context,
              width: itemWidth.clamp(200.0 * theme.scaling, 400.0 * theme.scaling),
              title: 'Pending Jobs',
              chipLabel: 'Unlinked',
              value: isLoading ? '...' : '${metrics.pendingJobs}',
              unit: 'cards',
              badgeKind: 3, // OutlineBadge
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required double width,
    required String title,
    required String chipLabel,
    required String value,
    required String unit,
    required int badgeKind,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    Widget badgeWidget;
    if (badgeKind == 1) {
      badgeWidget = shad.PrimaryBadge(child: Text(chipLabel));
    } else if (badgeKind == 2) {
      badgeWidget = shad.SecondaryBadge(child: Text(chipLabel));
    } else {
      badgeWidget = shad.OutlineBadge(child: Text(chipLabel));
    }

    return SizedBox(
      width: width,
      child: shad.Card(
        borderColor: colors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Title and chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
                badgeWidget,
              ],
            ),
            const shad.DensityGap(shad.gapMd),
            // Row 2: Metric value and small unit label
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.typography.mono.copyWith(
                    fontSize: theme.typography.h2.fontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                    height: 1.0,
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
                Text(
                  unit,
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
