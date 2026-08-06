/*
================================================================================
LLM CONTEXT & QUERY SPACE — SQ QUAL SERVICE (sq_qual_service.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical core service singleton for table `sq_QUAL` in target schema `IMMBE2627`.
   - Provides paginated quality fetching, searching, cloth type filtering, and category aggregations.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema isolated via `.schema('IMMBE2627')`.
   - Queries `sq_QUAL` for master item definitions.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_QUAL` is Airbyte mirror, strictly read-only.
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_qual.dart';
import '../service_supabase.dart';

/// [SqQualService] — Canonical Core Service Layer for `sq_QUAL`.
class SqQualService {
  static final SqQualService _instance = SqQualService._internal();
  factory SqQualService() => _instance;
  SqQualService._internal();

  final _db = SupabaseService();

  /// Fetches paginated quality list with optional filters.
  Future<({List<SqQualModel> data, int totalCount})> getPaginatedQualities({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
    String? clothType,
    String? category,
    String? isBaseQual,
    String? unit,
  }) async {
    try {
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('qcode');

      if (clothType != null && clothType.isNotEmpty && clothType != 'All') {
        countQuery = countQuery.ilike('CLOTHTYPE', clothType);
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        countQuery = countQuery.ilike('category', category);
      }
      if (isBaseQual != null && isBaseQual.isNotEmpty && isBaseQual != 'All') {
        countQuery = countQuery.eq('ISBASEQUAL', isBaseQual);
      }
      if (unit != null && unit.isNotEmpty && unit != 'All') {
        countQuery = countQuery.ilike('UNIT', unit);
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

      if (clothType != null && clothType.isNotEmpty && clothType != 'All') {
        fetchQuery = fetchQuery.ilike('CLOTHTYPE', clothType);
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        fetchQuery = fetchQuery.ilike('category', category);
      }
      if (isBaseQual != null && isBaseQual.isNotEmpty && isBaseQual != 'All') {
        fetchQuery = fetchQuery.eq('ISBASEQUAL', isBaseQual);
      }
      if (unit != null && unit.isNotEmpty && unit != 'All') {
        fetchQuery = fetchQuery.ilike('UNIT', unit);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        fetchQuery = fetchQuery.or('qcode.ilike.$q,NAME.ilike.$q,category.ilike.$q,HSN_CODE.ilike.$q');
      }

      fetchQuery = fetchQuery.order('qcode', ascending: true);

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>? ?? [];

      final items = rawList.map((j) => SqQualModel.fromJson(j as Map<String, dynamic>)).toList();

      return (data: items, totalCount: totalCount);
    } catch (e, stack) {
      debugPrint('Error in SqQualService.getPaginatedQualities: $e\n$stack');
      return (data: <SqQualModel>[], totalCount: 0);
    }
  }

  /// Fetches a single quality record by `qcode`.
  Future<SqQualModel?> getQualityByCode(String qcode) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('*')
          .eq('qcode', qcode)
          .maybeSingle();

      if (response == null) return null;
      return SqQualModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SqQualService.getQualityByCode: $e');
      return null;
    }
  }
}
