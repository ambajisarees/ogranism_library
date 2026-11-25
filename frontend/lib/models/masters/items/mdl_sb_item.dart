/*
================================================================================
LLM CONTEXT & QUERY SPACE — MODERN ITEM MASTER MODELS (mdl_sb_item.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Defines strongly-typed immutable models for the next-generation Multi-Vertical
     Item Master (`IMMBE2627.sb_item`), Admin Barrel Blueprint Config
     (`IMMBE2627.sb_item_group_config`), and Audit Log (`IMMBE2627.sb_item_audit_log`).
   - Powers both the "Clean-As-You-Go" Add/Upgrade workflow on the Items Landing
     Screen (`scr_itm_landing.dart`) and the Admin Item Schema Config screen.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `SbItemGroupConfig`: Admin-governed barrel definition holding default
     transaction capability switches (`canBePurchased`, `isInternal`, `canBeSold`,
     `isStockTracked`), `allowedSeries`, `allowedUoms`, `specSchema`, and
     `variationSchema`.
   - `SbItemVariation`: Option-B JSONB variation structure stored inside
     `sb_item.variations` for size/ply/micron/pattern variants (e.g. Carton
     `35.25*15*30 7 PLY` or Chainbag `14*18 50 Microns`).
   - `SbCompBreakdown`: Live 0-100% Completion Ratio calculator evaluating
     Identity (25 pts), GST Compliance (25 pts), Costing/Pricing (25 pts), and
     Admin-defined Domain Specs & Reorder rules (25 pts), plus legacy delta.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `base_fabric` was intentionally omitted at the item level (determined at
     design level in `sb_designs`).
   - `cess_rate` was intentionally omitted per business rule.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Dynamic roll-up metrics (such as `avg_weight` across child designs/variations)
     are computed via aggregation views as designs are linked.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../core/sq/sq_qual.dart';

/// [SbSpecFieldDef] — Schema definition for a single dynamic field inside
/// `sb_item_group_config.spec_schema` or `variation_schema`.
@immutable
class SbSpecFieldDef {
  final String key;
  final String label;
  final String type; // 'text', 'number', 'select', 'boolean'
  final List<String> options;
  final dynamic defaultValue;
  final bool required;
  final int scorePts;

  const SbSpecFieldDef({
    required this.key,
    required this.label,
    this.type = 'text',
    this.options = const [],
    this.defaultValue,
    this.required = false,
    this.scorePts = 5,
  });

  factory SbSpecFieldDef.fromJson(Map<String, dynamic> json) {
    final rawOpts = json['options'];
    final List<String> parsedOpts = rawOpts is List
        ? rawOpts.map((e) => e.toString()).toList()
        : const [];

    return SbSpecFieldDef(
      key: (json['key'] ?? '').toString().trim(),
      label: (json['label'] ?? json['key'] ?? '').toString().trim(),
      type: (json['type'] ?? 'text').toString().trim(),
      options: parsedOpts,
      defaultValue: json['default'],
      required: json['required'] == true,
      scorePts: (json['score_pts'] is num)
          ? (json['score_pts'] as num).toInt()
          : 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      if (options.isNotEmpty) 'options': options,
      if (defaultValue != null) 'default': defaultValue,
      'required': required,
      'score_pts': scorePts,
    };
  }

  SbSpecFieldDef copyWith({
    String? key,
    String? label,
    String? type,
    List<String>? options,
    dynamic defaultValue,
    bool? required,
    int? scorePts,
  }) {
    return SbSpecFieldDef(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      options: options ?? this.options,
      defaultValue: defaultValue ?? this.defaultValue,
      required: required ?? this.required,
      scorePts: scorePts ?? this.scorePts,
    );
  }
}

/// [SbItemGroupConfig] — Admin-managed Barrel / Item Group Blueprint from
/// `IMMBE2627.sb_item_group_config`.
@immutable
class SbItemGroupConfig {
  final String groupCode;
  final String displayName;
  final String description;
  final String iconName;
  final String defaultNature; // 'GOODS', 'SERVICE', 'CONSUMABLE'
  final bool canBePurchased;
  final bool isInternal;
  final bool canBeSold;
  final bool isStockTracked;
  final List<String> allowedSeries;
  final List<String> allowedUoms;
  final String defaultHsn;
  final double defaultGstRate;
  final bool supportsDesigns;
  final bool supportsVariations;
  final List<SbSpecFieldDef> specSchema;
  final List<SbSpecFieldDef> variationSchema;
  final int sortOrder;
  final bool isActive;

  const SbItemGroupConfig({
    required this.groupCode,
    required this.displayName,
    this.description = '',
    this.iconName = 'package',
    this.defaultNature = 'GOODS',
    this.canBePurchased = true,
    this.isInternal = false,
    this.canBeSold = false,
    this.isStockTracked = true,
    this.allowedSeries = const [],
    this.allowedUoms = const ['PCS', 'MTS', 'KG'],
    this.defaultHsn = '',
    this.defaultGstRate = 5.0,
    this.supportsDesigns = false,
    this.supportsVariations = true,
    this.specSchema = const [],
    this.variationSchema = const [],
    this.sortOrder = 100,
    this.isActive = true,
  });

  factory SbItemGroupConfig.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    List<SbSpecFieldDef> parseSpecList(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(SbSpecFieldDef.fromJson)
            .toList();
      }
      return const [];
    }

    return SbItemGroupConfig(
      groupCode: (json['group_code'] ?? '').toString().trim(),
      displayName: (json['display_name'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      iconName: (json['icon_name'] ?? 'package').toString().trim(),
      defaultNature: (json['default_nature'] ?? 'GOODS').toString().trim(),
      canBePurchased: json['can_be_purchased'] != false,
      isInternal: json['is_internal'] == true,
      canBeSold: json['can_be_sold'] == true,
      isStockTracked: json['is_stock_tracked'] != false,
      allowedSeries: parseStringList(json['allowed_series']),
      allowedUoms: parseStringList(json['allowed_uoms']),
      defaultHsn: (json['default_hsn'] ?? '').toString().trim(),
      defaultGstRate: (json['default_gst_rate'] is num)
          ? (json['default_gst_rate'] as num).toDouble()
          : double.tryParse(json['default_gst_rate']?.toString() ?? '5') ?? 5.0,
      supportsDesigns: json['supports_designs'] == true,
      supportsVariations: json['supports_variations'] != false,
      specSchema: parseSpecList(json['spec_schema']),
      variationSchema: parseSpecList(json['variation_schema']),
      sortOrder: (json['sort_order'] is num)
          ? (json['sort_order'] as num).toInt()
          : 100,
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_code': groupCode,
      'display_name': displayName,
      'description': description,
      'icon_name': iconName,
      'default_nature': defaultNature,
      'can_be_purchased': canBePurchased,
      'is_internal': isInternal,
      'can_be_sold': canBeSold,
      'is_stock_tracked': isStockTracked,
      'allowed_series': allowedSeries,
      'allowed_uoms': allowedUoms,
      'default_hsn': defaultHsn,
      'default_gst_rate': defaultGstRate,
      'supports_designs': supportsDesigns,
      'supports_variations': supportsVariations,
      'spec_schema': specSchema.map((e) => e.toJson()).toList(),
      'variation_schema': variationSchema.map((e) => e.toJson()).toList(),
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  IconData get icon {
    switch (iconName) {
      case 'shirt':
        return shad.LucideIcons.shirt;
      case 'scissors':
        return shad.LucideIcons.scissors;
      case 'layers':
        return shad.LucideIcons.layers;
      case 'box':
        return shad.LucideIcons.box;
      case 'sparkles':
        return shad.LucideIcons.sparkles;
      case 'wrench':
        return shad.LucideIcons.wrench;
      case 'building':
        return shad.LucideIcons.building;
      default:
        return shad.LucideIcons.package;
    }
  }

  SbItemGroupConfig copyWith({
    String? groupCode,
    String? displayName,
    String? description,
    String? iconName,
    String? defaultNature,
    bool? canBePurchased,
    bool? isInternal,
    bool? canBeSold,
    bool? isStockTracked,
    List<String>? allowedSeries,
    List<String>? allowedUoms,
    String? defaultHsn,
    double? defaultGstRate,
    bool? supportsDesigns,
    bool? supportsVariations,
    List<SbSpecFieldDef>? specSchema,
    List<SbSpecFieldDef>? variationSchema,
    int? sortOrder,
    bool? isActive,
  }) {
    return SbItemGroupConfig(
      groupCode: groupCode ?? this.groupCode,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      defaultNature: defaultNature ?? this.defaultNature,
      canBePurchased: canBePurchased ?? this.canBePurchased,
      isInternal: isInternal ?? this.isInternal,
      canBeSold: canBeSold ?? this.canBeSold,
      isStockTracked: isStockTracked ?? this.isStockTracked,
      allowedSeries: allowedSeries ?? this.allowedSeries,
      allowedUoms: allowedUoms ?? this.allowedUoms,
      defaultHsn: defaultHsn ?? this.defaultHsn,
      defaultGstRate: defaultGstRate ?? this.defaultGstRate,
      supportsDesigns: supportsDesigns ?? this.supportsDesigns,
      supportsVariations: supportsVariations ?? this.supportsVariations,
      specSchema: specSchema ?? this.specSchema,
      variationSchema: variationSchema ?? this.variationSchema,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// [SbItemVariation] — Option-B JSONB variation entry stored inside `sb_item.variations`.
/// Represents size/ply/micron/work variants (e.g. `35.25*15*30 7 PLY` under `CARTOON`).
@immutable
class SbItemVariation {
  final String code;
  final String name;
  final Map<String, dynamic> specs;
  final double costPrice;
  final double lastPurRate;
  final double sellPrice1;
  final int reorderLevel;
  final bool isActive;

  const SbItemVariation({
    required this.code,
    required this.name,
    this.specs = const {},
    this.costPrice = 0.0,
    this.lastPurRate = 0.0,
    this.sellPrice1 = 0.0,
    this.reorderLevel = 0,
    this.isActive = true,
  });

  factory SbItemVariation.fromJson(Map<String, dynamic> json) {
    final rawSpecs = json['specs'];
    final Map<String, dynamic> parsedSpecs = rawSpecs is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawSpecs)
        : const {};

    double toDbl(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    return SbItemVariation(
      code: (json['code'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      specs: parsedSpecs,
      costPrice: toDbl(json['cost_price']),
      lastPurRate: toDbl(json['last_pur_rate']),
      sellPrice1: toDbl(json['sell_price_1']),
      reorderLevel: (json['reorder_level'] is num)
          ? (json['reorder_level'] as num).toInt()
          : int.tryParse(json['reorder_level']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'specs': specs,
      'cost_price': costPrice,
      'last_pur_rate': lastPurRate,
      'sell_price_1': sellPrice1,
      'reorder_level': reorderLevel,
      'is_active': isActive,
    };
  }

  SbItemVariation copyWith({
    String? code,
    String? name,
    Map<String, dynamic>? specs,
    double? costPrice,
    double? lastPurRate,
    double? sellPrice1,
    int? reorderLevel,
    bool? isActive,
  }) {
    return SbItemVariation(
      code: code ?? this.code,
      name: name ?? this.name,
      specs: specs ?? this.specs,
      costPrice: costPrice ?? this.costPrice,
      lastPurRate: lastPurRate ?? this.lastPurRate,
      sellPrice1: sellPrice1 ?? this.sellPrice1,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// [SbPrefVendor] — Preferred supplier entry stored inside `sb_item.pref_vendor` JSONB.
@immutable
class SbPrefVendor {
  final String code;
  final String name;
  final bool isPrimary;

  const SbPrefVendor({
    required this.code,
    required this.name,
    this.isPrimary = true,
  });

  factory SbPrefVendor.fromJson(Map<String, dynamic> json) {
    return SbPrefVendor(
      code: (json['code'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      isPrimary: json['is_primary'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'is_primary': isPrimary,
    };
  }
}

/// [SbCompCheckItem] — Individual completion check item for the live feedback UI.
@immutable
class SbCompCheckItem {
  final String pillar; // 'Identity', 'Compliance', 'Costing', 'Specs & Warehouse'
  final String label;
  final bool isComplete;
  final int earnedPoints;
  final int maxPoints;
  final String hint;

  const SbCompCheckItem({
    required this.pillar,
    required this.label,
    required this.isComplete,
    required this.earnedPoints,
    required this.maxPoints,
    required this.hint,
  });
}

/// [SbCompBreakdown] — Full live Completion Ratio (`comp_score` 0-100%) result,
/// including comparison against the chosen legacy `sq_QUAL` item.
@immutable
class SbCompBreakdown {
  final int totalScore; // 0 to 100
  final int legacyBaselineScore; // 0 to 100
  final int identityScore; // max 25
  final int complianceScore; // max 25
  final int costingScore; // max 25
  final int specsScore; // max 25
  final List<SbCompCheckItem> checks;

  const SbCompBreakdown({
    required this.totalScore,
    required this.legacyBaselineScore,
    required this.identityScore,
    required this.complianceScore,
    required this.costingScore,
    required this.specsScore,
    required this.checks,
  });

  int get improvementDelta => (totalScore - legacyBaselineScore).clamp(0, 100);
  bool get isGoldStandard => totalScore >= 80;
  bool get isFunctional => totalScore >= 50;

  String get tierLabel {
    if (totalScore >= 85) return 'ERP GOLD STANDARD';
    if (totalScore >= 70) return 'BILLING READY';
    if (totalScore >= 50) return 'PARTIAL / FUNCTIONAL';
    return 'INCOMPLETE DRAFT';
  }
}

/// [MdlSbItem] — Canonical Domain Model for `IMMBE2627.sb_item`.
@immutable
class MdlSbItem {
  final String? id;
  final String itemCode;
  final String name;
  final String description;
  final String status;

  // Links to sq_QUAL
  final String? legacyQcode;
  final String? legacyItemsrno;

  // Barrels
  final String itemGroup;
  final String itemNature;
  final List<String> allowedSeries;

  // Transactions
  final bool canBePurchased;
  final bool isInternal;
  final bool canBeSold;
  final bool isStockTracked;

  // Compliance
  final String hsnCode;
  final bool isHsnLocked;
  final double gstRate;
  final bool isReverseCharge;

  // UOM & Specs
  final String primaryUom;
  final String? secondaryUom;
  final Map<String, dynamic> domainSpecs;

  // Variations (Option B)
  final List<SbItemVariation> variations;

  // Costing
  final double costPrice;
  final double lastPurRate;
  final double sellPrice1;
  final double sellPrice2;
  final double sellPrice3;

  // Warehouse
  final List<SbPrefVendor> prefVendor;
  final int reorderLevel;

  // Design Linkage
  final bool hasChildDesigns;
  final String? defDesignId;

  // Auditing
  final int compScore;
  final int version;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MdlSbItem({
    this.id,
    required this.itemCode,
    required this.name,
    this.description = '',
    this.status = 'ACTIVE',
    this.legacyQcode,
    this.legacyItemsrno,
    required this.itemGroup,
    this.itemNature = 'GOODS',
    this.allowedSeries = const [],
    this.canBePurchased = true,
    this.isInternal = false,
    this.canBeSold = false,
    this.isStockTracked = true,
    this.hsnCode = '',
    this.isHsnLocked = true,
    this.gstRate = 5.0,
    this.isReverseCharge = false,
    this.primaryUom = 'PCS',
    this.secondaryUom,
    this.domainSpecs = const {},
    this.variations = const [],
    this.costPrice = 0.0,
    this.lastPurRate = 0.0,
    this.sellPrice1 = 0.0,
    this.sellPrice2 = 0.0,
    this.sellPrice3 = 0.0,
    this.prefVendor = const [],
    this.reorderLevel = 0,
    this.hasChildDesigns = false,
    this.defDesignId,
    this.compScore = 0,
    this.version = 1,
    this.createdAt,
    this.updatedAt,
  });

  /// Smart auto-detection factory from a legacy `SqQualModel` row.
  factory MdlSbItem.fromLegacyQual(
    SqQualModel legacy, {
    SbItemGroupConfig? groupConfig,
    List<SbItemVariation> discoveredVariations = const [],
    double? historicalPurRate,
  }) {
    // 1. Infer smart item_group from legacy attributes
    final String upperName = legacy.name.toUpperCase();
    final String upperCloth = legacy.clothType.toUpperCase();
    final String upperCat = legacy.category.toUpperCase();

    String detectedGroup = groupConfig?.groupCode ?? '';
    if (detectedGroup.isEmpty) {
      if (legacy.isBaseQual == 'Y' || legacy.isBaseQual == 'G') {
        detectedGroup = 'GREY_FABRIC';
      } else if (upperName.contains('(FINISH)') ||
          upperName.contains('(FINAL)') ||
          upperName.contains('(RAW)')) {
        detectedGroup = 'SEMI_FINISHED_WIP';
      } else if (upperCat == 'PACKING' ||
          upperName.contains('CHAIN BAG') ||
          upperName.contains('CARTOON') ||
          upperName.contains('FOAM') ||
          upperName.contains('POUCH') ||
          upperName.contains('PLASTIC') ||
          upperName.contains('STICKER') ||
          upperName.contains('TAG') ||
          upperName.contains('CLIP') ||
          upperName.contains('RIBB')) {
        detectedGroup = 'PACKING_MATERIAL';
      } else if (upperName.contains('LACE') || upperName == 'BLOUSE') {
        detectedGroup = 'ACCESSORY_LACE';
      } else if (upperName.contains('PHOTO') ||
          upperName.contains('POSTER') ||
          upperName.contains('MODELLING') ||
          upperName.contains('VIDEO')) {
        detectedGroup = 'JOBWORK_SERVICE';
      } else if (upperCloth == 'SAREE' ||
          upperCloth == 'FINAL' ||
          upperCloth == 'DRESS') {
        if (legacy.sell1 > 0) {
          detectedGroup = 'FINISHED_SAREE';
        } else {
          detectedGroup = 'OVERHEAD_EXPENSE';
        }
      } else {
        detectedGroup = 'OVERHEAD_EXPENSE';
      }
    }

    // 2. Build initial domain_specs from legacy fields
    final Map<String, dynamic> specs = {};
    if (detectedGroup == 'FINISHED_SAREE') {
      specs['cloth_family'] = 'GEORGETTE';
      if (legacy.cut > 0) specs['cut_mtr'] = legacy.cut;
      if (legacy.pcsPerSet > 0) specs['pcs_per_set'] = legacy.pcsPerSet;
      if (legacy.packing.isNotEmpty) specs['default_packing'] = legacy.packing;
    } else if (detectedGroup == 'SEMI_FINISHED_WIP') {
      specs['process_stage'] = 'STITCHING';
      if (legacy.cut > 0) specs['target_cut_mtr'] = legacy.cut;
      specs['allow_loss_deduction'] = true;
    } else if (detectedGroup == 'GREY_FABRIC') {
      specs['weave_type'] =
          upperName.contains('PLAIN') ? 'PLAIN' : 'PATTA / PATTERN';
      specs['panna_inch'] = 44;
      specs['std_takhta_mtr'] = 120;
      specs['shrinkage_pct'] =
          legacy.expectShortage > 0 ? legacy.expectShortage : 4.0;
    } else if (detectedGroup == 'PACKING_MATERIAL') {
      if (upperName.contains('CARTOON') || upperName.contains('BOX')) {
        specs['sub_category'] = 'CARTOON';
      } else if (upperName.contains('FOAM')) {
        specs['sub_category'] = 'FOAM';
      } else if (upperName.contains('CHAIN')) {
        specs['sub_category'] = 'CHAINBAG';
      } else {
        specs['sub_category'] = 'BOPP_PLASTIC';
      }
    } else if (detectedGroup == 'ACCESSORY_LACE') {
      specs['accessory_type'] =
          upperName.contains('BLOUSE') ? 'BLOUSE_FABRIC' : 'LACE_BORDER';
      specs['roll_cut_mtr'] = legacy.cut > 0 ? legacy.cut : 9.0;
    } else if (detectedGroup == 'JOBWORK_SERVICE') {
      specs['service_domain'] = 'MODELLING_PHOTO';
      specs['billing_basis'] = 'PER_PC';
    } else {
      specs['expense_head'] = 'STATIONERY';
    }

    final double inferredCost = legacy.pur1 > 0
        ? legacy.pur1
        : (historicalPurRate != null && historicalPurRate > 0
            ? historicalPurRate
            : 0.0);

    final String legacyExtraRmk =
        (legacy.rawJson['EXTRARMK'] as String?)?.trim() ?? '';
    final String legacySupplier =
        (legacy.rawJson['SUPPLIER'] as String?)?.trim() ?? '';

    return MdlSbItem(
      itemCode: legacy.qcode.trim(),
      name: legacy.name.trim(),
      description: legacyExtraRmk,
      status: 'ACTIVE',
      legacyQcode: legacy.qcode.trim(),
      legacyItemsrno: legacy.itemSrNo.trim(),
      itemGroup: detectedGroup,
      itemNature: groupConfig?.defaultNature ??
          (detectedGroup == 'JOBWORK_SERVICE'
              ? 'SERVICE'
              : (detectedGroup == 'PACKING_MATERIAL' ||
                      detectedGroup == 'OVERHEAD_EXPENSE'
                  ? 'CONSUMABLE'
                  : 'GOODS')),
      allowedSeries: groupConfig?.allowedSeries ?? const [],
      canBePurchased: groupConfig?.canBePurchased ??
          (detectedGroup != 'FINISHED_SAREE' &&
              detectedGroup != 'SEMI_FINISHED_WIP'),
      isInternal: groupConfig?.isInternal ??
          (detectedGroup == 'SEMI_FINISHED_WIP' ||
              detectedGroup == 'GREY_FABRIC'),
      canBeSold: groupConfig?.canBeSold ?? (detectedGroup == 'FINISHED_SAREE'),
      isStockTracked: groupConfig?.isStockTracked ??
          (detectedGroup != 'JOBWORK_SERVICE' &&
              detectedGroup != 'OVERHEAD_EXPENSE'),
      hsnCode: (legacy.hsnCode.isNotEmpty && legacy.hsnCode != '-')
          ? legacy.hsnCode.trim()
          : (groupConfig?.defaultHsn ?? ''),
      isHsnLocked: true,
      gstRate: legacy.gstRate > 0
          ? legacy.gstRate
          : (groupConfig?.defaultGstRate ?? 5.0),
      isReverseCharge: false,
      primaryUom: legacy.unit.isNotEmpty ? legacy.unit.trim() : 'PCS',
      secondaryUom:
          (detectedGroup == 'FINISHED_SAREE' || detectedGroup == 'GREY_FABRIC')
              ? (legacy.unit == 'PCS' ? 'MTS' : 'PCS')
              : null,
      domainSpecs: specs,
      variations: discoveredVariations,
      costPrice: inferredCost,
      lastPurRate: historicalPurRate ?? inferredCost,
      sellPrice1: legacy.sell1,
      sellPrice2: legacy.sell2,
      sellPrice3: legacy.sell3,
      prefVendor: legacySupplier.isNotEmpty
          ? [SbPrefVendor(code: legacySupplier, name: legacySupplier)]
          : const [],
      reorderLevel: 0,
      hasChildDesigns: detectedGroup == 'FINISHED_SAREE',
    );
  }

  factory MdlSbItem.fromJson(Map<String, dynamic> json) {
    double toDbl(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    List<String> toStrList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    final rawSpecs = json['domain_specs'];
    final Map<String, dynamic> parsedSpecs = rawSpecs is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawSpecs)
        : const {};

    final rawVars = json['variations'];
    final List<SbItemVariation> parsedVars = rawVars is List
        ? rawVars
            .whereType<Map<String, dynamic>>()
            .map(SbItemVariation.fromJson)
            .toList()
        : const [];

    final rawVendors = json['pref_vendor'];
    final List<SbPrefVendor> parsedVendors = rawVendors is List
        ? rawVendors
            .whereType<Map<String, dynamic>>()
            .map(SbPrefVendor.fromJson)
            .toList()
        : const [];

    return MdlSbItem(
      id: json['id']?.toString(),
      itemCode: (json['item_code'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      status: (json['status'] ?? 'ACTIVE').toString().trim(),
      legacyQcode: json['legacy_qcode']?.toString().trim(),
      legacyItemsrno: json['legacy_itemsrno']?.toString().trim(),
      itemGroup: (json['item_group'] ?? 'FINISHED_SAREE').toString().trim(),
      itemNature: (json['item_nature'] ?? 'GOODS').toString().trim(),
      allowedSeries: toStrList(json['allowed_series']),
      canBePurchased: json['can_be_purchased'] != false,
      isInternal: json['is_internal'] == true,
      canBeSold: json['can_be_sold'] == true,
      isStockTracked: json['is_stock_tracked'] != false,
      hsnCode: (json['hsn_code'] ?? '').toString().trim(),
      isHsnLocked: json['is_hsn_locked'] != false,
      gstRate: toDbl(json['gst_rate']),
      isReverseCharge: json['is_reverse_charge'] == true,
      primaryUom: (json['primary_uom'] ?? 'PCS').toString().trim(),
      secondaryUom: json['secondary_uom']?.toString().trim(),
      domainSpecs: parsedSpecs,
      variations: parsedVars,
      costPrice: toDbl(json['cost_price']),
      lastPurRate: toDbl(json['last_pur_rate']),
      sellPrice1: toDbl(json['sell_price_1']),
      sellPrice2: toDbl(json['sell_price_2']),
      sellPrice3: toDbl(json['sell_price_3']),
      prefVendor: parsedVendors,
      reorderLevel: toInt(json['reorder_level']),
      hasChildDesigns: json['has_child_designs'] == true,
      defDesignId: json['def_design_id']?.toString(),
      compScore: toInt(json['comp_score']),
      version: toInt(json['version'] ?? 1),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({int? overrideCompScore}) {
    return {
      if (id != null) 'id': id,
      'item_code': itemCode,
      'name': name,
      'description': description.isEmpty ? null : description,
      'status': status,
      'legacy_qcode': (legacyQcode != null && legacyQcode!.isNotEmpty)
          ? legacyQcode
          : null,
      'legacy_itemsrno': (legacyItemsrno != null && legacyItemsrno!.isNotEmpty)
          ? legacyItemsrno
          : null,
      'item_group': itemGroup,
      'item_nature': itemNature,
      'allowed_series': allowedSeries,
      'can_be_purchased': canBePurchased,
      'is_internal': isInternal,
      'can_be_sold': canBeSold,
      'is_stock_tracked': isStockTracked,
      'hsn_code': hsnCode,
      'is_hsn_locked': isHsnLocked,
      'gst_rate': gstRate,
      'is_reverse_charge': isReverseCharge,
      'primary_uom': primaryUom,
      'secondary_uom': (secondaryUom != null && secondaryUom!.isNotEmpty)
          ? secondaryUom
          : null,
      'domain_specs': domainSpecs,
      'variations': variations.map((v) => v.toJson()).toList(),
      'cost_price': costPrice,
      'last_pur_rate': lastPurRate,
      'sell_price_1': sellPrice1,
      'sell_price_2': sellPrice2,
      'sell_price_3': sellPrice3,
      'pref_vendor': prefVendor.map((v) => v.toJson()).toList(),
      'reorder_level': reorderLevel,
      'has_child_designs': hasChildDesigns,
      if (defDesignId != null && defDesignId!.isNotEmpty)
        'def_design_id': defDesignId,
      'comp_score': overrideCompScore ?? compScore,
      'version': version,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Evaluates real-time Completion Ratio (`comp_score` 0-100%) and compares
  /// against the chosen legacy `sq_QUAL` item if present.
  SbCompBreakdown evaluateCompletion({
    SbItemGroupConfig? groupConfig,
    SqQualModel? legacySource,
  }) {
    final List<SbCompCheckItem> checks = [];

    // -------------------------------------------------------------------------
    // PILLAR 1: IDENTITY & BARREL (25 Pts)
    // -------------------------------------------------------------------------
    final bool hasCodeAndName =
        itemCode.trim().length >= 2 && name.trim().length >= 2;
    checks.add(SbCompCheckItem(
      pillar: 'Identity',
      label: 'Item Code & Commercial Name',
      isComplete: hasCodeAndName,
      earnedPoints: hasCodeAndName ? 10 : 0,
      maxPoints: 10,
      hint: 'Requires unique item_code and display name',
    ));

    final bool hasBarrelAndSwitch =
        itemGroup.isNotEmpty && (canBePurchased || isInternal || canBeSold);
    checks.add(SbCompCheckItem(
      pillar: 'Identity',
      label: 'Barrel & Transaction Routing',
      isComplete: hasBarrelAndSwitch,
      earnedPoints: hasBarrelAndSwitch ? 10 : 0,
      maxPoints: 10,
      hint: 'Assign item_group and at least 1 transaction capability switch',
    ));

    final bool hasUom = primaryUom.trim().isNotEmpty;
    checks.add(SbCompCheckItem(
      pillar: 'Identity',
      label: 'Primary UOM Assigned ($primaryUom)',
      isComplete: hasUom,
      earnedPoints: hasUom ? 5 : 0,
      maxPoints: 5,
      hint: 'Select primary measurement unit (PCS, MTS, KG)',
    ));

    final int identityPts = checks
        .where((c) => c.pillar == 'Identity')
        .fold(0, (s, c) => s + c.earnedPoints);

    // -------------------------------------------------------------------------
    // PILLAR 2: STATUTORY & GST COMPLIANCE (25 Pts)
    // -------------------------------------------------------------------------
    final String cleanHsn = hsnCode.replaceAll('-', '').trim();
    final bool hasValidHsn = cleanHsn.length >= 4;
    checks.add(SbCompCheckItem(
      pillar: 'Compliance',
      label: 'Statutory HSN / SAC Code (${hasValidHsn ? cleanHsn : "Missing"})',
      isComplete: hasValidHsn,
      earnedPoints: hasValidHsn ? 15 : 0,
      maxPoints: 15,
      hint: 'Enter minimum 4-to-8 digit HSN or 6-digit SAC code',
    ));

    final bool hasGstAndLock = gstRate >= 0 && isHsnLocked;
    checks.add(SbCompCheckItem(
      pillar: 'Compliance',
      label: 'GST Rate (${gstRate.toStringAsFixed(1)}%) & HSN Lock',
      isComplete: hasGstAndLock,
      earnedPoints: hasGstAndLock ? 10 : (gstRate >= 0 ? 5 : 0),
      maxPoints: 10,
      hint: 'Verify GST % slab and lock HSN to prevent bill overrides',
    ));

    final int compliancePts = checks
        .where((c) => c.pillar == 'Compliance')
        .fold(0, (s, c) => s + c.earnedPoints);

    // -------------------------------------------------------------------------
    // PILLAR 3: COSTING & PRICING (25 Pts)
    // -------------------------------------------------------------------------
    int costingEarned = 0;
    if (canBeSold && !canBePurchased) {
      // Sales catalog item: Needs sell_price_1 (15 pts) + base cost_price (10 pts)
      final bool hasSell = sellPrice1 > 0;
      final bool hasCost = costPrice > 0;
      checks.add(SbCompCheckItem(
        pillar: 'Costing',
        label: 'Catalog Selling Price (₹${sellPrice1.toStringAsFixed(0)})',
        isComplete: hasSell,
        earnedPoints: hasSell ? 15 : 0,
        maxPoints: 15,
        hint: 'Set primary wholesale selling price (sell_price_1 > 0)',
      ));
      checks.add(SbCompCheckItem(
        pillar: 'Costing',
        label: 'Base Landed Cost (₹${costPrice.toStringAsFixed(0)})',
        isComplete: hasCost,
        earnedPoints: hasCost ? 10 : 0,
        maxPoints: 10,
        hint: 'Enter standard base cost to unlock gross margin tracking',
      ));
    } else if (canBePurchased || isInternal) {
      // Purchase / Internal WIP item: Needs cost_price > 0 (20 pts) + vendor or last_pur_rate (5 pts)
      final bool hasCost = costPrice > 0 ||
          variations.any((v) => v.costPrice > 0);
      final bool hasVendorOrHistory = prefVendor.isNotEmpty || lastPurRate > 0;
      checks.add(SbCompCheckItem(
        pillar: 'Costing',
        label: 'Standard Purchase / Job Rate',
        isComplete: hasCost,
        earnedPoints: hasCost ? 20 : 0,
        maxPoints: 20,
        hint: 'Set cost_price > 0 (fills the 100% NULL legacy costing void)',
      ));
      checks.add(SbCompCheckItem(
        pillar: 'Costing',
        label: 'Preferred Vendor / Last Purchase Benchmark',
        isComplete: hasVendorOrHistory,
        earnedPoints: hasVendorOrHistory ? 5 : 0,
        maxPoints: 5,
        hint: 'Add at least 1 preferred supplier or historical purchase rate',
      ));
    } else {
      final bool hasAnyRate = costPrice > 0 || sellPrice1 > 0;
      checks.add(SbCompCheckItem(
        pillar: 'Costing',
        label: 'Benchmark Rate Configured',
        isComplete: hasAnyRate,
        earnedPoints: hasAnyRate ? 25 : 0,
        maxPoints: 25,
        hint: 'Specify either cost price or selling rate',
      ));
    }

    costingEarned = checks
        .where((c) => c.pillar == 'Costing')
        .fold(0, (s, c) => s + c.earnedPoints);

    // -------------------------------------------------------------------------
    // PILLAR 4: DOMAIN SPECS, VARIATIONS & WAREHOUSE (25 Pts)
    // -------------------------------------------------------------------------
    final List<SbSpecFieldDef> reqFields = groupConfig?.specSchema
            .where((f) => f.required)
            .toList() ??
        const [];

    int filledSpecCount = 0;
    for (final f in reqFields) {
      final val = domainSpecs[f.key];
      if (val != null && val.toString().trim().isNotEmpty && val != 0) {
        filledSpecCount++;
      }
    }
    final bool specsComplete =
        reqFields.isEmpty || filledSpecCount == reqFields.length;
    final int specMaxPts = isStockTracked ? 15 : 25;
    final int specEarnedPts = reqFields.isEmpty
        ? (domainSpecs.isNotEmpty ? specMaxPts : (specMaxPts ~/ 2))
        : ((filledSpecCount / reqFields.length) * specMaxPts).round();

    checks.add(SbCompCheckItem(
      pillar: 'Specs & Warehouse',
      label: reqFields.isEmpty
          ? 'Barrel Domain Specifications'
          : 'Barrel Specs ($filledSpecCount/${reqFields.length} required)',
      isComplete: specsComplete,
      earnedPoints: specEarnedPts,
      maxPoints: specMaxPts,
      hint: 'Complete Admin-defined domain_specs for $itemGroup',
    ));

    if (isStockTracked) {
      final bool hasReorderOrVars = reorderLevel > 0 ||
          variations.any((v) => v.reorderLevel > 0) ||
          variations.isNotEmpty;
      checks.add(SbCompCheckItem(
        pillar: 'Specs & Warehouse',
        label: variations.isNotEmpty
            ? 'Reorder Threshold & ${variations.length} Variation(s)'
            : 'Warehouse Reorder Threshold ($reorderLevel $primaryUom)',
        isComplete: hasReorderOrVars,
        earnedPoints: hasReorderOrVars ? 10 : 0,
        maxPoints: 10,
        hint: 'Set reorder_level > 0 or add size/ply variations',
      ));
    }

    final int specsPts = checks
        .where((c) => c.pillar == 'Specs & Warehouse')
        .fold(0, (s, c) => s + c.earnedPoints);

    final int total =
        (identityPts + compliancePts + costingEarned + specsPts).clamp(0, 100);

    // Compute Legacy Baseline Score for comparison delta
    int legacyScore = 35; // Base identity in sq_QUAL
    if (legacySource != null) {
      int ls = 20; // qcode + NAME + UNIT
      if (legacySource.hsnCode.isNotEmpty && legacySource.hsnCode != '-') {
        ls += 15;
      }
      if (legacySource.gstRate > 0) ls += 5;
      if (legacySource.sell1 > 0 || legacySource.pur1 > 0) ls += 10;
      if (legacySource.cut > 0 || legacySource.packing.isNotEmpty) ls += 5;
      legacyScore = ls.clamp(0, 100);
    }

    return SbCompBreakdown(
      totalScore: total,
      legacyBaselineScore: legacyScore,
      identityScore: identityPts,
      complianceScore: compliancePts,
      costingScore: costingEarned,
      specsScore: specsPts,
      checks: checks,
    );
  }

  MdlSbItem copyWith({
    String? id,
    String? itemCode,
    String? name,
    String? description,
    String? status,
    String? legacyQcode,
    String? legacyItemsrno,
    String? itemGroup,
    String? itemNature,
    List<String>? allowedSeries,
    bool? canBePurchased,
    bool? isInternal,
    bool? canBeSold,
    bool? isStockTracked,
    String? hsnCode,
    bool? isHsnLocked,
    double? gstRate,
    bool? isReverseCharge,
    String? primaryUom,
    String? secondaryUom,
    Map<String, dynamic>? domainSpecs,
    List<SbItemVariation>? variations,
    double? costPrice,
    double? lastPurRate,
    double? sellPrice1,
    double? sellPrice2,
    double? sellPrice3,
    List<SbPrefVendor>? prefVendor,
    int? reorderLevel,
    bool? hasChildDesigns,
    String? defDesignId,
    int? compScore,
    int? version,
  }) {
    return MdlSbItem(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      legacyQcode: legacyQcode ?? this.legacyQcode,
      legacyItemsrno: legacyItemsrno ?? this.legacyItemsrno,
      itemGroup: itemGroup ?? this.itemGroup,
      itemNature: itemNature ?? this.itemNature,
      allowedSeries: allowedSeries ?? this.allowedSeries,
      canBePurchased: canBePurchased ?? this.canBePurchased,
      isInternal: isInternal ?? this.isInternal,
      canBeSold: canBeSold ?? this.canBeSold,
      isStockTracked: isStockTracked ?? this.isStockTracked,
      hsnCode: hsnCode ?? this.hsnCode,
      isHsnLocked: isHsnLocked ?? this.isHsnLocked,
      gstRate: gstRate ?? this.gstRate,
      isReverseCharge: isReverseCharge ?? this.isReverseCharge,
      primaryUom: primaryUom ?? this.primaryUom,
      secondaryUom: secondaryUom ?? this.secondaryUom,
      domainSpecs: domainSpecs ?? this.domainSpecs,
      variations: variations ?? this.variations,
      costPrice: costPrice ?? this.costPrice,
      lastPurRate: lastPurRate ?? this.lastPurRate,
      sellPrice1: sellPrice1 ?? this.sellPrice1,
      sellPrice2: sellPrice2 ?? this.sellPrice2,
      sellPrice3: sellPrice3 ?? this.sellPrice3,
      prefVendor: prefVendor ?? this.prefVendor,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      hasChildDesigns: hasChildDesigns ?? this.hasChildDesigns,
      defDesignId: defDesignId ?? this.defDesignId,
      compScore: compScore ?? this.compScore,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// [MdlSbItemAuditLog] — Immutable Audit Trail Entry from `IMMBE2627.sb_item_audit_log`.
@immutable
class MdlSbItemAuditLog {
  final String id;
  final String itemId;
  final String changeType;
  final String fieldName;
  final String? oldValue;
  final String newValue;
  final String reasonComment;
  final String? changedByUserName;
  final DateTime createdAt;

  const MdlSbItemAuditLog({
    required this.id,
    required this.itemId,
    required this.changeType,
    required this.fieldName,
    this.oldValue,
    required this.newValue,
    required this.reasonComment,
    this.changedByUserName,
    required this.createdAt,
  });

  factory MdlSbItemAuditLog.fromJson(Map<String, dynamic> json) {
    return MdlSbItemAuditLog(
      id: (json['id'] ?? '').toString(),
      itemId: (json['item_id'] ?? '').toString(),
      changeType: (json['change_type'] ?? 'SPEC_UPDATE').toString(),
      fieldName: (json['field_name'] ?? '').toString(),
      oldValue: json['old_value']?.toString(),
      newValue: (json['new_value'] ?? '').toString(),
      reasonComment: (json['reason_comment'] ?? '').toString(),
      changedByUserName: json['changed_by_user_name']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

