/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Top Workspace Tab Header Bar (`DynamicHeaderTabs`) for Desktop (`shad.TabPane`
     with a 52px bar height, sidebar expand/collapse trigger, multi-tab workspace
     management, 1-9 keycap shortcut indicators, and 2px `PageLoadingNotification`
     progress bar) plus `DynamicMobileShell` for `< 768px` mobile viewports
     (leading drawer trigger, page title, trailing Search/Notifications/Tasks
     utilities, and full-width bottom `shad.TabList`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Leading Icon <-> KeyCap Switcher: Tab leading icon smoothly animates into a
     KeyCap (`1..9`) whenever `Alt` is held down (`isAltPressedNotifier`).
   - Header Action Buttons (`DynamicHeaderActionButton`): Use `ButtonSize.normal`
     with `ButtonDensity.icon` (`36px` matching SideNav) and `DyCountBadge`
     overlay pills for unread counters (`99+` cap).
   - Desktop workspace content padding: `H: 32px (padLg)`, `V: 24px (padMd)`.
   - `leading:` houses only focus-safe sidebar toggle controls; `trailing:` houses
     session utilities (`Alt+K` Search, `Alt+N` Notifications, `Alt+T` Tasks,
     `Alt+D` Theme Toggle, `Alt+U` User Avatar).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Rule 7 (`GEMINI.md`): NEVER wrap items inside `shad.TabPane` header lists with
     `Focus(descendantsAreFocusable: false)`; pass `FocusNode(skipTraversal: true)`
     directly to individual controls.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Double-click on empty tab bar area or middle-click tab closing can be added later.
================================================================================
*/

library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../services/service_keyboard_shortcuts.dart';
import '../../services/service_mobile_shell.dart';
import '../micro/dy_count_badge.dart';
import '../specs/dy_color_system.dart';

bool get _isAndroidPlatform => defaultTargetPlatform == TargetPlatform.android;

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
  final FocusScopeNode _tabContentFocusScope = FocusScopeNode(
    debugLabel: 'ActiveModuleTabFocusScope',
  );
  bool _childLoading = false;
  double? _childProgressValue;

  @override
  void initState() {
    super.initState();
    ServiceKeyboardShortcuts.instance.activeTabFocusScope =
        _tabContentFocusScope;
  }

  @override
  void didUpdateWidget(DynamicHeaderTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ServiceKeyboardShortcuts.instance.resetWorkspaceKeyboardState();
        }
      });
    }
  }

  @override
  void dispose() {
    if (ServiceKeyboardShortcuts.instance.activeTabFocusScope ==
        _tabContentFocusScope) {
      ServiceKeyboardShortcuts.instance.activeTabFocusScope = null;
    }
    _tabContentFocusScope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) {
      return widget.placeholder;
    }

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = colors.brightness == Brightness.dark;
    final gapUnit = theme.density.baseGap * scaling;
    final padUnit = theme.density.baseContainerPadding * scaling;
    final showProgress = widget.isLoading || _childLoading;
    final activeProgressValue = widget.progressValue ?? _childProgressValue;

    // Native density-scaled 52.0px top bar height matching NavRail icon visual balance
    final barHeight = (padUnit * shad.pad2xl) + (gapUnit * shad.gapXs);
    final tabMinWidth = padUnit * 8;
    final iconMdSize = theme.iconTheme.medium.size ?? 20.0;
    final tabIconSize = iconMdSize;
    final tabCloseIconSize = theme.iconTheme.xSmall.size ?? 12.0;

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
        borderRadius: theme.borderRadiusMd,
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
                  padding: EdgeInsets.only(
                    left: gapUnit * shad.gapSm,
                  ),
                  child: shad.IconButton.ghost(
                    focusNode: FocusNode(skipTraversal: true),
                    size: shad.ButtonSize.normal,
                    density: shad.ButtonDensity.icon,
                    icon: SizedBox(
                      width: iconMdSize,
                      height: iconMdSize,
                      child: Center(
                        child: Icon(
                          shad.LucideIcons.panelLeft,
                          size: iconMdSize,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                    onPressed: widget.onToggleSidebar,
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
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

              final isActiveTab = index == widget.selectedIndex;

              return shad.TabItem(
                child: Focus(
                  skipTraversal: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: gapUnit *
                          (isActiveTab ? shad.gapSm : shad.gapXs),
                      vertical: gapUnit * shad.gapSm,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: tabMinWidth),
                      child: shad.Label(
                        leading: ValueListenableBuilder<bool>(
                          valueListenable: ServiceKeyboardShortcuts
                              .instance.isAltPressedNotifier,
                          builder: (context, isAltPressed, _) {
                            return SizedBox(
                              width: iconMdSize,
                              height: iconMdSize,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 120),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                  scale: Tween<double>(begin: 0.8, end: 1.0)
                                      .animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                                child: (isAltPressed &&
                                        !_isAndroidPlatform &&
                                        index < 9)
                                    ? _buildHeaderKeyCap(
                                        context,
                                        theme,
                                        colors,
                                        '${index + 1}',
                                        key: ValueKey('tab_cap_${index + 1}'),
                                      )
                                    : Center(
                                        key: const ValueKey('tab_icon'),
                                        child: Icon(
                                          tab.icon,
                                          size: tabIconSize,
                                          color: colors.foreground,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        trailing: shad.IconButton.ghost(
                          focusNode: FocusNode(skipTraversal: true),
                          size: shad.ButtonSize.small,
                          density: shad.ButtonDensity.iconDense,
                          icon: Icon(
                            shad.LucideIcons.x,
                            size: tabCloseIconSize,
                            color: colors.mutedForeground,
                          ),
                          onPressed: () {
                            widget.onTabClosed(index);
                          },
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(right: gapUnit * shad.gapSm),
                          child: Text(
                            tab.title,
                            style: theme.typography.small.copyWith(
                              fontWeight: isActiveTab
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: colors.foreground,
                            ),
                          ),
                        ),
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
              borderRadius: theme.borderRadiusMd,
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
                  FocusScope(
                    node: _tabContentFocusScope,
                    child: shad.IndexedStack(
                      index: widget.selectedIndex,
                      children: widget.tabs.asMap().entries.map((entry) {
                        final isSelectedTab = entry.key == widget.selectedIndex;
                        final tab = entry.value;
                        return TickerMode(
                          enabled: isSelectedTab,
                          child: ExcludeFocus(
                            excluding: !isSelectedTab,
                            child: FocusTraversalGroup(
                              policy: WidgetOrderTraversalPolicy(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: padUnit * shad.padLg,
                                  vertical: padUnit * shad.padMd,
                                ),
                                child: tab.content,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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

/// Reusable header icon button that switches between its icon (with optional badge)
/// and a single-letter KeyCap whenever `Alt` is held down.
class DynamicHeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String keyCap;
  final VoidCallback onPressed;
  final int badgeCount;
  final bool showDotBadge;
  final String? tooltip;
  final bool showKeyCaps;
  final Widget? customChild;
  final EdgeInsetsGeometry? customPadding;

  const DynamicHeaderActionButton({
    super.key,
    required this.icon,
    required this.keyCap,
    required this.onPressed,
    this.badgeCount = 0,
    this.showDotBadge = false,
    this.tooltip,
    this.showKeyCaps = true,
    this.customChild,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final gapUnit = theme.density.baseGap * scaling;
    final iconMdSize = theme.iconTheme.medium.size ?? 20.0;
    final contentExtent = customChild != null ? 28.0 * scaling : iconMdSize;

    final innerContent = ValueListenableBuilder<bool>(
      valueListenable: ServiceKeyboardShortcuts.instance.isAltPressedNotifier,
      builder: (context, isAltPressed, _) {
        final showKeyCap = showKeyCaps && isAltPressed && !_isAndroidPlatform;
        return SizedBox(
          width: contentExtent,
          height: contentExtent,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: showKeyCap
                ? Center(
                    key: ValueKey('header_cap_${keyCap.toUpperCase()}'),
                    child: _buildHeaderKeyCap(
                      context,
                      theme,
                      colors,
                      keyCap.toUpperCase(),
                    ),
                  )
                : Stack(
                    key: ValueKey('header_icon_${keyCap}_$badgeCount'),
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: customChild ??
                            Icon(
                              icon,
                              size: iconMdSize,
                              color: colors.foreground,
                            ),
                      ),
                      if (badgeCount > 0)
                        Positioned(
                          top: -(gapUnit * 0.5),
                          right: -(gapUnit * 0.75),
                          child: DyCountBadge(
                            count: badgeCount,
                            isOverlay: true,
                          ),
                        )
                      else if (showDotBadge)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: SizedBox(
                            width: gapUnit * 0.75,
                            height: gapUnit * 0.75,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );

    final Widget button = customPadding != null
        ? shad.Button.ghost(
            focusNode: FocusNode(skipTraversal: true),
            style: const shad.ButtonStyle.ghost(
              size: shad.ButtonSize.normal,
              density: shad.ButtonDensity.icon,
            ).withPadding(padding: customPadding!),
            onPressed: onPressed,
            child: innerContent,
          )
        : shad.IconButton.ghost(
            focusNode: FocusNode(skipTraversal: true),
            size: shad.ButtonSize.normal,
            density: shad.ButtonDensity.icon,
            onPressed: onPressed,
            icon: innerContent,
          );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return shad.Tooltip(
        tooltip: (ctx) => shad.TooltipContainer(child: Text(tooltip!)),
        child: button,
      );
    }
    return button;
  }
}

Widget _buildHeaderKeyCap(
  BuildContext context,
  shad.ThemeData theme,
  shad.ColorScheme colors,
  String label, {
  Key? key,
}) {
  if (_isAndroidPlatform) return const SizedBox.shrink();

  final capExtent = theme.iconTheme.medium.size ?? 20.0;

  return shad.OutlinedContainer(
    key: key,
    width: capExtent,
    height: capExtent,
    theme: shad.OutlinedContainerTheme(
      backgroundColor: colors.mutedForeground,
      borderColor: colors.mutedForeground,
      borderWidth: 1.0,
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: EdgeInsets.zero,
    ),
    child: Center(
      child: Text(
        label,
        style: theme.typography.xSmall.merge(theme.typography.mono).copyWith(
              fontWeight: FontWeight.w700,
              height: 1.0,
              color: colors.primaryForeground,
            ),
      ),
    ),
  );
}

/// Mobile workspace shell framing the unified TopBar (leading drawer trigger,
/// page title, trailing Search/Notifications/Tasks actions), full-width region
/// `shad.TabList`, optional 2px progress bar, and active module canvas.
class DynamicMobileShell extends StatefulWidget {
  final String title;
  final Widget content;
  final VoidCallback onOpenDrawer;
  final GlobalKey? searchBtnKey;
  final VoidCallback? onSearchPressed;
  final GlobalKey? notifBtnKey;
  final VoidCallback? onNotificationsPressed;
  final int notificationCount;
  final GlobalKey? tasksBtnKey;
  final VoidCallback? onTasksPressed;
  final int taskCount;
  final bool isLoading;
  final double? progressValue;

  const DynamicMobileShell({
    super.key,
    required this.title,
    required this.content,
    required this.onOpenDrawer,
    this.searchBtnKey,
    this.onSearchPressed,
    this.notifBtnKey,
    this.onNotificationsPressed,
    this.notificationCount = 0,
    this.tasksBtnKey,
    this.onTasksPressed,
    this.taskCount = 0,
    this.isLoading = false,
    this.progressValue,
  });

  @override
  State<DynamicMobileShell> createState() => _DynamicMobileShellState();
}

class _DynamicMobileShellState extends State<DynamicMobileShell> {
  bool _childLoading = false;
  double? _childProgressValue;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final gapUnit = theme.density.baseGap * scaling;
    final padUnit = theme.density.baseContainerPadding * scaling;
    final isDark = colors.brightness == Brightness.dark;
    final showProgress = widget.isLoading || _childLoading;
    final activeProgressValue = widget.progressValue ?? _childProgressValue;

    final barHeight = (padUnit * shad.pad2xl) + (gapUnit * shad.gapXs);
    final iconMdSize = theme.iconTheme.medium.size ?? 20.0;
    final surfaceCanvasColor = DyColorSystem.resolveSurfaceCanvas(isDark);

    return NotificationListener<PageLoadingNotification>(
      onNotification: (notification) {
        setState(() {
          _childLoading = notification.isLoading;
          _childProgressValue = notification.progressValue;
        });
        return true;
      },
      child: ColoredBox(
        color: surfaceCanvasColor,
        child: ValueListenableBuilder<MobileTopBarConfig?>(
          valueListenable: ServiceMobileShell.instance.configNotifier,
          builder: (context, mobileConfig, _) {
            final isSubview = mobileConfig?.subviewTitle != null;
            final effectiveTitle =
                mobileConfig?.subviewTitle ?? widget.title;
            final showTabsInTopBar = mobileConfig != null &&
                mobileConfig.tabLabels.isNotEmpty &&
                !isSubview;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: barHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: gapUnit * shad.gapSm,
                    ),
                    child: Row(
                      children: [
                        if (isSubview && mobileConfig?.onBackFromSubview != null)
                          shad.IconButton.ghost(
                            focusNode: FocusNode(skipTraversal: true),
                            size: shad.ButtonSize.normal,
                            density: shad.ButtonDensity.icon,
                            icon: Icon(
                              shad.LucideIcons.arrowLeft,
                              size: iconMdSize,
                              color: colors.foreground,
                            ),
                            onPressed: mobileConfig!.onBackFromSubview,
                          )
                        else
                          shad.IconButton.ghost(
                            focusNode: FocusNode(skipTraversal: true),
                            size: shad.ButtonSize.normal,
                            density: shad.ButtonDensity.icon,
                            icon: Icon(
                              shad.LucideIcons.panelLeft,
                              size: iconMdSize,
                              color: colors.foreground,
                            ),
                            onPressed: widget.onOpenDrawer,
                          ),
                        const shad.DensityGap(shad.gapSm),
                        Expanded(
                          child: Text(
                            effectiveTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.semiBold
                                .merge(theme.typography.large)
                                .copyWith(color: colors.foreground),
                          ),
                        ),
                        if (mobileConfig?.onAddPressed != null &&
                            !isSubview) ...[
                          shad.IconButton.ghost(
                            focusNode: FocusNode(skipTraversal: true),
                            size: shad.ButtonSize.normal,
                            density: shad.ButtonDensity.icon,
                            icon: Icon(
                              shad.LucideIcons.plus,
                              size: iconMdSize,
                              color: colors.primary,
                            ),
                            onPressed: mobileConfig!.onAddPressed,
                          ),
                          const shad.DensityGap(shad.gapXs),
                        ],
                        DynamicHeaderActionButton(
                          key: widget.searchBtnKey,
                          icon: shad.LucideIcons.search,
                          tooltip: 'Search',
                          keyCap: 'K',
                          showKeyCaps: false,
                          onPressed: widget.onSearchPressed ?? () {},
                        ),
                        const shad.DensityGap(shad.gapXs),
                        DynamicHeaderActionButton(
                          key: widget.notifBtnKey,
                          icon: shad.LucideIcons.bell,
                          tooltip: 'Notifications',
                          keyCap: 'N',
                          showKeyCaps: false,
                          badgeCount: widget.notificationCount,
                          onPressed: widget.onNotificationsPressed ?? () {},
                        ),
                        const shad.DensityGap(shad.gapXs),
                        DynamicHeaderActionButton(
                          key: widget.tasksBtnKey,
                          icon: shad.LucideIcons.listTodo,
                          tooltip: 'Tasks & Approvals',
                          keyCap: 'T',
                          showKeyCaps: false,
                          badgeCount: widget.taskCount,
                          onPressed: widget.onTasksPressed ?? () {},
                        ),
                      ],
                    ),
                  ),
                ),
                if (showTabsInTopBar)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tabCount = mobileConfig.tabLabels.length;
                      final tabWidth = constraints.maxWidth / tabCount;
                      return shad.ComponentTheme<shad.FixedButtonTheme>(
                        data: shad.FixedButtonTheme(
                          padding: (context, states, defaultValue) =>
                              EdgeInsets.symmetric(
                            vertical: gapUnit * shad.gapSm,
                          ),
                        ),
                        child: shad.TabList(
                          index: mobileConfig.selectedTabIndex.clamp(
                            0,
                            tabCount - 1,
                          ),
                          onChanged: (idx) =>
                              mobileConfig.onTabChanged?.call(idx),
                          children: [
                            for (final label in mobileConfig.tabLabels)
                              shad.TabItem(
                                child: SizedBox(
                                  width: tabWidth,
                                  child: Center(
                                    child: Text(
                                      label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.typography.small.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  shad.Divider(color: colors.border, height: 1.0),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: padUnit * shad.padSm,
                          vertical: gapUnit * shad.gapSm,
                        ),
                        child: widget.content,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
