import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/box.dart';    // Direct import for CellBox
import '../cells/button.dart'; // Direct import for CellButton

/// [TissueStepper] — Discrete numerical input controller molecule.
///
/// Implements exact +/- increment logic with ghost buttons and a 
/// centered value display, ensuring symmetry with global action scaling.


/// Exact +/- stepper control geometry
class TissueStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const TissueStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CellBox(
      borderRadius: OrganismTheme.borderSm,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CellButton(
            text: '', // icon only
            icon: LucideIcons.minus,
            variant: CellButtonVariant.ghost,
            onPressed: () => onChanged(value - 1),
          ),
          Container(
            width: OrganismTheme.spacing2Xl,
            alignment: Alignment.center,
            child: Text(value.toString(), style: OrganismTheme.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
          ),
          CellButton(
            text: '', // icon only
            icon: LucideIcons.plus,
            variant: CellButtonVariant.ghost,
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
