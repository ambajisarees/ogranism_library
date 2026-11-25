/*
================================================================================
LLM CONTEXT & QUERY SPACE — FINANCE TRANSACTIONS SCREEN (scr_txn_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Bank/Cash Receipts, Payments & Contra Vouchers
     (`IMMBE2627.sb_transactions`, navigation index `302`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Covers NEFT/RTGS/UPI/Cheque collections, supplier/mill payouts, and
     bill-by-bill knock-off allocation (`VNO < 100000`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_transactions` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Connect bank statement parser & UPI UTR matching rules in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Transactions (`IMMBE2627.sb_transactions`).
class ScrTxnLanding extends StatelessWidget {
  const ScrTxnLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Transactions',
    moduleName: 'Voucher',
    entityPlural: 'Vouchers',
    targetTable: 'IMMBE2627.sb_transactions',
    formIcon: shad.LucideIcons.arrowLeftRight,
    kpis: [
      DyRegionKpiSpec(
        title: 'TOTAL VOUCHERS',
        subtitle: 'Awaiting sb_transactions bind',
        icon: shad.LucideIcons.arrowLeftRight,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'RECEIPTS INFLOW',
        subtitle: 'Customer NEFT/RTGS/Cheque',
        icon: shad.LucideIcons.arrowDownLeft,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'PAYMENTS OUTFLOW',
        subtitle: 'Grey, Mill & Job payouts',
        icon: shad.LucideIcons.arrowUpRight,
        tone: DyKpiTone.indigo,
      ),
      DyRegionKpiSpec(
        title: 'UNALLOCATED ADVANCE',
        subtitle: 'On-account pending knock-off',
        icon: shad.LucideIcons.circleAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'vno', label: 'Voucher #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'type', label: 'Type', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Party / Bank', flex: 2),
      DyTableColumnSpec(key: 'amt', label: 'Amount ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'vno', label: 'Voucher #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'type', label: 'Type', flex: 1),
      DyTableColumnSpec(key: 'mode', label: 'Mode', flex: 1),
      DyTableColumnSpec(key: 'bank', label: 'Bank / Cash A/C', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Party Account', flex: 2),
      DyTableColumnSpec(key: 'utr', label: 'Cheque / UTR #', flex: 1),
      DyTableColumnSpec(key: 'tds', label: 'TDS / Disc', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'amt', label: 'Net Amt ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Voucher Type',
    partyFilterIcon: shad.LucideIcons.arrowLeftRight,
    partyOptions: ['Receipt', 'Payment', 'Contra'],
    millFilterLabel: 'Mode',
    millFilterIcon: shad.LucideIcons.landmark,
    millOptions: ['NEFT / RTGS', 'UPI', 'Cheque', 'Cash'],
    statusOptions: ['Cleared', 'Pending Allocation', 'Bounced'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'type', label: 'Type', icon: shad.LucideIcons.arrowLeftRight),
      DabGroupOption(id: 'mode', label: 'Mode', icon: shad.LucideIcons.landmark),
      DabGroupOption(id: 'party', label: 'Party', icon: shad.LucideIcons.users),
    ],
    taskQueues: ['All', 'Allocate Bills', 'Cheque Clearing'],
    reportLenses: ['Cashflow', 'By Bank', 'Discount & TDS'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Voucher Type (Receipt / Payment / Contra) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Bank / Cash Account *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Counterparty Account (sb_ledgers) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Amount (₹) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Payment Mode (NEFT / Cheque / UPI)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'UTR / Instrument Ref #'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Narration & Invoice Knock-Off Ref'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
