import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Tab Data representation for Header Workspace Tabs.
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

/// Header Workspace Tabs component featuring a 48px top bar height,
/// pixel-perfect vertical divider between sidebar toggle and tabs,
/// 8px internal tab gap, 18px leading icons, and multi-tier surface elevation.
class DynamicHeaderTabs extends StatelessWidget {
  final List<DynamicTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<int> onTabClosed;
  final Widget placeholder;
  final VoidCallback? onSearchTriggered;
  final VoidCallback? onNotificationPressed;
  final bool isSidebarExpanded;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onNewTabPressed;
  final List<Widget>? trailing;

  const DynamicHeaderTabs({
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
    this.onNewTabPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return placeholder;
    }

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // Fixed 48.0px top bar height scaled by theme density multiplier
    final barHeight = 48.0 * theme.scaling;
    final tabMinWidth = 130.0 * theme.scaling;
    final tabIconSize = 18.0 * theme.scaling;
    final tabCloseIconSize = theme.iconTheme.xSmall.size;

    final paneItems = tabs.map((t) => shad.TabPaneData(t)).toList();
    if (onNewTabPressed != null) {
      paneItems.add(
        shad.TabPaneData(
          const DynamicTabItem(
            id: '__add_tab__',
            title: '',
            icon: shad.LucideIcons.plus,
            content: SizedBox.shrink(),
          ),
        ),
      );
    }

    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderWidth: 1.0,
      backgroundColor: colors.card,
      borderRadius: theme.borderRadiusLg,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
      clipBehavior: Clip.antiAlias,
      child: shad.ComponentTheme<shad.TabPaneTheme>(
        data: shad.TabPaneTheme(
          backgroundColor: colors.card,
          borderRadius: theme.borderRadiusLg,
          border: BorderSide(
            color: colors.border,
            width: 1.0,
          ),
        ),
        child: shad.TabPane<DynamicTabItem>(
          barHeight: barHeight,
          items: paneItems,
          focused: selectedIndex,
          onFocused: (idx) {
            if (idx < tabs.length) {
              onTabSelected(idx);
            }
          },
          onSort: null,
          leading: [
            if (onToggleSidebar != null) ...[
              Padding(
                padding: EdgeInsets.only(left: 4.0 * theme.scaling),
                child: shad.IconButton.ghost(
                  size: shad.ButtonSize.normal,
                  density: shad.ButtonDensity.iconDense,
                  icon: Icon(
                    isSidebarExpanded
                        ? shad.LucideIcons.panelLeftClose
                        : shad.LucideIcons.panelLeftOpen,
                    size: 18.0 * theme.scaling,
                  ),
                  onPressed: onToggleSidebar,
                ),
              ),
              const shad.DensityGap(shad.gapXs),
            ],
          ],
          trailing: trailing ?? [],
          itemBuilder: (context, item, index) {
            final tab = item.data;
            if (tab.id == '__add_tab__') {
              return shad.TabItem(
                child: Center(
                  child: shad.IconButton.ghost(
                    size: shad.ButtonSize.small,
                    density: shad.ButtonDensity.iconDense,
                    icon: Icon(
                      shad.LucideIcons.plus,
                      size: tabCloseIconSize,
                      color: colors.mutedForeground,
                    ),
                    onPressed: onNewTabPressed,
                  ),
                ),
              );
            }

            return shad.TabItem(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0 * theme.scaling,
                  vertical: 4.0 * theme.scaling,
                ),
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
              ),
            );
          },
          child: shad.OutlinedContainer(
            borderColor: Colors.transparent,
            borderWidth: 0.0,
            backgroundColor: colors.card,
            borderRadius: theme.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            clipBehavior: Clip.antiAlias,
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
