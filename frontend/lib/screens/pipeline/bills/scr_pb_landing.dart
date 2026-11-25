/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE BILLS LANDING SCREEN (scr_pb_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Purchase Bills (`pb` / `P1`..`P10`, navigation
     index `105`) standardized onto `DyLandingCanvas` (`9:3` Base-12 grid) +
     `DyRegionsCanvas`.
   - Keeps the legacy `ScrPbFormDialog` modal accessible under a `Legacy` button
     in `PageHeader` for immediate side-by-side reference.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Covers `P1` Grey, `P2` Finish, `P3` Lace, `P4` Mill/Job Work, `P5` Stitching,
     `P6` Packing, `P7` General, `P8` Yarn, `P9` Store, and `P10` Capital.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Phase 1 renders clean blank states; Phase 2 will rebind `SrvPb` (`sq_BILLS`
     / `sq_PINVTRN` / `sq_BILLDET` / `sq_MILLREC`) directly into `ScrPbRegions`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Replace `ScrPbFormDialog` with full modular `ScrPbForm` (`DyFormCanvas`)
     during Phase 2 Purchase Bills cutover.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';
import 'scr_pb_form_dialog.dart';

/// Linear Landing screen for Purchase Bills (`pb`).
class ScrPbLanding extends StatelessWidget {
  const ScrPbLanding({super.key});

  static final DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Bills',
    moduleName: 'Purchase Bill',
    entityPlural: 'Bills',
    targetTable: 'IMMBE2627.sb_purchase_bills',
    formIcon: shad.LucideIcons.receipt,
    headerExtraActionsBuilder: (context) => [
      PageHeaderActionButton(
        label: 'Legacy',
        icon: shad.LucideIcons.history,
        onPressed: () => ScrPbFormDialog.show(context),
      ),
    ],
    kpis: const [
      DyRegionKpiSpec(
        title: 'PURCHASE BILLS',
        subtitle: 'P1–P10 series awaiting bind',
        icon: shad.LucideIcons.receipt,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'GREY & FINISH BILLS',
        subtitle: 'P1 & P2 fabric inward',
        icon: shad.LucideIcons.layers,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'MILL & JOB WORK BILLS',
        subtitle: 'P4 & P5 processing invoices',
        icon: shad.LucideIcons.factory,
        tone: DyKpiTone.indigo,
      ),
      DyRegionKpiSpec(
        title: 'GSTR-2B / AUDIT HOLD',
        subtitle: 'Tax & rate verification queue',
        icon: shad.LucideIcons.shieldAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'billNo', label: 'Bill #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'series', label: 'Series', flex: 1),
      DyTableColumnSpec(key: 'supplier', label: 'Supplier / Mill', flex: 2),
      DyTableColumnSpec(key: 'billAmt', label: 'Bill Amt', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'billNo', label: 'Bill #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'series', label: 'Series', flex: 1),
      DyTableColumnSpec(key: 'supplier', label: 'Supplier / Mill', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Quality / Head', flex: 2),
      DyTableColumnSpec(key: 'qty', label: 'Qty / Mtrs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'gross', label: 'Taxable', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'gst', label: 'GST', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'billAmt', label: 'Net Payable', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Series',
    partyFilterIcon: shad.LucideIcons.receipt,
    partyOptions: const [
      'P1 Grey',
      'P2 Finish',
      'P3 Lace',
      'P4 Mill / Job Work',
      'P5 Stitching',
      'P6 Packing',
      'P7 General',
      'P8 Yarn',
      'P9 Store',
      'P10 Capital',
    ],
    millFilterLabel: 'Supplier',
    millFilterIcon: shad.LucideIcons.users,
    statusOptions: const ['Verified', 'GSTR-2B Pending', 'Rate Hold'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'series', label: 'Series', icon: shad.LucideIcons.receipt),
      DabGroupOption(id: 'supplier', label: 'Supplier', icon: shad.LucideIcons.users),
      DabGroupOption(id: 'quality', label: 'Quality', icon: shad.LucideIcons.shirt),
    ],
    taskQueues: const ['All', '2B Mismatch', 'Due Payment'],
    reportLenses: const ['By Series', 'By Supplier', 'GST Input'],
    addFormFields: const [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Bill Series (P1..P10)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Supplier / Mill (sb_parties) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Supplier Invoice No *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Quality / Expense Head'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Taxable Amount (₹)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Net Bill Amount (₹)'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'PO / Receipt Reference & Audit Remarks'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DyModuleBlankLanding(config: _config);
  }
}
