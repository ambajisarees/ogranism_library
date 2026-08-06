/*
================================================================================
LLM CONTEXT & QUERY SPACE — SQ QUAL MODEL (sq_qual.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical 1-to-1 data model for table `IMMBE2627.sq_QUAL` (Quality / Items Master — 1,016 rows).
   - Airbyte-managed read-only mirror of MSSQL AMAZE Quality Master table.
   - Defines fabric quality items, sales pricing (SELL1/2/3), tax compliance (HSN/GST), and production specs (CUT/PACKING).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Primary Key: `qcode` (100% unique string identifier).
   - Identity: `NAME` (100% populated display name).
   - `ISBASEQUAL` Barrels:
     - 'N' (870 items): Active Finished Sales Catalog Items.
     - 'Y' (111 items): Raw Grey Base Fabrics used in Weaving & Cutting Cards.
     - 'G' (35 items): Generic / Misc, Freight & Hardware entries.
   - Taxonomy: `CLOTHTYPE` (SAREE, FINAL, DRESS, material, -), `category` (SAREES, 2025, NAMAMI, EMB), `UNIT` (PCS, MTS).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_QUAL` is Airbyte-managed and Strictly Read-Only.
   - `pur1` and `COST_PER` are 99.7% NULL/Zero in database; procurement pricing is tracked in bills.
   - `SELL1` represents the primary catalog selling rate.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should future catalog images link to `qcode` or `itemsrno`?
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';

/// [SqQualModel] — Refined Canonical 1-to-1 Data Model for `sq_QUAL` (Item / Quality Master).
@immutable
class SqQualModel {
  final String qcode;
  final String name;
  final String clothType;
  final String category;
  final String unit;
  final String hsnCode;
  final double gstRate;
  final double sell1;
  final double sell2;
  final double sell3;
  final double pur1;
  final double costPer;
  final double cut;
  final double actCut;
  final String isBaseQual;
  final String baseQual;
  final String packing;
  final int pcsPerSet;
  final double avgWt;
  final double expectShortage;
  final String itemSrNo;
  final String author;
  final String updater;
  final DateTime? createdOn;
  final DateTime? lastEdited;
  final DateTime? syncTime;
  final Map<String, dynamic> rawJson;

  const SqQualModel({
    required this.qcode,
    required this.name,
    required this.clothType,
    required this.category,
    required this.unit,
    required this.hsnCode,
    required this.gstRate,
    required this.sell1,
    required this.sell2,
    required this.sell3,
    required this.pur1,
    required this.costPer,
    required this.cut,
    required this.actCut,
    required this.isBaseQual,
    required this.baseQual,
    required this.packing,
    required this.pcsPerSet,
    required this.avgWt,
    required this.expectShortage,
    required this.itemSrNo,
    required this.author,
    required this.updater,
    this.createdOn,
    this.lastEdited,
    this.syncTime,
    required this.rawJson,
  });

  /// Defensive `fromJson` factory handling Postgres 17 types safely.
  factory SqQualModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return SqQualModel(
      qcode: (json['qcode'] as String?)?.trim() ?? '',
      name: (json['NAME'] as String?)?.trim() ?? (json['qcode'] as String?)?.trim() ?? 'N/A',
      clothType: (json['CLOTHTYPE'] as String?)?.trim() ?? '-',
      category: (json['category'] as String?)?.trim() ?? '',
      unit: (json['UNIT'] as String?)?.trim() ?? 'PCS',
      hsnCode: (json['HSN_CODE'] as String?)?.trim() ?? '',
      gstRate: (json['GSTRATE'] as num?)?.toDouble() ?? 0.0,
      sell1: (json['SELL1'] as num?)?.toDouble() ?? 0.0,
      sell2: (json['SELL2'] as num?)?.toDouble() ?? 0.0,
      sell3: (json['SELL3'] as num?)?.toDouble() ?? 0.0,
      pur1: (json['pur1'] as num?)?.toDouble() ?? 0.0,
      costPer: (json['COST_PER'] as num?)?.toDouble() ?? 0.0,
      cut: (json['CUT'] as num?)?.toDouble() ?? 0.0,
      actCut: (json['ACT_CUT'] as num?)?.toDouble() ?? 0.0,
      isBaseQual: (json['ISBASEQUAL'] as String?)?.trim() ?? 'N',
      baseQual: (json['BASEQUAL'] as String?)?.trim() ?? '',
      packing: (json['PACKING'] as String?)?.trim() ?? '',
      pcsPerSet: (json['PCS_PER_SET'] as num?)?.toInt() ?? 0,
      avgWt: (json['avg_wt'] as num?)?.toDouble() ?? 0.0,
      expectShortage: (json['EXPECT_SHORTAGE'] as num?)?.toDouble() ?? 0.0,
      itemSrNo: (json['itemsrno'] as String?)?.trim() ?? '',
      author: (json['CREATOR'] as String?)?.trim() ?? '',
      updater: (json['UPDATER'] as String?)?.trim() ?? '',
      createdOn: parseDate(json['CREATETIME']),
      lastEdited: parseDate(json['UPDATETIME']),
      syncTime: parseDate(json['_sync_time']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'qcode': qcode,
        'NAME': name,
        'CLOTHTYPE': clothType,
        'category': category,
        'UNIT': unit,
        'HSN_CODE': hsnCode,
        'GSTRATE': gstRate,
        'SELL1': sell1,
        'SELL2': sell2,
        'SELL3': sell3,
        'pur1': pur1,
        'COST_PER': costPer,
        'CUT': cut,
        'ACT_CUT': actCut,
        'ISBASEQUAL': isBaseQual,
        'BASEQUAL': baseQual,
        'PACKING': packing,
        'PCS_PER_SET': pcsPerSet,
        'avg_wt': avgWt,
        'EXPECT_SHORTAGE': expectShortage,
        'itemsrno': itemSrNo,
        'CREATOR': author,
        'UPDATER': updater,
        'CREATETIME': createdOn?.toIso8601String(),
        'UPDATETIME': lastEdited?.toIso8601String(),
        '_sync_time': syncTime?.toIso8601String(),
      };

  // Domain Helper Getters
  bool get isGreyBaseFabric => isBaseQual == 'Y' || isBaseQual == 'G';
  bool get isSalesCatalogItem => isBaseQual == 'N' && (clothType == 'SAREE' || clothType == 'FINAL' || clothType == 'DRESS');
  bool get isMiscOrHardware => !isGreyBaseFabric && !isSalesCatalogItem;
}

/// Standardized UI Field Labels for `sq_QUAL`
abstract class SqQualLabels {
  static const String qcode = 'Item Code';
  static const String name = 'Item Name';
  static const String clothType = 'Cloth Type';
  static const String category = 'Collection / Category';
  static const String unit = 'Unit';
  static const String hsnCode = 'HSN Code';
  static const String gstRate = 'GST Rate';
  static const String sell1 = 'Sell Price (SELL1)';
  static const String sell2 = 'Wholesale (SELL2)';
  static const String cut = 'Standard Cut';
  static const String isBaseQual = 'Base Fabric Flag';
  static const String packing = 'Packing';
}

/// Dynamic Table UI Mapper Extension for `SqQualModel`
extension SqQualTableMapper on SqQualModel {
  DyTableRowData toRowData([NumberFormat? currencyFmt]) {
    final fmt = currencyFmt ?? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return DyTableRowData(
      id: qcode,
      voucherNo: qcode,
      partyName: name,
      designPattern: category.isNotEmpty ? category : clothType,
      quantity: cut > 0 ? '${cut.toStringAsFixed(2)} Mtr' : unit,
      amount: sell1 > 0 ? fmt.format(sell1) : '-',
      amountValue: sell1,
      status: isGreyBaseFabric ? 'GREY' : (sell1 > 0 ? 'ACTIVE' : 'DRAFT'),
      rawData: toJson(),
    );
  }

  static List<DyTableColumnSpec> get defaultColumns => const [
        DyTableColumnSpec(label: SqQualLabels.qcode, key: 'voucherNo', flex: 3),
        DyTableColumnSpec(label: SqQualLabels.name, key: 'partyName', flex: 4),
        DyTableColumnSpec(label: SqQualLabels.category, key: 'designPattern', flex: 2),
        DyTableColumnSpec(label: SqQualLabels.cut, key: 'quantity', flex: 2),
        DyTableColumnSpec(label: SqQualLabels.sell1, key: 'amount', flex: 3),
      ];
}
