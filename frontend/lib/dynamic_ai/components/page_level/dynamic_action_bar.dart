import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../micro_level/micro_button.dart';
import 'dab_widgets/dab_date_popover.dart';
import 'dab_widgets/dab_filter_popover.dart';
import 'dab_widgets/dab_overflow_popover.dart';
import 'dab_widgets/dab_status_popover.dart';

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
  final IconData icon;
  final String? selectedValue;

  const DabFilterItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedValue,
  });
}

/// Refined Data Action Bar (DAB) component following 5-Index Structure.
class DynamicActionBar extends StatelessWidget {
  // General Configuration
  final String entityName; // e.g. "Cards", "Bills", "Orders"

  // Index 0: View Mode Button Group (Table, List, Cards, Board)
  final String selectedView;
  final ValueChanged<String>? onViewChanged;
  final List<String> supportedViewModes;

  // Optional Submodule Selector Widget (placed at Index 1 after View Switcher)
  final Widget? submoduleWidget;

  // Optional Autocompletes & Grouping Switcher Slots
  final Widget? millAutoComplete;
  final Widget? qualityAutoComplete;
  final Widget? groupingSwitcher;
  final List<Widget>? customMiddleWidgets;

  // Index 1: Mandatory Search Field
  final bool showSearch;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final double? searchWidth;

  // Index 2: Filter Button Cards Data & Callbacks
  final bool showFilterButtons;
  final Set<String> selectedMills;
  final List<String> millOptions;
  final ValueChanged<Set<String>>? onMillChanged;

  final Set<String> selectedQualities;
  final List<String> qualityOptions;
  final ValueChanged<Set<String>>? onQualityChanged;

  final Set<String> selectedStatuses;
  final ValueChanged<Set<String>>? onStatusChanged;

  final VoidCallback? onOverflowFilterPressed;

  // Index 3: Mandatory Date Button Card & Popover
  final bool showDateFilter;
  final shad.CalendarValue? selectedDateRange;
  final String? selectedDateLabel;
  final ValueChanged<shad.CalendarValue?>? onDateRangeSelected;

  // Clear All Action
  final bool hasActiveFilters;
  final VoidCallback? onClearAllFilters;

  // Index 4: Optional Sort Button Card
  final bool showSort;
  final String? selectedSortLabel;
  final VoidCallback? onSortPressed;

