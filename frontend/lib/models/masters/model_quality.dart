/// ============================================================
/// PHASE 1 — Master Data Models
/// ============================================================
/// 
/// Type-safe model for the Quality Master (vwsq_qual).
/// Handles fabric taxonomy, pricing lists, and production specs.
/// ============================================================
library;

class QualityModel {
  // 1. IDENTITY & TAXONOMY
  final String qcode;
  final String name;
  final String clothType;
  final String unit;
  final String? category;
  final String? itemsrno;
  final String? mainScreen;
  final String? baseQualityCode; // BASEQUAL
  final String isBaseQual; // ISBASEQUAL (Y/N)

  // 2. SALES & PRICING
  final double sellRate1; // SELL1

  // 3. PRODUCTION & SPECS
  final double standardCut; // CUT
  final String? packingStyle; // PACKING

  // 4. COMPLIANCE & TAX
  final String? hsnCode; // HSN_CODE
  final double gstRate; // GSTRATE

  QualityModel({
    required this.qcode,
    required this.name,
    required this.clothType,
    required this.unit,
    this.category,
    this.itemsrno,
    this.mainScreen,
    this.baseQualityCode,
    required this.isBaseQual,
    required this.sellRate1,
    required this.standardCut,
    this.packingStyle,
    this.hsnCode,
    required this.gstRate,
  });

  /// Helper for UI logic
  bool get isGrey => isBaseQual == 'Y';

  factory QualityModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return QualityModel(
      qcode: json['qcode'] ?? '',
      name: json['NAME'] ?? 'Unknown Quality',
      clothType: json['CLOTHTYPE'] ?? 'UNCLASSIFIED',
      unit: json['UNIT'] ?? 'PCS',
      category: json['category'],
      itemsrno: json['itemsrno'],
      mainScreen: json['MAINSCREEN'],
      baseQualityCode: json['BASEQUAL'],
      isBaseQual: json['ISBASEQUAL'] ?? 'N',
      sellRate1: parseDouble(json['SELL1']),
      standardCut: parseDouble(json['CUT']),
      packingStyle: json['PACKING'],
      hsnCode: json['HSN_CODE'],
      gstRate: parseDouble(json['GSTRATE']),
    );
  }
}
