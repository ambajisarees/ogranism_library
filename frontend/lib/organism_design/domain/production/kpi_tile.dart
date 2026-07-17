import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';

enum DomainKpiTrend { up, down, neutral }

class DomainKpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? delta;
  final DomainKpiTrend trend;

  const DomainKpiTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.delta,
    this.trend = DomainKpiTrend.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OrganismTheme.spacingMd,
        vertical: OrganismTheme.spacingLg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: OrganismTheme.labelMedium(context).copyWith(
              color: colors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingSm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: OrganismTheme.numericLarge(context).copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: OrganismTheme.labelSmall(context).copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: OrganismTheme.spacingSm),
            _buildDelta(context, colors),
          ],
        ],
      ),
    );
  }

  Widget _buildDelta(BuildContext context, OrganismColors colors) {
    Color deltaColor;
    IconData icon;

    switch (trend) {
      case DomainKpiTrend.up:
        deltaColor = colors.success;
        icon = LucideIcons.trendingUp;
        break;
      case DomainKpiTrend.down:
        deltaColor = colors.error;
        icon = LucideIcons.trendingDown;
        break;
      case DomainKpiTrend.neutral:
        deltaColor = colors.textMuted;
        icon = LucideIcons.minus;
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: deltaColor),
        const SizedBox(width: 4),
        Text(
          delta!,
          style: OrganismTheme.labelMedium(context).copyWith(
            color: deltaColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
