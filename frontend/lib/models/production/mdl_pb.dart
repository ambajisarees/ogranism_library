/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE BILLS DOMAIN MODEL (mdl_pb.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Domain Data Model for Purchase Bills (`pb` / Purchase Invoices).
   - Adapts canonical `SqBillsModel` (headers) and line item models from `sq_BILLDET`,
     `sq_PINVTRN`, or `sq_MILLREC` into unified domain objects.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Schemas/Tables: `IMMBE2627.sq_BILLS` (Header), `sq_PINVTRN` (Grey line items),
     `sq_MILLREC` (Mill line items), `sq_BILLDET` (all other 8 submodules line items).
   - Composite Join Keys: `CNO = header.CNO AND VNO = header.VNO AND TYPE = header.TYPE`.
   - 10 Submodule Categories & Series Codes:
     * Grey (`P1`): Line items from `sq_PINVTRN`
     * Mill / Job Work (`J1`): Line items from `sq_MILLREC`
     * Lace (`p11`): Line items from `sq_BILLDET`
     * Finish (`P2`): Line items from `sq_BILLDET`
     * Modelling (`P6`): Line items from `sq_BILLDET`
     * Stitching (`P26`): Line items from `sq_BILLDET`
     * Diamond (`P27`): Line items from `sq_BILLDET`
     * Embroidery (`P28`): Line items from `sq_BILLDET`
     * Charak (`P29`): Line items from `sq_BILLDET`
     * Packing Material (`P4`): Line items from `sq_BILLDET`

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_BILLS` is Airbyte-managed read-only mirror of MSSQL AMAZE.
   - Fiscal Constraint: Current year queries evaluate `VNO < 100000`.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../models/core/sq/sq_bills.dart';

/// The 10 Purchase Bill categories supported in the Ambaji ERP system.
enum PbCategory {
  grey,
  mill,
  lace,
  finish,
  modelling,
  stitching,
  diamond,
  embroidery,
  charak,
  packingMaterial,
}

extension PbCategoryExtension on PbCategory {
  /// Display label for UI dropdowns, badges, and submodule switchers
  String get displayName {
    switch (this) {
      case PbCategory.grey:
        return 'Grey';
      case PbCategory.mill:
        return 'Mill';
      case PbCategory.lace:
        return 'Lace';
      case PbCategory.finish:
        return 'Finish';
      case PbCategory.modelling:
        return 'Modelling';
      case PbCategory.stitching:
        return 'Stitching';
      case PbCategory.diamond:
        return 'Diamond';
      case PbCategory.embroidery:
        return 'Embroidery';
      case PbCategory.charak:
        return 'Charak';
      case PbCategory.packingMaterial:
        return 'Packing Material';
    }
  }

  /// ERP Series Code (`TYPE` column in `sq_BILLS`)
  String get seriesCode {
    switch (this) {
      case PbCategory.grey:
        return 'P1';
      case PbCategory.mill:
        return 'J1';
      case PbCategory.lace:
        return 'p11';
      case PbCategory.finish:
        return 'P2';
      case PbCategory.modelling:
        return 'P6';
      case PbCategory.stitching:
        return 'P26';
      case PbCategory.diamond:
        return 'P27';
      case PbCategory.embroidery:
        return 'P28';
      case PbCategory.charak:
        return 'P29';
      case PbCategory.packingMaterial:
        return 'P4';
    }
  }

  /// Database line-item source table for this purchase bill category
  String get lineItemTableName {
    switch (this) {
      case PbCategory.grey:
        return 'sq_PINVTRN';
      case PbCategory.mill:
        return 'sq_MILLREC';
      default:
        return 'sq_BILLDET';
    }
  }

  /// Lucide Icon for the category
  IconData get icon {
    switch (this) {
      case PbCategory.grey:
        return shad.LucideIcons.package;
      case PbCategory.mill:
        return shad.LucideIcons.factory;
      case PbCategory.lace:
        return shad.LucideIcons.scissors;
      case PbCategory.finish:
        return shad.LucideIcons.sparkles;
      case PbCategory.modelling:
        return shad.LucideIcons.camera;
      case PbCategory.stitching:
        return shad.LucideIcons.shirt;
      case PbCategory.diamond:
        return shad.LucideIcons.gem;
      case PbCategory.embroidery:
        return shad.LucideIcons.flower;
      case PbCategory.charak:
        return shad.LucideIcons.waves;
      case PbCategory.packingMaterial:
        return shad.LucideIcons.box;
    }
  }

  /// Helper finding category enum from series code
  static PbCategory fromSeriesCode(String code) {
    final search = code.trim();
    for (final cat in PbCategory.values) {
      if (cat.seriesCode.toLowerCase() == search.toLowerCase()) {
        return cat;
      }
    }
    return PbCategory.grey;
  }
}

/// [MdlPbHeader] — Domain Data Model for a Purchase Bill Header
@immutable
class MdlPbHeader {
  final SqBillsModel core;
  final List<MdlPbLineItem> lineItems;

  const MdlPbHeader({
    required this.core,
    this.lineItems = const [],
  });

  /// Voucher Primary Key (VNO)
  int get vno => core.vno;

  /// Company Code (CNO)
  int get cno => core.cno;

  /// Series Type (e.g. `P1`, `P2`, `J1`, `p11`, `P26`)
  String get type => core.type;

  /// Formatted Voucher / Bill Number (e.g., `#1828`)
  String get displayBillNo => '#${core.vno}';

  /// Supplier / Party Ledger Name
  String get partyName => core.partyName.isNotEmpty ? core.partyName : 'Unknown Party';

  /// Primary Fabric Quality
  String get primaryQuality => core.quality.isNotEmpty ? core.quality : 'N/A';

  /// Bill Date
  DateTime get date => core.date ?? DateTime.now();

  /// Formatted Date String (e.g. `15 Jul 2026`)
  String get formattedDate {
    final dt = date;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  /// Total Net Bill Amount (₹)
  double get finalAmount => core.finalAmount;

  /// Formatted Final Amount String (e.g. `₹73,393`)
  String get formattedFinalAmount {
    if (finalAmount <= 0) return '₹0';
    final intPart = finalAmount.round().toString();

    if (intPart.length <= 3) return '₹$intPart';
    final last3 = intPart.substring(intPart.length - 3);
    final rest = intPart.substring(0, intPart.length - 3);
    final formattedRest = rest.replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+$)'), (m) => '${m[1]},');
    return '₹$formattedRest,$last3';
  }

  /// Total Quantity (Pcs & Meters)
  double get totalMeters => core.totalMeters;
  int get totalPcs => core.totalPieces;

  /// Formatted Combined Quantity String (e.g., `31 Pcs / 3683.0 Mtr`)
  String get formattedQuantity {
    if (totalPcs > 0 && totalMeters > 0) {
      return '$totalPcs Pcs / ${totalMeters.toStringAsFixed(1)} Mtr';
    } else if (totalMeters > 0) {
      return '${totalMeters.toStringAsFixed(1)} Mtr';
    } else if (totalPcs > 0) {
      return '$totalPcs Pcs';
    } else {
      return '-';
    }
  }

  /// Pendency / Completion Status
  bool get isPending => core.paymentStatus != 'Y';
  bool get isCompleted => !isPending;
  String get status => isPending ? 'Pending' : 'Completed';

  /// Supplier Invoice Number
  String get weaverBillNo => core.billNo;

  /// Copy with new line items or properties
  MdlPbHeader copyWith({
    List<MdlPbLineItem>? lineItems,
  }) {
    return MdlPbHeader(
      core: core,
      lineItems: lineItems ?? this.lineItems,
    );
  }
}

