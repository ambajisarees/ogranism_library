import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellGap/CellPad

/// [TissueCardHeader] — Standardized header box for [TissueCard] molecule.
///
/// Provides consistent padding, typography, and trailing action slots for 
/// ERP card components. Usually paired with [TissueCardContent].

/// The top composition layer of a TissueCard ensuring exact padding matrices.
class TissueCardHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;

  const TissueCardHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return CellPad(
      multiplier: 1.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OrganismTheme.titleMedium(context).copyWith(color: colors.textPrimary)),
                if (description != null) ...[
                  const CellGap(0.25),
                  Text(description!, style: OrganismTheme.bodyMedium(context).copyWith(color: colors.textSecondary)),
                ]
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
