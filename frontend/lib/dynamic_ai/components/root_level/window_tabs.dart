import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicTabItem {
  final String id;
  final String title;
  final IconData icon;
  final Widget content;

  const DynamicTabItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.content,
  });
}

class DynamicTabWorkspace extends StatelessWidget {
  final List<DynamicTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<int> onTabClosed;
  final Widget placeholder;
  final VoidCallback? onSearchTriggered;
  final VoidCallback? onNotificationPressed;
  final bool isSidebarExpanded;
  final VoidCallback? onToggleSidebar;

  final List<Widget>? trailing;

  const DynamicTabWorkspace({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.placeholder,
    this.onSearchTriggered,
    this.onNotificationPressed,
    this.isSidebarExpanded = false,
    this.onToggleSidebar,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return placeholder;
    }

    final theme = shad.Theme.of(context);

    // Spacing multipliers for sizes and margins
    final baseContainerPadding =
        theme.density.baseContainerPadding * theme.scaling;

    final barHeight = baseContainerPadding * 2.5; // Responsive height
    final tabMinWidth = 120.0 * theme.scaling;
    final tabIconSize = theme.iconTheme.small.size;
    final tabCloseIconSize = theme.iconTheme.xSmall.size;

    final paneItems = tabs.map((t) => shad.TabPaneData(t)).toList();

    return shad.Scaffold(
      backgroundColor: theme.colorScheme.background,
      child: shad.ComponentTheme<shad.OutlinedContainerTheme>(
        data: shad.OutlinedContainerTheme(
          borderColor: theme.colorScheme.border,
        ),
        child: shad.ComponentTheme<shad.TabPaneTheme>(
          data: shad.TabPaneTheme(
            backgroundColor: theme.colorScheme.background,
            border: BorderSide(
              color: theme.colorScheme.border,
              width: 1.0,
            ),
          ),
          child: shad.TabPane<DynamicTabItem>(
          barHeight: barHeight,
          items: paneItems,
          focused: selectedIndex,
          onFocused: onTabSelected,
          onSort: null,
          leading: [
            if (onToggleSidebar != null)
              Padding(
                padding: EdgeInsets.only(left: 4.0 * theme.scaling),
                child: shad.IconButton.ghost(
                  size: shad.ButtonSize.small,
                  density: shad.ButtonDensity.iconDense,
                  icon: Icon(
                    isSidebarExpanded
                        ? shad.LucideIcons.panelLeftClose
                        : shad.LucideIcons.panelLeftOpen,
                    size: 16 * theme.scaling,
                  ),
                  onPressed: onToggleSidebar,
                ),
              ),
          ],
          trailing: trailing ?? [],
          itemBuilder: (context, item, index) {
            final tab = item.data;
            return shad.TabItem(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: tabMinWidth),
                child: shad.Label(
                  leading: Icon(tab.icon, size: tabIconSize),
                  trailing: shad.IconButton.ghost(
                    size: shad.ButtonSize.small,
                    density: shad.ButtonDensity.iconDense,
                    icon: Icon(shad.LucideIcons.x, size: tabCloseIconSize),
                    onPressed: () {
                      onTabClosed(index);
                    },
                  ),
                  child: Text(tab.title),
                ),
              ),
            );
          },
          child: shad.IndexedStack(
            index: selectedIndex,
            children: tabs.map((tab) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.density.baseContainerPadding *
                      theme.scaling *
                      shad.padMd,
                  vertical: theme.density.baseContainerPadding *
                      theme.scaling *
                      shad.padSm,
                ),
                child: tab.content,
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );
  }
}
