/*
================================================================================
LLM CONTEXT & QUERY SPACE — VENDOR SOURCES & DESIGNS MODELS (mdl_design.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical domain models for the lean 3-Entity Textile Product Architecture:
     * `MdlSource` (`IMMBE2627.sb_sources`): Repository of vendor designs & origin
       metadata captured at Mill Program (`PRINTED`/`DYED`) or Finish Purchase
       (`TOP_DYED`).
     * `MdlDesign` (`IMMBE2627.sb_designs`): Commercial catalog SKU linked strictly
       to `sb_item` via `parent_item` (zero direct links back to `sq_QUAL`),
       tracking carried-forward `active_specs` and customer preference
       `design_attributes`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Source Code Convention: 4-character alpha vendor code + '-' + `source_des_no`
     (e.g., `AAIS-402`, `RAPR-Z19`).
   - Design Code Convention: `<PARENT_ITEM_SHORT>-<des_no>` (e.g., `VIDHI-001`).
   - Completion Scoring Engine (`evaluateCompletion`): Evaluates 4 pillars
     (0-100%) and generates `pending_tasks` automatically when visual media,
     active source, specs, or attributes are missing.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_sources` deliberately omits final specs, COGS breakdowns, and pipeline
     document arrays so repeat batches stay clean on the job card side.
   - `sb_designs` links strictly to `sb_item(id)` (`parent_item`) and
     `sb_sources(id)` (`active_source_id`).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Additional `active_specs` and `design_attributes` keys can evolve inside
     JSONB as we iterate on Cutting, Job Work, and Sales Order UI screens.
================================================================================
*/

library;

import 'package:flutter/foundation.dart';
import '../../dynamic_ai/micro/table/dy_table_models.dart';
import 'mdl_stock_ledger.dart';

/// Three core saree manufacturing pathways
enum SareeType {
  printed,
  dyed,
  topDyed;

  String get dbValue {
    switch (this) {
      case SareeType.printed:
        return 'PRINTED';
      case SareeType.dyed:
        return 'DYED';
      case SareeType.topDyed:
        return 'TOP_DYED';
    }
  }

  String get displayName {
    switch (this) {
      case SareeType.printed:
        return 'Printed Saree';
      case SareeType.dyed:
        return 'Dyed Saree';
      case SareeType.topDyed:
        return 'Top-Dyed Saree';
    }
  }

  static SareeType fromDbValue(String? val) {
    switch ((val ?? '').toUpperCase().trim()) {
      case 'DYED':
        return SareeType.dyed;
      case 'TOP_DYED':
        return SareeType.topDyed;
      case 'PRINTED':
      default:
        return SareeType.printed;
    }
  }
}

/// Two sanctioned entry points for creating a Vendor Source (`sb_sources`)
enum SourceEntryStage {
  millProgram,
  finishPurchase;

  String get dbValue {
    switch (this) {
      case SourceEntryStage.millProgram:
        return 'MILL_PROGRAM';
      case SourceEntryStage.finishPurchase:
        return 'FINISH_PURCHASE';
    }
  }

  String get displayName {
    switch (this) {
      case SourceEntryStage.millProgram:
        return 'Mill Program';
      case SourceEntryStage.finishPurchase:
        return 'Finish Purchase (Top-Dyed)';
    }
  }

  static SourceEntryStage fromDbValue(String? val) {
    switch ((val ?? '').toUpperCase().trim()) {
      case 'FINISH_PURCHASE':
        return SourceEntryStage.finishPurchase;
      case 'MILL_PROGRAM':
      default:
        return SourceEntryStage.millProgram;
    }
  }
}

/// Commercial Design Lifecycle Stages (`sb_designs`)
enum DesignStage {
  millStage,
  cuttingStage,
  jobStage,
  inStock,
  lowStock,
  repeatReq,
  archived;

