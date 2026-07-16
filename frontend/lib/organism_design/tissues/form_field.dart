import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/label.dart';   // Direct import for CellLabel
import '../cells/spatial.dart'; // Direct import for CellGap

/// [TissueFormField] — Label + Content stack with validation error track.
///
/// Standardized composition of form elements. Handles layout spacing 
/// between label, input, and optional [errorText] using theme tokens.

/// Standardized Composition of Form Elements: Label + Input + Error
class TissueFormField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? errorText;
  final Widget inputCell; // Expects a CellInput, CellCheckbox, or TissueDropdown

  const TissueFormField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.errorText,
    required this.inputCell,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CellLabel(text: label, isRequired: isRequired),
        CellGap.small,
        inputCell,
        if (errorText != null) ...[
          const CellGap(0.25),
          Text(errorText!, style: OrganismTheme.bodySmall(context).copyWith(color: colors.error)),
        ]
      ],
    );
  }
}
