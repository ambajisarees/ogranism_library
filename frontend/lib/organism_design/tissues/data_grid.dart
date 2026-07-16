import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../theme.dart';

/// [TissueDataGrid] — The Core ERP Engine Data Grid
/// Wrapper around PlutoGrid themed for the Organism Design System.
/// Supports keyboard navigation, inline editing, sorting, and freezing.
class TissueDataGrid extends StatelessWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final void Function(PlutoGridOnLoadedEvent)? onLoaded;
  final void Function(PlutoGridOnChangedEvent)? onChanged;
  final void Function(PlutoGridOnRowCheckedEvent)? onRowChecked;
  final PlutoGridMode mode;

  const TissueDataGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.onLoaded,
    this.onChanged,
    this.onRowChecked,
    this.mode = PlutoGridMode.normal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final borderColor = colors.border;
    final primaryColor = colors.primary;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: borderColor),
        borderRadius: OrganismTheme.borderMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: onLoaded,
        onChanged: onChanged,
        onRowChecked: onRowChecked,
        mode: mode,
        configuration: PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            gridBackgroundColor: colors.surface,
            gridBorderColor: borderColor,
            borderColor: borderColor,
            activatedColor: colors.primarySubtle,
            activatedBorderColor: primaryColor,
            checkedColor: colors.primarySubtle,
            cellColorInEditState: colors.surface,
            cellColorInReadOnlyState: colors.background,
            columnTextStyle: OrganismTheme.labelMedium(context).copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            cellTextStyle: OrganismTheme.tabularNumStyle(context),
            enableRowColorAnimation: false,
            menuBackgroundColor: colors.surface,
            enableColumnBorderVertical: false,
            enableColumnBorderHorizontal: true,
            enableCellBorderVertical: false,
            enableCellBorderHorizontal: true,
            rowHeight: 44,
            columnHeight: 44,
          ),
          scrollbar: PlutoGridScrollbarConfig(
            scrollbarThickness: 6,
            scrollbarRadius: const Radius.circular(4),
            scrollBarColor: colors.borderSubtle,
          ),
        ),
      ),
    );
  }
}
