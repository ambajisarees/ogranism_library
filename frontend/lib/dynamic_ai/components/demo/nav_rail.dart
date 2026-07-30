/// LLM NOTE: DynamicNavRail & DynamicNavRailItem
/// - Level: Demo / Fallback Navigation Rail
/// - Purpose: Alternative slim navigation rail implementation for compact displays.
/// - Widget Composition: Container -> Column(Header + Nav items list + Footer items).

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicNavRailItem {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isHeader;

  const DynamicNavRailItem({
    this.icon,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.isHeader = false,
  });
}

class DynamicNavRail extends StatelessWidget {
  final List<DynamicNavRailItem> items;
  final List<Widget> footerItems;
  final double width;
  final Widget? header;
  final double expandedSize;
  final bool expanded;

  const DynamicNavRail({
    super.key,
    required this.items,
    required this.footerItems,
    this.width = 64.0,
    this.header,
    this.expandedSize = 180.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // 1. Map main items to native NavigationItem / Header
    final List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      if (item.isHeader) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: theme.density.baseGap * shad.gapXs,
              horizontal: theme.density.baseGap * shad.gapXs,
            ),
            child: const shad.Divider(),
          ),
        );
        continue;
      }

      final smallIconSize = theme.iconTheme.small.size;
      final iconWidget = item.icon != null ? Icon(item.icon, size: smallIconSize) : SizedBox(width: smallIconSize, height: smallIconSize);

      children.add(
        shad.NavigationItem(
          key: ValueKey(i),
          selected: item.isSelected,
          onChanged: (isSelected) {
            if (isSelected && item.onTap != null) {
              item.onTap!();
            }
          },
          label: Text(item.label),
          child: iconWidget,
        ),
      );
    }

    // 3. Build native NavigationRail
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: colors.border,
            width: 1.0,
          ),
        ),
      ),
      child: shad.NavigationRail(
        backgroundColor: colors.background,
        alignment: shad.NavigationRailAlignment.start,
        labelType: expanded ? shad.NavigationLabelType.none : shad.NavigationLabelType.tooltip,
        expanded: expanded,
        collapsedSize: width,
        expandedSize: expandedSize,
        header: header != null ? [header!] : null,
        footer: footerItems.isNotEmpty ? footerItems : null,
        children: children,
      ),
    );
  }
}
