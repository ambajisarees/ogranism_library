/// LLM NOTE: DyTableGroupRow Refined
/// - Level: Core Table Row Component
/// - Specs:
///   - Outer padding `horizontal: 8 * theme.scaling` matching header
///   - Data cells: exact 6px horizontal padding matching header
///   - Trailing column: end-aligned ghost action buttons

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'dy_table_models.dart';
import '../../specs/dy_color_system.dart';

class DyTableGroupRow extends StatelessWidget {
  final DyTableRowData rowData;
  final List<DyTableColumnSpec> columns;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool showCheckbox;
  final ValueChanged<bool?>? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onMoreActions;

  const DyTableGroupRow({
    super.key,
    required this.rowData,
    required this.columns,
    required this.isExpanded,
    required this.onToggleExpand,
    this.showCheckbox = true,
    this.onSelect,
    this.onEdit,
    this.onMoreActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;
    final groupBg = DyColorSystem.resolveSurfaceCanvas(isDark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 42 * theme.scaling,
          color: groupBg,
          padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Col 0: Expand Chevron Icon Button + Select Checkbox
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
                          isExpanded
                              ? shad.LucideIcons.chevronDown
                              : shad.LucideIcons.chevronRight,
                          size: 16 * theme.scaling,
                          color: colors.foreground,
                        ),
                        onPressed: onToggleExpand,
                      ),
                    ),
                    if (showCheckbox)
                      shad.Checkbox(
                        state: rowData.isSelected
                            ? shad.CheckboxState.checked
                            : shad.CheckboxState.unchecked,
                        onChanged: (state) {
                          onSelect?.call(state == shad.CheckboxState.checked);
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Data Columns (Semibold text with 6px horizontal padding)
              ...columns.map((col) {
                final val = rowData.data[col.key] ?? (col.key == 'partyName' ? rowData.title : '');
                final isMono = col.isNumeric || col.key == 'vno';

                final textStyle = theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                  fontFamily: isMono ? 'monospace' : null,
                );

                return Expanded(
                  flex: col.flex,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * theme.scaling),
                    alignment: col.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      '$val',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ),
                );
              }),

              // Col Last: Fixed 72px End-Aligned Trailing Stack (Edit Pencil + Horizontal 3 Dots)
              SizedBox(
                width: 72 * theme.scaling,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28 * theme.scaling,
                      height: 28 * theme.scaling,
                      child: shad.IconButton.ghost(
                        size: shad.ButtonSize.small,
                        density: shad.ButtonDensity.compact,
                        icon: Icon(
                          shad.LucideIcons.pencil,
                          size: 16 * theme.scaling,
                          color: colors.mutedForeground,
                        ),
                        onPressed: onEdit,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 28 * theme.scaling,
                      height: 28 * theme.scaling,
                      child: shad.IconButton.ghost(
                        size: shad.ButtonSize.small,
                        density: shad.ButtonDensity.compact,
                        icon: Icon(
                          shad.LucideIcons.ellipsis,
                          size: 16 * theme.scaling,
                          color: colors.mutedForeground,
                        ),
                        onPressed: onMoreActions,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Full Width Divider
        Container(
          height: 1.0,
          color: colors.border,
        ),
      ],
    );
  }
}
