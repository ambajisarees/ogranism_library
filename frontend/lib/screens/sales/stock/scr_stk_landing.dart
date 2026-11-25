/*
================================================================================
LLM CONTEXT & QUERY SPACE — READY STOCK LANDING SCREEN (scr_stk_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Ready Saree Inventory & Godown Stock
     (`IMMBE2627.sb_stock`, navigation index `106`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states
     prior to Phase 2 stock rollup wiring.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly adheres to `DyModuleBlankLanding` (`6 -> 10` column expansion,
     `Shift+1..4` zoom, `Shift+P/X/N/Backspace`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_stock` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Reconcile physical box sets vs open sales orders (`sb_sales_orders`) in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Ready Stock (`IMMBE2627.sb_stock`).
class ScrStkLanding extends StatelessWidget {
  const ScrStkLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Stock',
    moduleName: 'Stock Adjustment',
    entityPlural: 'Items',
    targetTable: 'IMMBE2627.sb_stock',
    formIcon: shad.LucideIcons.warehouse,
    kpis: [
      DyRegionKpiSpec(
        title: 'READY DESIGNS IN STOCK',
        subtitle: 'Awaiting sb_stock bind',
        icon: shad.LucideIcons.warehouse,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'FREE AVAILABLE PCS',
        subtitle: 'Unallocated godown qty',
        icon: shad.LucideIcons.packageCheck,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'RESERVED FOR ORDERS',
        subtitle: 'Allocated against SOs',
        icon: shad.LucideIcons.lock,
        tone: DyKpiTone.indigo,
      ),
      DyRegionKpiSpec(
        title: 'SLOW MOVING (>90D)',
        subtitle: 'Ageing clearance watchlist',
        icon: shad.LucideIcons.clockAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'design', label: 'Design #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'quality', label: 'Quality', flex: 2),
      DyTableColumnSpec(key: 'godown', label: 'Godown / Floor', flex: 1),
      DyTableColumnSpec(key: 'availPcs', label: 'Free Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'rate', label: 'Wholesale ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'design', label: 'Design #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'quality', label: 'Quality', flex: 2),
      DyTableColumnSpec(key: 'godown', label: 'Godown / Floor', flex: 1),
      DyTableColumnSpec(key: 'packType', label: 'Pack Type', flex: 1),
      DyTableColumnSpec(key: 'inHandPcs', label: 'In Hand', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'reservedPcs', label: 'Reserved', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'availPcs', label: 'Free Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'rate', label: 'WSP (₹)', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'ageDays', label: 'Age Days', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Godown',
    partyFilterIcon: shad.LucideIcons.warehouse,
    partyOptions: ['Main Ring Road', '2nd Floor Packing', 'Basement Grey', 'Showroom'],
    millFilterLabel: 'Quality',
    millFilterIcon: shad.LucideIcons.shirt,
    statusOptions: ['In Stock', 'Low Stock', 'Dead Stock'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'quality', label: 'Quality', icon: shad.LucideIcons.shirt),
      DabGroupOption(id: 'godown', label: 'Godown', icon: shad.LucideIcons.warehouse),
    ],
    taskQueues: ['All', 'Reorder Low', 'Ageing >90d'],
    reportLenses: ['By Quality', 'By Godown', 'Stock Valuation'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Design SKU # (sb_designs) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Godown / Location *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Adjustment Type (Opening / Physical Audit)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Quantity Pcs (+/-)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Sets / Parcels'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Valuation Rate (₹)'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Audit / Re-count Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
