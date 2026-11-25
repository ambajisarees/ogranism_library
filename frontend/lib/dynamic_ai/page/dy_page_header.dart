/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC PAGE HEADER & CONTEXT TABS (dy_page_header.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Modular top page header with 3 operational modes (`standard`, `adding`, `editing`), 
     document ID badge, back button support, context page tabs (`PageTabs`), and 
     trailing actions.
   - Consolidates PageHeader and PageTabs micro widget in one page-level file.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses native `shadcn_flutter` typography tokens (`theme.typography.h2`, `theme.typography.mono`).
   - `PageTabs`: Context tab switcher row (36px height) with badge count support.
   - At most 4 trailing actions supported (`actions.length <= 4`).
================================================================================
*/

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart' hide Tab;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../services/service_header_toast.dart';
import '../micro/dy_micro_button.dart';
import '../specs/dy_color_system.dart';

bool get _isAndroidPlatform => defaultTargetPlatform == TargetPlatform.android;

/// Operational mode for [PageHeader]
enum PageHeaderMode { standard, adding, editing }

/// [PageTabs] — Zero-padding context tab switcher row for page-level navigation.
class PageTabs extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;
  final Map<int, int>? badgeCounts;

  const PageTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.tabs = const ['Dash', 'Details', 'Reports', 'Tasks'],
    this.badgeCounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.ComponentTheme<shad.TabsTheme>(
      data: shad.TabsTheme(
        containerPadding: EdgeInsets.all(6 * theme.scaling),
      ),
      child: shad.Tabs(
        index: selectedIndex,
        onChanged: onTabChanged,
        children: List.generate(tabs.length, (index) {
          final label = tabs[index];
          final count = badgeCounts?[index];
          final isTasks = label.toLowerCase() == 'tasks';

          return shad.TabItem(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (count != null && count > 0) ...[
                  const shad.DensityGap(shad.gapXs),
                  shad.PrimaryBadge(
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ] else if (isTasks) ...[
                  const shad.DensityGap(shad.gapXs),
                  Container(
                    width: 6 * theme.scaling,
                    height: 6 * theme.scaling,
                    decoration: BoxDecoration(
                      color: colors.destructive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Data specification for a subpage item in [PageSubpages].
class PageSubpageItem {
  final String label;
  final IconData? icon;

  const PageSubpageItem({
    required this.label,
    this.icon,
  });
}

/// [PageSubpages] — ButtonGroup of Icon + Label subpage switcher buttons matching trailing header button tokens.
class PageSubpages extends StatelessWidget {
  final int selectedIndex;
  final List<PageSubpageItem>? items;
  final List<String>? labels;
  final ValueChanged<int> onSubpageChanged;

  const PageSubpages({
    super.key,
    required this.selectedIndex,
    required this.onSubpageChanged,
    this.items,
    this.labels,
  });

  static const List<PageSubpageItem> defaultItems = [
    PageSubpageItem(label: 'Dash', icon: shad.LucideIcons.layoutDashboard),
    PageSubpageItem(label: 'Details', icon: shad.LucideIcons.fileText),
    PageSubpageItem(label: 'Reports', icon: shad.LucideIcons.fileSpreadsheet),
    PageSubpageItem(label: 'Tasks', icon: shad.LucideIcons.squareCheck),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final effectiveItems = items ??
        (labels != null
            ? labels!
                .map(
                    (l) => PageSubpageItem(label: l, icon: _getIconForLabel(l)))
                .toList()
            : defaultItems);

    return SizedBox(
      height: 36 * theme.scaling,
      child: shad.ButtonGroup(
        children: List.generate(effectiveItems.length, (index) {
          final item = effectiveItems[index];
          final isSelected = index == selectedIndex;

          if (isSelected) {
            final childRow = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 16 * theme.scaling,
                    color: colors.primaryForeground,
                  ),
                  SizedBox(width: 6 * theme.scaling),
                ],
                Text(
                  item.label,
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primaryForeground,
                  ),
                ),
              ],
            );

            return shad.PrimaryButton(
              size: shad.ButtonSize.normal,
              onPressed: () => onSubpageChanged(index),
              child: childRow,
            );
          }

          return MicroButton(
            label: item.label,
            leadingIcon: item.icon,
            isSelected: false,
            padding: EdgeInsets.symmetric(horizontal: 16 * theme.scaling),
            onPressed: () => onSubpageChanged(index),
          );
        }),
      ),
    );
  }

  static IconData? _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'dash':
      case 'dashboard':
        return shad.LucideIcons.layoutDashboard;
      case 'details':
        return shad.LucideIcons.fileText;
      case 'reports':
        return shad.LucideIcons.fileSpreadsheet;
      case 'tasks':
        return shad.LucideIcons.squareCheck;
      default:
        return null;
    }
  }
}

/// Standardized page header action button with `[Leading Icon] + [Label] +
/// [Permanent Trailing KeyCap]` matching Left Rail KeyCap design tokens.
class PageHeaderActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? keyCap;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PageHeaderActionButton({
    super.key,
    required this.label,
    this.icon,
    this.keyCap,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final showCap =
        !_isAndroidPlatform && keyCap != null && keyCap!.trim().isNotEmpty;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 14 * scaling,
            height: 14 * scaling,
            child: const shad.CircularProgressIndicator(strokeWidth: 2),
          )
        else if (icon != null)
          Icon(icon, size: theme.iconTheme.small.size ?? 16.0),
        if (isLoading || icon != null) const shad.DensityGap(shad.gapSm),
        Text(label),
        if (showCap) ...[
          const shad.DensityGap(shad.gapSm),
          _PageHeaderKeyCap(
            label: keyCap!.trim(),
            inverted: isPrimary,
            isDestructive: isDestructive,
          ),
        ],
      ],
    );

    if (isPrimary) {
      return shad.PrimaryButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      );
    }
    if (isDestructive) {
      return shad.DestructiveButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      );
    }
    return shad.OutlineButton(
      onPressed: isLoading ? null : onPressed,
      child: content,
    );
  }
}

