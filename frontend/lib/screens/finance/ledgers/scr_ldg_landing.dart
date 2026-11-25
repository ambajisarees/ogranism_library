/*
================================================================================
LLM CONTEXT & QUERY SPACE — FINANCE LEDGERS LANDING SCREEN (scr_ldg_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Account Ledgers & Party Outstanding Balances
     (`IMMBE2627.sb_ledgers`, navigation index `301`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states
     prior to Phase 2 financial mirror integration.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly adheres to `DyModuleBlankLanding` (`6 -> 10` column expansion,
     `Shift+1..4` zoom, `Shift+P/X/N/Backspace`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_ledgers` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Connect `sq_BALREC` / `sq_FAS` closing balance rollups in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Ledgers (`IMMBE2627.sb_ledgers`).
class ScrLdgLanding extends StatelessWidget {
  const ScrLdgLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Ledgers',
    moduleName: 'Ledger Account',
    entityPlural: 'Ledgers',
    targetTable: 'IMMBE2627.sb_ledgers',
    formIcon: shad.LucideIcons.bookOpen,
    kpis: [
      DyRegionKpiSpec(
        title: 'ACTIVE LEDGER ACCOUNTS',
        subtitle: 'Awaiting sb_ledgers bind',
        icon: shad.LucideIcons.bookOpen,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'TOTAL RECEIVABLES',
        subtitle: 'Sundry Debtors Dr balance',
        icon: shad.LucideIcons.arrowDownLeft,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'TOTAL PAYABLES',
        subtitle: 'Mill & Grey Cr balance',
        icon: shad.LucideIcons.arrowUpRight,
        tone: DyKpiTone.indigo,
      ),
      DyRegionKpiSpec(
        title: 'OVERDUE > 60 DAYS',
        subtitle: 'Payment follow-up queue',
        icon: shad.LucideIcons.clockAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'code', label: 'A/C Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Ledger Name', flex: 2),
      DyTableColumnSpec(key: 'group', label: 'Account Group', flex: 2),
      DyTableColumnSpec(key: 'opBal', label: 'Opening ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'clBal', label: 'Closing ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'drCr', label: 'Dr/Cr', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'code', label: 'A/C Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Ledger Name', flex: 2),
      DyTableColumnSpec(key: 'group', label: 'Group', flex: 2),
      DyTableColumnSpec(key: 'city', label: 'City', flex: 1),
      DyTableColumnSpec(key: 'opBal', label: 'Opening ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'debit', label: 'Total Debit', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'credit', label: 'Total Credit', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'clBal', label: 'Closing ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'drCr', label: 'Dr/Cr', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Group',
    partyFilterIcon: shad.LucideIcons.folderTree,
    partyOptions: ['Sundry Debtors', 'Sundry Creditors', 'Bank Accounts', 'Mill Accounts'],
    statusOptions: ['Dr Balance', 'Cr Balance', 'Settled'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'group', label: 'Group', icon: shad.LucideIcons.folderTree),
      DabGroupOption(id: 'city', label: 'City', icon: shad.LucideIcons.mapPin),
    ],
    taskQueues: ['All', 'Overdue Dr', 'Unreconciled'],
    reportLenses: ['By Group', 'Ageing Slabs', 'Top Debtors'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Ledger Account Code *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Ledger Title *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Account Group (sb_groups)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Linked Party (sb_parties)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Opening Balance (₹)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Dr / Cr Nature'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Bank Details & Statement Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
