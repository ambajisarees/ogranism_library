import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sq_PINVTRN
================================================================================
Database Table: IMMBE2627.sq_PINVTRN (Airbyte Mirrored Read-Only Detail Table — 6,785 rows)
Total Supabase Postgres Columns: 60 columns
Primary Key: CARDNO (bigint, NOT NULL — Unique Lot Card Number)

1. ACTIVELY USED COLUMNS & 3-4 WORD DOMAIN LOGIC (21 Mapped Fields):
--------------------------------------------------------------------------------
- CARDNO          : Unique sent lot card number
- MILL            : Processing mill ledger name
- WEAVER          : Grey weaver supplier name
- BROKER_CODE     : Agent or broker name
- CNO             : Company ID (always 4)
- VNO             : Linked purchase voucher number
- TYPE            : Voucher type (always P1)
- QUAL            : Grey fabric quality description
- WMTS            : Original sent grey meters
- WPCS            : Original sent grey takas
- RATE            : Grey purchase rate per meter
- DDATE           : Dispatch date to mill
- WCHAL           : Weaver challan sequence number
- WCHDAT          : Weaver challan issuance date
- LOT             : Mill lot sequence number
- WRMK            : Weaver dispatch remarks text
- DRMK            : Mill receipt remarks text
- CREATOR         : User ID who entered
- UPDATER         : User ID last edited
- CREATETIME      : Record creation timestamp
- UPDATETIME      : Record update timestamp

2. SAMPLE 0-COUNT / 100% NULL COLUMNS (Verified in Supabase):
--------------------------------------------------------------------------------
- CLOSED          : 0 non-null / 6,785 NULLs (100% NULL)
- DESIGN          : 0 non-null / 6,785 NULLs (100% NULL)
- EWB_NO          : 0 non-null / 6,785 NULLs (100% NULL)
- GODOWN_CARDNO   : 0 non-null / 6,785 NULLs (100% NULL)
- VEHICLE_NO      : 0 non-null / 6,785 NULLs (100% NULL)

3. UNUSED / OMITTED COLUMNS & 3-4 WORD DOMAIN LOGIC (39 Fields Omitted):
--------------------------------------------------------------------------------
- PURRATE         : Duplicate purchase rate (use RATE)
- CLN               : Duplicate challan sequence string
- INS_POLICY      : Unused insurance policy code
- PROGRAMTYPE     : Unused production program type
- _airbyte_*       : Airbyte internal metadata fields
================================================================================
*/

/// [SqPinvtrnModel] — Refined 1-to-1 Data Model for `sq_PINVTRN` (Grey Stock Dispatches & Sent Lot Cards).
@immutable
class SqPinvtrnModel {
  final int cardNo;
  final String mill;
  final String weaver;
  final String broker;
  final int cno;
  final int vno;
  final String type;
  final String quality;
  final double wmts;
  final int wpcs;
  final double rate;
  final DateTime? dispatchDate;
  final String weaverChallan;
  final DateTime? challanDate;
  final String lotNo;
  final String weaverRemark;
  final String dispatchRemark;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final Map<String, dynamic> rawJson;

