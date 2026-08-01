/// LLM NOTE: DyTableHeader Fixed Alignment & No Overflow
/// - Level: Core Table Header Component
/// - Specs:
///   - Header cell uses exact 6px horizontal padding (`horizontal: 6 * theme.scaling`) matching row text padding, ensuring 100% pixel-perfect start alignment between header labels and row text!
///   - Outer container padding `horizontal: 8 * theme.scaling` preventing right overflow in split views.
///   - Col 0 (Flex 1): Expand/Collapse All Icon + Select All Checkbox.
///   - Col Last: Empty blank column.

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'dy_table_models.dart';

enum DySortDirection {
  ascending,
  descending,
}

class DyTableHeader extends StatelessWidget {
  final List<DyTableColumnSpec> columns;
  final bool showCheckbox;
  final bool isAllSelected;
  final ValueChanged<bool?>? onSelectAll;
  final bool isAllExpanded;
  final VoidCallback? onToggleExpandAll;
  final String? activeSortKey;
  final DySortDirection? activeSortDirection;
  final Function(String key, DySortDirection? direction)? onSortChanged;

  const DyTableHeader({
    super.key,
    required this.columns,
    this.showCheckbox = true,
    this.isAllSelected = false,
    this.onSelectAll,
    this.isAllExpanded = false,
    this.onToggleExpandAll,
    this.activeSortKey,
    this.activeSortDirection,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusMd)),
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 8 * theme.scaling,
        vertical: 6 * theme.scaling,
      ),
      child: Row(
        children: [
          // Column 0: Fixed Leading Actions (Expand/Collapse All + Select All Checkbox)
          SizedBox(
            width: 54 * theme.scaling,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shad.IconButton.ghost(
                  icon: Icon(
                    isAllExpanded
                        ? shad.LucideIcons.chevronsDown
                        : shad.LucideIcons.chevronsRight,
                    size: 14 * theme.scaling,
                    color: colors.mutedForeground,
                  ),
                  onPressed: onToggleExpandAll,
                ),
                if (showCheckbox)
                  shad.Checkbox(
                    state: isAllSelected
                        ? shad.CheckboxState.checked
                        : shad.CheckboxState.unchecked,
                    onChanged: (state) {
                      onSelectAll?.call(state == shad.CheckboxState.checked);
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Dynamic Column Headers (Matching exact 6px cell padding for perfect start alignment)
          ...columns.map((col) {
            final isSortable = col.isSortable;
            final isSorted = activeSortKey == col.key;
            final sortDirection = isSorted ? activeSortDirection : null;

            final textColor = isSorted ? colors.foreground : colors.mutedForeground;

            Widget? sortIcon;
            if (isSortable) {
              if (isSorted && sortDirection == DySortDirection.ascending) {
                sortIcon = Icon(
                  shad.LucideIcons.arrowUp,
                  size: 12 * theme.scaling,
                  color: textColor,
                );
              } else if (isSorted && sortDirection == DySortDirection.descending) {
                sortIcon = Icon(
                  shad.LucideIcons.arrowDown,
                  size: 12 * theme.scaling,
                  color: textColor,
                );
              } else {
                sortIcon = Icon(
                  shad.LucideIcons.arrowUpDown,
                  size: 12 * theme.scaling,
                  color: colors.mutedForeground.withAlpha(140),
                );
              }
            }

            return Expanded(
              flex: col.flex,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isSortable
                    ? () {
                        if (!isSorted) {
                          onSortChanged?.call(col.key, DySortDirection.ascending);
                        } else if (sortDirection == DySortDirection.ascending) {
                          onSortChanged?.call(col.key, DySortDirection.descending);
                        } else {
                          onSortChanged?.call(col.key, null);
                        }
                      }
                    : null,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6 * theme.scaling),
                  alignment: col.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: col.isNumeric
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          col.label.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: isSorted ? FontWeight.bold : FontWeight.w600,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (sortIcon != null) ...[
                        SizedBox(width: 4 * theme.scaling),
                        sortIcon,
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          // Column Last: Empty blank column
          SizedBox(
            width: 40 * theme.scaling,
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
