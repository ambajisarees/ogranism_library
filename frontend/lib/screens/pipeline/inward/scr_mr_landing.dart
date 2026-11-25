/*
================================================================================
LLM CONTEXT & QUERY SPACE — MILL INWARD RECEIPTS SCREEN (scr_mr_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Grey & Mill Taka Inward Receipts
     (`IMMBE2627.sb_mill_receipts`, navigation index `201`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Tracks incoming finished takas from processing mills (`sq_MILLREC` mirror)
     before entering Cutting Cards (`cc`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_mill_receipts` schema staged; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Link LR weight / shortage tolerances directly into Cuttings pool in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Inward Receipts (`IMMBE2627.sb_mill_receipts`).
class ScrMrLanding extends StatelessWidget {
  const ScrMrLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Inward',
    moduleName: 'Inward Receipt',
    entityPlural: 'Receipts',
    targetTable: 'IMMBE2627.sb_mill_receipts',
    formIcon: shad.LucideIcons.packageCheck,
    kpis: [
      DyRegionKpiSpec(
        title: 'INWARD RECEIPTS',
        subtitle: 'Awaiting sb_mill_receipts bind',
        icon: shad.LucideIcons.packageCheck,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'TAKAS / METERS IN',
        subtitle: 'Ready for cutting queue',
        icon: shad.LucideIcons.layers,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'TRANSIT DISCREPANCY',
        subtitle: 'Weighbridge & lot variance',
        icon: shad.LucideIcons.scale,
        tone: DyKpiTone.warning,
      ),
      DyRegionKpiSpec(
        title: 'PENDING CUTTING',
        subtitle: 'Uncut mill challans',
        icon: shad.LucideIcons.scissors,
        tone: DyKpiTone.indigo,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'reccardno', label: 'Rec Card #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Inward Date', flex: 1),
      DyTableColumnSpec(key: 'mill', label: 'Mill / Supplier', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Quality', flex: 2),
      DyTableColumnSpec(key: 'mtrs', label: 'Recd Mtr', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Cut State', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'reccardno', label: 'Rec Card #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Inward Date', flex: 1),
      DyTableColumnSpec(key: 'millChallan', label: 'Mill Challan #', flex: 1),
      DyTableColumnSpec(key: 'mill', label: 'Mill / Supplier', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Quality', flex: 2),
      DyTableColumnSpec(key: 'lotNo', label: 'Lot #', flex: 1),
      DyTableColumnSpec(key: 'thans', label: 'Thans', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'greyMtrs', label: 'Grey Mtr', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'recdMtrs', label: 'Recd Mtr', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Mill',
    partyFilterIcon: shad.LucideIcons.factory,
    millFilterLabel: 'Quality',
    millFilterIcon: shad.LucideIcons.shirt,
    statusOptions: ['Uncut', 'Allocated', 'Cut Complete'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'mill', label: 'Mill', icon: shad.LucideIcons.factory),
      DabGroupOption(id: 'quality', label: 'Quality', icon: shad.LucideIcons.shirt),
    ],
    taskQueues: ['All', 'Shrink Check', 'Missing Lot'],
    reportLenses: ['By Mill', 'By Quality', 'Shortage Ageing'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Rec Card #', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Processing Mill (sb_parties) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Mill Challan / Program Ref'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Fabric Quality (sb_items)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'No. of Thans / Takas'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Received Meters'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Lot Number & Quality Inspection Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