  const DynamicActionBar({
    super.key,
    this.entityName = 'Cards',
    // Index 0
    this.selectedView = 'table',
    this.onViewChanged,
    this.supportedViewModes = const ['table', 'list', 'cards', 'board'],
    this.submoduleWidget,
    // Custom Autocompletes & Grouping
    this.millAutoComplete,
    this.qualityAutoComplete,
    this.groupingSwitcher,
    this.customMiddleWidgets,
    // Index 1
    this.showSearch = true,
    this.searchQuery,
    this.onSearchChanged,
    this.searchWidth,
    // Index 2
    this.showFilterButtons = true,
    this.selectedMills = const {},
    this.millOptions = const [],
    this.onMillChanged,
    this.selectedQualities = const {},
    this.qualityOptions = const [],
    this.onQualityChanged,
    this.selectedStatuses = const {},
    this.onStatusChanged,
    this.onOverflowFilterPressed,
    // Index 3
    this.showDateFilter = true,
    this.selectedDateRange,
    this.selectedDateLabel,
    this.onDateRangeSelected,
    // Clear All
    this.hasActiveFilters = false,
    this.onClearAllFilters,
    // Index 4
    this.showSort = false,
    this.selectedSortLabel,
    this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final millLabel = selectedMills.isEmpty
        ? 'Mill'
        : (selectedMills.length == 1
            ? selectedMills.first
            : 'Mill (${selectedMills.length})');
    final qualityLabel = selectedQualities.isEmpty
        ? 'Quality'
        : (selectedQualities.length == 1
            ? selectedQualities.first
            : 'Quality (${selectedQualities.length})');
    final statusLabel = selectedStatuses.isEmpty
        ? 'Status'
        : (selectedStatuses.length == 1
            ? selectedStatuses.first
            : 'Status (${selectedStatuses.length})');

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical:
              theme.density.baseContainerPadding * theme.scaling * shad.padXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==========================================
            // INDEX 0: Pure Native ButtonGroup with IconButton.outline
            // ==========================================
            shad.ButtonGroup(
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
            ),
            const shad.DensityGap(shad.gapSm),

            // ==========================================
            // OPTIONAL SUBMODULE SELECTOR
            // ==========================================
            if (submoduleWidget != null) ...[
              submoduleWidget!,
              const shad.DensityGap(shad.gapSm),
            ],

            // ==========================================
            // OPTIONAL AUTOCOMPLETES (Mill & Quality)
            // ==========================================
            if (millAutoComplete != null) ...[
              millAutoComplete!,
              const shad.DensityGap(shad.gapSm),
            ],
            if (qualityAutoComplete != null) ...[
              qualityAutoComplete!,
              const shad.DensityGap(shad.gapSm),
            ],

            // ==========================================
            // OPTIONAL GROUPING VIEW SWITCHER
            // ==========================================
            if (groupingSwitcher != null) ...[
              groupingSwitcher!,
              const shad.DensityGap(shad.gapSm),
            ],

            if (customMiddleWidgets != null)
              for (final widget in customMiddleWidgets!) ...[
                widget,
                const shad.DensityGap(shad.gapSm),
              ],

            // ==========================================
            // INDEX 1: Search Field (Optional)
            // ==========================================
            if (showSearch) ...[
              SizedBox(
                width: searchWidth ?? 220 * theme.scaling,
                child: shad.TextField(
                  filled: true,
                  placeholder: Text('Search $entityName...'),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * theme.scaling,
                    vertical: 7 * theme.scaling,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    border: Border.all(color: colors.border),
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
              const shad.DensityGap(shad.gapSm),
            ],

            // ==========================================
            // INDEX 2: Filter Button Cards (Optional)
            // ==========================================
            if (showFilterButtons) ...[
              // 1. Mill Filter Card + Popover
              Padding(
                padding: EdgeInsets.only(right: 8 * theme.scaling),
                child: Builder(
                  builder: (btnContext) {
                    return MicroButton(
                      leadingIcon: shad.LucideIcons.warehouse,
                      label: millLabel,
                      badgeCount: selectedMills.length > 1
                          ? selectedMills.length
                          : null,
                      trailingIcon: shad.LucideIcons.chevronDown,
                      isSelected: selectedMills.isNotEmpty,
                      onPressed: () {
                        shad.showOverlay(
                          btnContext,
                          shad.PopoverConfiguration(
                            anchorAlignment: Alignment.bottomCenter,
                            alignment: Alignment.topCenter,
                            offset: const Offset(0, 4),
                            builder: (context) => DabFilterPopover(
                              title: 'Mill',
                              options: millOptions,
                              selectedValues: selectedMills,
                              onChanged: (set) => onMillChanged?.call(set),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 2. Quality Filter Card + Popover
              Padding(
                padding: EdgeInsets.only(right: 8 * theme.scaling),
                child: Builder(
                  builder: (btnContext) {
                    return MicroButton(
                      leadingIcon: shad.LucideIcons.scissors,
                      label: qualityLabel,
                      badgeCount: selectedQualities.length > 1
                          ? selectedQualities.length
                          : null,
                      trailingIcon: shad.LucideIcons.chevronDown,
                      isSelected: selectedQualities.isNotEmpty,
                      onPressed: () {
                        shad.showOverlay(
                          btnContext,
                          shad.PopoverConfiguration(
                            anchorAlignment: Alignment.bottomCenter,
                            alignment: Alignment.topCenter,
                            offset: const Offset(0, 4),
                            builder: (context) => DabFilterPopover(
                              title: 'Quality',
                              options: qualityOptions,
                              selectedValues: selectedQualities,
                              onChanged: (set) => onQualityChanged?.call(set),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 3. Status Filter Card + Popover
              Padding(
                padding: EdgeInsets.only(right: 8 * theme.scaling),
                child: Builder(
                  builder: (btnContext) {
                    return MicroButton(
                      leadingIcon: shad.LucideIcons.circleDot,
                      label: statusLabel,
                      badgeCount: selectedStatuses.length > 1
                          ? selectedStatuses.length
                          : null,
                      trailingIcon: shad.LucideIcons.chevronDown,
                      isSelected: selectedStatuses.isNotEmpty,
                      onPressed: () {
                        shad.showOverlay(
                          btnContext,
                          shad.PopoverConfiguration(
                            anchorAlignment: Alignment.bottomCenter,
                            alignment: Alignment.topCenter,
                            offset: const Offset(0, 4),
                            builder: (context) => DabStatusPopover(
                              selectedStatuses: selectedStatuses,
                              onChanged: (set) => onStatusChanged?.call(set),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],

            // ==========================================
            // INDEX 3: Date Button Card + Popover (Optional)
            // ==========================================
            if (showDateFilter)
              Builder(
                builder: (btnContext) {
                  return MicroButton(
                    leadingIcon: shad.LucideIcons.calendar,
                    label: selectedDateLabel ?? 'Date',
                    trailingIcon: shad.LucideIcons.chevronDown,
                    isSelected: selectedDateRange != null,
                    onPressed: () {
                      shad.showOverlay(
                        btnContext,
                        shad.PopoverConfiguration(
                          anchorAlignment: Alignment.bottomCenter,
                          alignment: Alignment.topCenter,
                          offset: const Offset(0, 4),
                          builder: (context) => DabDatePopover(
                            selectedRange: selectedDateRange,
                            onRangeSelected: (range) =>
                                onDateRangeSelected?.call(range),
                            onClose: () => shad.closeOverlay(context),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

            // ==========================================
            // CLEAR ALL FILTERS CROSS BUTTON (After Date & Before Spacer)
            // ==========================================
            if (hasActiveFilters) ...[
              const shad.DensityGap(shad.gapSm),
              MicroButton(
                label: '',
                leadingIcon: shad.LucideIcons.x,
                onPressed: onClearAllFilters,
              ),
            ],

            // ==========================================
            // INDEX 4: Sort Button Card (Optional)
            // ==========================================
            if (showSort) ...[
              const shad.DensityGap(shad.gapSm),
              MicroButton(
                leadingIcon: shad.LucideIcons.arrowUpDown,
                label: selectedSortLabel ?? 'Sort',
                trailingIcon: shad.LucideIcons.chevronDown,
                isSelected: selectedSortLabel != null,
                onPressed: onSortPressed,
              ),
            ],

            // ==========================================
            // TRAILING SPACER + THREE-DOTS OVERFLOW BUTTON
            // ==========================================
            const Spacer(),
            Builder(
              builder: (btnContext) {
                return MicroButton(
                  label: '',
                  leadingIcon: shad.LucideIcons.ellipsisVertical,
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
      ),
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
      child: shad.IconButton.outline(
        density: shad.ButtonDensity.normal,
        icon: Icon(
          icon,
          size: 16 * theme.scaling,
          color: isSelected ? colors.primary : colors.mutedForeground,
        ),
        onPressed: () => onViewChanged?.call(viewMode),
      ),
    );
  }
}
