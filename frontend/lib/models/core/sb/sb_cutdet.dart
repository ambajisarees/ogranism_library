import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/page/dy_table_pane.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sb_cutdet
================================================================================
Database Table: IMMBE2627.sb_cutdet (Active Saree Cutting Cards Table — 3,409 rows)
Total Supabase Postgres Columns: 83 columns

PRIMARY KEYS & FOREIGN KEYS:
--------------------------------------------------------------------------------
- CUTCARDNO (bigint, NOT NULL): Supabase Primary Key (Card #1 to #3409)
- MULTI_VNO (bigint, NOT NULL): Linked Parent Batch Sequence (CC-0001 to CC-0311)
- CARDNO (bigint, NOT NULL): Linked Sent Grey Card (sq_PINVTRN.CARDNO)
- reccardno (bigint, NOT NULL): Linked Received Mill Card (sq_MILLREC.RECCARDNO)

1. ACTIVELY USED COLUMNS & 3-4 WORD DOMAIN LOGIC (30 Mapped Fields):
--------------------------------------------------------------------------------
- CUTCARDNO       : Unique saree cutting card ID
- MULTI_VNO       : Parent batch sequence number
- CARDNO          : Sent grey lot card ID
- reccardno       : Received mill lot card ID
- DESPNO          : Mill dispatch note sequence
- MILL            : Processing mill ledger name
- WEAVER          : Grey weaver supplier name
- GREYQUAL        : Fabric quality description string
- lot             : Mill lot sequence number
- WMTS            : Original sent grey meters
- WPCS            : Original sent grey takas
- RMTS            : Finished received mill meters
- RPCS            : Finished received mill takas
- RATE            : Grey fabric purchase rate
- JOBRATE         : Mill processing rate/meter
- CCUT            : Cut saree length specification
- CMTS            : Total cut saree meters
- CPCS            : Fresh saree pieces produced
- SECONDS         : Defective seconds pieces produced
- FENT            : Fent waste meters length
- FENT_WT         : Fent waste weight (Kg)
- AVG_WT          : Average saree weight (Kg)
- CUTDATE         : Cutting card execution date
- DDATE           : Original mill dispatch date
- sb_status       : Cutting card status flag
- sb_cardpic      : Image URL array string
- sb_created_by   : User ID creator UUID
- sb_updated_by   : User ID updater UUID
- sb_created_at   : Record creation timestamp
- sb_updated_at   : Record update timestamp

2. SAMPLE 0-COUNT / 100% NULL COLUMNS (Verified in Supabase):
--------------------------------------------------------------------------------
- ADD_OTH1        : 0 non-null / 3,409 NULLs (100% NULL)
- CHALTRN_CPCS    : 0 non-null / 3,409 NULLs (100% NULL)
- DESIGNNO        : 0 non-null / 3,409 NULLs (100% NULL)
- OUTCUT1         : 0 non-null / 3,409 NULLs (100% NULL)
- UNLINKED_OUT_PCS: 0 non-null / 3,409 NULLs (100% NULL)

3. UNUSED / OMITTED COLUMNS & 3-4 WORD DOMAIN LOGIC (53 Fields Omitted):
--------------------------------------------------------------------------------
- outcut1         : Legacy secondary cut length
- outcut2         : Legacy tertiary cut length
- fent            : Duplicate fent meter field
- cutter_name     : Legacy manual cutter name
- rmk             : Legacy card remarks text
- creator         : Legacy text creator string
- updater         : Legacy text updater string
================================================================================
*/

/// [SbCutdetModel] — Canonical Data Model for `sb_cutdet` (Active Saree Cutting Cards).
@immutable
class SbCutdetModel {
  final int cutCardNo;
  final int multiVno;
  final int cardNo;
  final int recCardNo;
  final int despNo;
  final String mill;
  final String weaver;
  final String quality;
  final String lotNo;
  final double greyMtrs;
  final int greyPcs;
  final double recMtrs;
  final int recPcs;
  final double greyRate;
  final double jobRate;
  final double cutLength;
  final double cutMtrs;
  final int freshPcs;
  final int secondsPcs;
  final double fentMts;
  final double fentWt; // Weight in Grams
  final double avgWt; // Saree Weight in Grams
  final DateTime cutDate;
  final DateTime? dispatchDate;
  final String status;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final Map<String, dynamic> rawJson;

  const SbCutdetModel({
    required this.cutCardNo,
    required this.multiVno,
    required this.cardNo,
    required this.recCardNo,
    required this.despNo,
    required this.mill,
    required this.weaver,
    required this.quality,
    required this.lotNo,
    required this.greyMtrs,
    required this.greyPcs,
    required this.recMtrs,
    required this.recPcs,
    required this.greyRate,
    required this.jobRate,
    required this.cutLength,
    required this.cutMtrs,
    required this.freshPcs,
    required this.secondsPcs,
    required this.fentMts,
    required this.fentWt,
    required this.avgWt,
    required this.cutDate,
    this.dispatchDate,
    required this.status,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory matching Postgres 17 types safely.
  factory SbCutdetModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseOptDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SbCutdetModel(
      cutCardNo: (json['CUTCARDNO'] as num?)?.toInt() ?? 0,
      multiVno: (json['MULTI_VNO'] as num?)?.toInt() ?? 0,
      cardNo: (json['CARDNO'] as num?)?.toInt() ?? 0,
      recCardNo: (json['reccardno'] as num?)?.toInt() ?? 0,
      despNo: (json['DESPNO'] as num?)?.toInt() ?? 0,
      mill: (json['MILL'] as String?)?.trim() ?? '',
      weaver: (json['WEAVER'] as String?)?.trim() ?? '',
      quality: (json['GREYQUAL'] as String?)?.trim() ?? '',
      lotNo: (json['lot'] as String?)?.trim() ?? '',
      greyMtrs: (json['WMTS'] as num?)?.toDouble() ?? 0.0,
      greyPcs: (json['WPCS'] as num?)?.toInt() ?? 0,
      recMtrs: (json['RMTS'] as num?)?.toDouble() ?? 0.0,
      recPcs: (json['RPCS'] as num?)?.toInt() ?? 0,
      greyRate: (json['RATE'] as num?)?.toDouble() ?? 0.0,
      jobRate: (json['JOBRATE'] as num?)?.toDouble() ?? 0.0,
      cutLength: (json['CCUT'] as num?)?.toDouble() ?? 5.25,
      cutMtrs: (json['CMTS'] as num?)?.toDouble() ?? 0.0,
      freshPcs: (json['CPCS'] as num?)?.toInt() ?? 0,
      secondsPcs: (json['SECONDS'] as num?)?.toInt() ?? 0,
      fentMts: (json['FENT'] as num?)?.toDouble() ?? 0.0,
      fentWt: (json['FENT_WT'] as num?)?.toDouble() ?? 0.0,
      avgWt: (json['AVG_WT'] as num?)?.toDouble() ?? 0.0,
      cutDate: parseDate(json['CUTDATE']),
      dispatchDate: parseOptDate(json['DDATE']),
      status: (json['sb_status'] as String?)?.trim() ?? 'PENDING',
      author: (json['sb_created_by'] as String?)?.trim() ?? '',
      updater: (json['sb_updated_by'] as String?)?.trim() ?? '',
      createdOn: parseOptDate(json['sb_created_at']),
      lastEdited: parseOptDate(json['sb_updated_at']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'CUTCARDNO': cutCardNo,
    'MULTI_VNO': multiVno,
    'CARDNO': cardNo,
    'reccardno': recCardNo,
    'DESPNO': despNo,
    'MILL': mill,
    'WEAVER': weaver,
    'GREYQUAL': quality,
    'lot': lotNo,
    'WMTS': greyMtrs,
    'WPCS': greyPcs,
    'RMTS': recMtrs,
    'RPCS': recPcs,
    'RATE': greyRate,
    'JOBRATE': jobRate,
    'CCUT': cutLength,
    'CMTS': cutMtrs,
    'CPCS': freshPcs,
    'SECONDS': secondsPcs,
    'FENT': fentMts,
    'FENT_WT': fentWt,
    'AVG_WT': avgWt,
    'CUTDATE': cutDate.toIso8601String(),
    'DDATE': dispatchDate?.toIso8601String(),
    'CNO': 4,
    'TYPE': 'J1',
    'MULTI_CNO': 4,
    'MULTI_TYPE': '03',
    'closed': 'Y',
    'sb_status': status,
    'sb_created_by': author,
    'sb_updated_by': updater,
    'sb_created_at': createdOn?.toIso8601String(),
    'sb_updated_at': lastEdited?.toIso8601String(),
  };

  // Domain Helper Getters
  double get totalRate => greyRate + jobRate;
  double get totalGreyInvestment => greyMtrs * greyRate;
  double get totalProcessingInvestment => recMtrs * jobRate;
  double get totalLandedInvestment => totalGreyInvestment + totalProcessingInvestment;
  double get costPerFreshPiece => freshPcs > 0 ? totalLandedInvestment / freshPcs : 0.0;
  String get cutDateStr => '${cutDate.day}/${cutDate.month}/${cutDate.year}';
}

/// Refined Standardized UI Field Labels for `sb_cutdet`
abstract class SbCutdetLabels {
  static const String cutCardNo = 'CUT-No';
  static const String multiVno = 'CC-VNO';
  static const String cardNo = 'CARD-No';
  static const String recCardNo = 'REC-No';
  static const String despNo = 'DESP-No';
  static const String mill = 'Mill';
  static const String weaver = 'Weaver';
  static const String fabric = 'Fabric';
  static const String lotNo = 'LOT-No';
  static const String greyMtrs = 'Grey Mtrs';
  static const String greyPcs = 'Grey Pcs';
  static const String recMtrs = 'Rec Mtrs';
  static const String recPcs = 'Rec Pcs';
  static const String greyRate = 'Grey Rate';
  static const String jobRate = 'Job Rate';
  static const String cut = 'Cut';
  static const String cutMtrs = 'Cut Mtrs';
  static const String freshPcs = 'Fresh Pcs';
  static const String secPcs = 'Sec Pcs';
  static const String fentMtrs = 'Fent Mtrs';
  static const String fentWt = 'Fent Wt';
  static const String sareeWt = 'Saree Wt';
  static const String cutDate = 'Cut Date';
  static const String dispDate = 'Disp Date';
  static const String status = 'Status';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
}

/// Dynamic Table UI Mapper Extension for `SbCutdetModel`
extension SbCutdetTableMapper on SbCutdetModel {
  DynamicTableRowData toRowData([NumberFormat? currencyFmt]) {
    final fmt = currencyFmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DynamicTableRowData(
      id: cutCardNo.toString(),
      voucherNo: 'CUT #$cutCardNo',
      partyName: mill.isNotEmpty ? mill : 'Unknown Mill',
      designPattern: quality.isNotEmpty ? quality : 'N/A',
      quantity: '$freshPcs Pcs ($recMtrs Mtr)',
      amount: fmt.format(costPerFreshPiece),
      amountValue: costPerFreshPiece,
      status: status.isNotEmpty ? status : 'PENDING',
      rawData: toJson(),
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: SbCutdetLabels.cutCardNo, key: 'voucherNo', flex: 2),
    DynamicTableColumnSpec(label: SbCutdetLabels.mill, key: 'partyName', flex: 3),
    DynamicTableColumnSpec(label: SbCutdetLabels.fabric, key: 'designPattern', flex: 3),
    DynamicTableColumnSpec(label: SbCutdetLabels.freshPcs, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SbCutdetLabels.greyRate, key: 'amount', flex: 3),
  ];
}
