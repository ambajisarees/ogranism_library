/*
================================================================================
LLM CONTEXT & QUERY SPACE — FINANCE JOURNALS LANDING SCREEN (scr_jrn_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Debit Notes, Credit Notes, Rate Difference &
     Adjustment Journals (`IMMBE2627.sb_journals`, navigation index `304`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Covers Sales Returns, Rate Claims, Shortage Debit Notes, Interest/Kasar
     adjustments, and Depreciation/Audit JVs.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_journals` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Link GST Credit/Debit Note HSN summaries directly into `sb_compliance`.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Journals (`IMMBE2627.sb_journals`).
class ScrJrnLanding extends StatelessWidget {
  const ScrJrnLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Journals',
    moduleName: 'Journal Entry',
    entityPlural: 'Journals',
    targetTable: 'IMMBE2627.sb_journals',
    formIcon: shad.LucideIcons.fileSpreadsheet,
    kpis: [
      DyRegionKpiSpec(
        title: 'POSTED JOURNALS',
        subtitle: 'Awaiting sb_journals bind',
        icon: shad.LucideIcons.fileSpreadsheet,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'CREDIT NOTES ISSUED',
        subtitle: 'Goods return & rate claim',
        icon: shad.LucideIcons.fileMinus,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'DEBIT NOTES RAISED',
        subtitle: 'Shortage & supplier claims',
        icon: shad.LucideIcons.filePlus,
        tone: DyKpiTone.indigo,
      ),
      DyRegionKpiSpec(
        title: 'APPROVAL PENDING',
        subtitle: 'Auditor & CA signoff',
        icon: shad.LucideIcons.shieldAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'jvNo', label: 'JV / Note #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'kind', label: 'Nature', flex: 1),
      DyTableColumnSpec(key: 'drAccount', label: 'Debit A/C', flex: 2),
      DyTableColumnSpec(key: 'crAccount', label: 'Credit A/C', flex: 2),
      DyTableColumnSpec(key: 'amount', label: 'Amount ₹', flex: 1, isNumeric: true),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'jvNo', label: 'JV / Note #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'kind', label: 'Nature', flex: 1),
      DyTableColumnSpec(key: 'drAccount', label: 'Debit Ledger', flex: 2),
      DyTableColumnSpec(key: 'crAccount', label: 'Credit Ledger', flex: 2),
      DyTableColumnSpec(key: 'refBill', label: 'Ref Invoice #', flex: 1),
      DyTableColumnSpec(key: 'gst', label: 'GST ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'amount', label: 'Total ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'postedBy', label: 'Posted By', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Nature',
    partyFilterIcon: shad.LucideIcons.fileSpreadsheet,
    partyOptions: ['Credit Note', 'Debit Note', 'Journal JV', 'Kasar / Discount'],
    statusOptions: ['Posted', 'Draft', 'Pending Approval'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'kind', label: 'Nature', icon: shad.LucideIcons.fileSpreadsheet),
      DabGroupOption(id: 'status', label: 'Status', icon: shad.LucideIcons.circleDot),
    ],
    taskQueues: ['All', 'CA Signoff', 'GST Note IRN'],
    reportLenses: ['By Nature', 'Credit/Debit Summary', 'Monthly Trend'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Entry Type (JV / Credit Note / Debit Note) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Debit Ledger (sb_ledgers) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Credit Ledger (sb_ledgers) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Net Amount (₹) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Linked Invoice / Bill #'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'GST Impact Slab %'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Detailed Journal Narration & Claim Justification'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
