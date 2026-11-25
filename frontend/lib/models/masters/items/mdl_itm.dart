/*
================================================================================
LLM CONTEXT & QUERY SPACE — ITEMS MODULE DATA MODELS (mdl_itm.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Data Model for Items / Quality Master (`itm` / Master Layer).
   - Wraps canonical `SqQualModel` instances from table `IMMBE2627.sq_QUAL` (1,016 items).
   - Maps database columns to 3-tiered table structures (`DyTable`) and categorizes items into 4 functional barrels.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Submodule Categorization (`ItmCategory`):
     - `all`: All 1,016 items in master quality registry.
     - `saree`: Finished Sales Sarees (`ISBASEQUAL = 'N'` & `CLOTHTYPE` IN ('SAREE', 'FINAL', 'DRESS')).
     - `grey`: Raw Grey Base Fabrics (`ISBASEQUAL` IN ('Y', 'G') & used in weaving/cutting).
     - `others`: Non-saree items, stationery, hardware, accessories, freight.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `SELL1` represents catalog selling price.
   - `CUT` represents standard saree manufacturing cut length.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../core/sq/sq_qual.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';

/// Functional Submodule Categories for Items Master
enum ItmCategory {
  all,
  saree,
  grey,
  others;

  String get displayName {
    switch (this) {
      case ItmCategory.all:
        return 'All Items';
      case ItmCategory.saree:
        return 'Finished Sarees';
      case ItmCategory.grey:
        return 'Grey Fabrics';
      case ItmCategory.others:
        return 'Others & Misc';
    }
  }

  IconData get icon {
    switch (this) {
      case ItmCategory.all:
        return shad.LucideIcons.package;
      case ItmCategory.saree:
        return shad.LucideIcons.shirt;
      case ItmCategory.grey:
        return shad.LucideIcons.layers;
      case ItmCategory.others:
        return shad.LucideIcons.box;
    }
  }
}

/// [MdlItmHeader] — Primary Domain Model for Item Master Row Representation
@immutable
class MdlItmHeader {
  final SqQualModel core;

  const MdlItmHeader({required this.core});

  String get qcode => core.qcode;
  String get name => core.name;
  String get clothType => core.clothType;
  String get category => core.category;
  String get unit => core.unit;
  String get hsnCode => core.hsnCode;
  double get gstRate => core.gstRate;
  double get sellPrice => core.sell1;
  double get wholesalePrice => core.sell2;
  double get cutLength => core.cut;
  String get isBaseQual => core.isBaseQual;
  String get packingStyle => core.packing;

  bool get isGreyFabric => core.isGreyBaseFabric;
  bool get isFinishedSaree => core.isSalesCatalogItem;
  bool get isMisc => core.isMiscOrHardware;

  String formattedSellPrice([NumberFormat? fmt]) {
    if (sellPrice <= 0) return '-';
    final f = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return f.format(sellPrice);
  }

  /// Convert into a Tier 2 Document Header Row for [DyTable]
  DyTableRowData toDyDefRowData([NumberFormat? fmt]) {
    final currencyFmt = fmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DyTableRowData(
      id: qcode,
      rowType: DyTableRowType.def,
      voucherNo: qcode,
      partyName: name,
      designPattern: category.isNotEmpty ? category : clothType,
      quantity: cutLength > 0 ? '${cutLength.toStringAsFixed(2)} Mtr' : unit,
      amount: formattedSellPrice(currencyFmt),
      amountValue: sellPrice,
      status: isGreyFabric ? 'GREY' : (sellPrice > 0 ? 'ACTIVE' : 'DRAFT'),
      data: {
        'vno': qcode,
        'partyName': name,
        'clothtype': clothType,
        'category': category.isNotEmpty ? category : '-',
        'designPattern': category.isNotEmpty ? category : clothType,
        'unit': unit,
        'hsn': hsnCode.isNotEmpty ? hsnCode : '-',
        'gstRate': gstRate > 0 ? '${gstRate.toStringAsFixed(1)}%' : '-',
        'cut': cutLength > 0 ? '${cutLength.toStringAsFixed(2)} Mtr' : '-',
        'quantity': cutLength > 0 ? '${cutLength.toStringAsFixed(2)} Mtr' : unit,
        'amount': formattedSellPrice(currencyFmt),
        'status': isGreyFabric ? 'GREY' : (sellPrice > 0 ? 'ACTIVE' : 'DRAFT'),
      },
      rawData: core.rawJson,
    );
  }
}
