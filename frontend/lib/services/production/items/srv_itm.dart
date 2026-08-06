/*
================================================================================
LLM CONTEXT & QUERY SPACE — ITEMS MODULE SERVICE (srv_itm.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Service Singleton for Items / Quality Master (`itm` / Master Layer).
   - Manages data access and filtering across Supabase table `IMMBE2627.sq_QUAL` (1,016 items).
   - Handles search queries, cloth type filters, category filters, unit filters, and submodule barrel filters.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Submodule Filtering:
     - `ItmCategory.all`: Fetches all items.
     - `ItmCategory.saree`: Filters `ISBASEQUAL = 'N'` & `CLOTHTYPE` IN ('SAREE', 'FINAL', 'DRESS').
     - `ItmCategory.grey`: Filters `ISBASEQUAL` IN ('Y', 'G').
     - `ItmCategory.others`: Filters non-saree, non-grey items.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_QUAL` is Airbyte-managed read-only mirror.
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_qual.dart';
import '../../../models/production/items/mdl_itm.dart';
import '../../core/service_supabase.dart';

/// [SrvItm] — Module Service Singleton for Items Master Operations.
class SrvItm {
  static final SrvItm _instance = SrvItm._internal();
  factory SrvItm() => _instance;
  SrvItm._internal();

  final _db = SupabaseService();

  /// Fetches paginated Item headers for [category] with optional context filters.
  Future<({List<MdlItmHeader> data, int totalCount})> getItems({
    required ItmCategory category,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    Set<String> selectedClothTypes = const {},
    Set<String> selectedCategories = const {},
    Set<String> selectedUnits = const {},
  }) async {
    try {
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('qcode');

      // Submodule filter
      switch (category) {
        case ItmCategory.saree:
          countQuery = countQuery.eq('ISBASEQUAL', 'N').inFilter('CLOTHTYPE', ['SAREE', 'FINAL', 'DRESS']);
          break;
        case ItmCategory.grey:
          countQuery = countQuery.inFilter('ISBASEQUAL', ['Y', 'G']);
          break;
        case ItmCategory.others:
          countQuery = countQuery.not('CLOTHTYPE', 'in', '("SAREE","FINAL")').neq('ISBASEQUAL', 'Y');
          break;
        case ItmCategory.all:
          break;
      }

      if (selectedClothTypes.isNotEmpty) {
        countQuery = countQuery.inFilter('CLOTHTYPE', selectedClothTypes.toList());
      }
      if (selectedCategories.isNotEmpty) {
        countQuery = countQuery.inFilter('category', selectedCategories.toList());
      }
      if (selectedUnits.isNotEmpty) {
        countQuery = countQuery.inFilter('UNIT', selectedUnits.toList());
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        countQuery = countQuery.or('qcode.ilike.$q,NAME.ilike.$q,category.ilike.$q,HSN_CODE.ilike.$q');
      }

      final countRes = await countQuery.count();
      final int totalCount = countRes.count ?? 0;

      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('*');

      // Submodule filter
      switch (category) {
        case ItmCategory.saree:
          fetchQuery = fetchQuery.eq('ISBASEQUAL', 'N').inFilter('CLOTHTYPE', ['SAREE', 'FINAL', 'DRESS']);
          break;
        case ItmCategory.grey:
          fetchQuery = fetchQuery.inFilter('ISBASEQUAL', ['Y', 'G']);
          break;
        case ItmCategory.others:
          fetchQuery = fetchQuery.not('CLOTHTYPE', 'in', '("SAREE","FINAL")').neq('ISBASEQUAL', 'Y');
          break;
        case ItmCategory.all:
          break;
      }

      if (selectedClothTypes.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('CLOTHTYPE', selectedClothTypes.toList());
      }
      if (selectedCategories.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('category', selectedCategories.toList());
      }
      if (selectedUnits.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('UNIT', selectedUnits.toList());
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        fetchQuery = fetchQuery.or('qcode.ilike.$q,NAME.ilike.$q,category.ilike.$q,HSN_CODE.ilike.$q');
      }

      fetchQuery = fetchQuery.order('qcode', ascending: true);

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final rawList = response as List<dynamic>? ?? [];

      final items = rawList
          .map((j) => MdlItmHeader(core: SqQualModel.fromJson(j as Map<String, dynamic>)))
          .toList();

      return (data: items, totalCount: totalCount);
    } catch (e, stack) {
      debugPrint('Error in SrvItm.getItems: $e\n$stack');
      return (data: <MdlItmHeader>[], totalCount: 0);
    }
  }

  /// Distinct Cloth Types (`CLOTHTYPE`)
  Future<List<String>> getClothTypeOptions() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('CLOTHTYPE')
          .not('CLOTHTYPE', 'is', null)
          .limit(200);

      final list = response as List<dynamic>? ?? [];
      final set = <String>{};
      for (final row in list) {
        final type = (row['CLOTHTYPE'] as String?)?.trim();
        if (type != null && type.isNotEmpty) {
          set.add(type);
        }
      }
      final sorted = set.toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('Error in SrvItm.getClothTypeOptions: $e');
      return [];
    }
  }

  /// Distinct Collection Categories (`category`)
  Future<List<String>> getCategoryOptions() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('category')
          .not('category', 'is', null)
          .limit(200);

      final list = response as List<dynamic>? ?? [];
      final set = <String>{};
      for (final row in list) {
        final cat = (row['category'] as String?)?.trim();
        if (cat != null && cat.isNotEmpty) {
          set.add(cat);
        }
      }
      final sorted = set.toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('Error in SrvItm.getCategoryOptions: $e');
      return [];
    }
  }

  /// Distinct Billing Units (`UNIT`)
  Future<List<String>> getUnitOptions() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('UNIT')
          .not('UNIT', 'is', null)
          .limit(200);

      final list = response as List<dynamic>? ?? [];
      final set = <String>{};
      for (final row in list) {
        final u = (row['UNIT'] as String?)?.trim();
        if (u != null && u.isNotEmpty) {
          set.add(u);
        }
      }
      final sorted = set.toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('Error in SrvItm.getUnitOptions: $e');
      return [];
    }
  }
}
