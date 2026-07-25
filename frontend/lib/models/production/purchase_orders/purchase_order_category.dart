import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Target line-item source tables in the database for Purchase Orders.
enum POLineItemSourceTable {
  billdet, // sq_BILLDET (Standard bill detail lines for POs)
}

/// The 5 Purchase Order categories supported in the Ambaji ERP system.
enum PurchaseOrderCategory {
  grey,
  finish,
  lace,
  studio,
  packing,
}

extension PurchaseOrderCategoryExtension on PurchaseOrderCategory {
  /// Display label for UI dropdowns, tabs, and badges
  String get label {
    switch (this) {
      case PurchaseOrderCategory.grey:
        return 'Grey';
      case PurchaseOrderCategory.finish:
        return 'Finish';
      case PurchaseOrderCategory.lace:
        return 'Lace';
      case PurchaseOrderCategory.studio:
        return 'Studio';
      case PurchaseOrderCategory.packing:
        return 'Packing';
    }
  }

  /// ERP Series Code (`TYPE` column in `sq_BILLS`)
  /// Returns null for Grey since Grey POs are currently empty/placeholder.
  String? get seriesCode {
    switch (this) {
      case PurchaseOrderCategory.grey:
        return null;
      case PurchaseOrderCategory.finish:
        return 'O13';
      case PurchaseOrderCategory.lace:
        return 'O14';
      case PurchaseOrderCategory.studio:
        return 'O16';
      case PurchaseOrderCategory.packing:
        return 'O15';
    }
  }

  /// ERP Bill Type Code (`BILLATYPE` column in `sq_SERIES`)
  int? get billType {
    switch (this) {
      case PurchaseOrderCategory.grey:
        return null;
      case PurchaseOrderCategory.finish:
        return 113;
      case PurchaseOrderCategory.lace:
        return 105;
      case PurchaseOrderCategory.studio:
        return 120;
      case PurchaseOrderCategory.packing:
        return 112;
    }
  }

  /// Returns true if this category is currently an empty placeholder
  bool get isEmptyCategory => seriesCode == null;

  /// Database line-item source table
  POLineItemSourceTable get lineItemSource => POLineItemSourceTable.billdet;

  /// Lucide Icon for the category
  IconData get icon {
    switch (this) {
      case PurchaseOrderCategory.grey:
        return shad.LucideIcons.package;
      case PurchaseOrderCategory.finish:
        return shad.LucideIcons.sparkles;
      case PurchaseOrderCategory.lace:
        return shad.LucideIcons.scissors;
      case PurchaseOrderCategory.studio:
        return shad.LucideIcons.camera;
      case PurchaseOrderCategory.packing:
        return shad.LucideIcons.box;
    }
  }

  /// Finds category from series code
  static PurchaseOrderCategory fromSeriesCode(String? code) {
    if (code == null) return PurchaseOrderCategory.grey;
    final search = code.trim();
    for (final cat in PurchaseOrderCategory.values) {
      if (cat.seriesCode != null && cat.seriesCode!.toLowerCase() == search.toLowerCase()) {
        return cat;
      }
    }
    return PurchaseOrderCategory.grey;
  }
}