  const SqPinvtrnModel({
    required this.cardNo,
    required this.mill,
    required this.weaver,
    required this.broker,
    required this.cno,
    required this.vno,
    required this.type,
    required this.quality,
    required this.wmts,
    required this.wpcs,
    required this.rate,
    this.dispatchDate,
    required this.weaverChallan,
    this.challanDate,
    required this.lotNo,
    required this.weaverRemark,
    required this.dispatchRemark,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory matching Postgres 17 types safely.
  factory SqPinvtrnModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqPinvtrnModel(
      cardNo: (json['CARDNO'] as num?)?.toInt() ?? 0,
      mill: (json['MILL'] as String?)?.trim() ?? '',
      weaver: (json['WEAVER'] as String?)?.trim() ?? '',
      broker: (json['BROKER_CODE'] as String?)?.trim() ?? '',
      cno: (json['CNO'] as num?)?.toInt() ?? 4,
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      type: (json['TYPE'] as String?)?.trim() ?? 'P1',
      quality: (json['QUAL'] as String?)?.trim() ?? '',
      wmts: (json['WMTS'] as num?)?.toDouble() ?? 0.0,
      wpcs: (json['WPCS'] as num?)?.toInt() ?? 0,
      rate: (json['RATE'] as num?)?.toDouble() ?? (json['PURRATE'] as num?)?.toDouble() ?? 0.0,
      dispatchDate: parseDate(json['DDATE']),
      weaverChallan: (json['WCHAL'] as String?)?.trim() ?? '',
      challanDate: parseDate(json['WCHDAT']),
      lotNo: (json['LOT'] as String?)?.trim() ?? '',
      weaverRemark: (json['WRMK'] as String?)?.trim() ?? '',
      dispatchRemark: (json['DRMK'] as String?)?.trim() ?? '',
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseDate(json['CREATETIME']),
      lastEdited: parseDate(json['UPDATETIME']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'CARDNO': cardNo,
    'MILL': mill,
    'WEAVER': weaver,
    'BROKER_CODE': broker,
    'CNO': cno,
    'VNO': vno,
    'TYPE': type,
    'QUAL': quality,
    'WMTS': wmts,
    'WPCS': wpcs,
    'RATE': rate,
    'DDATE': dispatchDate?.toIso8601String(),
    'WCHAL': weaverChallan,
    'WCHDAT': challanDate?.toIso8601String(),
    'LOT': lotNo,
    'WRMK': weaverRemark,
    'DRMK': dispatchRemark,
    'CREATOR': author,
    'UPDATER': updater,
    'CREATETIME': createdOn?.toIso8601String(),
    'UPDATETIME': lastEdited?.toIso8601String(),
  };

  // Domain Helper Getters
  bool get isCurrentFY => cardNo > 0 && cardNo < 100000;
  bool get isCarriedForward => cardNo >= 100000;
  double get totalGreyValue => wmts * (rate > 0 ? rate : 180.0);
  String get dispatchDateStr => dispatchDate != null ? '${dispatchDate!.day}/${dispatchDate!.month}/${dispatchDate!.year}' : 'N/A';
}

/// Refined Standardized UI Field Labels for `sq_PINVTRN`
abstract class SqPinvtrnLabels {
  static const String cardNo = 'CARD-No';
  static const String mill = 'Mill';
  static const String weaver = 'Weaver';
  static const String broker = 'Broker';
  static const String cno = 'CNO';
  static const String vocNo = 'VOC-No';
  static const String type = 'TYPE';
  static const String fabric = 'Fabric';
  static const String greyMtrs = 'Grey Mtrs';
  static const String greyPcs = 'Grey Pcs';
  static const String greyRate = 'Grey Rate';
  static const String dispDate = 'Disp Date';
  static const String clnNo = 'CLN-No';
  static const String chalDate = 'Chal Date';
  static const String lotNo = 'LOT-No';
  static const String weaverRemark = 'Weaver Remark';
  static const String dispatchRemark = 'Dispatch Remark';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
}

/// Dynamic Table UI Mapper Extension for `SqPinvtrnModel`
extension SqPinvtrnTableMapper on SqPinvtrnModel {
  DynamicTableRowData toRowData([NumberFormat? currencyFmt]) {
    final fmt = currencyFmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DynamicTableRowData(
      id: cardNo.toString(),
      voucherNo: dispatchDateStr,
      partyName: mill.isNotEmpty ? mill : (weaver.isNotEmpty ? weaver : 'Unknown Mill'),
      designPattern: quality.isNotEmpty ? quality : 'N/A',
      quantity: '${wmts.toInt()} Mtr',
      amount: fmt.format(totalGreyValue),
      amountValue: totalGreyValue,
      status: isCarriedForward ? 'CF' : 'Active',
      rawData: toJson(),
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: SqPinvtrnLabels.cardNo, key: 'id', flex: 2),
    DynamicTableColumnSpec(label: SqPinvtrnLabels.mill, key: 'partyName', flex: 3),
    DynamicTableColumnSpec(label: SqPinvtrnLabels.fabric, key: 'designPattern', flex: 3),
    DynamicTableColumnSpec(label: SqPinvtrnLabels.greyMtrs, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SqPinvtrnLabels.greyRate, key: 'amount', flex: 3),
    DynamicTableColumnSpec(label: SqPinvtrnLabels.dispDate, key: 'voucherNo', flex: 2),
  ];
}
