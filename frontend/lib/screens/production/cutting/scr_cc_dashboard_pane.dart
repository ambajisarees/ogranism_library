/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Dashboard Pane for Multi-Cutting Cards (`cc` / Stage 2 of Production Pipeline).
   - Renders 6 aggregate KPI metric stat cards across all 311 cutting card summaries 
     with native `shadcn_flutter` typography tokens (`theme.typography.h2`, `h4`, `mono`, `xSmall`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Displays 6 Key Metrics: Total Received Mtrs, Total Fresh Sarees, Average Yield %, Average Cost / Saree, Total Investment, Average Mill Shortage %.
   - High-contrast visual cards with subtle icons and density scaling multipliers.
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../services/production/srv_cc.dart';

/// [ScrCcDashboardPane] — Dashboard KPI Metrics Pane for Multi-Cutting Cards.
class ScrCcDashboardPane extends StatelessWidget {
  final MdlCcMetrics metrics;
  final bool isLoading;

  const ScrCcDashboardPane({
    super.key,
    required this.metrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    if (isLoading) {
      return const Center(child: shad.CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Text(
            'Production Pipeline • Multi-Cutting Performance Metrics',
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.mutedForeground,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // 6-Card Metric Grid (2 Rows of 3 Cards)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'TOTAL FABRIC RECEIVED',
                  value: '${metrics.totalReceivedMeters.toStringAsFixed(0)} Mtr',
                  subValue: '311 Batch Summaries',
                  icon: shad.LucideIcons.packageCheck,
                  accentColor: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'TOTAL FRESH SAREES',
                  value: '${metrics.totalFreshPcs} Pcs',
                  subValue: 'Ready for Job Work',
                  icon: shad.LucideIcons.scissors,
                  accentColor: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'AVERAGE FRESH YIELD',
                  value: '${metrics.avgFreshYieldPct.toStringAsFixed(1)}%',
                  subValue: 'Benchmark: 85.0%',
                  icon: shad.LucideIcons.percent,
                  accentColor: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'AVERAGE COST / SAREE',
                  value: '₹${metrics.avgCostPerPc.toStringAsFixed(2)}',
                  subValue: 'Grey Purchase + Processing',
                  icon: shad.LucideIcons.tag,
                  accentColor: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'TOTAL INVENTORY CAPITAL',
                  value: '₹${(metrics.totalInvestment / 100000).toStringAsFixed(2)} L',
                  subValue: 'Landed Inventory Cost',
                  icon: shad.LucideIcons.indianRupee,
                  accentColor: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'AVERAGE MILL SHORTAGE',
                  value: '${metrics.avgShortagePct.toStringAsFixed(1)}%',
                  subValue: 'Processing Shrinkage Loss',
                  icon: shad.LucideIcons.trendingDown,
                  accentColor: colors.destructive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String subValue,
    required IconData icon,
    Color? accentColor,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final primaryColor = accentColor ?? colors.primary;

    return shad.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.mutedForeground,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                ),
                child: Icon(icon, size: 14, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
