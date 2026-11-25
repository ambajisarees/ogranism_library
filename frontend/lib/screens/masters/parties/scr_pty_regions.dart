/*
================================================================================
LLM CONTEXT & QUERY SPACE — PARTIES MODULAR REGIONS (scr_pty_regions.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Domain-specific 4-Region Bento components (`ScrPtyMetricsPane`,
     `ScrPtyDataPane`, `ScrPtyTasksPane`, `ScrPtyReportsPane`) for Parties Master
     (`IMMBE2627.sb_parties`, navigation index `1`).
   - Wraps `DyMetricsRegion`, `DyDataRegion`, `DyTasksRegion`, and
     `DyReportsRegion` from `dynamic_ai/shells/dy_regions_canvas.dart` with
     Parties table columns (`6 -> 10` expansion), KPI tiles, KYC task queues,
     and Role/City/GST report lenses.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Table: `IMMBE2627.sb_parties` (UUID PK `id`, unique `party_code`,
     normalized fields `trade_name`, `party_role`, `city_name`, `state_name`,
     `gstin`, `mobile`, `adatiya_name`, `credit_limit`, `verification_status`).
   - Uses gap-compensated Base-12 sizing via `DyRegionsCanvas` components.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Zero Supabase reads executed in Phase 1 blank mode; Phase 2 will hydrate
     `sb_parties` counts, rows, KYC verification tasks, and rollups via `SrvPty`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Confirm default sort field (`trade_name` vs `updated_at`) once `sb_parties`
     is populated in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/micro/dab/dab_region_header.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Domain constants and table column definitions mapped 1:1 to `IMMBE2627.sb_parties`.
abstract class ScrPtySpecs {
  static const String targetTable = 'IMMBE2627.sb_parties';

  static const List<DyRegionKpiSpec> kpis = [
    DyRegionKpiSpec(
      title: 'TOTAL PARTIES',
      subtitle: 'Awaiting sb_parties sync',
      icon: shad.LucideIcons.users,
      tone: DyKpiTone.primary,
    ),
    DyRegionKpiSpec(
      title: 'CUSTOMERS',
      subtitle: 'Sales & wholesale buyers',
      icon: shad.LucideIcons.shoppingBag,
      tone: DyKpiTone.success,
    ),
    DyRegionKpiSpec(
      title: 'MILLS & KARIGARS',
      subtitle: 'Process houses & jobbers',
      icon: shad.LucideIcons.factory,
      tone: DyKpiTone.indigo,
    ),
    DyRegionKpiSpec(
      title: 'KYC / GST PENDING',
      subtitle: 'Verification queue',
      icon: shad.LucideIcons.shieldAlert,
      tone: DyKpiTone.warning,
    ),
  ];

  static const List<DyTableColumnSpec> collapsedColumns = [
    DyTableColumnSpec(
      key: 'party_code',
      label: 'Party Code',
      flex: 1,
      isPinnedLeft: true,
    ),
    DyTableColumnSpec(key: 'trade_name', label: 'Trade Name', flex: 2),
    DyTableColumnSpec(key: 'party_role', label: 'Role', flex: 1),
    DyTableColumnSpec(key: 'city_name', label: 'City', flex: 1),
    DyTableColumnSpec(key: 'gstin', label: 'GSTIN', flex: 2),
    DyTableColumnSpec(key: 'verification_status', label: 'KYC Status', flex: 1),
  ];

  static const List<DyTableColumnSpec> expandedColumns = [
    DyTableColumnSpec(
      key: 'party_code',
      label: 'Party Code',
      flex: 1,
      isPinnedLeft: true,
    ),
    DyTableColumnSpec(key: 'trade_name', label: 'Trade Name', flex: 2),
    DyTableColumnSpec(key: 'party_role', label: 'Role', flex: 1),
    DyTableColumnSpec(key: 'taxpayer_type', label: 'GST Type', flex: 1),
    DyTableColumnSpec(key: 'city_name', label: 'City', flex: 1),
    DyTableColumnSpec(key: 'state_name', label: 'State', flex: 1),
    DyTableColumnSpec(key: 'gstin', label: 'GSTIN', flex: 2),
    DyTableColumnSpec(key: 'mobile', label: 'WhatsApp / Mobile', flex: 1),
    DyTableColumnSpec(key: 'adatiya_name', label: 'Source / Adatiya', flex: 1),
    DyTableColumnSpec(key: 'verification_status', label: 'KYC Status', flex: 1),
  ];

  static const List<String> roleOptions = [
    'CUSTOMER',
    'SUPPLIER',
    'MILL_PROCESSOR',
    'KARIGAR_JOBBER',
    'BROKER_ADATIYA',
  ];

  static const List<String> cityOptions = [
    'Surat',
    'Mumbai',
    'Delhi',
    'Ahmedabad',
    'Jaipur',
    'Kolkata',
  ];

  static const List<String> gstStatusOptions = [
    'Regular',
    'Composition',
    'Unregistered',
  ];

  static const List<String> kycStatusOptions = [
    'HUMAN_VERIFIED',
    'KYC_PENDING',
    'ON_HOLD',
  ];

  static const List<DabGroupOption> groupOptions = [
    DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
    DabGroupOption(id: 'party_role', label: 'Role', icon: shad.LucideIcons.users),
    DabGroupOption(id: 'city_name', label: 'City', icon: shad.LucideIcons.mapPin),
    DabGroupOption(id: 'state_name', label: 'State', icon: shad.LucideIcons.map),
  ];

  static const List<String> taskQueues = ['All', 'KYC Pending', 'Due Review'];
  static const List<String> reportLenses = [
    'By Role',
    'By City',
    'GST Compliance',
  ];
}

/// Region 1 (`Metrics`) pane for `IMMBE2627.sb_parties`.
class ScrPtyMetricsPane extends StatelessWidget {
  final DabTimeHorizon horizon;
  final int? selectedKpiIndex;
  final ValueChanged<int> onKpiSelected;
  final bool isExpanded;
  final int trendMode;
  final ValueChanged<int> onTrendModeChanged;

  const ScrPtyMetricsPane({
    super.key,
    required this.horizon,
    required this.selectedKpiIndex,
    required this.onKpiSelected,
    required this.isExpanded,
    required this.trendMode,
    required this.onTrendModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DyMetricsRegion(
      kpis: ScrPtySpecs.kpis,
      selectedKpiIndex: selectedKpiIndex,
      onKpiSelected: onKpiSelected,
      isExpanded: isExpanded,
      trendTitle: 'Parties Activity (${horizon.label})',
      trendSubtitle: 'Awaiting ${ScrPtySpecs.targetTable} records',
      primarySeriesLabel: 'Onboarded',
      secondarySeriesLabel: 'Verified',
      trendModeLabels: const ['Count', 'Verified'],
      selectedTrendMode: trendMode,
      onTrendModeChanged: onTrendModeChanged,
      donutTitle: 'Parties by Role',
      donutSubtitle: 'Schema: ${ScrPtySpecs.targetTable}',
      donutCenterLabel: 'Parties',
    );
  }
}

/// Region 2 (`Data`) pane for `IMMBE2627.sb_parties`.
class ScrPtyDataPane extends StatelessWidget {
  final String viewMode;
  final bool isExpanded;

  const ScrPtyDataPane({
    super.key,
    required this.viewMode,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return DyDataRegion(
      entityPlural: 'Parties',
      targetTable: ScrPtySpecs.targetTable,
      emptyIcon: shad.LucideIcons.users,
      viewMode: viewMode,
      isExpanded: isExpanded,
      collapsedColumns: ScrPtySpecs.collapsedColumns,
      expandedColumns: ScrPtySpecs.expandedColumns,
    );
  }
}

/// Region 3 (`Tasks`) pane for `IMMBE2627.sb_parties`.
class ScrPtyTasksPane extends StatelessWidget {
  final int queueIndex;
  final String searchQuery;
  final bool isExpanded;

  const ScrPtyTasksPane({
    super.key,
    required this.queueIndex,
    required this.searchQuery,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final activeQueue = ScrPtySpecs.taskQueues[
        queueIndex.clamp(0, ScrPtySpecs.taskQueues.length - 1)];

    return DyTasksRegion(
      activeQueueLabel: activeQueue,
      targetTable: ScrPtySpecs.targetTable,
      searchQuery: searchQuery,
      isExpanded: isExpanded,
    );
  }
}

/// Region 4 (`Reports`) pane for `IMMBE2627.sb_parties`.
class ScrPtyReportsPane extends StatelessWidget {
  final int lensIndex;
  final bool isExpanded;

  const ScrPtyReportsPane({
    super.key,
    required this.lensIndex,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final activeLens = ScrPtySpecs.reportLenses[
        lensIndex.clamp(0, ScrPtySpecs.reportLenses.length - 1)];

    return DyReportsRegion(
      lensLabel: activeLens,
      targetTable: ScrPtySpecs.targetTable,
      isExpanded: isExpanded,
    );
  }
}
