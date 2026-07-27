import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Specification model for configuring a data table column.
class DynamicTableColumnSpec {
  final String label;
  final String key;
  final bool isSortable;
  final int flex;
  final double? width;
  final Alignment alignment;

  const DynamicTableColumnSpec({
    required this.label,
    required this.key,
    this.isSortable = true,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

/// Data model representing a table row entry.
class DynamicTableRowData {
  final String id;
  final String voucherNo;
  final String partyName;
  final String designPattern;
  final String quantity;
  final String amount;
  final double amountValue;
  final String status;
  final String? expandedDetails;
  final String? thumbnailUrl;
  final List<String> imageUrls;
  final Map<String, dynamic>? rawData;

  const DynamicTableRowData({
    required this.id,
    required this.voucherNo,
    required this.partyName,
    required this.designPattern,
    required this.quantity,
    required this.amount,
    required this.amountValue,
    required this.status,
    this.expandedDetails,
    this.thumbnailUrl,
    this.imageUrls = const [],
    this.rawData,
  });
}

/// Reusable ERP Dense Data Table Page-Level Component
class DynamicDenseTable extends StatefulWidget {
  final List<DynamicTableColumnSpec> columns;
  final List<DynamicTableRowData> rows;
  final Set<String> selectedRowIds;
  final bool enableExpansion;
  final Color? headerBackgroundColor;
  final bool showSummaryRow;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final Function(String sortKey, bool isAsc)? onSortChanged;
  final ValueChanged<DynamicTableRowData>? onRowTap;
  final String? initialSortKey;
  final bool initialSortAscending;
  final bool isLoading;
  final int? totalRecords;
  final ValueChanged<int>? onPageChanged;
  final int currentPage;

  const DynamicDenseTable({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedRowIds = const {},
    this.enableExpansion = false,
    this.headerBackgroundColor,
    this.showSummaryRow = true,
    this.onSelectionChanged,
    this.onSortChanged,
    this.onRowTap,
    this.initialSortKey,
    this.initialSortAscending = true,
    this.isLoading = false,
    this.totalRecords,
    this.onPageChanged,
    this.currentPage = 1,
  });

  @override
  State<DynamicDenseTable> createState() => _DynamicDenseTableState();
}

class _DynamicDenseTableState extends State<DynamicDenseTable> {
  int _currentPage = 1;
  late Set<String> _selectedIds;
  int _expandedIndex = -1;
  String? _activeSortKey;
  bool _isAscending = true;
  final Map<String, bool> _hoveredHeaders = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
    _selectedIds = Set.from(widget.selectedRowIds);
    _activeSortKey = widget.initialSortKey;
    _isAscending = widget.initialSortAscending;
  }

  @override
  void didUpdateWidget(covariant DynamicDenseTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      _currentPage = widget.currentPage;
    }
    if (widget.selectedRowIds != oldWidget.selectedRowIds) {
      _selectedIds = Set.from(widget.selectedRowIds);
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == widget.rows.length) {
        _selectedIds.clear();
      } else {
        _selectedIds = widget.rows.map((r) => r.id).toSet();
      }
    });
    widget.onSelectionChanged?.call(_selectedIds);
  }

  void _toggleRowSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    widget.onSelectionChanged?.call(_selectedIds);
  }

  void _handleHeaderSort(DynamicTableColumnSpec col) {
    if (!col.isSortable) return;

    setState(() {
      if (_activeSortKey == col.key) {
        _isAscending = !_isAscending;
      } else {
        _activeSortKey = col.key;
        _isAscending = true;
      }
    });

    widget.onSortChanged?.call(col.key, _isAscending);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;
    final defaultHeaderFooterBg =
        isDark ? const Color(0xFF141210) : const Color(0xFFFCFDFE);
    final isAllSelected =
        widget.rows.isNotEmpty && _selectedIds.length == widget.rows.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isBounded = constraints.maxHeight.isFinite;

        Widget rowsContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isLoading)
              ...List.generate(6, (index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSkeletonRow(context, theme, colors),
                    shad.Divider(color: colors.border),
                  ],
                );
              })
            else if (widget.rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No voucher records available',
                      style: theme.typography.textMuted),
                ),
              )
            else
              ...List.generate(widget.rows.length, (index) {
                final row = widget.rows[index];
                final isSelected = _selectedIds.contains(row.id);
                final isExpanded = _expandedIndex == index;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.enableExpansion) {
                          setState(() {
                            _expandedIndex = isExpanded ? -1 : index;
                          });
                        }
                        widget.onRowTap?.call(row);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        color: isSelected ? colors.primary.withAlpha(20) : null,
                        child: Row(
                          children: [
                            // LEADING EXPAND ICON
                            if (widget.enableExpansion) ...[
                              SizedBox(
                                width: 24,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _expandedIndex = isExpanded ? -1 : index;
                                    });
                                  },
                                  child: Icon(
                                    isExpanded
                                        ? shad.LucideIcons.chevronDown
                                        : shad.LucideIcons.chevronRight,
                                    size: 16,
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],

                            // Checkbox
                            SizedBox(
                              width: 32,
                              child: shad.Checkbox(
                                state: isSelected
                                    ? shad.CheckboxState.checked
                                    : shad.CheckboxState.unchecked,
                                onChanged: (_) => _toggleRowSelection(row.id),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Row Data Cells
                            ...widget.columns.map((col) => _buildRowCell(
                                context, col, row, isExpanded, index)),
                          ],
                        ),
                      ),
                    ),

                    // Accordion Expansion Row Details (Optional)
                    if (widget.enableExpansion && isExpanded)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(80),
                        child: Row(
                          children: [
                            Icon(shad.LucideIcons.cornerDownRight,
                                size: 16, color: colors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                row.expandedDetails ??
                                    'Expanded Details: Grey Fabric Lot #${row.voucherNo.replaceAll(RegExp(r'[^0-9]'), '')} • Station: Surat Warehouse • Dispatcher: Ambaji ERP Operator',
                                style: theme.typography.xSmall,
                              ),
                            ),
                          ],
                        ),
                      ),

                    shad.Divider(color: colors.border),
                  ],
                );
              }),
          ],
        );

        if (isBounded) {
          rowsContent = Flexible(
            child: SingleChildScrollView(
              child: rowsContent,
            ),
          );
        }

        return shad.OutlinedContainer(
          borderColor: colors.border,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. HEADER ROW (Same vertical padding as data rows: horizontal 16, vertical 10, Slate 10 token #FCFDFE)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: widget.headerBackgroundColor ?? defaultHeaderFooterBg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leading Expand Chevron Column (Only if expansion enabled)
                    if (widget.enableExpansion) ...[
                      const SizedBox(width: 24),
                      const SizedBox(width: 8),
                    ],

                    // Select All Checkbox
                    SizedBox(
                      width: 32,
                      child: shad.Checkbox(
                        state: isAllSelected
                            ? shad.CheckboxState.checked
                            : _selectedIds.isNotEmpty
                                ? shad.CheckboxState.indeterminate
                                : shad.CheckboxState.unchecked,
                        onChanged: (_) => _toggleSelectAll(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Dynamic Column Headers
                    ...widget.columns.map((col) => _buildHeaderCell(context, col)),
                  ],
                ),
              ),
              shad.Divider(color: colors.border),

              // 2. DATA ROWS (Flexible & Scrollable if bounded, else natural Column)
              rowsContent,
              // 3. TABLE FOOTER ROW (3 Areas: Record/Selection Counter, Numerical Column Computations, Compact 2-Button Pagination)
              shad.Divider(color: colors.border),
              _buildTableFooterRow(context, theme, colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(BuildContext context, DynamicTableColumnSpec col) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final isSorted = _activeSortKey == col.key;
    final isHovered = _hoveredHeaders[col.key] ?? false;

    // Hide text label for actions column or if label is empty/ACTIONS
    final isActionsCol =
        col.key == 'actions' || col.label.toUpperCase() == 'ACTIONS';
    final labelText = isActionsCol ? '' : col.label.toUpperCase();

    Widget cellChild;

    if (col.isSortable && !isActionsCol) {
      // SORTABLE HEADER LOGIC:
      // Default: Grey muted text token (colors.mutedForeground).
      // Active Sorted: Black token (colors.foreground) + Bold, Icon direction changes ONLY. Zero primary color tint.
      // Hover: Occupies full header row height (36px) with 8px radius token (theme.radiusMd).
      cellChild = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredHeaders[col.key] = true),
        onExit: (_) => setState(() => _hoveredHeaders[col.key] = false),
        child: GestureDetector(
          onTap: () => _handleHeaderSort(col),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isHovered ? colors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(theme.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    labelText,
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: isSorted ? FontWeight.bold : FontWeight.w600,
                      color:
                          isSorted ? colors.foreground : colors.mutedForeground,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isSorted
                      ? (_isAscending
                          ? shad.LucideIcons.arrowUp
                          : shad.LucideIcons.arrowDown)
                      : shad.LucideIcons.arrowUpDown,
                  size: 12,
                  color: isSorted ? colors.foreground : colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      cellChild = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          labelText,
          style: theme.typography.xSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.mutedForeground,
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }

    final alignWidget = Align(
      alignment: col.alignment,
      child: cellChild,
    );

    if (col.width != null) {
      return SizedBox(width: col.width, child: alignWidget);
    }

    return Expanded(
      flex: col.flex,
      child: alignWidget,
    );
  }

  String _truncateToTwoWords(String input) {
    final words = input.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) return input;
    return '${words[0]} ${words[1]}';
  }

  Widget _buildSkeletonRow(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.enableExpansion) ...[
            const SizedBox(width: 24),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 32,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors.muted.withAlpha(150),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ...widget.columns.map((col) {
            final child = Align(
              alignment: col.alignment,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: col.width != null ? (col.width! * 0.5) : 50,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.muted.withAlpha(150),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );

            if (col.width != null) {
              return SizedBox(width: col.width, child: child);
            }
            return Expanded(flex: col.flex, child: child);
          }),
        ],
      ),
    );
  }

  Widget _buildRowCell(
    BuildContext context,
    DynamicTableColumnSpec col,
    DynamicTableRowData row,
    bool isExpanded,
    int rowIndex,
  ) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    Widget childContent;

    switch (col.key.toLowerCase()) {
      case 'vno':
      case 'voucherno':
      case 'ccno':
      case 'cc_no':
        final rawVno = row.rawData?['ccno']?.toString() ?? row.voucherNo;
        final ccText = rawVno.replaceAll(RegExp(r'[^0-9]'), '');

        childContent = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showImageGalleryOverlay(context, row),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    border: Border.all(color: colors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildThumbnailWidget(row, theme, colors),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                ccText,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.mono.copyWith(
                  fontSize: 13 * theme.scaling,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
        break;

      case 'cutdate':
      case 'date':
        final dateText = row.rawData?['cutdate']?.toString() ?? '';
        childContent = Text(
          dateText,
          style: theme.typography.textSmall,
        );
        break;

      case 'mill':
      case 'party':
      case 'partyname':
        final rawMill = row.rawData?['mill']?.toString() ?? row.partyName;
        childContent = Text(
          _truncateToTwoWords(rawMill),
          style:
              theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
        );
        break;

      case 'quality':
      case 'greyqual':
      case 'design':
      case 'designpattern':
        final rawQual = row.rawData?['quality']?.toString() ?? row.designPattern;
        childContent = Text(
          rawQual,
          overflow: TextOverflow.ellipsis,
          style:
              theme.typography.xSmall.copyWith(color: colors.mutedForeground),
        );
        break;

      case 'cutlength':
        final lenText = row.rawData?['cutlength']?.toString() ?? '';
        childContent = Text(
          lenText,
          style: theme.typography.mono.copyWith(
            fontSize: 13 * theme.scaling,
            fontWeight: FontWeight.w500,
          ),
        );
        break;

      case 'freshpcs':
      case 'qty':
      case 'quantity':
        final pcsText = row.rawData?['freshpcs']?.toString() ?? row.quantity;
        childContent = Text(
          pcsText,
          style: theme.typography.mono.copyWith(
            fontSize: 13 * theme.scaling,
            fontWeight: FontWeight.w500,
          ),
        );
        break;

      case 'costperpc':
      case 'amount':
        final costText = row.rawData?['costperpc']?.toString() ?? row.amount;
        childContent = Text(
          costText,
          style: theme.typography.mono.copyWith(
            fontSize: 13 * theme.scaling,
            fontWeight: FontWeight.w500,
          ),
        );
        break;

      case 'freshpct':
        final pctText = row.rawData?['freshpct']?.toString() ?? '';
        childContent = Text(
          pctText,
          style: theme.typography.mono.copyWith(
            fontSize: 13 * theme.scaling,
            fontWeight: FontWeight.w500,
          ),
        );
        break;

      case 'status':
        childContent = _buildStatusBadge(row.status);
        break;

      case 'actions':
        childContent = shad.IconButton.ghost(
          size: shad.ButtonSize.small,
          icon: const Icon(shad.LucideIcons.ellipsis, size: 14),
          onPressed: () {
            shad.showToast(
              context: context,
              builder: (context, show) => shad.Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Actions for ${row.voucherNo}'),
                ),
              ),
            );
          },
        );
        break;

      default:
        childContent = Text(
          row.rawData?[col.key]?.toString() ?? '',
          style: theme.typography.textSmall,
        );
        break;
    }

    final alignWidget = Align(
      alignment: col.alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: childContent,
      ),
    );

    if (col.width != null) {
      return SizedBox(width: col.width, child: alignWidget);
    }

    return Expanded(
      flex: col.flex,
      child: alignWidget,
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const shad.PrimaryBadge(child: Text('Completed'));
      case 'IN_PROCESS':
      case 'IN PROCESS':
        return const shad.SecondaryBadge(child: Text('In Process'));
      case 'PENDING':
      default:
        return const shad.OutlineBadge(child: Text('Pending'));
    }
  }

  Widget _buildTableFooterRow(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final totalCount = widget.totalRecords ?? widget.rows.length;
    final displayedCount = widget.rows.length;
    final selectedCount = _selectedIds.length;

    final startIdx = displayedCount > 0 ? (_currentPage - 1) * 50 + 1 : 0;
    final endIdx = (_currentPage - 1) * 50 + displayedCount;

    final recordText = selectedCount > 0
        ? '$selectedCount of ${_formatNumber(totalCount)} Selected'
        : '$startIdx-$endIdx of ${_formatNumber(totalCount)} Records';

    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final defaultHeaderFooterBg =
        isDark ? const Color(0xFF141210) : const Color(0xFFFCFDFE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: widget.headerBackgroundColor ?? defaultHeaderFooterBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading Expand Chevron Column Spacer (if expansion enabled)
          if (widget.enableExpansion) ...[
            const SizedBox(width: 24),
            const SizedBox(width: 8),
          ],

          // Select All Checkbox Alignment Spacer
          const SizedBox(width: 32),
          const SizedBox(width: 12),

          // 1:1 Column Alignment Mapping for Footer Row (Merging Col 0 & Col 1 for Record Text)
          ...List.generate(widget.columns.length, (index) {
            if (index == 1 && widget.columns.length >= 2) {
              return const SizedBox.shrink();
            }

            final col = widget.columns[index];
            Widget? footerCellChild;
            double? cellWidth = col.width;
            int cellFlex = col.flex;

            if (index == 0 && widget.columns.length >= 2) {
              final col1 = widget.columns[1];
              if (col.width != null || col1.width != null) {
                cellWidth = (col.width ?? 0.0) + (col1.width ?? 0.0);
              } else {
                cellFlex = col.flex + col1.flex;
              }

              footerCellChild = Text(
                recordText,
                maxLines: 1,
                softWrap: false,
                style: theme.typography.textSmall.copyWith(
                  fontWeight:
                      selectedCount > 0 ? FontWeight.bold : FontWeight.normal,
                  color: colors.foreground,
                ),
              );
            } else {
              final key = col.key.toLowerCase();
              if (key == 'qty' || key == 'quantity' || key == 'freshpcs') {
                final computation = _computeColumnStat(col);
                if (computation != null) {
                  footerCellChild = Text(
                    computation,
                    style: theme.typography.mono.copyWith(
                      fontSize: 13 * theme.scaling,
                      fontWeight: FontWeight.w500,
                      color: colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                }
              } else if (key == 'amount' || key == 'costperpc') {
                final computation = _computeColumnStat(col);
                if (computation != null) {
                  footerCellChild = Text(
                    computation,
                    style: theme.typography.mono.copyWith(
                      fontSize: 13 * theme.scaling,
                      fontWeight: FontWeight.w500,
                      color: colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                }
              } else if (key == 'freshpct') {
                final computation = _computeColumnStat(col);
                if (computation != null) {
                  footerCellChild = Text(
                    computation,
                    style: theme.typography.mono.copyWith(
                      fontSize: 13 * theme.scaling,
                      fontWeight: FontWeight.w500,
                      color: colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                }
              } else if (key == 'actions' || (key == 'status' && !widget.columns.any((c) => c.key.toLowerCase() == 'actions'))) {
                final canPrev = _currentPage > 1;
                final canNext = (_currentPage * 50) < totalCount;

                footerCellChild = Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      icon: const Icon(shad.LucideIcons.chevronLeft, size: 16),
                      onPressed: canPrev
                          ? () {
                              setState(() => _currentPage--);
                              widget.onPageChanged?.call(_currentPage);
                            }
                          : null,
                    ),
                    const SizedBox(width: 4),
                    shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      icon: const Icon(shad.LucideIcons.chevronRight, size: 16),
                      onPressed: canNext
                          ? () {
                              setState(() => _currentPage++);
                              widget.onPageChanged?.call(_currentPage);
                            }
                          : null,
                    ),
                  ],
                );
              }
            }

            final alignWidget = Align(
              alignment: index == 0 ? Alignment.centerLeft : col.alignment,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: footerCellChild ?? const SizedBox.shrink(),
              ),
            );

            if (cellWidth != null && cellWidth > 0) {
              return SizedBox(width: cellWidth, child: alignWidget);
            }

            return Expanded(
              flex: cellFlex,
              child: alignWidget,
            );
          }),
        ],
      ),
    );
  }

  String? _computeColumnStat(DynamicTableColumnSpec col) {
    if (widget.rows.isEmpty) return null;

    final key = col.key.toLowerCase();
    if (key == 'qty' || key == 'quantity') {
      double totalMeters = 0.0;
      for (final r in widget.rows) {
        final numVal =
            double.tryParse(r.quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                0.0;
        totalMeters += numVal;
      }
      return _formatNumber(totalMeters.round());
    }

    if (key == 'freshpcs') {
      int totalPcs = 0;
      for (final r in widget.rows) {
        final rawVal = r.rawData?['freshpcs_num'] ?? r.rawData?['freshpcs'] ?? r.quantity;
        final numVal = (rawVal is num)
            ? rawVal.toInt()
            : int.tryParse(rawVal.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        totalPcs += numVal;
      }
      return _formatNumber(totalPcs);
    }

    if (key == 'amount') {
      double totalAmount = 0.0;
      for (final r in widget.rows) {
        totalAmount += r.amountValue;
      }
      return '₹${_formatNumber(totalAmount.round())}';
    }

    if (key == 'costperpc') {
      double totalCost = 0.0;
      int count = 0;
      for (final r in widget.rows) {
        final rawVal = r.rawData?['costperpc_num'] ?? r.amountValue;
        final numVal = (rawVal is num) ? rawVal.toDouble() : 0.0;
        if (numVal > 0) {
          totalCost += numVal;
          count++;
        }
      }
      final avgCost = count > 0 ? totalCost / count : 0.0;
      return '₹${avgCost.toStringAsFixed(2)}';
    }

    if (key == 'freshpct') {
      double totalPct = 0.0;
      int count = 0;
      for (final r in widget.rows) {
        final rawVal = r.rawData?['freshpct_num'];
        final numVal = (rawVal is num) ? rawVal.toDouble() : 0.0;
        if (numVal > 0) {
          totalPct += numVal;
          count++;
        }
      }
      final avgPct = count > 0 ? totalPct / count : 0.0;
      return '${avgPct.toStringAsFixed(1)}%';
    }

    return null;
  }

  String _formatNumber(int val) {
    return val.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildThumbnailWidget(
    DynamicTableRowData row,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    if (row.thumbnailUrl != null && row.thumbnailUrl!.isNotEmpty) {
      return Image.network(
        row.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackThumbnailIcon(colors),
      );
    }
    if (row.imageUrls.isNotEmpty) {
      return Image.network(
        row.imageUrls.first,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackThumbnailIcon(colors),
      );
    }
    return _buildFallbackThumbnailIcon(colors);
  }

  Widget _buildFallbackThumbnailIcon(shad.ColorScheme colors) {
    return Container(
      color: colors.primary.withAlpha(25),
      child: Center(
        child: Icon(shad.LucideIcons.image, size: 14, color: colors.primary),
      ),
    );
  }

  void _showImageGalleryOverlay(BuildContext context, DynamicTableRowData row) {
    showDialog(
      context: context,
      builder: (context) {
        return _FabricImageGalleryDialog(row: row);
      },
    );
  }
}

class _FabricImageGalleryDialog extends StatefulWidget {
  final DynamicTableRowData row;

  const _FabricImageGalleryDialog({required this.row});

  @override
  State<_FabricImageGalleryDialog> createState() =>
      _FabricImageGalleryDialogState();
}

class _FabricImageGalleryDialogState
    extends State<_FabricImageGalleryDialog> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final images = widget.row.imageUrls.isNotEmpty
        ? widget.row.imageUrls
        : (widget.row.thumbnailUrl != null
            ? [widget.row.thumbnailUrl!]
            : <String>[]);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(theme.radiusLg),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(shad.LucideIcons.scissors, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fabric Design Gallery • ${widget.row.voucherNo}',
                        style: theme.typography.textLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Party: ${widget.row.partyName} • Pattern: ${widget.row.designPattern}',
                        style: theme.typography.xSmall
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                shad.IconButton.ghost(
                  icon: const Icon(shad.LucideIcons.x, size: 16),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const shad.Divider(),
            const SizedBox(height: 12),

            // Main Featured Image Preview
            Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(color: colors.border),
                color: colors.muted,
              ),
              clipBehavior: Clip.antiAlias,
              child: images.isNotEmpty
                  ? Image.network(
                      images[_selectedImageIndex],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildLargeFallbackPreview(colors, theme, widget.row),
                    )
                  : _buildLargeFallbackPreview(colors, theme, widget.row),
            ),
            const SizedBox(height: 16),

            // Thumbnail Selector Carousel (If multiple images exist)
            if (images.length > 1) ...[
              Text(
                'Related Saree Fabric Photos (${images.length})',
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedImageIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImageIndex = index),
                      child: Container(
                        width: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colors.muted,
                            child: Center(
                              child: Text('${index + 1}',
                                  style: theme.typography.textSmall),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metadata Footer Badges
            Row(
              children: [
                shad.PrimaryBadge(child: Text('Qty: ${widget.row.quantity}')),
                const SizedBox(width: 8),
                shad.SecondaryBadge(child: Text('Value: ${widget.row.amount}')),
                const Spacer(),
                shad.OutlineButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeFallbackPreview(
    shad.ColorScheme colors,
    shad.ThemeData theme,
    DynamicTableRowData row,
  ) {
    return Container(
      color: colors.primary.withAlpha(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(shad.LucideIcons.scissors, size: 48, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'High-Res Fabric Preview (${row.designPattern})',
              style: theme.typography.textSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Saree Lot #${row.voucherNo.replaceAll(RegExp(r'[^\d]'), '')} • ${row.partyName}',
              style:
                  theme.typography.xSmall.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
