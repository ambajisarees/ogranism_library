import 'package:meta/meta.dart';

/// [DesignModel] — Represents a cataloged SKU Design under a finished Quality category.
@immutable
class DesignModel {
  final String id;
  final String itemQCode;       // Finished quality parent code (e.g. VIDHI, ALEXA)
  final String designNo;        // Unique design code (e.g. ALEXA-102, ALEXA-MAIN)
  final int designIndex;        // Numeric auto-increment tracker index (0 for master)
  final String status;          // 'in_production', 'at_mill', 'in_stock', 'archived'
  final bool isMaster;          // Non-dispatchable reference card for sales/rough-booking
  final String? setPicPath;     // Group color matching image storage path
  final String? setPosterPath;  // Professional model photoshoot poster path
  final String? catalogPdfPath;  // Catalog PDF catalog document path
  final int openingBalance;
  final int stockProduction;
  final int stockReady;
  final int stockSold;
  final int stockDamaged;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DesignModel({
    required this.id,
    required this.itemQCode,
    required this.designNo,
    required this.designIndex,
    required this.status,
    required this.isMaster,
    this.setPicPath,
    this.setPosterPath,
    this.catalogPdfPath,
    required this.openingBalance,
    required this.stockProduction,
    required this.stockReady,
    required this.stockSold,
    required this.stockDamaged,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  DesignModel copyWith({
    String? id,
    String? itemQCode,
    String? designNo,
    int? designIndex,
    String? status,
    bool? isMaster,
    String? setPicPath,
    String? setPosterPath,
    String? catalogPdfPath,
    int? openingBalance,
    int? stockProduction,
    int? stockReady,
    int? stockSold,
    int? stockDamaged,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DesignModel(
      id: id ?? this.id,
      itemQCode: itemQCode ?? this.itemQCode,
      designNo: designNo ?? this.designNo,
      designIndex: designIndex ?? this.designIndex,
      status: status ?? this.status,
      isMaster: isMaster ?? this.isMaster,
      setPicPath: setPicPath ?? this.setPicPath,
      setPosterPath: setPosterPath ?? this.setPosterPath,
      catalogPdfPath: catalogPdfPath ?? this.catalogPdfPath,
      openingBalance: openingBalance ?? this.openingBalance,
      stockProduction: stockProduction ?? this.stockProduction,
      stockReady: stockReady ?? this.stockReady,
      stockSold: stockSold ?? this.stockSold,
      stockDamaged: stockDamaged ?? this.stockDamaged,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory DesignModel.fromJson(Map<String, dynamic> json) {
    return DesignModel(
      id: json['id'] as String? ?? '',
      itemQCode: json['item_qcode'] as String? ?? 'N/A',
      designNo: json['design_no'] as String? ?? 'N/A',
      designIndex: (json['design_index'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'in_stock',
      isMaster: json['is_master'] as bool? ?? false,
      setPicPath: json['set_pic_path'] as String?,
      setPosterPath: json['set_poster_path'] as String?,
      catalogPdfPath: json['catalog_pdf_path'] as String?,
      openingBalance: (json['opening_balance'] as num?)?.toInt() ?? 0,
      stockProduction: (json['stock_production'] as num?)?.toInt() ?? 0,
      stockReady: (json['stock_ready'] as num?)?.toInt() ?? 0,
      stockSold: (json['stock_sold'] as num?)?.toInt() ?? 0,
      stockDamaged: (json['stock_damaged'] as num?)?.toInt() ?? 0,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
    );
  }

  /// Helper to convert status string into human-readable label
  String get displayStatus {
    switch (status) {
      case 'in_production':
        return 'In Production';
      case 'at_mill':
        return 'At Mill';
      case 'in_stock':
        return 'In Stock';
      case 'archived':
        return 'Archived';
      default:
        return 'Active';
    }
  }
}
