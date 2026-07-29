import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sq_MILLREC
================================================================================
Database Table: IMMBE2627.sq_MILLREC (Airbyte Mirrored Read-Only Receipt Table — 14,333 rows)
Total Supabase Postgres Columns: 51 columns
Primary Key: RECCARDNO (bigint, NOT NULL — Unique Mill Receipt Card Number)
Foreign Key: CARDNO links to sq_PINVTRN.CARDNO

1. ACTIVELY USED COLUMNS & 3-4 WORD DOMAIN LOGIC (19 Mapped Fields):
--------------------------------------------------------------------------------
- RECCARDNO        : Unique mill receipt card ID
- CARDNO           : Sent grey lot card ID
- MILL_CODE        : Processing mill ledger name
- VNO              : Linked purchase voucher number
- DESPNO           : Mill dispatch note sequence
- GREYQUAL         : Finished fabric quality name
- RMTS             : Received finished fabric meters
- RPCS             : Received finished fabric takas
- WMTS             : Original sent grey meters
- WPCS             : Original sent grey takas
- JOBRATE          : Mill processing rate/meter
- RATE             : Grey fabric purchase rate
- CUTDATE          : Receipt cutting date stamp
- lot              : Mill lot sequence number
- RMK              : Mill receipt remarks text
- CREATOR          : User ID who entered
- UPDATER          : User ID last edited
- CREATETIME       : Record creation timestamp
- UPDATETIME       : Record update timestamp

2. SAMPLE 0-COUNT / 100% NULL COLUMNS (Verified in Supabase):
--------------------------------------------------------------------------------
- chaldate         : 0 non-null / 14,333 NULLs (100% NULL)
- chalno           : 0 non-null / 14,333 NULLs (100% NULL)
- CLOSED_UNCUT     : 0 non-null / 14,333 NULLs (100% NULL)
- PRINT_STYLE      : 0 non-null / 14,333 NULLs (100% NULL)
- SCREEN           : 0 non-null / 14,333 NULLs (100% NULL)

3. UNUSED / OMITTED COLUMNS & 3-4 WORD DOMAIN LOGIC (32 Fields Omitted):
--------------------------------------------------------------------------------
- GREYRATE         : Duplicate grey rate (use RATE)
- MILL             : Legacy mill code string
- CNO              : Company master ID (always 4)
- TYPE             : Voucher category (always J1)
- _airbyte_*       : Airbyte internal metadata fields
================================================================================
*/

/// [SqMillrecModel] — Refined Canonical Model for `sq_MILLREC` (Mill Process Receipts).
@immutable
class SqMillrecModel {
  final int recCardNo;
  final int cardNo;
  final String mill;
  final int vno;
  final int despNo;
  final String quality;
  final double recMtrs;
  final int recPcs;
  final double greyMtrs;
  final int greyPcs;
  final double jobRate;
  final double greyRate;
  final DateTime? cutDate;
  final String lotNo;
  final String remarks;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final Map<String, dynamic> rawJson;

