/*
================================================================================
LLM CONTEXT & QUERY SPACE — PACKING PIPELINE LANDING SCREEN (scr_pck_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Folding, Box/Bale Packing & Staging
     (`IMMBE2627.sb_packing`, navigation index `202`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Bridges finished WIP from Jobs/Cuttings (`O5..O12`) into box sets & bales
     ready for Sales Orders and Dispatch (`S1`/`S3`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_packing` schema staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Confirm barcode / parcel sticker thermal dimensions in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Packing (`IMMBE2627.sb_packing`).
class ScrPckLanding extends StatelessWidget {
  const ScrPckLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Packing',
    moduleName: 'Packing Slip',
    entityPlural: 'Slips',
    targetTable: 'IMMBE2627.sb_packing',
    formIcon: shad.LucideIcons.boxes,
    kpis: [
      DyRegionKpiSpec(
        title: 'PACKING SLIPS',
        subtitle: 'Awaiting sb_packing bind',
        icon: shad.LucideIcons.boxes,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'BALES / BOXES STAGED',
        subtitle: 'Ready for Sales Invoice',
        icon: shad.LucideIcons.package,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'FRESH VS SECOND PCS',
        subtitle: 'Fold table QC grading',
        icon: shad.LucideIcons.checkCheck,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'PACKING MATERIAL LOW',
        subtitle: 'Box, pouch & zip inventory',
        icon: shad.LucideIcons.triangleAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'slipNo', label: 'Slip #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'design', label: 'Design #', flex: 2),
      DyTableColumnSpec(key: 'pcs', label: 'Packed Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'bales', label: 'Parcels', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Stage', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'slipNo', label: 'Slip #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'design', label: 'Design #', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Quality', flex: 2),
      DyTableColumnSpec(key: 'packType', label: 'Pack Type', flex: 1),
      DyTableColumnSpec(key: 'sets', label: 'Sets', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'pcs', label: 'Fresh Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'secondPcs', label: 'Second', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'bales', label: 'Parcels', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Stage', flex: 1),
    ],
    partyFilterLabel: 'Pack Type',
    partyFilterIcon: shad.LucideIcons.box,
    partyOptions: ['Box Pack', 'Zipper Pouch', 'Loose Bale', 'Catlog Set'],
    statusOptions: ['Staged', 'Invoiced', 'Hold'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'design', label: 'Design', icon: shad.LucideIcons.palette),
      DabGroupOption(id: 'packType', label: 'Pack Type', icon: shad.LucideIcons.box),
    ],
    taskQueues: ['All', 'Barcode Pending', 'Short Lot'],
    reportLenses: ['By Design', 'By Pack Type', 'Daily Output'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Packing Slip #', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Design / Lot # (sb_designs) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Packing Spec (sq_PACKING)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Total Saree Sets'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Fresh Pcs'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Bale / Parcel Count'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Table Master & Packing Remarks'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
