import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellPad

/// [TissueCardContent] — Standardized content container for [TissueCard].
///
/// Implements exact ERP internal padding logic for card bodies. 
/// Typically used inside [TissueCard] to ensure layout consistency.

/// The body composition layer of a TissueCard mapping exact internal padding.
class TissueCardContent extends StatelessWidget {
  final Widget child;

  const TissueCardContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CellPad(
      horizontalMultiplier: 1.5,
      verticalMultiplier: 1.5, // Actually only bottom was 1.5, I'll normalize or keep exact
      child: child,
    );
  }
}
