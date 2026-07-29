import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sq_CHALTRN
================================================================================
Database Table: IMMBE2627.sq_CHALTRN (Airbyte Mirrored Read-Only Line Detail Table — 59,970 rows)
Total Supabase Postgres Columns: 50 columns
Primary Composite Keys: CARDNO, TAKASRNO
Foreign Keys: 
  - CARDNO links to sq_PINVTRN.CARDNO (Sent Lot Header)
  - RECCARDNO links to sq_MILLREC.RECCARDNO (Received Lot Header)
  - PVNO links to sq_BILLS.VNO (Purchase Invoice Header)

1. ACTIVELY USED COLUMNS & 3-4 WORD DOMAIN LOGIC (15 Mapped Fields):
--------------------------------------------------------------------------------
- TAKASRNO   : Individual taka roll number (1-96)
- CARDNO     : Sent grey lot card ID
- RECCARDNO  : Received mill lot card ID
- TAKAGROUP  : Taka roll grouping category string
- PVNO       : Purchase bill voucher number
- AUTOSRNO   : Auto increment detail line ID
- DMTS       : Original sent weaver grey meters
- RMTS       : Finished received roll meters
- RECRMK     : Roll cut breakup notes (e.g. 122+8)
- CREATOR    : User ID who entered
- UPDATER    : User ID last edited
- CREATETIME : Record creation timestamp
- UPDATETIME : Record update timestamp
- _sync_time : Airbyte sync timestamp
- DISPUTE    : Taka quality dispute flag (Y/N)

2. SAMPLE 0-COUNT / 100% NULL COLUMNS (Verified in Supabase):
--------------------------------------------------------------------------------
- DISPUTEAMT : 0 non-null / 59,970 NULLs (100% NULL)
- DISPUTERMK : 0 non-null / 59,970 NULLs (100% NULL)
- FOLD_LENGTH: 0 non-null / 59,970 NULLs (100% NULL)
- GREYSRNO   : 0 non-null / 59,970 NULLs (100% NULL)
- uncut_mts  : 0 non-null / 59,970 NULLs (100% NULL)

3. UNUSED / OMITTED COLUMNS & 3-4 WORD DOMAIN LOGIC (35 Fields Omitted):
--------------------------------------------------------------------------------
- WMTS       : Unused duplicate grey meters (use DMTS)
- TAKA_WT    : Sent grey roll weight (Kg)
- RTAKA_WT   : Received roll weight (Kg)
- MMTS       : Mill process meters calculation
- CCUT       : Cutting saree length specification
- CMTS       : Total cut saree meters
- CPCS       : Total cut saree pieces
- FENT       : Fent waste meters length
- WRMK       : Weaver roll remark string
- _airbyte_* : Airbyte internal metadata fields
================================================================================
*/

/// [SqChaltrnModel] — Refined Canonical 1-to-1 Data Model for `sq_CHALTRN` (Roll/Taka Details).
@immutable
class SqChaltrnModel {
  final int takaSrNo;
  final int cardNo;
  final int recCardNo;
  final String takaGroup;
  final int pvNo;
  final int autoSrNo;
  final double greyMtrs; // DMTS
  final double recMtrs; // RMTS
  final String recRemarks; // RECRMK
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final DateTime? syncTime;
  final String dispute;
  final Map<String, dynamic> rawJson;

