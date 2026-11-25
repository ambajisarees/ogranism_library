/*
================================================================================
LLM CONTEXT & QUERY SPACE — JOB WORK MODULE MODEL (mdl_jw.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Data Model for Job Work Operations (`jw` / Stage 2 & 3 Production Pipeline).
   - Adapts canonical `SqBillsModel` (job headers) and `SqBilldetModel` (job detail lines)
     into domain objects for UI rendering in DyTable, Page Shells, and DyShlDetails.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Schema/Tables: `IMMBE2627.sq_BILLS` (headers) & `IMMBE2627.sq_BILLDET` (detail lines).
   - Composite Keys: `CNO`, `VNO`, `TYPE`.
   - Series Mapping (`JwCategory`):
     * `O5`  -> Stitch Desp
     * `O6`  -> Stitch Recd
     * `O7`  -> Diamond Desp
     * `O8`  -> Diamond Recd
     * `O9`  -> Embroidery Desp
     * `O10` -> Embroidery Recd
     * `O11` -> Charak Desp
     * `O12` -> Charak Recd
   - DyTable Integration: Provides `toDyDefRowData()` and `toDyChildRowData()` for 3-tiered DyTable hierarchy.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - FY 26-27 active records exist for `O5` (335), `O6` (434), `O7` (30), `O8` (30).
   - `O9`..`O12` contain prior FY historical records. Service falls back gracefully.
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../dynamic_ai/micro/table/dy_table_models.dart';
import '../core/sq/sq_bills.dart';
import '../core/sq/sq_billdet.dart';

/// Submodule categories for Job Work (O5 through O12 series)
enum JwCategory {
  stitchDesp,
  stitchRecd,
  diamondDesp,
  diamondRecd,
  embroideryDesp,
  embroideryRecd,
  charakDesp,
  charakRecd;

  String get displayName {
    switch (this) {
      case JwCategory.stitchDesp:
        return 'Stitch Desp';
      case JwCategory.stitchRecd:
        return 'Stitch Recd';
      case JwCategory.diamondDesp:
        return 'Diamond Desp';
      case JwCategory.diamondRecd:
        return 'Diamond Recd';
      case JwCategory.embroideryDesp:
        return 'Embroidery Desp';
      case JwCategory.embroideryRecd:
        return 'Embroidery Recd';
      case JwCategory.charakDesp:
        return 'Charak Desp';
      case JwCategory.charakRecd:
        return 'Charak Recd';
    }
  }

  String get seriesCode {
    switch (this) {
      case JwCategory.stitchDesp:
        return 'O5';
      case JwCategory.stitchRecd:
        return 'O6';
      case JwCategory.diamondDesp:
        return 'O7';
      case JwCategory.diamondRecd:
        return 'O8';
      case JwCategory.embroideryDesp:
        return 'O9';
      case JwCategory.embroideryRecd:
        return 'O10';
      case JwCategory.charakDesp:
        return 'O11';
      case JwCategory.charakRecd:
        return 'O12';
    }
  }

  bool get isDispatch => index % 2 == 0;
  bool get isReceived => index % 2 == 1;

  static JwCategory fromSeriesCode(String code) {
    final clean = code.trim().toUpperCase();
    for (final cat in JwCategory.values) {
      if (cat.seriesCode == clean) return cat;
    }
    return JwCategory.stitchDesp;
  }
}

/// [MdlJwHeader] — Domain Data Model for a Job Work Header Record (`sq_BILLS`)
@immutable
class MdlJwHeader {
  final SqBillsModel core;
  final List<MdlJwLineItem> lineItems;

  const MdlJwHeader({
    required this.core,
    this.lineItems = const [],
  });

  /// Primary Composite ID
  String get id => '${core.type}_${core.cno}_${core.vno}';

  int get cno => core.cno;
  int get vno => core.vno;
  String get type => core.type;
  String get seriesCode => core.type;

  /// Formatted Voucher Code (e.g. `JW-O5-0012` or `#12`)
  String get displayVoucherCode => '${core.type} #${core.vno}';

  /// Job Worker / Tailor / Mill Party Name
  String get partyName => core.partyName.isNotEmpty ? core.partyName : 'Unknown Party';

  /// Fabric Quality Header
  String get quality => core.quality.isNotEmpty ? core.quality : 'N/A';

  /// Voucher Date
  DateTime? get date => core.date;

  /// Formatted Date String
  String get formattedDate {
    if (date == null) return 'N/A';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date!.day.toString().padLeft(2, '0')} ${months[date!.month - 1]} ${date!.year}';
  }

  /// Challan / Bill Ref Number
  String get challanNo => core.billNo.isNotEmpty ? core.billNo : '-';

  /// Total Job Work Pieces
  int get totalPieces => core.totalPieces;
  String get formattedTotalPieces => totalPieces > 0 ? '$totalPieces Pcs' : '0 Pcs';

  /// Total Job Work Meters
  double get totalMeters => core.totalMeters;
  String get formattedTotalMeters => totalMeters > 0 ? '${totalMeters.toStringAsFixed(1)} Mtr' : '0.0 Mtr';

  /// Financial Amount (₹)
  double get netAmount => core.finalAmount > 0 ? core.finalAmount : core.billAmount;
  String formattedAmount([NumberFormat? fmt]) {
    if (netAmount <= 0) return '₹0.00';
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(netAmount);
  }

  /// Payment / Completion Status
  bool get isCompleted => core.paymentStatus.toUpperCase() == 'Y';
  bool get isPending => !isCompleted;
  String get status => isCompleted ? 'COMPLETED' : 'PENDING';

  /// Convert into a Tier 2 Document Header Row for [DyTable]
  DyTableRowData toDyDefRowData([NumberFormat? fmt]) {
    final currencyFmt = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DyTableRowData(
      id: id,
      rowType: DyTableRowType.def,
      voucherNo: displayVoucherCode,
      partyName: partyName,
      data: {
        'vno': displayVoucherCode,
        'date': formattedDate,
        'partyName': partyName,
        'designPattern': quality,
        'quantity': '$totalPieces Pcs ($formattedTotalMeters)',
        'totalPcs': totalPieces > 0 ? '$totalPieces Pcs' : '-',
        'totalMtrs': formattedTotalMeters,
        'rate': core.rate > 0 ? currencyFmt.format(core.rate) : '-',
        'amount': formattedAmount(currencyFmt),
        'status': status,
      },
      children: lineItems.map((item) => item.toDyChildRowData(displayVoucherCode, currencyFmt)).toList(),
      rawData: core.rawJson,
    );
  }

  /// Copy with new line items
  MdlJwHeader copyWith({
    List<MdlJwLineItem>? lineItems,
  }) {
    return MdlJwHeader(
      core: core,
      lineItems: lineItems ?? this.lineItems,
    );
  }
}

/// [MdlJwLineItem] — Domain Data Model for a Detail Cut/Job Line Item (`sq_BILLDET`)
@immutable
class MdlJwLineItem {
  final SqBilldetModel core;

  const MdlJwLineItem({required this.core});

  int get srno => core.srNo;
  int get srNo => core.srNo;
  int get vno => core.vno;
  String get type => core.type;
  String get quality => core.quality.isNotEmpty ? core.quality : 'N/A';
  int get pieces => core.pieces.toInt();
  double get meters => core.meters;
  double get rate => core.rate;
  double get amount => core.amount;
  double get cutLength => core.cutLength;

  String formattedAmount([NumberFormat? fmt]) {
    if (amount <= 0) return '₹0.00';
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(amount);
  }

  /// Convert into a Tier 3 Detail Line Item Row for [DyTable]
  DyTableRowData toDyChildRowData(String parentVno, [NumberFormat? fmt]) {
    final currencyFmt = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DyTableRowData(
      id: '${type}_${core.cno}_${vno}_${core.srNo}',
      rowType: DyTableRowType.child,
      parentId: parentVno,
      voucherNo: 'ITEM #${core.srNo}',
      partyName: quality,
      data: {
        'vno': 'ITEM #${core.srNo}',
        'partyName': quality,
        'designPattern': quality,
        'totalMtrs': meters > 0 ? '${meters.toStringAsFixed(1)} Mtr' : '-',
        'quantity': meters > 0 ? '${meters.toStringAsFixed(1)} Mtr ($pieces Pcs)' : '$pieces Pcs',
        'totalPcs': pieces > 0 ? '$pieces Pcs' : '-',
        'pcs': pieces > 0 ? '$pieces' : '-',
        'rate': rate > 0 ? currencyFmt.format(rate) : '-',
        'amount': formattedAmount(currencyFmt),
        'status': 'COMPLETED',
      },
      rawData: core.rawJson,
    );
  }
}
