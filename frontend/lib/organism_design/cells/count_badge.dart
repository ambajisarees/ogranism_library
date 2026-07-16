import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellCountBadge] — Microscopic numeric notification dot.
///
/// Designed for high-density app routing and icon indicators. Renders a 
/// circular badge with a count, automatically handling [maxCount] overflows.
class CellCountBadge extends StatelessWidget {
  final int count;
  final int maxCount;

  const CellCountBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final colors = OrganismTheme.colorsOf(context);
    final displayStr = count > maxCount ? '\$maxCount+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colors.error, // Red aesthetic for semantic notifications
        borderRadius: OrganismTheme.borderPill,
        border: Border.all(color: colors.surface, width: 1.5), // Ring for contrast against backgrounds
      ),
      child: Text(
        displayStr,
        textAlign: TextAlign.center,
        style: OrganismTheme.labelSmall(context).copyWith(
          color: colors.surface,
          height: 1.1,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
