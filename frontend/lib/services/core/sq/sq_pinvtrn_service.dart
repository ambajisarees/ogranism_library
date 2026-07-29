import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/core/sq/sq_pinvtrn.dart';
import '../service_supabase.dart';

/// [SqPinvtrnService] — Canonical Core Service Layer for `sq_PINVTRN` (Grey Stock Dispatches & Sent Lot Cards).
class SqPinvtrnService {
  static final SqPinvtrnService _instance = SqPinvtrnService._internal();
  factory SqPinvtrnService() => _instance;
  SqPinvtrnService._internal();

  final _db = SupabaseService();

  /// Fetches paginated grey stock dispatches from `sq_PINVTRN` for FY 26-27 (`CARDNO < 100000`).
  Future<PaginatedResult<SqPinvtrnModel>> getPaginatedDispatches({
    int offset = 0,
    int limit = 50,
    String? mill,
    String? weaver,
    String? quality,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sq_PINVTRN')
          .select('CARDNO')
          .lt('CARDNO', 100000);

      if (mill != null && mill.isNotEmpty && mill != 'All') {
        query = query.ilike('MILL', '%$mill%');
      }
      if (weaver != null && weaver.isNotEmpty && weaver != 'All') {
        query = query.ilike('WEAVER', '%$weaver%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        query = query.ilike('QUAL', '%$quality%');
      }
      if (startDate != null) {
        query = query.gte('DDATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('DDATE', endDate.toIso8601String());
      }

      final countRes = await query.count(CountOption.exact);
      final totalCount = countRes.count;

      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_PINVTRN')
          .select('*')
          .lt('CARDNO', 100000);

      if (mill != null && mill.isNotEmpty && mill != 'All') {
        fetchQuery = fetchQuery.ilike('MILL', '%$mill%');
      }
      if (weaver != null && weaver.isNotEmpty && weaver != 'All') {
        fetchQuery = fetchQuery.ilike('WEAVER', '%$weaver%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        fetchQuery = fetchQuery.ilike('QUAL', '%$quality%');
      }
      if (startDate != null) {
        fetchQuery = fetchQuery.gte('DDATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        fetchQuery = fetchQuery.lte('DDATE', endDate.toIso8601String());
      }

      if (sortBy == 'DATE_ASC') {
        fetchQuery = fetchQuery.order('DDATE', ascending: true);
      } else {
        fetchQuery = fetchQuery.order('DDATE', ascending: false).order('CARDNO', ascending: false);
      }

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>;
      final data = rawList.map((j) => SqPinvtrnModel.fromJson(j as Map<String, dynamic>)).toList();

      return PaginatedResult(
        data: data,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error in SqPinvtrnService.getPaginatedDispatches: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetches a single dispatch record by `CARDNO`.
  Future<SqPinvtrnModel?> getDispatchByCardNo({
    required int cardNo,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_PINVTRN')
          .select('*')
          .eq('CARDNO', cardNo)
          .maybeSingle();

      if (response == null) return null;
      return SqPinvtrnModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SqPinvtrnService.getDispatchByCardNo: $e');
      return null;
    }
  }
}
