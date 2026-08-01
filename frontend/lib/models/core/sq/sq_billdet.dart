import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/page/dy_table_pane.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sq_BILLDET
================================================================================
Database Table: IMMBE2627.sq_BILLDET (Airbyte Mirrored Read-Only Detail Line Table — 20,524 rows)
Total Supabase Postgres Columns: 86 columns
Primary Composite Keys: CNO (bigint), VNO (bigint), TYPE (varchar), SRNO (bigint)
Foreign Keys to sq_BILLS: CNO, VNO, TYPE

1. ACTIVELY USED COLUMNS & 3-4 WORD DOMAIN LOGIC (24 Mapped Fields):
--------------------------------------------------------------------------------
- CNO         : Company master ID (always 4)
- VNO         : Linked invoice voucher number
- TYPE        : Voucher category type code
- SRNO        : Line item serial sequence
- qual        : Fabric quality item description
- MTS         : Line item fabric meters
- PCS         : Line item fabric pieces
- RATE        : Unit price rate per meter
- AMT         : Line item total financial amount
- CUT         : Individual saree cut length
- UNIT        : Billing unit (MTR/PCS)
- PACK        : Packaging style (CHAINBAG/NAKED)
- HSN_CODE    : GST HSN tax code
- orderno     : Linked sales purchase order ID
- ORDBILL     : Linked order bill sequence
- ORDTYPE     : Linked order category type
- ORDSRNO     : Linked order serial sequence
- DETAILS     : Line item special remarks
- discamt     : Line item discount amount
- CREATOR     : User ID who entered
- UPDATER     : User ID last edited
- CREATETIME  : Record creation timestamp
- UPDATETIME  : Record update timestamp
- _sync_time  : Airbyte sync timestamp

2. SAMPLE 0-COUNT / 100% NULL COLUMNS (Verified in Supabase):
--------------------------------------------------------------------------------
- ADJUST_BILL : 0 non-null / 20,524 NULLs (100% NULL)
- DETRD_AMT   : 0 non-null / 20,524 NULLs (100% NULL)
- JOB_LESS_PCS: 0 non-null / 20,524 NULLs (100% NULL)
- RF_PCS      : 0 non-null / 20,524 NULLs (100% NULL)
- WORK_TYPE   : 0 non-null / 20,524 NULLs (100% NULL)

3. UNUSED / OMITTED COLUMNS & 3-4 WORD DOMAIN LOGIC (62 Fields Omitted):
--------------------------------------------------------------------------------
- BASEQUAL    : Duplicate base quality string
- altqual     : Alternate quality description
- RANGE       : Saree price range category
- AVG_WT      : Line item fabric weight
- CLOSED      : Line item pendency status
- REFPTY      : Reference party ledger name
- TP_PCS      : Third party pieces count
- _airbyte_*  : Airbyte internal metadata fields
================================================================================
*/

/// [SqBilldetModel] — Refined Canonical 1-to-1 Data Model for `sq_BILLDET` (Invoice Line Items).
@immutable
class SqBilldetModel {
  final int cno;
  final int vno;
  final String type;
  final int srNo;
  final String quality;
  final double meters;
  final double pieces;
  final double rate;
  final double amount;
  final double cutLength;
  final String unit;
  final String packing;
  final String hsnCode;
  final int orderNo;
  final String ordBill;
  final String ordType;
  final int ordSrNo;
  final String remarks;
  final double discountAmt;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final DateTime? syncTime;
  final Map<String, dynamic> rawJson;

