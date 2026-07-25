import 'package:flutter/foundation.dart';
import '../../models/production/model_recipe_mill.dart';
import '../core/service_supabase.dart';

/// Service layer managing Supabase operations for Mill Printing Recipes (`sb_recipe_mill`).
/// Schema: `IMMBE2627`
class RecipeMillService {
  static final RecipeMillService _instance = RecipeMillService._internal();
  factory RecipeMillService() => _instance;
  RecipeMillService._internal();

  final _db = SupabaseService();

  /// Standard print types available in textile mill printing.
  static const List<String> standardPrintTypes = [
    'Overprint',
    'Padding',
    'Discharge',
    'Pigment',
    'Reactive',
    'Direct',
    'Digital',
    'Screen',
  ];

  /// Standard value additions / processes in mill printing.
  static const List<String> standardValueTypes = [
    'Ink',
    'Smoke',
    'Zari',
    'Foil',
    'Table Print',
    'Machine Print',
    'Brass',
    'Duster',
    'Emboss',
  ];

  /// Fetches all mill recipes with server/client filtering.
  Future<List<MillRecipeModel>> getRecipes({
    String? searchQuery,
    String? filterMill,
    String? filterFabric,
    String? filterPrintType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_recipe_mill')
          .select('*')
          .order('effective_date', ascending: false);

      List<MillRecipeModel> recipes = (response as List)
          .map((json) => MillRecipeModel.fromJson(json))
          .toList();

      // Apply Mill filter
      if (filterMill != null && filterMill.isNotEmpty && filterMill != 'All') {
        recipes = recipes
            .where((r) =>
                r.millCode.toLowerCase() == filterMill.toLowerCase() ||
                r.millName.toLowerCase().contains(filterMill.toLowerCase()))
            .toList();
      }

      // Apply Fabric filter
      if (filterFabric != null && filterFabric.isNotEmpty && filterFabric != 'All') {
        recipes = recipes
            .where((r) =>
                r.fabricCode.toLowerCase() == filterFabric.toLowerCase() ||
                r.fabricName.toLowerCase().contains(filterFabric.toLowerCase()))
            .toList();
      }

      // Apply Print Type filter
      if (filterPrintType != null && filterPrintType.isNotEmpty && filterPrintType != 'All') {
        recipes = recipes
            .where((r) => r.printType.toLowerCase() == filterPrintType.toLowerCase())
            .toList();
      }

      // Apply Date Filters
      if (startDate != null) {
        recipes = recipes
            .where((r) => r.effectiveDate.isAfter(startDate.subtract(const Duration(days: 1))))
            .toList();
      }
      if (endDate != null) {
        recipes = recipes
            .where((r) => r.effectiveDate.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      }

      // Apply Search Query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        recipes = recipes.where((r) {
          return r.millName.toLowerCase().contains(query) ||
              r.fabricName.toLowerCase().contains(query) ||
              r.printType.toLowerCase().contains(query) ||
              r.valueType.toLowerCase().contains(query) ||
              (r.remarks?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      return recipes;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching mill recipes: $e');
      }
      return [];
    }
  }

  /// Groups recipes by Mill for the 2-Pane Left Sidebar List.
  Future<List<MillRecipeGroupModel>> getMillGroups({
    String? searchQuery,
    String? filterMill,
    String? filterFabric,
  }) async {
    final allRecipes = await getRecipes(
      searchQuery: searchQuery,
      filterMill: filterMill,
      filterFabric: filterFabric,
    );

    Map<String, List<MillRecipeModel>> grouped = {};
    for (var recipe in allRecipes) {
      grouped.putIfAbsent(recipe.millCode, () => []).add(recipe);
    }

    List<MillRecipeGroupModel> groups = [];
    grouped.forEach((millCode, recipes) {
      final millName = recipes.first.millName;
      final activeCount = recipes.where((r) => r.isActive).length;
      final fabricSet = recipes.map((r) => r.fabricCode).toSet();
      final latestDate = recipes.map((r) => r.effectiveDate).reduce((a, b) => a.isAfter(b) ? a : b);
      final avgRate = recipes.isNotEmpty
          ? recipes.map((r) => r.rate).reduce((a, b) => a + b) / recipes.length
          : 0.0;

      groups.add(MillRecipeGroupModel(
        millCode: millCode,
        millName: millName,
        activeRecipesCount: activeCount,
        fabricsCount: fabricSet.length,
        latestRevisionDate: latestDate,
        avgRate: avgRate,
        recipes: recipes,
      ));
    });

    // Sort by latest revision date descending
    groups.sort((a, b) => b.latestRevisionDate.compareTo(a.latestRevisionDate));
    return groups;
  }

  /// Calculates top-level metric statistics for summary cards.
  Future<MillRecipeMetricsModel> getMetrics() async {
    final recipes = await getRecipes();
    if (recipes.isEmpty) {
      return const MillRecipeMetricsModel();
    }

    final activeRecipes = recipes.where((r) => r.isActive).toList();
    final totalActive = activeRecipes.length;
    final avgRate = activeRecipes.isNotEmpty
        ? activeRecipes.map((r) => r.rate).reduce((a, b) => a + b) / activeRecipes.length
        : 0.0;

    final millsCount = recipes.map((r) => r.millCode).toSet().length;

    // Find top print type
    Map<String, int> typeCounts = {};
    for (var r in recipes) {
      typeCounts[r.printType] = (typeCounts[r.printType] ?? 0) + 1;
    }
    String topType = 'Overprint';
    int maxCount = 0;
    typeCounts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        topType = type;
      }
    });

    return MillRecipeMetricsModel(
      totalActiveRecipes: totalActive,
      avgPrintingRate: avgRate,
      activeMillsCount: millsCount,
      topPrintType: topType,
      totalRevisionsCount: recipes.length,
    );
  }

  /// Saves or updates a single mill printing recipe record.
  Future<bool> saveRecipe(MillRecipeModel recipe) async {
    try {
      final data = recipe.toJson();
      if (recipe.id.isEmpty) {
        data.remove('id');
        await _db.client.schema('IMMBE2627').from('sb_recipe_mill').insert(data);
      } else {
        await _db.client
            .schema('IMMBE2627')
            .from('sb_recipe_mill')
            .update(data)
            .eq('id', recipe.id);
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving mill recipe: $e');
      }
      return false;
    }
  }

  /// Batch saves multiple mill recipe records.
  Future<bool> batchSaveRecipes(List<MillRecipeModel> recipes) async {
    try {
      final inserts = recipes.map((r) {
        final data = r.toJson();
        if (r.id.isEmpty) data.remove('id');
        return data;
      }).toList();

      await _db.client.schema('IMMBE2627').from('sb_recipe_mill').upsert(inserts);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error batch saving mill recipes: $e');
      }
      return false;
    }
  }

  /// Deletes a recipe record by ID.
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_recipe_mill')
          .delete()
          .eq('id', recipeId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting mill recipe: $e');
      }
      return false;
    }
  }

  /// Toggles active status of a recipe.
  Future<bool> toggleRecipeStatus(String recipeId, bool isActive) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_recipe_mill')
          .update({'is_active': isActive, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', recipeId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling mill recipe status: $e');
      }
      return false;
    }
  }

  /// Fetches unique Mill master options from `sq_MASTER` and existing recipes.
  Future<List<Map<String, String>>> getMillOptions() async {
    try {
      final sqResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('code, NAME')
          .order('NAME', ascending: true)
          .limit(200);

      List<Map<String, String>> mills = (sqResponse as List).map((item) {
        return {
          'code': item['code']?.toString() ?? '',
          'name': item['NAME']?.toString() ?? '',
        };
      }).toList();

      // If empty or fallback, provide standard defaults
      if (mills.isEmpty) {
        return [
          {'code': 'M001', 'name': 'Ambaji Mill Prints'},
          {'code': 'M002', 'name': 'Shree Ram Processors'},
          {'code': 'M003', 'name': 'Vardhman Textile Prints'},
        ];
      }
      return mills;
    } catch (e) {
      return [
        {'code': 'M001', 'name': 'Ambaji Mill Prints'},
        {'code': 'M002', 'name': 'Shree Ram Processors'},
        {'code': 'M003', 'name': 'Vardhman Textile Prints'},
      ];
    }
  }

  /// Fetches unique Fabric/Quality options from `sq_QUAL` and existing recipes.
  Future<List<Map<String, String>>> getFabricOptions() async {
    try {
      final sqResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('qcode, NAME')
          .order('NAME', ascending: true)
          .limit(200);

      List<Map<String, String>> fabrics = (sqResponse as List).map((item) {
        return {
          'code': item['qcode']?.toString() ?? '',
          'name': item['NAME']?.toString() ?? '',
        };
      }).toList();

      if (fabrics.isEmpty) {
        return [
          {'code': 'Q001', 'name': '60x60 Cotton Satin'},
          {'code': 'Q002', 'name': 'Georgette 60G'},
          {'code': 'Q003', 'name': 'Dola Silk'},
          {'code': 'Q004', 'name': 'Organza Silk'},
        ];
      }
      return fabrics;
    } catch (e) {
      return [
        {'code': 'Q001', 'name': '60x60 Cotton Satin'},
        {'code': 'Q002', 'name': 'Georgette 60G'},
        {'code': 'Q003', 'name': 'Dola Silk'},
        {'code': 'Q004', 'name': 'Organza Silk'},
      ];
    }
  }
}
