/*
================================================================================
LLM CONTEXT & QUERY SPACE — VENDOR SOURCES & DESIGNS SERVICE (srv_design.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Unified Supabase Data Service for the 3-Entity Architecture:
     * `IMMBE2627.sb_sources` (Vendor design repository: Mill Programs + Top-Dyed
       Finish Purchases)
     * `IMMBE2627.sb_designs` (Commercial Design SKUs strictly linked to
       `sb_item` via `parent_item`)
     * `IMMBE2627.sb_item` (Finished Saree billing item lookup)

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema isolated via `.schema('IMMBE2627')`.
   - `getDesigns(...)` joins `sb_item!parent_item` and `sb_sources!active_source_id`
     plus optional `sbvw_stock_summary` by `design_code = des_code`.
   - `saveSource(...)` upserts on `source_code` (`<4-ALPHA-VENDOR>-<DES_NO>`).
   - `saveDesign(...)` evaluates completion score (`comp_score`) & pending
     tasks automatically and upserts on `des_code`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_designs` has zero foreign keys or string links to `sq_QUAL`; `sb_item`
     serves as the exclusive commercial billing item master.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future Cutting Card & Job Card screens will query `getSources()` &
     `getDesigns()` directly from this service.
================================================================================
*/

library;

import 'package:flutter/foundation.dart';
import '../../models/masters/items/mdl_sb_item.dart';
import '../../models/masters/mdl_design.dart';
import '../../models/masters/mdl_stock_ledger.dart';
import '../core/service_supabase.dart';

class SrvDesign {
  static final SrvDesign _instance = SrvDesign._internal();
  factory SrvDesign() => _instance;
  SrvDesign._internal();

  final _db = SupabaseService().client;

  // ===========================================================================
  // 1. VENDOR SOURCES REPOSITORY (`IMMBE2627.sb_sources`)
  // ===========================================================================

