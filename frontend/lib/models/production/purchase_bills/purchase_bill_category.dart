import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Target line-item source tables in the database.
enum LineItemSourceTable {
  pinvtrn, // sq_PINVTRN (Grey Takhta rolls)
  millrec, // sq_MILLREC (Mill receipt records)
  billdet, // sq_BILLDET (Standard bill detail lines)
}

/// The 10 Purchase Bill categories supported in the Ambaji ERP system.
enum PurchaseBillCategory {
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

extension PurchaseBillCategoryExtension on PurchaseBillCategory {
  /// Display label for UI dropdowns and badges
  String get label {
    switch (this) {
      case PurchaseBillCategory.grey:
        return 'Grey';
      case PurchaseBillCategory.mill:
        return 'Mill';
      case PurchaseBillCategory.lace:
        return 'Lace';
      case PurchaseBillCategory.finish:
        return 'Finish';
      case PurchaseBillCategory.modelling:
        return 'Modelling';
      case PurchaseBillCategory.stitching:
        return 'Stitching';
      case PurchaseBillCategory.diamond:
        return 'Diamond';
      case PurchaseBillCategory.embroidery:
        return 'Embroidery';
      case PurchaseBillCategory.charak:
        return 'Charak';
      case PurchaseBillCategory.packingMaterial:
        return 'Packing Material';
    }
  }

  /// ERP Series Code (`TYPE` column in `sq_BILLS`)
  String get seriesCode {
    switch (this) {
      case PurchaseBillCategory.grey:
        return 'P1';
      case PurchaseBillCategory.mill:
        return 'J1';
      case PurchaseBillCategory.lace:
        return 'p11';
      case PurchaseBillCategory.finish:
        return 'P2';
      case PurchaseBillCategory.modelling:
        return 'P6';
      case PurchaseBillCategory.stitching:
        return 'P26';
      case PurchaseBillCategory.diamond:
        return 'P27';
      case PurchaseBillCategory.embroidery:
        return 'P28';
      case PurchaseBillCategory.charak:
        return 'P29';
      case PurchaseBillCategory.packingMaterial:
        return 'P4';
    }
  }

  /// Database line-item source table
  LineItemSourceTable get lineItemSource {
    switch (this) {
      case PurchaseBillCategory.grey:
        return LineItemSourceTable.pinvtrn;
      case PurchaseBillCategory.mill:
        return LineItemSourceTable.millrec;
      default:
        return LineItemSourceTable.billdet;
    }
  }

  /// Lucide Icon for the category
  IconData get icon {
    switch (this) {
      case PurchaseBillCategory.grey:
        return shad.LucideIcons.package;
      case PurchaseBillCategory.mill:
        return shad.LucideIcons.factory;
      case PurchaseBillCategory.lace:
        return shad.LucideIcons.scissors;
      case PurchaseBillCategory.finish:
        return shad.LucideIcons.sparkles;
      case PurchaseBillCategory.modelling:
        return shad.LucideIcons.camera;
      case PurchaseBillCategory.stitching:
        return shad.LucideIcons.shirt;
      case PurchaseBillCategory.diamond:
        return shad.LucideIcons.gem;
      case PurchaseBillCategory.embroidery:
        return shad.LucideIcons.flower;
      case PurchaseBillCategory.charak:
        return shad.LucideIcons.waves;
      case PurchaseBillCategory.packingMaterial:
        return shad.LucideIcons.box;
    }
  }

  /// Finds category from series code
  static PurchaseBillCategory fromSeriesCode(String code) {
    final search = code.trim();
    for (final cat in PurchaseBillCategory.values) {
      if (cat.seriesCode.toLowerCase() == search.toLowerCase()) {
        return cat;
      }
    }
    return PurchaseBillCategory.grey;
  }
}
