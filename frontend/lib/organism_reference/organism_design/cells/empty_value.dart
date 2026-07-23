import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellEmptyValue] — Universal visual placeholder for `null` or missing data.
///
/// Bypasses throwing scattered empty text gaps by uniformly enforcing a visual Em-Dash ('—')
/// token that maps standard data grids smoothly so developers know the data field isn't completely broken, 
/// but just explicitly empty/null.
class CellEmptyValue extends StatelessWidget {
  final String fallbackText;

  const CellEmptyValue({
    super.key,
    this.fallbackText = '—',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Empty',
      child: Text(
        fallbackText,
        style: OrganismTheme.bodyMedium(context).copyWith(
          color: OrganismTheme.colorsOf(context).textMuted.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
