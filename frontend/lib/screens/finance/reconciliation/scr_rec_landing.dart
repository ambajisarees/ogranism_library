/*
================================================================================
LLM CONTEXT & QUERY SPACE — FINANCE RECONCILIATION SCREEN (scr_rec_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Bank, Adatiya & Mill Statement Reconciliation
     (`IMMBE2627.sb_reconciliation`, navigation index `303`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Matches bank feed entries, GSTR-2B supplier filings, and party statement
     claims against posted ERP vouchers & bills.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_reconciliation` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Integrate CSV/MT940 bank feed upload action in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Reconciliation (`IMMBE2627.sb_reconciliation`).
class ScrRecLanding extends StatelessWidget {
  const ScrRecLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Reconciliation',
    moduleName: 'Recon Batch',
    entityPlural: 'Items',
    targetTable: 'IMMBE2627.sb_reconciliation',
    formIcon: shad.LucideIcons.scale,
    kpis: [
      DyRegionKpiSpec(
        title: 'MATCHED ITEMS',
        subtitle: 'Awaiting sb_reconciliation bind',
        icon: shad.LucideIcons.circleCheck,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'BANK UNMATCHED',
        subtitle: 'Pending book voucher match',
        icon: shad.LucideIcons.landmark,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'GSTR-2B MISMATCHES',
        subtitle: 'Supplier ITC delta check',
        icon: shad.LucideIcons.shieldAlert,
        tone: DyKpiTone.warning,
      ),
      DyRegionKpiSpec(
        title: 'NET VARIANCE (₹)',
        subtitle: 'Unreconciled delta',
        icon: shad.LucideIcons.scale,
        tone: DyKpiTone.indigo,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'refId', label: 'Ref #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'stream', label: 'Stream', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Bank / Party', flex: 2),
      DyTableColumnSpec(key: 'delta', label: 'Diff ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Match', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'refId', label: 'Ref #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Txn Date', flex: 1),
      DyTableColumnSpec(key: 'stream', label: 'Stream', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Bank / Counterparty', flex: 2),
      DyTableColumnSpec(key: 'bookAmt', label: 'ERP Book ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'extAmt', label: 'Statement ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'delta', label: 'Variance ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'utr', label: 'UTR / Inv Ref', flex: 1),
      DyTableColumnSpec(key: 'age', label: 'Age Days', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'State', flex: 1),
    ],
    partyFilterLabel: 'Stream',
    partyFilterIcon: shad.LucideIcons.scale,
    partyOptions: ['Bank BRS', 'GSTR-2B ITC', 'Adatiya Patti', 'Mill Ledger'],
    statusOptions: ['Matched', 'Unmatched', 'Variance'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'stream', label: 'Stream', icon: shad.LucideIcons.scale),
      DabGroupOption(id: 'party', label: 'Account', icon: shad.LucideIcons.users),
    ],
    taskQueues: ['All', 'Bank Exceptions', 'GST Hold'],
    reportLenses: ['By Stream', 'By Variance', 'BRS Summary'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Reconciliation Stream (BRS / GSTR-2B) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Statement / Bank Account *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Statement Period End Date'),
      DyModuleFormFieldSpec(colSpan: 6, placeholder: 'Statement Closing Balance (₹)'),
      DyModuleFormFieldSpec(colSpan: 6, placeholder: 'CSV / Statement Reference Tag'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Auditor Remarks & Exception Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
