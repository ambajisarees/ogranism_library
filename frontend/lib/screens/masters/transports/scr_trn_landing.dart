/*
================================================================================
LLM CONTEXT & QUERY SPACE — TRANSPORTS MASTER LANDING SCREEN (scr_trn_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Logistics Carriers, Booking Offices & Transport
     Masters (`IMMBE2627.sb_transports`, navigation index `13`).
   - Renders clean blank states across Metrics, Data (`6 -> 10` columns), Tasks,
     Reports, and `[N]` Add Flow using `MastersBlankLinearLanding`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses `DyLinearLandingCanvas` (`9:3` Bento split) + `36px` DABs.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_transports` currently blank; Phase 2 will model Transporter ID (GST
     E-Way Bill), booking branch, and destination route lanes.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Link transport route coverage directly to `sb_parties` and Dispatch LR.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Transports (`IMMBE2627.sb_transports`).
class ScrTrnLanding extends StatelessWidget {
  const ScrTrnLanding({super.key});

  static const MastersBlankLandingConfig _config = MastersBlankLandingConfig(
    title: 'Transports',
    moduleName: 'Transport',
    entityPlural: 'Transports',
    targetTable: 'IMMBE2627.sb_transports',
    formIcon: shad.LucideIcons.truck,
    kpis: [
      MastersKpiSpec(
        title: 'TOTAL TRANSPORTS',
        subtitle: 'Awaiting sb_transports sync',
        icon: shad.LucideIcons.truck,
        tone: DyKpiTone.primary,
      ),
      MastersKpiSpec(
        title: 'E-WAY VERIFIED',
        subtitle: 'Valid Transporter GSTIN IDs',
        icon: shad.LucideIcons.shieldCheck,
        tone: DyKpiTone.success,
      ),
      MastersKpiSpec(
        title: 'SERVICE HUBS',
        subtitle: 'Booking godowns & hubs',
        icon: shad.LucideIcons.mapPin,
        tone: DyKpiTone.indigo,
      ),
      MastersKpiSpec(
        title: 'MISSING ID / ROUTE',
        subtitle: 'Needs E-Way transporter ID',
        icon: shad.LucideIcons.triangleAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'code', label: 'Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Transport Name', flex: 2),
      DyTableColumnSpec(key: 'ewayId', label: 'Transporter ID', flex: 2),
      DyTableColumnSpec(key: 'hubCity', label: 'Origin Hub', flex: 1),
      DyTableColumnSpec(key: 'phone', label: 'Booking Phone', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'code', label: 'Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Transport Name', flex: 2),
      DyTableColumnSpec(key: 'ewayId', label: 'Transporter ID', flex: 2),
      DyTableColumnSpec(key: 'hubCity', label: 'Origin Hub', flex: 1),
      DyTableColumnSpec(key: 'bookingOffice', label: 'Booking Office', flex: 1),
      DyTableColumnSpec(key: 'deliveryZones', label: 'Coverage Zones', flex: 2),
      DyTableColumnSpec(key: 'phone', label: 'Booking Phone', flex: 1),
      DyTableColumnSpec(key: 'avgTransit', label: 'Transit Days', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'lrPrefix', label: 'LR Prefix', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Hub City',
    partyFilterIcon: shad.LucideIcons.mapPin,
    partyOptions: ['Surat Ring Road', 'Sachin GIDC', 'Bhiwandi', 'Delhi', 'Ahmedabad'],
    millFilterLabel: 'Zone',
    millFilterIcon: shad.LucideIcons.globe,
    millOptions: ['North India', 'South India', 'East India', 'West India', 'Central'],
    fabricFilterLabel: 'E-Way ID',
    fabricFilterIcon: shad.LucideIcons.shieldCheck,
    fabricOptions: ['GST Verified', 'ID Missing'],
    statusOptions: ['Active', 'Preferred', 'Inactive'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'hub', label: 'Hub', icon: shad.LucideIcons.mapPin),
      DabGroupOption(id: 'zone', label: 'Zone', icon: shad.LucideIcons.globe),
    ],
    taskQueues: ['All', 'Missing E-Way ID', 'Active'],
    reportLenses: ['By Hub', 'By Zone', 'Transit SLA'],
    addFormFields: [
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Transport Carrier Name *'),
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Transporter ID (GST E-Way 15-Digit)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Origin Booking Hub (e.g. Ring Road)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Booking Office Address'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Booking Desk Phone'),
      MastersFormFieldSpec(colSpan: 12, placeholder: 'Destination Coverage Zones & Transit Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const MastersBlankLinearLanding(config: _config);
  }
}
