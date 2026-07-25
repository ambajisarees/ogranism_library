import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../models/production/model_recipe_mill.dart';

/// Top row rendering 4 high-level comparison KPI cards for Mill Printing Recipes.
class MillRecipeMetricCards extends StatelessWidget {
  final MillRecipeMetricsModel metrics;
  final bool isLoading;

  const MillRecipeMetricCards({
    super.key,
    required this.metrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context: context,
            title: 'Active Recipes',
            value: isLoading ? '...' : '${metrics.totalActiveRecipes}',
            subtitle: '${metrics.totalRevisionsCount} Total Revisions',
            icon: shad.LucideIcons.soup,
            badgeColor: colors.primary,
          ),
        ),
        const shad.DensityGap(shad.gapMd),
        Expanded(
          child: _buildMetricCard(
            context: context,
            title: 'Avg Printing Rate',
            value: isLoading
                ? '...'
                : '₹${metrics.avgPrintingRate.toStringAsFixed(2)}/m',
            subtitle: 'Across all active mills',
            icon: shad.LucideIcons.indianRupee,
            badgeColor: colors.chart2,
          ),
        ),
        const shad.DensityGap(shad.gapMd),
        Expanded(
          child: _buildMetricCard(
            context: context,
            title: 'Active Mills',
            value: isLoading ? '...' : '${metrics.activeMillsCount}',
            subtitle: 'Processing Partners',
            icon: shad.LucideIcons.building,
            badgeColor: colors.chart3,
          ),
        ),
        const shad.DensityGap(shad.gapMd),
        Expanded(
          child: _buildMetricCard(
            context: context,
            title: 'Top Print Type',
            value: isLoading ? '...' : metrics.topPrintType,
            subtitle: 'Highest Volume Process',
            icon: shad.LucideIcons.printer,
            badgeColor: colors.chart4,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color badgeColor,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.Card(
      child: Padding(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shad.SecondaryBadge(
                  child: Icon(
                    icon,
                    size: 14,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.typography.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
