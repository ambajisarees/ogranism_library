import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/purchase_orders/purchase_order_category.dart';
import '../../models/production/purchase_orders/model_purchase_order_header.dart';
import '../../models/production/purchase_orders/model_purchase_order_item.dart';
import '../core/service_supabase.dart';

/// [PurchaseOrderService] - Service layer managing Supabase operations for all 5 Purchase Order Categories.
/// Target Schema: `IMMBE2627`
class PurchaseOrderService {
  static final PurchaseOrderService _instance = PurchaseOrderService._internal();
  factory PurchaseOrderService() => _instance;
  PurchaseOrderService._internal();

  final _db = SupabaseService();

  /// Fetches exact live count of headers from `sq_BILLS` for each of the 5 Purchase Order categories.
  Future<Map<PurchaseOrderCategory, int>> getCategoryHeaderCounts() async {
    try {
      final Map<PurchaseOrderCategory, int> categoryCounts = {};

      await Future.wait(PurchaseOrderCategory.values.map((cat) async {
        final code = cat.seriesCode;
        if (code == null) {
          categoryCounts[cat] = 0;
          return;
        }

        final res = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLS')
            .select('VNO')
            .ilike('TYPE', code)
            .lt('VNO', 100000)
            .count(CountOption.exact);

        categoryCounts[cat] = res.count;
      }));

      return categoryCounts;
    } catch (e) {
      debugPrint('Error in getCategoryHeaderCounts (Purchase Orders): $e');
      final Map<PurchaseOrderCategory, int> fallback = {};
      for (final cat in PurchaseOrderCategory.values) {
        fallback[cat] = 0;
      }
      return fallback;
    }
  }

