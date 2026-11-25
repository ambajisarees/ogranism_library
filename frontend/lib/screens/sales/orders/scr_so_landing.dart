/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES ORDERS LANDING SCREEN (scr_so_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Customer Sales Orders & Bookings
     (`IMMBE2627.sb_sales_orders`, navigation index `108`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states
     prior to Phase 2 backend binding.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Tracks wholesale customer & broker bookings before stock allocation, packing,
     and invoice billing (`S1`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_sales_orders` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Map broker/adatiya commission overrides cleanly per customer order in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Sales Orders (`IMMBE2627.sb_sales_orders`).
class ScrSoLanding extends StatelessWidget {
  const ScrSoLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Orders',
    moduleName: 'Sales Order',
    entityPlural: 'Orders',
    targetTable: 'IMMBE2627.sb_sales_orders',
    formIcon: shad.LucideIcons.shoppingBag,
    kpis: [
      DyRegionKpiSpec(
        title: 'OPEN SALES ORDERS',
        subtitle: 'Awaiting sb_sales_orders bind',
        icon: shad.LucideIcons.shoppingBag,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'PENDING PCS TO PACK',
        subtitle: 'Confirmed buyer demand',
        icon: shad.LucideIcons.package,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'READY FOR DISPATCH',
        subtitle: 'Packed bales staged',
        icon: shad.LucideIcons.checkCheck,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'CREDIT HOLD ORDERS',
        subtitle: 'Exceeding party limit',
        icon: shad.LucideIcons.shieldAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'soNo', label: 'Order #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'customer', label: 'Customer', flex: 2),
      DyTableColumnSpec(key: 'haste', label: 'Haste / Broker', flex: 2),
      DyTableColumnSpec(key: 'pendPcs', label: 'Pend Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'soNo', label: 'Order #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'customer', label: 'Customer', flex: 2),
      DyTableColumnSpec(key: 'haste', label: 'Haste / Broker', flex: 2),
      DyTableColumnSpec(key: 'city', label: 'Destination', flex: 1),
      DyTableColumnSpec(key: 'ordPcs', label: 'Ord Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'packedPcs', label: 'Packed', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'pendPcs', label: 'Pending', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'estAmt', label: 'Order Value', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Customer',
    partyFilterIcon: shad.LucideIcons.users,
    millFilterLabel: 'Broker / Adatiya',
    millFilterIcon: shad.LucideIcons.compass,
    statusOptions: ['Confirmed', 'Partially Packed', 'Credit Hold', 'Completed'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'customer', label: 'Customer', icon: shad.LucideIcons.users),
      DabGroupOption(id: 'haste', label: 'Haste', icon: shad.LucideIcons.compass),
      DabGroupOption(id: 'city', label: 'City', icon: shad.LucideIcons.mapPin),
    ],
    taskQueues: ['All', 'Credit Review', 'Packing Due'],
    reportLenses: ['By Customer', 'By Design', 'Order Ageing'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Sales Order # (auto)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Customer (sb_parties) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Haste / Adatiya Broker'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Design / Set Selection (sb_designs)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Requested Delivery Date'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Preferred Transport (sb_transports)'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Booking & Packing Special Instructions'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
