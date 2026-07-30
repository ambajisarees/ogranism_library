/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Module Data Model for Multi-Cutting Cards (`cc` / Stage 2 of Production Pipeline).
   - Adapts canonical `SbCutdetSummaryModel` (cutting summaries) and `SbCutdetModel` 
     (cut piece detail lines) into domain objects for UI rendering.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Schema/Table: `IMMBE2627.sb_cutdet_summary` (311 summary records) & `IMMBE2627.sb_cutdet`.
   - Primary Key Joins: `MULTI_VNO` in summary maps to `VNO` / `CUTCARDNOS` in detail cut lines.
   - Yield & Financial Metrics:
     * `freshYieldPct` (`FRESH_PCT`): Fresh saree yield % from printed fabric rolls (target ~85%+).
     * `costPerPc` (`cost_per_pc`): Net cost per cut saree piece considering grey rate & job rate.
     * `totalInvestment` (`total_investment`): Total inventory capital invested in the cutting batch.
     * `cardPicPath` (`sb_cardpic`): Relative storage URI for scanned physical cutting card image.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_cutdet_summary`: 311 total records for FY 26-27. `sb_cardpic` null rate is ~75% 
     (only uploaded scanned receipts populated).
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../models/core/sb/sb_cutdet_summary.dart';
import '../../models/core/sb/sb_cutdet.dart';

/// Categories for Multi-Cutting Cards
enum CcCategory {
  standardCutting,
  jobWorkCutting,
  specialLot,
}

extension CcCategoryExtension on CcCategory {
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

  /// Standard Cut Length per Saree (e.g. `6.00 Mtr` or `5.20 Mtr`)
  double get cutLength => core.cutLength;
  String get formattedCutLength => cutLength > 0 ? '${cutLength.toStringAsFixed(2)} Mtr' : 'N/A';

  /// Average Weight per Piece (kg)
  double get avgWeight => core.avgWt;

  /// Total Received Fabric Meters
  double get totalReceivedMeters => core.totalRmts;
  String get formattedReceivedMeters => totalReceivedMeters > 0 ? '${totalReceivedMeters.toStringAsFixed(1)} Mtr' : '0.0 Mtr';

  /// Total Rolls Received
  int get totalReceivedPcs => core.totalRpcs;

  /// Total Fresh Sarees Cut
  int get totalFreshPcs => core.totalFreshPcs;

  /// Total Second Sarees Cut
  int get totalSecondPcs => core.totalSecondPcs;

  /// Total Fent / Wastage Meters
  double get totalFentMts => core.totalFentMts;

  /// Fresh Saree Yield Percentage (e.g. `84.34%`)
  double get freshYieldPct => core.freshPct;
  String get formattedFreshYield => freshYieldPct > 0 ? '${freshYieldPct.toStringAsFixed(1)}%' : '0.0%';

  /// Second Yield Percentage
  double get secondPct => core.secondPct;

  /// Wastage / Fent Yield Percentage
  double get fentPct => core.fentPct;

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

  /// Scanned Physical Card Picture Storage URI
  String? get cardPicPath => core.cardPics.isNotEmpty ? core.cardPics.first : null;

  /// Status (`COMPLETED`, `PENDING`, `IN_PROCESS`)
  String get status => core.status.isNotEmpty ? core.status : 'COMPLETED';

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isPending => !isCompleted;

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
  String get quality => core.quality;
  double get meters => core.recMtrs > 0 ? core.recMtrs : core.cutMtrs;
  double get pieces => core.freshPcs.toDouble();
  double get rate => core.greyRate;
  double get amount => core.totalLandedInvestment;

  String formattedAmount() => amount > 0 ? '₹${amount.toStringAsFixed(2)}' : '₹0.00';
}
