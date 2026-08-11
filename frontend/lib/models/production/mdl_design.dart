/*
================================================================================
LLM CONTEXT & QUERY SPACE — DESIGN MASTER DATA MODEL (mdl_design.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Data Model for Designs Master (`sb_designs`).
   - Anchored on composite primary business key `design_code` (`itemqcode-design_no`, e.g., `VIDHI-MAIN` or `VIDHI-101`).
   - Manages origin specs (`source_type`, `source_vendor`, `source_desno`, `source_jobtype`), matching recipes (`options_matching`, `final_matching`), packaging specs (`final_saree_wt`, `pcs_per_set`, `final_bundle_wt`), lifecycle stages, and joined live stock summaries.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `isMaster = true` for `Main` master design only.
   - `lifecycleStage` enum: `millStage`, `inProduction`, `inStock`, `lowStock`, `repeatReq`, `archived`.
   - 1-to-Many Job Card Linkage: Job cards link to `design_code` inside `sb_jobcards` / `sq_CHALTRN`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Live stock numbers are joined dynamically from `sbvw_stock_summary` via `StockSummaryModel`.
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'mdl_stock_ledger.dart';

/// Design Lifecycle Stage Enum
enum DesignStage {
  millStage,
  inProduction,
  inStock,
  lowStock,
  repeatReq,
  archived;

  String get dbValue {
    switch (this) {
      case DesignStage.millStage:
        return 'MILL_STAGE';
      case DesignStage.inProduction:
        return 'IN_PRODUCTION';
      case DesignStage.inStock:
        return 'IN_STOCK';
      case DesignStage.lowStock:
        return 'LOW_STOCK';
      case DesignStage.repeatReq:
        return 'REPEAT_REQ';
      case DesignStage.archived:
        return 'ARCHIVED';
    }
  }

  String get displayName {
    switch (this) {
      case DesignStage.millStage:
        return 'Mill Stage';
      case DesignStage.inProduction:
        return 'In Production';
      case DesignStage.inStock:
        return 'In Stock';
      case DesignStage.lowStock:
        return 'Low Stock';
      case DesignStage.repeatReq:
        return 'Repeat Required';
      case DesignStage.archived:
        return 'Archived';
    }
  }

  static DesignStage fromDbValue(String val) {
    switch (val.toUpperCase().trim()) {
      case 'MILL_STAGE':
        return DesignStage.millStage;
      case 'IN_PRODUCTION':
        return DesignStage.inProduction;
      case 'IN_STOCK':
        return DesignStage.inStock;
      case 'LOW_STOCK':
        return DesignStage.lowStock;
      case 'REPEAT_REQ':
        return DesignStage.repeatReq;
      case 'ARCHIVED':
        return DesignStage.archived;
      default:
        return DesignStage.millStage;
    }
  }
}

/// [MdlDesign] — Primary Domain Model for Design SKU Representation
@immutable
class MdlDesign {
  final String id;
  final String designCode;
  final String itemSrNo;
  final String itemQCode;
  final String designNo;
  final bool isMaster;
  final DesignStage lifecycleStage;
  final String sourceType;
  final String sourceVendor;
  final String sourceDesNo;
  final String sourceJobType;
  final double finalSareeWt;
  final int pcsPerSet;
  final double finalBundleWt;
  final List<Map<String, dynamic>> optionsMatching;
  final List<Map<String, dynamic>> finalMatching;
  final int reorderLevelPcs;
  final List<String> mediaUrls;
  final List<String> pdfPaths;
  final StockSummaryModel? stockSummary;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const MdlDesign({
    required this.id,
    required this.designCode,
    required this.itemSrNo,
    required this.itemQCode,
    required this.designNo,
    required this.isMaster,
    required this.lifecycleStage,
    required this.sourceType,
    required this.sourceVendor,
    required this.sourceDesNo,
    required this.sourceJobType,
    required this.finalSareeWt,
    required this.pcsPerSet,
    required this.finalBundleWt,
    required this.optionsMatching,
    required this.finalMatching,
    required this.reorderLevelPcs,
    required this.mediaUrls,
    required this.pdfPaths,
    this.stockSummary,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Factory `fromJson` handling defensive type parsing safely.
  factory MdlDesign.fromJson(Map<String, dynamic> json, [StockSummaryModel? stockSummary]) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    List<Map<String, dynamic>> parseMatchingList(dynamic val) {
      if (val is List) {
        return val.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }

    List<String> parseStringList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    return MdlDesign(
      id: (json['id'] as String?)?.trim() ?? '',
      designCode: (json['design_code'] as String?)?.trim() ?? '',
      itemSrNo: (json['itemsrno'] as String?)?.trim() ?? '',
      itemQCode: (json['itemqcode'] as String?)?.trim() ?? '',
      designNo: (json['design_no'] as String?)?.trim() ?? 'Main',
      isMaster: json['is_master'] as bool? ?? false,
      lifecycleStage: DesignStage.fromDbValue((json['lifecycle_stage'] as String?) ?? 'MILL_STAGE'),
      sourceType: (json['source_type'] as String?)?.trim() ?? '',
      sourceVendor: (json['source_vendor'] as String?)?.trim() ?? '',
      sourceDesNo: (json['source_desno'] as String?)?.trim() ?? '',
      sourceJobType: (json['source_jobtype'] as String?)?.trim() ?? '',
      finalSareeWt: (json['final_saree_wt'] as num?)?.toDouble() ?? 0.0,
      pcsPerSet: (json['pcs_per_set'] as num?)?.toInt() ?? 6,
      finalBundleWt: (json['final_bundle_wt'] as num?)?.toDouble() ?? 0.0,
      optionsMatching: parseMatchingList(json['options_matching']),
      finalMatching: parseMatchingList(json['final_matching']),
      reorderLevelPcs: (json['reorder_level_pcs'] as num?)?.toInt() ?? 100,
      mediaUrls: parseStringList(json['media_urls']),
      pdfPaths: parseStringList(json['pdf_paths']),
      stockSummary: stockSummary,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      createdBy: (json['created_by'] as String?)?.trim(),
      updatedBy: (json['updated_by'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'design_code': designCode,
        'itemsrno': itemSrNo,
        'itemqcode': itemQCode,
        'design_no': designNo,
        'is_master': isMaster,
        'lifecycle_stage': lifecycleStage.dbValue,
        'source_type': sourceType,
        'source_vendor': sourceVendor,
        'source_desno': sourceDesNo,
        'source_jobtype': sourceJobType,
        'final_saree_wt': finalSareeWt,
        'pcs_per_set': pcsPerSet,
        'final_bundle_wt': finalBundleWt,
        'options_matching': optionsMatching,
        'final_matching': finalMatching,
        'reorder_level_pcs': reorderLevelPcs,
        'media_urls': mediaUrls,
        'pdf_paths': pdfPaths,
      };

  // Stock Helper Getters
  int get currentStock => stockSummary?.currentStock ?? 0;
  int get soOrderable => stockSummary?.soOrderable ?? 0;
  int get flOrderable => stockSummary?.flOrderable ?? 0;
  int get stockAtMill => stockSummary?.stockAtMill ?? 0;
  int get stockAtJob => stockSummary?.stockAtJob ?? 0;
  int get soPending => stockSummary?.soPending ?? 0;
  int get flPending => stockSummary?.flPending ?? 0;
}
