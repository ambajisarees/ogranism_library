/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC SUMMARY BAR (dy_summary_bar.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Fixed-height summary footer bar component for Add/Edit form workflows & reporting panes.
   - Renders a horizontal row of financial KPI metrics, yield indicators, and charting summary tiles.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Height: ~88px scaled (`88 * theme.scaling`).
   - Uses native `shadcn_flutter` color tokens (`colors.card`, `colors.border`, `colors.primary`).
   - Accepts list of [DySummaryMetricTile] or custom action widgets.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Metric model for [DySummaryBar].
class DySummaryMetricTile {
  final String label;
  final String value;
  final String? subValue;
  final IconData? icon;
  final Color? accentColor;

  const DySummaryMetricTile({
    required this.label,
    required this.value,
    this.subValue,
    this.icon,
    this.accentColor,
  });
}

/// [DySummaryBar] — Fixed-Height Horizontal Summary Footer Component.
class DySummaryBar extends StatelessWidget {
  final List<DySummaryMetricTile> metrics;
  final Widget? trailingActions;
  final double height;

  const DySummaryBar({
    super.key,
    required this.metrics,
    this.trailingActions,
    this.height = 88.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      backgroundColor: colors.card,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * theme.scaling,
        vertical: 12 * theme.scaling,
      ),
      child: SizedBox(
        height: (height - 24) * theme.scaling,
        child: Row(
          children: [
            // Horizontal list of Metric Tiles
            Expanded(
              child: Row(
                children: metrics.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final accent = item.accentColor ?? colors.primary;

                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  if (item.icon != null) ...[
                                    Icon(
                                      item.icon,
                                      size: 13 * theme.scaling,
                                      color: colors.mutedForeground,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: Text(
                                      item.label.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.typography.xSmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colors.mutedForeground,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                              if (item.subValue != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.subValue!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.xSmall.copyWith(
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (idx < metrics.length - 1) ...[
                          VerticalDivider(
                            color: colors.border,
                            width: 24 * theme.scaling,
                            indent: 4,
                            endIndent: 4,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            if (trailingActions != null) ...[
              const shad.DensityGap(shad.gapLg),
              trailingActions!,
            ],
          ],
        ),
      ),
    );
  }
}
