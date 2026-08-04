import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/page/dy_table_pane.dart';

/*
================================================================================
SUPABASE TABLE SCHEMA DOCUMENTATION — sb_cutdet_summary
================================================================================
Database Table: IMMBE2627.sb_cutdet_summary (Batch Summary Table — 311 active rows)
Total Supabase Postgres Columns: 40 columns

PRIMARY KEYS & FOREIGN KEYS:
--------------------------------------------------------------------------------
- id (uuid, NOT NULL): Supabase Primary Key
- MULTI_VNO (bigint, NOT NULL): Cutting Batch Sequence Number (Primary Key #1 to #3428)
- cc_code (text): Formatted Cutting Batch Code (e.g. 'CC-0001', 'CC-0002')

1. ACTIVELY USED COLUMNS & 3-4 WORD DOMAIN LOGIC (34 Mapped Fields):
--------------------------------------------------------------------------------
- id                 : Unique Supabase UUID key
- MULTI_VNO          : Cutting batch sequence number
- cc_code            : Formatted 4-digit cutting code
- MILL               : Processing mill ledger name
- GREYQUAL           : Fabric quality description string
- CUTDATE            : Batch cutting execution date
- CUT_LENGTH         : Cut saree length specification
- AVG_WT             : Average saree fabric weight
- TOTAL_RMTS         : Received finished fabric meters
- TOTAL_RPCS         : Received finished fabric takas
- TOTAL_WMTS         : Original sent grey meters
- TOTAL_DMTS         : Total mill dispatched meters
- GREY_RATE          : Weighted grey purchase rate
- JOB_RATE           : Weighted mill job rate
- total_investment   : Total landed batch investment
- cost_per_pc        : Net landed cost/fresh saree
- TOTAL_FRESH_PCS    : Fresh saree pieces produced
- TOTAL_SECOND_PCS   : Defective seconds pieces produced
- TOTAL_FENT_MTS     : Total fent waste meters
- TOTAL_FENT_WT      : Total fent waste weight
- FRESH_PCT          : Fresh saree yield percentage
- SHORTAGE_PCT       : Mill processing shortage percentage
- SECOND_PCT         : Defective seconds yield percentage
- FENT_PCT           : Fent waste yield percentage
- JOB_TYPE           : Mill process category name
- VALUE_ADDITION     : Value addition work type
- CUTCARDNOS         : Array of child CUTCARDNOs
- RECCARDNOS         : Array of child reccardnos
- sb_status          : Batch completion status flag
- sb_cardpic         : Image URL array string
- sb_created_by      : User ID creator UUID
- sb_updated_by      : User ID updater UUID
- sb_created_at      : Record creation timestamp
- sb_updated_at      : Record update timestamp

2. SAMPLE 0-COUNT / 100% NULL COLUMNS (Verified in Supabase):
--------------------------------------------------------------------------------
- SCREEN             : 0 non-null / 311 NULLs (100% NULL)
- job_issued_date    : 0 non-null / 311 NULLs (100% NULL)
- job_received_date  : 0 non-null / 311 NULLs (100% NULL)
- job_card_vnos      : 0 non-null / 311 NULLs (100% NULL)

3. UNUSED / OMITTED COLUMNS & 3-4 WORD DOMAIN LOGIC (6 Fields Omitted):
--------------------------------------------------------------------------------
- cc_no              : Dropped redundant string number
- TOTAL_SAREE_WT     : Dropped unneeded weight sum
- grey_purchase_date : Unused grey purchase date
- stock_received_date: Unused stock receipt date

LANDED FINANCIAL FORMULAE:
--------------------------------------------------------------------------------
- Total Investment = (TOTAL_WMTS * GREY_RATE) + (TOTAL_RMTS * JOB_RATE).
- Cost per Saree Piece = Total Investment / TOTAL_FRESH_PCS.
================================================================================
*/

