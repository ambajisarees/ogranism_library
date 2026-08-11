/*
================================================================================
LLM CONTEXT & QUERY SPACE — DESIGNS MASTER SERVICE (srv_design.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Service Singleton for Designs Master (`sb_designs`).
   - Handles creation, fetching, matching recipe updates, and stage transitions for Design SKUs.
   - Joins live stock ledger summaries from `sbvw_stock_summary`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema isolated via `.schema('IMMBE2627')`.
   - `ensureMasterDesign(...)` automatically creates a `VIDHI-MAIN` master design SKU when an Item is initialized if one doesn't exist.
   - `getDesignsByItemSrNo(...)` returns all designs for an Item with joined live stock summaries.
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../models/production/mdl_design.dart';
import '../../models/production/mdl_stock_ledger.dart';
import '../core/service_supabase.dart';

/// [SrvDesign] — Module Service Singleton for Design Master Operations.
class SrvDesign {
  static final SrvDesign _instance = SrvDesign._internal();
  factory SrvDesign() => _instance;
  SrvDesign._internal();

  final _db = SupabaseService();

  /// Fetches all Design SKUs for a specific Item (`itemsrno`) with joined live stock summaries.
  Future<List<MdlDesign>> getDesignsByItemSrNo(String itemSrNo) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .select('*')
          .eq('itemsrno', itemSrNo)
          .order('is_master', ascending: false)
          .order('design_no', ascending: true);

      final rawList = response as List<dynamic>? ?? [];
      if (rawList.isEmpty) return [];

      // Fetch stock summaries for these designs from sbvw_stock_summary
      final stockMap = await _fetchStockSummariesForItem(itemSrNo);

      return rawList.map((j) {
        final designCode = (j['design_code'] as String?)?.trim() ?? '';
        final stockSummary = stockMap[designCode];
        return MdlDesign.fromJson(j as Map<String, dynamic>, stockSummary);
      }).toList();
    } catch (e, stack) {
      debugPrint('Error in SrvDesign.getDesignsByItemSrNo: $e\n$stack');
      return [];
    }
  }

  /// Fetches a single Design SKU by `designCode`.
  Future<MdlDesign?> getDesignByCode(String designCode) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .select('*')
          .eq('design_code', designCode)
          .maybeSingle();

      if (response == null) return null;

      // Fetch joined stock summary
      final stockSummary = await _fetchStockSummaryForDesign(designCode);
      return MdlDesign.fromJson(response, stockSummary);
    } catch (e) {
      debugPrint('Error in SrvDesign.getDesignByCode: $e');
      return null;
    }
  }

  /// Creates or updates a Design SKU (`sb_designs`).
  Future<MdlDesign?> createOrUpdateDesign({
    required String itemSrNo,
    required String itemQCode,
    required String designNo,
    bool isMaster = false,
    DesignStage stage = DesignStage.millStage,
    String? sourceType,
    String? sourceVendor,
    String? sourceDesNo,
    String? sourceJobType,
    double finalSareeWt = 0.0,
    int pcsPerSet = 6,
    double finalBundleWt = 0.0,
    List<Map<String, dynamic>> optionsMatching = const [],
    List<Map<String, dynamic>> finalMatching = const [],
    int reorderLevelPcs = 100,
    List<String> mediaUrls = const [],
    List<String> pdfPaths = const [],
  }) async {
    try {
      final designCode = '${itemQCode.trim().toUpperCase()}-${designNo.trim().toUpperCase()}';

      final payload = {
        'design_code': designCode,
        'itemsrno': itemSrNo.trim(),
        'itemqcode': itemQCode.trim().toUpperCase(),
        'design_no': designNo.trim(),
        'is_master': isMaster,
        'lifecycle_stage': stage.dbValue,
        'source_type': sourceType?.trim(),
        'source_vendor': sourceVendor?.trim(),
        'source_desno': sourceDesNo?.trim(),
        'source_jobtype': sourceJobType?.trim(),
        'final_saree_wt': finalSareeWt,
        'pcs_per_set': pcsPerSet,
        'final_bundle_wt': finalBundleWt,
        'options_matching': optionsMatching,
        'final_matching': finalMatching,
        'reorder_level_pcs': reorderLevelPcs,
        'media_urls': mediaUrls,
        'pdf_paths': pdfPaths,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .upsert(payload, onConflict: 'design_code')
          .select()
          .single();

      final stockSummary = await _fetchStockSummaryForDesign(designCode);
      return MdlDesign.fromJson(response, stockSummary);
    } catch (e, stack) {
      debugPrint('Error in SrvDesign.createOrUpdateDesign: $e\n$stack');
      return null;
    }
  }

  /// Ensures a Master Design SKU (`VIDHI-MAIN`) exists for an Item.
  Future<MdlDesign?> ensureMasterDesign({
    required String itemSrNo,
    required String itemQCode,
  }) async {
    final masterCode = '${itemQCode.trim().toUpperCase()}-MAIN';
    final existing = await getDesignByCode(masterCode);
    if (existing != null) return existing;

    return createOrUpdateDesign(
      itemSrNo: itemSrNo,
      itemQCode: itemQCode,
      designNo: 'Main',
      isMaster: true,
      stage: DesignStage.millStage,
    );
  }

  /// Updates the matching recipes (`options_matching` & `final_matching`) for a Design.
  Future<bool> updateMatchingRecipes({
    required String designCode,
    required List<Map<String, dynamic>> optionsMatching,
    required List<Map<String, dynamic>> finalMatching,
  }) async {
    try {
      await _db.client.schema('IMMBE2627').from('sb_designs').update({
        'options_matching': optionsMatching,
        'final_matching': finalMatching,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('design_code', designCode);

      return true;
    } catch (e) {
      debugPrint('Error in SrvDesign.updateMatchingRecipes: $e');
      return false;
    }
  }

  // Internal Stock Summary Fetch Helpers
  Future<Map<String, StockSummaryModel>> _fetchStockSummariesForItem(String itemSrNo) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sbvw_stock_summary')
          .select('*')
          .eq('itemsrno', itemSrNo);

      final list = response as List<dynamic>? ?? [];
      final map = <String, StockSummaryModel>{};
      for (final row in list) {
        final m = StockSummaryModel.fromJson(row as Map<String, dynamic>);
        map[m.designCode] = m;
      }
      return map;
    } catch (e) {
      debugPrint('Error in SrvDesign._fetchStockSummariesForItem: $e');
      return {};
    }
  }

  Future<StockSummaryModel?> _fetchStockSummaryForDesign(String designCode) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sbvw_stock_summary')
          .select('*')
          .eq('design_code', designCode)
          .maybeSingle();

      if (response == null) return null;
      return StockSummaryModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SrvDesign._fetchStockSummaryForDesign: $e');
      return null;
    }
  }
}
