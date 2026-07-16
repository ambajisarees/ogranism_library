import 'package:flutter/material.dart';
import '../theme.dart';

/// [TissueMenuGroup] — A structural container for [CellMenuItem] blocks.
///
/// Handles vertical stacking and optional grouping logic for complex menus.
class TissueMenuGroup extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final bool showDivider;

  const TissueMenuGroup({
    super.key,
    required this.children,
    this.title,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingXs),
            child: Divider(color: colors.border, height: 1),
          ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OrganismTheme.spacingMd, 
              OrganismTheme.spacingSm, 
              OrganismTheme.spacingMd, 
              OrganismTheme.spacingXs
            ),
            child: Text(
              title!.toUpperCase(),
              style: OrganismTheme.labelMedium(context).copyWith(
                color: colors.textMuted,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ...children,
      ],
    );
  }
}