  const SqBilldetModel({
    required this.cno,
    required this.vno,
    required this.type,
    required this.srNo,
    required this.quality,
    required this.meters,
    required this.pieces,
    required this.rate,
    required this.amount,
    required this.cutLength,
    required this.unit,
    required this.packing,
    required this.hsnCode,
    required this.orderNo,
    required this.ordBill,
    required this.ordType,
    required this.ordSrNo,
    required this.remarks,
    required this.discountAmt,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    this.syncTime,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory matching Postgres 17 types safely.
  factory SqBilldetModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqBilldetModel(
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: (json['TYPE'] as String?)?.trim() ?? '',
      srNo: (json['SRNO'] as num?)?.toInt() ?? 0,
      quality: (json['qual'] as String?)?.trim() ?? (json['BASEQUAL'] as String?)?.trim() ?? '',
      meters: (json['MTS'] as num?)?.toDouble() ?? 0.0,
      pieces: (json['PCS'] as num?)?.toDouble() ?? 0.0,
      rate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      amount: (json['AMT'] as num?)?.toDouble() ?? 0.0,
      cutLength: (json['CUT'] as num?)?.toDouble() ?? 0.0,
      unit: (json['UNIT'] as String?)?.trim() ?? 'MTR',
      packing: (json['PACK'] as String?)?.trim() ?? '',
      hsnCode: (json['HSN_CODE'] as String?)?.trim() ?? '',
      orderNo: (json['orderno'] as num?)?.toInt() ?? (json['ORDBILL'] as num?)?.toInt() ?? 0,
      ordBill: (json['ORDBILL'] as String?)?.trim() ?? '',
      ordType: (json['ORDTYPE'] as String?)?.trim() ?? '',
      ordSrNo: (json['ORDSRNO'] as num?)?.toInt() ?? 0,
      remarks: (json['DETAILS'] as String?)?.trim() ?? '',
      discountAmt: (json['discamt'] as num?)?.toDouble() ?? 0.0,
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseDate(json['CREATETIME']),
      lastEdited: parseDate(json['UPDATETIME']),
      syncTime: parseDate(json['_sync_time']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'CNO': cno,
    'VNO': vno,
    'TYPE': type,
    'SRNO': srNo,
    'qual': quality,
    'MTS': meters,
    'PCS': pieces,
    'RATE': rate,
    'AMT': amount,
    'CUT': cutLength,
    'UNIT': unit,
    'PACK': packing,
    'HSN_CODE': hsnCode,
    'orderno': orderNo,
    'ORDBILL': ordBill,
    'ORDTYPE': ordType,
    'ORDSRNO': ordSrNo,
    'DETAILS': remarks,
    'discamt': discountAmt,
    'CREATOR': author,
    'UPDATER': updater,
    'CREATETIME': createdOn?.toIso8601String(),
    'UPDATETIME': lastEdited?.toIso8601String(),
    '_sync_time': syncTime?.toIso8601String(),
  };

  // Domain Helper Getters
  bool get isCurrentFY => vno > 0 && vno < 100000;
  double get effectiveRatePerMtr => meters > 0 ? amount / meters : rate;
}

/// Refined Standardized UI Field Labels for `sq_BILLDET`
abstract class SqBilldetLabels {
  static const String cno = 'CNO';
  static const String vocNo = 'VOC-No';
  static const String type = 'TYPE';
  static const String srNo = 'SR-No';
  static const String fabric = 'Fabric';
  static const String mtrs = 'Mtrs';
  static const String pcs = 'Pcs';
  static const String rate = 'Rate';
  static const String amount = 'Amount';
  static const String cut = 'Cut';
  static const String unit = 'Unit';
  static const String packing = 'Packing';
  static const String hsnNo = 'HSN-No';
  static const String ordNo = 'ORD-No';
  static const String billNo = 'BILL-No';
  static const String orderType = 'Order Type';
  static const String ordSrNo = 'ORD-SR-No';
  static const String remarks = 'Remarks';
  static const String discAmt = 'Disc Amt';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
  static const String syncTime = 'Sync Time';
}

/// Dynamic Table UI Mapper Extension for `SqBilldetModel`
extension SqBilldetTableMapper on SqBilldetModel {
  DynamicTableRowData toRowData([NumberFormat? currencyFmt]) {
    final fmt = currencyFmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DynamicTableRowData(
      id: '${type}_${vno}_$srNo',
      voucherNo: 'SR #$srNo',
      partyName: quality.isNotEmpty ? quality : 'Line Item',
      designPattern: packing.isNotEmpty ? packing : 'Standard',
      quantity: '${meters.toInt()} Mtr',
      amount: fmt.format(amount),
      amountValue: amount,
      status: isCurrentFY ? 'Active' : 'CF',
      rawData: toJson(),
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: SqBilldetLabels.srNo, key: 'voucherNo', flex: 2),
    DynamicTableColumnSpec(label: SqBilldetLabels.fabric, key: 'partyName', flex: 3),
    DynamicTableColumnSpec(label: SqBilldetLabels.mtrs, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SqBilldetLabels.rate, key: 'status', flex: 2),
    DynamicTableColumnSpec(label: SqBilldetLabels.amount, key: 'amount', flex: 3),
  ];
}
