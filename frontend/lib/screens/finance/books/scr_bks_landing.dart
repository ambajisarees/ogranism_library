/*
================================================================================
LLM CONTEXT & QUERY SPACE — FINANCE BOOKS LANDING SCREEN (scr_bks_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Statutory Financial Books: Day Book, Cash/Bank
     Register, Trial Balance, Trading & P&L, and Balance Sheet
     (`IMMBE2627.sb_books`, navigation index `306`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly enforces Schedule III / Textile Trading-P&L book reporting
     across FY 26-27 (`IMMBE2627`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_books` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Connect automated PDF / Excel Trial Balance schedule pack in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Financial Books (`IMMBE2627.sb_books`).
class ScrBksLanding extends StatelessWidget {
  const ScrBksLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Books',
    moduleName: 'Book Schedule',
    entityPlural: 'Schedules',
    targetTable: 'IMMBE2627.sb_books',
    formIcon: shad.LucideIcons.library,
    kpis: [
      DyRegionKpiSpec(
        title: 'GROSS REVENUE (YTD)',
        subtitle: 'Awaiting sb_books bind',
        icon: shad.LucideIcons.trendingUp,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'CLOSING INVENTORY',
        subtitle: 'Grey + WIP + Ready Stock',
        icon: shad.LucideIcons.warehouse,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'CASH & BANK BALANCE',
        subtitle: 'All active bank ledgers',
        icon: shad.LucideIcons.landmark,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'TRIAL BALANCE DELTA',
        subtitle: 'Dr vs Cr parity check',
        icon: shad.LucideIcons.scale,
        tone: DyKpiTone.indigo,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'schedule', label: 'Schedule / Head', flex: 2, isPinnedLeft: true),
      DyTableColumnSpec(key: 'book', label: 'Statement', flex: 1),
      DyTableColumnSpec(key: 'debit', label: 'Debit ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'credit', label: 'Credit ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'net', label: 'Net Balance ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Audit', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'schedule', label: 'Schedule / Group', flex: 2, isPinnedLeft: true),
      DyTableColumnSpec(key: 'book', label: 'Statement', flex: 1),
      DyTableColumnSpec(key: 'fyPrev', label: 'Prev FY ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'opBal', label: 'Opening ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'debit', label: 'Period Dr ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'credit', label: 'Period Cr ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'net', label: 'Closing ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'pctRev', label: '% Share', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'updated', label: 'Last Sync', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Audit', flex: 1),
    ],
    partyFilterLabel: 'Statement',
    partyFilterIcon: shad.LucideIcons.library,
    partyOptions: ['Trial Balance', 'Trading & P&L', 'Balance Sheet', 'Day Book', 'Cash Book'],
    statusOptions: ['Balanced', 'Provisional', 'Audited'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'book', label: 'Statement', icon: shad.LucideIcons.library),
      DabGroupOption(id: 'nature', label: 'Nature', icon: shad.LucideIcons.scale),
    ],
    taskQueues: ['All', 'Audit Review', 'Period Lock'],
    reportLenses: ['Trial Balance', 'Trading Margin', 'Working Capital'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Schedule Title *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Book Statement (Trial / P&L / BS) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Fiscal Period (FY 26-27)'),
      DyModuleFormFieldSpec(colSpan: 6, placeholder: 'Included Ledger Groups (sb_groups)'),
      DyModuleFormFieldSpec(colSpan: 6, placeholder: 'Schedule Display Order'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'CA Grouping Rule & Disclosure Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
