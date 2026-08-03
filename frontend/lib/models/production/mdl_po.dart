/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE ORDERS MODULE MODEL (mdl_po.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Domain-specific module data model for Purchase Orders (`po`).
   - Wraps canonical core models `SqBillsModel` and `SqBilldetModel` to provide PO-specific getters, category mapping (`O13`/`O14`/`O15`/`O16`), status computations, and line item lists.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `PoCategory`: Enum representing the 5 PO submodules (`grey`, `finish`, `lace`, `packing`, `studio`).
   - `MdlPoHeader`: Encapsulates header details, supplier name, voucher series (`O13`-`O16`), order amount, and pendency state.
   - `MdlPoLineItem`: Encapsulates detail item lines (fabric quality, meters, pieces, negotiated unit rate, and total line amount).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Core model `sq_BILLS` remains 100% read-only and untouched.
   - `grey` category uses null `seriesCode` as a placeholder for raw grey purchase order allocations.
   - Pendency rule evaluates to pending when `paymentStatus` is `'N'` or empty.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: Add transactional payload builder (`toInsertJson()`) for Deno Edge Function PO creation transactions.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../core/sq/sq_bills.dart';
import '../core/sq/sq_billdet.dart';

/// The 5 Purchase Order categories supported in Ambaji ERP.
enum PoCategory {
  grey(null, 'Grey', shad.LucideIcons.scroll),
  finish('O13', 'Finish', shad.LucideIcons.packageCheck),
  lace('O14', 'Lace', shad.LucideIcons.sparkles),
  packing('O15', 'Packing', shad.LucideIcons.box),
  studio('O16', 'Studio', shad.LucideIcons.camera);

  final String? seriesCode;
  final String label;
  final IconData icon;

  const PoCategory(this.seriesCode, this.label, this.icon);

  /// Resolves `PoCategory` from legacy series code string (`TYPE` column)
  static PoCategory fromSeriesCode(String? code) {
    if (code == null || code.trim().isEmpty) return PoCategory.finish;
    final search = code.trim().toUpperCase();
    for (final cat in PoCategory.values) {
      if (cat.seriesCode != null && cat.seriesCode!.toUpperCase() == search) {
        return cat;
      }
    }
    return PoCategory.finish;
  }
}

/// [MdlPoHeader] — Purchase Order Domain Model wrapping `SqBillsModel`.
@immutable
class MdlPoHeader {
  final SqBillsModel core;
  final List<MdlPoLineItem> lineItems;

  const MdlPoHeader({
    required this.core,
    this.lineItems = const [],
  });

  // Core unwrapped getters for UI convenience
  int get cno => core.cno;
  int get vno => core.vno;
  String get type => core.type;
  String get billNo => core.billNo;
  DateTime? get date => core.date;
  String get partyName => core.partyName;
  String get brokerName => core.brokerName;
  String get quality => core.quality;
  double get rate => core.rate;
  double get billAmount => core.billAmount;
  double get finalAmount => core.finalAmount;
  double get totalMeters => core.totalMeters;
  int get totalPieces => core.totalPieces;
  String get paymentStatus => core.paymentStatus;
  String get remarks => core.remarks;
  String get author => core.author;

  /// Resolved PO Submodule Category
  PoCategory get category => PoCategory.fromSeriesCode(type);

  /// Standardized Display Order Number (e.g. "PO-10485" or "PO-O13-10485")
  String get displayOrderNo => billNo.isNotEmpty ? billNo : 'PO-${type.toUpperCase()}-$vno';

  /// Pendency evaluation (True if payment or fulfillment is pending)
  bool get isPending => paymentStatus.toUpperCase() == 'N' || paymentStatus.trim().isEmpty;

  /// Primary Fabric quality aggregated from line items (or fallback to header quality)
  String get primaryFabric {
    if (lineItems.isNotEmpty) {
      final qualities = lineItems.map((i) => i.quality).where((q) => q.trim().isNotEmpty).toSet();
      if (qualities.isNotEmpty) return qualities.join(', ');
    }
    return quality.trim().isNotEmpty ? quality.trim() : 'N/A';
  }

  /// Average / Negotiated Unit Rate
  double get averageRate {
    if (rate > 0) return rate;
    if (lineItems.isNotEmpty) {
      final valid = lineItems.where((i) => i.rate > 0);
      if (valid.isNotEmpty) {
        final totalAmt = valid.fold<double>(0, (sum, i) => sum + i.amount);
        final totalMts = valid.fold<double>(0, (sum, i) => sum + (i.meters > 0 ? i.meters : i.pieces));
        if (totalMts > 0) return totalAmt / totalMts;
        return valid.first.rate;
      }
    }
    return 0.0;
  }

  /// Formatted Rate String
  String formattedRate([NumberFormat? fmt]) {
    final r = averageRate;
    if (r <= 0) return '-';
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(r);
  }

  /// Formatted Date string
  String get formattedDate {
    if (date == null) return 'N/A';
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  /// Formatted Final Currency Amount
  String formattedFinalAmount([NumberFormat? fmt]) {
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(finalAmount > 0 ? finalAmount : billAmount);
  }

  /// Linked Job / Order number from RRNO (or fallback)
  String get jobLink => core.lrNo.trim().isNotEmpty ? core.lrNo.trim() : '-';

  /// Total Pieces display string
  String get totalPcsDisplay {
    if (totalPieces > 0) return '$totalPieces';
    if (lineItems.isNotEmpty) {
      final pcs = lineItems.fold<double>(0, (sum, i) => sum + i.pieces);
      if (pcs > 0) return '${pcs.toInt()}';
    }
    return '-';
  }

  /// Total Quantity display string
  String get totalQtyDisplay {
    if (totalMeters > 0) return totalMeters.toStringAsFixed(1);
    if (lineItems.isNotEmpty) {
      final mts = lineItems.fold<double>(0, (sum, i) => sum + i.meters);
      if (mts > 0) return mts.toStringAsFixed(1);
    }
    return '-';
  }

  /// Primary Unit display string
  String get primaryUnit {
    if (lineItems.isNotEmpty) {
      final u = lineItems.first.unit.trim();
      if (u.isNotEmpty) return u;
    }
    return totalPieces > 0 && totalMeters == 0 ? 'PCS' : 'MTR';
  }

  /// Copy with updated line items list
  MdlPoHeader copyWith({List<MdlPoLineItem>? lineItems}) {
    return MdlPoHeader(
      core: core,
      lineItems: lineItems ?? this.lineItems,
    );
  }
}

/// [MdlPoLineItem] — Purchase Order Detail Line Item wrapping `SqBilldetModel`.
@immutable
class MdlPoLineItem {
  final SqBilldetModel core;

  const MdlPoLineItem({
    required this.core,
  });

  int get cno => core.cno;
  int get vno => core.vno;
  String get type => core.type;
  int get srNo => core.srNo;
  String get quality => core.quality;
  double get meters => core.meters;
  double get pieces => core.pieces;
  double get rate => core.rate;
  double get amount => core.amount;
  double get cutLength => core.cutLength;
  String get unit => core.unit;
  String get hsnCode => core.hsnCode;

  /// Formatted Quantity string (e.g. "120 Mtr" or "50 Pcs")
  String get formattedQuantity => pieces > 0 ? '${pieces.toInt()} Pcs' : '${meters.toStringAsFixed(1)} Mtr';

  /// Formatted Line Amount
  String formattedAmount([NumberFormat? fmt]) {
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(amount);
  }
}
