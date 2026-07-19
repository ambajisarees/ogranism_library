import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class MetricItem {
  final Widget icon;
  final String label;
  final String value;
  final String unit;

  const MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });
}

class MetricCard extends StatelessWidget {
  final MetricItem item;

  const MetricCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.density.baseContainerPadding * shad.padXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // C1: Large icon with no background
          IconTheme(
            data: IconThemeData(
              size: 28,
              color: theme.colorScheme.primary,
            ),
            child: item.icon,
          ),
          const shad.DensityGap(shad.gapMd),
          // C2: Column with label and metric row
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // R1: Label
                Text(
                  item.label,
                  style: theme.typography.textMuted.copyWith(fontSize: 11),
                ),
                const shad.DensityGap(shad.gapXs),
                // R2: Value + Spacer + Unit type
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        item.value,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.textLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      item.unit,
                      style: theme.typography.textMuted.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
