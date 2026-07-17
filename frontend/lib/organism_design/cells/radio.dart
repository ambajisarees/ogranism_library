// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellRadio] — Standard mutually-exclusive scalar atom.
///
/// A precision-wrapped native [Radio] that follows the theme color palette 
/// and density rules. Use inside a group sharing the same [groupValue].

/// Exact Shadcn Radio Group primitive mapped natively.
class CellRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;

  const CellRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: colors.primary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.minimumDensity,
      ),
    );
  }
}
