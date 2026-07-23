import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'dab_widgets/display_pagination.dart';
import '../micro_level/micro_button.dart';

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

  // Index 0: Optional Display Pagination (Used in Tables, omitted in List Views)
  final bool showPagination;
  final int loadedCount;
  final int totalCount;
  final int selectedCount;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  // Index 1: Mandatory Search Field
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final double? searchWidth;

  // Index 2: Filter Button Cards Row (Min 1, Max 3 + Overflow 3-Dots)
  final List<DabFilterItem> filters;
  final ValueChanged<DabFilterItem>? onFilterPressed;
  final VoidCallback? onOverflowFilterPressed;

  // Index 3: Mandatory Date Button Card
  final String? selectedDateLabel;
  final VoidCallback? onDatePressed;

  // Index 4: Optional Sort Button Card (Omitted in Tables, used in List Views)
  final bool showSort;
  final String? selectedSortLabel;
  final VoidCallback? onSortPressed;

  const DynamicActionBar({
    super.key,
    this.entityName = 'Cards',
    // Index 0
    this.showPagination = true,
    this.loadedCount = 50,
    this.totalCount = 51,
    this.selectedCount = 0,
    this.onPreviousPage,
    this.onNextPage,
    // Index 1
    this.searchQuery,
    this.onSearchChanged,
    this.searchWidth,
    // Index 2
    this.filters = const [],
    this.onFilterPressed,
    this.onOverflowFilterPressed,
    // Index 3
    this.selectedDateLabel,
    this.onDatePressed,
    // Index 4
    this.showSort = false,
    this.selectedSortLabel,
    this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // Filter cards logic (Max 3 visible + Overflow 4th card)
    final visibleFilters = filters.take(3).toList();
    final hasOverflow = filters.length > 3;

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: theme.density.baseContainerPadding * theme.scaling * shad.padXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          // ==========================================
          // INDEX 0: Display Pagination (Optional - Tables)
          // ==========================================
          if (showPagination) ...[
            DisplayPagination(
              loadedCount: loadedCount,
              totalCount: totalCount,
              selectedCount: selectedCount,
              entityName: entityName,
              onPrevious: onPreviousPage,
              onNext: onNextPage,
            ),
            const shad.DensityGap(shad.gapMd),
          ],

          // ==========================================
          // INDEX 1: Search Field (Mandatory with native filled: true)
          // ==========================================
          SizedBox(
            width: searchWidth ?? 220 * theme.scaling,
            child: shad.TextField(
              filled: true,
              placeholder: Text('Search $entityName...'),
              padding: EdgeInsets.symmetric(
                horizontal: 12 * theme.scaling,
                vertical: 8 * theme.scaling,
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

          // ==========================================
          // INDEX 2: Filter Button Cards (Min 1, Max 3 + 3-Dots)
          // ==========================================
          if (filters.isNotEmpty) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: visibleFilters.map((filter) {
                final isSelected = filter.selectedValue != null && filter.selectedValue!.isNotEmpty;

                return Padding(
                  padding: EdgeInsets.only(right: 8 * theme.scaling),
                  child: MicroButton(
                    leadingIcon: filter.icon,
                    label: filter.selectedValue ?? filter.label,
                    trailingIcon: shad.LucideIcons.chevronDown,
                    isSelected: isSelected,
                    onPressed: () => onFilterPressed?.call(filter),
                  ),
                );
              }).toList(),
            ),

            // Trailing 3-Dots Overflow Button Card (if >3 filters)
            if (hasOverflow) ...[
              Padding(
                padding: EdgeInsets.only(right: 8 * theme.scaling),
                child: MicroButton(
                  label: '',
                  leadingIcon: shad.LucideIcons.ellipsisVertical,
                  onPressed: onOverflowFilterPressed,
                ),
              ),
            ],
          ],

          // ==========================================
          // INDEX 3: Date Button Card (Mandatory)
          // ==========================================
          MicroButton(
            leadingIcon: shad.LucideIcons.calendar,
            label: selectedDateLabel ?? 'Date',
            trailingIcon: shad.LucideIcons.chevronDown,
            isSelected: selectedDateLabel != null,
            onPressed: onDatePressed,
          ),

          // ==========================================
          // INDEX 4: Sort Button Card (Optional - List Views)
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
        ],
      ),
    ),
  );
}
}
