import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'dab_widgets/date_popover.dart';
import 'dab_widgets/filter_popover.dart';
import 'dab_widgets/sort_popover.dart';

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

class DynamicActionBar extends StatefulWidget {
  // Tabs Selection
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  // View Select
  final String? selectedViewValue;
  final ValueChanged<String?>? onViewChanged;

  // Search Query
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;

  // Sub-tabs Selection for Links
  final int subTabIndex;
  final ValueChanged<int> onSubTabChanged;
  
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
    this.selectedViewValue,
    this.onViewChanged,
    this.searchQuery,
    this.onSearchChanged,
    required this.subTabIndex,
    required this.onSubTabChanged,
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

  void _showPopover(BuildContext context, WidgetBuilder builder) {
    final theme = shad.Theme.of(context);
    shad.showOverlay(
      context,
      shad.PopoverConfiguration(
        alignment: Alignment.topRight,
        anchorAlignment: Alignment.bottomRight,
        allowInvertVertical: false,
        offset: Offset(0, theme.density.baseContainerPadding * shad.padX2s),
        builder: builder,
      ),
    );
  }

  Widget _buildPopoverChip({
    required BuildContext context,
    required Widget titleIcon,
    required String label,
    required Widget defaultIcon,
    required bool isSelected,
    required VoidCallback onPressed,
    required VoidCallback onClear,
  }) {
    final theme = shad.Theme.of(context);
    final iconSmallSize = theme.iconTheme.small.size;

    return shad.Chip(
      style: !isSelected
          ? const shad.ButtonStyle.outline()
          : const shad.ButtonStyle.primary(),
      leading: isSelected ? titleIcon : defaultIcon,
      trailing: !isSelected
          ? Icon(shad.LucideIcons.ellipsisVertical, size: iconSmallSize)
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: Padding(
                padding: EdgeInsets.all(theme.density.baseGap * shad.padX2s),
                child: Icon(shad.LucideIcons.x, size: iconSmallSize),
              ),
            ),
      onPressed: onPressed,
      child: Text(
        label,
        style: theme.typography.textSmall.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    final filterOpt = _filterOptions.where((o) => o.value == widget.selectedFilterValue).firstOrNull;
    final filterLabel = filterOpt?.label ?? widget.selectedFilterValue ?? 'Status';

    final sortOpt = _sortOptions.where((o) => o.value == widget.selectedSortValue).firstOrNull;
    final sortLabel = sortOpt?.label ?? widget.selectedSortValue ?? 'Sort';

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.density.baseContainerPadding * shad.padXs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. TABS (Pill-style, expand: false)
          shad.Tabs(
            expand: false,
            index: widget.tabIndex,
            onChanged: widget.onTabChanged,
            children: const [
              shad.TabItem(child: Text('Summary')),
              shad.TabItem(child: Text('Details')),
              shad.TabItem(child: Text('Links')),
              shad.TabItem(child: Text('Metrics')),
            ],
          ),
          
          const shad.DensityGap(shad.gapSm),

          // 2. SELECT Field
          shad.Select<String>(
            value: widget.selectedViewValue ?? 'all',
            onChanged: widget.onViewChanged,
            placeholder: const Text('View'),
            popup: (context) => const shad.SelectGroup(
              children: [
                shad.SelectItemButton(value: 'all', child: Text('All Views')),
                shad.SelectItemButton(value: 'active', child: Text('Active Only')),
                shad.SelectItemButton(value: 'archived', child: Text('Archived')),
              ],
            ),
            itemBuilder: (context, val) => Text(
              val == 'all'
                  ? 'All Views'
                  : val == 'active'
                      ? 'Active Only'
                      : 'Archived',
            ),
          ),
          
          // 3. SPACER
          const Spacer(),

          // 4. SEARCH BAR (Compact height matching chips!)
          SizedBox(
            width: 180 * theme.scaling,
            child: shad.TextField(
              placeholder: const Text('Search...'),
              padding: EdgeInsets.symmetric(
                horizontal: 10 * theme.scaling,
                vertical: 4.5 * theme.scaling,
              ),
              onChanged: widget.onSearchChanged,
              features: [
                shad.InputFeature.leading(
                  Icon(shad.LucideIcons.search,
                      size: 14 * theme.scaling,
                      color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),

          const shad.DensityGap(shad.gapSm),
          
          // 5. DATE Filter Chip & Popover
          _buildPopoverChip(
            context: context,
            titleIcon: const Icon(shad.LucideIcons.calendar),
            defaultIcon: const Icon(shad.LucideIcons.infinity),
            label: widget.selectedDateValue ?? 'All',
            isSelected: widget.selectedDateValue != null,
            onPressed: () => _showPopover(
              context,
              (context) => DatePopover(
                selectedValue: widget.selectedDateValue,
                onSelected: widget.onDateChanged,
              ),
            ),
            onClear: () => widget.onDateChanged(null),
          ),
          
          const shad.DensityGap(shad.gapSm),
          
          // 6. FILTER (Status) Chip & Popover
          _buildPopoverChip(
            context: context,
            titleIcon: const Icon(shad.LucideIcons.filter),
            defaultIcon: const Icon(shad.LucideIcons.circleDot),
            label: filterLabel,
            isSelected: widget.selectedFilterValue != null,
            onPressed: () => _showPopover(
              context,
              (context) => FilterPopover(
                options: _filterOptions,
                selectedValue: widget.selectedFilterValue,
                onSelected: widget.onFilterChanged,
              ),
            ),
            onClear: () => widget.onFilterChanged(null),
          ),
          
          const shad.DensityGap(shad.gapSm),
          
          // 7. SORT Chip & Popover
          _buildPopoverChip(
            context: context,
            titleIcon: const Icon(shad.LucideIcons.arrowUpDown),
            defaultIcon: const Icon(shad.LucideIcons.arrowDown),
            label: sortLabel,
            isSelected: widget.selectedSortValue != null,
            onPressed: () => _showPopover(
              context,
              (context) => SortPopover(
                options: _sortOptions,
                selectedValue: widget.selectedSortValue,
                onSelected: widget.onSortChanged,
              ),
            ),
            onClear: () => widget.onSortChanged(null),
          ),
        ],
      ),
    );
  }
}
