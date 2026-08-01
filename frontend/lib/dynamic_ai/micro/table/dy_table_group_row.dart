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
    this.isExpanded = true,
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
    final groupBg = isDark ? const Color(0xFF141210) : const Color(0xFFFCFDFE);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36 * theme.scaling,
          color: groupBg, // Module tabs surface canvas token (#FCFDFE / #141210)
          padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
          child: Row(
            children: [
              // Col 0: Expand Chevron Icon Button + Select Checkbox
              SizedBox(
                width: 54 * theme.scaling,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    shad.IconButton.ghost(
                      icon: Icon(
                        isExpanded
                            ? shad.LucideIcons.chevronDown
                            : shad.LucideIcons.chevronRight,
                        size: 14 * theme.scaling,
                        color: colors.foreground,
                      ),
                      onPressed: onToggleExpand,
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

        // Full Width Divider
        Container(
          height: 1.0,
          color: colors.border,
        ),
      ],
    );
  }
}
