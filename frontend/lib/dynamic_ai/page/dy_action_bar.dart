/// LLM NOTE: DynamicActionBar (DAB)
/// - Level: Page-Level Action & Filter Toolbar (34px Height)
/// - Role: High-density 34px toolbar providing an 8-slot pipeline:
///   1. ViewSwitcher (Optional)
///   2. ModuleSwitcher (Optional)
///   3. Search Input (Mandatory / standard)
///   4. Context Filter MicroButtons (Party, Mill, Fabric, Status)
///   5. Date MicroButton
///   6. Sort MicroButton (Optional)
///   7. Clear Filters MicroButton (when hasActiveFilters == true)
///   8. Trailing 3-Dots Menu (Always pinned right)
/// - Zero-Shift Contract: Filter MicroButton labels are static ('Party', 'Mill', 'Fabric', 'Status', 'Date'). Selection count updates exclusively in the badge chip (0 when unselected, count when selected with semibold w600 chip text across all states).
/// - Popover Start Alignment: All filter popovers align flush to the left edge of the trigger (anchorAlignment: Alignment.bottomLeft, alignment: Alignment.topLeft).

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../micro/dy_micro_button.dart';
import '../micro/dab/dab_date_pop.dart';
import '../micro/dab/dab_overflow_pop.dart';
import '../micro/dab/dab_select_pop.dart';
import '../micro/dab/dab_slider_pop.dart';

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

/// Refined Data Action Bar (DAB) component following 8-Slot Zero-Shift Structure.
class DynamicActionBar extends StatelessWidget {
  // General Configuration
  final String entityName; // e.g. "Cards", "Bills", "Orders"

  // Slot 1: View Mode Button Group (Table, List, Cards, Board)
  final String selectedView;
  final ValueChanged<String>? onViewChanged;
  final List<String> supportedViewModes;

  // Slot 2: Optional Submodule Selector Widget
  final Widget? submoduleWidget;

  // Optional Autocompletes & Grouping Switcher Slots
  final Widget? millAutoComplete;
  final Widget? qualityAutoComplete;
  final Widget? groupingSwitcher;
  final List<Widget>? customMiddleWidgets;

  // Slot 3: Search Field
  final bool showSearch;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final double? searchWidth;

  // Slot 4: Context Filter MicroButtons (Party, Mill, Fabric, Status)
  final bool showFilterButtons;
  final Set<String> selectedMills;
  final List<String> millOptions;
  final ValueChanged<Set<String>>? onMillChanged;

  final Set<String> selectedFabrics;
  final List<String> fabricOptions;
  final ValueChanged<Set<String>>? onFabricChanged;

  // Backward compatibility getters / parameters for Quality
  Set<String> get selectedQualities => selectedFabrics;
  List<String> get qualityOptions => fabricOptions;

  final Set<String> selectedParties;
  final List<String> partyOptions;
  final ValueChanged<Set<String>>? onPartyChanged;

  final Set<String> selectedStatuses;
  final ValueChanged<Set<String>>? onStatusChanged;

  final VoidCallback? onOverflowFilterPressed;

  // Slot 5: Date Button Card & Popover
  final bool showDateFilter;
  final shad.CalendarValue? selectedDateRange;
  final String? selectedDateLabel;
  final ValueChanged<shad.CalendarValue?>? onDateRangeSelected;

  // Slot 7: Clear All Action
  final bool hasActiveFilters;
  final VoidCallback? onClearAllFilters;

  // Slot 6: Optional Sort Button Card
  final bool showSort;
  final String? selectedSortLabel;
  final VoidCallback? onSortPressed;

