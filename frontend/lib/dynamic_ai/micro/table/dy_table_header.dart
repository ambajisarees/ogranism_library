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
import '../../specs/dy_color_system.dart';

enum DySortDirection {
  ascending,
  descending,
}

class DyTableHeader extends StatelessWidget {
  final List<DyTableColumnSpec> columns;
  final bool showCheckbox;
  final bool isAllSelected;
  final shad.CheckboxState? selectionState;
  final bool isAllExpanded;
  final VoidCallback? onSelectAll;
  final VoidCallback? onToggleExpandAll;
  final String? activeSortKey;
  final DySortDirection? activeSortDirection;
  final Function(String key, DySortDirection? direction)? onSortChanged;

  const DyTableHeader({
    super.key,
    required this.columns,
    this.showCheckbox = true,
    this.isAllSelected = false,
    this.selectionState,
    this.isAllExpanded = false,
    this.onSelectAll,
    this.onToggleExpandAll,
    this.activeSortKey,
    this.activeSortDirection,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    final effectiveSelectionState = selectionState ??
        (isAllSelected ? shad.CheckboxState.checked : shad.CheckboxState.unchecked);

    return Container(
      height: 54 * theme.scaling,
      decoration: BoxDecoration(
        color: DyColorSystem.resolveSurfaceCanvas(isDark),
        borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusMd)),
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 8 * theme.scaling,
        vertical: 8 * theme.scaling,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Column 0: Fixed Leading Actions (Expand/Collapse All + Select All Checkbox)
          SizedBox(
            width: 54 * theme.scaling,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28 * theme.scaling,
                  height: 28 * theme.scaling,
                  child: shad.IconButton.ghost(
                    size: shad.ButtonSize.small,
                    density: shad.ButtonDensity.compact,
                    icon: Icon(
                      isAllExpanded
                          ? shad.LucideIcons.chevronsDownUp
                          : shad.LucideIcons.chevronsUpDown,
                      size: 16 * theme.scaling,
                      color: colors.mutedForeground,
                    ),
                    onPressed: onToggleExpandAll,
                  ),
                ),
                if (showCheckbox)
                  shad.Checkbox(
                    state: effectiveSelectionState,
                    onChanged: (state) {
                      onSelectAll?.call();
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Dynamic Column Headers (Zero cell padding, ghost button with 2px padding on all sides)
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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

          // Column Last: Synchronized 72px blank space matching row trailing stack
          SizedBox(
            width: 72 * theme.scaling,
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
