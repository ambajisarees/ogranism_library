/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC 4-REGION SHELL (dy_regions_canvas.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized modular 4-Region building blocks (`DyMetricsRegion`, `DyDataRegion`,
     `DyTasksRegion`, `DyReportsRegion`, `DyEmptyRegionCard`) powering all ERP
     modules on top of `DyLandingCanvas` and `DyFormCanvas`.
   - Re-exports `dy_module_blank_landing.dart` (`DyModuleBlankLanding`,
     `DyModuleLandingConfig`, `showDyLegacyOverlay`, and `Masters*` aliases) so
     every screen module imports one unified shell entry point.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Enforces gap-compensated Base-12 geometry via `DyGridSystem.spanWidth` for KPI rows
     (`3-3-3-3`, `4-4-4`, `6-3-3`, `5-4-3`, `7-3-2`) and Expanded Metrics charts.
   - Supports progressive `6 -> 10` column switching inside `DyDataRegion`, plus
     `table`, `list`, `cards`, and `board` view modes with clean zero-record states.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Pure native `shadcn_flutter` tokens only (`colors.*`, `theme.typography.*`,
     `theme.density.*`, `shad.DensityGap`).
   - All badge chips wrap in `Focus(canRequestFocus: false, skipTraversal: true,
     descendantsAreFocusable: false)` per `GEMINI.md` Rule 8.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Module screens progressively replace `DyModuleBlankLanding` with dedicated
     `scr_<mns>_regions.dart` + `scr_<mns>_form.dart` during Phase 2 backend wiring.
================================================================================
*/

library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../micro/cards/dy_grid_card.dart';
import '../micro/cards/dy_kanban_item.dart';
import '../micro/cards/dy_kpi_metric_card.dart';
import '../micro/cards/dy_list_item.dart';
import '../micro/charts/dy_donut_breakdown_card.dart';
import '../micro/charts/dy_horizontal_bar_card.dart';
import '../micro/charts/dy_trend_area_chart.dart';
import '../page/dy_card_pane.dart';
import '../page/dy_details_pane.dart';
import '../page/dy_kanban_pane.dart';
import '../page/dy_list_pane.dart';
import '../page/dy_table.dart';
import '../specs/dy_color_system.dart';
import '../specs/dy_grid_system.dart';

export 'dy_module_blank_landing.dart';

/// Descriptor for a single KPI tile in Region 1 (`Metrics`).
class DyRegionKpiSpec {
  final String title;
  final String value;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final DyKpiTone tone;
  final int colSpan;
  final List<double>? sparklineValues;

  const DyRegionKpiSpec({
    required this.title,
    this.value = '0',
    required this.subtitle,
    this.badgeText = 'Blank',
    this.icon = shad.LucideIcons.activity,
    this.tone = DyKpiTone.primary,
    this.colSpan = DyGridSystem.flexBoard4PaneEqual,
    this.sparklineValues,
  });
}

/// Descriptor for a task card in Region 3 (`Tasks`).
class DyRegionTaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String queue;
  final String badgeText;
  final DyKpiTone tone;

  const DyRegionTaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.queue,
    required this.badgeText,
    this.tone = DyKpiTone.primary,
  });
}

