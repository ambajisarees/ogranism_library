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
  });

  @override
  State<DyTable> createState() => _DyTableState();
}

class _DyTableState extends State<DyTable> {
  final Set<String> _expandedRowIds = {};
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

  /// Sorts columns to ensure text columns are at start and numerical columns at end
  List<DyTableColumnSpec> _getOrderedColumns() {
    final textCols = widget.columns.where((c) => !c.isNumeric).toList();
    final numCols = widget.columns.where((c) => c.isNumeric).toList();
    return [...textCols, ...numCols];
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final orderedColumns = _getOrderedColumns();
    final isAllSelected = widget.rows.isNotEmpty &&
        widget.rows.every((r) => widget.selectedRowIds.contains(r.id));
    final isAllExpanded = widget.rows.isNotEmpty &&
        _expandedRowIds.length == widget.rows.length;

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
                  isAllSelected: isAllSelected,
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
                  onSelectAll: (val) {
                    if (widget.onSelectionChanged != null) {
                      final newSet = <String>{};
                      if (val == true) {
                        for (final r in widget.rows) {
                          newSet.add(r.id);
                        }
                      }
                      widget.onSelectionChanged!(newSet);
                    }
                  },
                ),

                // 2. Dynamic Scrollable Rows List (Shrinks for few rows, scrolls for many)
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.rows.length,
                    itemBuilder: (context, index) {
                      final row = widget.rows[index];
                      final isExpanded = _expandedRowIds.contains(row.id);

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

        const shad.DensityGap(shad.gapSm),

        // Standalone 44px Pagination Footer Row
        DyPaginationRow(
          currentPage: widget.pageIndex,
          totalRecords: widget.totalRecords > 0 ? widget.totalRecords : widget.rows.length,
          onPageChanged: widget.onPageChanged,
        ),
      ],
    );
  }

  Widget _buildRowTree({
    required DyTableRowData row,
    required List<DyTableColumnSpec> columns,
    required bool isExpanded,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Master Row Renderer by RowType
        if (row.rowType == DyTableRowType.group)
          DyTableGroupRow(
            rowData: row,
            columns: columns,
            isExpanded: isExpanded,
            onToggleExpand: () => _toggleRowExpansion(row.id),
          )
        else if (row.rowType == DyTableRowType.def)
          DyTableDefRow(
            rowData: row,
            columns: columns,
            isExpanded: isExpanded,
            onSelect: (val) {
              if (widget.onSelectionChanged != null) {
                final newSet = Set<String>.from(widget.selectedRowIds);
                if (val == true) {
                  newSet.add(row.id);
                } else {
                  newSet.remove(row.id);
                }
                widget.onSelectionChanged!(newSet);
              }
            },
            onToggleExpand: () => _toggleRowExpansion(row.id),
          )
        else
          DyTableChildRow(
            rowData: row,
            columns: columns,
            onSelect: (val) {
              if (widget.onSelectionChanged != null) {
                final newSet = Set<String>.from(widget.selectedRowIds);
                if (val == true) {
                  newSet.add(row.id);
                } else {
                  newSet.remove(row.id);
                }
                widget.onSelectionChanged!(newSet);
              }
            },
          ),

        // Render Expanded Children (if expanded and has children)
        if (isExpanded && row.hasChildren)
          for (final child in row.children)
            DyTableChildRow(
              rowData: child,
              columns: columns,
              onSelect: (val) {
                if (widget.onSelectionChanged != null) {
                  final newSet = Set<String>.from(widget.selectedRowIds);
                  if (val == true) {
                    newSet.add(child.id);
                  } else {
                    newSet.remove(child.id);
                  }
                  widget.onSelectionChanged!(newSet);
                }
              },
            ),
      ],
    );
  }
}
