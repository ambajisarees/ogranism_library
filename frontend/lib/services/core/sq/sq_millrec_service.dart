import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/core/sq/sq_millrec.dart';
import '../service_supabase.dart';

/// [SqMillrecService] — Canonical Core Service Layer for `sq_MILLREC` (Mill Process Receipts).
class SqMillrecService {
  static final SqMillrecService _instance = SqMillrecService._internal();
  factory SqMillrecService() => _instance;
  SqMillrecService._internal();

  final _db = SupabaseService();

  /// Fetches paginated mill receipt records from `sq_MILLREC` for FY 26-27 (`VNO < 100000`).
  Future<PaginatedResult<SqMillrecModel>> getPaginatedReceipts({
    int offset = 0,
    int limit = 50,
    String? mill,
    String? quality,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sq_MILLREC')
          .select('RECCARDNO')
          .lt('VNO', 100000);

      if (mill != null && mill.isNotEmpty && mill != 'All') {
        query = query.ilike('MILL_CODE', '%$mill%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        query = query.ilike('GREYQUAL', '%$quality%');
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
          .from('sq_MILLREC')
          .select('*')
          .lt('VNO', 100000);

      if (mill != null && mill.isNotEmpty && mill != 'All') {
        fetchQuery = fetchQuery.ilike('MILL_CODE', '%$mill%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        fetchQuery = fetchQuery.ilike('GREYQUAL', '%$quality%');
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
        fetchQuery = fetchQuery.order('CUTDATE', ascending: false).order('RECCARDNO', ascending: false);
      }

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>;
      final data = rawList.map((j) => SqMillrecModel.fromJson(j as Map<String, dynamic>)).toList();

      return PaginatedResult(
        data: data,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error in SqMillrecService.getPaginatedReceipts: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetches a single mill receipt by `RECCARDNO`.
  Future<SqMillrecModel?> getReceiptByRecCardNo({
    required int recCardNo,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MILLREC')
          .select('*')
          .eq('RECCARDNO', recCardNo)
          .maybeSingle();

      if (response == null) return null;
      return SqMillrecModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SqMillrecService.getReceiptByRecCardNo: $e');
      return null;
    }
  }

  /// Fetches receipts linked to a sent grey lot card (`CARDNO`).
  Future<List<SqMillrecModel>> getReceiptsByCardNo({
    required int cardNo,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MILLREC')
          .select('*')
          .eq('CARDNO', cardNo)
          .order('RECCARDNO', ascending: true);

      final List<dynamic> rawList = response as List<dynamic>;
      return rawList.map((j) => SqMillrecModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error in SqMillrecService.getReceiptsByCardNo: $e');
      return [];
    }
  }
}
