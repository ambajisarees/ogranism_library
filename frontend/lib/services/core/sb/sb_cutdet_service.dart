import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/core/sb/sb_cutdet.dart';
import '../service_supabase.dart';

/// [SbCutdetService] — Canonical Core Service Layer for `sb_cutdet` (Active Saree Cutting Cards).
class SbCutdetService {
  static final SbCutdetService _instance = SbCutdetService._internal();
  factory SbCutdetService() => _instance;
  SbCutdetService._internal();

  final _db = SupabaseService();

  /// Fetches paginated cutting cards from `sb_cutdet`.
  Future<PaginatedResult<SbCutdetModel>> getPaginatedCuttingCards({
    int offset = 0,
    int limit = 50,
    int? multiVno,
    String? mill,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .select('CUTCARDNO');

      if (multiVno != null && multiVno > 0) {
        query = query.eq('MULTI_VNO', multiVno);
      }
      if (mill != null && mill.isNotEmpty && mill != 'All') {
        query = query.ilike('MILL', '%$mill%');
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
          .from('sb_cutdet')
          .select('*');

      if (multiVno != null && multiVno > 0) {
        fetchQuery = fetchQuery.eq('MULTI_VNO', multiVno);
      }
      if (mill != null && mill.isNotEmpty && mill != 'All') {
        fetchQuery = fetchQuery.ilike('MILL', '%$mill%');
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
        fetchQuery = fetchQuery.order('CUTDATE', ascending: false).order('CUTCARDNO', ascending: false);
      }

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>;
      final data = rawList.map((j) => SbCutdetModel.fromJson(j as Map<String, dynamic>)).toList();

      return PaginatedResult(
        data: data,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error in SbCutdetService.getPaginatedCuttingCards: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetches all cutting cards belonging to a parent batch (`MULTI_VNO`).
  Future<List<SbCutdetModel>> getCardsByMultiVno({
    required int multiVno,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .select('*')
          .eq('MULTI_VNO', multiVno)
          .order('CUTCARDNO', ascending: true);

      final List<dynamic> rawList = response as List<dynamic>;
      return rawList.map((j) => SbCutdetModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error in SbCutdetService.getCardsByMultiVno: $e');
      return [];
    }
  }

  /// Inserts a clean batch of cutting cards into `sb_cutdet`.
  Future<bool> insertCuttingBatchCards({
    required List<SbCutdetModel> cards,
  }) async {
    try {
      if (cards.isEmpty) return false;
      final payload = cards.map((c) => c.toJson()).toList();

      await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .insert(payload);

      return true;
    } catch (e) {
      debugPrint('Error in SbCutdetService.insertCuttingBatchCards: $e');
      return false;
    }
  }
}
