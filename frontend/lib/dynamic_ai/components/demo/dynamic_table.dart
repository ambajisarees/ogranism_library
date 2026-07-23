import 'package:flutter/material.dart' hide Card, TableRow, TableCell;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Column definition for [DynamicTable].
class DynamicTableColumn<T> {
  final Widget header;
  final shad.TableSize size;
  final bool isNumeric;
  final Widget Function(BuildContext context, T item, int index) cellBuilder;
  final Widget Function(BuildContext context)? footerBuilder;

  const DynamicTableColumn({
    required this.header,
    this.size = const shad.FlexTableSize(flex: 1.0),
    this.isNumeric = false,
    required this.cellBuilder,
    this.footerBuilder,
  });

  /// Helper factory for simple text headers.
  factory DynamicTableColumn.text({
    required String title,
    shad.TableSize size = const shad.FlexTableSize(flex: 1.0),
    bool isNumeric = false,
    required Widget Function(BuildContext context, T item, int index) cellBuilder,
    Widget Function(BuildContext context)? footerBuilder,
  }) {
    return DynamicTableColumn<T>(
      header: Text(title),
      size: size,
      isNumeric: isNumeric,
      cellBuilder: cellBuilder,
      footerBuilder: footerBuilder,
    );
  }
}

/// Dynamic, native data table component built on native `shadcn_flutter` table primitives.
/// Guarantees 100% full height canvas expansion and native `shad.Pagination`.
class DynamicTable<T> extends StatelessWidget {
  final List<DynamicTableColumn<T>> columns;
  final List<T> items;
  final bool selectable;
  final Set<int> selectedIndices;
  final ValueChanged<Set<int>>? onSelectionChanged;
  final bool isLoading;
  final Widget? emptyPlaceholder;
  final bool showFooter;
  final Widget? customFooterBar;

  // Pagination parameters
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  const DynamicTable({
    super.key,
    required this.columns,
    required this.items,
    this.selectable = false,
    this.selectedIndices = const {},
    this.onSelectionChanged,
    this.isLoading = false,
    this.emptyPlaceholder,
    this.showFooter = false,
    this.customFooterBar,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPageChanged,
    this.showPagination = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    if (isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * shad.padLg),
          child: const shad.CircularProgressIndicator(),
        ),
      );
    }

    if (items.isEmpty) {
      return emptyPlaceholder ??
          Center(
            child: Padding(
              padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * shad.padLg),
              child: Text(
                'No data available.',
                style: theme.typography.textLarge.copyWith(color: colors.mutedForeground),
              ),
            ),
          );
    }

    // Build Column Widths map
    final Map<int, shad.TableSize> columnWidthsMap = {};
    int colIndexOffset = 0;

    if (selectable) {
      columnWidthsMap[0] = const shad.FixedTableSize(44);
      colIndexOffset = 1;
    }

    for (int i = 0; i < columns.length; i++) {
      columnWidthsMap[i + colIndexOffset] = columns[i].size;
    }

    // Build Table Header
    final headerCells = <shad.TableCell>[];

    if (selectable) {
      final allSelected = items.isNotEmpty && selectedIndices.length == items.length;
      headerCells.add(
        _buildCell(
          theme,
          colors,
          shad.Checkbox(
            state: allSelected
                ? shad.CheckboxState.checked
                : (selectedIndices.isNotEmpty
                    ? shad.CheckboxState.indeterminate
                    : shad.CheckboxState.unchecked),
            onChanged: (val) {
              if (onSelectionChanged == null) return;
              if (allSelected) {
                onSelectionChanged!({});
              } else {
                onSelectionChanged!(Set.from(List.generate(items.length, (i) => i)));
              }
            },
          ),
        ),
      );
    }

    for (final col in columns) {
      headerCells.add(
        _buildHeaderCell(theme, colors, col.header, col.isNumeric),
      );
    }

    // Build Table Rows
    final tableRows = <shad.TableRow>[
      shad.TableHeader(cells: headerCells),
    ];

    for (int index = 0; index < items.length; index++) {
      final item = items[index];
      final isSelected = selectedIndices.contains(index);
      final rowCells = <shad.TableCell>[];

      if (selectable) {
        rowCells.add(
          _buildCell(
            theme,
            colors,
            shad.Checkbox(
              state: isSelected ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
              onChanged: (val) {
                if (onSelectionChanged == null) return;
                final newSet = Set<int>.from(selectedIndices);
                if (isSelected) {
                  newSet.remove(index);
                } else {
                  newSet.add(index);
                }
                onSelectionChanged!(newSet);
              },
            ),
          ),
        );
      }

      for (final col in columns) {
        rowCells.add(
          _buildCell(
            theme,
            colors,
            col.cellBuilder(context, item, index),
            isNumeric: col.isNumeric,
          ),
        );
      }

      tableRows.add(shad.TableRow(cells: rowCells));
    }

    // Build Native TableFooter if enabled
    if (showFooter) {
      final footerCells = <shad.TableCell>[];

      if (selectable) {
        footerCells.add(_buildCell(theme, colors, const SizedBox.shrink()));
      }

      for (final col in columns) {
        final footerChild = col.footerBuilder?.call(context) ?? const SizedBox.shrink();
        footerCells.add(_buildCell(theme, colors, footerChild, isNumeric: col.isNumeric, isBold: true));
      }

      tableRows.add(shad.TableFooter(cells: footerCells));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table canvas stretching to 100% full vertical height
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: shad.Table(
                      columnWidths: columnWidthsMap,
                      rows: tableRows,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Custom Footer Bar or Native Table Footer Utility Strip
        if (customFooterBar != null) customFooterBar!,

        // Native Pagination Footer Control Strip
        if (showPagination) ...[
          const shad.Divider(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.density.baseContainerPadding * theme.scaling * shad.padSm,
              vertical: theme.density.baseGap * theme.scaling * shad.gapSm,
            ),
            child: Row(
              children: [
                if (selectable && selectedIndices.isNotEmpty)
                  Text(
                    '${selectedIndices.length} of ${items.length} row(s) selected',
                    style: theme.typography.textSmall.copyWith(
                      color: colors.mutedForeground,
                    ),
                  )
                else
                  Text(
                    'Showing ${items.length} records',
                    style: theme.typography.textSmall.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                const Spacer(),
                shad.Pagination(
                  page: currentPage,
                  totalPages: totalPages,
                  onPageChanged: onPageChanged ?? (p) {},
                  showLabel: false,
                  maxPages: 3,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static shad.TableCell _buildHeaderCell(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    Widget content,
    bool isNumeric,
  ) {
    Widget child = DefaultTextStyle(
      style: theme.typography.textSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: colors.foreground,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: content,
    );

    if (isNumeric) {
      child = Align(
        alignment: Alignment.centerRight,
        child: child,
      );
    }

    return shad.TableCell(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.density.baseContainerPadding * theme.scaling * shad.padSm,
          vertical: theme.density.baseGap * theme.scaling * shad.gapSm,
        ),
        child: child,
      ),
    );
  }

  static shad.TableCell _buildCell(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    Widget content, {
    bool isNumeric = false,
    bool isBold = false,
  }) {
    Widget child = DefaultTextStyle(
      style: theme.typography.textSmall.copyWith(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: colors.foreground,
      ),
      child: content,
    );

    if (isNumeric) {
      child = Align(
        alignment: Alignment.centerRight,
        child: child,
      );
    }

    return shad.TableCell(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.density.baseContainerPadding * theme.scaling * shad.padSm,
          vertical: theme.density.baseGap * theme.scaling * shad.gapSm,
        ),
        child: child,
      ),
    );
  }
}
