import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellGap

/// [TissueReadOnlyField] — Non-interactive data label molecule.
///
/// Headless layout block for uneditable system values ensuring layout 
/// symmetry with editable forms. Supports monospace variants for codes.


/// Headless layout block for uneditable system values ensuring layout 
/// symmetry with editable forms.
class TissueReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;
  final Color? valueColor;

  const TissueReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.isMono = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: OrganismTheme.labelLarge(context).copyWith(color: colors.textSecondary)),
        const CellGap(0.25),
        Text(
          value, 
          style: (isMono ? OrganismTheme.code(context) : OrganismTheme.bodyLarge(context)).copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
