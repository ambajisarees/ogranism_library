import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellDivider] — Atomic 1px structural membrane.
///
/// Provides a consistent separator line respecting theme border colors.
/// Optimized for horizontal partitions but supports [isVertical] mode.

/// The naked 1px membrane separator.
class CellDivider extends StatelessWidget {
  final bool isVertical;
  final double? length;

  const CellDivider({super.key, this.isVertical = false, this.length});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Container(
      width: isVertical ? 1 : length,
      height: isVertical ? length : 1,
      color: colors.border,
    );
  }
}
