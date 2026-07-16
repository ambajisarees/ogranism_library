import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_supabase.dart';
import '../models/model_party.dart';
import '../models/model_quality.dart';

/// ============================================================
/// PHASE 1 — Master Data Services (DEBUGGED)
/// ============================================================
///
/// Registry-specific service for Parties and Qualities.
/// Implements efficient pagination for high-volume masters.
/// ============================================================

class MastersService {
  final _db = SupabaseService();

  /// Fetches a paginated list of Parties from sq_MASTER.
  /// Uses explicit PostgrestResponse casting for reliable count access.
  Future<PaginatedResult<PartyModel>> getParties({
    required int offset,
    int limit = 50,
    String? searchTerm,
    int? accountType,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('vwsq_MASTER')
          .select('*');

      // Search filters
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('NAME.ilike.%$searchTerm%,code.ilike.%$searchTerm%');
      }

      if (accountType != null) {
        query = query.eq('ATYPE', accountType);
      }

      // Execute query
      final PostgrestResponse response = await query
          .order('NAME', ascending: true)
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final List<dynamic> dataList = response.data as List<dynamic>;
      final int totalCount = response.count ?? 0;

      return PaginatedResult(
        data: dataList.map((j) => PartyModel.fromJson(j)).toList(),
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      return PaginatedResult(
        data: [],
        totalCount: 0,
        offset: offset,
        limit: limit,
        error: _db.handleDbError(e),
      );
    }
  }

  /// Fetches the Product Catalogue from vwsq_qual.
  /// Categorized by Sales, Grey, or Others.
  Future<PaginatedResult<QualityModel>> getQualities({
    int offset = 0,
    int limit = 100,
    String? searchTerm,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('vwsq_qual')
          .select('*');

      // 1. SEARCH TERM
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('NAME.ilike.%$searchTerm%,qcode.ilike.%$searchTerm%');
      }

      final PostgrestResponse response = await query
          .order('NAME', ascending: true)
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final List<dynamic> dataList = response.data as List<dynamic>;
      final int totalCount = response.count ?? 0;

      return PaginatedResult(
        data: dataList.map((j) => QualityModel.fromJson(j)).toList(),
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      return PaginatedResult(
        data: [],
        totalCount: 0,
        offset: offset,
        limit: limit,
        error: _db.handleDbError(e),
      );
    }
  }
}
