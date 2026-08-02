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
import '../../specs/dy_color_system.dart';

class DyTableChildRow extends StatefulWidget {
  final DyTableRowData rowData;
  final List<DyTableColumnSpec> columns;
  final bool showCheckbox;
  final bool isLastChild;
  final ValueChanged<bool?>? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onMoreActions;

  const DyTableChildRow({
    super.key,
    required this.rowData,
    required this.columns,
    this.showCheckbox = true,
    this.isLastChild = false,
    this.onSelect,
    this.onEdit,
    this.onMoreActions,
  });

  @override
  State<DyTableChildRow> createState() => _DyTableChildRowState();
}

class _DyTableChildRowState extends State<DyTableChildRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    final rowBg = widget.rowData.isSelected || _isHovered
        ? DyColorSystem.resolveRootBackground(isDark)
        : colors.card;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 36 * theme.scaling,
            color: rowBg,
            padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Col 0: Empty Expand Chevron Offset + Select Checkbox
                SizedBox(
                  width: 54 * theme.scaling,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 24 * theme.scaling),
                      if (widget.showCheckbox)
                        shad.Checkbox(
                          state: widget.rowData.isSelected
                              ? shad.CheckboxState.checked
                              : shad.CheckboxState.unchecked,
                          onChanged: (state) {
                            widget.onSelect?.call(state == shad.CheckboxState.checked);
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Data Columns (Muted foreground text with 6px horizontal cell padding)
                ...widget.columns.map((col) {
                  final val = widget.rowData.data[col.key] ?? '';
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

                // Col Last: Synchronized 72px blank space matching parent trailing stack
                SizedBox(
                  width: 72 * theme.scaling,
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Dynamic Divider: Full-Width if last child in group, Indented otherwise
          if (widget.isLastChild)
            Container(
              height: 1.0,
              color: colors.border,
            )
          else
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
      ),
    );
  }
}
