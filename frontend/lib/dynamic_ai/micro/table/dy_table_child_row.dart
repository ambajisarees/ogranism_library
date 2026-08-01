/// LLM NOTE: DyTableChildRow Refined
/// - Level: Core Table Row Component
/// - Specs:
///   - Outer padding `horizontal: 8 * theme.scaling` matching header
///   - Data cells: exact 6px horizontal padding matching header
///   - Trailing column: end-aligned ghost action buttons

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'dy_table_models.dart';

class DyTableChildRow extends StatelessWidget {
  final DyTableRowData rowData;
  final List<DyTableColumnSpec> columns;
  final bool showCheckbox;
  final ValueChanged<bool?>? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onMoreActions;

  const DyTableChildRow({
    super.key,
    required this.rowData,
    required this.columns,
    this.showCheckbox = true,
    this.onSelect,
    this.onEdit,
    this.onMoreActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36 * theme.scaling,
          color: rowData.isSelected ? colors.accent : colors.card,
          padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
          child: Row(
            children: [
              // Col 0: Empty Expand Chevron Offset + Select Checkbox
              SizedBox(
                width: 54 * theme.scaling,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 24 * theme.scaling),
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

              // Data Columns (Muted foreground text with 6px horizontal padding)
              ...columns.map((col) {
                final val = rowData.data[col.key] ?? '';
                final isMono = col.isNumeric || col.key == 'vno';

                final textStyle = theme.typography.textSmall.copyWith(
                  color: colors.mutedForeground,
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

              // Col Last: End-Aligned Trailing Ghost Action Buttons
              SizedBox(
                width: 40 * theme.scaling,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shad.IconButton.ghost(
                      icon: Icon(
                        shad.LucideIcons.pencil,
                        size: 13 * theme.scaling,
                        color: colors.mutedForeground,
                      ),
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right-Aligned Indented Divider (stretches from right edge to Column 1 offset)
        Row(
          children: [
            SizedBox(width: 70 * theme.scaling),
            Expanded(
              child: Container(
                height: 1.0,
                color: colors.border,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
