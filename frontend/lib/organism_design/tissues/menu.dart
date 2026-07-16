import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellGap

/// [TissueMenu] — Multi-choice anchored list molecule.
///
/// Natively maps [Shadcn]'s DropdownMenu onto a standardized [PopupMenuButton].
/// Supports icons, destructive semantic states, and precise ERP scaling.


/// Models a single menu item for TissueMenu
class TissueMenuItemData {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const TissueMenuItemData({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
  });
}

/// Natively maps Shadcn's DropdownMenu onto a standard flutter PopupMenu with exact dimensional scaling.
class TissueMenu extends StatelessWidget {
  final Widget child; // Trigger
  final List<TissueMenuItemData> items;

  const TissueMenu({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return PopupMenuButton<int>(
      offset: const Offset(0, OrganismTheme.buttonHeightStandard),
      color: colors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: OrganismTheme.borderMd,
        side: BorderSide(color: colors.border),
      ),
      tooltip: '', // Override native long-press tooltip
      child: child,
      itemBuilder: (context) {
        return items.asMap().entries.map((entry) {
          final item = entry.value;
          final color = item.isDestructive ? colors.error : colors.textPrimary;
          return PopupMenuItem<int>(
            value: entry.key,
            onTap: item.onTap,
            height: OrganismTheme.buttonHeightStandard,
            textStyle: OrganismTheme.bodyMedium(context).copyWith(color: color),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: OrganismTheme.iconSizeSm,
                    color: color,
                  ),
                  CellGap.standard,
                ],
                Text(item.label),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