  const DynamicActionBar({
    super.key,
    this.entityName = 'Cards',
    // Slot 1
    this.selectedView = 'table',
    this.onViewChanged,
    this.supportedViewModes = const ['table', 'list', 'cards', 'board'],
    // Slot 2
    this.submoduleWidget,
    // Custom Autocompletes & Grouping
    this.millAutoComplete,
    this.qualityAutoComplete,
    this.groupingSwitcher,
    this.customMiddleWidgets,
    // Slot 3
    this.showSearch = true,
    this.searchQuery,
    this.onSearchChanged,
    this.searchWidth,
    // Slot 4
    this.showFilterButtons = true,
    this.selectedMills = const {},
    this.millOptions = const [],
    this.onMillChanged,
    Set<String>? selectedFabrics,
    List<String>? fabricOptions,
    ValueChanged<Set<String>>? onFabricChanged,
    // Backward compatibility aliases
    Set<String>? selectedQualities,
    List<String>? qualityOptions,
    ValueChanged<Set<String>>? onQualityChanged,
    this.selectedParties = const {},
    this.partyOptions = const [],
    this.onPartyChanged,
    this.selectedStatuses = const {},
    this.onStatusChanged,
    this.onOverflowFilterPressed,
    // Slot 5
    this.showDateFilter = true,
    this.selectedDateRange,
    this.selectedDateLabel,
    this.onDateRangeSelected,
    // Slot 7
    this.hasActiveFilters = false,
    this.onClearAllFilters,
    // Slot 6
    this.showSort = false,
    this.selectedSortLabel,
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
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
            // ==========================================
            // SLOT 1: OPTIONAL SUBMODULE SELECTOR / MODULE MB
            // ==========================================
            if (submoduleWidget != null) ...[
              submoduleWidget!,
              const shad.DensityGap(shad.gapSm),
            ],

            // OPTIONAL AUTOCOMPLETES (Mill & Fabric)
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
            // SLOT 3: Search Field
            // ==========================================
            if (showSearch) ...[
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
              const shad.DensityGap(shad.gapSm),
            ],

            // ==========================================
            // SLOT 4: Zero-Shift Filter MicroButtons (Party, Mill, Fabric, Status)
            // ==========================================
            if (showFilterButtons) ...[
              // 1. Party Filter MicroButton
              if (onPartyChanged != null || partyOptions.isNotEmpty) ...[
                Builder(
                  builder: (btnContext) {
                    return MicroButton(
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
                    );
                  },
                ),
                const shad.DensityGap(shad.gapSm),
              ],

              // 2. Mill Filter MicroButton
              if (onMillChanged != null || millOptions.isNotEmpty) ...[
                Builder(
                  builder: (btnContext) {
                    return MicroButton(
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
                    );
                  },
                ),
                const shad.DensityGap(shad.gapSm),
              ],

              // 3. Fabric Filter MicroButton (renamed from Quality)
              if (onFabricChanged != null || fabricOptions.isNotEmpty) ...[
                Builder(
                  builder: (btnContext) {
                    return MicroButton(
                      leadingIcon: shad.LucideIcons.scissors,
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
                    );
                  },
                ),
                const shad.DensityGap(shad.gapSm),
              ],

              // 4. Status Filter MicroButton
              if (onStatusChanged != null) ...[
                Builder(
                  builder: (btnContext) {
                    return MicroButton(
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
                              options: const ['UNCUT', 'IN CUTTING', 'MILL DISPATCH', 'COMPLETED'],
                              selectedValues: selectedStatuses,
                              onChanged: (set) => onStatusChanged?.call(set),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const shad.DensityGap(shad.gapSm),
              ],
              // 5. Range Slider MicroButton
              Builder(
                builder: (btnContext) {
                  return MicroButton(
                    leadingIcon: shad.LucideIcons.slidersHorizontal,
                    label: 'Range',
                    badgeCount: 0,
                    trailingIcon: shad.LucideIcons.chevronDown,
                    isSelected: false,
                    onPressed: () {
                      shad.showOverlay(
                        btnContext,
                        shad.PopoverConfiguration(
                          anchorAlignment: Alignment.bottomLeft,
                          alignment: Alignment.topLeft,
                          offset: const Offset(0, 4),
                          builder: (context) => DabSliderPopover(
                            title: 'Meters Range',
                            min: 0,
                            max: 1000,
                            startValue: 100,
                            endValue: 500,
                            onChanged: (start, end) {},
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const shad.DensityGap(shad.gapSm),
            ],

            // ==========================================
            // SLOT 5: Date MicroButton & Popover (Left-Aligned)
            // ==========================================
            if (showDateFilter) ...[
              Builder(
                builder: (btnContext) {
                  return MicroButton(
                    leadingIcon: shad.LucideIcons.calendar,
                    label: 'Date',
                    badgeCount: selectedDateRange != null ? 1 : 0,
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
              const shad.DensityGap(shad.gapSm),
            ],

            // ==========================================
            // SLOT 7: CLEAR ALL FILTERS CROSS BUTTON
            // ==========================================
            if (hasActiveFilters) ...[
              MicroButton(
                label: '',
                leadingIcon: shad.LucideIcons.x,
                onPressed: onClearAllFilters,
              ),
              const shad.DensityGap(shad.gapSm),
            ],

            // ==========================================
            // SLOT 6: Sort Button Card (Optional)
            // ==========================================
            if (showSort) ...[
              MicroButton(
                leadingIcon: shad.LucideIcons.arrowUpDown,
                label: selectedSortLabel ?? 'Sort',
                trailingIcon: shad.LucideIcons.chevronDown,
                isSelected: selectedSortLabel != null,
                onPressed: onSortPressed,
              ),
              const shad.DensityGap(shad.gapSm),
            ],
                  ],
                ),
              ),
            ),

            // ==========================================
            // VIEW MODE SWITCHER BUTTON GROUP (Pinned Right before 3-Dots)
            // ==========================================
            const shad.DensityGap(shad.gapSm),
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

            // ==========================================
            // SLOT 8: TRAILING THREE-DOTS OVERFLOW BUTTON (Pinned Right)
            // ==========================================
            const shad.DensityGap(shad.gapSm),
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
      child: MicroButton(
        label: '',
        leadingIcon: icon,
        isSelected: isSelected,
        padding: EdgeInsets.all(10 * theme.scaling),
        onPressed: () => onViewChanged?.call(viewMode),
      ),
    );
  }
}
