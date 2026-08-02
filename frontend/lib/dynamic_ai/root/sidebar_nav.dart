/// LLM NOTE: DynamicSidebarNav & DynamicSidebarGroup
/// - Level: Root App Left Navigation Sidebar
/// - Purpose: Collapsible left navigation sidebar managing module sections, active item highlighting, badge counters, and keyboard navigation.

library;

/// LLM NOTE: DynamicSidebarNav & DynamicSidebarNavItem
/// - Level: Root Primary Navigation Sidebar
/// - Purpose: Pure native wrapper around shad.NavigationSidebar providing primary module navigation, section headers, collapsed/expanded states, and footer actions.
/// - Widget Composition: shad.NavigationSidebar -> header + children(shad.NavigationItem / shad.NavigationButton) + footer.
/// - Rules: Obey Sidebar Sliver Contract: All children must be native AbstractNavigationButton instances; section headers are disabled NavigationItems.

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../specs/dy_color_system.dart';

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
    final isDark = colors.brightness == Brightness.dark;
    final level0Background = DyColorSystem.resolveRootBackground(isDark);
    final slate100Hover = colors.accent;
    final slate200Selected = DyColorSystem.resolveSelectItem(isDark, colors);

    final List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.isHeader) {
        children.add(
          shad.NavigationItem(
            key: ValueKey('header_$i'),
            enabled: false,
            label: expanded ? Text(item.label.toUpperCase()) : null,
            child: const SizedBox.shrink(),
          ),
        );
        continue;
      }

      children.add(
        shad.NavigationItem(
          key: ValueKey(i),
          selected: item.isSelected,
          style: shad.ButtonStyle.ghost().copyWith(
            decoration: (context, state, decoration) {
              if (state.hovered) {
                return (decoration as BoxDecoration? ?? const BoxDecoration())
                    .copyWith(color: slate100Hover);
              }
              return decoration;
            },
          ),
          selectedStyle: shad.ButtonStyle.secondary().copyWith(
            decoration: (context, state, decoration) {
              return (decoration as BoxDecoration? ?? const BoxDecoration())
                  .copyWith(color: slate200Selected);
            },
          ),
          onChanged: (isSelected) {
            if (isSelected && item.onTap != null) {
              item.onTap!();
            }
          },
          label: Text(item.label),
          child: item.icon != null ? Icon(item.icon) : const SizedBox.shrink(),
        ),
      );
    }

    final currentWidth = expanded ? expandedWidth : collapsedWidth;

    return shad.NavigationSidebar(
      backgroundColor: level0Background,
      expanded: expanded,
      constraints: BoxConstraints(
        minWidth: currentWidth,
        maxWidth: currentWidth,
      ),
      labelType: expanded
          ? shad.NavigationLabelType.all
          : shad.NavigationLabelType.tooltip,
      header: header != null ? [header!] : null,
      footer: footerItems.isNotEmpty ? footerItems : null,
      children: children,
    );
  }
}
