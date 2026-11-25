/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE ORDERS LANDING SCREEN (scr_po_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Purchase Orders (`po` / `O13`..`O16` + Grey POs)
     standardized onto `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas`.
   - Navigation index `5`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Covers Finish (`O13`), Lace (`O14`), Packing (`O15`), Studio (`O16`), and Grey POs
     (`IMMBE2627.sb_purchase_orders` target / `sq_ORDMAS` read mirror).
   - Progressive `6 -> 10` column expansion, `Shift+1..4` zoom, `Shift+P/X/N/Backspace`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Renders clean blank states during Phase 1 shell rollout; Phase 2 will rebind
     live `SrvPo` data directly into `ScrPoRegions`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Wire direct `SrvPo` live stream and PO voucher entry flow in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Purchase Orders (`po`).
class ScrPoLanding extends StatelessWidget {
  const ScrPoLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Purchase Orders',
    moduleName: 'Purchase Order',
    entityPlural: 'Orders',
    targetTable: 'IMMBE2627.sb_purchase_orders',
    formIcon: shad.LucideIcons.clipboardList,
    kpis: [
      DyRegionKpiSpec(
        title: 'OPEN ORDERS',
        subtitle: 'Pending mill/supplier delivery',
        icon: shad.LucideIcons.clipboardList,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'PENDING METERS / PCS',
        subtitle: 'Awaiting inward receipt',
        icon: shad.LucideIcons.packageOpen,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'DUE THIS WEEK',
        subtitle: 'SLA delivery window',
        icon: shad.LucideIcons.clock,
        tone: DyKpiTone.warning,
      ),
      DyRegionKpiSpec(
        title: 'ORDER VALUE (EST.)',
        subtitle: 'O13–O16 + Grey series',
        icon: shad.LucideIcons.indianRupee,
        tone: DyKpiTone.indigo,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'vno', label: 'PO #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Supplier / Party', flex: 2),
      DyTableColumnSpec(key: 'series', label: 'Series', flex: 1),
      DyTableColumnSpec(key: 'qty', label: 'Pend Qty', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'vno', label: 'PO #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'series', label: 'Series', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Supplier / Party', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Quality', flex: 2),
      DyTableColumnSpec(key: 'ordQty', label: 'Ordered', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'recdQty', label: 'Received', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'pendQty', label: 'Pending', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'rate', label: 'Rate', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Series',
    partyFilterIcon: shad.LucideIcons.layers,
    partyOptions: ['Finish (O13)', 'Lace (O14)', 'Packing (O15)', 'Studio (O16)', 'Grey'],
    millFilterLabel: 'Supplier',
    millFilterIcon: shad.LucideIcons.users,
    millOptions: [],
    statusOptions: ['Pending', 'Completed', 'Overdue'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'party', label: 'Party', icon: shad.LucideIcons.users),
      DabGroupOption(id: 'quality', label: 'Quality', icon: shad.LucideIcons.shirt),
      DabGroupOption(id: 'series', label: 'Series', icon: shad.LucideIcons.layers),
    ],
    taskQueues: ['All', 'Overdue POs', 'Due Today'],
    reportLenses: ['By Series', 'By Party', 'Ageing'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'PO Series (O13 / O14 / O15 / O16 / Grey)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Supplier / Party (sb_parties) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Quality / Material (sb_items)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Order Qty (Mtrs / Pcs)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Rate (₹)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Expected Delivery Date'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Design # & PO Remarks'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
