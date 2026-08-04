/*
================================================================================
LLM CONTEXT & QUERY SPACE — CUTTING CARDS MODULE MODEL (mdl_cc.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Data Model for Multi-Cutting Cards (`cc` / Stage 2 of Production Pipeline).
   - Adapts canonical `SbCutdetSummaryModel` (cutting summaries) and `SbCutdetModel` 
     (cut piece detail lines) into domain objects for UI rendering in DyTable and Page Shells.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Schema/Table: `IMMBE2627.sb_cutdet_summary` (311 summary records) & `IMMBE2627.sb_cutdet` (3,409 detail lines).
   - Primary Key Joins: `MULTI_VNO` in summary maps to `VNO` / `CUTCARDNOS` in detail cut lines.
   - Yield & Financial Metrics:
     * `freshYieldPct` (`FRESH_PCT`): Fresh saree yield % from printed fabric rolls (target ~85%+).
     * `costPerPc` (`cost_per_pc`): Net cost per cut saree piece considering grey rate & job rate.
     * `totalInvestment` (`total_investment`): Total inventory capital invested in the cutting batch.
     * `cardPicPath` (`sb_cardpic`): Relative storage URI for scanned physical cutting card image.
   - DyTable Integration: Provides `toDyDefRowData()` and `toDyChildRowData()` for 3-tiered DyTable hierarchy.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_cutdet_summary`: 311 total records for FY 26-27. `sb_cardpic` null rate is ~75% 
     (only uploaded scanned receipts populated).
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../dynamic_ai/micro/table/dy_table_models.dart';
import '../core/sb/sb_cutdet_summary.dart';
import '../core/sb/sb_cutdet.dart';

/// Categories for Multi-Cutting Cards
enum CcCategory {
  standardCutting,
  jobWorkCutting,
  specialLot;

  String get displayName {
    switch (this) {
      case CcCategory.standardCutting:
        return 'Standard Cutting';
      case CcCategory.jobWorkCutting:
        return 'Job Work Cutting';
      case CcCategory.specialLot:
        return 'Special Lot';
    }
  }

  String get dbCode {
    switch (this) {
      case CcCategory.standardCutting:
        return 'Standard Cutting';
      case CcCategory.jobWorkCutting:
        return 'Job Work Cutting';
      case CcCategory.specialLot:
        return 'Special Lot';
    }
  }
}

/// [MdlCcHeader] — Domain Data Model for a Multi-Cutting Card Summary Record
@immutable
class MdlCcHeader {
  final SbCutdetSummaryModel core;
  final List<MdlCcLineItem> lineItems;

  const MdlCcHeader({
    required this.core,
    this.lineItems = const [],
  });

  /// Primary ID
  String get id => core.id;

  /// Voucher / Cutting Batch Number
  int get multiVno => core.multiVno;

  /// Standardized Cutting Code (e.g., `CC-0293`)
  String get displayCcCode => core.ccCode;

  /// Mill / Processor Name
  String get millName => core.mill.isNotEmpty ? core.mill : 'Unknown Mill';

  /// Grey Fabric Quality Name
  String get greyQuality => core.quality.isNotEmpty ? core.quality : 'N/A';

  /// Cutting Date
  DateTime get cutDate => core.cutDate;

  /// Formatted Cut Date String (e.g. `15 Jul 2026`)
  String get formattedCutDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${cutDate.day.toString().padLeft(2, '0')} ${months[cutDate.month - 1]} ${cutDate.year}';
  }

  /// Standard Cut Length per Saree (e.g. `6.00 Mtr` or `5.25 Mtr`)
  double get cutLength => core.cutLength;
  String get formattedCutLength => cutLength > 0 ? '${cutLength.toStringAsFixed(2)} Mtr' : 'N/A';

  /// Average Weight per Piece (kg)
  double get avgWeight => core.avgWt;

  /// Total Sent Grey Fabric Meters
  double get totalWmts => core.totalWmts;
  String get formattedSentGreyMeters => totalWmts > 0 ? '${totalWmts.toStringAsFixed(1)} Mtr' : '0.0 Mtr';

  /// Total Received Fabric Meters
  double get totalReceivedMeters => core.totalRmts;
  String get formattedReceivedMeters => totalReceivedMeters > 0 ? '${totalReceivedMeters.toStringAsFixed(1)} Mtr' : '0.0 Mtr';

  /// Total Dispatched Meters
  double get totalDmts => core.totalDmts;
  String get formattedDispatchedMeters => totalDmts > 0 ? '${totalDmts.toStringAsFixed(1)} Mtr' : '0.0 Mtr';

  /// Total Rolls Received
  int get totalReceivedPcs => core.totalRpcs;

  /// Total Fresh Sarees Cut
  int get totalFreshPcs => core.totalFreshPcs;

  /// Total Second Sarees Cut
  int get totalSecondPcs => core.totalSecondPcs;

  /// Total Fent / Wastage Meters
  double get totalFentMts => core.totalFentMts;

  /// Total Fent / Wastage Weight (Kg)
  double get totalFentWt => core.totalFentWt;
  String get formattedFentWeight => totalFentWt > 0 ? '${totalFentWt.toStringAsFixed(2)} Kg' : '0.00 Kg';

  /// Fresh Saree Yield Percentage (e.g. `84.34%`)
  double get freshYieldPct => core.freshPct;
  String get formattedFreshYield => freshYieldPct > 0 ? '${freshYieldPct.toStringAsFixed(1)}%' : '0.0%';

  /// Second Yield Percentage
  double get secondPct => core.secondPct;

  /// Wastage / Fent Yield Percentage
  double get fentPct => core.fentPct;

  /// Mill Processing Shortage / Shrinkage Percentage
  double get shortagePct => core.shortagePct;
  String get formattedShortagePct => shortagePct > 0 ? '${shortagePct.toStringAsFixed(1)}%' : '0.0%';

  /// Grey Fabric Purchase Rate (₹/Mtr)
  double get greyRate => core.greyRate;
  String formattedGreyRate([NumberFormat? fmt]) {
    if (greyRate <= 0) return '₹0.00';
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(greyRate);
  }

  /// Processing / Job Work Rate (₹/Mtr)
  double get jobRate => core.jobRate;
  String formattedJobRate([NumberFormat? fmt]) {
    if (jobRate <= 0) return '₹0.00';
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(jobRate);
  }

  /// Cost Per Saree Piece (₹)
  double get costPerPc => core.costPerPc;
  String get formattedCostPerPc => costPerPc > 0 ? '₹${costPerPc.toStringAsFixed(2)}' : '₹0.00';

  /// Total Inventory Investment Amount (₹)
  double get totalInvestment => core.totalInvestment;
  String get formattedTotalInvestment {
    if (totalInvestment <= 0) return '₹0.00';
    final parts = totalInvestment.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    if (intPart.length <= 3) return '₹$intPart.$decPart';
    final last3 = intPart.substring(intPart.length - 3);
    final rest = intPart.substring(0, intPart.length - 3);
    final formattedRest = rest.replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+$)'), (m) => '${m[1]},');
    return '₹$formattedRest,$last3.$decPart';
  }

  /// Mill Process Category & Value Addition
  String get jobType => core.jobType;
  String get valueType => core.valueType;

  /// Array of Child Card Numbers
  List<int> get cutCardNos => core.cutCardNos;
  List<int> get reccardNos => core.reccardNos;

  /// Scanned Physical Card Picture Storage URI
  String? get cardPicPath => core.cardPics.isNotEmpty ? core.cardPics.first : null;
  bool get hasCardPic => cardPicPath != null && cardPicPath!.isNotEmpty;

  /// Status (`COMPLETED`, `PENDING`, `IN_PROCESS`)
  String get status => core.status.isNotEmpty ? core.status : 'COMPLETED';

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isPending => !isCompleted;

  /// Categorized Fresh Yield Performance
  String get freshYieldStatus {
    if (freshYieldPct >= 85.0) return 'High Yield';
    if (freshYieldPct >= 80.0) return 'Normal Yield';
    return 'Low Yield';
  }

  /// Convert into a Tier 2 Document Header Row for [DyTable]
  DyTableRowData toDyDefRowData([NumberFormat? fmt]) {
    final currencyFmt = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DyTableRowData(
      id: id.isNotEmpty ? id : multiVno.toString(),
      rowType: DyTableRowType.def,
      voucherNo: displayCcCode,
      partyName: millName,
      imagePath: cardPicPath,
      data: {
        'vno': displayCcCode,
        'date': formattedCutDate,
        'partyName': millName,
        'designPattern': greyQuality,
        'cutLength': formattedCutLength,
        'quantity': '$totalFreshPcs Pcs ($formattedReceivedMeters)',
        'totalPcs': totalFreshPcs > 0 ? '$totalFreshPcs Pcs' : '-',
        'freshPct': formattedFreshYield,
        'rate': formattedCostPerPc,
        'amount': currencyFmt.format(totalInvestment),
        'status': isPending ? 'PENDING' : 'COMPLETED',
      },
      children: lineItems.map((item) => item.toDyChildRowData(displayCcCode, currencyFmt)).toList(),
      rawData: core.toJson(),
    );
  }

  /// Copy with new line items or properties
  MdlCcHeader copyWith({
    List<MdlCcLineItem>? lineItems,
  }) {
    return MdlCcHeader(
      core: core,
      lineItems: lineItems ?? this.lineItems,
    );
  }
}

/// [MdlCcLineItem] — Domain Data Model for a Detail Cut Piece Line Item
@immutable
class MdlCcLineItem {
  final SbCutdetModel core;

  const MdlCcLineItem({required this.core});

  int get vno => core.cutCardNo;
  int get cutCardNo => core.cutCardNo;
  int get multiVno => core.multiVno;
  int get cardNo => core.cardNo;
  int get recCardNo => core.recCardNo;
  int get despNo => core.despNo;
  String get millName => core.mill.isNotEmpty ? core.mill : 'Unknown Mill';
  String get weaverName => core.weaver;
  String get quality => core.quality.isNotEmpty ? core.quality : 'N/A';
  String get greyLotNo => core.lotNo;
  double get meters => core.recMtrs > 0 ? core.recMtrs : core.cutMtrs;
  double get greyMtrs => core.greyMtrs;
  int get greyPcs => core.greyPcs;
  double get recMtrs => core.recMtrs;
  int get recPcs => core.recPcs;
  double get pieces => core.freshPcs.toDouble();
  int get freshPcs => core.freshPcs;
  int get secondsPcs => core.secondsPcs;
  double get fentMts => core.fentMts;
  double get fentWt => core.fentWt;
  double get avgWt => core.avgWt;
  double get rate => core.greyRate;
  double get greyRate => core.greyRate;
  double get jobRate => core.jobRate;
  double get totalRate => core.totalRate;
  double get cutLength => core.cutLength;
  double get cutMtrs => core.cutMtrs;

  double get totalGreyInvestment => core.totalGreyInvestment;
  double get totalProcessingInvestment => core.totalProcessingInvestment;
  double get amount => core.totalLandedInvestment;
  double get totalLandedInvestment => core.totalLandedInvestment;
  double get costPerFreshPiece => core.costPerFreshPiece;

  DateTime get cutDate => core.cutDate;
  String get status => core.status;

  String formattedAmount([NumberFormat? fmt]) {
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(amount);
  }

  /// Convert into a Tier 3 Detail Line Item Row for [DyTable]
  DyTableRowData toDyChildRowData(String parentVno, [NumberFormat? fmt]) {
    final currencyFmt = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DyTableRowData(
      id: cutCardNo.toString(),
      rowType: DyTableRowType.child,
      parentId: parentVno,
      voucherNo: 'CUT #$cutCardNo',
      partyName: weaverName.isNotEmpty ? weaverName : millName,
      data: {
        'vno': 'CUT #$cutCardNo',
        'partyName': weaverName.isNotEmpty ? weaverName : millName,
        'designPattern': quality,
        'totalMtrs': meters > 0 ? '${meters.toStringAsFixed(1)} Mtr' : '-',
        'quantity': meters > 0 ? '${meters.toStringAsFixed(1)} Mtr ($freshPcs Pcs)' : '-',
        'totalPcs': freshPcs > 0 ? '$freshPcs Pcs' : '-',
        'pcs': freshPcs > 0 ? '$freshPcs' : '-',
        'rate': totalRate > 0 ? currencyFmt.format(totalRate) : '-',
        'amount': currencyFmt.format(amount),
        'status': status.isNotEmpty ? status : 'COMPLETED',
      },
      rawData: core.toJson(),
    );
  }
}

/// [MdlCcBatchInput] — Input Data Holder & Calculation Engine for Creating Cutting Batches
class MdlCcBatchInput {
  final int multiVno;
  final String millName;
  final DateTime cutDate;
  final double cutLength;
  final int totalFreshPcs;
  final int totalSecondPcs;
  final double avgWtGrams; // Saree Weight in Grams
  final double totalFentWtGrams; // Fent Weight in Grams
  final List<Map<String, dynamic>> selectedCards;

  MdlCcBatchInput({
    required this.multiVno,
    required this.millName,
    required this.cutDate,
    required this.cutLength,
    required this.totalFreshPcs,
    required this.totalSecondPcs,
    required this.avgWtGrams,
    required this.totalFentWtGrams,
    required this.selectedCards,
  });

  /// Calculate pro-rated detail rows for [SbCutdetModel]
  List<SbCutdetModel> buildDetailRows({required String author, int startCutCardNo = 1}) {
    if (selectedCards.isEmpty) return [];

    final totalRmts = selectedCards.fold<double>(
      0.0,
      (sum, c) => sum + ((c['RMTS'] as num?)?.toDouble() ?? 0.0),
    );

    if (totalRmts <= 0) return [];

    List<SbCutdetModel> details = [];
    int freshPcsDistributed = 0;
    int secondsPcsDistributed = 0;

    for (int i = 0; i < selectedCards.length; i++) {
      final card = selectedCards[i];
      final isLast = i == selectedCards.length - 1;
      final cardRmts = (card['RMTS'] as num?)?.toDouble() ?? 0.0;
      final ratio = cardRmts / totalRmts;

      // Pro-rate fresh pcs
      int freshPcs = isLast
          ? (totalFreshPcs - freshPcsDistributed)
          : (totalFreshPcs * ratio).round();
      freshPcsDistributed += freshPcs;

      // Pro-rate second pcs
      int secondsPcs = isLast
          ? (totalSecondPcs - secondsPcsDistributed)
          : (totalSecondPcs * ratio).round();
      secondsPcsDistributed += secondsPcs;

      // Pro-rate fent weight in grams
      double fentWtGrams = double.parse((totalFentWtGrams * ratio).toStringAsFixed(2));

      // Calculate Fent Meters (2 decimals): FENT = (FENT_WT_Grams * CCUT) / AVG_WT_Grams
      double fentMts = avgWtGrams > 0
          ? double.parse(((fentWtGrams * cutLength) / avgWtGrams).toStringAsFixed(2))
          : 0.0;

      // Cut Meters = freshPcs * cutLength
      double cutMts = double.parse((freshPcs * cutLength).toStringAsFixed(2));

      final recCardNo = (card['RECCARDNO'] as num?)?.toInt() ?? 0;
      final cardNo = (card['CARDNO'] as num?)?.toInt() ?? 0;
      final despNo = (card['DESPNO'] as num?)?.toInt() ?? 0;

      final cutCardNo = startCutCardNo + i;

      DateTime? parseOptDate(dynamic v) => v != null && v.toString().isNotEmpty ? DateTime.tryParse(v.toString()) : null;

      details.add(
        SbCutdetModel(
          cutCardNo: cutCardNo,
          multiVno: multiVno,
          cardNo: cardNo,
          recCardNo: recCardNo,
          despNo: despNo,
          mill: millName,
          weaver: (card['WEAVER'] as String?)?.trim() ?? '',
          quality: (card['GREYQUAL'] as String?)?.trim() ?? '',
          lotNo: (card['lot'] as String?)?.trim() ?? '',
          greyMtrs: (card['WMTS'] as num?)?.toDouble() ?? 0.0,
          greyPcs: (card['WPCS'] as num?)?.toInt() ?? 0,
          recMtrs: cardRmts,
          recPcs: (card['RPCS'] as num?)?.toInt() ?? 0,
          greyRate: (card['RATE'] as num?)?.toDouble() ?? 0.0,
          jobRate: (card['JOBRATE'] as num?)?.toDouble() ?? 0.0,
          cutLength: cutLength,
          cutMtrs: cutMts,
          freshPcs: freshPcs,
          secondsPcs: secondsPcs,
          fentMts: fentMts,
          fentWt: fentWtGrams,
          avgWt: avgWtGrams,
          cutDate: cutDate,
          dispatchDate: parseOptDate(card['DDATE']),
          status: 'COMPLETED',
          author: author,
          updater: author,
          createdOn: DateTime.now(),
          lastEdited: DateTime.now(),
          rawJson: {},
        ),
      );
    }

    return details;
  }

  /// Calculate summary row for [SbCutdetSummaryModel]
  SbCutdetSummaryModel buildSummaryRow(List<SbCutdetModel> details, {required String author}) {
    double totalWmts = 0.0;
    double totalRmts = 0.0;
    int totalRpcs = 0;
    int freshPcsSum = 0;
    int secondsPcsSum = 0;
    double fentWtSumGrams = 0.0;
    double fentMtsSum = 0.0;
    double totalWeightedGreyCost = 0.0;
    double totalJobRateSum = 0.0;
    Set<String> qualities = {};
    List<int> recCardNosList = [];
    List<int> cutCardNosList = [];
    DateTime? earliestGreyPurchaseDate;
    DateTime? earliestStockReceivedDate;

    for (final d in details) {
      totalWmts += d.greyMtrs;
      totalRmts += d.recMtrs;
      totalRpcs += d.recPcs;
      freshPcsSum += d.freshPcs;
      secondsPcsSum += d.secondsPcs;
      fentWtSumGrams += d.fentWt;
      fentMtsSum += d.fentMts;
      totalWeightedGreyCost += (d.greyMtrs * d.greyRate);
      totalJobRateSum += d.jobRate;

      if (d.quality.isNotEmpty) qualities.add(d.quality);
      recCardNosList.add(d.recCardNo);
      cutCardNosList.add(d.cutCardNo);

      if (d.dispatchDate != null) {
        if (earliestGreyPurchaseDate == null || d.dispatchDate!.isBefore(earliestGreyPurchaseDate)) {
          earliestGreyPurchaseDate = d.dispatchDate;
        }
      }
      if (d.cutDate.isBefore(earliestStockReceivedDate ?? DateTime.now())) {
        earliestStockReceivedDate = d.cutDate;
      }
    }

    // 2-decimal rounded rates
    final greyRate = totalWmts > 0
        ? double.parse((totalWeightedGreyCost / totalWmts).toStringAsFixed(2))
        : 0.0;
    final jobRate = details.isNotEmpty
        ? double.parse((totalJobRateSum / details.length).toStringAsFixed(2))
        : 0.0;

    // Total Cut Meters (Fresh)
    final totalCmts = freshPcsSum * cutLength;

    // Second Meters = TOTAL_RMTS - TOTAL_CMTS - TOTAL_FENT_MTS
    final totalSecondMts = double.parse((totalRmts - totalCmts - fentMtsSum).toStringAsFixed(2));

    // Second Cut = TOTAL_SECOND_MTS / TOTAL_SECOND_PCS
    final secondCut = (secondsPcsSum > 0 && totalSecondMts > 0)
        ? double.parse((totalSecondMts / secondsPcsSum).toStringAsFixed(2))
        : 0.0;

    // Percentages (2 decimals)
    final freshPct = totalRmts > 0 ? double.parse(((totalCmts / totalRmts) * 100).toStringAsFixed(2)) : 0.0;
    final secondPct = totalRmts > 0 ? double.parse(((totalSecondMts / totalRmts) * 100).toStringAsFixed(2)) : 0.0;
    final fentPct = totalRmts > 0 ? double.parse(((fentMtsSum / totalRmts) * 100).toStringAsFixed(2)) : 0.0;
    final shortagePct = totalWmts > 0 ? double.parse((((totalWmts - totalRmts) / totalWmts) * 100).toStringAsFixed(2)) : 0.0;

    // Financials (2 decimals)
    final totalInvestment = double.parse(((totalWmts * greyRate) + (totalRmts * jobRate)).toStringAsFixed(2));
    final costPerPc = freshPcsSum > 0 ? double.parse((totalInvestment / freshPcsSum).toStringAsFixed(2)) : 0.0;

    final qualityStr = qualities.join(', ');

    return SbCutdetSummaryModel(
      id: '',
      multiVno: multiVno,
      ccCode: 'CC-${multiVno.toString().padLeft(4, '0')}',
      mill: millName,
      quality: qualityStr,
      cutDate: cutDate,
      cutLength: cutLength,
      avgWt: avgWtGrams,
      totalRmts: totalRmts,
      totalRpcs: totalRpcs,
      totalWmts: totalWmts,
      totalDmts: totalWmts,
      greyRate: greyRate,
      jobRate: jobRate,
      totalInvestment: totalInvestment,
      costPerPc: costPerPc,
      totalFreshPcs: freshPcsSum,
      totalSecondPcs: secondsPcsSum,
      totalSecondMts: totalSecondMts,
      secondCut: secondCut,
      totalFentMts: fentMtsSum,
      totalFentWt: fentWtSumGrams,
      freshPct: freshPct,
      shortagePct: shortagePct,
      secondPct: secondPct,
      fentPct: fentPct,
      jobType: 'CUTTING',
      valueType: 'NONE',
      greyPurchaseDate: earliestGreyPurchaseDate,
      stockReceivedDate: earliestStockReceivedDate,
      cutCardNos: cutCardNosList,
      reccardNos: recCardNosList,
      status: 'COMPLETED',
      cardPics: [],
      author: author,
      updater: author,
      createdOn: DateTime.now(),
      lastEdited: DateTime.now(),
      rawJson: {},
    );
  }
}

