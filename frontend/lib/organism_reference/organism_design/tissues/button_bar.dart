import 'package:flutter/material.dart';
import '../cells/spatial.dart'; // Direct import for CellGap/CellPad

/// [TissueButtonBar] — Horizontal action group molecule.
///
/// Hodes multiple buttons, icons, and dividers with standardized ERP spacing.
/// Used for header actions, form footer, and kinetic toolbars.


/// A flexible horizontal bar housing multiple buttons, icons, and dividers.
/// Standard for ERP header actions and form footers.
class TissueButtonBar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;

  const TissueButtonBar({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) CellGap.standard,
          children[i],
        ],
      ],
    );
  }
}