  Future<List<MdlSource>> getSources({
    String? sareeType,
    String? entryStage,
    String? searchQuery,
  }) async {
    try {
      var query = _db.schema('IMMBE2627').from('sb_sources').select('*');

      if (sareeType != null && sareeType.isNotEmpty) {
        query = query.eq('saree_type', sareeType.toUpperCase());
      }
      if (entryStage != null && entryStage.isNotEmpty) {
        query = query.eq('entry_stage', entryStage.toUpperCase());
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or('source_code.ilike.%$q%,source_des_no.ilike.%$q%');
      }

      final rows = await query.order('updated_at', ascending: false).limit(200);
      final list = rows as List<dynamic>? ?? [];
      return list
          .map((e) => MdlSource.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e, stack) {
      debugPrint('Error in SrvDesign.getSources: $e\n$stack');
      return [];
    }
  }

  Future<MdlSource?> saveSource(MdlSource source) async {
    try {
      final String? uid = _db.auth.currentUser?.id;
      final payload = source.toUpsertJson(userId: uid);
      if (source.id == null && uid != null) {
        payload['created_by'] = uid;
      }

      final res = await _db
          .schema('IMMBE2627')
          .from('sb_sources')
          .upsert(payload, onConflict: 'source_code')
          .select()
          .single();

      return MdlSource.fromJson(Map<String, dynamic>.from(res));
    } catch (e, stack) {
      debugPrint('Error in SrvDesign.saveSource: $e\n$stack');
      rethrow;
    }
  }

  // ===========================================================================
  // 2. COMMERCIAL DESIGNS (`IMMBE2627.sb_designs`)
  // ===========================================================================

  Future<List<MdlDesign>> getDesigns({
    String? sareeType,
    String? lifecycleStage,
    String? searchQuery,
  }) async {
    try {
      var query = _db.schema('IMMBE2627').from('sb_designs').select(
            '*, sb_item!parent_item(id, item_code, name, sell_price_1), sb_sources!active_source_id(id, source_code, source_des_no, origin_specs)',
          );

      if (sareeType != null && sareeType.isNotEmpty) {
        query = query.eq('saree_type', sareeType.toUpperCase());
      }
      if (lifecycleStage != null && lifecycleStage.isNotEmpty) {
        query = query.eq('lifecycle_stage', lifecycleStage.toUpperCase());
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or('des_code.ilike.%$q%,des_no.ilike.%$q%');
      }

      final rows = await query.order('updated_at', ascending: false).limit(200);
      final list = rows as List<dynamic>? ?? [];
      if (list.isEmpty) return [];

      final codes = list
          .map((e) => (e['des_code'] as String?)?.trim() ?? '')
          .where((c) => c.isNotEmpty)
          .toList();
      final stockMap = await _fetchStockByDesignCodes(codes);

      return list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        final code = (map['des_code'] as String?)?.trim() ?? '';
        return MdlDesign.fromJson(map, stockSummary: stockMap[code]);
      }).toList();
    } catch (e, stack) {
      debugPrint('Error in SrvDesign.getDesigns: $e\n$stack');
      return [];
    }
  }

  Future<MdlDesign?> saveDesign(MdlDesign design) async {
    try {
      final String? uid = _db.auth.currentUser?.id;
      final payload = design.toUpsertJson(userId: uid);
      if (design.id == null && uid != null) {
        payload['created_by'] = uid;
      }

      final res = await _db
          .schema('IMMBE2627')
          .from('sb_designs')
          .upsert(payload, onConflict: 'des_code')
          .select(
            '*, sb_item!parent_item(id, item_code, name, sell_price_1), sb_sources!active_source_id(id, source_code, source_des_no, origin_specs)',
          )
          .single();

      final map = Map<String, dynamic>.from(res);
      final code = (map['des_code'] as String?)?.trim() ?? '';
      final stockMap = await _fetchStockByDesignCodes([code]);
      return MdlDesign.fromJson(map, stockSummary: stockMap[code]);
    } catch (e, stack) {
      debugPrint('Error in SrvDesign.saveDesign: $e\n$stack');
      rethrow;
    }
  }

  // ===========================================================================
  // 3. PARENT COMMERCIAL ITEMS LOOKUP (`sb_item` ONLY) & VENDORS/GREY HINTS
  // ===========================================================================

  Future<List<MdlSbItem>> getFinishedSareeItems() async {
    try {
      final rows = await _db
          .schema('IMMBE2627')
          .from('sb_item')
          .select('*')
          .or('item_group.eq.FINISHED_SAREE,has_child_designs.eq.true')
          .order('name', ascending: true);

      final list = rows as List<dynamic>? ?? [];
      return list
          .map((e) => MdlSbItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error in SrvDesign.getFinishedSareeItems: $e');
      return [];
    }
  }

  Future<List<String>> getVendorNameHints() async {
    try {
      final rows = await _db
          .schema('IMMBE2627')
          .from('sq_ACMAST')
          .select('pname')
          .or('ptype.ilike.%MILL%,ptype.ilike.%WEAV%,ptype.ilike.%SUPP%')
          .limit(60);
      final list = rows as List<dynamic>? ?? [];
      return list
          .map((e) => (e['pname'] as String?)?.trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (_) {
      return const [
        'AAISWARYA DYEING MILLS PVT LTD',
        'SHAILJA TEXPRINTS PVT.LTD.',
        'VASANT FABRICS PVT.LTD..',
        'DURGA PROCESSORS PVT.LTD.',
        'LAXMI VISHNU SILK MILLS',
        'SHREE RAPIER WEAVERS',
      ];
    }
  }

  Future<Map<String, StockSummaryModel>> _fetchStockByDesignCodes(
    List<String> codes,
  ) async {
    if (codes.isEmpty) return {};
    try {
      final rows = await _db
          .schema('IMMBE2627')
          .from('sbvw_stock_summary')
          .select('*')
          .inFilter('design_code', codes);

      final list = rows as List<dynamic>? ?? [];
      final map = <String, StockSummaryModel>{};
      for (final row in list) {
        final m =
            StockSummaryModel.fromJson(Map<String, dynamic>.from(row as Map));
        map[m.designCode] = m;
      }
      return map;
    } catch (e) {
      debugPrint('Error in SrvDesign._fetchStockByDesignCodes: $e');
      return {};
    }
  }
}
