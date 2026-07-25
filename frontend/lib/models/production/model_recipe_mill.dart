import 'package:flutter/foundation.dart';

/// Immutable model representing a Mill Printing Job Work Recipe record (`sb_recipe_mill`).
@immutable
class MillRecipeModel {
  final String id;
  final String millCode;
  final String millName;
  final String fabricCode;
  final String fabricName;
  final String printType; // e.g. Overprint, Padding, Discharge, Pigment, Direct, Digital
  final String valueType; // e.g. Ink, Smoke, Zari, Foil, Table Print, Machine Print
  final double rate; // Rate in ₹ per meter
  final DateTime effectiveDate;
  final bool isActive;
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const MillRecipeModel({
    required this.id,
    required this.millCode,
    required this.millName,
    required this.fabricCode,
    required this.fabricName,
    required this.printType,
    required this.valueType,
    required this.rate,
    required this.effectiveDate,
    this.isActive = true,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  /// Factory constructor for defensive parsing from Supabase JSON.
  factory MillRecipeModel.fromJson(Map<String, dynamic> json) {
    return MillRecipeModel(
      id: json['id']?.toString() ?? '',
      millCode: json['mill_code']?.toString() ?? '',
      millName: json['mill_name']?.toString() ?? 'Unknown Mill',
      fabricCode: json['fabric_code']?.toString() ?? '',
      fabricName: json['fabric_name']?.toString() ?? 'Unknown Fabric',
      printType: json['print_type']?.toString() ?? 'Overprint',
      valueType: json['value_type']?.toString() ?? 'Ink',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      effectiveDate: json['effective_date'] != null
          ? DateTime.tryParse(json['effective_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      remarks: json['remarks']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      createdBy: json['created_by']?.toString(),
    );
  }

  /// Converts the model to JSON for database insert/update operations.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'mill_code': millCode,
      'mill_name': millName,
      'fabric_code': fabricCode,
      'fabric_name': fabricName,
      'print_type': printType,
      'value_type': valueType,
      'rate': rate,
      'effective_date': effectiveDate.toIso8601String().split('T').first,
      'is_active': isActive,
      'remarks': remarks,
      'created_by': createdBy ?? 'system',
    };
    if (id.isNotEmpty) {
      data['id'] = id;
    }
    return data;
  }

  /// Copies the object with optional parameter overrides.
  MillRecipeModel copyWith({
    String? id,
    String? millCode,
    String? millName,
    String? fabricCode,
    String? fabricName,
    String? printType,
    String? valueType,
    double? rate,
    DateTime? effectiveDate,
    bool? isActive,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return MillRecipeModel(
      id: id ?? this.id,
      millCode: millCode ?? this.millCode,
      millName: millName ?? this.millName,
      fabricCode: fabricCode ?? this.fabricCode,
      fabricName: fabricName ?? this.fabricName,
      printType: printType ?? this.printType,
      valueType: valueType ?? this.valueType,
      rate: rate ?? this.rate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      isActive: isActive ?? this.isActive,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

/// Model holding top-level summary metrics for the KPI cards.
@immutable
class MillRecipeMetricsModel {
  final int totalActiveRecipes;
  final double avgPrintingRate;
  final int activeMillsCount;
  final String topPrintType;
  final int totalRevisionsCount;

  const MillRecipeMetricsModel({
    this.totalActiveRecipes = 0,
    this.avgPrintingRate = 0.0,
    this.activeMillsCount = 0,
    this.topPrintType = 'Overprint',
    this.totalRevisionsCount = 0,
  });
}

/// Model for grouping Mill Recipes in the 2-Pane Left Sidebar List.
@immutable
class MillRecipeGroupModel {
  final String millCode;
  final String millName;
  final int activeRecipesCount;
  final int fabricsCount;
  final DateTime latestRevisionDate;
  final double avgRate;
  final List<MillRecipeModel> recipes;

  const MillRecipeGroupModel({
    required this.millCode,
    required this.millName,
    required this.activeRecipesCount,
    required this.fabricsCount,
    required this.latestRevisionDate,
    required this.avgRate,
    required this.recipes,
  });
}
