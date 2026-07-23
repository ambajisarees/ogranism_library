import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class CuttingFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedMill;
  final String selectedFabric;
  final List<String> millOptions;
  final List<String> fabricOptions;
  final ValueChanged<String> onMillChanged;
  final ValueChanged<String> onFabricChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onResetFilters;
  final int totalRecords;
  final int displayedRecords;
  final int selectedCount;

  const CuttingFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedMill,
    required this.selectedFabric,
    required this.millOptions,
    required this.fabricOptions,
    required this.onMillChanged,
    required this.onFabricChanged,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
    required this.onResetFilters,
    required this.totalRecords,
    required this.displayedRecords,
    required this.selectedCount,
  });

  bool get hasActiveFilters =>
      (selectedMill.isNotEmpty && selectedMill != 'All') ||
      (selectedFabric.isNotEmpty && selectedFabric != 'All') ||
      startDate != null ||
      endDate != null ||
      searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    final String recordsLabel = selectedCount > 0
        ? '$selectedCount of $totalRecords Selected'
        : '$displayedRecords of $totalRecords Records';

    return Row(
      children: [
        // 1. Compact Surface Pagination / Records Element
        shad.OutlinedContainer(
          borderColor: colors.border,
          backgroundColor: colors.card,
          borderRadius: theme.borderRadiusSm,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10 * theme.scaling, vertical: 6 * theme.scaling),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selectedCount > 0 ? shad.LucideIcons.squareCheck : shad.LucideIcons.layers,
                  size: 14 * theme.scaling,
                  color: selectedCount > 0 ? colors.primary : colors.mutedForeground,
                ),
                SizedBox(width: 6 * theme.scaling),
                Text(
                  recordsLabel,
                  style: theme.typography.mono.copyWith(
                    fontSize: theme.typography.xSmall.fontSize,
                    fontWeight: FontWeight.bold,
                    color: selectedCount > 0 ? colors.primary : colors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
        const shad.DensityGap(shad.gapMd),

        // 2. Search Input
        Expanded(
          child: shad.TextField(
            controller: searchController,
            placeholder: const Text('Search CC Code, Mill, Fabric, Batch #...'),
            onChanged: onSearchChanged,
            features: [
              shad.InputFeature.leading(
                Icon(shad.LucideIcons.search, size: 16 * theme.scaling, color: colors.mutedForeground),
              ),
              if (searchController.text.isNotEmpty)
                shad.InputFeature.trailing(
                  shad.IconButton.ghost(
                    density: shad.ButtonDensity.iconDense,
                    size: shad.ButtonSize.small,
                    icon: Icon(shad.LucideIcons.x, size: 14 * theme.scaling),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  ),
                ),
            ],
          ),
        ),
        const shad.DensityGap(shad.gapMd),

        // 3. Filter Popover Button
        Builder(
          builder: (context) {
            return shad.OutlineButton(
              onPressed: () {
                shad.showOverlay(
                  context,
                  shad.PopoverConfiguration(
                    alignment: Alignment.bottomLeft,
                    offset: Offset(0, 6 * theme.scaling),
                    builder: (context) => shad.ModalContainer(
                      child: SizedBox(
                        width: 320 * theme.scaling,
                        height: 380 * theme.scaling,
                        child: Padding(
                          padding: EdgeInsets.all(padSm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Filter Cutting Batches',
                                style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const shad.DensityGap(shad.gapMd),
                              Text(
                                'Mill Filter',
                                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                              ),
                              const shad.DensityGap(shad.gapSm),
                              SizedBox(
                                height: 120 * theme.scaling,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildOptionItem(context, 'All Mills', 'All', selectedMill, (val) {
                                        onMillChanged(val);
                                      }),
                                      ...millOptions.map((m) => _buildOptionItem(context, m, m, selectedMill, (val) {
                                            onMillChanged(val);
                                          })),
                                    ],
                                  ),
                                ),
                              ),
                              const shad.DensityGap(shad.gapMd),
                              const shad.Divider(),
                              const shad.DensityGap(shad.gapMd),
                              Text(
                                'Fabric / Quality',
                                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                              ),
                              const shad.DensityGap(shad.gapSm),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildOptionItem(context, 'All Fabrics', 'All', selectedFabric, (val) {
                                        onFabricChanged(val);
                                      }),
                                      ...fabricOptions.map((f) => _buildOptionItem(context, f, f, selectedFabric, (val) {
                                            onFabricChanged(val);
                                          })),
                                    ],
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
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shad.LucideIcons.filter, size: 16 * theme.scaling),
                  const shad.DensityGap(shad.gapSm),
                  const Text('Filters'),
                  if ((selectedMill.isNotEmpty && selectedMill != 'All') ||
                      (selectedFabric.isNotEmpty && selectedFabric != 'All')) ...[
                    const shad.DensityGap(shad.gapSm),
                    const shad.PrimaryBadge(child: Text('1+')),
                  ],
                ],
              ),
            );
          },
        ),
        const shad.DensityGap(shad.gapMd),

        // 4. Date Range Selector Popover Button
        Builder(
          builder: (context) {
            return shad.OutlineButton(
              onPressed: () {
                shad.showOverlay(
                  context,
                  shad.PopoverConfiguration(
                    alignment: Alignment.bottomLeft,
                    offset: Offset(0, 6 * theme.scaling),
                    builder: (context) => shad.ModalContainer(
                      child: SizedBox(
                        width: 260 * theme.scaling,
                        child: Padding(
                          padding: EdgeInsets.all(padSm),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Select Date Range',
                                style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const shad.DensityGap(shad.gapMd),
                              shad.Button.ghost(
                                onPressed: () {
                                  shad.closeOverlay(context);
                                  final now = DateTime.now();
                                  onDateRangeChanged(DateTimeRange(
                                      start: now.subtract(const Duration(days: 7)), end: now));
                                },
                                child: const Align(alignment: Alignment.centerLeft, child: Text('Last 7 Days')),
                              ),
                              shad.Button.ghost(
                                onPressed: () {
                                  shad.closeOverlay(context);
                                  final now = DateTime.now();
                                  onDateRangeChanged(DateTimeRange(
                                      start: now.subtract(const Duration(days: 30)), end: now));
                                },
                                child: const Align(alignment: Alignment.centerLeft, child: Text('Last 30 Days')),
                              ),
                              shad.Button.ghost(
                                onPressed: () {
                                  shad.closeOverlay(context);
                                  final now = DateTime.now();
                                  onDateRangeChanged(DateTimeRange(
                                      start: DateTime(now.year, 1, 1), end: now));
                                },
                                child: const Align(alignment: Alignment.centerLeft, child: Text('Year to Date')),
                              ),
                              if (startDate != null || endDate != null) ...[
                                const shad.Divider(),
                                shad.Button.ghost(
                                  onPressed: () {
                                    shad.closeOverlay(context);
                                    onDateRangeChanged(null);
                                  },
                                  child: const Align(alignment: Alignment.centerLeft, child: Text('Clear Date Filter')),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shad.LucideIcons.calendar, size: 16 * theme.scaling),
                  const shad.DensityGap(shad.gapSm),
                  Text(
                    startDate != null
                        ? '${startDate!.day}/${startDate!.month} - ${endDate?.day ?? ''}/${endDate?.month ?? ''}'
                        : 'Date',
                  ),
                ],
              ),
            );
          },
        ),

        if (hasActiveFilters) ...[
          const shad.DensityGap(shad.gapMd),
          shad.IconButton.ghost(
            icon: Icon(shad.LucideIcons.rotateCcw, size: 16 * theme.scaling),
            onPressed: onResetFilters,
          ),
        ],
      ],
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
    String value,
    String currentValue,
    ValueChanged<String> onSelect,
  ) {
    final theme = shad.Theme.of(context);
    final isSelected = (currentValue.isEmpty && value == 'All') || currentValue == value;
    return shad.Button.ghost(
      onPressed: () => onSelect(value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          if (isSelected) Icon(shad.LucideIcons.check, size: 14 * theme.scaling),
        ],
      ),
    );
  }
}
