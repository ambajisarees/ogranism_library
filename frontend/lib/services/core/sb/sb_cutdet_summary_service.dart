import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/core/sb/sb_cutdet_summary.dart';
import '../service_supabase.dart';

/// [SbCutdetSummaryService] — Canonical Core Service Layer for `sb_cutdet_summary` (Cutting Batch Summaries).
class SbCutdetSummaryService {
  static final SbCutdetSummaryService _instance = SbCutdetSummaryService._internal();
  factory SbCutdetSummaryService() => _instance;
  SbCutdetSummaryService._internal();

  final _db = SupabaseService();

  /// Fetches paginated batch summaries from `sb_cutdet_summary`.
  Future<PaginatedResult<SbCutdetSummaryModel>> getPaginatedSummaries({
    int offset = 0,
    int limit = 50,
    String? mill,
    String? quality,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('MULTI_VNO');

      if (mill != null && mill.isNotEmpty && mill != 'All') {
        query = query.ilike('MILL', '%$mill%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        query = query.ilike('GREYQUAL', '%$quality%');
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.eq('sb_status', status);
      }
      if (startDate != null) {
        query = query.gte('CUTDATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('CUTDATE', endDate.toIso8601String());
      }

      final countRes = await query.count(CountOption.exact);
      final totalCount = countRes.count;

      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('*');

      if (mill != null && mill.isNotEmpty && mill != 'All') {
        fetchQuery = fetchQuery.ilike('MILL', '%$mill%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        fetchQuery = fetchQuery.ilike('GREYQUAL', '%$quality%');
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        fetchQuery = fetchQuery.eq('sb_status', status);
      }
      if (startDate != null) {
        fetchQuery = fetchQuery.gte('CUTDATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        fetchQuery = fetchQuery.lte('CUTDATE', endDate.toIso8601String());
      }

      if (sortBy == 'DATE_ASC') {
        fetchQuery = fetchQuery.order('CUTDATE', ascending: true);
      } else {
        fetchQuery = fetchQuery.order('CUTDATE', ascending: false).order('MULTI_VNO', ascending: false);
      }

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>;
      final data = rawList.map((j) => SbCutdetSummaryModel.fromJson(j as Map<String, dynamic>)).toList();

      return PaginatedResult(
        data: data,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error in SbCutdetSummaryService.getPaginatedSummaries: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetches a single batch summary by `MULTI_VNO`.
  Future<SbCutdetSummaryModel?> getSummaryByMultiVno({
    required int multiVno,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('*')
          .eq('MULTI_VNO', multiVno)
          .maybeSingle();

      if (response == null) return null;
      return SbCutdetSummaryModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SbCutdetSummaryService.getSummaryByMultiVno: $e');
      return null;
    }
  }

  /// Upserts (creates or updates) a cutting batch summary record in `sb_cutdet_summary`.
  Future<bool> upsertSummary({
    required SbCutdetSummaryModel summary,
  }) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .upsert(summary.toJson(), onConflict: 'MULTI_VNO');

      return true;
    } catch (e) {
      debugPrint('Error in SbCutdetSummaryService.upsertSummary: $e');
      return false;
    }
  }
}
