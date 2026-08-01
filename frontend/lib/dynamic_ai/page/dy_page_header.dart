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
    this.tabs = const ['Details', 'Reports', 'Tasks'],
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

/// [PageHeader] — Modular top page header with 3 operational modes
/// (`standard`, `adding`, `editing`), auto-configured action buttons, and back button support.
class PageHeader extends StatelessWidget {
  final String title;
  final PageHeaderMode mode;
  final String? moduleName;
  final String? docId;

  // Callbacks for adding/editing modes
  final VoidCallback? onBack;
  final VoidCallback? onDiscard;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onConfirm;
  final bool isSaving;

  final Widget? pageTabs;

  // Optional Trailing Actions (overrides auto-generated buttons if provided)
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.mode = PageHeaderMode.standard,
    this.moduleName,
    this.docId,
    this.pageTabs,
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
    } else if (mode == PageHeaderMode.editing) {
      titleText = docId ?? title;
    }

    final bool showBackButton =
        mode == PageHeaderMode.adding || mode == PageHeaderMode.editing || onBack != null;

    // Resolve Trailing Action Buttons
    List<Widget> resolvedActions = List.from(actions);
    if (resolvedActions.isEmpty) {
      if (mode == PageHeaderMode.adding) {
        resolvedActions = [
          shad.OutlineButton(
            onPressed: onDiscard ?? onBack,
            child: const Text('Discard'),
          ),
          shad.OutlineButton(
            onPressed: onSaveDraft,
            child: const Text('Save Draft'),
          ),
          shad.PrimaryButton(
            onPressed: isSaving ? null : onConfirm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: shad.CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(shad.LucideIcons.check),
                const shad.DensityGap(shad.gapSm),
                Text(isSaving ? 'Saving...' : 'Confirm'),
              ],
            ),
          ),
        ];
      } else if (mode == PageHeaderMode.editing) {
        resolvedActions = [
          shad.OutlineButton(
            onPressed: onDiscard ?? onBack,
            child: const Text('Discard'),
          ),
          shad.PrimaryButton(
            onPressed: isSaving ? null : onConfirm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: shad.CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(shad.LucideIcons.check),
                const shad.DensityGap(shad.gapSm),
                Text(isSaving ? 'Saving...' : 'Confirm'),
              ],
            ),
          ),
        ];
      }
    }

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Prepend Back Arrow for Adding / Editing modes or when onBack is provided
          if (showBackButton) ...[
            shad.IconButton.ghost(
              icon: const Icon(shad.LucideIcons.arrowLeft),
              onPressed: onBack ?? onDiscard,
            ),
            const shad.DensityGap(shad.gapSm),
          ],

          // Title Text
          Text(
            titleText,
            style: theme.typography.h2.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          // Optional Document ID Badge
          if (docId != null && mode == PageHeaderMode.standard) ...[
            const shad.DensityGap(shad.gapSm),
            shad.SecondaryBadge(
              child: Text(
                docId!,
                style: theme.typography.mono.copyWith(
                  fontSize: 12 * theme.scaling,
                ),
              ),
            ),
          ],

          // Optional Page Tabs (PageTabs) between Title/DocID and Spacer
          if (pageTabs != null) ...[
            const shad.DensityGap(shad.gapLg),
            pageTabs!,
          ],

          // Spacer (Pushes trailing actions to far right)
          const Spacer(),

          // Trailing Actions Row
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
    );
  }
}