  String get dbValue {
    switch (this) {
      case DesignStage.millStage:
        return 'MILL_STAGE';
      case DesignStage.cuttingStage:
        return 'CUTTING_STAGE';
      case DesignStage.jobStage:
        return 'JOB_STAGE';
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
      case DesignStage.cuttingStage:
        return 'Cutting Stage';
      case DesignStage.jobStage:
        return 'Job Work Stage';
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

  static DesignStage fromDbValue(String? val) {
    switch ((val ?? '').toUpperCase().trim()) {
      case 'CUTTING_STAGE':
        return DesignStage.cuttingStage;
      case 'JOB_STAGE':
      case 'IN_PRODUCTION':
        return DesignStage.jobStage;
      case 'IN_STOCK':
        return DesignStage.inStock;
      case 'LOW_STOCK':
        return DesignStage.lowStock;
      case 'REPEAT_REQ':
        return DesignStage.repeatReq;
      case 'ARCHIVED':
        return DesignStage.archived;
      case 'MILL_STAGE':
      default:
        return DesignStage.millStage;
    }
  }
}

/// [MdlSource] — Vendor Design Repository Row (`IMMBE2627.sb_sources`).
@immutable
class MdlSource {
  final String? id;
  final String sourceDesNo;
  final String sourceCode;
  final SareeType sareeType;
  final SourceEntryStage entryStage;
  final Map<String, dynamic> originSpecs;
  final List<String> rawMediaIds;
  final String? thumbUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const MdlSource({
    this.id,
    required this.sourceDesNo,
    required this.sourceCode,
    this.sareeType = SareeType.printed,
    this.entryStage = SourceEntryStage.millProgram,
    this.originSpecs = const {},
    this.rawMediaIds = const [],
    this.thumbUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Builds canonical 4-alpha vendor prefix + `source_des_no` (e.g. `AAIS-402`).
  static String formatSourceCode(String vendorInput, String sourceDesNo) {
    final alphaOnly =
        vendorInput.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final String prefix;
    if (alphaOnly.length >= 4) {
      prefix = alphaOnly.substring(0, 4);
    } else if (alphaOnly.isNotEmpty) {
      prefix = alphaOnly.padRight(4, 'X');
    } else {
      prefix = 'VEND';
    }
    final cleanDesNo = sourceDesNo.trim().toUpperCase();
    return cleanDesNo.isEmpty ? prefix : '$prefix-$cleanDesNo';
  }

  String get vendorCode =>
      (originSpecs['vendor_code'] as String?)?.trim() ??
      (sourceCode.contains('-') ? sourceCode.split('-').first : 'VEND');

  String get vendorName =>
      (originSpecs['vendor_name'] as String?)?.trim() ?? '';

  String get baseFabric =>
      (originSpecs['base_fabric'] as String?)?.trim() ?? '';

  double get originRate {
    final raw = originSpecs['mill_rate'] ?? originSpecs['purchase_rate'];
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '0') ?? 0.0;
  }

  List<String> get colorOptions {
    final raw = originSpecs['color_options'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  List<String> get finalColors {
    final raw = originSpecs['final_colors'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  factory MdlSource.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    List<String> parseStringList(dynamic val) {
      if (val is List) {
        return val
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return const [];
    }

    return MdlSource(
      id: (json['id'] as String?)?.trim(),
      sourceDesNo: (json['source_des_no'] as String?)?.trim() ?? '',
      sourceCode: (json['source_code'] as String?)?.trim() ?? '',
      sareeType: SareeType.fromDbValue(json['saree_type'] as String?),
      entryStage: SourceEntryStage.fromDbValue(json['entry_stage'] as String?),
      originSpecs: json['origin_specs'] is Map
          ? Map<String, dynamic>.from(json['origin_specs'] as Map)
          : const {},
      rawMediaIds: parseStringList(json['raw_media_ids']),
      thumbUrl: (json['thumb_url'] as String?)?.trim(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      createdBy: (json['created_by'] as String?)?.trim(),
      updatedBy: (json['updated_by'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toUpsertJson({String? userId}) => {
        if (id != null && id!.isNotEmpty) 'id': id,
        'source_des_no': sourceDesNo.trim().toUpperCase(),
        'source_code': sourceCode.trim().toUpperCase(),
        'saree_type': sareeType.dbValue,
        'entry_stage': entryStage.dbValue,
        'origin_specs': originSpecs,
        'raw_media_ids': rawMediaIds,
        'thumb_url': thumbUrl,
        'updated_at': DateTime.now().toIso8601String(),
        if (userId != null) 'updated_by': userId,
      };

  MdlSource copyWith({
    String? id,
    String? sourceDesNo,
    String? sourceCode,
    SareeType? sareeType,
    SourceEntryStage? entryStage,
    Map<String, dynamic>? originSpecs,
    List<String>? rawMediaIds,
    String? thumbUrl,
  }) {
    return MdlSource(
      id: id ?? this.id,
      sourceDesNo: sourceDesNo ?? this.sourceDesNo,
      sourceCode: sourceCode ?? this.sourceCode,
      sareeType: sareeType ?? this.sareeType,
      entryStage: entryStage ?? this.entryStage,
      originSpecs: originSpecs ?? this.originSpecs,
      rawMediaIds: rawMediaIds ?? this.rawMediaIds,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  DyTableRowData toDyDefRowData() {
    final String rateText =
        originRate > 0 ? '₹${originRate.toStringAsFixed(2)}' : '-';
    final String specsText = baseFabric.isNotEmpty
        ? '$baseFabric${finalColors.isNotEmpty ? " • ${finalColors.length} Col" : ""}'
        : '${finalColors.length} Colours';

    return DyTableRowData(
      id: id ?? sourceCode,
      rowType: DyTableRowType.def,
      voucherNo: sourceCode,
      partyName: vendorName.isNotEmpty ? vendorName : vendorCode,
      designPattern: specsText,
      quantity: entryStage.displayName,
      amount: rateText,
      amountValue: originRate,
      status: sareeType.dbValue,
      data: {
        'vno': sourceCode,
        'partyName': vendorName.isNotEmpty ? vendorName : vendorCode,
        'sareeType': sareeType.displayName,
        'sourceCode': entryStage.displayName,
        'specs': specsText,
        'attrs': colorOptions.isNotEmpty
            ? colorOptions.take(4).join(', ')
            : 'Source #$sourceDesNo',
        'compScore': rawMediaIds.isNotEmpty || thumbUrl != null ? 'PHOTO' : 'RAW',
        'status': 'SOURCE',
      },
      rawData: toUpsertJson(),
    );
  }
}

/// Evaluation outcome of Design Completion & Auto-Task Engine
@immutable
class DesignCompletionEval {
  final int score;
  final List<Map<String, dynamic>> pendingTasks;

  const DesignCompletionEval({
    required this.score,
    required this.pendingTasks,
  });
}

/// [MdlDesign] — Primary Commercial Design SKU Model (`IMMBE2627.sb_designs`).
@immutable
class MdlDesign {
  final String? id;
  final String desCode;
  final String desNo;
  final SareeType sareeType;
  final String parentItemId;
  final bool isMaster;
  final String? activeSourceId;
  final Map<String, dynamic> activeSpecs;
  final Map<String, dynamic> designAttributes;
  final String? thumbUrl;
  final List<String> mediaUrls;
  final List<String> pdfPaths;
  final DesignStage lifecycleStage;
  final int compScore;
  final List<Map<String, dynamic>> pendingTasks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  // Joined relational display fields (read-only)
  final String? parentItemCode;
  final String? parentItemName;
  final double parentSellPrice;
  final String? activeSourceCode;
  final String? activeSourceVendor;
  final String? activeBaseFabric;
  final StockSummaryModel? stockSummary;

  const MdlDesign({
    this.id,
    required this.desCode,
    required this.desNo,
    this.sareeType = SareeType.printed,
    required this.parentItemId,
    this.isMaster = false,
    this.activeSourceId,
    this.activeSpecs = const {},
    this.designAttributes = const {},
    this.thumbUrl,
    this.mediaUrls = const [],
    this.pdfPaths = const [],
    this.lifecycleStage = DesignStage.millStage,
    this.compScore = 0,
    this.pendingTasks = const [],
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.parentItemCode,
    this.parentItemName,
    this.parentSellPrice = 0.0,
    this.activeSourceCode,
    this.activeSourceVendor,
    this.activeBaseFabric,
    this.stockSummary,
  });

  /// Formats canonical commercial `des_code` from parent item & design number.
  static String formatDesCode(String parentItemCodeOrName, String desNo) {
    final cleanItem = parentItemCodeOrName
        .replaceFirst(RegExp(r'^SAR-'), '')
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '-');
    final cleanNo = desNo.trim().toUpperCase();
    return cleanNo.isEmpty ? '$cleanItem-001' : '$cleanItem-$cleanNo';
  }

  double get finalCut => (activeSpecs['final_cut'] as num?)?.toDouble() ?? 0.0;
  double get finalWeight =>
      (activeSpecs['final_weight'] as num?)?.toDouble() ?? 0.0;
  int get pcsPerSet => (activeSpecs['pcs_per_set'] as num?)?.toInt() ?? 6;
  double get finalBundleWeight =>
      (activeSpecs['final_bundle_weight'] as num?)?.toDouble() ?? 0.0;

  List<String> get finalColors {
    final raw = activeSpecs['final_colors'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String get printFamily =>
      (designAttributes['print_family'] as String?)?.trim() ?? '';
  String get borderStyle =>
      (designAttributes['border_style'] as String?)?.trim() ?? '';
  String get occasion =>
      (designAttributes['occasion'] as String?)?.trim() ?? '';

  /// Evaluates 4-pillar readiness score (0-100%) & generates missing tasks.
  DesignCompletionEval evaluateCompletion() {
    int pts = 0;
    final tasks = <Map<String, dynamic>>[];

    // 1. Commercial Identity & Parent sb_item (25 pts)
    if (desCode.trim().isNotEmpty && parentItemId.trim().isNotEmpty) {
      pts += 25;
    } else {
      tasks.add({
        'role': 'MERCHANDISER',
        'title': 'Assign parent sb_item & finalize des_code',
      });
    }

    // 2. Active Source Linkage (25 pts)
    if (activeSourceId != null && activeSourceId!.isNotEmpty) {
      pts += 25;
    } else {
      tasks.add({
        'role': 'PRODUCTION',
        'title': 'Link Vendor Source (Mill / Top-Dyed PO) to $desCode',
      });
    }

    // 3. Final Batch Specs snapshot (25 pts)
    if (finalWeight > 0 && finalCut > 0) {
      pts += 15;
    } else {
      tasks.add({
        'role': 'CUTTING_TEAM',
        'title': 'Verify final cut & saree weight for $desCode',
      });
    }
    if (finalColors.isNotEmpty) {
      pts += 10;
    } else {
      tasks.add({
        'role': 'JOB_TEAM',
        'title': 'Confirm final colour palette for $desCode',
      });
    }

    // 4. Visual Media & Customer Attributes (25 pts)
    if ((thumbUrl != null && thumbUrl!.isNotEmpty) || mediaUrls.isNotEmpty) {
      pts += 15;
    } else {
      tasks.add({
        'role': 'MOBILE_CUTTING',
        'title': 'Upload primary swatch/studio photo for $desCode',
      });
    }
    if (printFamily.isNotEmpty || occasion.isNotEmpty) {
      pts += 10;
    } else {
      tasks.add({
        'role': 'MERCHANDISER',
        'title': 'Tag print family & customer attributes for $desCode',
      });
    }

    return DesignCompletionEval(
      score: pts.clamp(0, 100),
      pendingTasks: tasks,
    );
  }

  factory MdlDesign.fromJson(
    Map<String, dynamic> json, {
    StockSummaryModel? stockSummary,
  }) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    List<String> parseStringList(dynamic val) {
      if (val is List) {
        return val
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return const [];
    }

    List<Map<String, dynamic>> parseMapList(dynamic val) {
      if (val is List) {
        return val
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return const [];
    }

    final itemMap =
        json['sb_item'] is Map ? Map<String, dynamic>.from(json['sb_item'] as Map) : null;
    final srcMap = json['sb_sources'] is Map
        ? Map<String, dynamic>.from(json['sb_sources'] as Map)
        : null;
    final srcOrigin = srcMap != null && srcMap['origin_specs'] is Map
        ? Map<String, dynamic>.from(srcMap['origin_specs'] as Map)
        : null;

    return MdlDesign(
      id: (json['id'] as String?)?.trim(),
      desCode: (json['des_code'] as String?)?.trim() ?? '',
      desNo: (json['des_no'] as String?)?.trim() ?? '001',
      sareeType: SareeType.fromDbValue(json['saree_type'] as String?),
      parentItemId: (json['parent_item'] as String?)?.trim() ?? '',
      isMaster: json['is_master'] as bool? ?? false,
      activeSourceId: (json['active_source_id'] as String?)?.trim(),
      activeSpecs: json['active_specs'] is Map
          ? Map<String, dynamic>.from(json['active_specs'] as Map)
          : const {},
      designAttributes: json['design_attributes'] is Map
          ? Map<String, dynamic>.from(json['design_attributes'] as Map)
          : const {},
      thumbUrl: (json['thumb_url'] as String?)?.trim(),
      mediaUrls: parseStringList(json['media_urls']),
      pdfPaths: parseStringList(json['pdf_paths']),
      lifecycleStage: DesignStage.fromDbValue(json['lifecycle_stage'] as String?),
      compScore: (json['comp_score'] as num?)?.toInt() ?? 0,
      pendingTasks: parseMapList(json['pending_tasks']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      createdBy: (json['created_by'] as String?)?.trim(),
      updatedBy: (json['updated_by'] as String?)?.trim(),
      parentItemCode: (itemMap?['item_code'] as String?)?.trim(),
      parentItemName: (itemMap?['name'] as String?)?.trim(),
      parentSellPrice: (itemMap?['sell_price_1'] as num?)?.toDouble() ?? 0.0,
      activeSourceCode: (srcMap?['source_code'] as String?)?.trim(),
      activeSourceVendor: (srcOrigin?['vendor_name'] as String?)?.trim(),
      activeBaseFabric: (srcOrigin?['base_fabric'] as String?)?.trim(),
      stockSummary: stockSummary,
    );
  }

  Map<String, dynamic> toUpsertJson({String? userId}) {
    final eval = evaluateCompletion();
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'des_code': desCode.trim().toUpperCase(),
      'des_no': desNo.trim().toUpperCase(),
      'saree_type': sareeType.dbValue,
      'parent_item': parentItemId,
      'is_master': isMaster,
      'active_source_id': activeSourceId,
      'active_specs': activeSpecs,
      'design_attributes': designAttributes,
      'thumb_url': thumbUrl,
      'media_urls': mediaUrls,
      'pdf_paths': pdfPaths,
      'lifecycle_stage': lifecycleStage.dbValue,
      'comp_score': eval.score,
      'pending_tasks': eval.pendingTasks,
      'updated_at': DateTime.now().toIso8601String(),
      if (userId != null) 'updated_by': userId,
    };
  }

  MdlDesign copyWith({
    String? id,
    String? desCode,
    String? desNo,
    SareeType? sareeType,
    String? parentItemId,
    bool? isMaster,
    String? activeSourceId,
    Map<String, dynamic>? activeSpecs,
    Map<String, dynamic>? designAttributes,
    String? thumbUrl,
    List<String>? mediaUrls,
    List<String>? pdfPaths,
    DesignStage? lifecycleStage,
    int? compScore,
    List<Map<String, dynamic>>? pendingTasks,
  }) {
    return MdlDesign(
      id: id ?? this.id,
      desCode: desCode ?? this.desCode,
      desNo: desNo ?? this.desNo,
      sareeType: sareeType ?? this.sareeType,
      parentItemId: parentItemId ?? this.parentItemId,
      isMaster: isMaster ?? this.isMaster,
      activeSourceId: activeSourceId ?? this.activeSourceId,
      activeSpecs: activeSpecs ?? this.activeSpecs,
      designAttributes: designAttributes ?? this.designAttributes,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      pdfPaths: pdfPaths ?? this.pdfPaths,
      lifecycleStage: lifecycleStage ?? this.lifecycleStage,
      compScore: compScore ?? this.compScore,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
      parentItemCode: parentItemCode,
      parentItemName: parentItemName,
      parentSellPrice: parentSellPrice,
      activeSourceCode: activeSourceCode,
      activeSourceVendor: activeSourceVendor,
      activeBaseFabric: activeBaseFabric,
      stockSummary: stockSummary,
    );
  }

  int get currentStock => stockSummary?.currentStock ?? 0;

  DyTableRowData toDyDefRowData() {
    final String itemLabel = parentItemName?.isNotEmpty == true
        ? '$parentItemName (${parentItemCode ?? ""})'
        : (parentItemCode ?? 'ITEM');
    final String specsSummary = [
      if (finalCut > 0) '${finalCut.toStringAsFixed(2)}m',
      if (finalWeight > 0) '${finalWeight.toStringAsFixed(0)}g',
      if (finalColors.isNotEmpty) '${finalColors.length} Col',
    ].join(' • ');
    final String attrsSummary = [
      if (printFamily.isNotEmpty) printFamily,
      if (occasion.isNotEmpty) occasion,
    ].join(' • ');

    return DyTableRowData(
      id: id ?? desCode,
      rowType: DyTableRowType.def,
      voucherNo: desCode,
      partyName: itemLabel,
      designPattern: activeSourceCode ?? '-',
      quantity: specsSummary.isNotEmpty ? specsSummary : '$pcsPerSet Pcs Set',
      amount: parentSellPrice > 0
          ? '₹${parentSellPrice.toStringAsFixed(0)}'
          : '-',
      amountValue: parentSellPrice,
      status: lifecycleStage.displayName,
      data: {
        'vno': desCode,
        'partyName': itemLabel,
        'sareeType': sareeType.displayName,
        'sourceCode': activeSourceCode ?? 'UNLINKED',
        'specs': specsSummary.isNotEmpty ? specsSummary : '$pcsPerSet Pcs Set',
        'attrs': attrsSummary.isNotEmpty ? attrsSummary : '-',
        'compScore': '$compScore%',
        'status': lifecycleStage.displayName,
      },
      rawData: toUpsertJson(),
    );
  }
}
