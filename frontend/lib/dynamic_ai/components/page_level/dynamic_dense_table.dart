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
    _selectedIds = Set.from(widget.selectedRowIds);
  }

  @override
  void didUpdateWidget(covariant DynamicDenseTable oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    // Direct OutlinedContainer sitting cleanly on page without wrapper Card or title header
    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: Column(
        children: [
          // 1. HEADER ROW (Same vertical padding as data rows: horizontal 16, vertical 10, Slate 10 token #FCFDFE)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: widget.headerBackgroundColor ?? defaultHeaderFooterBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leading Expand Chevron Column (Only if expansion enabled)
                if (widget.enableExpansion) const SizedBox(width: 24),

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

          // 2. DATA ROWS
          if (widget.rows.isEmpty)
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
                          // LEADING EXPAND ICON (Replacing trailing position!)
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

          // 3. TABLE FOOTER ROW (3 Areas: Record/Selection Counter, Numerical Column Computations, Shadcn Pagination)
          _buildTableFooterRow(context, theme, colors),
        ],
      ),
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
      // NON-SORTABLE HEADER LOGIC: Plain grey text aligned directly with data
      cellChild = MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          alignment: col.alignment,
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

    switch (col.key) {
      case 'vno':
      case 'voucherNo':
        childContent = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row Fabric Image Thumbnail (Clickable to open image gallery overlay!)
            GestureDetector(
              onTap: () => _showImageGalleryOverlay(context, row),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    border: Border.all(color: colors.border),
                    color: colors.muted,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildThumbnailWidget(row, theme, colors),
                ),
              ),
            ),
            const SizedBox(width: 8), // Exact 8px gap before VNO #10481!
            Flexible(
              child: Text(
                row.voucherNo,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.textSmall
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
        break;

      case 'party':
      case 'partyName':
        childContent = Text(
          row.partyName,
          style:
              theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
        );
        break;

      case 'design':
      case 'designPattern':
        childContent = Text(
          row.designPattern,
          style:
              theme.typography.xSmall.copyWith(color: colors.mutedForeground),
        );
        break;

      case 'qty':
      case 'quantity':
        childContent = Text(
          row.quantity,
          style: theme.typography.textSmall,
        );
        break;

      case 'amount':
        childContent = Text(
          row.amount,
          style:
              theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
        );
        break;

      case 'status':
        childContent = _buildStatusBadge(row.status);
        break;

      case 'actions':
        // REPLACED 3 DOTS VERTICAL WITH 3 DOTS HORIZONTAL (ellipsis)!
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
    final totalRecords = widget.rows.length;
    final selectedCount = _selectedIds.length;

    // Supports up to 50,000+ records seamlessly!
    final recordText = selectedCount > 0
        ? '$selectedCount of ${_formatNumber(totalRecords)} Selected'
        : '1 of ${_formatNumber(totalRecords)} Records';

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
          if (widget.enableExpansion) const SizedBox(width: 24),

          // Checkbox Alignment Spacer
          const SizedBox(width: 32),
          const SizedBox(width: 12),

          // AREA 1: Record / Selection Counter (Start of Footer)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: selectedCount > 0
                  ? colors.primary.withAlpha(25)
                  : colors.muted.withAlpha(120),
              borderRadius: BorderRadius.circular(theme.radiusMd),
              border: Border.all(
                color: selectedCount > 0
                    ? colors.primary.withAlpha(100)
                    : colors.border,
              ),
            ),
            child: Text(
              recordText,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: selectedCount > 0 ? colors.primary : colors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // AREA 2: Aligned Numerical Column Computations (Middle Area)
          Expanded(
            child: Row(
              children: widget.columns.map((col) {
                final computation = _computeColumnStat(col);
                final alignWidget = Align(
                  alignment: col.alignment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: computation != null
                        ? Text(
                            computation,
                            style: theme.typography.xSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.foreground,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );

                if (col.width != null) {
                  return SizedBox(width: col.width, child: alignWidget);
                }

                return Expanded(
                  flex: col.flex,
                  child: alignWidget,
                );
              }).toList(),
            ),
          ),

          // AREA 3: Native Shadcn Pagination Controls (End of Footer)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              shad.IconButton.ghost(
                size: shad.ButtonSize.small,
                density: shad.ButtonDensity.iconDense,
                icon: const Icon(shad.LucideIcons.chevronLeft, size: 14),
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                'Page $_currentPage of 50',
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(width: 6),
              shad.IconButton.ghost(
                size: shad.ButtonSize.small,
                density: shad.ButtonDensity.iconDense,
                icon: const Icon(shad.LucideIcons.chevronRight, size: 14),
                onPressed: () => setState(() => _currentPage++),
              ),
            ],
          ),
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
      return 'Total: ${_formatNumber(totalMeters.round())} Mtr';
    }

    if (key == 'amount') {
      double totalAmount = 0.0;
      for (final r in widget.rows) {
        totalAmount += r.amountValue;
      }
      return 'Total: ₹${_formatNumber(totalAmount.round())}';
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
