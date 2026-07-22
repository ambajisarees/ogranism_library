import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Compact KPI card primitive built on native [shad.Card].
class DynamicMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? subtext;
  final IconData? icon;
  final Widget? trendBadge;

  const DynamicMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.subtext,
    this.icon,
    this.trendBadge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final padding = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    return shad.Card(
      borderColor: colors.border,
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(theme.density.baseGap * theme.scaling * 0.5),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                  ),
                  child: Icon(icon, size: 14, color: colors.primary),
                ),
                const shad.DensityGap(shad.gapSm),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.typography.textSmall.copyWith(
                    color: colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trendBadge != null) trendBadge!,
            ],
          ),
          const shad.DensityGap(shad.gapSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.typography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                ),
              ),
              if (unit != null) ...[
                const shad.DensityGap(shad.gapXs),
                Text(
                  unit!,
                  style: theme.typography.textSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
          if (subtext != null) ...[
            const shad.DensityGap(shad.gapXs),
            Text(
              subtext!,
              style: theme.typography.textMuted.copyWith(
                fontSize: 11,
                color: colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Container row widget for displaying [DynamicMetricCard] widgets above DAB.
class DynamicMetricRow extends StatelessWidget {
  final List<DynamicMetricCard> cards;

  const DynamicMetricRow({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const shad.DensityGap(shad.gapSm),
        ],
      ],
    );
  }
}
