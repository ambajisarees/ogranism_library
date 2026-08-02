/// LLM NOTE: DynamicHeaderTabs, DynamicTabItem & PageLoadingNotification
/// - Level: Root App Workspace Header Bar (48px Height)
/// - Purpose: Top workspace tab bar supporting multi-tab navigation, tab creation/closing, global Ctrl+K search trigger, theme toggle, notification bell, and a 2px active progress bar dispatched via PageLoadingNotification.
/// - Widget Composition: NotificationListener`PageLoadingNotification` -> Column(Top Header Row + 2px Progress Bar + Active Tab Content).

library;

import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../specs/dy_color_system.dart';

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

/// Notification dispatched by child screens to trigger the top 2px progress bar on DynamicHeaderTabs.
class PageLoadingNotification extends Notification {
  final bool isLoading;
  final double? progressValue;

  PageLoadingNotification(this.isLoading, {this.progressValue});
}

/// Header Workspace Tabs component featuring a 48px top bar height,
/// pixel-perfect vertical divider between sidebar toggle and tabs,
/// 8px internal tab gap, 18px leading icons, and multi-tier surface elevation.
class DynamicHeaderTabs extends StatefulWidget {
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
  final bool isLoading;
  final double? progressValue;

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
    this.isLoading = false,
    this.progressValue,
  });

  @override
  State<DynamicHeaderTabs> createState() => _DynamicHeaderTabsState();
}

class _DynamicHeaderTabsState extends State<DynamicHeaderTabs> {
  bool _childLoading = false;
  double? _childProgressValue;

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) {
      return widget.placeholder;
    }

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final showProgress = widget.isLoading || _childLoading;
    final activeProgressValue = widget.progressValue ?? _childProgressValue;

    // Fixed 48.0px top bar height scaled by theme density multiplier
    final barHeight = 48.0 * theme.scaling;
    final tabMinWidth = 130.0 * theme.scaling;
    final tabIconSize = 18.0 * theme.scaling;
    final tabCloseIconSize = theme.iconTheme.xSmall.size;

    final paneItems = widget.tabs.map((t) => shad.TabPaneData(t)).toList();
    if (widget.onNewTabPressed != null) {
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

    final isDark = theme.colorScheme.brightness == Brightness.dark;

    // Protected Custom ERP Surface Canvas Tokens (Slate 10 / Stone 980)
    final surfaceCanvasColor = DyColorSystem.resolveSurfaceCanvas(isDark);

    return NotificationListener<PageLoadingNotification>(
      onNotification: (notification) {
        setState(() {
          _childLoading = notification.isLoading;
          _childProgressValue = notification.progressValue;
        });
        return true;
      },
      child: shad.OutlinedContainer(
        borderColor: colors.border,
        borderWidth: 1.0,
        backgroundColor: surfaceCanvasColor,
        borderRadius: theme.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        clipBehavior: Clip.antiAlias,
        child: shad.ComponentTheme<shad.TabPaneTheme>(
          data: shad.TabPaneTheme(
            backgroundColor: surfaceCanvasColor,
          ),
          child: shad.TabPane<DynamicTabItem>(
            barHeight: barHeight,
            items: paneItems,
            focused: widget.selectedIndex,
            onFocused: (idx) {
              if (idx < widget.tabs.length) {
                widget.onTabSelected(idx);
              }
            },
            onSort: null,
            leading: [
              if (widget.onToggleSidebar != null) ...[
                Padding(
                  padding: EdgeInsets.only(left: 4.0 * theme.scaling),
                  child: shad.IconButton.ghost(
                    size: shad.ButtonSize.normal,
                    density: shad.ButtonDensity.iconDense,
                    icon: Icon(
                      widget.isSidebarExpanded
                          ? shad.LucideIcons.panelLeftClose
                          : shad.LucideIcons.panelLeftOpen,
                      size: 18.0 * theme.scaling,
                    ),
                    onPressed: widget.onToggleSidebar,
                  ),
                ),
                const shad.DensityGap(shad.gapXs),
              ],
            ],
            trailing: widget.trailing ?? [],
            itemBuilder: (context, item, index) {
              final tab = item.data;
              if (tab.id == '__add_tab__') {
                return shad.TabItem(
                  child: Center(
                    child: shad.IconButton.ghost(
                      focusNode: FocusNode(skipTraversal: true),
                      size: shad.ButtonSize.small,
                      density: shad.ButtonDensity.iconDense,
                      icon: Icon(
                        shad.LucideIcons.plus,
                        size: tabCloseIconSize,
                        color: colors.mutedForeground,
                      ),
                      onPressed: widget.onNewTabPressed,
                    ),
                  ),
                );
              }

              return shad.TabItem(
                child: Focus(
                  skipTraversal: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0 * theme.scaling,
                      vertical: 12.0 * theme.scaling,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: tabMinWidth),
                      child: shad.Label(
                        leading: Icon(tab.icon, size: tabIconSize),
                        trailing: shad.IconButton.ghost(
                          focusNode: FocusNode(skipTraversal: true),
                          size: shad.ButtonSize.small,
                          density: shad.ButtonDensity.iconDense,
                          icon:
                              Icon(shad.LucideIcons.x, size: tabCloseIconSize),
                          onPressed: () {
                            widget.onTabClosed(index);
                          },
                        ),
                        child: Text(tab.title),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: shad.OutlinedContainer(
              borderColor: Colors.transparent,
              borderWidth: 0.0,
              backgroundColor: surfaceCanvasColor,
              borderRadius: theme.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  shad.IndexedStack(
                    index: widget.selectedIndex,
                    children: widget.tabs.map((tab) {
                      return FocusScope(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: theme.density.baseContainerPadding *
                                shad.padLg,
                            right: theme.density.baseContainerPadding *
                                shad.padLg,
                            top: theme.density.baseContainerPadding *
                                shad.padLg,
                            bottom: theme.density.baseContainerPadding *
                                shad.padMd,
                          ),
                          child: tab.content,
                        ),
                      );
                    }).toList(),
                  ),
                  if (showProgress)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 2.0,
                      child: shad.ComponentTheme<shad.ProgressTheme>(
                        data: const shad.ProgressTheme(
                          minHeight: 2.0,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: SizedBox(
                          height: 2.0,
                          child: shad.Progress(
                            progress: activeProgressValue,
                            color: colors.primary,
                            backgroundColor: colors.primary.withAlpha(35),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