  const SqMillrecModel({
    required this.recCardNo,
    required this.cardNo,
    required this.mill,
    required this.vno,
    required this.despNo,
    required this.quality,
    required this.recMtrs,
    required this.recPcs,
    required this.greyMtrs,
    required this.greyPcs,
    required this.jobRate,
    required this.greyRate,
    this.cutDate,
    required this.lotNo,
    required this.remarks,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory matching Postgres 17 types safely.
  factory SqMillrecModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqMillrecModel(
      recCardNo: (json['RECCARDNO'] as num?)?.toInt() ?? 0,
      cardNo: (json['CARDNO'] as num?)?.toInt() ?? 0,
      mill: (json['MILL_CODE'] as String?)?.trim() ?? (json['MILL'] as String?)?.trim() ?? '',
      vno: (json['VNO'] as num?)?.toInt() ?? 0,
      despNo: (json['DESPNO'] as num?)?.toInt() ?? 0,
      quality: (json['GREYQUAL'] as String?)?.trim() ?? '',
      recMtrs: (json['RMTS'] as num?)?.toDouble() ?? 0.0,
      recPcs: (json['RPCS'] as num?)?.toInt() ?? 0,
      greyMtrs: (json['WMTS'] as num?)?.toDouble() ?? 0.0,
      greyPcs: (json['WPCS'] as num?)?.toInt() ?? 0,
      jobRate: (json['JOBRATE'] as num?)?.toDouble() ?? 0.0,
      greyRate: (json['RATE'] as num?)?.toDouble() ?? (json['GREYRATE'] as num?)?.toDouble() ?? 0.0,
      cutDate: parseDate(json['CUTDATE']),
      lotNo: (json['lot'] as String?)?.trim() ?? (json['LOT'] as String?)?.trim() ?? '',
      remarks: (json['RMK'] as String?)?.trim() ?? '',
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseDate(json['CREATETIME']),
      lastEdited: parseDate(json['UPDATETIME']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'RECCARDNO': recCardNo,
    'CARDNO': cardNo,
    'MILL_CODE': mill,
    'VNO': vno,
    'DESPNO': despNo,
    'GREYQUAL': quality,
    'RMTS': recMtrs,
    'RPCS': recPcs,
    'WMTS': greyMtrs,
    'WPCS': greyPcs,
    'JOBRATE': jobRate,
    'RATE': greyRate,
    'CUTDATE': cutDate?.toIso8601String(),
    'lot': lotNo,
    'RMK': remarks,
    'CREATOR': author,
    'UPDATER': updater,
    'CREATETIME': createdOn?.toIso8601String(),
    'UPDATETIME': lastEdited?.toIso8601String(),
  };

  // Domain Helper Getters
  bool get isCurrentFY => vno > 0 && vno < 100000;
  bool get isCarriedForward => vno >= 100000;
  double get totalJobCost => recMtrs * jobRate;
  double get totalLandedCost => recMtrs * (greyRate + jobRate);
  String get cutDateStr => cutDate != null ? '${cutDate!.day}/${cutDate!.month}/${cutDate!.year}' : 'N/A';
}

/// Refined Standardized UI Field Labels for `sq_MILLREC`
abstract class SqMillrecLabels {
  static const String recNo = 'REC-No';
  static const String cardNo = 'CARD-No';
  static const String mill = 'Mill';
  static const String vocNo = 'VOC-No';
  static const String despNo = 'DESP-No';
  static const String fabric = 'Fabric';
  static const String recMtrs = 'Rec Mtrs';
  static const String recPcs = 'Rec Pcs';
  static const String greyMtrs = 'Grey Mtrs';
  static const String greyPcs = 'Grey Pcs';
  static const String jobRate = 'Job Rate';
  static const String greyRate = 'Grey Rate';
  static const String cutDate = 'Cut Date';
  static const String lotNo = 'LOT-No';
  static const String remarks = 'Mill Remarks';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
}

/// Dynamic Table UI Mapper Extension for `SqMillrecModel`
extension SqMillrecTableMapper on SqMillrecModel {
  DynamicTableRowData toRowData([NumberFormat? currencyFmt]) {
    final fmt = currencyFmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DynamicTableRowData(
      id: recCardNo.toString(),
      voucherNo: cutDateStr,
      partyName: mill.isNotEmpty ? mill : 'Unknown Mill',
      designPattern: quality.isNotEmpty ? quality : 'N/A',
      quantity: '${recMtrs.toInt()} Mtr',
      amount: fmt.format(totalLandedCost),
      amountValue: totalLandedCost,
      status: isCarriedForward ? 'CF' : 'Active',
      rawData: toJson(),
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: SqMillrecLabels.recNo, key: 'id', flex: 2),
    DynamicTableColumnSpec(label: SqMillrecLabels.mill, key: 'partyName', flex: 3),
    DynamicTableColumnSpec(label: SqMillrecLabels.fabric, key: 'designPattern', flex: 3),
    DynamicTableColumnSpec(label: SqMillrecLabels.recMtrs, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SqMillrecLabels.jobRate, key: 'amount', flex: 3),
    DynamicTableColumnSpec(label: SqMillrecLabels.cutDate, key: 'voucherNo', flex: 2),
  ];
}
