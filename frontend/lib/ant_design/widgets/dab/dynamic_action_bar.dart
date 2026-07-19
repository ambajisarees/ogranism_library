import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'dynamic_action_row.dart';
import 'date_popover.dart';
import 'filter_popover.dart';
import 'sort_popover.dart';

class DynamicActionBar extends StatefulWidget {
  // Tabs Selection
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  
  // Date selection
  final String? selectedDateValue;
  final ValueChanged<String?> onDateChanged;
  
  // Filter selection (Status)
  final String? selectedFilterValue;
  final ValueChanged<String?> onFilterChanged;
  
  // Sorting selection
  final String? selectedSortValue;
  final ValueChanged<String?> onSortChanged;

  const DynamicActionBar({
    super.key,
    required this.tabIndex,
    required this.onTabChanged,
    required this.selectedDateValue,
    required this.onDateChanged,
    required this.selectedFilterValue,
    required this.onFilterChanged,
    required this.selectedSortValue,
    required this.onSortChanged,
  });

  @override
  State<DynamicActionBar> createState() => _DynamicActionBarState();
}

class _DynamicActionBarState extends State<DynamicActionBar> {
  List<DynamicActionOption> get _filterOptions => const [
    DynamicActionOption(
      label: 'Design',
      icon: Icon(shad.LucideIcons.scissors),
      value: 'design',
    ),
    DynamicActionOption(
      label: 'Grey Warehouse',
      icon: Icon(shad.LucideIcons.warehouse),
      value: 'grey_warehouse',
    ),
    DynamicActionOption(
      label: 'Production',
      icon: Icon(shad.LucideIcons.settings),
      value: 'production',
    ),
    DynamicActionOption(
      label: 'Active',
      icon: Icon(shad.LucideIcons.circleDot),
      value: 'active',
    ),
    DynamicActionOption(
      label: 'Pending',
      icon: Icon(shad.LucideIcons.clock),
      value: 'pending',
    ),
    DynamicActionOption(
      label: 'Completed',
      icon: Icon(shad.LucideIcons.check),
      value: 'completed',
    ),
  ];

  List<DynamicActionOption> get _sortOptions => const [
    DynamicActionOption(
      label: 'Oldest First',
      icon: Icon(shad.LucideIcons.arrowUp),
      value: 'oldest',
    ),
    DynamicActionOption(
      label: 'Name ↑',
      icon: Icon(shad.LucideIcons.arrowUp),
      value: 'name_asc',
    ),
    DynamicActionOption(
      label: 'Name ↓',
      icon: Icon(shad.LucideIcons.arrowDown),
      value: 'name_desc',
    ),
    DynamicActionOption(
      label: 'Priority ↑',
      icon: Icon(shad.LucideIcons.arrowUpNarrowWide),
      value: 'priority_asc',
    ),
    DynamicActionOption(
      label: 'Priority ↓',
      icon: Icon(shad.LucideIcons.arrowDownWideNarrow),
      value: 'priority_desc',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return shad.Card(
      padding: EdgeInsets.symmetric(
        horizontal: theme.density.baseContainerPadding * shad.padSm,
        vertical: theme.density.baseContainerPadding * shad.padXs,
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Prefix Tabs (Dashboard, Details, Links)
            shad.Tabs(
              index: widget.tabIndex,
              onChanged: widget.onTabChanged,
              children: [
                shad.TabItem(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Dashboard'),
                      const shad.DensityGap(shad.gapSm),
                      shad.PrimaryBadge(
                        child: const Text('12'),
                      ),
                    ],
                  ),
                ),
                shad.TabItem(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Details'),
                      const shad.DensityGap(shad.gapSm),
                      shad.PrimaryBadge(
                        child: const Text('5'),
                      ),
                    ],
                  ),
                ),
                shad.TabItem(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Links'),
                      const shad.DensityGap(shad.gapSm),
                      shad.PrimaryBadge(
                        child: const Text('3'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // 2. Date DAR
            DynamicActionRow(
              titleIcon: const Icon(shad.LucideIcons.calendar),
              defaultLabel: 'All Time',
              defaultIcon: const Icon(shad.LucideIcons.infinity),
              selectedValue: widget.selectedDateValue,
              onSelected: widget.onDateChanged,
              popoverBuilder: (context) => DatePopover(
                selectedValue: widget.selectedDateValue,
                onSelected: widget.onDateChanged,
              ),
            ),
            
            const shad.DensityGap(shad.gapLg),
            
            // 3. Filter DAR
            DynamicActionRow(
              titleIcon: const Icon(shad.LucideIcons.filter),
              defaultLabel: 'All Status',
              defaultIcon: const Icon(shad.LucideIcons.filter),
              selectedValue: widget.selectedFilterValue,
              onSelected: widget.onFilterChanged,
              popoverBuilder: (context) => FilterPopover(
                selectedValue: widget.selectedFilterValue,
                onSelected: widget.onFilterChanged,
                options: _filterOptions,
              ),
            ),
            
            const shad.DensityGap(shad.gapLg),
            
            // 4. Sort DAR
            DynamicActionRow(
              titleIcon: const Icon(shad.LucideIcons.arrowUpDown),
              defaultLabel: 'Latest First',
              defaultIcon: const Icon(shad.LucideIcons.arrowDown),
              selectedValue: widget.selectedSortValue,
              onSelected: widget.onSortChanged,
              popoverBuilder: (context) => SortPopover(
                selectedValue: widget.selectedSortValue,
                onSelected: widget.onSortChanged,
                options: _sortOptions,
              ),
            ),
          ],
        ),
    );
  }
}
