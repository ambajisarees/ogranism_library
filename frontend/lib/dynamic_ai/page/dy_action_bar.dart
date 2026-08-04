/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC ACTION BAR (dy_action_bar.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - High-density 34px toolbar component enforcing DAB Mode Architecture.
   - Modes: [DabMode.details] (landing pages) & [DabMode.form] (add/edit pages).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Start of DAB (Modular per mode & page):
     1. Submodule Selector (optional)
     2. View Mode Switcher (compulsory 4 view modes: table, list, cards, board)
     3. AutoComplete / Single Select Widget (optional, matching search specs)
     4. Context Filter MicroButtons (Party, Mill, Fabric, Status, Date)
     5. Non-Table Sort MicroButton (compulsory for list/cards/board)
     6. Group Switcher Button Group (optional, first option always 'None')
   - Center Spacer:
     7. Spacer (consumes 100% of remaining horizontal space)
   - End of DAB (Consistent across ALL modes & pages):
     8. Search Input Field (compulsory, fixed 34px height)
     9. Trailing Three-Dots Overflow Button (compulsory, pinned right)
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../micro/dy_micro_button.dart';
import '../micro/dab/dab_date_pop.dart';
import '../micro/dab/dab_group_popover.dart';
import '../micro/dab/dab_group_switcher.dart';
import '../micro/dab/dab_overflow_pop.dart';
import '../micro/dab/dab_select_pop.dart';
import '../micro/dab/dab_sort_popover.dart';

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

/// [DynamicActionBar] — Standardized High-Density 34px Action & Filter Bar Component.
class DynamicActionBar extends StatelessWidget {
  final DabMode mode;
  final String entityName;

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
  final Set<String> selectedMills;
  final List<String> millOptions;
  final ValueChanged<Set<String>>? onMillChanged;
  final Set<String> selectedFabrics;
  final List<String> fabricOptions;
  final ValueChanged<Set<String>>? onFabricChanged;
  final Set<String> selectedParties;
  final List<String> partyOptions;
  final ValueChanged<Set<String>>? onPartyChanged;
  final Set<String> selectedStatuses;
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
    this.selectedMills = const {},
    this.millOptions = const [],
    this.onMillChanged,
    Set<String>? selectedFabrics,
    List<String>? fabricOptions,
    ValueChanged<Set<String>>? onFabricChanged,
    Set<String>? selectedQualities,
    List<String>? qualityOptions,
    ValueChanged<Set<String>>? onQualityChanged,
    this.selectedParties = const {},
    this.partyOptions = const [],
    this.onPartyChanged,
    this.selectedStatuses = const {},
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

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ==========================================
          // MODULAR START OF DAB (Left-Aligned Items)
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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

                  // 5. Context Filter MicroButtons (Party, Mill, Fabric, Status)
                  if (showFilterButtons) ...[
                    // Party Filter
                    if (onPartyChanged != null || partyOptions.isNotEmpty) ...[
                      Builder(
                        builder: (btnContext) => MicroButton(
                          leadingIcon: shad.LucideIcons.users,
                          label: 'Party',
                          badgeCount: selectedParties.length,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedParties.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                                builder: (context) => DabSelectPopover(
                                  title: 'Party',
                                  options: partyOptions,
                                  selectedValues: selectedParties,
                                  onChanged: (set) => onPartyChanged?.call(set),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                    ],

                    // Mill Filter
                    if (onMillChanged != null || millOptions.isNotEmpty) ...[
                      Builder(
                        builder: (btnContext) => MicroButton(
                          leadingIcon: shad.LucideIcons.warehouse,
                          label: 'Mill',
                          badgeCount: selectedMills.length,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedMills.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                                builder: (context) => DabSelectPopover(
                                  title: 'Mill',
                                  options: millOptions,
                                  selectedValues: selectedMills,
                                  onChanged: (set) => onMillChanged?.call(set),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                    ],

                    // Fabric Filter
                    if (onFabricChanged != null || fabricOptions.isNotEmpty) ...[
                      Builder(
                        builder: (btnContext) => MicroButton(
                          leadingIcon: shad.LucideIcons.shirt,
                          label: 'Fabric',
                          badgeCount: selectedFabrics.length,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedFabrics.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                                builder: (context) => DabSelectPopover(
                                  title: 'Fabric',
                                  options: fabricOptions,
                                  selectedValues: selectedFabrics,
                                  onChanged: (set) => onFabricChanged?.call(set),
                                ),
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
                        builder: (btnContext) => MicroButton(
                          leadingIcon: shad.LucideIcons.circleDot,
                          label: 'Status',
                          badgeCount: selectedStatuses.length,
                          trailingIcon: shad.LucideIcons.chevronDown,
                          isSelected: selectedStatuses.isNotEmpty,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomLeft,
                                alignment: Alignment.topLeft,
                                offset: const Offset(0, 4),
                                builder: (context) => DabSelectPopover(
                                  title: 'Status',
                                  options: const ['Pending', 'Completed'],
                                  selectedValues: selectedStatuses,
                                  onChanged: (set) => onStatusChanged?.call(set),
                                ),
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
                      builder: (btnContext) => MicroButton(
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
                              builder: (context) => DabDatePopover(
                                selectedRange: selectedDateRange,
                                onRangeSelected: (range) => onDateRangeSelected?.call(range),
                                onClose: () => shad.closeOverlay(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // 6. Non-Table Sort MicroButton (Compulsory for list, cards, board)
                  if (selectedView != 'table' && (onSortFieldChanged != null || sortOptions != null)) ...[
                    Builder(
                      builder: (btnContext) {
                        final activeOpt = sortOptions?.firstWhere(
                          (o) => o.id == selectedSortField,
                          orElse: () => DabSortOption(id: selectedSortField ?? 'date', label: 'Sort'),
                        );
                        final activeLabel = activeOpt?.label ?? 'Sort';

                        return MicroButton(
                          leadingIcon: shad.LucideIcons.arrowUpDown,
                          label: 'Sort: $activeLabel',
                          trailingIcon: isSortAscending ? shad.LucideIcons.arrowUp : shad.LucideIcons.arrowDown,
                          isSelected: selectedSortField != null,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomRight,
                                alignment: Alignment.topRight,
                                offset: const Offset(0, 4),
                                builder: (context) => DabSortPopover(
                                  selectedId: selectedSortField ?? 'date',
                                  isAscending: isSortAscending,
                                  options: sortOptions ?? _defaultSortOptions,
                                  onSelected: (id) => onSortFieldChanged?.call(id),
                                  onToggleDirection: () => onToggleSortDirection?.call(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const shad.DensityGap(shad.gapSm),
                  ],

                  // 7. Group Popover MicroButton (1 to 4 levels)
                  if (onGroupLevelsChanged != null) ...[
                    Builder(
                      builder: (btnContext) => MicroButton(
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
                              builder: (popContext) => DabGroupPopover(
                                initialLevels: groupLevels,
                                onApply: (levels) => onGroupLevelsChanged?.call(levels),
                                onClose: () => shad.closeOverlay(popContext),
                              ),
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
                    MicroButton(
                      label: '',
                      leadingIcon: shad.LucideIcons.x,
                      onPressed: onClearAllFilters,
                    ),
                    const shad.DensityGap(shad.gapSm),
                  ],
                ],
              ),
            ),
          ),

          // ==========================================
          // CONSISTENT END OF DAB (Search + 3-Dots Pinned Right)
          // ==========================================
          if (showSearch) ...[
            const shad.DensityGap(shad.gapSm),
            SizedBox(
              width: searchWidth ?? 220 * theme.scaling,
              height: 34 * theme.scaling,
              child: shad.TextField(
                filled: true,
                placeholder: Text('Search $entityName...'),
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * theme.scaling,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  border: Border.all(color: colors.border, width: 1.0),
                ),
                onChanged: onSearchChanged,
                features: [
                  shad.InputFeature.leading(
                    Icon(
                      shad.LucideIcons.search,
                      size: 16 * theme.scaling,
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const shad.DensityGap(shad.gapSm),
          Builder(
            builder: (btnContext) {
              return MicroButton(
                label: '',
                leadingIcon: shad.LucideIcons.ellipsisVertical,
                padding: EdgeInsets.all(10 * theme.scaling),
                onPressed: () {
                  if (onOverflowFilterPressed != null) {
                    onOverflowFilterPressed!();
                  } else {
                    shad.showOverlay(
                      btnContext,
                      shad.PopoverConfiguration(
                        anchorAlignment: Alignment.bottomRight,
                        alignment: Alignment.topRight,
                        offset: const Offset(0, 4),
                        builder: (context) => const DabOverflowPopover(),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
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

    return shad.Tooltip(
      anchorAlignment: anchorAlignment,
      alignment: popoverAlignment,
      tooltip: (context) => shad.TooltipContainer(
        child: Text(tooltipText),
      ),
      child: MicroButton(
        label: '',
        leadingIcon: icon,
        isSelected: isSelected,
        padding: EdgeInsets.all(10 * theme.scaling),
        onPressed: () => onViewChanged?.call(viewMode),
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
