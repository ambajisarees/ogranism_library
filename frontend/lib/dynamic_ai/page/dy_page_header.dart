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

import 'package:flutter/material.dart' hide Tab;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../micro/dy_micro_button.dart';

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
            ? labels!.map((l) => PageSubpageItem(label: l, icon: _getIconForLabel(l))).toList()
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

/// [PageHeader] — Modular top page header with 3 operational modes
/// (`standard`, `adding`, `editing`), auto-configured action buttons, and back button support.
class PageHeader extends StatelessWidget {
  final String title;
  final PageHeaderMode mode;
  final String? moduleName;

  // Callbacks for adding/editing modes
  final VoidCallback? onBack;
  final VoidCallback? onDiscard;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onConfirm;
  final bool isSaving;

  final Widget? subpages;

  // Optional Trailing Actions (overrides auto-generated buttons if provided)
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.mode = PageHeaderMode.standard,
    this.moduleName,
    this.subpages,
    this.onBack,
    this.onDiscard,
    this.onSaveDraft,
    this.onConfirm,
    this.isSaving = false,
    this.actions = const [],
  }) : assert(actions.length <= 4, 'PageHeader can take at most 4 actions');

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    // Resolve Title
    String titleText = title;
    if (mode == PageHeaderMode.adding) {
      titleText = moduleName != null ? 'Add $moduleName' : 'Add $title';
    }

    final bool showBackButton = mode == PageHeaderMode.adding ||
        mode == PageHeaderMode.editing ||
        onBack != null;

    // Resolve Trailing Action Buttons
    List<Widget> resolvedActions = List.from(actions);
    if (resolvedActions.isEmpty) {
      if (mode == PageHeaderMode.adding) {
        resolvedActions = [
          shad.DestructiveButton(
            onPressed: onDiscard ?? onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.x, size: 16 * theme.scaling),
                const shad.DensityGap(shad.gapSm),
                const Text('Discard'),
              ],
            ),
          ),
          shad.OutlineButton(
            onPressed: onSaveDraft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.fileText, size: 16 * theme.scaling),
                const shad.DensityGap(shad.gapSm),
                const Text('Draft'),
              ],
            ),
          ),
          shad.PrimaryButton(
            onPressed: isSaving ? null : onConfirm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  SizedBox(
                    width: 14 * theme.scaling,
                    height: 14 * theme.scaling,
                    child: const shad.CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(shad.LucideIcons.check, size: 16 * theme.scaling),
                const shad.DensityGap(shad.gapSm),
                Text(isSaving ? 'Saving...' : 'Confirm'),
              ],
            ),
          ),
        ];
      } else if (mode == PageHeaderMode.editing) {
        resolvedActions = [
          shad.DestructiveButton(
            onPressed: onDiscard ?? onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.x, size: 16 * theme.scaling),
                const shad.DensityGap(shad.gapSm),
                const Text('Discard'),
              ],
            ),
          ),
          shad.PrimaryButton(
            onPressed: isSaving ? null : onConfirm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  SizedBox(
                    width: 14 * theme.scaling,
                    height: 14 * theme.scaling,
                    child: const shad.CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(shad.LucideIcons.check, size: 16 * theme.scaling),
                const shad.DensityGap(shad.gapSm),
                Text(isSaving ? 'Saving...' : 'Update'),
              ],
            ),
          ),
        ];
      }
    }

    return SizedBox(
      width: double.infinity,
      child: FocusTraversalGroup(
        policy: WidgetOrderTraversalPolicy(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Optional Back Button (IconButton.outline size normal)
            if (showBackButton) ...[
              shad.IconButton.outline(
                size: shad.ButtonSize.normal,
                icon: Icon(
                  shad.LucideIcons.arrowLeft,
                  size: 16 * theme.scaling,
                ),
                onPressed: onBack ?? onDiscard,
              ),
              const shad.DensityGap(shad.gapLg),
            ],

            // 2. Title Text
            Text(
              titleText,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.typography.h2.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),

            // 3. Optional Subpages ButtonGroup
            if (subpages != null) ...[
              const shad.DensityGap(shad.gapXl),
              subpages!,
            ],

            // 4. Spacer
            const Spacer(),

            // 5. Trailing Actions Row
            if (resolvedActions.isNotEmpty) ...[
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
        ),
      ),
    );
  }
}
