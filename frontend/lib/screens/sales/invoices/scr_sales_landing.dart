/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES INVOICES LANDING SCREEN (scr_sales_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Sales & Tax Invoices (`so` / `S1`, `S3`,
     navigation index `110`) standardized onto `DyLandingCanvas` (`9:3` Base-12
     grid) + `DyRegionsCanvas`.
   - Keeps `DiaSalesInvoicePrint` (`dialogs/dia_sales_invoice_print.dart`)
     accessible under a `Legacy` button in `PageHeader` for immediate PDF &
     thermal invoice reference.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Table: `IMMBE2627.sb_sales_invoices` (mirroring `sq_BILLS` `S1`/`S3`
     + `sq_BILLDET` Haste consignee billing).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Phase 1 renders clean blank states; Phase 2 will rebind `SrvSales` cache
     (`MdlSalesBill`) directly into `ScrSalesRegions`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Wire direct Tax Invoice & Packing Slip generator in Phase 2 Sales cutover.
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
import '../../../models/sales/mdl_sales.dart';
import 'dialogs/dia_sales_invoice_print.dart';

/// Linear Landing screen for Sales Invoices (`IMMBE2627.sb_sales_invoices`).
class ScrSalesLanding extends StatelessWidget {
  const ScrSalesLanding({super.key});

  static final DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Invoices',
    moduleName: 'Sales Invoice',
    entityPlural: 'Invoices',
    targetTable: 'IMMBE2627.sb_sales_invoices',
    formIcon: shad.LucideIcons.fileCheck,
    headerExtraActionsBuilder: (context) => [
      PageHeaderActionButton(
        label: 'Legacy',
        icon: shad.LucideIcons.history,
        onPressed: () => DiaSalesInvoicePrint.show(
          context,
          bill: MdlSalesBill(
            cno: 1,
            vno: 1001,
            type: 'S1',
            billNo: 'S1-1001 (Sample)',
            date: DateTime(2026, 11, 24),
            billerCode: 'AMBAJI SAMPLE PARTY',
            brokerName: 'Direct',
            haste: '',
            bales: 2,
            grossAmount: 48500,
            billAmount: 50925,
            finalAmount: 50925,
            totalPieces: 110,
            totalMeters: 605,
            transport: 'Shree Maruti Courier',
            ewayBillNo: '',
            lrNo: 'LR-8821',
            paymentStatus: 'N',
            quality: '60Gm Silk Print',
          ),
          lineItems: const [],
        ),
      ),
    ],
    kpis: const [
      DyRegionKpiSpec(
        title: 'TOTAL INVOICES (S1/S3)',
        subtitle: 'Awaiting sb_sales_invoices bind',
        icon: shad.LucideIcons.fileCheck,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'NET SALES TURNOVER',
        subtitle: 'Active FY billing value',
        icon: shad.LucideIcons.indianRupee,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'BALES & PCS INVOICED',
        subtitle: 'Customer & Haste waves',
        icon: shad.LucideIcons.package,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'E-INVOICE / LR PENDING',
        subtitle: 'Dispatch compliance queue',
        icon: shad.LucideIcons.shieldAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'billNo', label: 'Invoice #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'biller', label: 'Biller Party', flex: 2),
      DyTableColumnSpec(key: 'haste', label: 'Haste / Broker', flex: 2),
      DyTableColumnSpec(key: 'billAmt', label: 'Bill Amt', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'stage', label: 'Stage', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'billNo', label: 'Invoice #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'biller', label: 'Biller Party', flex: 2),
      DyTableColumnSpec(key: 'haste', label: 'Haste / Consignee', flex: 2),
      DyTableColumnSpec(key: 'transport', label: 'Transport', flex: 1),
      DyTableColumnSpec(key: 'bales', label: 'Bales', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'pcs', label: 'Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'grossAmt', label: 'Taxable', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'billAmt', label: 'Net Payable', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'stage', label: 'Stage', flex: 1),
    ],
    partyFilterLabel: 'Customer',
    partyFilterIcon: shad.LucideIcons.users,
    millFilterLabel: 'Broker / Adatiya',
    millFilterIcon: shad.LucideIcons.compass,
    fabricFilterLabel: 'Transport',
    fabricFilterIcon: shad.LucideIcons.truck,
    statusOptions: const ['SETTLED', 'EWB LOGGED', 'LR LOGGED', 'PENDING LR'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'biller', label: 'Customer', icon: shad.LucideIcons.users),
      DabGroupOption(id: 'broker', label: 'Broker', icon: shad.LucideIcons.compass),
      DabGroupOption(id: 'haste', label: 'Haste', icon: shad.LucideIcons.mapPin),
      DabGroupOption(id: 'transport', label: 'Transport', icon: shad.LucideIcons.truck),
    ],
    taskQueues: const ['All', 'Pending LR', 'IRN Pending'],
    reportLenses: const ['By Customer', 'By Haste', 'By Transport'],
    addFormFields: const [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Invoice Series (S1 Tax Invoice / S3)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Biller Customer (sb_parties) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Haste Consignee / Broker'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Transport Carrier (sb_transports)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Bales / Parcels'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Packing Slip Ref #'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Billing & LR Remarks'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DyModuleBlankLanding(config: _config);
  }
}
