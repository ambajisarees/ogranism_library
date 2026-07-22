import 'package:flutter/foundation.dart';

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

List<int> _parseIntList(dynamic list) {
  if (list == null || list is! List) return [];
  return list.map((item) {
    if (item is num) return item.toInt();
    if (item is String) return int.tryParse(item) ?? 0;
    return 0;
  }).toList();
}

/// [CuttingCardModel] - Represents a Grey Cutting Card from the `sb_cutdet` or `sq_CUTDET` table.
@immutable
class CuttingCardModel {
  final int cardNo;
  final int cutCardNo;
  final DateTime? cutDate;
  final String mill;
  final String greyQual;
  final String lot;
  final double pieces;
  final double meters;
  final double seconds;
  final double jobRate;
  final bool isClosed;
  final String creator;
  final DateTime? createTime;

  // Extended fields for sb_cutdet & batch integrations
  final int? multiVno;
  final double ccut;      // Cut length
  final double fentMts;   // Fent meters in fabric (FENT)
  final double fentWt;    // Fent weight in KG (FENT_WT)
  final int reccardno;    // Sibling or parent receipt reference
  final double rmts;       // Received meters (RMTS)
  final String? screen;
  final String? sbCardPic;
  final double rate;       // Grey purchase rate (RATE)
  final double wmts;       // Grey planned/outward meters (WMTS)

  const CuttingCardModel({
    required this.cardNo,
    required this.cutCardNo,
    this.cutDate,
    required this.mill,
    required this.greyQual,
    required this.lot,
    this.pieces = 0.0,
    this.meters = 0.0,
    this.seconds = 0.0,
    this.jobRate = 0.0,
    this.isClosed = false,
    this.creator = '',
    this.createTime,
    this.multiVno,
    this.ccut = 0.0,
    this.fentMts = 0.0,
    this.fentWt = 0.0,
    this.reccardno = 0,
    this.rmts = 0.0,
    this.screen,
    this.sbCardPic,
    this.rate = 0.0,
    this.wmts = 0.0,
  });

  factory CuttingCardModel.fromJson(Map<String, dynamic> json) {
    return CuttingCardModel(
      cardNo: _parseInt(json['CARDNO']),
      cutCardNo: _parseInt(json['CUTCARDNO']),
      cutDate: json['CUTDATE'] != null ? DateTime.tryParse(json['CUTDATE'].toString()) : null,
      mill: json['MILL'] as String? ?? 'N/A',
      greyQual: json['GREYQUAL'] as String? ?? 'N/A',
      lot: json['lot'] as String? ?? 'N/A',
      pieces: _parseDouble(json['CPCS']),
      meters: _parseDouble(json['CMTS']),
      seconds: _parseDouble(json['SECONDS']),
      jobRate: _parseDouble(json['JOBRATE']),
      isClosed: (json['closed'] as String?)?.toUpperCase() == 'Y',
      creator: json['CREATOR'] as String? ?? '',
      createTime: json['CREATETIME'] != null ? DateTime.tryParse(json['CREATETIME'].toString()) : null,
      
      // Extended fields
      multiVno: json['MULTI_VNO'] != null ? _parseInt(json['MULTI_VNO']) : null,
      ccut: _parseDouble(json['CCUT']),
      fentMts: _parseDouble(json['FENT']),
      fentWt: _parseDouble(json['FENT_WT']),
      reccardno: _parseInt(json['reccardno']),
      rmts: _parseDouble(json['RMTS']),
      screen: json['SCREEN'] as String?,
      sbCardPic: json['sb_cardpic'] as String?,
      rate: _parseDouble(json['RATE']),
      wmts: _parseDouble(json['WMTS']),
    );
  }

  /// Helper for UI formatting
  String get displayCardNo => '#$cutCardNo';
  String get displayMeters => '${meters.toStringAsFixed(2)} Mts';
  String get displayPieces => '${pieces.toInt()} Pcs';
}

/// [CuttingBatchSummaryModel] - Represents a parent cutting card batch summary from the `sb_cutdet_summary` table.
@immutable
class CuttingBatchSummaryModel {
  final String id;
  final int multiVno;
  final String mill;
  final String greyQual;
  final DateTime cutDate;
  final double cutLength;
  final double avgWt;
  final double totalRmts;
  final int totalRpcs;
  final int totalFreshPcs;
  final int totalSecondPcs;
  final double totalFentWt;
  final double totalSareeWt;
  final double totalFentMts;
  final double totalSecondMts;
  final double freshPct;
  final double secondPct;
  final double fentPct;
  final String jobType;
  final String valueAddition;
  final String? screen;
  final String? sbCardPic;
  final List<int> cutCardNos;
  final List<int> reccardNos;
  final String sbStatus;
  final String ccNo;    // Zero-padded 4-digit: "0001"
  final String ccCode;  // Display code: "CC-0001"
  final DateTime? greyPurchaseDate;
  final DateTime? stockReceivedDate;
  final DateTime? jobIssuedDate;
  final DateTime? jobReceivedDate;
  final double? totalInvestment;
  final double? costPerPc;
  final List<int> jobCardVnos;