/// Standardized bordered empty-state card inside `DyRegionsCanvas`.
class DyEmptyRegionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DyEmptyRegionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;

    return shad.OutlinedContainer(
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderWidth: 1.0,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: EdgeInsets.all(16 * scaling),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22 * scaling, color: colors.mutedForeground),
            const shad.DensityGap(shad.gapSm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
            const shad.DensityGap(shad.gapXs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Region 1 (`Metrics`): Gap-compensated Base-12 KPI row collapsed; adds
/// `DyTrendAreaChart` and `DyDonutBreakdownCard` when zoomed (`Shift+1`).
class DyMetricsRegion extends StatelessWidget {
  final List<DyRegionKpiSpec> kpis;
  final int? selectedKpiIndex;
  final ValueChanged<int> onKpiSelected;
  final bool isExpanded;
  final String trendTitle;
  final String trendSubtitle;
  final String primarySeriesLabel;
  final String secondarySeriesLabel;
  final List<String> trendModeLabels;
  final int selectedTrendMode;
  final ValueChanged<int>? onTrendModeChanged;
  final List<DyTrendPoint> trendPoints;
  final String donutTitle;
  final String donutSubtitle;
  final String donutCenterLabel;
  final String donutCenterValue;
  final List<DyDonutSlice> donutSlices;
  final int trendColSpan;

  const DyMetricsRegion({
    super.key,
    required this.kpis,
    required this.selectedKpiIndex,
    required this.onKpiSelected,
    this.isExpanded = false,
    this.trendTitle = 'Module Activity',
    this.trendSubtitle = 'Awaiting synced records',
    this.primarySeriesLabel = 'Created',
    this.secondarySeriesLabel = 'Updated',
    this.trendModeLabels = const ['Count', 'Verified'],
    this.selectedTrendMode = 0,
    this.onTrendModeChanged,
    this.trendPoints = const [
      DyTrendPoint(label: 'Jul', primaryValue: 0, secondaryValue: 0),
      DyTrendPoint(label: 'Aug', primaryValue: 0, secondaryValue: 0),
      DyTrendPoint(label: 'Sep', primaryValue: 0, secondaryValue: 0),
      DyTrendPoint(label: 'Oct', primaryValue: 0, secondaryValue: 0),
      DyTrendPoint(label: 'Nov', primaryValue: 0, secondaryValue: 0),
    ],
    this.donutTitle = 'Distribution',
    this.donutSubtitle = 'Status Mix',
    this.donutCenterLabel = 'Records',
    this.donutCenterValue = '0',
    this.donutSlices = const [
      DyDonutSlice(
        label: 'No Data Yet',
        value: 1,
        formattedValue: '0',
        paletteIndex: 2,
      ),
    ],
    this.trendColSpan = DyGridSystem.flexGoldenMaster,
  });

  Widget _buildCard(int i) => DyKpiMetricCard(
        title: kpis[i].title,
        value: kpis[i].value,
        subtitle: kpis[i].subtitle,
        badgeText: kpis[i].badgeText,
        icon: kpis[i].icon,
        tone: kpis[i].tone,
        sparklineValues: kpis[i].sparklineValues,
        isSelected: selectedKpiIndex == i,
        onTap: () => onKpiSelected(i),
      );

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final gap = theme.density.baseGap * theme.scaling * shad.gapMd;

    final kpiGrid = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520 * theme.scaling) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < kpis.length; i++) ...[
                if (i > 0) const shad.DensityGap(shad.gapMd),
                _buildCard(i),
              ],
            ],
          );
        }

        if (constraints.maxWidth < 900 * theme.scaling) {
          final itemW = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (int i = 0; i < kpis.length; i++)
                SizedBox(width: itemW, child: _buildCard(i)),
            ],
          );
        }

        final totalSpan = kpis.fold<int>(0, (sum, k) => sum + k.colSpan);
        final useExactGrid =
            totalSpan == DyGridSystem.flexBase && kpis.length > 1;

        return Row(
          children: [
            for (int i = 0; i < kpis.length; i++) ...[
              if (i > 0) const shad.DensityGap(shad.gapMd),
              if (useExactGrid && i < kpis.length - 1)
                SizedBox(
                  width: DyGridSystem.spanWidth(
                    totalWidth: constraints.maxWidth,
                    span: kpis[i].colSpan,
                    gap: gap,
                  ),
                  child: _buildCard(i),
                )
              else
                Expanded(child: _buildCard(i)),
            ],
          ],
        );
      },
    );

    if (!isExpanded) return kpiGrid;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16 * theme.scaling),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          kpiGrid,
          const shad.DensityGap(shad.gapMd),
          LayoutBuilder(
            builder: (context, constraints) {
              final trendCard = DyTrendAreaChart(
                title: trendTitle,
                subtitle: trendSubtitle,
                primarySeriesLabel: primarySeriesLabel,
                secondarySeriesLabel: secondarySeriesLabel,
                modeLabels: trendModeLabels,
                selectedModeIndex: selectedTrendMode,
                onModeChanged: onTrendModeChanged,
                chartHeight: 220,
                points: trendPoints,
              );

              final donutCard = DyDonutBreakdownCard(
                title: donutTitle,
                subtitle: donutSubtitle,
                centerLabel: donutCenterLabel,
                centerValue: donutCenterValue,
                slices: donutSlices,
              );

              if (constraints.maxWidth < 920 * theme.scaling) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    trendCard,
                    const shad.DensityGap(shad.gapMd),
                    donutCard,
                  ],
                );
              }

              final donutSpan =
                  (DyGridSystem.flexBase - trendColSpan).clamp(1, 11);
              final donutWidth = DyGridSystem.spanWidth(
                totalWidth: constraints.maxWidth,
                span: donutSpan,
                gap: gap,
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: trendCard),
                  const shad.DensityGap(shad.gapMd),
                  SizedBox(width: donutWidth, child: donutCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Region 2 (`Data`): Progressive `6 -> 10` column `DyTable` plus `list`,
/// `cards`, and `board` view modes with clean blank states.
class DyDataRegion extends StatelessWidget {
  final String entityPlural;
  final String targetTable;
  final IconData emptyIcon;
  final String viewMode;
  final bool isExpanded;
  final bool isLoading;
  final List<DyTableColumnSpec> collapsedColumns;
  final List<DyTableColumnSpec> expandedColumns;
  final List<DyTableRowData> rows;
  final int? totalRecords;
  final int pageIndex;
  final int pageSize;
  final ValueChanged<int>? onPageChanged;
  final Set<String> selectedRowIds;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final ValueChanged<DyTableRowData>? onEditRow;
  final bool showTrailingActions;
  final Map<String, String>? summaryTotals;
  final List<DynamicListItem> listItems;
  final DynamicListItem? selectedListItem;
  final ValueChanged<DynamicListItem?>? onListItemSelected;
  final List<DyGridItem> gridItems;
  final DyGridItem? selectedGridItem;
  final ValueChanged<DyGridItem?>? onGridItemSelected;
  final List<DyKanbanItem> kanbanItems;
  final List<({String title, Color color})> kanbanStages;
  final Widget Function(
    BuildContext context,
    DynamicListItem? listItem,
    DyGridItem? gridItem,
  )? detailsBuilder;

  const DyDataRegion({
    super.key,
    required this.entityPlural,
    required this.targetTable,
    this.emptyIcon = shad.LucideIcons.database,
    this.viewMode = 'table',
    this.isExpanded = false,
    this.isLoading = false,
    required this.collapsedColumns,
    required this.expandedColumns,
    this.rows = const [],
    this.totalRecords,
    this.pageIndex = 1,
    this.pageSize = 50,
    this.onPageChanged,
    this.selectedRowIds = const {},
    this.onSelectionChanged,
    this.onEditRow,
    this.showTrailingActions = true,
    this.summaryTotals,
    this.listItems = const [],
    this.selectedListItem,
    this.onListItemSelected,
    this.gridItems = const [],
    this.selectedGridItem,
    this.onGridItemSelected,
    this.kanbanItems = const [],
    this.kanbanStages = const [],
    this.detailsBuilder,
  });

  Widget _buildInspector(
    BuildContext context,
    DynamicListItem? listItem,
    DyGridItem? gridItem,
  ) {
    if (detailsBuilder != null) {
      return detailsBuilder!(context, listItem, gridItem);
    }
    return DyDetailsPane(
      title: listItem?.title ?? gridItem?.title ?? 'No Selection',
      subtitle: listItem?.subtitle ?? gridItem?.partyName,
      metadata: {
        'Table': targetTable,
        'Entity': entityPlural,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    if (viewMode == 'list' && listItems.isNotEmpty) {
      final active = selectedListItem ?? listItems.first;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: DyGridSystem.fixedListMasterWidth * theme.scaling,
            child: DyListPane(
              items: listItems,
              selectedItem: active,
              onItemSelected: (item) => onListItemSelected?.call(item),
            ),
          ),
          const shad.DensityGap(shad.gapMd),
          Expanded(child: _buildInspector(context, active, null)),
        ],
      );
    }

    if (viewMode == 'cards' && gridItems.isNotEmpty) {
      final active = selectedGridItem ?? gridItems.first;
      return LayoutBuilder(
        builder: (context, constraints) {
          final gap = theme.density.baseGap * theme.scaling * shad.gapMd;
          final inspectorW = DyGridSystem.spanWidth(
            totalWidth: constraints.maxWidth,
            span: DyGridSystem.flexCardsInspector,
            gap: gap,
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DyCardPane(
                  items: gridItems,
                  selectedItem: active,
                  onItemSelected: (item) => onGridItemSelected?.call(item),
                  totalRecords: totalRecords ?? gridItems.length,
                  currentPage: pageIndex,
                  onPageChanged: onPageChanged,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              SizedBox(
                width: inspectorW,
                child: _buildInspector(context, null, active),
              ),
            ],
          );
        },
      );
    }

    if (viewMode == 'board' &&
        kanbanItems.isNotEmpty &&
        kanbanStages.isNotEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < kanbanStages.length; i++) ...[
            if (i > 0) const shad.DensityGap(shad.gapMd),
            Expanded(
              child: DyKanbanPane(
                stageTitle: kanbanStages[i].title,
                stageColor: kanbanStages[i].color,
                items: kanbanItems
                    .where((item) => item.status == kanbanStages[i].title)
                    .toList(),
                onItemSelected: (_) {},
              ),
            ),
          ],
        ],
      );
    }

    if (viewMode != 'table') {
      return DyEmptyRegionCard(
        icon: emptyIcon,
        title: 'No $entityPlural records yet',
        subtitle:
            '${viewMode.toUpperCase()} view ready for $targetTable. Use Add [N] to stage an entry.',
      );
    }

    final table = DyTable(
      columns: isExpanded ? expandedColumns : collapsedColumns,
      rows: rows,
      isLoading: isLoading,
      totalRecords: totalRecords ?? rows.length,
      pageIndex: pageIndex,
      pageSize: pageSize,
      onPageChanged: onPageChanged,
      selectedRowIds: selectedRowIds,
      onSelectionChanged: onSelectionChanged,
      onEditRow: onEditRow,
      showTrailingActions: showTrailingActions,
      summaryTotals: summaryTotals ??
          {
            collapsedColumns.first.key: 'TOTAL (${rows.length} $entityPlural)',
          },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = (isExpanded ? 920 : 620) * theme.scaling;
        if (constraints.maxWidth >= minWidth || !constraints.hasBoundedHeight) {
          return table;
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(constraints.maxWidth, minWidth),
            height: constraints.maxHeight,
            child: table,
          ),
        );
      },
    );
  }
}

