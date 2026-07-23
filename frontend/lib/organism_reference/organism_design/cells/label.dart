import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellLabel] — Field title atom enforcing text requirements.
///
/// Standard heading for form inputs. Renders label text with an optional
/// required asterisk (*) using semantic theme colors.

/// Strict input label mapping directly to LabelLarge for consistency 
/// above inputs in form fields.
class CellLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  
  const CellLabel({super.key, required this.text, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: OrganismTheme.labelLarge(context).copyWith(color: colors.textPrimary)),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text('*', style: OrganismTheme.labelLarge(context).copyWith(color: colors.error)),
        ]
      ],
    );
  }
}
