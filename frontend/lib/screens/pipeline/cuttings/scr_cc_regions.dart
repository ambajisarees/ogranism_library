/*
================================================================================
LLM CONTEXT & QUERY SPACE — CUTTING CARDS LIVE REGIONS (scr_cc_regions.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Domain-specific 4-Region Bento components (`ScrCcMetricsPane`, `ScrCcDataPane`,
     `ScrCcTasksPane`, `ScrCcReportsPane`) for Multi-Cutting Cards (`cc`, nav index `6`).
   - Adapts live `List<MdlCcHeader>` and `MdlCcMetrics` from `SrvCc` (`sb_cutdet_summary`
     + `sb_cutdet`) into `DyMetricsRegion`, `DyDataRegion`, `DyTasksRegion`, and
     `DyReportsRegion` inside `DyLandingCanvas`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Table Columns match `MdlCcHeader.toDyDefRowData()` keys (`vno`, `date`,
     `partyName`, `designPattern`, `cutLength`, `quantity`, `freshPct`, `rate`,
     `amount`, `status`) with progressive `6 -> 10` column expansion.
   - Supports 3-tiered `DyTable` grouping (`None`, `Mill`, `Quality`), `List`
     + child cut-line inspector (`DyDetailsPane`), `Cards`, and `Board` views.
   - Tasks queue surfaces batches with shrinkage `> 10%`, low yield `< 80%`,
     or missing scanned physical cutting card (`!c.hasCardPic`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Uses gap-compensated Base-12 sizing via `DyRegionsCanvas`.
   - `sb_cutdet_summary.sb_cardpic` null rate ~75%, surfaced gracefully in the
     `Missing Scan` task queue and card inspector.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Direct image upload to Supabase Storage for missing card scans can plug
     into `ScrCcTasksPane.onResolveTask` in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_grid_card.dart';
import '../../../dynamic_ai/micro/cards/dy_kanban_item.dart';
import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../dynamic_ai/micro/charts/dy_donut_breakdown_card.dart';
import '../../../dynamic_ai/micro/charts/dy_horizontal_bar_card.dart';
import '../../../dynamic_ai/micro/charts/dy_trend_area_chart.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/micro/dab/dab_region_header.dart';
import '../../../dynamic_ai/page/dy_details_pane.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';
import '../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../models/pipeline/mdl_cc.dart';
import '../../../services/pipeline/srv_cc.dart';

/// Column definitions & DAB option metadata for Cutting Cards (`sb_cutdet_summary`).
abstract class ScrCcSpecs {
  static const String targetTable = 'IMMBE2627.sb_cutdet_summary';

  static const List<DyTableColumnSpec> collapsedColumns = [
    DyTableColumnSpec(key: 'vno', label: 'Card #', flex: 1, isPinnedLeft: true),
    DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
    DyTableColumnSpec(key: 'partyName', label: 'Mill / Process House', flex: 2),
    DyTableColumnSpec(key: 'designPattern', label: 'Quality', flex: 2),
    DyTableColumnSpec(key: 'quantity', label: 'Output / Mtrs', flex: 2),
    DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
  ];

  static const List<DyTableColumnSpec> expandedColumns = [
    DyTableColumnSpec(key: 'vno', label: 'Card #', flex: 1, isPinnedLeft: true),
    DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
    DyTableColumnSpec(key: 'partyName', label: 'Mill / Process House', flex: 2),
    DyTableColumnSpec(key: 'designPattern', label: 'Quality', flex: 2),
    DyTableColumnSpec(key: 'cutLength', label: 'Cut Spec', flex: 1),
    DyTableColumnSpec(key: 'quantity', label: 'Output / Mtrs', flex: 2),
    DyTableColumnSpec(key: 'freshPct', label: 'Yield %', flex: 1, isNumeric: true),
    DyTableColumnSpec(key: 'rate', label: 'Cost/Pc', flex: 1, isNumeric: true),
    DyTableColumnSpec(key: 'amount', label: 'Investment', flex: 1, isNumeric: true),
    DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
  ];

  static const List<String> statusOptions = ['Completed', 'Pending'];

  static const List<DabGroupOption> groupOptions = [
    DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
    DabGroupOption(id: 'mill', label: 'Mill', icon: shad.LucideIcons.factory),
    DabGroupOption(id: 'quality', label: 'Quality', icon: shad.LucideIcons.shirt),
  ];

  static const List<String> taskQueues = ['All', 'High Shrinkage', 'Missing Scan'];
  static const List<String> reportLenses = ['By Mill', 'By Quality', 'Yield Slabs'];

  static String formatCompactInr(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    }
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L';
    }
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)} K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

/// Region 1 (`Metrics`) pane hydrated from `SrvCc` metrics + active batches.
class ScrCcMetricsPane extends StatelessWidget {
  final DabTimeHorizon horizon;
  final List<MdlCcHeader> cards;
  final MdlCcMetrics metrics;
  final int totalCount;
  final int? selectedKpiIndex;
  final ValueChanged<int> onKpiSelected;
  final bool isExpanded;
  final int trendMode;
  final ValueChanged<int> onTrendModeChanged;

  const ScrCcMetricsPane({
    super.key,
    required this.horizon,
    required this.cards,
    required this.metrics,
    required this.totalCount,
    required this.selectedKpiIndex,
    required this.onKpiSelected,
    required this.isExpanded,
    required this.trendMode,
    required this.onTrendModeChanged,
  });

  List<MdlCcHeader> _horizonCards() {
    final now = DateTime.now();
    switch (horizon) {
      case DabTimeHorizon.thisYear:
        return cards;
      case DabTimeHorizon.thisMonth:
        final cutoff = DateTime(now.year, now.month, 1);
        return cards.where((c) => !c.cutDate.isBefore(cutoff)).toList();
      case DabTimeHorizon.thisWeek:
        final cutoff = now.subtract(const Duration(days: 7));
        return cards.where((c) => !c.cutDate.isBefore(cutoff)).toList();
      case DabTimeHorizon.today:
        final cutoff = DateTime(now.year, now.month, now.day);
        return cards.where((c) => !c.cutDate.isBefore(cutoff)).toList();
    }
  }

  List<DyTrendPoint> _buildMonthlyTrend(List<MdlCcHeader> subset) {
    if (subset.isEmpty) {
      return const [
        DyTrendPoint(label: 'Jul', primaryValue: 0, secondaryValue: 0),
        DyTrendPoint(label: 'Aug', primaryValue: 0, secondaryValue: 0),
        DyTrendPoint(label: 'Sep', primaryValue: 0, secondaryValue: 0),
        DyTrendPoint(label: 'Oct', primaryValue: 0, secondaryValue: 0),
        DyTrendPoint(label: 'Nov', primaryValue: 0, secondaryValue: 0),
      ];
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final Map<int, ({String label, double pcs, double mtrs})> buckets = {};
    for (final c in subset) {
      final ym = c.cutDate.year * 100 + c.cutDate.month;
      final label = '${months[c.cutDate.month - 1]} ${c.cutDate.year % 100}';
      final prev = buckets[ym];
      buckets[ym] = (
        label: label,
        pcs: (prev?.pcs ?? 0.0) + c.totalFreshPcs,
        mtrs: (prev?.mtrs ?? 0.0) + c.totalReceivedMeters,
      );
    }
    final keys = buckets.keys.toList()..sort();
    final recent = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;
    return [
      for (final k in recent)
        DyTrendPoint(
          label: buckets[k]!.label,
          primaryValue: trendMode == 0 ? buckets[k]!.pcs : buckets[k]!.mtrs,
          secondaryValue: trendMode == 0 ? buckets[k]!.mtrs : buckets[k]!.pcs,
        ),
    ];
  }

  List<DyDonutSlice> _buildYieldSlices(List<MdlCcHeader> subset) {
    int high = 0;
    int normal = 0;
    int low = 0;
    for (final c in subset) {
      if (c.freshYieldPct >= 85.0) {
        high++;
      } else if (c.freshYieldPct >= 80.0) {
        normal++;
      } else {
        low++;
      }
    }
    if (high + normal + low == 0) {
      return const [
        DyDonutSlice(
          label: 'No Batches',
          value: 1,
          formattedValue: '0',
          paletteIndex: 2,
        ),
      ];
    }
    return [
      DyDonutSlice(
        label: 'High (>=85%)',
        value: high.toDouble(),
        formattedValue: '$high',
        paletteIndex: 1,
      ),
      DyDonutSlice(
        label: 'Normal (80-85%)',
        value: normal.toDouble(),
        formattedValue: '$normal',
        paletteIndex: 0,
      ),
      DyDonutSlice(
        label: 'Low (<80%)',
        value: low.toDouble(),
        formattedValue: '$low',
        paletteIndex: 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final subset = _horizonCards();
    final useGlobal = horizon == DabTimeHorizon.thisYear && metrics.totalFreshPcs > 0;

    final int batchCount = useGlobal ? (totalCount > 0 ? totalCount : subset.length) : subset.length;
    final double recMtrs = useGlobal
        ? metrics.totalReceivedMeters
        : subset.fold<double>(0.0, (s, c) => s + c.totalReceivedMeters);
    final int freshPcs = useGlobal
        ? metrics.totalFreshPcs
        : subset.fold<int>(0, (s, c) => s + c.totalFreshPcs);
    final double avgYield = useGlobal
        ? metrics.avgFreshYieldPct
        : (subset.isEmpty
            ? 0.0
            : subset.fold<double>(0.0, (s, c) => s + c.freshYieldPct) / subset.length);
    final double avgCost = useGlobal
        ? metrics.avgCostPerPc
        : (subset.isEmpty
            ? 0.0
            : subset.fold<double>(0.0, (s, c) => s + c.costPerPc) / subset.length);
    final double totalInv = useGlobal
        ? metrics.totalInvestment
        : subset.fold<double>(0.0, (s, c) => s + c.totalInvestment);
    final double avgShrink = useGlobal
        ? metrics.avgShortagePct
        : (subset.isEmpty
            ? 0.0
            : subset.fold<double>(0.0, (s, c) => s + c.shortagePct) / subset.length);

    final trendPts = _buildMonthlyTrend(subset);
    final sparkPcs = trendPts.map((p) => p.primaryValue).toList();
    final intFmt = NumberFormat.decimalPattern('en_IN');

    final kpis = [
      DyRegionKpiSpec(
        title: 'CUTTING BATCHES',
        value: intFmt.format(batchCount),
        subtitle: '${intFmt.format(recMtrs.round())} Mtrs received',
        badgeText: horizon.label,
        icon: shad.LucideIcons.scissors,
        tone: DyKpiTone.primary,
        sparklineValues: sparkPcs.length >= 2 ? sparkPcs : null,
      ),
      DyRegionKpiSpec(
        title: 'FRESH SAREE YIELD',
        value: '${avgYield.toStringAsFixed(1)}%',
        subtitle: 'Benchmark target >= 85.0%',
        badgeText: avgYield >= 85.0 ? 'On SLA' : 'Below SLA',
        icon: shad.LucideIcons.percent,
        tone: avgYield >= 85.0 ? DyKpiTone.success : DyKpiTone.warning,
      ),
      DyRegionKpiSpec(
        title: 'FRESH SAREES CUT',
        value: intFmt.format(freshPcs),
        subtitle: 'Avg ₹${avgCost.toStringAsFixed(2)} / Saree',
        badgeText: 'sb_cutdet',
        icon: shad.LucideIcons.layers,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'LANDED INVESTMENT',
        value: ScrCcSpecs.formatCompactInr(totalInv),
        subtitle: 'Avg shrink ${avgShrink.toStringAsFixed(1)}%',
        badgeText: 'Grey + Job',
        icon: shad.LucideIcons.indianRupee,
        tone: DyKpiTone.indigo,
      ),
    ];

    return DyMetricsRegion(
      kpis: kpis,
      selectedKpiIndex: selectedKpiIndex,
      onKpiSelected: onKpiSelected,
      isExpanded: isExpanded,
      trendTitle: 'Cutting Output Trajectory (${horizon.label})',
      trendSubtitle: 'Sourced from ${ScrCcSpecs.targetTable}',
      primarySeriesLabel: trendMode == 0 ? 'Fresh Pcs' : 'Recd Mtrs',
      secondarySeriesLabel: trendMode == 0 ? 'Recd Mtrs' : 'Fresh Pcs',
      trendModeLabels: const ['Fresh Pcs', 'Recd Mtrs'],
      selectedTrendMode: trendMode,
      onTrendModeChanged: onTrendModeChanged,
      trendPoints: trendPts,
      donutTitle: 'Yield Performance Mix',
      donutSubtitle: 'High >=85% • Normal 80-85% • Low <80%',
      donutCenterLabel: 'Batches',
      donutCenterValue: '${subset.length}',
      donutSlices: _buildYieldSlices(subset),
    );
  }
}

/// Region 2 (`Data`) pane rendering live 3-tiered `DyTable`, `List`, `Cards`, and `Board`.
class ScrCcDataPane extends StatelessWidget {
  final List<MdlCcHeader> cards;
  final bool isLoading;
  final bool isExpanded;
  final String viewMode;
  final String groupingMode;
  final int totalRecords;
  final int pageIndex;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final MdlCcHeader? selectedCard;
  final ValueChanged<MdlCcHeader> onSelectCard;
  final ValueChanged<MdlCcHeader> onEditCard;

  const ScrCcDataPane({
    super.key,
    required this.cards,
    required this.isLoading,
    required this.isExpanded,
    required this.viewMode,
    required this.groupingMode,
    required this.totalRecords,
    required this.pageIndex,
    required this.pageSize,
    required this.onPageChanged,
    required this.selectedCard,
    required this.onSelectCard,
    required this.onEditCard,
  });

  List<DyTableRowData> _buildTableRows() {
    if (cards.isEmpty) return const [];
    if (groupingMode == 'none') {
      return cards.map((c) => c.toDyDefRowData()).toList();
    }

    final Map<String, List<MdlCcHeader>> grouped = {};
    for (final c in cards) {
      final key = groupingMode == 'mill' ? c.millName : c.greyQuality;
      grouped.putIfAbsent(key, () => []).add(c);
    }

    final sortedKeys = grouped.keys.toList()..sort();
    return [
      for (final gKey in sortedKeys)
        DyTableRowData(
          id: 'grp_$gKey',
          rowType: DyTableRowType.group,
          voucherNo: gKey,
          partyName: '${grouped[gKey]!.length} batches',
          data: {
            'vno': gKey,
            'partyName': groupingMode == 'mill' ? gKey : '-',
            'designPattern': groupingMode == 'quality' ? gKey : '${grouped[gKey]!.length} batches',
            'quantity':
                '${grouped[gKey]!.fold<int>(0, (s, c) => s + c.totalFreshPcs)} Pcs',
            'amount': ScrCcSpecs.formatCompactInr(
              grouped[gKey]!.fold<double>(0.0, (s, c) => s + c.totalInvestment),
            ),
            'status': '${grouped[gKey]!.length} Cards',
          },
          children: grouped[gKey]!.map((c) => c.toDyDefRowData()).toList(),
        ),
    ];
  }

  Widget _buildStatusBadge(MdlCcHeader c) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      descendantsAreFocusable: false,
      child: c.isCompleted
          ? const shad.PrimaryBadge(child: Text('COMPLETED'))
          : const shad.OutlineBadge(child: Text('PENDING')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildTableRows();
    final totalPcs = cards.fold<int>(0, (s, c) => s + c.totalFreshPcs);
    final totalInv = cards.fold<double>(0.0, (s, c) => s + c.totalInvestment);

    final listItems = [
      for (final c in cards)
        DynamicListItem(
          id: c.id.isNotEmpty ? c.id : c.multiVno.toString(),
          title: c.millName,
          amount: c.formattedTotalInvestment,
          topLeading: _buildStatusBadge(c),
          topTrailing: c.formattedCutDate,
          subtitle: '${c.greyQuality} • ${c.totalFreshPcs} Pcs (${c.formattedFreshYield})',
          indexNumber: c.displayCcCode,
          rawData: c.core.toJson(),
        ),
    ];

    final gridItems = [
      for (final c in cards)
        DyGridItem(
          id: c.id.isNotEmpty ? c.id : c.multiVno.toString(),
          title: c.greyQuality,
          voucherNo: c.displayCcCode,
          partyName: c.millName,
          designPattern: '${c.formattedCutLength} • ${c.formattedFreshYield}',
          quantity: '${c.totalFreshPcs} Pcs',
          amount: c.formattedTotalInvestment,
          statusBadge: _buildStatusBadge(c),
          thumbnailUrl: c.cardPicPath,
          imageUrls: c.core.cardPics,
          rawData: c.core.toJson(),
        ),
    ];

    final kanbanItems = [
      for (final c in cards)
        DyKanbanItem(
          id: c.id.isNotEmpty ? c.id : c.multiVno.toString(),
          title: c.greyQuality,
          voucherNo: c.displayCcCode,
          partyName: c.millName,
          designPattern: c.formattedCutLength,
          quantity: '${c.totalFreshPcs} Pcs (${c.formattedFreshYield})',
          amount: c.formattedTotalInvestment,
          status: c.isCompleted ? 'COMPLETED' : 'PENDING',
          statusBadge: _buildStatusBadge(c),
          rawData: c.core.toJson(),
        ),
    ];

    MdlCcHeader? resolveById(String? id) {
      if (id == null) return null;
      for (final c in cards) {
        final cId = c.id.isNotEmpty ? c.id : c.multiVno.toString();
        if (cId == id) return c;
      }
      return null;
    }

    final activeListItem = selectedCard != null && listItems.isNotEmpty
        ? listItems.firstWhere(
            (i) => i.id == (selectedCard!.id.isNotEmpty ? selectedCard!.id : selectedCard!.multiVno.toString()),
            orElse: () => listItems.first,
          )
        : (listItems.isNotEmpty ? listItems.first : null);

    final activeGridItem = selectedCard != null && gridItems.isNotEmpty
        ? gridItems.firstWhere(
            (i) => i.id == (selectedCard!.id.isNotEmpty ? selectedCard!.id : selectedCard!.multiVno.toString()),
            orElse: () => gridItems.first,
          )
        : (gridItems.isNotEmpty ? gridItems.first : null);

    return DyDataRegion(
      entityPlural: 'Cards',
      targetTable: ScrCcSpecs.targetTable,
      emptyIcon: shad.LucideIcons.scissors,
      viewMode: viewMode,
      isExpanded: isExpanded,
      isLoading: isLoading,
      collapsedColumns: ScrCcSpecs.collapsedColumns,
      expandedColumns: ScrCcSpecs.expandedColumns,
      rows: rows,
      totalRecords: totalRecords,
      pageIndex: pageIndex,
      pageSize: pageSize,
      onPageChanged: onPageChanged,
      onEditRow: (row) {
        final match = resolveById(row.id);
        if (match != null) onEditCard(match);
      },
      summaryTotals: {
        'vno': 'TOTAL (${cards.length} Cards)',
        'quantity': '$totalPcs Pcs',
        'amount': ScrCcSpecs.formatCompactInr(totalInv),
      },
      listItems: listItems,
      selectedListItem: activeListItem,
      onListItemSelected: (item) {
        final match = resolveById(item?.id);
        if (match != null) onSelectCard(match);
      },
      gridItems: gridItems,
      selectedGridItem: activeGridItem,
      onGridItemSelected: (item) {
        final match = resolveById(item?.id);
        if (match != null) onSelectCard(match);
      },
      kanbanItems: kanbanItems,
      kanbanStages: [
        (title: 'PENDING', color: DyColorSystem.orange500),
        (title: 'COMPLETED', color: DyColorSystem.emerald500),
      ],
      detailsBuilder: (ctx, lItem, gItem) {
        final match = resolveById(lItem?.id ?? gItem?.id);
        if (match == null) {
          return const DyDetailsPane(title: 'Select a Cutting Card');
        }
        return DyDetailsPane(
          title: match.displayCcCode,
          subtitle: '${match.millName} • ${match.greyQuality}',
          statusBadge: _buildStatusBadge(match),
          imageUrls: match.core.cardPics,
          metadata: {
            'Cut Date': match.formattedCutDate,
            'Cut Length': match.formattedCutLength,
            'Sent Grey': match.formattedSentGreyMeters,
            'Recd Fabric': match.formattedReceivedMeters,
            'Fresh Pcs': '${match.totalFreshPcs} Pcs (${match.formattedFreshYield})',
            'Second Pcs': '${match.totalSecondPcs} Pcs',
            'Fent Weight': match.formattedFentWeight,
            'Shrinkage %': match.formattedShortagePct,
            'Cost / Saree': match.formattedCostPerPc,
            'Investment': match.formattedTotalInvestment,
          },
          lineItemsTable: match.lineItems.isEmpty
              ? null
              : DyTable(
                  columns: const [
                    DyTableColumnSpec(key: 'vno', label: 'Cut #', flex: 1),
                    DyTableColumnSpec(key: 'partyName', label: 'Weaver / Mill', flex: 2),
                    DyTableColumnSpec(key: 'totalMtrs', label: 'Recd Mtr', flex: 1, isNumeric: true),
                    DyTableColumnSpec(key: 'totalPcs', label: 'Fresh Pcs', flex: 1, isNumeric: true),
                    DyTableColumnSpec(key: 'amount', label: 'Landed ₹', flex: 1, isNumeric: true),
                  ],
                  rows: match.lineItems
                      .map((li) => li.toDyChildRowData(match.displayCcCode))
                      .toList(),
                  totalRecords: match.lineItems.length,
                  showTrailingActions: false,
                ),
          onEdit: () => onEditCard(match),
        );
      },
    );
  }
}

/// Region 3 (`Tasks`) pane surfacing Shrinkage Alerts & Missing Card Scans.
class ScrCcTasksPane extends StatelessWidget {
  final List<MdlCcHeader> cards;
  final int queueIndex;
  final String searchQuery;
  final bool isExpanded;
  final Set<String> dismissedIds;
  final ValueChanged<String> onDismissTask;

  const ScrCcTasksPane({
    super.key,
    required this.cards,
    required this.queueIndex,
    required this.searchQuery,
    required this.isExpanded,
    required this.dismissedIds,
    required this.onDismissTask,
  });

  List<DyRegionTaskItem> _buildTasks() {
    final activeQueue = ScrCcSpecs.taskQueues[
        queueIndex.clamp(0, ScrCcSpecs.taskQueues.length - 1)];
    final q = searchQuery.trim().toLowerCase();
    final List<DyRegionTaskItem> tasks = [];

    for (final c in cards) {
      if (c.shortagePct > 10.0 || (c.freshYieldPct > 0 && c.freshYieldPct < 80.0)) {
        final id = 'shrink_${c.multiVno}';
        if (!dismissedIds.contains(id) &&
            (activeQueue == 'All' || activeQueue == 'High Shrinkage')) {
          final isShrink = c.shortagePct > 10.0;
          tasks.add(
            DyRegionTaskItem(
              id: id,
              title: '${c.displayCcCode} • ${isShrink ? 'Shrink ${c.formattedShortagePct}' : 'Low Yield ${c.formattedFreshYield}'}',
              subtitle: '${c.millName} • ${c.greyQuality}',
              queue: 'High Shrinkage',
              badgeText: isShrink ? 'Shrink >10%' : 'Yield <80%',
              tone: DyKpiTone.danger,
            ),
          );
        }
      }
      if (!c.hasCardPic) {
        final id = 'scan_${c.multiVno}';
        if (!dismissedIds.contains(id) &&
            (activeQueue == 'All' || activeQueue == 'Missing Scan')) {
          tasks.add(
            DyRegionTaskItem(
              id: id,
              title: 'Upload Scan • ${c.displayCcCode}',
              subtitle: '${c.millName} • ${c.formattedCutDate}',
              queue: 'Missing Scan',
              badgeText: 'No Card Pic',
              tone: DyKpiTone.warning,
            ),
          );
        }
      }
      if (tasks.length >= 25) break;
    }

    if (q.isEmpty) return tasks;
    return tasks
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final activeQueue = ScrCcSpecs.taskQueues[
        queueIndex.clamp(0, ScrCcSpecs.taskQueues.length - 1)];

    return DyTasksRegion(
      tasks: _buildTasks(),
      activeQueueLabel: activeQueue,
      targetTable: ScrCcSpecs.targetTable,
      searchQuery: searchQuery,
      isExpanded: isExpanded,
      onResolveTask: onDismissTask,
    );
  }
}

/// Region 4 (`Reports`) pane aggregating Mill, Quality & Yield breakdowns.
class ScrCcReportsPane extends StatelessWidget {
  final List<MdlCcHeader> cards;
  final int lensIndex;
  final bool isExpanded;
  final ValueChanged<DyBarMetricItem>? onItemTap;

  const ScrCcReportsPane({
    super.key,
    required this.cards,
    required this.lensIndex,
    required this.isExpanded,
    this.onItemTap,
  });

  List<DyBarMetricItem> _buildItems() {
    if (cards.isEmpty) return const [];

    if (lensIndex == 2) {
      int high = 0, normal = 0, low = 0;
      for (final c in cards) {
        if (c.freshYieldPct >= 85.0) {
          high++;
        } else if (c.freshYieldPct >= 80.0) {
          normal++;
        } else {
          low++;
        }
      }
      return [
        DyBarMetricItem(
          label: 'High Yield (>=85%)',
          formattedValue: '$high Batches',
          rawValue: high.toDouble(),
          subtitle: 'Target SLA met',
          tone: DyKpiTone.success,
        ),
        DyBarMetricItem(
          label: 'Normal Yield (80-85%)',
          formattedValue: '$normal Batches',
          rawValue: normal.toDouble(),
          subtitle: 'Acceptable tolerance',
          tone: DyKpiTone.cyan,
        ),
        DyBarMetricItem(
          label: 'Low Yield (<80%)',
          formattedValue: '$low Batches',
          rawValue: low.toDouble(),
          subtitle: 'Review shrinkage / fent',
          tone: DyKpiTone.warning,
        ),
      ];
    }

    final Map<String, ({int pcs, double sumYield, int count})> buckets = {};
    for (final c in cards) {
      final key = lensIndex == 0 ? c.millName : c.greyQuality;
      final prev = buckets[key];
      buckets[key] = (
        pcs: (prev?.pcs ?? 0) + c.totalFreshPcs,
        sumYield: (prev?.sumYield ?? 0.0) + c.freshYieldPct,
        count: (prev?.count ?? 0) + 1,
      );
    }

    final sorted = buckets.entries.toList()
      ..sort((a, b) => b.value.pcs.compareTo(a.value.pcs));
    final top = sorted.take(6).toList();
    return [
      for (final e in top)
        DyBarMetricItem(
          label: e.key,
          formattedValue: '${e.value.pcs} Pcs',
          rawValue: e.value.pcs.toDouble(),
          subtitle:
              '${(e.value.sumYield / e.value.count).toStringAsFixed(1)}% Yield • ${e.value.count} Cards',
          tone: (e.value.sumYield / e.value.count) >= 85.0
              ? DyKpiTone.success
              : DyKpiTone.cyan,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activeLens = ScrCcSpecs.reportLenses[
        lensIndex.clamp(0, ScrCcSpecs.reportLenses.length - 1)];

    return DyReportsRegion(
      lensLabel: activeLens,
      targetTable: ScrCcSpecs.targetTable,
      isExpanded: isExpanded,
      items: _buildItems(),
      onItemTap: onItemTap,
    );
  }
}
