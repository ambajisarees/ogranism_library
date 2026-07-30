/*
================================================================================
LLM CONTEXT & QUERY SPACE — SQ BILLS SERVICE (sq_bills_service.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical core service singleton for table `sq_BILLS` in target schema `IMMBE2627`.
   - Provides paginated header fetching, series filtering (`TYPE`), count aggregation, and key lookups.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema isolated via `.schema('IMMBE2627')`.
   - Enforces fiscal year filter `VNO < 100000`.
   - Requires composite join keys `CNO / VNO / TYPE` to uniquely identify header records.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_BILLS` is Airbyte mirror, strictly read-only.
   - Use CountOption.exact for PostgREST pagination accuracy.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should server-side Postgres RPC views (`vwsq_`) be used for multi-series queries?
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/core/sq/sq_bills.dart';
import '../service_supabase.dart';

/// [SqBillsService] — Canonical Core Service Layer for `sq_BILLS` (Read-Only Airbyte Mirror).
class SqBillsService {
  static final SqBillsService _instance = SqBillsService._internal();
  factory SqBillsService() => _instance;
  SqBillsService._internal();

  final _db = SupabaseService();

  /// Fetches paginated bills header list filtered by series `type`, `partyName`, `quality`, and date range.
  Future<PaginatedResult<SqBillsModel>> getPaginatedBills({
    int offset = 0,
    int limit = 50,
    String? type,
    String? partyName,
    String? quality,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      // 1. Fetch exact total count
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO')
          .lt('VNO', 100000);

      if (type != null && type.isNotEmpty && type != 'All') {
        countQuery = countQuery.ilike('TYPE', type);
      }
      if (partyName != null && partyName.isNotEmpty && partyName != 'All') {
        countQuery = countQuery.ilike('code', '%$partyName%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        countQuery = countQuery.ilike('QUAL', '%$quality%');
      }
      if (startDate != null) {
        countQuery = countQuery.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        countQuery = countQuery.lte('DATE', endDate.toIso8601String());
      }

      final countRes = await countQuery.count(CountOption.exact);
      final int totalCount = countRes.count;

      // 2. Fetch paginated data
      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .lt('VNO', 100000);

      if (type != null && type.isNotEmpty && type != 'All') {
        fetchQuery = fetchQuery.ilike('TYPE', type);
      }
      if (partyName != null && partyName.isNotEmpty && partyName != 'All') {
        fetchQuery = fetchQuery.ilike('code', '%$partyName%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        fetchQuery = fetchQuery.ilike('QUAL', '%$quality%');
      }
      if (startDate != null) {
        fetchQuery = fetchQuery.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        fetchQuery = fetchQuery.lte('DATE', endDate.toIso8601String());
      }

      // Ordering
      switch (sortBy) {
        case 'DATE_ASC':
          fetchQuery = fetchQuery.order('DATE', ascending: true);
          break;
        case 'VNO_DESC':
          fetchQuery = fetchQuery.order('VNO', ascending: false);
          break;
        case 'VNO_ASC':
          fetchQuery = fetchQuery.order('VNO', ascending: true);
          break;
        case 'DATE_DESC':
        default:
          fetchQuery = fetchQuery.order('DATE', ascending: false).order('VNO', ascending: false);
          break;
      }

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>;

      final items = rawList.map((j) => SqBillsModel.fromJson(j as Map<String, dynamic>)).toList();

      return PaginatedResult(
        data: items,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e, stack) {
      debugPrint('Error in SqBillsService.getPaginatedBills: $e\n$stack');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit, error: e.toString());
    }
  }

  /// Fetches a single bill header by composite key (CNO, VNO, TYPE).
  Future<SqBillsModel?> getBillByKey({
    required int vno,
    required String type,
    int cno = 1,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('CNO', cno)
          .eq('VNO', vno)
          .eq('TYPE', type)
          .maybeSingle();

      if (response == null) return null;
      return SqBillsModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SqBillsService.getBillByKey: $e');
      return null;
    }
  }
}