/// [MdlPbLineItem] — Domain Data Model for a Purchase Bill Line Item
@immutable
class MdlPbLineItem {
  final int srNo;
  final String quality;
  final double meters;
  final int pcs;
  final double rate;
  final double amount;
  final Map<String, dynamic> rawJson;

  const MdlPbLineItem({
    required this.srNo,
    required this.quality,
    required this.meters,
    required this.pcs,
    required this.rate,
    required this.amount,
    required this.rawJson,
  });

  /// Generic Factory parsing line item from `sq_BILLDET`, `sq_PINVTRN`, or `sq_MILLREC`
  factory MdlPbLineItem.fromJson(Map<String, dynamic> json, String tableName) {
    if (tableName == 'sq_PINVTRN') {
      // Grey Purchase line item (`sq_PINVTRN`)
      final mts = (json['MTS'] as num?)?.toDouble() ?? 0.0;
      final pcs = (json['PCS'] as num?)?.toInt() ?? 0;
      final rate = (json['RATE'] as num?)?.toDouble() ?? 0.0;
      final amt = (json['AMT'] as num?)?.toDouble() ?? (mts * rate);

      return MdlPbLineItem(
        srNo: (json['SRNO'] as num?)?.toInt() ?? 0,
        quality: (json['QUAL'] as String?)?.trim() ?? '',
        meters: mts,
        pcs: pcs,
        rate: rate,
        amount: amt,
        rawJson: json,
      );
    } else if (tableName == 'sq_MILLREC') {
      // Mill / Job Work line item (`sq_MILLREC`)
      final mts = (json['RMTS'] as num?)?.toDouble() ?? 0.0;
      final pcs = (json['RPCS'] as num?)?.toInt() ?? 0;
      final rate = (json['JOBRATE'] as num?)?.toDouble() ?? 0.0;
      final amt = (json['AMT'] as num?)?.toDouble() ?? (mts * rate);

      return MdlPbLineItem(
        srNo: (json['SRNO'] as num?)?.toInt() ?? 0,
        quality: (json['GREYQUAL'] as String?)?.trim() ?? '',
        meters: mts,
        pcs: pcs,
        rate: rate,
        amount: amt,
        rawJson: json,
      );
    } else {
      // Standard purchase bill detail line item (`sq_BILLDET`)
      final mts = (json['MTS'] as num?)?.toDouble() ?? 0.0;
      final pcs = (json['PCS'] as num?)?.toInt() ?? 0;
      final rate = (json['RATE'] as num?)?.toDouble() ?? 0.0;
      final amt = (json['AMT'] as num?)?.toDouble() ?? (mts * rate);

      return MdlPbLineItem(
        srNo: (json['SRNO'] as num?)?.toInt() ?? 0,
        quality: (json['QUAL'] as String?)?.trim() ?? '',
        meters: mts,
        pcs: pcs,
        rate: rate,
        amount: amt,
        rawJson: json,
      );
    }
  }

  String formattedAmount() => amount > 0 ? '₹${amount.toStringAsFixed(2)}' : '₹0.00';
}