  const SqChaltrnModel({
    required this.takaSrNo,
    required this.cardNo,
    required this.recCardNo,
    required this.takaGroup,
    required this.pvNo,
    required this.autoSrNo,
    required this.greyMtrs,
    required this.recMtrs,
    required this.recRemarks,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    this.syncTime,
    required this.dispute,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory matching Postgres 17 types safely.
  factory SqChaltrnModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqChaltrnModel(
      takaSrNo: (json['TAKASRNO'] as num?)?.toInt() ?? 0,
      cardNo: (json['CARDNO'] as num?)?.toInt() ?? 0,
      recCardNo: (json['RECCARDNO'] as num?)?.toInt() ?? 0,
      takaGroup: (json['TAKAGROUP'] as String?)?.trim() ?? '',
      pvNo: (json['PVNO'] as num?)?.toInt() ?? 0,
      autoSrNo: (json['AUTOSRNO'] as num?)?.toInt() ?? 0,
      greyMtrs: (json['DMTS'] as num?)?.toDouble() ?? (json['WMTS'] as num?)?.toDouble() ?? 0.0,
      recMtrs: (json['RMTS'] as num?)?.toDouble() ?? 0.0,
      recRemarks: (json['RECRMK'] as String?)?.trim() ?? '',
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseDate(json['CREATETIME']),
      lastEdited: parseDate(json['UPDATETIME']),
      syncTime: parseDate(json['_sync_time']),
      dispute: (json['DISPUTE'] as String?)?.trim() ?? '',
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'TAKASRNO': takaSrNo,
    'CARDNO': cardNo,
    'RECCARDNO': recCardNo,
    'TAKAGROUP': takaGroup,
    'PVNO': pvNo,
    'AUTOSRNO': autoSrNo,
    'DMTS': greyMtrs,
    'RMTS': recMtrs,
    'RECRMK': recRemarks,
    'CREATOR': author,
    'UPDATER': updater,
    'CREATETIME': createdOn?.toIso8601String(),
    'UPDATETIME': lastEdited?.toIso8601String(),
    '_sync_time': syncTime?.toIso8601String(),
    'DISPUTE': dispute,
  };

  // Domain Helper Getters
  bool get isReceived => recCardNo > 0 || recMtrs > 0;
  double get shrinkageMeters => greyMtrs > recMtrs && recMtrs > 0 ? greyMtrs - recMtrs : 0.0;
  double get shrinkagePercent => greyMtrs > 0 && recMtrs > 0 ? (shrinkageMeters / greyMtrs) * 100 : 0.0;
}

/// Refined Standardized UI Field Labels for `sq_CHALTRN`
abstract class SqChaltrnLabels {
  static const String takaNo = 'TAKA-No';
  static const String cardNo = 'CARD-No';
  static const String recNo = 'REC-No';
  static const String group = 'Group';
  static const String vocNo = 'VOC-No';
  static const String autoNo = 'Auto-No';
  static const String greyMtrs = 'Grey Mtrs';
  static const String recMtrs = 'Rec Mtrs';
  static const String recRemarks = 'Rec Remarks';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
  static const String syncTime = 'Sync Time';
  static const String dispute = 'Dispute';
}

/// Dynamic Table UI Mapper Extension for `SqChaltrnModel`
extension SqChaltrnTableMapper on SqChaltrnModel {
  DynamicTableRowData toRowData([NumberFormat? currencyFmt]) {
    return DynamicTableRowData(
      id: '${cardNo}_$takaSrNo',
      voucherNo: 'Taka #$takaSrNo',
      partyName: takaGroup.isNotEmpty ? takaGroup : 'Standard Roll',
      designPattern: recRemarks.isNotEmpty ? recRemarks : 'N/A',
      quantity: '${greyMtrs.toInt()} Mtr',
      amount: isReceived ? '${recMtrs.toInt()} Mtr Rec' : 'Pending',
      amountValue: greyMtrs,
      status: isReceived ? 'Received' : 'Pending',
      rawData: toJson(),
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: SqChaltrnLabels.takaNo, key: 'voucherNo', flex: 2),
    DynamicTableColumnSpec(label: SqChaltrnLabels.cardNo, key: 'id', flex: 2),
    DynamicTableColumnSpec(label: SqChaltrnLabels.greyMtrs, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SqChaltrnLabels.recMtrs, key: 'amount', flex: 3),
    DynamicTableColumnSpec(label: SqChaltrnLabels.recRemarks, key: 'designPattern', flex: 3),
  ];
}
