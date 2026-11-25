/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC ACTION BAR (dy_action_bar.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - High-density 36px toolbar component enforcing unified DAB layout:
     `[Region Title] -> [Leading Actions] -> [Trailing Actions] -> [Optional 3-Dots] -> [Mandatory Expand]`.
   - Modes: [DabMode.details] (landing pages) & [DabMode.form] (add/edit pages).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Built strictly with native `shadcn_flutter` `OutlineButton` / `SelectedButton`
     / `ButtonGroup` inheriting global `OutlineButtonTheme` (`36px` height, `colors.background`
     -> `colors.accent`, `1px colors.border`, `theme.radiusMd`) and `DyCountBadge`.
   - Data DAB:
     * Title -> Submodule -> ButtonGroup View Switcher -> AutoComplete -> Filters -> Sort -> Group -> Clear
     * Trailing Actions: Search Input (`36px`)
     * Trailing Controls: Optional 3-Dots + Mandatory Expand Button (`[2]`)
   - Non-Data DABs (Metrics / Tasks / Reports):
     * Title -> Leading Actions (e.g., Expanded Tasks ButtonGroup) -> Trailing Actions (Horizon/Lens ButtonGroup or Menu + Search) -> Optional 3-Dots -> Mandatory Expand Button.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Supports backwards-compatible custom filter labels/icons (`millFilterLabel`,
     `fabricFilterLabel`, `statusOptions`) across Pipeline & Sales modules.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None currently; 100% backwards-compatible across all pipeline & sales modules.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../micro/dy_count_badge.dart';
import '../micro/dab/dab_date_pop.dart';
import '../micro/dab/dab_group_popover.dart';
import '../micro/dab/dab_group_switcher.dart';
import '../micro/dab/dab_region_header.dart';
import '../micro/dab/dab_select_pop.dart';
import '../micro/dab/dab_sort_popover.dart';
import '../specs/dy_grid_system.dart';

export '../micro/dab/dab_region_header.dart';

/// Explicit modes for [DynamicActionBar].
enum DabMode {
  /// Standard page landing mode (Submodule -> View Switcher -> Filters -> Sort -> Group -> Spacer -> Search -> 3-Dots).
  details,

  /// Form entry mode (View Switcher -> AutoComplete / Filters -> Group -> Spacer -> Search -> 3-Dots).
  form,
}

/// Legacy option model for popovers.
class DynamicActionOption {
  final String label;
  final Widget? icon;
  final String value;

  const DynamicActionOption({
    required this.label,
    this.icon,
    required this.value,
  });
}

/// Data model for filter button cards in DAB.
class DabFilterItem {
  final String id;
  final String label;
  final IconData? icon;
  final int count;

  const DabFilterItem({
    required this.id,
    required this.label,
    this.icon,
    this.count = 0,
  });
}

/// [DynamicActionBar] — Unified High-Density 34px 4-Region Action & Filter Bar.
class DynamicActionBar extends StatelessWidget {
  final DabMode mode;
  final String entityName;

  // Unified 4-Region & Expansion State Props
  final DabRegion region;
  final String? regionTitle;
  final int? regionNumber;
  final bool showRegionHeader;
  final bool showOverflowButton;
  final bool showExpandButton;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final DabTimeHorizon selectedHorizon;
  final ValueChanged<DabTimeHorizon>? onHorizonChanged;
  final List<String> taskQueueLabels;
  final int selectedTaskQueueIndex;
  final ValueChanged<int>? onTaskQueueChanged;
  final List<String> reportLensLabels;
  final int selectedReportLensIndex;
  final ValueChanged<int>? onReportLensChanged;

  // View Switcher Props
  final String selectedView;
  final ValueChanged<String>? onViewChanged;
  final List<String> supportedViewModes;

  // Submodule Selector
  final Widget? submoduleWidget;

  // AutoCompletes & Form Widgets
  final Widget? autoCompleteWidget;
  final Widget? millAutoComplete;
  final Widget? qualityAutoComplete;
  final List<Widget>? customMiddleWidgets;

  // Group Switcher & Popover
  final String selectedGroup;
  final ValueChanged<String>? onGroupChanged;
  final List<DabGroupOption> groupOptions;
  final Widget? groupingSwitcher;
  final List<String> groupLevels;
  final ValueChanged<List<String>>? onGroupLevelsChanged;

  // Search Input Props
  final bool showSearch;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final double? searchWidth;

  // Context Filters
  final bool showFilterButtons;
  final String partyFilterLabel;
  final IconData partyFilterIcon;
  final Set<String> selectedMills;
  final List<String> millOptions;
  final ValueChanged<Set<String>>? onMillChanged;
  final String millFilterLabel;
  final IconData millFilterIcon;
  final Set<String> selectedFabrics;
  final List<String> fabricOptions;
  final ValueChanged<Set<String>>? onFabricChanged;
  final String fabricFilterLabel;
  final IconData fabricFilterIcon;
  final Set<String> selectedParties;
  final List<String> partyOptions;
  final ValueChanged<Set<String>>? onPartyChanged;
  final Set<String> selectedStatuses;
  final List<String> statusOptions;
  final ValueChanged<Set<String>>? onStatusChanged;
  final VoidCallback? onOverflowFilterPressed;

  // Date Filter Props
  final bool showDateFilter;
  final bool showRangeFilter;
  final shad.CalendarValue? selectedDateRange;
  final String? selectedDateLabel;
  final ValueChanged<shad.CalendarValue?>? onDateRangeSelected;

  // Filter Clear & Sorting Props
  final bool hasActiveFilters;
  final VoidCallback? onClearAllFilters;
  final bool showSort;
  final String? selectedSortLabel;
  final String? selectedSortField;
  final bool isSortAscending;
  final List<DabSortOption>? sortOptions;
  final ValueChanged<String>? onSortFieldChanged;
  final VoidCallback? onToggleSortDirection;
  final VoidCallback? onSortPressed;

  const DynamicActionBar({
    super.key,
    this.mode = DabMode.details,
    this.entityName = 'Cards',
    this.region = DabRegion.data,
    this.regionTitle,
    this.regionNumber,
    this.showRegionHeader = true,
    this.showOverflowButton = true,
    this.showExpandButton = true,
    this.isExpanded = false,
    this.onToggleExpand,
    this.selectedHorizon = DabTimeHorizon.thisYear,
    this.onHorizonChanged,
    this.taskQueueLabels = const ['All', 'Overdue', 'Today'],
    this.selectedTaskQueueIndex = 0,
    this.onTaskQueueChanged,
    this.reportLensLabels = const ['By Mill', 'By Party', 'By Quality', 'Ageing'],
    this.selectedReportLensIndex = 0,
    this.onReportLensChanged,
    this.selectedView = 'table',
    this.onViewChanged,
    this.supportedViewModes = const ['table', 'list', 'cards', 'board'],
    this.submoduleWidget,
    this.autoCompleteWidget,
    this.millAutoComplete,
    this.qualityAutoComplete,
    this.customMiddleWidgets,
    this.selectedGroup = 'none',
    this.onGroupChanged,
    this.groupOptions = kDefaultGroupOptions,
    this.groupingSwitcher,
    this.groupLevels = const [],
    this.onGroupLevelsChanged,
    this.showSearch = true,
    this.searchQuery,
    this.onSearchChanged,
    this.searchWidth,
    this.showFilterButtons = true,
    this.partyFilterLabel = 'Party',
    this.partyFilterIcon = shad.LucideIcons.users,
    this.selectedMills = const {},
    this.millOptions = const [],
    this.onMillChanged,
    this.millFilterLabel = 'Mill',
    this.millFilterIcon = shad.LucideIcons.warehouse,
    Set<String>? selectedFabrics,
    List<String>? fabricOptions,
    ValueChanged<Set<String>>? onFabricChanged,
    Set<String>? selectedQualities,
    List<String>? qualityOptions,
    ValueChanged<Set<String>>? onQualityChanged,
    this.fabricFilterLabel = 'Fabric',
    this.fabricFilterIcon = shad.LucideIcons.shirt,
    this.selectedParties = const {},
    this.partyOptions = const [],
    this.onPartyChanged,
    this.selectedStatuses = const {},
    this.statusOptions = const ['Pending', 'Completed'],
    this.onStatusChanged,
    this.onOverflowFilterPressed,
    this.showDateFilter = true,
    this.showRangeFilter = false,
    this.selectedDateRange,
    this.selectedDateLabel,
    this.onDateRangeSelected,
    this.hasActiveFilters = false,
    this.onClearAllFilters,
    this.showSort = false,
    this.selectedSortLabel,
    this.selectedSortField,
    this.isSortAscending = true,
    this.sortOptions,
    this.onSortFieldChanged,
    this.onToggleSortDirection,
    this.onSortPressed,
  })  : selectedFabrics = selectedFabrics ?? selectedQualities ?? const {},
        fabricOptions = fabricOptions ?? qualityOptions ?? const [],
        onFabricChanged = onFabricChanged ?? onQualityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final bool isMobile =
        MediaQuery.sizeOf(context).width < DyGridSystem.breakpointMobile;

    if (isMobile) {
      return _buildMobileActionOnlyBar(context, theme, colors);
    }

    if (region != DabRegion.data) {
      return _buildCompactOrExpandedNonDataBar(context, theme, colors);
    }

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 36 * theme.scaling),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==========================================
            // LEADING EXPAND CONTROL (Data DAB)
            // ==========================================
            if (showExpandButton && onToggleExpand != null) ...[
              DabRegionLeading(
                region: DabRegion.data,
                regionNumberOverride: regionNumber,
                isExpanded: isExpanded,
                onToggleExpand: onToggleExpand,
              ),
              const shad.DensityGap(shad.gapSm),
            ],
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Submodule Selector (Optional)
                    if (submoduleWidget != null) ...[
                      submoduleWidget!,
                      const shad.DensityGap(shad.gapSm),
                    ],

                  // 2. View Mode Switcher Button Group (Compulsory 4 view modes)
                  if (supportedViewModes.isNotEmpty) ...[
                    _buildViewSwitcherGroup(context, theme, colors),
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // 3. AutoComplete / Single Select Widget (Optional)
                  if (autoCompleteWidget != null) ...[
                    autoCompleteWidget!,
                    const shad.DensityGap(shad.gapSm),
                  ],
                  if (millAutoComplete != null) ...[
                    millAutoComplete!,
                    const shad.DensityGap(shad.gapSm),
                  ],
                  if (qualityAutoComplete != null) ...[
                    qualityAutoComplete!,
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // 4. Custom Middle Widgets (Optional e.g. Draft Badge)
                  if (customMiddleWidgets != null)
                    for (final widget in customMiddleWidgets!) ...[
                      widget,
                      const shad.DensityGap(shad.gapSm),
                    ],

                  // 5. Context Filter Outline Buttons (Party, Mill/Broker, Fabric/Transport, Status)
                  if (showFilterButtons) ...[
                    // Party Filter
                    if (onPartyChanged != null || partyOptions.isNotEmpty) ...[
                      Builder(
                        builder: (btnContext) => _buildDabOutlineButton(
                          theme: theme,
                          colors: colors,
                          leadingIcon: partyFilterIcon,
                          label: partyFilterLabel,
                          badgeCount: selectedParties.length,
                          showZeroBadge: true,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedParties.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                              ),
                              builder: (context) => DabSelectPopover(
                                title: partyFilterLabel,
                                options: partyOptions,
                                selectedValues: selectedParties,
                                onChanged: (set) => onPartyChanged?.call(set),
                              ),
                            );
                          },
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                    ],

                    // Mill / Secondary Entity Filter
                    if (onMillChanged != null || millOptions.isNotEmpty) ...[
                      Builder(
                        builder: (btnContext) => _buildDabOutlineButton(
                          theme: theme,
                          colors: colors,
                          leadingIcon: millFilterIcon,
                          label: millFilterLabel,
                          badgeCount: selectedMills.length,
                          showZeroBadge: true,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedMills.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                              ),
                              builder: (context) => DabSelectPopover(
                                title: millFilterLabel,
                                options: millOptions,
                                selectedValues: selectedMills,
                                onChanged: (set) => onMillChanged?.call(set),
                              ),
                            );
                          },
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                    ],

                    // Fabric / Tertiary Entity Filter
                    if (onFabricChanged != null || fabricOptions.isNotEmpty) ...[
                      Builder(
                        builder: (btnContext) => _buildDabOutlineButton(
                          theme: theme,
                          colors: colors,
                          leadingIcon: fabricFilterIcon,
                          label: fabricFilterLabel,
                          badgeCount: selectedFabrics.length,
                          showZeroBadge: true,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedFabrics.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                              ),
                              builder: (context) => DabSelectPopover(
                                title: fabricFilterLabel,
                                options: fabricOptions,
                                selectedValues: selectedFabrics,
                                onChanged: (set) => onFabricChanged?.call(set),
                              ),
                            );
                          },
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                    ],

                    // Status Filter
                    if (onStatusChanged != null) ...[
                      Builder(
                        builder: (btnContext) => _buildDabOutlineButton(
                          theme: theme,
                          colors: colors,
                          leadingIcon: shad.LucideIcons.circleDot,
                          label: 'Status',
                          badgeCount: selectedStatuses.length,
                          showZeroBadge: true,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedStatuses.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                              ),
                              builder: (context) => DabSelectPopover(
                                title: 'Status',
                                options: statusOptions,
                                selectedValues: selectedStatuses,
                                onChanged: (set) => onStatusChanged?.call(set),
                              ),
                            );
                          },
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                    ],
                  ],

                  // Date Filter
                  if (showDateFilter && onDateRangeSelected != null) ...[
                    Builder(
                      builder: (btnContext) => _buildDabOutlineButton(
                        theme: theme,
                        colors: colors,
                        leadingIcon: shad.LucideIcons.calendar,
                        label: selectedDateLabel ?? 'Date',
                        badgeCount: selectedDateRange != null ? 1 : null,
                        trailingIcon: shad.LucideIcons.chevronDown,
                        isSelected: selectedDateRange != null,
                        onPressed: () {
                          shad.showOverlay(
                            btnContext,
                            shad.PopoverConfiguration(
                              anchorAlignment: Alignment.bottomLeft,
                              alignment: Alignment.topLeft,
                              offset: const Offset(0, 4),
                            ),
                            builder: (context) => DabDatePopover(
                              selectedRange: selectedDateRange,
                              onRangeSelected: (range) => onDateRangeSelected?.call(range),
                              onClose: () => shad.closeOverlay(context),
                            ),
                          );
                        },
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // 6. Non-Table Sort Button (Compulsory for list, cards, board)
                  if (selectedView != 'table' && (onSortFieldChanged != null || sortOptions != null)) ...[
                    Builder(
                      builder: (btnContext) {
                        final activeOpt = sortOptions?.firstWhere(
                          (o) => o.id == selectedSortField,
                          orElse: () => DabSortOption(id: selectedSortField ?? 'date', label: 'Sort'),
                        );
                        final activeLabel = activeOpt?.label ?? 'Sort';

                        return _buildDabOutlineButton(
                          theme: theme,
                          colors: colors,
                          leadingIcon: shad.LucideIcons.arrowUpDown,
                          label: 'Sort: $activeLabel',
                          trailingIcon: isSortAscending ? shad.LucideIcons.arrowUp : shad.LucideIcons.arrowDown,
                          isSelected: selectedSortField != null,
                          onPressed: () {
                            shad.showDropdown<void>(
                              context: btnContext,
                              anchorAlignment: Alignment.bottomLeft,
                              alignment: Alignment.topLeft,
                              offset: Offset(0, 4 * theme.scaling),
                              builder: (_) => DabSortPopover(
                                selectedId: selectedSortField ?? 'date',
                                isAscending: isSortAscending,
                                options: sortOptions ?? _defaultSortOptions,
                                onSelected: (id) =>
                                    onSortFieldChanged?.call(id),
                                onToggleDirection: () =>
                                    onToggleSortDirection?.call(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // 7. Group Popover Button (1 to 4 levels)
                  if (onGroupLevelsChanged != null) ...[
                    Builder(
                      builder: (btnContext) => _buildDabOutlineButton(
                        theme: theme,
                        colors: colors,
                        leadingIcon: shad.LucideIcons.layers,
                        label: 'Group',
                        badgeCount: groupLevels.isNotEmpty ? groupLevels.length : null,
                        isSelected: groupLevels.isNotEmpty,
                        onPressed: () {
                          shad.showOverlay(
                            btnContext,
                            shad.PopoverConfiguration(
                              anchorAlignment: Alignment.bottomLeft,
                              alignment: Alignment.topLeft,
                              offset: const Offset(0, 4),
                            ),
                            builder: (popContext) => DabGroupPopover(
                              initialLevels: groupLevels,
                              onApply: (levels) => onGroupLevelsChanged?.call(levels),
                              onClose: () => shad.closeOverlay(popContext),
                            ),
                          );
                        },
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // 8. Group Switcher Button Group (Optional Anchor)
                  if (onGroupChanged != null || groupingSwitcher != null) ...[
                    groupingSwitcher ??
                        DabGroupSwitcher(
                          selectedGroup: selectedGroup,
                          onGroupChanged: (g) => onGroupChanged?.call(g),
                          groups: groupOptions,
                        ),
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // Clear All Action Button
                  if (hasActiveFilters) ...[
                    _buildDabIconOutlineButton(
                      theme: theme,
                      colors: colors,
                      icon: shad.LucideIcons.x,
                      onPressed: onClearAllFilters,
                    ),
                    const shad.DensityGap(shad.gapSm),
                  ],
                ],
              ),
            ),
          ),

          // ==========================================
          // CONSISTENT END OF DAB (Search + Optional 3-Dots)
          // ==========================================
          if (showSearch) ...[
            const shad.DensityGap(shad.gapSm),
            _buildSearchInput(theme, colors),
          ],

          if (showOverflowButton) ...[
            const shad.DensityGap(shad.gapSm),
            DabRegionTrailingActions(
              showOverflowButton: showOverflowButton,
              onOverflowPressed: onOverflowFilterPressed,
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildSearchInput(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    bool fillWidth = false,
  }) {
    final textField = shad.TextField(
      placeholder: Text('Search $entityName...'),
      onChanged: onSearchChanged,
      features: const [
        shad.InputFeature.leading(
          Icon(shad.LucideIcons.search),
        ),
      ],
    );
    if (fillWidth) return textField;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: searchWidth ?? 220 * theme.scaling,
      ),
      child: textField,
    );
  }

  Widget _buildMobileActionOnlyBar(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final Widget leadingAction;
    switch (region) {
      case DabRegion.metrics:
        leadingAction = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DabTimeHorizonTabs(
            selectedHorizon: selectedHorizon,
            onHorizonChanged: onHorizonChanged,
          ),
        );
      case DabRegion.data:
        leadingAction = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildSearchInput(theme, colors, fillWidth: true),
            ),
            if (hasActiveFilters && onClearAllFilters != null) ...[
              const shad.DensityGap(shad.gapSm),
              _buildDabOutlineButton(
                theme: theme,
                colors: colors,
                label: 'Clear',
                leadingIcon: shad.LucideIcons.x,
                onPressed: onClearAllFilters,
              ),
            ],
          ],
        );
      case DabRegion.tasks:
        leadingAction = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DabCompactTabs(
            labels: taskQueueLabels,
            selectedIndex: selectedTaskQueueIndex,
            onChanged: onTaskQueueChanged,
          ),
        );
      case DabRegion.reports:
        leadingAction = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DabCompactTabs(
            labels: reportLensLabels,
            selectedIndex: selectedReportLensIndex,
            onChanged: onReportLensChanged,
          ),
        );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 36 * theme.scaling),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: leadingAction),
          if (showOverflowButton) ...[
            const shad.DensityGap(shad.gapSm),
            DabRegionTrailingActions(
              showOverflowButton: showOverflowButton,
              onOverflowPressed: onOverflowFilterPressed,
              showExpandButton: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactOrExpandedNonDataBar(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final List<Widget> leadingActions = [];
    final List<Widget> trailingActions = [];

    switch (region) {
      case DabRegion.metrics:
        leadingActions.add(
          DabTimeHorizonTabs(
            selectedHorizon: selectedHorizon,
            onHorizonChanged: onHorizonChanged,
          ),
        );
      case DabRegion.tasks:
        if (taskQueueLabels.isNotEmpty) {
          if (isExpanded) {
            leadingActions.add(
              DabCompactTabs(
                labels: taskQueueLabels,
                selectedIndex: selectedTaskQueueIndex,
                onChanged: onTaskQueueChanged,
              ),
            );
            if (showSearch && onSearchChanged != null) {
              trailingActions.add(_buildSearchInput(theme, colors));
            }
          } else {
            leadingActions.add(
              _buildSingleSelectMenuButton(
                theme: theme,
                colors: colors,
                icon: shad.LucideIcons.listFilter,
                labels: taskQueueLabels,
                selectedIndex: selectedTaskQueueIndex,
                onSelected: onTaskQueueChanged,
              ),
            );
          }
        }
      case DabRegion.reports:
        if (reportLensLabels.isNotEmpty) {
          if (isExpanded) {
            leadingActions.add(
              DabCompactTabs(
                labels: reportLensLabels,
                selectedIndex: selectedReportLensIndex,
                onChanged: onReportLensChanged,
              ),
            );
          } else {
            leadingActions.add(
              _buildSingleSelectMenuButton(
                theme: theme,
                colors: colors,
                icon: shad.LucideIcons.slidersHorizontal,
                labels: reportLensLabels,
                selectedIndex: selectedReportLensIndex,
                onSelected: onReportLensChanged,
              ),
            );
          }
        }
      case DabRegion.data:
        break;
    }

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 36 * theme.scaling),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showExpandButton && onToggleExpand != null) ...[
              DabRegionLeading(
                region: region,
                regionNumberOverride: regionNumber,
                isExpanded: isExpanded,
                onToggleExpand: onToggleExpand,
              ),
              if (leadingActions.isNotEmpty) const shad.DensityGap(shad.gapSm),
            ],
            for (int i = 0; i < leadingActions.length; i++) ...[
              if (i > 0) const shad.DensityGap(shad.gapSm),
              leadingActions[i],
            ],
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (int i = 0; i < trailingActions.length; i++) ...[
                        if (i > 0) const shad.DensityGap(shad.gapSm),
                        trailingActions[i],
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (showOverflowButton) ...[
              const shad.DensityGap(shad.gapSm),
              DabRegionTrailingActions(
                showOverflowButton: showOverflowButton,
                onOverflowPressed: onOverflowFilterPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSelectMenuButton({
    required shad.ThemeData theme,
    required shad.ColorScheme colors,
    required IconData icon,
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int>? onSelected,
  }) {
    final safeIdx = selectedIndex.clamp(0, labels.length - 1);
    return Builder(
      builder: (btnContext) => _buildDabOutlineButton(
        theme: theme,
        colors: colors,
        leadingIcon: icon,
        label: labels[safeIdx],
        trailingIcon: shad.LucideIcons.chevronDown,
        isSelected: safeIdx > 0,
        onPressed: () {
          shad.showDropdown<void>(
            context: btnContext,
            anchorAlignment: Alignment.bottomLeft,
            alignment: Alignment.topLeft,
            offset: Offset(0, 4 * theme.scaling),
            builder: (popContext) => shad.DropdownMenu(
              children: [
                shad.MenuRadioGroup<int>(
                  value: safeIdx,
                  onChanged: (ctx, val) => onSelected?.call(val),
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      shad.MenuRadio<int>(
                        value: i,
                        child: Text(labels[i]),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDabOutlineButton({
    required shad.ThemeData theme,
    required shad.ColorScheme colors,
    required String label,
    IconData? leadingIcon,
    int? badgeCount,
    bool showZeroBadge = false,
    IconData? trailingIcon,
    bool isSelected = false,
    VoidCallback? onPressed,
  }) {
    final scaling = theme.scaling;
    final iconSmSize = theme.iconTheme.small.size ?? 16.0;
    final style = const shad.ButtonStyle.outline().withPadding(
      padding: EdgeInsets.symmetric(horizontal: 12 * scaling),
    );

    return SizedBox(
      height: 36 * scaling,
      child: shad.SelectedButton(
        value: isSelected,
        alignment: Alignment.center,
        style: style,
        selectedStyle: style,
        onChanged: onPressed != null ? (_) => onPressed() : null,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          descendantsAreFocusable: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: iconSmSize,
                  color: colors.mutedForeground,
                ),
                if (label.isNotEmpty) const shad.DensityGap(shad.gapSm),
              ],
              if (label.isNotEmpty)
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.textSmall.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              if (badgeCount != null &&
                  (badgeCount > 0 || showZeroBadge)) ...[
                if (label.isNotEmpty || leadingIcon != null)
                  const shad.DensityGap(shad.gapSm),
                DyCountBadge(
                  count: badgeCount,
                  isPrimary: isSelected,
                ),
              ],
              if (trailingIcon != null) ...[
                if (label.isNotEmpty ||
                    leadingIcon != null ||
                    (badgeCount != null && (badgeCount > 0 || showZeroBadge)))
                  const shad.DensityGap(shad.gapSm),
                Icon(
                  trailingIcon,
                  size: iconSmSize,
                  color: colors.mutedForeground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDabIconOutlineButton({
    required shad.ThemeData theme,
    required shad.ColorScheme colors,
    required IconData icon,
    bool isSelected = false,
    VoidCallback? onPressed,
  }) {
    final scaling = theme.scaling;
    final iconMdSize = 20.0 * scaling;
    final iconSmSize = theme.iconTheme.small.size ?? 16.0;
    const style = shad.ButtonStyle.outline(density: shad.ButtonDensity.icon);

    return SizedBox(
      width: 36 * scaling,
      height: 36 * scaling,
      child: shad.SelectedButton(
        value: isSelected,
        alignment: Alignment.center,
        style: style,
        selectedStyle: style,
        onChanged: onPressed != null ? (_) => onPressed() : null,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          descendantsAreFocusable: false,
          child: SizedBox(
            width: iconMdSize,
            height: iconMdSize,
            child: Center(
              child: Icon(
                icon,
                size: iconSmSize,
                color: colors.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewSwitcherGroup(BuildContext context, shad.ThemeData theme, shad.ColorScheme colors) {
    return shad.ButtonGroup(
      children: [
        if (supportedViewModes.contains('table'))
          _buildViewButton(
            context: context,
            theme: theme,
            colors: colors,
            viewMode: 'table',
            icon: shad.LucideIcons.table,
            tooltipText: 'Table View',
            anchorAlignment: Alignment.bottomLeft,
            popoverAlignment: Alignment.topLeft,
          ),
        if (supportedViewModes.contains('list'))
          _buildViewButton(
            context: context,
            theme: theme,
            colors: colors,
            viewMode: 'list',
            icon: shad.LucideIcons.list,
            tooltipText: 'List View',
            anchorAlignment: Alignment.bottomCenter,
            popoverAlignment: Alignment.topCenter,
          ),
        if (supportedViewModes.contains('cards'))
          _buildViewButton(
            context: context,
            theme: theme,
            colors: colors,
            viewMode: 'cards',
            icon: shad.LucideIcons.layoutGrid,
            tooltipText: 'Cards View',
            anchorAlignment: Alignment.bottomCenter,
            popoverAlignment: Alignment.topCenter,
          ),
        if (supportedViewModes.contains('board'))
          _buildViewButton(
            context: context,
            theme: theme,
            colors: colors,
            viewMode: 'board',
            icon: shad.LucideIcons.kanban,
            tooltipText: 'Board View',
            anchorAlignment: Alignment.bottomRight,
            popoverAlignment: Alignment.topRight,
          ),
      ],
    );
  }

  Widget _buildViewButton({
    required BuildContext context,
    required shad.ThemeData theme,
    required shad.ColorScheme colors,
    required String viewMode,
    required IconData icon,
    required String tooltipText,
    required Alignment anchorAlignment,
    required Alignment popoverAlignment,
  }) {
    final bool isSelected = selectedView == viewMode;

    return shad.FocusToFront(
      child: shad.Tooltip(
        anchorAlignment: anchorAlignment,
        alignment: popoverAlignment,
        tooltip: (context) => shad.TooltipContainer(
          child: Text(tooltipText),
        ),
        child: _buildDabIconOutlineButton(
          theme: theme,
          colors: colors,
          icon: icon,
          isSelected: isSelected,
          onPressed: () => onViewChanged?.call(viewMode),
        ),
      ),
    );
  }

  static const List<DabSortOption> _defaultSortOptions = [
    DabSortOption(id: 'date', label: 'Date', icon: shad.LucideIcons.calendar),
    DabSortOption(id: 'vno', label: 'Voucher / Code #', icon: shad.LucideIcons.hash),
    DabSortOption(id: 'party', label: 'Party / Mill', icon: shad.LucideIcons.user),
    DabSortOption(id: 'amount', label: 'Amount / Value', icon: shad.LucideIcons.indianRupee),
  ];
}
