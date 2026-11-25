/*
================================================================================
LLM CONTEXT & QUERY SPACE — FINANCE COMPLIANCE SCREEN (scr_cmp_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Statutory GST (GSTR-1, GSTR-3B, E-Invoice IRN,
     E-Way Bill) & TDS/TCS Compliance (`IMMBE2627.sb_compliance`, index `305`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Aggregates statutory return readiness, HSN summaries (`5407`/`5208`), and
     upcoming statutory challan due dates.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_compliance` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Connect GSP JSON export for GSTR-1 B2B / HSN tables in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Compliance (`IMMBE2627.sb_compliance`).
class ScrCmpLanding extends StatelessWidget {
  const ScrCmpLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Compliance',
    moduleName: 'Filing Item',
    entityPlural: 'Filings',
    targetTable: 'IMMBE2627.sb_compliance',
    formIcon: shad.LucideIcons.shieldCheck,
    kpis: [
      DyRegionKpiSpec(
        title: 'STATUTORY RETURNS DUE',
        subtitle: 'Awaiting sb_compliance bind',
        icon: shad.LucideIcons.shieldCheck,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'OUTPUT GST LIABILITY',
        subtitle: 'CGST + SGST + IGST (S1)',
        icon: shad.LucideIcons.indianRupee,
        tone: DyKpiTone.indigo,
      ),
      DyRegionKpiSpec(
        title: 'ELIGIBLE ITC (2B)',
        subtitle: 'Verified input tax credit',
        icon: shad.LucideIcons.circleCheck,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'IRN / TDS EXCEPTIONS',
        subtitle: 'Pending portal validation',
        icon: shad.LucideIcons.shieldAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'period', label: 'Period', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'filing', label: 'Return / Act', flex: 2),
      DyTableColumnSpec(key: 'dueDate', label: 'Due Date', flex: 1),
      DyTableColumnSpec(key: 'taxAmt', label: 'Net Liability ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'arn', label: 'ARN / Challan', flex: 2),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'period', label: 'Period', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'filing', label: 'Return / Act', flex: 2),
      DyTableColumnSpec(key: 'dueDate', label: 'Due Date', flex: 1),
      DyTableColumnSpec(key: 'taxable', label: 'Taxable ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'outputTax', label: 'Output GST', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'itcClaimed', label: 'ITC Claimed', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'netPay', label: 'Challan ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'filedOn', label: 'Filed Date', flex: 1),
      DyTableColumnSpec(key: 'arn', label: 'ARN / Ack #', flex: 2),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Filing',
    partyFilterIcon: shad.LucideIcons.shieldCheck,
    partyOptions: ['GSTR-1', 'GSTR-3B', 'TDS 194C / 194H', 'TCS 206C', 'E-Invoice IRN'],
    statusOptions: ['Filed', 'Due Soon', 'Exception'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'filing', label: 'Return Type', icon: shad.LucideIcons.shieldCheck),
      DabGroupOption(id: 'period', label: 'Month', icon: shad.LucideIcons.calendar),
    ],
    taskQueues: ['All', 'Due This Week', 'IRN Failed'],
    reportLenses: ['GST Liability', 'HSN Summary', 'TDS Register'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Compliance Head (GSTR-1 / GSTR-3B / TDS) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Return Period (e.g. Nov 2026) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Due Date'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Challan / Tax Amount (₹)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'ARN / BSR Challan Reference'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Filing Status (Prepared / Filed)'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'CA Review Notes & Portal Attachments Ref'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
