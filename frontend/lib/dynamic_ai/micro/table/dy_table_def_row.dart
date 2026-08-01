/// LLM NOTE: DyTableDefRow Refined
/// - Level: Core Table Row Component
/// - Specs:
///   - Outer padding `horizontal: 8 * theme.scaling` matching header
///   - Data cells: exact 6px horizontal padding matching header
///   - Trailing column: end-aligned ghost action buttons

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'dy_table_gallery_modal.dart';
import 'dy_table_models.dart';

class DyTableDefRow extends StatelessWidget {
  final DyTableRowData rowData;
  final List<DyTableColumnSpec> columns;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool showCheckbox;
  final ValueChanged<bool?>? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onMoreActions;

  const DyTableDefRow({
    super.key,
    required this.rowData,
    required this.columns,
    this.isExpanded = false,
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
    final hasExpandableContent = rowData.hasChildren || rowData.expandedDetails != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36 * theme.scaling,
          color: rowData.isSelected ? colors.accent : colors.card,
          padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
          child: Row(
            children: [
              // Col 0: Expand Chevron Icon Button + Select Checkbox
              SizedBox(
                width: 54 * theme.scaling,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasExpandableContent)
                      shad.IconButton.ghost(
                        icon: Icon(
                          isExpanded
                              ? shad.LucideIcons.chevronDown
                              : shad.LucideIcons.chevronRight,
                          size: 14 * theme.scaling,
                          color: colors.mutedForeground,
                        ),
                        onPressed: onToggleExpand,
                      )
                    else
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

              // Data Columns (6px horizontal padding matching header text start)
              ...columns.map((col) {
                final val = rowData.data[col.key] ?? '';
                final isVoucherCol = col.key == 'vno' || col.key == 'voucherNo';
                final isMono = col.isNumeric || isVoucherCol;

                Widget cellContent;
                if (isVoucherCol && rowData.imagePath != null && rowData.imagePath!.isNotEmpty) {
                  cellContent = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fabric Thumbnail Lightbox Trigger Button
                      shad.IconButton.ghost(
                        icon: Icon(
                          shad.LucideIcons.image,
                          size: 13 * theme.scaling,
                          color: colors.primary,
                        ),
                        onPressed: () {
                          DyTableGalleryModal.show(
                            context,
                            title: 'Design: ${rowData.designPattern ?? val}',
                            imagePath: rowData.imagePath,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$val',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.textSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.foreground,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (col.key == 'status') {
                  cellContent = _buildStatusBadge(context, '$val');
                } else {
                  cellContent = Text(
                    '$val',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.textSmall.copyWith(
                      color: colors.foreground,
                      fontFamily: isMono ? 'monospace' : null,
                    ),
                  );
                }

                return Expanded(
                  flex: col.flex,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * theme.scaling),
                    alignment: col.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                    child: cellContent,
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

  Widget _buildStatusBadge(BuildContext context, String statusStr) {
    final theme = shad.Theme.of(context);
    final upper = statusStr.toUpperCase();

    if (upper == 'UNCUT' || upper == 'IN CUTTING') {
      return shad.SecondaryBadge(
        child: Text(
          statusStr,
          style: theme.typography.xSmall,
        ),
      );
    } else if (upper == 'ACTIVE' || upper == 'COMPLETED') {
      return shad.PrimaryBadge(
        child: Text(
          statusStr,
          style: theme.typography.xSmall,
        ),
      );
    }
    return shad.OutlineBadge(
      child: Text(
        statusStr,
        style: theme.typography.xSmall,
      ),
    );
  }
}
