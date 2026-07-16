import 'package:flutter/material.dart';
import '../theme.dart';
import 'focus.dart';   // Direct import for OrganismFocus
import 'spatial.dart'; // Direct import for CellGap/CellPad

/// [CellListTile] — Standard composition atom for Avatar + Text groupings.
///
/// Handles leading widgets (like [CellAvatar]), title/subtitle stacks, and 
/// trailing widgets. Injects standard [OrganismFocus] for accessibility.

/// A standard composition Cell for Avatar + Text groupings.
/// Used in NavBoat footers and TissueListCards.
class CellListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isCompact;

  const CellListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return OrganismFocus(
      onTap: onTap,
      borderRadius: OrganismTheme.borderMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: OrganismTheme.borderMd,
        child: CellPad(
          multiplier: isCompact ? 0.5 : 1.0,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                CellGap.standard,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title, 
                      style: OrganismTheme.labelLarge(context).copyWith(height: 1.1, color: colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