/// [SbCutdetSummaryModel] — Canonical Data Model for `sb_cutdet_summary` (Batch Summary).
@immutable
class SbCutdetSummaryModel {
  final String id;
  final int multiVno;
  final String ccCode;
  final String mill;
  final String quality;
  final DateTime cutDate;
  final double cutLength;
  final double avgWt;
  final double totalRmts;
  final int totalRpcs;
  final double totalWmts;
  final double totalDmts;
  final double greyRate;
  final double jobRate;
  final double totalInvestment;
  final double costPerPc;
  final int totalFreshPcs;
  final int totalSecondPcs;
  final double totalSecondMts;
  final double secondCut;
  final double totalFentMts;
  final double totalFentWt;
  final double freshPct;
  final double shortagePct;
  final double secondPct;
  final double fentPct;
  final String jobType;
  final String valueType;
  final DateTime? greyPurchaseDate;
  final DateTime? stockReceivedDate;
  final List<int> cutCardNos;
  final List<int> reccardNos;
  final String status;
  final List<String> cardPics;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final Map<String, dynamic> rawJson;

  const SbCutdetSummaryModel({
    required this.id,
    required this.multiVno,
    required this.ccCode,
    required this.mill,
    required this.quality,
    required this.cutDate,
    required this.cutLength,
    required this.avgWt,
    required this.totalRmts,
    required this.totalRpcs,
    required this.totalWmts,
    required this.totalDmts,
    required this.greyRate,
    required this.jobRate,
    required this.totalInvestment,
    required this.costPerPc,
    required this.totalFreshPcs,
    required this.totalSecondPcs,
    required this.totalSecondMts,
    required this.secondCut,
    required this.totalFentMts,
    required this.totalFentWt,
    required this.freshPct,
    required this.shortagePct,
    required this.secondPct,
    required this.fentPct,
    required this.jobType,
    required this.valueType,
    this.greyPurchaseDate,
    this.stockReceivedDate,
    required this.cutCardNos,
    required this.reccardNos,
    required this.status,
    required this.cardPics,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory matching Postgres 17 types safely.
  factory SbCutdetSummaryModel.fromJson(Map<String, dynamic> json) {
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

    List<int> parseIntList(dynamic list) {
      if (list == null || list is! List) return [];
      return list.map((item) {
        if (item is num) return item.toInt();
        if (item is String) return int.tryParse(item) ?? 0;
        return 0;
      }).toList();
    }

    List<String> parsePics(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.isNotEmpty) {
        if (val.startsWith('[')) {
          try {
            final decoded = jsonDecode(val);
            if (decoded is List) return decoded.map((e) => e.toString()).toList();
          } catch (_) {}
        }
        return [val];
      }
      return [];
    }

    final vno = (json['MULTI_VNO'] as num?)?.toInt() ?? 0;
    final wmts = (json['TOTAL_WMTS'] as num?)?.toDouble() ?? 0.0;
    final rmts = (json['TOTAL_RMTS'] as num?)?.toDouble() ?? 0.0;
    final gRate = (json['GREY_RATE'] as num?)?.toDouble() ?? 0.0;
    final jRate = (json['JOB_RATE'] as num?)?.toDouble() ?? 0.0;
    final freshPcs = (json['TOTAL_FRESH_PCS'] as num?)?.toInt() ?? 0;
    final secPcs = (json['TOTAL_SECOND_PCS'] as num?)?.toInt() ?? 0;
    final secMts = (json['TOTAL_SECOND_MTS'] as num?)?.toDouble() ?? 0.0;

    // Landed Investment Calculation: (WMTS * Grey Rate) + (RMTS * Job Rate)
    final calculatedInvestment = (wmts * gRate) + (rmts * jRate);
    final investment = calculatedInvestment > 0 
        ? double.parse(calculatedInvestment.toStringAsFixed(2))
        : ((json['total_investment'] as num?)?.toDouble() ?? 0.0);
    final computedCostPerPc = freshPcs > 0 
        ? double.parse((investment / freshPcs).toStringAsFixed(2))
        : 0.0;

    final computedSecondCut = (secPcs > 0 && secMts > 0)
        ? double.parse((secMts / secPcs).toStringAsFixed(2))
        : ((json['SECOND_CUT'] as num?)?.toDouble() ?? 0.0);

    return SbCutdetSummaryModel(
      id: (json['id'] as String?)?.trim() ?? '',
      multiVno: vno,
      ccCode: (json['cc_code'] as String?)?.trim() ?? 'CC-${vno.toString().padLeft(4, '0')}',
      mill: (json['MILL'] as String?)?.trim() ?? '',
      quality: (json['GREYQUAL'] as String?)?.trim() ?? '',
      cutDate: parseDate(json['CUTDATE']),
      cutLength: (json['CUT_LENGTH'] as num?)?.toDouble() ?? 5.25,
      avgWt: (json['AVG_WT'] as num?)?.toDouble() ?? 0.0,
      totalRmts: rmts,
      totalRpcs: (json['TOTAL_RPCS'] as num?)?.toInt() ?? 0,
      totalWmts: wmts,
      totalDmts: (json['TOTAL_DMTS'] as num?)?.toDouble() ?? 0.0,
      greyRate: gRate,
      jobRate: jRate,
      totalInvestment: investment,
      costPerPc: computedCostPerPc,
      totalFreshPcs: freshPcs,
      totalSecondPcs: secPcs,
      totalSecondMts: secMts,
      secondCut: computedSecondCut,
      totalFentMts: (json['TOTAL_FENT_MTS'] as num?)?.toDouble() ?? 0.0,
      totalFentWt: (json['TOTAL_FENT_WT'] as num?)?.toDouble() ?? 0.0,
      freshPct: (json['FRESH_PCT'] as num?)?.toDouble() ?? 0.0,
      shortagePct: (json['SHORTAGE_PCT'] as num?)?.toDouble() ?? 0.0,
      secondPct: (json['SECOND_PCT'] as num?)?.toDouble() ?? 0.0,
      fentPct: (json['FENT_PCT'] as num?)?.toDouble() ?? 0.0,
      jobType: (json['JOB_TYPE'] as String?)?.trim() ?? 'CUTTING',
      valueType: (json['VALUE_ADDITION'] as String?)?.trim() ?? 'NONE',
      greyPurchaseDate: parseOptDate(json['grey_purchase_date']),
      stockReceivedDate: parseOptDate(json['stock_received_date']),
      cutCardNos: parseIntList(json['CUTCARDNOS']),
      reccardNos: parseIntList(json['RECCARDNOS']),
      status: (json['sb_status'] as String?)?.trim() ?? 'COMPLETED',
      cardPics: parsePics(json['sb_cardpic']),
      author: (json['sb_created_by'] as String?)?.trim() ?? '',
      updater: (json['sb_updated_by'] as String?)?.trim() ?? '',
      createdOn: parseOptDate(json['sb_created_at']),
      lastEdited: parseOptDate(json['sb_updated_at']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id.isNotEmpty) 'id': id,
    'MULTI_VNO': multiVno,
    'cc_code': ccCode,
    'MILL': mill,
    'GREYQUAL': quality,
    'CUTDATE': cutDate.toIso8601String(),
    'CUT_LENGTH': cutLength,
    'AVG_WT': avgWt,
    'TOTAL_RMTS': totalRmts,
    'TOTAL_RPCS': totalRpcs,
    'TOTAL_WMTS': totalWmts,
    'TOTAL_DMTS': totalDmts,
    'GREY_RATE': greyRate,
    'JOB_RATE': jobRate,
    'total_investment': totalInvestment,
    'cost_per_pc': costPerPc,
    'TOTAL_FRESH_PCS': totalFreshPcs,
    'TOTAL_SECOND_PCS': totalSecondPcs,
    'TOTAL_SECOND_MTS': totalSecondMts,
    'SECOND_CUT': secondCut,
    'TOTAL_FENT_MTS': totalFentMts,
    'TOTAL_FENT_WT': totalFentWt,
    'FRESH_PCT': freshPct,
    'SHORTAGE_PCT': shortagePct,
    'SECOND_PCT': secondPct,
    'FENT_PCT': fentPct,
    'JOB_TYPE': jobType,
    'VALUE_ADDITION': valueType,
    if (greyPurchaseDate != null) 'grey_purchase_date': greyPurchaseDate!.toIso8601String(),
    if (stockReceivedDate != null) 'stock_received_date': stockReceivedDate!.toIso8601String(),
    'CUTCARDNOS': cutCardNos,
    'RECCARDNOS': reccardNos,
    'sb_status': status,
    'sb_cardpic': jsonEncode(cardPics),
    'sb_created_by': author,
    'sb_updated_by': updater,
    'sb_created_at': createdOn?.toIso8601String(),
    'sb_updated_at': lastEdited?.toIso8601String(),
  };

  // Domain Helper Getters
  double get combinedRatePerMtr => greyRate + jobRate;
  String get cutDateStr => '${cutDate.day}/${cutDate.month}/${cutDate.year}';
}

/// Refined Standardized UI Field Labels for `sb_cutdet_summary`
abstract class SbCutdetSummaryLabels {
  static const String ccVno = 'CC-VNO';
  static const String ccCode = 'CC-Code';
  static const String mill = 'Mill';
  static const String fabric = 'Fabric';
  static const String cutDate = 'Cut Date';
  static const String cut = 'Cut';
  static const String sareeWt = 'Saree Wt';
  static const String recMtrs = 'Rec Mtrs';
  static const String recPcs = 'Rec Pcs';
  static const String greyMtrs = 'Grey Mtrs';
  static const String sentMtrs = 'Sent Mtrs';
  static const String greyRate = 'Grey Rate';
  static const String jobRate = 'Job Rate';
  static const String totalInvestment = 'Total Investment';
  static const String costPerPc = 'Cost / Pc';
  static const String freshPcs = 'Fresh Pcs';
  static const String secPcs = 'Sec Pcs';
  static const String fentMtrs = 'Fent Mtrs';
  static const String fentWt = 'Fent Wt';
  static const String freshPct = 'Fresh %';
  static const String shortagePct = 'Shortage %';
  static const String secPct = 'Sec %';
  static const String fentPct = 'Fent %';
  static const String jobType = 'Job Type';
  static const String valueType = 'Value Type';
  static const String status = 'Status';
  static const String author = 'Author';
  static const String updater = 'Updater';
  static const String createdOn = 'Created On';
  static const String lastEdited = 'Last Edited';
}

/// Dynamic Table UI Mapper Extension for `SbCutdetSummaryModel`
extension SbCutdetSummaryTableMapper on SbCutdetSummaryModel {
  DynamicTableRowData toRowData([NumberFormat? currencyFmt]) {
    final fmt = currencyFmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DynamicTableRowData(
      id: multiVno.toString(),
      voucherNo: ccCode,
      partyName: mill.isNotEmpty ? mill : 'Unknown Mill',
      designPattern: quality.isNotEmpty ? quality : 'N/A',
      quantity: '$totalFreshPcs Pcs ($totalRmts Mtr)',
      amount: fmt.format(costPerPc),
      amountValue: costPerPc,
      status: status.isNotEmpty ? status : 'COMPLETED',
      rawData: toJson(),
    );
  }

  static List<DynamicTableColumnSpec> get defaultColumns => const [
    DynamicTableColumnSpec(label: SbCutdetSummaryLabels.ccCode, key: 'voucherNo', flex: 2),
    DynamicTableColumnSpec(label: SbCutdetSummaryLabels.mill, key: 'partyName', flex: 3),
    DynamicTableColumnSpec(label: SbCutdetSummaryLabels.fabric, key: 'designPattern', flex: 3),
    DynamicTableColumnSpec(label: SbCutdetSummaryLabels.freshPcs, key: 'quantity', flex: 2),
    DynamicTableColumnSpec(label: SbCutdetSummaryLabels.costPerPc, key: 'amount', flex: 3),
    DynamicTableColumnSpec(label: SbCutdetSummaryLabels.cutDate, key: 'status', flex: 2),
  ];
}