  const CuttingBatchSummaryModel({
    required this.id,
    required this.multiVno,
    required this.mill,
    required this.greyQual,
    required this.cutDate,
    required this.cutLength,
    required this.avgWt,
    required this.totalRmts,
    required this.totalRpcs,
    required this.totalFreshPcs,
    required this.totalSecondPcs,
    required this.totalFentWt,
    required this.totalSareeWt,
    required this.totalFentMts,
    required this.totalSecondMts,
    required this.freshPct,
    required this.secondPct,
    required this.fentPct,
    required this.jobType,
    required this.valueAddition,
    this.screen,
    this.sbCardPic,
    required this.cutCardNos,
    required this.reccardNos,
    required this.sbStatus,
    this.ccNo = '0000',
    this.ccCode = 'CC-0000',
    this.greyPurchaseDate,
    this.stockReceivedDate,
    this.jobIssuedDate,
    this.jobReceivedDate,
    this.totalInvestment,
    this.costPerPc,
    this.jobCardVnos = const [],
  });

  factory CuttingBatchSummaryModel.fromJson(Map<String, dynamic> json) {
    final multiVnoVal = _parseInt(json['MULTI_VNO']);
    return CuttingBatchSummaryModel(
      id: json['id'] as String? ?? '',
      multiVno: multiVnoVal,
      mill: json['MILL'] as String? ?? 'N/A',
      greyQual: json['GREYQUAL'] as String? ?? 'N/A',
      cutDate: json['CUTDATE'] != null ? DateTime.parse(json['CUTDATE'].toString()) : DateTime.now(),
      cutLength: _parseDouble(json['CUT_LENGTH']),
      avgWt: _parseDouble(json['AVG_WT']),
      totalRmts: _parseDouble(json['TOTAL_RMTS']),
      totalRpcs: _parseInt(json['TOTAL_RPCS']),
      totalFreshPcs: _parseInt(json['TOTAL_FRESH_PCS']),
      totalSecondPcs: _parseInt(json['TOTAL_SECOND_PCS']),
      totalFentWt: _parseDouble(json['TOTAL_FENT_WT']),
      totalSareeWt: _parseDouble(json['TOTAL_SAREE_WT']),
      totalFentMts: _parseDouble(json['TOTAL_FENT_MTS']),
      totalSecondMts: _parseDouble(json['TOTAL_SECOND_MTS']),
      freshPct: _parseDouble(json['FRESH_PCT']),
      secondPct: _parseDouble(json['SECOND_PCT']),
      fentPct: _parseDouble(json['FENT_PCT']),
      jobType: json['JOB_TYPE'] as String? ?? 'N/A',
      valueAddition: json['VALUE_ADDITION'] as String? ?? 'None',
      screen: json['SCREEN'] as String?,
      sbCardPic: json['sb_cardpic'] as String?,
      cutCardNos: _parseIntList(json['CUTCARDNOS']),
      reccardNos: _parseIntList(json['RECCARDNOS']),
      sbStatus: json['sb_status'] as String? ?? 'COMPLETED',
      ccNo: json['cc_no'] as String? ?? multiVnoVal.toString().padLeft(4, '0'),
      ccCode: json['cc_code'] as String? ?? 'CC-${multiVnoVal.toString().padLeft(4, '0')}',
      greyPurchaseDate: json['grey_purchase_date'] != null ? DateTime.tryParse(json['grey_purchase_date'].toString()) : null,
      stockReceivedDate: json['stock_received_date'] != null ? DateTime.tryParse(json['stock_received_date'].toString()) : null,
      jobIssuedDate: json['job_issued_date'] != null ? DateTime.tryParse(json['job_issued_date'].toString()) : null,
      jobReceivedDate: json['job_received_date'] != null ? DateTime.tryParse(json['job_received_date'].toString()) : null,
      totalInvestment: json['total_investment'] != null ? _parseDouble(json['total_investment']) : null,
      costPerPc: json['cost_per_pc'] != null ? _parseDouble(json['cost_per_pc']) : null,
      jobCardVnos: json['job_card_vnos'] != null
          ? List<int>.from((json['job_card_vnos'] as List).map((x) => _parseInt(x)))
          : const [],
    );
  }

  /// Display code — e.g. "CC-0001"
  String get displayCode => ccCode;

  double get totalFreshMts => totalFreshPcs * cutLength;
}


