import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/core/sq/sq_bills.dart';
import '../service_supabase.dart';

/// [SqBillsService] — Canonical Core Service Layer for `sq_BILLS` (Invoices & Orders Header).
class SqBillsService {
  static final SqBillsService _instance = SqBillsService._internal();
  factory SqBillsService() => _instance;
  SqBillsService._internal();

  final _db = SupabaseService();

  /// Fetches paginated header records from `sq_BILLS` for FY 26-27 (`VNO < 100000`).
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
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO')
          .lt('VNO', 100000);

      if (type != null && type.isNotEmpty && type != 'All') {
        query = query.ilike('TYPE', type);
      }
      if (partyName != null && partyName.isNotEmpty && partyName != 'All') {
        query = query.ilike('code', '%$partyName%');
      }
      if (quality != null && quality.isNotEmpty && quality != 'All') {
        query = query.ilike('QUAL', '%$quality%');
      }
      if (startDate != null) {
        query = query.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('DATE', endDate.toIso8601String());
      }

      final countRes = await query.count(CountOption.exact);
      final totalCount = countRes.count;

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

      if (sortBy == 'DATE_ASC') {
        fetchQuery = fetchQuery.order('DATE', ascending: true);
      } else {
        fetchQuery = fetchQuery.order('DATE', ascending: false).order('VNO', ascending: false);
      }

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final List<dynamic> rawList = response as List<dynamic>;
      final data = rawList.map((j) => SqBillsModel.fromJson(j as Map<String, dynamic>)).toList();

      return PaginatedResult(
        data: data,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error in SqBillsService.getPaginatedBills: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetches a single header by voucher keys (`VNO`, `TYPE`, `CNO`).
  Future<SqBillsModel?> getBillByVno({
    required int vno,
    required String type,
    int cno = 4,
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
      debugPrint('Error in SqBillsService.getBillByVno: $e');
      return null;
    }
  }
}
