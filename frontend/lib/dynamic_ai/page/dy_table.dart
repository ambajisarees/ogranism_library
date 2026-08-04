/// LLM NOTE: DyTable Master Coordinator
/// - Level: Page View Pane Component
/// - Role: Master table coordinator engine supporting 3-tiered row hierarchy (group_row, def_row, child_row), 12-column grid system provisioning, and sticky header/footer.

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../micro/dy_pagination_row.dart';
import '../micro/table/dy_table_child_row.dart';
import '../micro/table/dy_table_def_row.dart';
import '../micro/table/dy_table_footer.dart';
import '../micro/table/dy_table_group_row.dart';
import '../micro/table/dy_table_header.dart';
import '../micro/table/dy_table_subheader_row.dart';
import '../micro/table/dy_table_models.dart';

// Re-export models for backward compatibility across all screens
export '../micro/table/dy_table_models.dart';

class DyTable extends StatefulWidget {
  final List<DyTableColumnSpec> columns;
  final List<DyTableRowData> rows;
  final Set<String> selectedRowIds;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final Map<String, String>? summaryTotals;
  final int pageIndex;
  final int totalPages;
  final int totalRecords;
  final ValueChanged<int>? onPageChanged;
  final String? groupByKey;
  final bool isLoading;
  final bool showTrailingActions;

  const DyTable({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedRowIds = const {},
    this.onSelectionChanged,
    this.summaryTotals,
    this.pageIndex = 1,
    this.totalPages = 1,
    this.totalRecords = 0,
    this.onPageChanged,
    this.groupByKey,
    this.isLoading = false,
    this.showTrailingActions = true,
  });

  @override
  State<DyTable> createState() => _DyTableState();
}

class _DyTableState extends State<DyTable> {
  final Set<String> _expandedRowIds = {};
  final Set<String> _internalSelectedRowIds = {};
  String? _sortKey;
  DySortDirection? _sortDirection;

  @override
  void initState() {
    super.initState();
    // Default expand first group/parent row for clean initial view
    if (widget.rows.isNotEmpty) {
      _expandedRowIds.add(widget.rows.first.id);
    }
  }

  void _toggleSelectAll(bool? selectAll, List<DyTableRowData> sortedRows) {
    setState(() {
      if (selectAll == true) {
        _internalSelectedRowIds.clear();
        for (final r in sortedRows) {
          _internalSelectedRowIds.add(r.id);
        }
      } else {
        _internalSelectedRowIds.clear();
      }
    });

    final newSet = selectAll == true
        ? sortedRows.map((r) => r.id).toSet()
        : <String>{};
    widget.onSelectionChanged?.call(newSet);
  }

