import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/model_jobwork.dart';
import '../core/service_supabase.dart';

/// [OrdersService] — Singleton service managing Finish (O13) and Lace (O14) Purchase Orders.
class OrdersService {
  static final OrdersService _instance = OrdersService._internal();
  factory OrdersService() => _instance;
  OrdersService._internal();

  final _db = SupabaseService();

  /// Fetch Purchase Orders (O13/O14) registry headers with paging, filters, and custom sorting.
  Future<PaginatedResult<JobReceiveModel>> getPurchaseOrders({
    required String type, // 'O13' or 'O14'
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
            .eq('TYPE', type)
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
          .eq('TYPE', type)
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

      final List<dynamic> list = response.data as List<dynamic>;
      final int totalCount = response.count;

      // Map rows and resolve fabric lists in parallel
      final mappedList = list.map((json) => JobReceiveModel.fromJson(json)).toList();
      final resolvedList = await Future.wait(mappedList.map((header) async {
        final lineFabrics = await _fetchLineFabrics(header.vno, type);
        return header.copyWith(itemReceived: lineFabrics);
      }));

      return PaginatedResult(
        data: resolvedList,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('OrdersService.getPurchaseOrders error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Private helper to fetch and list unique fabrics in detail lines for a header.
  Future<String> _fetchLineFabrics(int vno, String type) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('qual')
          .eq('VNO', vno)
          .eq('TYPE', type);

      final List<dynamic> list = response as List<dynamic>;
      final qualities = list
          .map((row) => row['qual']?.toString().trim() ?? '')
          .where((qual) => qual.isNotEmpty)
          .toSet()
          .toList();

      if (qualities.isEmpty) return 'No Items';
      return qualities.join(', ');
    } catch (_) {
      return 'No Items';
    }
  }

  /// Fetch detail lines for a selected purchase order.
  Future<List<JobWorkDetailLineModel>> getPurchaseOrderLines(int vno, String type) async {
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
      debugPrint('OrdersService.getPurchaseOrderLines error: $e');
      return [];
    }
  }

  /// Fetch unique vendor names (Khata) who have records for this type.
  Future<List<String>> getUniqueVendors({required String type}) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('code')
          .eq('TYPE', type)
          .lt('VNO', 100000);

      final List<dynamic> list = response as List<dynamic>;
      return list
          .map((row) => row['code']?.toString().trim() ?? '')
          .where((code) => code.isNotEmpty && code != 'null')
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      debugPrint('OrdersService.getUniqueVendors error: $e');
      return [];
    }
  }

  /// Fetch unique quality fabrics that exist in order lines.
  Future<List<String>> getUniqueFabrics({required String type}) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('qual')
          .eq('TYPE', type)
          .lt('VNO', 100000);

      final List<dynamic> list = response as List<dynamic>;
      return list
          .map((row) => row['qual']?.toString().trim() ?? '')
          .where((qual) => qual.isNotEmpty && qual != 'null')
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      debugPrint('OrdersService.getUniqueFabrics error: $e');
      return [];
    }
  }
}
