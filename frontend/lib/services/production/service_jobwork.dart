import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/model_jobwork.dart';
import '../core/service_supabase.dart';


/// [JobWorkService] — Manages queries and services for Stitching Dispatches (O5)
/// and Stitching Receives (O6) from the `sq_BILLS` and `sq_BILLDET` tables.
class JobWorkService {
  static final JobWorkService _instance = JobWorkService._internal();
  factory JobWorkService() => _instance;
  JobWorkService._internal();

  final _db = SupabaseService();

  /// Fetch Stitching Dispatches (O5) registry headers.
  Future<PaginatedResult<JobDispatchModel>> getJobDispatches({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'O5')
          .lt('VNO', 100000); // Enforce active FY 26-27 records

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('code.ilike.%$searchTerm%,CHALLAN.ilike.%$searchTerm%');
      }

      final response = await query
          .order('VNO', ascending: false)
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final data = (response.data as List)
          .map((json) => JobDispatchModel.fromJson(json))
          .toList();

      return PaginatedResult(
        data: data,
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      print('JobWorkService.getJobDispatches error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit, error: e.toString());
    }
  }

  /// Fetch Stitching Receives (O6) registry headers.
  Future<PaginatedResult<JobReceiveModel>> getJobReceives({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'O6')
          .lt('VNO', 100000); // Enforce active FY 26-27 records

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('code.ilike.%$searchTerm%,CHALLAN.ilike.%$searchTerm%');
      }

      final response = await query
          .order('VNO', ascending: false)
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final data = (response.data as List)
          .map((json) => JobReceiveModel.fromJson(json))
          .toList();

      return PaginatedResult(
        data: data,
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      print('JobWorkService.getJobReceives error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit, error: e.toString());
    }
  }

  /// Fetch detail lines for a specific voucher from `sq_BILLDET` (works for both O5 and O6).
  Future<List<JobWorkDetailLineModel>> getJobWorkLines(int vno, String type) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('VNO', vno)
          .eq('TYPE', type)
          .order('SRNO', ascending: true);

      return (response as List)
          .map((json) => JobWorkDetailLineModel.fromJson(json))
          .toList();
    } catch (e) {
      print('JobWorkService.getJobWorkLines (VNO: $vno, TYPE: $type) error: $e');
      return [];
    }
  }

  /// Fetch dispatches (O5) that are linked to a specific cutting card.
  /// (Using our linkage design: `orderno = CUTCARDNO` and `ORDTYPE = 'O3'`).
  Future<List<JobWorkDetailLineModel>> getDispatchesForCuttingCard(int cutCardNo) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('TYPE', 'O5')
          .eq('orderno', cutCardNo)
          .eq('ORDTYPE', 'O3')
          .order('VNO', ascending: false);

      return (response as List)
          .map((json) => JobWorkDetailLineModel.fromJson(json))
          .toList();
    } catch (e) {
      print('JobWorkService.getDispatchesForCuttingCard (Card: $cutCardNo) error: $e');
      return [];
    }
  }

  /// Fetch receives (O6) that are linked to a specific parent dispatch (O5).
  /// (Using our linkage design: `STAGE_VNO = parentVno` and `STAGE_TYPE = 'O5'`).
  Future<List<JobWorkDetailLineModel>> getReceivesForDispatch(int parentVno) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('TYPE', 'O6')
          .eq('STAGE_VNO', parentVno)
          .eq('STAGE_TYPE', 'O5')
          .order('VNO', ascending: false);

      return (response as List)
          .map((json) => JobWorkDetailLineModel.fromJson(json))
          .toList();
    } catch (e) {
      print('JobWorkService.getReceivesForDispatch (Parent VNO: $parentVno) error: $e');
      return [];
    }
  }
}
