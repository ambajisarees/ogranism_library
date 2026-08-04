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
import '../../specs/dy_color_system.dart';

class DyTableDefRow extends StatefulWidget {
  final DyTableRowData rowData;
  final List<DyTableColumnSpec> columns;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool showCheckbox;
  final bool showTrailingActions;
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
    this.showTrailingActions = true,
    this.onSelect,
    this.onEdit,
    this.onMoreActions,
  });

  @override
  State<DyTableDefRow> createState() => _DyTableDefRowState();
}

class _DyTableDefRowState extends State<DyTableDefRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;
    final hasExpandableContent = widget.rowData.hasChildren || widget.rowData.expandedDetails != null;

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
            height: 42 * theme.scaling,
            color: rowBg,
            padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Col 0: Expand Chevron Icon Button + Select Checkbox (Outside GestureDetector for 100% direct clickability)
                SizedBox(
                  width: 54 * theme.scaling,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (hasExpandableContent)
                        SizedBox(
                          width: 28 * theme.scaling,
                          height: 28 * theme.scaling,
                          child: shad.IconButton.ghost(
                            size: shad.ButtonSize.small,
                            density: shad.ButtonDensity.compact,
                            icon: Icon(
                              widget.isExpanded
                                  ? shad.LucideIcons.chevronDown
                                  : shad.LucideIcons.chevronRight,
                              size: 16 * theme.scaling,
                              color: colors.mutedForeground,
                            ),
                            onPressed: widget.onToggleExpand,
                          ),
                        )
                      else
                        SizedBox(width: 28 * theme.scaling),

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

                // Data Columns (Wrapped in GestureDetector for row tap expand)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onToggleExpand,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...widget.columns.map((col) {
                          final val = widget.rowData.data[col.key] ?? '';
                          final isVoucherCol = col.key == 'vno' || col.key == 'voucherNo';
                          final isMono = col.isNumeric || isVoucherCol;

                          Widget cellContent;
                          if (isVoucherCol && widget.rowData.imagePath != null && widget.rowData.imagePath!.isNotEmpty) {
                            cellContent = Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Fabric Thumbnail Lightbox Trigger Button
                                SizedBox(
                                  width: 28 * theme.scaling,
                                  height: 28 * theme.scaling,
                                  child: shad.IconButton.ghost(
                                    size: shad.ButtonSize.small,
                                    density: shad.ButtonDensity.compact,
                                    icon: Icon(
                                      shad.LucideIcons.image,
                                      size: 16 * theme.scaling,
                                      color: colors.primary,
                                    ),
                                    onPressed: () {
                                      DyTableGalleryModal.show(
                                        context,
                                        title: 'Design: ${widget.rowData.designPattern ?? val}',
                                        imagePath: widget.rowData.imagePath,
                                      );
                                    },
                                  ),
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
                      ],
                    ),
                  ),
                ),

                // 2. Col Last: Fixed 72px End-Aligned Trailing Stack (Optional)
                if (widget.showTrailingActions)
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
                          onPressed: () {
                            if (widget.onEdit != null) {
                              widget.onEdit!();
                            } else {
                              shad.showToast(
                                context: context,
                                builder: (context, overlay) => shad.Card(
                                  child: Text('Edit Record #${widget.rowData.id}'),
                                ),
                              );
                            }
                          },
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
                          onPressed: () {
                            if (widget.onMoreActions != null) {
                              widget.onMoreActions!();
                            } else {
                              shad.showToast(
                                context: context,
                                builder: (context, overlay) => shad.Card(
                                  child: Text('Actions Menu #${widget.rowData.id}'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Dynamic Divider: Indented if expanded with children, Full-Width if collapsed
        if (widget.isExpanded && widget.rowData.hasChildren)
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
          )
        else
          Container(
            height: 1.0,
            color: colors.border,
          ),
      ],
    ),
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
