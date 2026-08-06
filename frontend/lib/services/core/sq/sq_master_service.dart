/*
================================================================================
LLM CONTEXT & QUERY SPACE — SQ MASTER SERVICE (sq_master_service.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical core service singleton for table `sq_MASTER` in target schema `IMMBE2627`.
   - Provides paginated party master fetching, searching, ATYPE filtering, city options, and broker options.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema isolated via `.schema('IMMBE2627')`.
   - Queries `sq_MASTER` for party profiles and ledger definitions.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_MASTER` is Airbyte mirror, strictly read-only.
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_master.dart';
import '../service_supabase.dart';

/// [SqMasterService] — Canonical Core Service Layer for `sq_MASTER`.
class SqMasterService {
  static final SqMasterService _instance = SqMasterService._internal();
  factory SqMasterService() => _instance;
  SqMasterService._internal();

  final _db = SupabaseService();

  /// Fetches paginated party master list with optional filters.
  Future<({List<SqMasterModel> data, int totalCount})> getPaginatedMasters({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
    int? atype,
    List<int>? atypeList,
    String? city,
    String? broker,
  }) async {
    try {
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('code');

      if (atype != null) {
        countQuery = countQuery.eq('ATYPE', atype);
      } else if (atypeList != null && atypeList.isNotEmpty) {
        countQuery = countQuery.inFilter('ATYPE', atypeList);
      }

      if (city != null && city.isNotEmpty && city != 'All') {
        countQuery = countQuery.ilike('CITY1', city);
      }
      if (broker != null && broker.isNotEmpty && broker != 'All') {
        countQuery = countQuery.ilike('ADATIYA', broker);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        countQuery = countQuery.or('code.ilike.$q,NAME.ilike.$q,CITY1.ilike.$q,STATION.ilike.$q,GSTIN.ilike.$q,MOBILE.ilike.$q');
      }

      final countRes = await countQuery.count();
      final int totalCount = countRes.count ?? 0;

      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('*');

      if (atype != null) {
        fetchQuery = fetchQuery.eq('ATYPE', atype);
      } else if (atypeList != null && atypeList.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('ATYPE', atypeList);
      }

      if (city != null && city.isNotEmpty && city != 'All') {
        fetchQuery = fetchQuery.ilike('CITY1', city);
      }
      if (broker != null && broker.isNotEmpty && broker != 'All') {
        fetchQuery = fetchQuery.ilike('ADATIYA', broker);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        fetchQuery = fetchQuery.or('code.ilike.$q,NAME.ilike.$q,CITY1.ilike.$q,STATION.ilike.$q,GSTIN.ilike.$q,MOBILE.ilike.$q');
      }

      fetchQuery = fetchQuery.order('code', ascending: true);

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>? ?? [];

      final items = rawList.map((j) => SqMasterModel.fromJson(j as Map<String, dynamic>)).toList();

      return (data: items, totalCount: totalCount);
    } catch (e, stack) {
      debugPrint('Error in SqMasterService.getPaginatedMasters: $e\n$stack');
      return (data: <SqMasterModel>[], totalCount: 0);
    }
  }

  /// Fetches a single party master record by `code`.
  Future<SqMasterModel?> getMasterByCode(String code) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('*')
          .eq('code', code)
          .maybeSingle();

      if (response == null) return null;
      return SqMasterModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SqMasterService.getMasterByCode: $e');
      return null;
    }
  }
}
