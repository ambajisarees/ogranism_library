import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellPlaceholder] — Development skeleton block atom.
///
/// Renders a muted placeholder box with a label. Used for layout prototyping
/// and documentation examples.

/// A standard atomic placeholder for documentation and prototyping.
class CellPlaceholder extends StatelessWidget {
  final double? width;
  final double height;
  final String? label;

  const CellPlaceholder({
    super.key,
    this.width,
    this.height = 40,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: OrganismTheme.borderSm,
        border: Border.all(
          color: colors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          label ?? 'Placeholder',
          style: OrganismTheme.bodySmall(context).copyWith(
            color: colors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
