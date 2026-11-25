/*
================================================================================
LLM CONTEXT & QUERY SPACE — DISPATCH & LOGISTICS SCREEN (scr_dsp_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Bale Dispatch, LR / Bilti & E-Way Bill
     Logistics (`IMMBE2627.sb_dispatch`, navigation index `109`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Tracks gate passes, transport booking (`sb_transports`), Lorry Receipt (`RRNO`
     / `RRDATE`), and Part-B E-Way Bill generation post Sales Invoice billing.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_dispatch` schema staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Connect LR scan OCR / transporter portal status webhook in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Dispatch (`IMMBE2627.sb_dispatch`).
class ScrDspLanding extends StatelessWidget {
  const ScrDspLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Dispatch',
    moduleName: 'Dispatch Challan',
    entityPlural: 'Dispatches',
    targetTable: 'IMMBE2627.sb_dispatch',
    formIcon: shad.LucideIcons.truck,
    kpis: [
      DyRegionKpiSpec(
        title: 'PENDING LR / BILTI',
        subtitle: 'Awaiting sb_dispatch bind',
        icon: shad.LucideIcons.truck,
        tone: DyKpiTone.warning,
      ),
      DyRegionKpiSpec(
        title: 'DISPATCHED BALES',
        subtitle: 'Active FY transport gate pass',
        icon: shad.LucideIcons.packageCheck,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'E-WAY BILLS LOGGED',
        subtitle: 'GST compliant shipments',
        icon: shad.LucideIcons.fileCheck,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'POD CONFIRMED',
        subtitle: 'Delivered to buyer destination',
        icon: shad.LucideIcons.mapPinCheck,
        tone: DyKpiTone.indigo,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'invNo', label: 'Invoice #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'customer', label: 'Party / Haste', flex: 2),
      DyTableColumnSpec(key: 'transport', label: 'Transport', flex: 2),
      DyTableColumnSpec(key: 'lrNo', label: 'LR #', flex: 1),
      DyTableColumnSpec(key: 'bales', label: 'Bales', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'stage', label: 'Stage', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'invNo', label: 'Invoice #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'invDate', label: 'Bill Date', flex: 1),
      DyTableColumnSpec(key: 'customer', label: 'Party / Haste', flex: 2),
      DyTableColumnSpec(key: 'city', label: 'Station / City', flex: 1),
      DyTableColumnSpec(key: 'transport', label: 'Transport', flex: 2),
      DyTableColumnSpec(key: 'lrNo', label: 'LR #', flex: 1),
      DyTableColumnSpec(key: 'lrDate', label: 'LR Date', flex: 1),
      DyTableColumnSpec(key: 'ewbNo', label: 'E-Way Bill #', flex: 1),
      DyTableColumnSpec(key: 'bales', label: 'Bales', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'stage', label: 'Stage', flex: 1),
    ],
    partyFilterLabel: 'Transport',
    partyFilterIcon: shad.LucideIcons.truck,
    millFilterLabel: 'Destination',
    millFilterIcon: shad.LucideIcons.mapPin,
    statusOptions: ['PENDING LR', 'LR LOGGED', 'EWB LOGGED', 'DELIVERED'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'transport', label: 'Transport', icon: shad.LucideIcons.truck),
      DabGroupOption(id: 'city', label: 'Destination', icon: shad.LucideIcons.mapPin),
    ],
    taskQueues: ['All', 'Missing LR', 'EWB Expiring'],
    reportLenses: ['By Transport', 'By Destination', 'TAT SLA'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Invoice Reference # *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Transport Carrier (sb_transports) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Number of Bales / Parcels'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'LR / Bilti Number'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'LR Dispatch Date'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'E-Way Bill # (12-Digit)'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Freight Charge, Station & Tempo Driver Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
