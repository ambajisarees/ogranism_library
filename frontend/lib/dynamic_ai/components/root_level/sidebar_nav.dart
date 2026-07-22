import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Model representing a navigation item in [DynamicSidebarNav].
class DynamicSidebarNavItem {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isHeader;

  const DynamicSidebarNavItem({
    this.icon,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.isHeader = false,
  });
}

/// Pure native [shad.NavigationSidebar] wrapper for textile ERP navigation.
class DynamicSidebarNav extends StatelessWidget {
  final List<DynamicSidebarNavItem> items;
  final List<Widget> footerItems;
  final Widget? header;
  final double collapsedWidth;
  final double expandedWidth;
  final bool expanded;

  const DynamicSidebarNav({
    super.key,
    required this.items,
    this.footerItems = const [],
    this.header,
    this.collapsedWidth = 64.0,
    this.expandedWidth = 200.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.isHeader) {
        if (expanded) {
          children.add(
            shad.NavigationItem(
              key: ValueKey('header_$i'),
              enabled: false,
              label: Text(
                item.label.toUpperCase(),
                style: theme.typography.textMuted.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: colors.mutedForeground,
                ),
              ),
              child: const SizedBox.shrink(),
            ),
          );
        }
        continue;
      }

      final smallIconSize = theme.iconTheme.small.size;
      final iconWidget = item.icon != null
          ? Icon(item.icon, size: smallIconSize)
          : SizedBox(width: smallIconSize, height: smallIconSize);

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

    final currentWidth = expanded ? expandedWidth : collapsedWidth;

    return shad.NavigationSidebar(
      backgroundColor: colors.background,
      expanded: expanded,
      constraints: BoxConstraints(
        minWidth: currentWidth,
        maxWidth: currentWidth,
      ),
      labelType: expanded
          ? shad.NavigationLabelType.all
          : shad.NavigationLabelType.none,
      header: header != null ? [header!] : null,
      footer: footerItems.isNotEmpty ? footerItems : null,
      children: children,
    );
  }
}
