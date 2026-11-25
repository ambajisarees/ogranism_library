/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES INVOICE DOMAIN MODEL (mdl_sales.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary domain data model for Sales module (`sales` / `so`).
   - Represents sales invoices (`sq_BILLS` series `S1`) and line items (`sq_BILLDET`).
   - Encapsulates Master Customer and Haste business logic, where a biller can dispatch
     goods to multiple distinct hastes under one billing ledger account.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Schema/Table: `IMMBE2627.sq_BILLS` (Header), `IMMBE2627.sq_BILLDET` (Line Items).
   - Haste Rule:
     * When haste is present (`haste != null && haste.isNotEmpty`):
       - effectivePartyName = haste (delivery destination)
       - effectiveAgentOrBiller = code / partyName (biller party)
       - billType = SalesBillType.haste
     * When haste is empty (`haste == null || haste.isEmpty`):
       - effectivePartyName = code / partyName (main customer)
       - effectiveAgentOrBiller = BCODE / brokerName (agent/broker or 'Direct')
       - billType = SalesBillType.customer
   - Dispatch & Reconciliation Stage (`dispatchStage`):
     * `'SETTLED'` when `paymentStatus == 'Y'`
     * `'EWB LOGGED'` when `ewayBillNo` is populated
     * `'LR LOGGED'` when `lrNo` (`RRNO`) is populated
     * `'PENDING LR'` otherwise (active dispatch/bilti wave)
   - Bales: Extracted from `PARCELS` (numeric / integer).
   - Amounts: `grossamt` (Gross Amount) and `BILLAMT` (Final Payable Amount).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_BILLS` is an Airbyte read-only mirror.
   - Active FY S1 invoices (`VNO < 100000`) total ~13,591 rows.
   - Default fallbacks (`?? 0.0`, `?? 0`, `?? 'N/A'`) ensure zero null-unwrapping crashes.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future step will attach `sb_packing_slips` & `sb_invoice_recon` reconciliation state.
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/sq/sq_bills.dart';
import '../core/sq/sq_billdet.dart';
import '../../dynamic_ai/micro/table/dy_table_models.dart';

/// Classification of sales invoice according to party delivery style.
enum SalesBillType {
  customer,
  haste,
}

extension SalesBillTypeExt on SalesBillType {
  String get displayName {
    switch (this) {
      case SalesBillType.customer:
        return 'Customer';
      case SalesBillType.haste:
        return 'Haste';
    }
  }
}

/// [MdlSalesBill] — Domain model wrapping a single sales invoice header and details.
@immutable
class MdlSalesBill {
  final int cno;
  final int vno;
  final String type;
  final String billNo;
  final DateTime? date;
  final String billerCode; // `code` in sq_BILLS (Master Customer / Biller Account)
  final String brokerName; // `BCODE` in sq_BILLS
  final String haste; // `haste` in sq_BILLS
  final int bales; // `PARCELS` in sq_BILLS
  final double grossAmount; // `grossamt`
  final double billAmount; // `BILLAMT`
  final double finalAmount; // `finalamt`
  final int totalPieces; // `TOTPCS`
  final double totalMeters; // `TOTMTS`
  final String transport; // `TRANSPORT`
  final String ewayBillNo; // `EWB_NO`
  final String lrNo; // `RRNO`
  final DateTime? lrDate; // `RRDATE`
  final String paymentStatus; // `paid`
  final String quality; // `QUAL`
  final List<SqBilldetModel> lineItems;
  final Map<String, dynamic> rawJson;

  const MdlSalesBill({
    required this.cno,
    required this.vno,
    required this.type,
    required this.billNo,
    this.date,
    required this.billerCode,
    required this.brokerName,
    required this.haste,
    required this.bales,
    required this.grossAmount,
    required this.billAmount,
    required this.finalAmount,
    required this.totalPieces,
    required this.totalMeters,
    required this.transport,
    required this.ewayBillNo,
    required this.lrNo,
    this.lrDate,
    required this.paymentStatus,
    required this.quality,
    this.lineItems = const [],
    this.rawJson = const {},
  });

  /// Composite primary key string (`CNO_TYPE_VNO`).
  String get compositeId => '${cno}_${type}_$vno';

  /// Factory adapting canonical [SqBillsModel].
  factory MdlSalesBill.fromSqBills(SqBillsModel sq, {List<SqBilldetModel> lineItems = const []}) {
    final raw = sq.rawJson;
    final int parcels = (raw['PARCELS'] as num?)?.toInt() ??
        (raw['parcels'] as num?)?.toInt() ??
        (raw['TOTAL_PARCEL'] as num?)?.toInt() ??
        0;

    return MdlSalesBill(
      cno: sq.cno,
      vno: sq.vno,
      type: sq.type,
      billNo: sq.billNo.isNotEmpty ? sq.billNo : sq.vno.toString(),
      date: sq.date,
      billerCode: sq.partyName.trim(),
      brokerName: sq.brokerName.trim(),
      haste: sq.haste.trim(),
      bales: parcels,
      grossAmount: sq.grossAmount > 0 ? sq.grossAmount : sq.billAmount,
      billAmount: sq.billAmount,
      finalAmount: sq.finalAmount > 0 ? sq.finalAmount : sq.billAmount,
      totalPieces: sq.totalPieces,
      totalMeters: sq.totalMeters,
      transport: sq.transport.trim(),
      ewayBillNo: sq.ewayBillNo.trim(),
      lrNo: sq.lrNo.trim(),
      lrDate: sq.lrDate,
      paymentStatus: sq.paymentStatus.trim(),
      quality: sq.quality.trim(),
      lineItems: lineItems,
      rawJson: raw,
    );
  }

  /// Whether this bill has a designated Haste.
  bool get hasHaste => haste.isNotEmpty;

  /// Whether LR / Bilti number is recorded.
  bool get hasLr => lrNo.isNotEmpty;

  /// Whether GST E-Waybill number is recorded.
  bool get hasEwayBill => ewayBillNo.isNotEmpty;

  /// Whether invoice is marked settled (`paid == 'Y'`).
  bool get isSettled => paymentStatus.toUpperCase() == 'Y';

  /// Standardized 4-stage dispatch / reconciliation status label.
  String get dispatchStage {
    if (isSettled) return 'SETTLED';
    if (hasEwayBill) return 'EWB LOGGED';
    if (hasLr) return 'LR LOGGED';
    return 'PENDING LR';
  }

  /// Compact Transport + LR summary cell string.
  String get formattedTransportLr {
    final tr = transport.isNotEmpty ? transport : 'Direct / Unassigned';
    if (hasLr) return '$tr • LR $lrNo';
    return tr;
  }

  /// Effective Party Name:
  /// - If haste is present: Pick haste
  /// - If party has no haste: Pick main customer
  String get effectivePartyName {
    if (hasHaste) return haste;
    return billerCode.isNotEmpty ? billerCode : 'Unknown Customer';
  }

  /// Effective Agent / Biller Name:
  /// - If haste is present: Pick biller party
  /// - If no haste: Pick agent
  String get effectiveAgentOrBiller {
    if (hasHaste) {
      return billerCode.isNotEmpty ? billerCode : 'Direct Biller';
    }
    return brokerName.isNotEmpty ? brokerName : 'Direct Sale';
  }

  /// Categorical delivery badge type.
  SalesBillType get billType => hasHaste ? SalesBillType.haste : SalesBillType.customer;

  /// Formatted date string (DD-MMM-YYYY).
  String get formattedDate {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date!);
  }

  /// Formatted LR date string (DD-MMM-YYYY).
  String get formattedLrDate {
    if (lrDate == null) return 'Pending';
    return DateFormat('dd MMM yyyy').format(lrDate!);
  }

  /// Formatted currency string for Bill Amount (₹XX,XXX).
  String get formattedBillAmount {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(billAmount);
  }

  /// Formatted currency string for Gross Amount (₹XX,XXX).
  String get formattedGrossAmount {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(grossAmount);
  }

  /// Converts this invoice into standard [DyTableRowData] for tabular reporting.
  DyTableRowData toDyRowData() {
    return DyTableRowData(
      id: compositeId,
      rowType: DyTableRowType.def,
      voucherNo: billNo.isNotEmpty ? billNo : vno.toString(),
      partyName: effectivePartyName,
      status: dispatchStage,
      data: {
        'vno': billNo.isNotEmpty ? billNo : vno.toString(),
        'date': formattedDate,
        'partyName': effectivePartyName,
        'agentOrBiller': effectiveAgentOrBiller,
        'billerCode': billerCode,
        'haste': haste,
        'billType': billType.displayName,
        'isHaste': hasHaste,
        'bales': bales,
        'pieces': totalPieces,
        'meters': totalMeters.toStringAsFixed(1),
        'pcsMts': totalPieces > 0 ? '$totalPieces Pcs' : '${totalMeters.toStringAsFixed(0)} Mts',
        'grossAmt': formattedGrossAmount,
        'grossAmtVal': grossAmount,
        'billAmt': formattedBillAmount,
        'billAmtVal': billAmount,
        'transport': transport.isNotEmpty ? transport : '-',
        'transportLr': formattedTransportLr,
        'lrNo': hasLr ? lrNo : 'Pending LR',
        'ewbNo': hasEwayBill ? ewayBillNo : '-',
        'status': dispatchStage,
      },
    );
  }
}

/// [MdlHasteSubgroup] — Intermediate subgroup of invoices under a Master Customer belonging to a specific Haste (or Direct).
@immutable
class MdlHasteSubgroup {
  final String hasteName; // Haste delivery name or 'Direct Customer Dispatch'
  final bool isDirect;
  final List<MdlSalesBill> bills; // Always sorted latest first (DATE desc, VNO desc)

  const MdlHasteSubgroup({
    required this.hasteName,
    required this.isDirect,
    required this.bills,
  });

  int get totalBills => bills.length;
  int get totalBales => bills.fold<int>(0, (sum, b) => sum + b.bales);
  double get totalGrossAmt => bills.fold<double>(0.0, (sum, b) => sum + b.grossAmount);
  double get totalBillAmt => bills.fold<double>(0.0, (sum, b) => sum + b.billAmount);
  int get totalPieces => bills.fold<int>(0, (sum, b) => sum + b.totalPieces);
  double get totalMeters => bills.fold<double>(0.0, (sum, b) => sum + b.totalMeters);

  String get formattedTotalBillAmt {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(totalBillAmt);
  }

  String get formattedTotalGrossAmt {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(totalGrossAmt);
  }
}

/// [MdlCustomerSalesGroup] — Aggregated sales data grouped by Master Customer (`billerCode`), containing Haste subgroups.
@immutable
class MdlCustomerSalesGroup {
  final String customerName; // Master biller name (`code` in sq_BILLS)
  final List<MdlHasteSubgroup> hasteSubgroups;

  const MdlCustomerSalesGroup({
    required this.customerName,
    required this.hasteSubgroups,
  });

  /// All bills across all haste subgroups for this customer, sorted latest first.
  List<MdlSalesBill> get bills => hasteSubgroups.expand((h) => h.bills).toList();

  int get totalBills => hasteSubgroups.fold<int>(0, (sum, h) => sum + h.totalBills);
  int get totalBales => hasteSubgroups.fold<int>(0, (sum, h) => sum + h.totalBales);
  double get totalGrossAmt => hasteSubgroups.fold<double>(0.0, (sum, h) => sum + h.totalGrossAmt);
  double get totalBillAmt => hasteSubgroups.fold<double>(0.0, (sum, h) => sum + h.totalBillAmt);
  int get totalPieces => hasteSubgroups.fold<int>(0, (sum, h) => sum + h.totalPieces);
  double get totalMeters => hasteSubgroups.fold<double>(0.0, (sum, h) => sum + h.totalMeters);

  /// Distinct hastes operating under this customer.
  int get hasteCount => hasteSubgroups.where((h) => !h.isDirect).length;

  String get formattedTotalBillAmt {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(totalBillAmt);
  }

  String get formattedTotalGrossAmt {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(totalGrossAmt);
  }
}