  /// PHASE 1: Fast Header Fetch (<100ms response time).
  /// Downloads paginated header records from `sq_BILLS` for Pane 1.
  Future<PaginatedResult<PurchaseOrderHeaderModel>> getPurchaseOrderHeaders({
    int offset = 0,
    int limit = 50,
    PurchaseOrderCategory category = PurchaseOrderCategory.finish,
    String? searchQuery,
    String? filterSupplier,
    String? filterQuality,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      final seriesCode = category.seriesCode;
      if (seriesCode == null) {
        // Grey module or empty category
        return PaginatedResult(
          data: [],
          totalCount: 0,
          offset: offset,
          limit: limit,
        );
      }

      // 1. Fetch exact total count from sq_BILLS for TYPE = seriesCode and VNO < 100000 (FY 26-27)
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO')
          .ilike('TYPE', seriesCode)
          .lt('VNO', 100000);

      if (filterSupplier != null && filterSupplier.isNotEmpty && filterSupplier != 'All') {
        query = query.ilike('code', '%$filterSupplier%');
      }
      if (filterQuality != null && filterQuality.isNotEmpty && filterQuality != 'All') {
        query = query.ilike('QUAL', '%$filterQuality%');
      }
      if (startDate != null) {
        query = query.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('DATE', endDate.toIso8601String());
      }

      final countRes = await query.count(CountOption.exact);
      final totalHeaderCount = countRes.count;

      // 2. Fetch Paginated Header records
      dynamic dataQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .ilike('TYPE', seriesCode)
          .lt('VNO', 100000);

      if (filterSupplier != null && filterSupplier.isNotEmpty && filterSupplier != 'All') {
        dataQuery = dataQuery.ilike('code', '%$filterSupplier%');
      }
      if (filterQuality != null && filterQuality.isNotEmpty && filterQuality != 'All') {
        dataQuery = dataQuery.ilike('QUAL', '%$filterQuality%');
      }
      if (startDate != null) {
        dataQuery = dataQuery.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        dataQuery = dataQuery.lte('DATE', endDate.toIso8601String());
      }

      // Apply Order By
      if (sortBy == 'DATE_DESC') {
        dataQuery = dataQuery.order('DATE', ascending: false);
      } else if (sortBy == 'DATE_ASC') {
        dataQuery = dataQuery.order('DATE', ascending: true);
      } else if (sortBy == 'BILL_DESC') {
        dataQuery = dataQuery.order('VNO', ascending: false);
      } else if (sortBy == 'BILL_ASC') {
        dataQuery = dataQuery.order('VNO', ascending: true);
      } else if (sortBy == 'AMT_DESC') {
        dataQuery = dataQuery.order('finalamt', ascending: false);
      } else if (sortBy == 'AMT_ASC') {
        dataQuery = dataQuery.order('finalamt', ascending: true);
      } else {
        dataQuery = dataQuery.order('DATE', ascending: false);
      }

      // Apply range pagination
      final endRange = offset + limit - 1;
      final response = await dataQuery.range(offset, endRange);

      final List<Map<String, dynamic>> rawData = List<Map<String, dynamic>>.from(response as List);

      // Parse Header Models
      List<PurchaseOrderHeaderModel> orders = rawData.map((json) {
        return PurchaseOrderHeaderModel.fromJson(json, items: []);
      }).toList();

      // Apply Search Query in memory if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        orders = orders.where((b) {
          return b.orderNo.toLowerCase().contains(q) ||
              b.vno.toString().contains(q) ||
              b.partyName.toLowerCase().contains(q) ||
              b.brokerCode.toLowerCase().contains(q) ||
              b.primaryQuality.toLowerCase().contains(q);
        }).toList();
      }

      return PaginatedResult(
        data: orders,
        totalCount: totalHeaderCount,
        offset: offset,
        limit: limit,
      );
    } catch (e, stack) {
      debugPrint('Error in getPurchaseOrderHeaders: $e\n$stack');
      return PaginatedResult(
        data: [],
        totalCount: 0,
        offset: offset,
        limit: limit,
        error: e.toString(),
      );
    }
  }

  /// PHASE 2: On-Demand Line Item Fetch (~50ms response time).
  /// Fetches line items ONLY for a single selected PO (`CNO = cno AND VNO = vno AND TYPE = type`).
  Future<List<PurchaseOrderItemModel>> getPurchaseOrderLineItems({
    required int cno,
    required int vno,
    required String type,
  }) async {
    try {
      final itemsResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('CNO', cno)
          .eq('VNO', vno)
          .eq('TYPE', type);

      final List<dynamic> rawItems = itemsResponse as List;
      final items = rawItems
          .map((json) => PurchaseOrderItemModel.fromJson(json, POLineItemSourceTable.billdet))
          .toList();

      return items;
    } catch (e, stack) {
      debugPrint('Error in getPurchaseOrderLineItems: $e\n$stack');
      return [];
    }
  }

  /// Fetches unique Supplier / Party names from `sq_BILLS.code` for filter dropdowns.
  Future<List<String>> getUniqueSuppliers({PurchaseOrderCategory category = PurchaseOrderCategory.finish}) async {
    try {
      final code = category.seriesCode;
      if (code == null) return [];

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('code')
          .eq('TYPE', code)
          .lt('VNO', 100000)
          .limit(100);

      final Set<String> suppliers = {};
      for (final r in response as List) {
        final c = r['code'] as String?;
        if (c != null && c.trim().isNotEmpty) {
          suppliers.add(c.trim());
        }
      }
      final list = suppliers.toList();
      list.sort();
      return list;
    } catch (e) {
      debugPrint('Error getUniqueSuppliers (PO): $e');
      return [];
    }
  }

  /// Fetches unique Qualities for filter dropdowns.
  Future<List<String>> getUniqueQualities({PurchaseOrderCategory category = PurchaseOrderCategory.finish}) async {
    try {
      final code = category.seriesCode;
      if (code == null) return [];

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('QUAL')
          .eq('TYPE', code)
          .lt('VNO', 100000)
          .limit(100);

      final Set<String> qualities = {};
      for (final r in response as List) {
        final qual = r['QUAL'] as String?;
        if (qual != null && qual.trim().isNotEmpty) {
          qualities.add(qual.trim());
        }
      }
      final list = qualities.toList();
      list.sort();
      return list;
    } catch (e) {
      debugPrint('Error getUniqueQualities (PO): $e');
      return [];
    }
  }
}
