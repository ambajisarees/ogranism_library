import 'package:flutter/foundation.dart';
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

  /// Fetch Stitching Dispatches (O5) registry headers with filters and sorting.
  Future<PaginatedResult<JobDispatchModel>> getJobDispatches({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
    String? filterKhata,
    String? filterFabric,
    String? sortBy = 'DATE_DESC',
  }) async {
    try {
      // 1. Handle fabric filter lookup via child table (sq_BILLDET)
      List<int>? vnoFilterList;
      if (filterFabric != null && filterFabric.isNotEmpty) {
        final linesResponse = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLDET')
            .select('VNO')
            .eq('TYPE', 'O5')
            .eq('qual', filterFabric);
        
        final List<dynamic> linesList = linesResponse as List<dynamic>;
        vnoFilterList = linesList.map((e) => (e['VNO'] as num).toInt()).toList();
        if (vnoFilterList.isEmpty) {
          return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
        }
      }

      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'O5')
          .lt('VNO', 100000); // Enforce active FY 26-27 records

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('code.ilike.%$searchTerm%,CHALLAN.ilike.%$searchTerm%');
      }

      if (filterKhata != null && filterKhata.isNotEmpty) {
        query = query.eq('code', filterKhata);
      }

      if (vnoFilterList != null) {
        query = query.inFilter('VNO', vnoFilterList);
      }

      // 2. Apply Custom Sorting
      if (sortBy == 'DATE_ASC') {
        query = query.order('DATE', ascending: true).order('VNO', ascending: true);
      } else if (sortBy == 'JOBNO_DESC') {
        query = query.order('VNO', ascending: false);
      } else if (sortBy == 'JOBNO_ASC') {
        query = query.order('VNO', ascending: true);
      } else {
        // Default: DATE_DESC
        query = query.order('DATE', ascending: false).order('VNO', ascending: false);
      }

      final response = await query
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      var data = (response.data as List)
          .map((json) => JobDispatchModel.fromJson(json))
          .toList();

      // Fetch qualities for the dispatches currently on the page to resolve "item dispatched"
      final vnos = data.map((d) => d.vno).toList();
      if (vnos.isNotEmpty) {
        final linesResponse = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLDET')
            .select('VNO, qual')
            .eq('TYPE', 'O5')
            .inFilter('VNO', vnos);
        
        final Map<int, List<String>> vnoQualities = {};
        for (var line in linesResponse as List) {
          final v = (line['VNO'] as num).toInt();
          final q = line['qual'] as String? ?? '';
          if (q.isNotEmpty) {
            vnoQualities.putIfAbsent(v, () => []).add(q);
          }
        }
        
        data = data.map((d) {
          final quals = vnoQualities[d.vno]?.toSet().toList() ?? [];
          return d.copyWith(itemDispatched: quals.join(', '));
        }).toList();
      }

      return PaginatedResult(
        data: data,
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('JobWorkService.getJobDispatches error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit, error: e.toString());
    }
  }

  /// Fetch Stitching Receives (O6) registry headers.
  /// Fetch Stitching Receives (O6) registry headers with filters and sorting.
  Future<PaginatedResult<JobReceiveModel>> getJobReceives({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
    String? filterKhata,
    String? filterFabric,
    String? sortBy = 'DATE_DESC',
  }) async {
    try {
      // 1. Handle fabric filter lookup via child table (sq_BILLDET)
      List<int>? vnoFilterList;
      if (filterFabric != null && filterFabric.isNotEmpty) {
        final linesResponse = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLDET')
            .select('VNO')
            .eq('TYPE', 'O6')
            .eq('qual', filterFabric);
        
        final List<dynamic> linesList = linesResponse as List<dynamic>;
        vnoFilterList = linesList.map((e) => (e['VNO'] as num).toInt()).toList();
        if (vnoFilterList.isEmpty) {
          return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
        }
      }

      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'O6')
          .lt('VNO', 100000); // Enforce active FY 26-27 records

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('code.ilike.%$searchTerm%,CHALLAN.ilike.%$searchTerm%');
      }

      if (filterKhata != null && filterKhata.isNotEmpty) {
        query = query.eq('code', filterKhata);
      }

      if (vnoFilterList != null) {
        query = query.inFilter('VNO', vnoFilterList);
      }

      // 2. Apply Custom Sorting
      if (sortBy == 'DATE_ASC') {
        query = query.order('DATE', ascending: true).order('VNO', ascending: true);
      } else if (sortBy == 'JOBNO_DESC') {
        query = query.order('VNO', ascending: false);
      } else if (sortBy == 'JOBNO_ASC') {
        query = query.order('VNO', ascending: true);
      } else {
        // Default: DATE_DESC
        query = query.order('DATE', ascending: false).order('VNO', ascending: false);
      }

      final response = await query
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      var data = (response.data as List)
          .map((json) => JobReceiveModel.fromJson(json))
          .toList();

      // Fetch qualities for the receives currently on the page to resolve "item received"
      final vnos = data.map((d) => d.vno).toList();
      if (vnos.isNotEmpty) {
        final linesResponse = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLDET')
            .select('VNO, qual')
            .eq('TYPE', 'O6')
            .inFilter('VNO', vnos);
        
        final Map<int, List<String>> vnoQualities = {};
        for (var line in linesResponse as List) {
          final v = (line['VNO'] as num).toInt();
          final q = line['qual'] as String? ?? '';
          if (q.isNotEmpty) {
            vnoQualities.putIfAbsent(v, () => []).add(q);
          }
        }
        
        data = data.map((d) {
          final quals = vnoQualities[d.vno]?.toSet().toList() ?? [];
          return d.copyWith(itemReceived: quals.join(', '));
        }).toList();
      }

      return PaginatedResult(
        data: data,
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('JobWorkService.getJobReceives error: $e');
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
      debugPrint('JobWorkService.getJobWorkLines (VNO: $vno, TYPE: $type) error: $e');
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
      debugPrint('JobWorkService.getDispatchesForCuttingCard (Card: $cutCardNo) error: $e');
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
      debugPrint('JobWorkService.getReceivesForDispatch (Parent VNO: $parentVno) error: $e');
      return [];
    }
  }

  /// Fetch all unique Tailors (Khatas) from sq_BILLS with TYPE = 'O5' or 'O6'
  Future<List<String>> getUniqueTailors({String type = 'O5'}) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('code')
          .eq('TYPE', type)
          .lt('VNO', 100000);
      
      final List<dynamic> list = response as List<dynamic>;
      final codes = list.map((e) => e['code'] as String? ?? '').where((e) => e.isNotEmpty).toSet().toList();
      codes.sort();
      return codes;
    } catch (e) {
      debugPrint('JobWorkService.getUniqueTailors error: $e');
      return [];
    }
  }

  /// Fetch all unique Fabrics (Qualities) from sq_BILLDET with TYPE = 'O5' or 'O6'
  Future<List<String>> getUniqueFabrics({String type = 'O5'}) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('qual')
          .eq('TYPE', type)
          .lt('VNO', 100000);
      
      final List<dynamic> list = response as List<dynamic>;
      final qualities = list.map((e) => e['qual'] as String? ?? 'N/A').where((e) => e != 'N/A' && e.isNotEmpty).toSet().toList();
      qualities.sort();
      return qualities;
    } catch (e) {
      debugPrint('JobWorkService.getUniqueFabrics error: $e');
      return [];
    }
  }
}
