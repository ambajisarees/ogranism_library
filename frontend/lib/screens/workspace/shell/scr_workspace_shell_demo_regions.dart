/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Modular sample region panes for `ScrWorkspaceShellDemo` (Stage 3 & Stage 4)
     demonstrating the 4-Region Linear Landing Canvas architecture (`Metrics`,
     `Data`, `Tasks`, `Reports`) plus Add Flow form:
     * `ShellMetricsKpiRow` / `ShellMetricsExpandedView`: 4 horizon-reactive
       `DyKpiMetricCard`s + `fl_chart` Trajectory, Donut & Leaderboard pivots.
     * `ShellDataRegionPane`: Base-12 responsive `DyTable` scaling cleanly from
       8 columns (`6 data + leading + trailing`) in Flex 8 landing split to 12
       columns (`10 data + leading + trailing`) in Flex 12 expansion, plus List,
       Cards, and 4-Stage Kanban board views.
     * `ShellTasksRegionPane`: Equal-height top Flex 4 queue with Resolve action.
     * `ShellReportsRegionPane`: Equal-height bottom Flex 4 pivot bars + full table.
     * `ShellAddCuttingForm`: Native `DyFormSection` entry form for `[N] Add`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` widgets, `DyColorSystem` scales,
     and `DynamicAI` components (`DyTable`, `DyKpiMetricCard`, `DyListPane`,
     `DyCardPane`, `DyKanbanPane`, `DyFormSection`).
   - Horizontal scroll fallback kicks in on `< 560px` phone viewports inside
     `ShellDataRegionPane` so table columns stay readable without squeezing.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - All badge chips wrap in `Focus(canRequestFocus: false, ...)` per Rule 8.
   - Pure client-side preset data modeled after Cuttings (`sq_BILLS` / `sb_cutdet`).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Ready to mirror verbatim into live modules (`Cuttings`, `Jobs`) after sign-off.
================================================================================
*/

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_grid_card.dart';
import '../../../dynamic_ai/micro/cards/dy_kanban_item.dart';
import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../dynamic_ai/micro/charts/dy_donut_breakdown_card.dart';
import '../../../dynamic_ai/micro/charts/dy_horizontal_bar_card.dart';
import '../../../dynamic_ai/micro/charts/dy_trend_area_chart.dart';
import '../../../dynamic_ai/micro/dab/dab_region_header.dart';
import '../../../dynamic_ai/page/dy_card_pane.dart';
import '../../../dynamic_ai/page/dy_form_section.dart';
import '../../../dynamic_ai/page/dy_kanban_pane.dart';
import '../../../dynamic_ai/page/dy_list_pane.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../dynamic_ai/specs/dy_grid_system.dart';
import '../../../services/service_header_toast.dart';

class ShellTaskEntry {
  final String id;
  final String title;
  final String subtitle;
  final String queue;
  final String badgeText;
  final DyKpiTone tone;

  const ShellTaskEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.queue,
    required this.badgeText,
    required this.tone,
  });
}

/// Row 2: 4 Interactive KPI Cards reacting to `DabTimeHorizon` selector.
class ShellMetricsKpiRow extends StatelessWidget {
  final DabTimeHorizon horizon;
  final int? selectedKpiIndex;
  final ValueChanged<int> onKpiSelected;

  const ShellMetricsKpiRow({
    super.key,
    required this.horizon,
    required this.selectedKpiIndex,
    required this.onKpiSelected,
  });

  List<(String, String, String, String, DyKpiTone, List<double>)> _resolveKpis() {
    switch (horizon) {
      case DabTimeHorizon.thisYear:
        return const [
          ('Pending Batches', '42', 'Across 8 dyeing mills', '+6 vs prev', DyKpiTone.cyan, [28, 31, 35, 39, 42]),
          ('Fresh Saree Yield', '88.4%', 'Target benchmark >= 86%', '+1.8%', DyKpiTone.success, [84.2, 85.8, 86.4, 87.9, 88.4]),
          ('Karigar WIP Lots', '128', '14,820 Pcs in fold queue', '9 overdue', DyKpiTone.warning, [110, 118, 125, 132, 128]),
          ('Ready For Packing', '₹38.4 L', '224 cut bales dispatched', 'On SLA', DyKpiTone.indigo, [22, 26, 31, 35, 38.4]),
        ];
      case DabTimeHorizon.thisMonth:
        return const [
          ('Pending Batches', '19', 'In cutting & table fold', '+3 mo', DyKpiTone.cyan, [12, 14, 15, 17, 19]),
          ('Fresh Saree Yield', '89.7%', 'Top mill: Suryansh (92%)', '+2.4%', DyKpiTone.success, [86.0, 87.1, 88.5, 89.0, 89.7]),
          ('Karigar WIP Lots', '48', '5,640 Pcs active', '4 overdue', DyKpiTone.warning, [40, 44, 52, 49, 48]),
          ('Ready For Packing', '₹14.2 L', '84 bales invoiced', '94% SLA', DyKpiTone.indigo, [8.5, 10.2, 11.8, 13.0, 14.2]),
        ];
      case DabTimeHorizon.thisWeek:
        return const [
          ('Pending Batches', '7', '3 scheduled today', 'Balanced', DyKpiTone.cyan, [5, 6, 8, 7, 7]),
          ('Fresh Saree Yield', '90.2%', 'Zero major shortage', '+0.9%', DyKpiTone.success, [88.9, 89.3, 89.8, 90.0, 90.2]),
          ('Karigar WIP Lots', '18', '2,120 Pcs allocated', '2 watch', DyKpiTone.warning, [14, 16, 20, 19, 18]),
          ('Ready For Packing', '₹4.8 L', '26 cut bales ready', '100% SLA', DyKpiTone.indigo, [2.1, 2.8, 3.5, 4.1, 4.8]),
        ];
      case DabTimeHorizon.today:
        return const [
          ('Pending Batches', '3', 'Table 1 & Table 3 active', 'Live', DyKpiTone.cyan, [1, 2, 2, 3, 3]),
          ('Fresh Saree Yield', '91.5%', '60G Georgette lot', '+3.1%', DyKpiTone.success, [89.0, 90.1, 90.8, 91.2, 91.5]),
          ('Karigar WIP Lots', '6', '680 Pcs clocked today', 'On track', DyKpiTone.warning, [3, 4, 5, 6, 6]),
          ('Ready For Packing', '₹1.35 L', '8 bales staged', 'Evening LR', DyKpiTone.indigo, [0.4, 0.7, 0.9, 1.1, 1.35]),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final kpis = _resolveKpis();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520 * theme.scaling) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < kpis.length; i++) ...[
                if (i > 0) const shad.DensityGap(shad.gapMd),
                DyKpiMetricCard(
                  title: kpis[i].$1,
                  value: kpis[i].$2,
                  subtitle: kpis[i].$3,
                  badgeText: kpis[i].$4,
                  icon: shad.LucideIcons.activity,
                  tone: kpis[i].$5,
                  sparklineValues: kpis[i].$6,
                  isSelected: selectedKpiIndex == i,
                  onTap: () => onKpiSelected(i),
                ),
              ],
            ],
          );
        }

        if (constraints.maxWidth < 900 * theme.scaling) {
          final gap = theme.density.baseGap * theme.scaling * shad.gapMd;
          final itemW = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (int i = 0; i < kpis.length; i++)
                SizedBox(
                  width: itemW,
                  child: DyKpiMetricCard(
                    title: kpis[i].$1,
                    value: kpis[i].$2,
                    subtitle: kpis[i].$3,
                    badgeText: kpis[i].$4,
                    icon: shad.LucideIcons.activity,
                    tone: kpis[i].$5,
                    sparklineValues: kpis[i].$6,
                    isSelected: selectedKpiIndex == i,
                    onTap: () => onKpiSelected(i),
                  ),
                ),
            ],
          );
        }

        final gap = theme.density.baseGap * theme.scaling * shad.gapMd;
        final useExactGrid = kpis.length == 4;

        Widget buildCard(int i) => DyKpiMetricCard(
              title: kpis[i].$1,
              value: kpis[i].$2,
              subtitle: kpis[i].$3,
              badgeText: kpis[i].$4,
              icon: shad.LucideIcons.activity,
              tone: kpis[i].$5,
              sparklineValues: kpis[i].$6,
              isSelected: selectedKpiIndex == i,
              onTap: () => onKpiSelected(i),
            );

        return Row(
          children: [
            for (int i = 0; i < kpis.length; i++) ...[
              if (i > 0) const shad.DensityGap(shad.gapMd),
              if (useExactGrid && i < kpis.length - 1)
                SizedBox(
                  width: DyGridSystem.spanWidth(
                    totalWidth: constraints.maxWidth,
                    span: DyGridSystem.flexBoard4PaneEqual,
                    gap: gap,
                  ),
                  child: buildCard(i),
                )
              else
                Expanded(child: buildCard(i)),
            ],
          ],
        );
      },
    );
  }
}

/// Expanded Metrics View: Scrollable 4 KPI Cards + Trajectory/Donut Charts.
class ShellMetricsExpandedView extends StatelessWidget {
  final DabTimeHorizon horizon;
  final int? selectedKpiIndex;
  final ValueChanged<int> onKpiSelected;
  final int trendMode;
  final ValueChanged<int> onTrendModeChanged;

  const ShellMetricsExpandedView({
    super.key,
    required this.horizon,
    required this.selectedKpiIndex,
    required this.onKpiSelected,
    required this.trendMode,
    required this.onTrendModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16 * theme.scaling),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShellMetricsKpiRow(
            horizon: horizon,
            selectedKpiIndex: selectedKpiIndex,
            onKpiSelected: onKpiSelected,
          ),
          const shad.DensityGap(shad.gapMd),
          LayoutBuilder(
            builder: (context, constraints) {
              final trendCard = DyTrendAreaChart(
                title: 'Cutting Output Trajectory (${horizon.label})',
                subtitle: 'Fresh Pcs output vs grey issued baseline',
                primarySeriesLabel: 'Fresh Output',
                secondarySeriesLabel: 'Grey Issued',
                modeLabels: const ['Pieces', 'Amount ₹'],
                selectedModeIndex: trendMode,
                onModeChanged: onTrendModeChanged,
                chartHeight: 220,
                points: trendMode == 0
                    ? const [
                        DyTrendPoint(label: 'Jul', primaryValue: 2400, secondaryValue: 2650),
                        DyTrendPoint(label: 'Aug', primaryValue: 2950, secondaryValue: 3200),
                        DyTrendPoint(label: 'Sep', primaryValue: 3420, secondaryValue: 3800),
                        DyTrendPoint(label: 'Oct', primaryValue: 4180, secondaryValue: 4520),
                        DyTrendPoint(label: 'Nov', primaryValue: 3890, secondaryValue: 4210),
                      ]
                    : const [
                        DyTrendPoint(label: 'Jul', primaryValue: 580000, secondaryValue: 640000),
                        DyTrendPoint(label: 'Aug', primaryValue: 740000, secondaryValue: 810000),
                        DyTrendPoint(label: 'Sep', primaryValue: 890000, secondaryValue: 960000),
                        DyTrendPoint(label: 'Oct', primaryValue: 1120000, secondaryValue: 1200000),
                        DyTrendPoint(label: 'Nov', primaryValue: 980000, secondaryValue: 1050000),
                      ],
              );

              final donutCard = DyDonutBreakdownCard(
                title: 'Stage Aging Mix',
                subtitle: 'Distribution of active cutting cards',
                centerLabel: 'Cards',
                centerValue: '42',
                slices: const [
                  DyDonutSlice(label: 'Completed', value: 18, formattedValue: '18', paletteIndex: 2),
                  DyDonutSlice(label: '0-7d Cutting', value: 13, formattedValue: '13', paletteIndex: 3),
                  DyDonutSlice(label: '8-15d Pending', value: 7, formattedValue: '7', paletteIndex: 1),
                  DyDonutSlice(label: 'Overdue >15d', value: 4, formattedValue: '4', paletteIndex: 0),
                ],
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

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: trendCard),
                  const shad.DensityGap(shad.gapMd),
                  Expanded(flex: 5, child: donutCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Base-12 Data Region (`6 data cols + 2 = 8` in Flex 8; `10 data cols + 2 = 12` when expanded).
class ShellDataRegionPane extends StatelessWidget {
  final bool isExpanded;
  final String viewMode;
  final String groupingMode;
  final String searchQuery;
  final Set<String> selectedParties;
  final Set<String> selectedMills;
  final Set<String> selectedFabrics;
  final Set<String> selectedStatuses;
  final ValueChanged<DyTableRowData>? onInspectRowMobile;

  const ShellDataRegionPane({
    super.key,
    required this.isExpanded,
    required this.viewMode,
    required this.groupingMode,
    required this.searchQuery,
    required this.selectedParties,
    required this.selectedMills,
    required this.selectedFabrics,
    required this.selectedStatuses,
    this.onInspectRowMobile,
  });

  static const List<DyTableColumnSpec> _compactCols8 = [
    DyTableColumnSpec(key: 'vno', label: 'Voucher #', flex: 1, isPinnedLeft: true),
    DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
    DyTableColumnSpec(key: 'partyName', label: 'Mill / Party', flex: 2),
    DyTableColumnSpec(key: 'designPattern', label: 'Quality', flex: 2),
    DyTableColumnSpec(key: 'quantity', label: 'Net Pcs', flex: 1, isNumeric: true),
    DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
  ];

  static const List<DyTableColumnSpec> _expandedCols12 = [
    DyTableColumnSpec(key: 'vno', label: 'Voucher #', flex: 1, isPinnedLeft: true),
    DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
    DyTableColumnSpec(key: 'partyName', label: 'Mill / Party', flex: 2),
    DyTableColumnSpec(key: 'broker', label: 'Master', flex: 1),
    DyTableColumnSpec(key: 'designPattern', label: 'Quality', flex: 2),
    DyTableColumnSpec(key: 'designCode', label: 'Design #', flex: 1),
    DyTableColumnSpec(key: 'than', label: 'Thans', flex: 1, isNumeric: true),
    DyTableColumnSpec(key: 'meters', label: 'Mtrs', flex: 1, isNumeric: true),
    DyTableColumnSpec(key: 'quantity', label: 'Net Pcs', flex: 1, isNumeric: true),
    DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
  ];

  static List<DyTableRowData> _sampleRows() {
    return [
      DyTableRowData(
        id: 'cc_294',
        voucherNo: 'CC-0294',
        partyName: 'Suryansh Mill',
        designPattern: '60Gm Silk Print',
        quantity: '420 Pcs',
        amount: '₹1,84,250',
        status: 'Pending',
        data: const {
          'date': '20 Nov 26',
          'broker': 'Ramesh Table',
          'designCode': 'D-9042',
          'than': '24',
          'meters': '2,380',
        },
        children: [
          DyTableRowData(
            id: 'cc_294_c1',
            rowType: DyTableRowType.child,
            voucherNo: '#1',
            partyName: 'Taka 4401 • Red/Gold',
            designPattern: '5.50 Cut + Blouse',
            quantity: '210 Pcs',
            status: 'Cut',
            data: const {'date': 'Cut 1'},
          ),
          DyTableRowData(
            id: 'cc_294_c2',
            rowType: DyTableRowType.child,
            voucherNo: '#2',
            partyName: 'Taka 4402 • Bottle Green',
            designPattern: '5.50 Cut + Blouse',
            quantity: '210 Pcs',
            status: 'Pending',
            data: const {'date': 'Cut 2'},
          ),
        ],
      ),
      DyTableRowData(
        id: 'cc_293',
        voucherNo: 'CC-0293',
        partyName: 'Mahadev Dyeing',
        designPattern: 'Georgette',
        quantity: '360 Pcs',
        amount: '₹1,52,400',
        status: 'Completed',
        data: const {
          'date': '19 Nov 26',
          'broker': 'Suresh Fold',
          'designCode': 'D-8831',
          'than': '20',
          'meters': '2,010',
        },
      ),
      DyTableRowData(
        id: 'cc_292',
        voucherNo: 'CC-0292',
        partyName: 'Vardhman Prints',
        designPattern: 'Dola Silk',
        quantity: '510 Pcs',
        amount: '₹2,64,800',
        status: 'Pending',
        data: const {
          'date': '18 Nov 26',
          'broker': 'Ramesh Table',
          'designCode': 'D-9104',
          'than': '30',
          'meters': '2,940',
        },
      ),
      DyTableRowData(
        id: 'cc_291',
        voucherNo: 'CC-0291',
        partyName: 'Suryansh Mill',
        designPattern: 'Georgette',
        quantity: '285 Pcs',
        amount: '₹1,19,700',
        status: 'Completed',
        data: const {
          'date': '17 Nov 26',
          'broker': 'Mukesh Master',
          'designCode': 'D-8790',
          'than': '16',
          'meters': '1,620',
        },
      ),
      DyTableRowData(
        id: 'cc_290',
        voucherNo: 'CC-0290',
        partyName: 'Ambaji Creation',
        designPattern: '60Gm Silk',
        quantity: '390 Pcs',
        amount: '₹1,75,500',
        status: 'Pending',
        data: const {
          'date': '15 Nov 26',
          'broker': 'Suresh Fold',
          'designCode': 'D-9015',
          'than': '22',
          'meters': '2,210',
        },
      ),
      DyTableRowData(
        id: 'cc_289',
        voucherNo: 'CC-0289',
        partyName: 'Shree Laxmi Prints',
        designPattern: 'Dola Silk',
        quantity: '450 Pcs',
        amount: '₹2,38,500',
        status: 'Completed',
        data: const {
          'date': '14 Nov 26',
          'broker': 'Mukesh Master',
          'designCode': 'D-8955',
          'than': '25',
          'meters': '2,540',
        },
      ),
    ];
  }

  List<DyTableRowData> _filteredRows() {
    final q = searchQuery.trim().toLowerCase();
    return _sampleRows().where((r) {
      if (selectedParties.isNotEmpty &&
          !selectedParties.contains(r.partyName)) {
        return false;
      }
      if (selectedMills.isNotEmpty && !selectedMills.contains(r.partyName)) {
        return false;
      }
      if (selectedFabrics.isNotEmpty &&
          !selectedFabrics.any((f) => (r.designPattern ?? '').contains(f))) {
        return false;
      }
      if (selectedStatuses.isNotEmpty && !selectedStatuses.contains(r.status)) {
        return false;
      }
      if (q.isEmpty) return true;
      return (r.voucherNo ?? '').toLowerCase().contains(q) ||
          (r.partyName ?? '').toLowerCase().contains(q) ||
          (r.designPattern ?? '').toLowerCase().contains(q);
    }).toList();
  }

  List<DyTableRowData> _groupedRows(List<DyTableRowData> filtered) {
    if (groupingMode == 'none') return filtered;
    final map = <String, List<DyTableRowData>>{};
    for (final row in filtered) {
      final key = groupingMode == 'fabric'
          ? (row.designPattern ?? 'Quality')
          : (row.partyName ?? 'Mill');
      map.putIfAbsent(key, () => []).add(row);
    }
    return map.entries.map((e) {
      return DyTableRowData(
        id: 'grp_${e.key}',
        rowType: DyTableRowType.group,
        title: '${e.key} (${e.value.length})',
        partyName: e.key,
        data: {
          'vno': '${e.key} (${e.value.length})',
          'quantity': '${e.value.length * 380} Pcs',
        },
        children: e.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final filtered = _filteredRows();
    final isPhone = MediaQuery.sizeOf(context).width < 768.0;
    final effectiveViewMode = isPhone ? 'list' : viewMode;

    switch (effectiveViewMode) {
      case 'list':
        return DynamicList(
          items: [
            for (final r in filtered)
              DynamicListItem(
                id: r.id,
                title: r.partyName ?? '-',
                subtitle: '${r.designPattern ?? ''} • ${r.quantity ?? ''}',
                indexNumber: '#${r.voucherNo ?? ''}',
                amount: r.amount,
                topTrailing: r.data['date']?.toString(),
                topLeading: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  descendantsAreFocusable: false,
                  child: r.status == 'Completed'
                      ? const shad.PrimaryBadge(child: Text('Completed'))
                      : const shad.OutlineBadge(child: Text('Pending')),
                ),
              ),
          ],
          selectedItem: null,
          onItemSelected: (item) {
            if (item == null) return;
            if (onInspectRowMobile != null) {
              for (final row in filtered) {
                if (row.id == item.id) {
                  onInspectRowMobile!(row);
                  return;
                }
              }
            }
            ServiceHeaderToast.instance.show('Selected ${item.indexNumber}');
          },
        );
      case 'cards':
        return DyViewCard(
          items: [
            for (final r in filtered)
              DyGridItem(
                id: r.id,
                title: r.partyName ?? '-',
                voucherNo: r.voucherNo ?? '-',
                partyName: r.designPattern ?? '-',
                designPattern: 'Design ${r.data['designCode'] ?? ''}',
                quantity: r.quantity ?? '-',
                amount: r.amount ?? '-',
                statusBadge: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  descendantsAreFocusable: false,
                  child: r.status == 'Completed'
                      ? const shad.PrimaryBadge(child: Text('DONE'))
                      : const shad.OutlineBadge(child: Text('PENDING')),
                ),
              ),
          ],
          selectedItem: null,
          onItemSelected: (item) {
            if (item != null) {
              ServiceHeaderToast.instance.show('Opened ${item.voucherNo}');
            }
          },
        );
      case 'board':
        final pending = filtered.where((r) => r.status != 'Completed').toList();
        final done = filtered.where((r) => r.status == 'Completed').toList();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DyKanbanPane(
                stageTitle: 'PENDING CUTTING',
                stageColor: DyColorSystem.orange500,
                items: [
                  for (final r in pending)
                    DyKanbanItem(
                      id: r.id,
                      title: r.partyName ?? '-',
                      voucherNo: r.voucherNo ?? '-',
                      partyName: r.partyName ?? '-',
                      designPattern: r.designPattern ?? '-',
                      quantity: r.quantity ?? '-',
                      amount: r.amount ?? '-',
                      status: 'Pending',
                    ),
                ],
                onItemSelected: (item) => ServiceHeaderToast.instance
                    .show('Inspecting ${item.voucherNo}'),
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            Expanded(
              child: DyKanbanPane(
                stageTitle: 'COMPLETED READY',
                stageColor: DyColorSystem.emerald500,
                items: [
                  for (final r in done)
                    DyKanbanItem(
                      id: r.id,
                      title: r.partyName ?? '-',
                      voucherNo: r.voucherNo ?? '-',
                      partyName: r.partyName ?? '-',
                      designPattern: r.designPattern ?? '-',
                      quantity: r.quantity ?? '-',
                      amount: r.amount ?? '-',
                      status: 'Completed',
                    ),
                ],
                onItemSelected: (item) => ServiceHeaderToast.instance
                    .show('Inspecting ${item.voucherNo}'),
              ),
            ),
          ],
        );
      case 'table':
      default:
        final table = DyTable(
          columns: isExpanded ? _expandedCols12 : _compactCols8,
          rows: _groupedRows(filtered),
          totalRecords: filtered.length,
          summaryTotals: {
            'vno': 'TOTAL (${filtered.length} Docs)',
            'quantity': '${filtered.length * 402} Pcs',
            if (isExpanded) 'than': '${filtered.length * 22}',
          },
          onEditRow: (row) => ServiceHeaderToast.instance
              .show('Editing ${row.voucherNo ?? row.id}'),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final minWidth =
                (isExpanded ? 920 : 620) * theme.scaling;
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
}

/// Top Half of Flex 4 Column: Internally scrollable operational Tasks Queue.
class ShellTasksRegionPane extends StatelessWidget {
  final List<ShellTaskEntry> tasks;
  final bool isExpanded;
  final ValueChanged<String> onResolveTask;

  const ShellTasksRegionPane({
    super.key,
    required this.tasks,
    required this.isExpanded,
    required this.onResolveTask,
  });

  Color _toneColor(DyKpiTone tone) {
    switch (tone) {
      case DyKpiTone.danger:
        return DyColorSystem.red500;
      case DyKpiTone.warning:
        return DyColorSystem.orange500;
      case DyKpiTone.success:
        return DyColorSystem.emerald500;
      case DyKpiTone.cyan:
      case DyKpiTone.primary:
      case DyKpiTone.indigo:
      case DyKpiTone.pink:
      case DyKpiTone.fuchsia:
        return DyColorSystem.cyan500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    return shad.OutlinedContainer(
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderWidth: 1.0,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: EdgeInsets.all(10 * scaling),
      child: tasks.isEmpty
          ? Center(
              child: Text(
                'All caught up — zero pending tasks',
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            )
          : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const shad.DensityGap(shad.gapSm),
              itemBuilder: (context, idx) {
                final t = tasks[idx];
                final accent = _toneColor(t.tone);
                return shad.OutlinedContainer(
                  backgroundColor:
                      DyColorSystem.resolveSurfaceCanvas(isDark),
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
                                    t.title,
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
                                      t.badgeText,
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
                            SizedBox(height: 2 * scaling),
                            Text(
                              t.subtitle,
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
                        onPressed: () => onResolveTask(t.id),
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

/// Bottom Half of Flex 4 Column: Internally scrollable Operational Reports Pivot.
class ShellReportsRegionPane extends StatelessWidget {
  final int lensIndex;
  final bool isExpanded;

  const ShellReportsRegionPane({
    super.key,
    required this.lensIndex,
    required this.isExpanded,
  });

  List<DyBarMetricItem> _itemsForLens() {
    switch (lensIndex) {
      case 1: // By Party
        return const [
          DyBarMetricItem(label: 'Ambaji Creation', formattedValue: '420 Pcs', rawValue: 420, subtitle: '91.4% Yield • 24 Thans', tone: DyKpiTone.success),
          DyBarMetricItem(label: 'Shree Laxmi Prints', formattedValue: '390 Pcs', rawValue: 390, subtitle: '88.0% Yield • 22 Thans', tone: DyKpiTone.cyan),
          DyBarMetricItem(label: 'Ganesh Sarees', formattedValue: '310 Pcs', rawValue: 310, subtitle: '85.2% Yield • 18 Thans', tone: DyKpiTone.indigo),
          DyBarMetricItem(label: 'Navkar Silk House', formattedValue: '245 Pcs', rawValue: 245, subtitle: '81.6% Yield • 14 Thans', tone: DyKpiTone.warning),
        ];
      case 2: // By Quality
        return const [
          DyBarMetricItem(label: '60Gm Silk Print', formattedValue: '810 Pcs', rawValue: 810, subtitle: '5.50 Cut • Avg ₹438/Pc', tone: DyKpiTone.success),
          DyBarMetricItem(label: 'Dola Silk Heavy', formattedValue: '640 Pcs', rawValue: 640, subtitle: '6.30 With Blouse', tone: DyKpiTone.cyan),
          DyBarMetricItem(label: 'Georgette Crush', formattedValue: '490 Pcs', rawValue: 490, subtitle: 'Dyed + Shrink 6.2%', tone: DyKpiTone.indigo),
        ];
      case 3: // Ageing
        return const [
          DyBarMetricItem(label: '0-7 Days Active', formattedValue: '1,290 Pcs', rawValue: 1290, subtitle: '13 Cutting Cards on schedule', tone: DyKpiTone.success),
          DyBarMetricItem(label: '8-15 Days Watch', formattedValue: '480 Pcs', rawValue: 480, subtitle: '7 Cards awaiting fold', tone: DyKpiTone.warning),
          DyBarMetricItem(label: '>15 Days Overdue', formattedValue: '215 Pcs', rawValue: 215, subtitle: '4 Cards escalated', tone: DyKpiTone.danger),
        ];
      case 0: // By Mill
      default:
        return const [
          DyBarMetricItem(label: 'Suryansh Mill', formattedValue: '91.2% Yield', rawValue: 91.2, subtitle: '705 Pcs • 40 Thans cut', tone: DyKpiTone.success),
          DyBarMetricItem(label: 'Vardhman Prints', formattedValue: '88.6% Yield', rawValue: 88.6, subtitle: '510 Pcs • 30 Thans cut', tone: DyKpiTone.cyan),
          DyBarMetricItem(label: 'Mahadev Dyeing', formattedValue: '84.9% Yield', rawValue: 84.9, subtitle: '360 Pcs • 20 Thans cut', tone: DyKpiTone.indigo),
          DyBarMetricItem(label: 'Laxmi Dyeing', formattedValue: '79.4% Yield', rawValue: 79.4, subtitle: '240 Pcs • High shrink alert', tone: DyKpiTone.warning),
        ];
    }
  }

  Color _toneColor(DyKpiTone? tone) {
    switch (tone) {
      case DyKpiTone.success:
        return DyColorSystem.emerald500;
      case DyKpiTone.warning:
        return DyColorSystem.orange500;
      case DyKpiTone.danger:
        return DyColorSystem.red500;
      case DyKpiTone.indigo:
        return DyColorSystem.indigo500;
      default:
        return DyColorSystem.cyan500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final items = _itemsForLens();

    if (isExpanded) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16 * scaling),
        child: DyHorizontalBarCard(
          title: 'Cutting Yield & Ageing Pivot',
          subtitle: 'Interactive module breakdown ordered by output/yield',
          items: items,
          onItemTap: (item) =>
              ServiceHeaderToast.instance.show('Pivot selected: ${item.label}'),
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
          final barColor = _toneColor(item.tone);

          return GestureDetector(
            onTap: () => ServiceHeaderToast.instance
                .show('Filtered by ${item.label}'),
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
                      style: theme.typography.xSmall.merge(theme.typography.mono).copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.foreground,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * scaling),
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

/// Sample `[N] Add Cutting Card` form rendered inside `DyLinearLandingCanvas`.
class ShellAddCuttingForm extends StatelessWidget {
  final VoidCallback onCancel;

  const ShellAddCuttingForm({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DyFormSection(
        title: 'New Cutting Card Batch',
        leadingIcon: shad.LucideIcons.scissors,
        fields: const [
          DyFormField(
            colSpan: 4,
            child: shad.TextField(placeholder: Text('Voucher # (CC-0295)')),
          ),
          DyFormField(
            colSpan: 4,
            child: shad.TextField(placeholder: Text('Mill / Process House')),
          ),
          DyFormField(
            colSpan: 4,
            child: shad.TextField(placeholder: Text('Fabric Quality')),
          ),
          DyFormField(
            colSpan: 6,
            child: shad.TextField(placeholder: Text('Karigar Table / Master')),
          ),
          DyFormField(
            colSpan: 6,
            child: shad.TextField(placeholder: Text('Notes / Shrinkage Spec')),
          ),
        ],
      ),
    );
  }
}
