import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellGap/CellPad

/// [TissuePageHeader] — Top-level navigation and title anchor molecule.
///
/// Defines the massive title and subtitle block for an active screen route. 
/// Handles trailing action slots and standardized vertical gutter spacing.


/// The massive top-level block defining an active screen route in the ERP.
class TissuePageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const TissuePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return CellPad(
      verticalMultiplier: 1.5,
      horizontalMultiplier: 0.0,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Corrected mainAxisSize for header rows
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OrganismTheme.displayLarge(context).copyWith(color: colors.textPrimary)),
                if (subtitle != null) ...[
                  CellGap.small,
                  Text(subtitle!, style: OrganismTheme.bodyLarge(context).copyWith(color: colors.textSecondary)),
                ]
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