Color _resolveRegionToneColor(DyKpiTone? tone, Color fallback) {
  switch (tone) {
    case DyKpiTone.danger:
      return DyColorSystem.red500;
    case DyKpiTone.warning:
      return DyColorSystem.orange500;
    case DyKpiTone.success:
      return DyColorSystem.emerald500;
    case DyKpiTone.indigo:
      return DyColorSystem.indigo500;
    case DyKpiTone.cyan:
      return DyColorSystem.cyan500;
    case DyKpiTone.pink:
    case DyKpiTone.fuchsia:
      return DyColorSystem.pink500;
    case DyKpiTone.primary:
    case null:
      return fallback;
  }
}

/// Region 3 (`Tasks`): Scrollable operational queue with quick Done/Resolve button
/// or clean zero-task empty state.
class DyTasksRegion extends StatelessWidget {
  final List<DyRegionTaskItem> tasks;
  final String activeQueueLabel;
  final String targetTable;
  final String searchQuery;
  final bool isExpanded;
  final ValueChanged<String>? onResolveTask;

  const DyTasksRegion({
    super.key,
    this.tasks = const [],
    required this.activeQueueLabel,
    required this.targetTable,
    this.searchQuery = '',
    this.isExpanded = false,
    this.onResolveTask,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      final filterNote = searchQuery.trim().isNotEmpty
          ? ' • Matching "${searchQuery.trim()}"'
          : '';
      return DyEmptyRegionCard(
        icon: shad.LucideIcons.listChecks,
        title: 'Zero $activeQueueLabel Tasks',
        subtitle: 'Pending governance tasks for $targetTable$filterNote.',
      );
    }

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = colors.brightness == Brightness.dark;

    return shad.OutlinedContainer(
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderWidth: 1.0,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: EdgeInsets.all(8 * scaling),
      child: ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const shad.DensityGap(shad.gapSm),
        itemBuilder: (context, idx) {
          final task = tasks[idx];
          final accent = _resolveRegionToneColor(task.tone, colors.primary);

          return shad.OutlinedContainer(
            backgroundColor: DyColorSystem.resolveSurfaceCanvas(isDark),
            borderColor: colors.border,
            borderWidth: 1.0,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            padding: EdgeInsets.symmetric(
              horizontal: 10 * scaling,
              vertical: 8 * scaling,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.xSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.foreground,
                              ),
                            ),
                          ),
                          const shad.DensityGap(shad.gapXs),
                          Focus(
                            canRequestFocus: false,
                            skipTraversal: true,
                            descendantsAreFocusable: false,
                            child: shad.SecondaryBadge(
                              child: Text(
                                task.badgeText,
                                style: theme.typography.xSmall.copyWith(
                                  fontSize: 10 * scaling,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const shad.DensityGap(shad.gapXs),
                      Text(
                        task.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: onResolveTask == null
                      ? null
                      : () => onResolveTask!(task.id),
                  child: Text(isExpanded ? 'Mark Resolved' : 'Done'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Region 4 (`Reports`): Compact progress pivot bars collapsed, and full
/// `DyHorizontalBarCard` + summary `DyTable` when expanded (`Shift+4`).
class DyReportsRegion extends StatelessWidget {
  final String lensLabel;
  final String targetTable;
  final bool isExpanded;
  final List<DyBarMetricItem> items;
  final ValueChanged<DyBarMetricItem>? onItemTap;

  const DyReportsRegion({
    super.key,
    required this.lensLabel,
    required this.targetTable,
    this.isExpanded = false,
    this.items = const [],
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;

    if (items.isEmpty) {
      final summaryCard = DyEmptyRegionCard(
        icon: shad.LucideIcons.chartColumn,
        title: '$lensLabel Report (0 Records)',
        subtitle: 'Analytics breakdown will populate from $targetTable.',
      );

      if (!isExpanded) return summaryCard;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          summaryCard,
          const shad.DensityGap(shad.gapMd),
          Expanded(
            child: DyTable(
              columns: const [
                DyTableColumnSpec(key: 'bucket', label: 'Group / Bucket', flex: 3),
                DyTableColumnSpec(
                  key: 'count',
                  label: 'Records',
                  flex: 1,
                  isNumeric: true,
                ),
                DyTableColumnSpec(
                  key: 'complete',
                  label: 'Verified %',
                  flex: 1,
                  isNumeric: true,
                ),
                DyTableColumnSpec(key: 'status', label: 'Health', flex: 2),
              ],
              rows: const [],
              totalRecords: 0,
              showTrailingActions: false,
            ),
          ),
        ],
      );
    }

    if (isExpanded) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16 * scaling),
        child: DyHorizontalBarCard(
          title: '$lensLabel Pivot Breakdown',
          subtitle: 'Interactive module breakdown sourced from $targetTable',
          items: items,
          onItemTap: onItemTap,
        ),
      );
    }

    double maxRaw = 1.0;
    for (final it in items) {
      maxRaw = math.max(maxRaw, it.rawValue);
    }

    return shad.OutlinedContainer(
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderWidth: 1.0,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: EdgeInsets.all(10 * scaling),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const shad.DensityGap(shad.gapSm),
        itemBuilder: (context, idx) {
          final item = items[idx];
          final progress = (item.rawValue / maxRaw).clamp(0.0, 1.0);
          final barColor =
              _resolveRegionToneColor(item.tone, DyColorSystem.cyan500);

          return GestureDetector(
            onTap: onItemTap == null ? null : () => onItemTap!(item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.xSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      item.formattedValue,
                      style: theme.typography.xSmall
                          .merge(theme.typography.mono)
                          .copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.foreground,
                          ),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapXs),
                shad.LinearProgressIndicator(
                  value: progress,
                  theme: shad.LinearProgressIndicatorTheme(
                    color: barColor,
                    backgroundColor: colors.muted,
                    minHeight: 5 * scaling,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
