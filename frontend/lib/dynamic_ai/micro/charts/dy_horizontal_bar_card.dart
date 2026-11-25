/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC HORIZONTAL BAR CARD (dy_horizontal_bar_card.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Reusable ranked horizontal bar & operational funnel component in `dynamic_ai`.
   - Powers both Top-N Leaderboards (Master Customers, Brokers/Adatiyas, Hastes,
     Transporters) and 4-Wave Dispatch / Reconciliation Funnels.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses 100% native `shadcn_flutter` primitives (`shad.Card`, `shad.LinearProgressIndicator`,
     `shad.SecondaryBadge`, `MicroButton`) and `DyColorSystem` semantic colors.
   - Supports optional category switcher tabs (`tabLabels` + `selectedTabIndex`)
     and optional row tap callbacks (`onItemTap`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Normalizes bar ratios safely against `maxValue` (guards `0.0` denominators).
   - Isolates inner badge chips with `Focus(canRequestFocus: false)` per Rule 8.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Can click through directly to filtered `Reports` or `Tasks` view in Phase 4.
================================================================================
*/

import 'dart:math' as math;
import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../specs/dy_color_system.dart';
import '../cards/dy_kpi_metric_card.dart';
import '../dy_micro_button.dart';

/// Single horizontal metric bar row for [DyHorizontalBarCard].
class DyBarMetricItem {
  final String label;
  final String formattedValue;
  final double rawValue;
  final String? subtitle;
  final String? badgeText;
  final DyKpiTone? tone;

  const DyBarMetricItem({
    required this.label,
    required this.formattedValue,
    required this.rawValue,
    this.subtitle,
    this.badgeText,
    this.tone,
  });
}

/// [DyHorizontalBarCard] — Native Ranked Leaderboard & Operational Funnel Card.
class DyHorizontalBarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<DyBarMetricItem> items;
  final List<String> tabLabels;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabChanged;
  final ValueChanged<DyBarMetricItem>? onItemTap;
  final bool showRankNumbers;
  final double? fixedMaxValue;

  const DyHorizontalBarCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    this.tabLabels = const [],
    this.selectedTabIndex = 0,
    this.onTabChanged,
    this.onItemTap,
    this.showRankNumbers = true,
    this.fixedMaxValue,
  });

  Color _resolveBarColor(DyKpiTone? tone, int index, shad.ColorScheme colors) {
    if (tone != null) {
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
    final palette = DyColorSystem.chartPalette;
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;

    double computedMax = fixedMaxValue ?? 0.0;
    if (fixedMaxValue == null) {
      for (final item in items) {
        computedMax = math.max(computedMax, item.rawValue);
      }
    }
    final safeMax = computedMax <= 0 ? 1.0 : computedMax;

    return shad.Card(
      theme: shad.CardTheme(padding: EdgeInsets.all(pad)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header + Optional Dimension Tabs
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
              if (tabLabels.isNotEmpty) ...[
                const shad.DensityGap(shad.gapSm),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6 * theme.scaling,
                    runSpacing: 6 * theme.scaling,
                    children: [
                      for (int i = 0; i < tabLabels.length; i++)
                        MicroButton(
                          label: tabLabels[i],
                          isSelected: i == selectedTabIndex,
                          isGhost: i != selectedTabIndex,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * theme.scaling,
                            vertical: 5 * theme.scaling,
                          ),
                          onPressed: onTabChanged != null
                              ? () => onTabChanged!(i)
                              : null,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const shad.DensityGap(shad.gapMd),

          // 2. Ranked Horizontal Bars
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24 * theme.scaling),
              child: Center(
                child: Text(
                  'No records in selected filter',
                  style: theme.typography.textSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const shad.DensityGap(shad.gapSm),
                  _buildBarRow(
                    theme,
                    colors,
                    items[i],
                    i,
                    (items[i].rawValue / safeMax).clamp(0.0, 1.0),
                    _resolveBarColor(items[i].tone, i, colors),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBarRow(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    DyBarMetricItem item,
    int index,
    double progress,
    Color barColor,
  ) {
    final rowBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (showRankNumbers) ...[
              SizedBox(
                width: 24 * theme.scaling,
                child: Text(
                  '#${index + 1}',
                  style: theme.typography.xSmall.copyWith(
                    fontFamily: theme.typography.mono.fontFamily,
                    color: index < 3 ? colors.primary : colors.mutedForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
              ),
            ),
            if (item.badgeText != null && item.badgeText!.isNotEmpty) ...[
              const shad.DensityGap(shad.gapXs),
              Focus(
                canRequestFocus: false,
                skipTraversal: true,
                descendantsAreFocusable: false,
                child: shad.SecondaryBadge(
                  child: Text(
                    item.badgeText!,
                    style: theme.typography.xSmall.copyWith(
                      color: barColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const shad.DensityGap(shad.gapSm),
            Text(
              item.formattedValue,
              style: theme.typography.mono.copyWith(
                fontSize: 12.5 * theme.scaling,
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
          ],
        ),
        if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
          SizedBox(height: 2 * theme.scaling),
          Padding(
            padding: EdgeInsets.only(
              left: showRankNumbers ? 24 * theme.scaling : 0,
            ),
            child: Text(
              item.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
        ],
        SizedBox(height: 5 * theme.scaling),
        Padding(
          padding: EdgeInsets.only(
            left: showRankNumbers ? 24 * theme.scaling : 0,
          ),
          child: shad.LinearProgressIndicator(
            value: progress,
            theme: shad.LinearProgressIndicatorTheme(
              color: barColor,
              backgroundColor: colors.muted,
              minHeight: 5 * theme.scaling,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ],
    );

    if (onItemTap == null) return rowBody;

    return GestureDetector(
      onTap: () => onItemTap!(item),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: rowBody,
      ),
    );
  }
}