  void _toggleRowSelection(String rowId, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _internalSelectedRowIds.add(rowId);
      } else {
        _internalSelectedRowIds.remove(rowId);
      }
    });

    final activeSet = widget.selectedRowIds.isNotEmpty
        ? Set<String>.from(widget.selectedRowIds)
        : Set<String>.from(_internalSelectedRowIds);
    if (isSelected == true) {
      activeSet.add(rowId);
    } else {
      activeSet.remove(rowId);
    }
    widget.onSelectionChanged?.call(activeSet);
  }

  void _toggleRowExpansion(String rowId) {
    setState(() {
      if (_expandedRowIds.contains(rowId)) {
        _expandedRowIds.remove(rowId);
      } else {
        _expandedRowIds.add(rowId);
      }
    });
  }

  void _toggleExpandAll() {
    setState(() {
      if (_expandedRowIds.length == widget.rows.length) {
        _expandedRowIds.clear();
      } else {
        _expandedRowIds.addAll(widget.rows.map((r) => r.id));
      }
    });
  }

  List<DyTableRowData> _getSortedRows() {
    if (_sortKey == null || _sortDirection == null) {
      return widget.rows;
    }
    final sorted = List<DyTableRowData>.from(widget.rows);
    sorted.sort((a, b) {
      final valA = a.data[_sortKey] ?? '';
      final valB = b.data[_sortKey] ?? '';
      int cmp = 0;
      if (valA is num && valB is num) {
        cmp = valA.compareTo(valB);
      } else {
        final strA = valA.toString();
        final strB = valB.toString();
        final numA = double.tryParse(strA.replaceAll(RegExp(r'[^0-9.]'), ''));
        final numB = double.tryParse(strB.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (numA != null && numB != null) {
          cmp = numA.compareTo(numB);
        } else {
          cmp = strA.compareTo(strB);
        }
      }
      return _sortDirection == DySortDirection.ascending ? cmp : -cmp;
    });
    return sorted;
  }

  List<DyTableColumnSpec> _getOrderedColumns() {
    return widget.columns;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final orderedColumns = _getOrderedColumns();
    final sortedRows = _getSortedRows();
    final selectedCount = widget.selectedRowIds.isNotEmpty
        ? widget.selectedRowIds.length
        : _internalSelectedRowIds.length;

    final shad.CheckboxState headerSelectionState;
    if (sortedRows.isNotEmpty && selectedCount == sortedRows.length) {
      headerSelectionState = shad.CheckboxState.checked;
    } else if (selectedCount > 0) {
      headerSelectionState = shad.CheckboxState.indeterminate;
    } else {
      headerSelectionState = shad.CheckboxState.unchecked;
    }

    final isAllExpanded = sortedRows.isNotEmpty &&
        _expandedRowIds.length == sortedRows.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(theme.radiusMd),
              border: Border.all(color: colors.border, width: 1.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Sticky Column Header Row
                DyTableHeader(
                  columns: orderedColumns,
                  selectionState: headerSelectionState,
                  isAllExpanded: isAllExpanded,
                  onToggleExpandAll: _toggleExpandAll,
                  activeSortKey: _sortKey,
                  activeSortDirection: _sortDirection,
                  onSortChanged: (key, direction) {
                    setState(() {
                      _sortKey = direction != null ? key : null;
                      _sortDirection = direction;
                    });
                  },
                  onSelectAll: () {
                    if (selectedCount > 0) {
                      _toggleSelectAll(false, sortedRows);
                    } else {
                      _toggleSelectAll(true, sortedRows);
                    }
                  },
                ),

                // 2. Dynamic Scrollable Rows List or 12 Shimmer Skeletons
                Flexible(
                  fit: FlexFit.loose,
                  child: widget.isLoading
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return _buildSkeletonRow(
                                context, theme, colors, orderedColumns);
                          },
                        )
                      : sortedRows.isEmpty
                          ? Container(
                              padding: EdgeInsets.all(32 * theme.scaling),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    shad.LucideIcons.inbox,
                                    size: 32 * theme.scaling,
                                    color: colors.mutedForeground,
                                  ),
                                  const shad.DensityGap(shad.gapMd),
                                  Text(
                                    'No records found',
                                    style: theme.typography.p.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'No items match the current search or filters.',
                                    style: theme.typography.small.copyWith(
                                      color: colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: sortedRows.length,
                              itemBuilder: (context, index) {
                                final row = sortedRows[index];
                                final isExpanded =
                                    _expandedRowIds.contains(row.id);

                                return _buildRowTree(
                                  row: row,
                                  columns: orderedColumns,
                                  isExpanded: isExpanded,
                                );
                              },
                            ),
                ),

                // 3. Sticky Summary Totals Footer Row (if provided)
                if (widget.summaryTotals != null)
                  DyTableFooter(
                    columns: orderedColumns,
                    summaryTotals: widget.summaryTotals!,
                  ),
              ],
            ),
          ),
        ),

        const shad.DensityGap(shad.gapMd),

        // Standalone 44px Pagination Footer Row
        DyPaginationRow(
          currentPage: widget.pageIndex,
          totalRecords: widget.totalRecords > 0
              ? widget.totalRecords
              : sortedRows.length,
          selectedCount: widget.selectedRowIds.isNotEmpty
              ? widget.selectedRowIds.length
              : _internalSelectedRowIds.length,
          onPageChanged: widget.onPageChanged,
        ),
      ],
    );
  }

  Widget _buildSkeletonRow(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
    List<DyTableColumnSpec> columns,
  ) {
    return Container(
      height: 36 * theme.scaling,
      padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54 * theme.scaling,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 24 * theme.scaling),
                Container(
                  width: 16 * theme.scaling,
                  height: 16 * theme.scaling,
                  decoration: BoxDecoration(
                    color: colors.muted.withAlpha(120),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ...columns.map((col) {
            return Expanded(
              flex: col.flex,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6 * theme.scaling),
                child: Container(
                  height: 14 * theme.scaling,
                  decoration: BoxDecoration(
                    color: colors.muted.withAlpha(120),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
          SizedBox(width: 72 * theme.scaling),
        ],
      ),
    );
  }

  Widget _buildRowTree({
    required DyTableRowData row,
    required List<DyTableColumnSpec> columns,
    required bool isExpanded,
  }) {
    final isSelected = widget.selectedRowIds.contains(row.id) || _internalSelectedRowIds.contains(row.id);
    final effectiveRow = row.copyWith(isSelected: isSelected);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Master Row Renderer by RowType
        if (row.rowType == DyTableRowType.group)
          DyTableGroupRow(
            rowData: effectiveRow,
            columns: columns,
            isExpanded: isExpanded,
            onToggleExpand: () => _toggleRowExpansion(row.id),
          )
        else if (row.rowType == DyTableRowType.def)
          DyTableDefRow(
            rowData: effectiveRow,
            columns: columns,
            isExpanded: isExpanded,
            showTrailingActions: widget.showTrailingActions,
            onSelect: (val) => _toggleRowSelection(row.id, val),
            onToggleExpand: () => _toggleRowExpansion(row.id),
          )
        else
          DyTableChildRow(
            rowData: effectiveRow,
            columns: columns,
          ),

        // Render Expanded Children (if expanded and has children)
        if (isExpanded && row.hasChildren) ...[
          if (row.children.every((c) => c.rowType == DyTableRowType.child)) ...[
            DyTableSubheaderRow(
              columns: row.childColumns ?? columns,
            ),
            for (int i = 0; i < row.children.length; i++)
              DyTableChildRow(
                rowData: row.children[i],
                columns: row.childColumns ?? columns,
                isLastChild: i == row.children.length - 1,
              ),
          ] else ...[
            for (final childRow in row.children)
              _buildRowTree(
                row: childRow,
                columns: row.childColumns ?? columns,
                isExpanded: _expandedRowIds.contains(childRow.id),
              ),
          ],
        ],
      ],
    );
  }
}
