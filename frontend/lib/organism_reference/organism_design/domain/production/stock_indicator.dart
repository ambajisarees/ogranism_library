import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainStockIndicator] — Linear density bar for inventory levels.
///
/// Use for visualizing stock-on-hand vs reorder levels.
/// Semantic colors: Red (Critical), Amber (Warning), Fuchsia (Healthy).
class DomainStockIndicator extends StatelessWidget {
  final double current;
  final double max;
  final bool isCompact;

  const DomainStockIndicator({
    super.key,
    required this.current,
    required this.max,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final ratio = (current / max).clamp(0.0, 1.0);
    
    Color barColor;
    if (ratio < 0.2) {
      barColor = colors.error;
    } else if (ratio < 0.5) {
      barColor = colors.warning;
    } else {
      barColor = colors.primary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CellProgressBar(
          value: ratio,
          color: barColor,
          isIndeterminate: false,
        ),
        if (!isCompact) ...[
          const CellGap(0.25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(ratio * 100).toInt()}% ON HAND',
                style: OrganismTheme.labelSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${current.toInt()} / ${max.toInt()}',
                style: OrganismTheme.numericSmall(context).copyWith(
                  fontSize: 9,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
