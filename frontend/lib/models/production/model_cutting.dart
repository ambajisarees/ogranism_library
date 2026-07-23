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

List<String> _parseImagePaths(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
  }
  if (raw is String && raw.isNotEmpty) {
    if (raw.contains(',')) {
      return raw.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [raw.trim()];
  }
  return [];
}

/// [CuttingCardModel] - Represents an individual Grey Cutting Card row from `sb_cutdet`.
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

  // Extended batch integration fields
  final int? multiVno;
  final double ccut;
  final double fentMts;
  final double fentWt;
  final int reccardno;
  final double rmts;
  final String? screen;
  final String? sbCardPic;
  final List<String> cardPics;
  final double rate;
  final double wmts;

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
    this.cardPics = const [],
    this.rate = 0.0,
    this.wmts = 0.0,
  });

  factory CuttingCardModel.fromJson(Map<String, dynamic> json) {
    final rawPic = json['sb_cardpic'];
    final pics = _parseImagePaths(rawPic);

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
      multiVno: json['MULTI_VNO'] != null ? _parseInt(json['MULTI_VNO']) : null,
      ccut: _parseDouble(json['CCUT']),
      fentMts: _parseDouble(json['FENT']),
      fentWt: _parseDouble(json['FENT_WT']),
      reccardno: _parseInt(json['reccardno']),
      rmts: _parseDouble(json['RMTS']),
      screen: json['SCREEN'] as String?,
      sbCardPic: rawPic as String?,
      cardPics: pics,
      rate: _parseDouble(json['RATE']),
      wmts: _parseDouble(json['WMTS']),
    );
  }

  String get displayCardNo => '#$cutCardNo';
  String get displayMeters => '${meters.toStringAsFixed(2)} Mts';
  String get displayPieces => '${pieces.toInt()} Pcs';
}

/// [CuttingBatchSummaryModel] - Represents a parent batch summary from `sb_cutdet_summary`.
@immutable
class CuttingBatchSummaryModel {
  final String id;
  final int multiVno;
  final String mill;
  final String greyQual;
  final DateTime cutDate;
  final double cutLength;
  final double avgWt;
  final double totalRmts; // Processed Cut meters received from mill
  final double totalDmts; // Dispatched Grey meters sent to mill (sq_MILLREC anchor)
  final double totalWmts; // Weaver grey meters
  final double greyRate;  // Weighted grey fabric cost/m
  final double jobRate;   // Weighted printing/dyeing job rate/m
  final double shortagePct; // Mill processing shortage %: (TOTAL_DMTS - TOTAL_RMTS) / TOTAL_DMTS * 100
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
  final List<String> cardPics;
  final List<int> cutCardNos;
  final List<int> reccardNos;
  final String sbStatus;
  final String ccNo;
  final String ccCode;
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
    required this.totalDmts,
    required this.totalWmts,
    required this.greyRate,
    required this.jobRate,
    required this.shortagePct,
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
    this.cardPics = const [],
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
    final rawPic = json['sb_cardpic'];
    final pics = _parseImagePaths(rawPic);

    return CuttingBatchSummaryModel(
      id: json['id'] as String? ?? '',
      multiVno: multiVnoVal,
      mill: json['MILL'] as String? ?? 'N/A',
      greyQual: json['GREYQUAL'] as String? ?? 'N/A',
      cutDate: json['CUTDATE'] != null
          ? DateTime.tryParse(json['CUTDATE'].toString()) ?? DateTime.now()
          : DateTime.now(),
      cutLength: _parseDouble(json['CUT_LENGTH']),
      avgWt: _parseDouble(json['AVG_WT']),
      totalRmts: _parseDouble(json['TOTAL_RMTS']),
      totalDmts: _parseDouble(json['TOTAL_DMTS']),
      totalWmts: _parseDouble(json['TOTAL_WMTS']),
      greyRate: _parseDouble(json['GREY_RATE']),
      jobRate: _parseDouble(json['JOB_RATE']),
      shortagePct: _parseDouble(json['SHORTAGE_PCT']),
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
      sbCardPic: rawPic as String?,
      cardPics: pics,
      cutCardNos: _parseIntList(json['CUTCARDNOS']),
      reccardNos: _parseIntList(json['RECCARDNOS']),
      sbStatus: json['sb_status'] as String? ?? 'COMPLETED',
      ccNo: json['cc_no'] as String? ?? multiVnoVal.toString().padLeft(4, '0'),
      ccCode: json['cc_code'] as String? ?? 'CC-${multiVnoVal.toString().padLeft(4, '0')}',
      greyPurchaseDate: json['grey_purchase_date'] != null
          ? DateTime.tryParse(json['grey_purchase_date'].toString())
          : null,
      stockReceivedDate: json['stock_received_date'] != null
          ? DateTime.tryParse(json['stock_received_date'].toString())
          : null,
      jobIssuedDate: json['job_issued_date'] != null
          ? DateTime.tryParse(json['job_issued_date'].toString())
          : null,
      jobReceivedDate: json['job_received_date'] != null
          ? DateTime.tryParse(json['job_received_date'].toString())
          : null,
      totalInvestment: json['total_investment'] != null ? _parseDouble(json['total_investment']) : null,
      costPerPc: json['cost_per_pc'] != null ? _parseDouble(json['cost_per_pc']) : null,
      jobCardVnos: json['job_card_vnos'] != null
          ? List<int>.from((json['job_card_vnos'] as List).map((x) => _parseInt(x)))
          : const [],
    );
  }

  String get displayCode => ccCode;

  /// Finished fresh saree meters cut: TOTAL_FRESH_PCS * CUT_LENGTH
  double get totalFreshMts => totalFreshPcs * cutLength;

  /// Fresh %: (TOTAL_RMTS / TOTAL_DMTS) * 100
  double get calculatedFreshPct {
    if (freshPct > 0) return freshPct;
    if (totalDmts <= 0) return 0.0;
    return ((totalRmts / totalDmts) * 100.0).clamp(0.0, 100.0);
  }

  /// Mill Shortage %: ((TOTAL_DMTS - TOTAL_RMTS) / TOTAL_DMTS) * 100
  double get calculatedShortagePct {
    if (shortagePct > 0) return shortagePct;
    if (totalDmts <= 0) return 0.0;
    return (((totalDmts - totalRmts) / totalDmts) * 100.0).clamp(0.0, 100.0);
  }
}

/// [CuttingMetricsModel] - Data model for top landing page metric summary cards.
@immutable
class CuttingMetricsModel {
  final int totalSareesCut;
  final double avgShortagePct;
  final int pendingBatches;
  final int pendingJobs;

  const CuttingMetricsModel({
    this.totalSareesCut = 0,
    this.avgShortagePct = 0.0,
    this.pendingBatches = 0,
    this.pendingJobs = 0,
  });
}
