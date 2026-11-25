/*
================================================================================
LLM CONTEXT & QUERY SPACE — LIVE COMPLETION RATIO METER (itm_completion_meter.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Renders the real-time "Clean-As-You-Go" Completion Ratio (`comp_score` 0-100%)
     feedback panel inside the Add/Upgrade Item Modal (`dia_itm_add_edit.dart`).
   - Compares the newly enriched `sb_item` against the chosen legacy `sq_QUAL`
     baseline and displays a 4-pillar breakdown with checklist hints.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Evaluates 4 pillars (25 points each): Identity, GST Compliance, Costing,
     and Admin-governed Domain Specs & Warehouse Reorder.
   - Uses pure native `shadcn_flutter` tokens (`shad.OutlinedContainer`,
     `shad.LinearProgressIndicator`, `shad.PrimaryBadge`, `shad.SecondaryBadge`,
     `shad.DensityGap`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Zero custom `Container` or `BoxDecoration` wrappers.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../models/masters/items/mdl_sb_item.dart';

/// [ItmCompletionMeter] — Real-time 0-100% Completion Ratio & Legacy Delta Widget.
class ItmCompletionMeter extends StatelessWidget {
  final SbCompBreakdown breakdown;
  final String? legacyQcode;

  const ItmCompletionMeter({
    super.key,
    required this.breakdown,
    this.legacyQcode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.75;

    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: breakdown.isGoldStandard ? colors.primary : colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Header Row: Title + Legacy Delta + Score Badge
          Row(
            children: [
              Icon(
                breakdown.isGoldStandard
                    ? shad.LucideIcons.circleCheck
                    : shad.LucideIcons.gauge,
                size: 16 * theme.scaling,
                color: breakdown.isGoldStandard
                    ? colors.primary
                    : colors.mutedForeground,
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: Text(
                  'Completion Ratio & Sanitation Check',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
              ),
              if (legacyQcode != null && legacyQcode!.isNotEmpty) ...[
                shad.SecondaryBadge(
                  child: Text(
                    'Legacy ($legacyQcode): ${breakdown.legacyBaselineScore}%  →  Now: ${breakdown.totalScore}% (+${breakdown.improvementDelta}%)',
                    style: theme.typography.xSmall.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const shad.DensityGap(0.5),
              ],
              if (breakdown.isGoldStandard)
                shad.PrimaryBadge(
                  child: Text(
                    '${breakdown.totalScore}% • ${breakdown.tierLabel}',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (breakdown.isFunctional)
                shad.SecondaryBadge(
                  child: Text(
                    '${breakdown.totalScore}% • ${breakdown.tierLabel}',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                shad.DestructiveBadge(
                  child: Text(
                    '${breakdown.totalScore}% • ${breakdown.tierLabel}',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const shad.DensityGap(0.6),

          // Progress Bar
          shad.LinearProgressIndicator(
            value: (breakdown.totalScore / 100.0).clamp(0.0, 1.0),
          ),
          const shad.DensityGap(0.75),

          // 4 Pillar Mini Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildPillarCell(
                  theme,
                  colors,
                  title: '1. Identity & Barrel',
                  pts: breakdown.identityScore,
                  maxPts: 25,
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: _buildPillarCell(
                  theme,
                  colors,
                  title: '2. GST & HSN Lock',
                  pts: breakdown.complianceScore,
                  maxPts: 25,
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: _buildPillarCell(
                  theme,
                  colors,
                  title: '3. Cost & Pricing',
                  pts: breakdown.costingScore,
                  maxPts: 25,
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: _buildPillarCell(
                  theme,
                  colors,
                  title: '4. Specs & Reorder',
                  pts: breakdown.specsScore,
                  maxPts: 25,
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.75),

          // Individual Check Chips
          Wrap(
            spacing: 6 * theme.scaling,
            runSpacing: 6 * theme.scaling,
            children: breakdown.checks.map((chk) {
              return shad.OutlinedContainer(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * theme.scaling,
                  vertical: 4 * theme.scaling,
                ),
                backgroundColor:
                    chk.isComplete ? colors.secondary : colors.background,
                borderColor: chk.isComplete ? colors.border : colors.destructive,
                borderRadius: theme.borderRadiusSm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      chk.isComplete
                          ? shad.LucideIcons.check
                          : shad.LucideIcons.circleAlert,
                      size: 12 * theme.scaling,
                      color: chk.isComplete
                          ? colors.primary
                          : colors.destructive,
                    ),
                    const shad.DensityGap(0.35),
                    Text(
                      '${chk.label} (${chk.earnedPoints}/${chk.maxPoints})',
                      style: theme.typography.xSmall.copyWith(
                        fontWeight:
                            chk.isComplete ? FontWeight.w500 : FontWeight.w600,
                        color: chk.isComplete
                            ? colors.foreground
                            : colors.destructive,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCell(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String title,
    required int pts,
    required int maxPts,
  }) {
    final bool isFull = pts >= maxPts;
    return shad.OutlinedContainer(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * theme.scaling,
        vertical: 6 * theme.scaling,
      ),
      backgroundColor: colors.background,
      borderColor: isFull ? colors.primary : colors.border,
      borderRadius: theme.borderRadiusSm,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$pts/$maxPts',
            style: theme.typography.xSmall.copyWith(
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.w700,
              color: isFull ? colors.primary : colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
