import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/box.dart';     // Direct import for CellBox
import '../cells/spatial.dart'; // Direct import for CellGap/CellPad

/// [TissueEmptyState] — Visual placeholder for missing data collections molecule.
///
/// Fallback UI state used when SQL queries return no results. 
/// Centrally manages centering, icon sizing, and action row spacing.


/// Fallback state when SQL queries return no data.
class TissueEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const TissueEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Center(
      child: CellPad(
        multiplier: 2.0,
        child: Row(
          children: [
            Expanded(
              child: CellBox(
                borderRadius: OrganismTheme.borderLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CellPad.standard(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: OrganismTheme.iconSizeLg,
                color: colors.textMuted,
              ),
            ),
          ),
          const CellGap(1.5),
          Text(title, style: OrganismTheme.titleMedium(context).copyWith(color: colors.textPrimary)),
          CellGap.small,
          Text(
            message,
            textAlign: TextAlign.center,
            style: OrganismTheme.bodyMedium(context).copyWith(color: colors.textSecondary),
          ),
          if (action != null) ...[
            const CellGap(1.5),
            action!
          ]
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);
}
}
