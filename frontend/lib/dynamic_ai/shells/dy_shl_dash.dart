/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC DASHBOARD SHELL (dy_shl_dash.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Dashboard analytics, operational KPI metric cards, and charts shell layout.
   - Framed directly underneath PageHeader on ERP landing screens.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Renders top KPI stats row (4 cards: Total Output, Pending Batches, Efficiency, Active Mills).
   - Renders 2-column analytics summary panel (recent activity + volume progress).
   - Strictly uses native `shadcn_flutter` color, typography, and density scaling.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DyShlDash] — Page Shell for Dashboard Analytics & KPI Metric Cards.
class DyShlDash extends StatelessWidget {
  final String title;

  const DyShlDash({
    super.key,
    this.title = 'Dashboard Overview',
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. KPI CARDS GRID (4 Column Responsive Row)
          Row(
            children: [
              _buildKpiCard(
                theme,
                colors,
                title: 'Total Production',
                value: '42,850 Mts',
                change: '+12.4%',
                isPositive: true,
                icon: shad.LucideIcons.trendingUp,
              ),
              const shad.DensityGap(shad.gapMd),
              _buildKpiCard(
                theme,
                colors,
                title: 'Pending Batches',
                value: '18 Batches',
                change: '3 Critical',
                isPositive: false,
                icon: shad.LucideIcons.scissors,
              ),
              const shad.DensityGap(shad.gapMd),
              _buildKpiCard(
                theme,
                colors,
                title: 'Cutting Efficiency',
                value: '94.2%',
                change: '+2.1%',
                isPositive: true,
                icon: shad.LucideIcons.activity,
              ),
              const shad.DensityGap(shad.gapMd),
              _buildKpiCard(
                theme,
                colors,
                title: 'Active Mills',
                value: '14 Suppliers',
                change: '100% On-time',
                isPositive: true,
                icon: shad.LucideIcons.factory,
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 2. MAIN ANALYTICS PANELS (2 Columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Production Trend Summary Card
              Expanded(
                flex: 6,
                child: shad.Card(
                  child: Padding(
                    padding: EdgeInsets.all(16 * theme.scaling),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Monthly Output Analytics',
                              style: theme.typography.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const shad.OutlineBadge(child: Text('FY 26-27')),
                          ],
                        ),
                        const shad.DensityGap(shad.gapMd),
                        Container(
                          height: 240 * theme.scaling,
                          decoration: BoxDecoration(
                            color: colors.muted.withAlpha(30),
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                            border: Border.all(color: colors.border),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  shad.LucideIcons.activity,
                                  size: 40 * theme.scaling,
                                  color: colors.mutedForeground,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Production Trend Graph Surface',
                                  style: theme.typography.textSmall.copyWith(
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // Right: Recent Activity Log Card
              Expanded(
                flex: 4,
                child: shad.Card(
                  child: Padding(
                    padding: EdgeInsets.all(16 * theme.scaling),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Operations Log',
                          style: theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const shad.DensityGap(shad.gapMd),
                        _buildActivityItem(
                          theme,
                          colors,
                          time: '10 mins ago',
                          title: 'Batch #CC-1048 Saved',
                          desc: 'Ambaji Silks • 210 Mts processed',
                        ),
                        const shad.Divider(),
                        _buildActivityItem(
                          theme,
                          colors,
                          time: '45 mins ago',
                          title: 'Mill Receipt Received',
                          desc: 'Lot #10481-B • Royal Silk Grey',
                        ),
                        const shad.Divider(),
                        _buildActivityItem(
                          theme,
                          colors,
                          time: '2 hours ago',
                          title: 'Challan #CH-884 Approved',
                          desc: 'Dispatch to Shree Ram Dyeing',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    return Expanded(
      child: shad.Card(
        child: Padding(
          padding: EdgeInsets.all(14 * theme.scaling),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icon(icon, size: 16 * theme.scaling, color: colors.mutedForeground),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.typography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  shad.SecondaryBadge(
                    child: Text(
                      change,
                      style: theme.typography.xSmall.copyWith(
                        color: isPositive ? colors.primary : colors.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String time,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * theme.scaling),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8 * theme.scaling,
            height: 8 * theme.scaling,
            margin: EdgeInsets.only(top: 4 * theme.scaling),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
