import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellProgressBar] — Linear mathematical progress visualizer atom.
///
/// Accepts a [value] between 0.0 and 1.0. Renders a theme-aligned track 
/// and progress bar. Used for file uploads, process status, and goals.

/// Continuous or determinate linear loading geometry mapping to Shadcn/Progress
class CellProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final bool isIndeterminate;

  const CellProgressBar({
    super.key,
    required this.value,
    this.color,
    this.isIndeterminate = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isIndeterminate) {
      return LinearProgressIndicator(
        backgroundColor: OrganismTheme.colorsOf(context).surfaceSubtle,
        color: color ?? OrganismTheme.colorsOf(context).primary,
        minHeight: 8,
        borderRadius: OrganismTheme.borderSm,
      );
    }

    final colors = OrganismTheme.colorsOf(context);
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: OrganismTheme.borderSm,
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? colors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
