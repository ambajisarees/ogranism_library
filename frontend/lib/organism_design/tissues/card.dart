import 'package:flutter/material.dart';
import '../cells/box.dart'; // Direct import for CellBox

/// [TissueCard] — Composable layout boundary molecule.
///
/// Wraps a [Column] of children in a standardized [CellBox] surface.
/// Provides exact ERP physical mapping (1px solid border, surface fill).


/// A composable layout boundary replacing hardcoded static cards.
/// Provides exact ERP physical mapping (1px solid border, surface fill).
class TissueCard extends StatelessWidget {
  final List<Widget> children;
  final bool hasShadow;
  final EdgeInsetsGeometry padding;

  const TissueCard({
    super.key,
    required this.children,
    this.hasShadow = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CellBox(
      hasShadow: hasShadow,
      padding: padding,
      borderRadius: BorderRadius.zero, // Enforced sharp edges for professional look
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