/// [PageHeader] — Modular top page header with 3 operational modes
/// (`standard`, `adding`, `editing`), interactive `>` breadcrumb trail,
/// permanent center desktop toast slot, and trailing keycap action buttons.
class PageHeader extends StatelessWidget {
  final String title;
  final PageHeaderMode mode;
  final String? moduleName;

  // Callbacks for adding/editing & default standard actions
  final VoidCallback? onBack;
  final VoidCallback? onDiscard;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onConfirm;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;
  final VoidCallback? onAdd;
  final bool showDefaultStandardActions;
  final bool isSaving;

  final Widget? subpages;
  final String? breadcrumbSubtitle;
  final VoidCallback? onBreadcrumbRootTap;

  // Optional Trailing Actions (overrides auto-generated buttons if provided)
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.mode = PageHeaderMode.standard,
    this.moduleName,
    this.subpages,
    this.breadcrumbSubtitle,
    this.onBreadcrumbRootTap,
    this.onBack,
    this.onDiscard,
    this.onSaveDraft,
    this.onConfirm,
    this.onPrint,
    this.onExport,
    this.onAdd,
    this.showDefaultStandardActions = false,
    this.isSaving = false,
    this.actions = const [],
  }) : assert(actions.length <= 4, 'PageHeader can take at most 4 actions');

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // Resolve Title
    String titleText = title;
    if (mode == PageHeaderMode.adding) {
      titleText = moduleName != null ? 'Add $moduleName' : 'Add $title';
    } else if (mode == PageHeaderMode.editing) {
      titleText = moduleName != null ? 'Edit $moduleName' : 'Edit $title';
    }

    final hasBreadcrumb = mode == PageHeaderMode.standard &&
        breadcrumbSubtitle != null &&
        breadcrumbSubtitle!.trim().isNotEmpty;

    final bool showBackButton = mode == PageHeaderMode.adding ||
        mode == PageHeaderMode.editing ||
        onBack != null ||
        hasBreadcrumb;

    // Resolve Trailing Action Buttons
    List<Widget> resolvedActions = [];
    if (mode == PageHeaderMode.adding) {
      resolvedActions = actions.isNotEmpty
          ? List.from(actions)
          : [
              PageHeaderActionButton(
                label: 'Discard',
                icon: shad.LucideIcons.x,
                keyCap: 'Esc',
                isDestructive: true,
                onPressed: onDiscard ?? onBack,
              ),
              PageHeaderActionButton(
                label: 'Draft',
                icon: shad.LucideIcons.fileText,
                keyCap: 'D',
                onPressed: onSaveDraft,
              ),
              PageHeaderActionButton(
                label: isSaving ? 'Saving...' : 'Confirm',
                icon: shad.LucideIcons.check,
                keyCap: 'S',
                isPrimary: true,
                isLoading: isSaving,
                onPressed: onConfirm,
              ),
            ];
    } else if (mode == PageHeaderMode.editing) {
      resolvedActions = actions.isNotEmpty
          ? List.from(actions)
          : [
              PageHeaderActionButton(
                label: 'Discard',
                icon: shad.LucideIcons.x,
                keyCap: 'Esc',
                isDestructive: true,
                onPressed: onDiscard ?? onBack,
              ),
              PageHeaderActionButton(
                label: isSaving ? 'Saving...' : 'Update',
                icon: shad.LucideIcons.check,
                keyCap: 'S',
                isPrimary: true,
                isLoading: isSaving,
                onPressed: onConfirm,
              ),
            ];
    } else if (showDefaultStandardActions ||
        onPrint != null ||
        onExport != null ||
        onAdd != null) {
      resolvedActions = [
        ...actions,
        PageHeaderActionButton(
          label: 'Print',
          icon: shad.LucideIcons.printer,
          keyCap: 'P',
          onPressed: onPrint,
        ),
        PageHeaderActionButton(
          label: 'Export',
          icon: shad.LucideIcons.download,
          keyCap: 'X',
          onPressed: onExport,
        ),
        PageHeaderActionButton(
          label: 'Add',
          icon: shad.LucideIcons.plus,
          keyCap: 'N',
          isPrimary: true,
          onPressed: onAdd,
        ),
      ];
    } else {
      resolvedActions = List.from(actions);
    }

    final Widget titleOrBreadcrumb = hasBreadcrumb
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              shad.Button.ghost(
                style: const shad.ButtonStyle.ghost().copyWith(
                  padding: (ctx, state, pad) => EdgeInsets.symmetric(
                    horizontal:
                        theme.density.baseGap * theme.scaling * shad.gapXs,
                    vertical: 2 * theme.scaling,
                  ),
                ),
                onPressed: onBreadcrumbRootTap ?? onBack,
                child: Text(
                  titleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.h2.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      theme.density.baseGap * theme.scaling * shad.gapXs,
                ),
                child: Text(
                  '>',
                  style: theme.typography.h2.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  breadcrumbSubtitle!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.typography.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: colors.foreground,
                  ),
                ),
              ),
            ],
          )
        : Text(
            titleText,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.typography.h2.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          );

    return SizedBox(
      width: double.infinity,
      child: FocusTraversalGroup(
        policy: WidgetOrderTraversalPolicy(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720 * theme.scaling;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (showBackButton) ...[
                        shad.IconButton.outline(
                          size: shad.ButtonSize.normal,
                          icon: Icon(
                            shad.LucideIcons.arrowLeft,
                            size: theme.iconTheme.small.size ?? 16.0,
                          ),
                          onPressed: onBack ?? onBreadcrumbRootTap ?? onDiscard,
                        ),
                        const shad.DensityGap(shad.gapSm),
                      ],
                      Expanded(child: titleOrBreadcrumb),
                    ],
                  ),
                  if (subpages != null || resolvedActions.isNotEmpty) ...[
                    const shad.DensityGap(shad.gapSm),
                    Wrap(
                      spacing: 8 * theme.scaling,
                      runSpacing: 8 * theme.scaling,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (subpages != null) subpages!,
                        ...resolvedActions,
                      ],
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Optional Back Button (IconButton.outline size normal)
                if (showBackButton) ...[
                  shad.IconButton.outline(
                    size: shad.ButtonSize.normal,
                    icon: Icon(
                      shad.LucideIcons.arrowLeft,
                      size: theme.iconTheme.small.size ?? 16.0,
                    ),
                    onPressed: onBack ?? onBreadcrumbRootTap ?? onDiscard,
                  ),
                  const shad.DensityGap(shad.gapLg),
                ],

                // 2. Title Text / Interactive Breadcrumb + Optional Subpages + Permanent Center Toast Zone
                Expanded(
                  child: Row(
                    children: [
                      Flexible(child: titleOrBreadcrumb),
                      if (subpages != null) ...[
                        const shad.DensityGap(shad.gapXl),
                        subpages!,
                      ],
                      const shad.DensityGap(shad.gapMd),
                      const Expanded(
                        child: Center(
                          child: _DesktopHeaderToastZone(),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Trailing Actions Row
                if (resolvedActions.isNotEmpty) ...[
                  const shad.DensityGap(shad.gapMd),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: resolvedActions.map((act) {
                      return Padding(
                        padding: EdgeInsets.only(left: 8 * theme.scaling),
                        child: act,
                      );
                    }).toList(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PageHeaderKeyCap extends StatelessWidget {
  final String label;
  final bool inverted;
  final bool isDestructive;

  const _PageHeaderKeyCap({
    required this.label,
    this.inverted = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final height = 18 * scaling;
    final minWidth = 18 * scaling;
    final bgColor = isDestructive
        ? shad.Colors.white
        : (inverted ? colors.primaryForeground : colors.mutedForeground);
    final textColor = isDestructive
        ? colors.destructive
        : (inverted ? colors.primary : colors.primaryForeground);

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      descendantsAreFocusable: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          minHeight: height,
          maxHeight: height,
        ),
        child: shad.OutlinedContainer(
          backgroundColor: bgColor,
          borderColor: bgColor,
          borderWidth: 1.0,
          borderRadius: BorderRadius.circular(theme.radiusSm),
          padding: EdgeInsets.symmetric(
            horizontal: label.length > 1 ? 5 * scaling : 4 * scaling,
          ),
          child: Center(
            widthFactor: 1.0,
            child: Text(
              label,
              style: theme.typography.xSmall.merge(theme.typography.mono).copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: textColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopHeaderToastZone extends StatelessWidget {
  const _DesktopHeaderToastZone();

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<HeaderToastMessage?>(
      valueListenable: ServiceHeaderToast.instance.activeToastNotifier,
      builder: (context, toast, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: toast == null
              ? const SizedBox.shrink(key: ValueKey('toast_empty'))
              : _buildToastPill(theme, colors, scaling, isDark, toast),
        );
      },
    );
  }

  Widget _buildToastPill(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scaling,
    bool isDark,
    HeaderToastMessage toast,
  ) {
    final Color accent;
    final IconData icon;
    switch (toast.tone) {
      case HeaderToastTone.success:
        accent = DyColorSystem.emerald500;
        icon = shad.LucideIcons.circleCheck;
      case HeaderToastTone.warning:
        accent = DyColorSystem.orange500;
        icon = shad.LucideIcons.triangleAlert;
      case HeaderToastTone.error:
        accent = DyColorSystem.red500;
        icon = shad.LucideIcons.circleAlert;
      case HeaderToastTone.info:
        accent = DyColorSystem.cyan500;
        icon = shad.LucideIcons.info;
    }

    return ConstrainedBox(
      key: ValueKey<int>(toast.id),
      constraints: BoxConstraints(
        maxWidth: 420 * scaling,
        minHeight: 36 * scaling,
        maxHeight: 36 * scaling,
      ),
      child: shad.OutlinedContainer(
        backgroundColor: DyColorSystem.resolveSurface(accent, isDark),
        borderColor: DyColorSystem.resolveBorder(accent, isDark),
        borderWidth: 1.0,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scaling,
          vertical: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: theme.iconTheme.small.size ?? 16.0, color: accent),
            const shad.DensityGap(shad.gapSm),
            Flexible(
              child: Text(
                toast.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.small
                    .merge(theme.typography.medium)
                    .copyWith(color: colors.foreground),
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            shad.IconButton.ghost(
              focusNode: FocusNode(skipTraversal: true),
              size: shad.ButtonSize.small,
              density: shad.ButtonDensity.iconDense,
              icon: Icon(
                shad.LucideIcons.x,
                size: theme.iconTheme.xSmall.size ?? 12.0,
                color: colors.mutedForeground,
              ),
              onPressed: ServiceHeaderToast.instance.clear,
            ),
          ],
        ),
      ),
    );
  }
}
