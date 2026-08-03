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
