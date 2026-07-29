import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/purchase_bills/purchase_bill_category.dart';
import '../../models/production/purchase_bills/model_purchase_bill_header.dart';
import '../../models/production/purchase_bills/model_purchase_bill_item.dart';
import '../core/service_supabase.dart';

/// [PurchaseBillService] - Service layer managing Supabase operations for all 10 Purchase Bill Categories.
/// Target Schema: `IMMBE2627`
class PurchaseBillService {
  static final PurchaseBillService _instance = PurchaseBillService._internal();
  factory PurchaseBillService() => _instance;
  PurchaseBillService._internal();

  final _db = SupabaseService();

  /// Fetches exact live count of headers from `sq_BILLS` for each of the 10 Purchase Bill categories.
  Future<Map<PurchaseBillCategory, int>> getCategoryHeaderCounts() async {
    try {
      final Map<PurchaseBillCategory, int> categoryCounts = {};

      await Future.wait(PurchaseBillCategory.values.map((cat) async {
        final res = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLS')
            .select('VNO')
            .ilike('TYPE', cat.seriesCode)
            .lt('VNO', 100000)
            .count(CountOption.exact);

        categoryCounts[cat] = res.count;
      }));

      return categoryCounts;
    } catch (e) {
      debugPrint('Error in getCategoryHeaderCounts: $e');
      final Map<PurchaseBillCategory, int> fallback = {};
      for (final cat in PurchaseBillCategory.values) {
        fallback[cat] = 0;
      }
      return fallback;
    }
  }

  /// PHASE 1: Fast Header Fetch (<100ms response time).
  /// Downloads ONLY 50 paginated header records from `sq_BILLS` for Pane 1.
  Future<PaginatedResult<PurchaseBillHeaderModel>> getPurchaseBillHeaders({
    int offset = 0,
    int limit = 50,
    PurchaseBillCategory category = PurchaseBillCategory.grey,
    String? searchQuery,
    String? filterSupplier,
    String? filterQuality,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      final seriesCode = category.seriesCode;

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

      // 2. Fetch Paginated 50 Header records
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

      // Apply Order By directly in Postgres (Column names are 'DATE', 'VNO', 'finalamt')
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
      final billsResponse = await dataQuery.range(offset, endRange);

      final List<Map<String, dynamic>> rawBills = List<Map<String, dynamic>>.from(billsResponse as List);

      // Parse Header Models (without line items attached yet)
      List<PurchaseBillHeaderModel> bills = rawBills.map((json) {
        return PurchaseBillHeaderModel.fromJson(json, items: []);
      }).toList();

      // Apply Search Query in memory if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        bills = bills.where((b) {
          return b.weaverBillNo.toLowerCase().contains(q) ||
              b.vno.toString().contains(q) ||
              b.partyName.toLowerCase().contains(q) ||
              b.brokerCode.toLowerCase().contains(q) ||
              b.primaryQuality.toLowerCase().contains(q);
        }).toList();
      }

      return PaginatedResult(
        data: bills,
        totalCount: totalHeaderCount,
        offset: offset,
        limit: limit,
      );
    } catch (e, stack) {
      debugPrint('Error in getPurchaseBillHeaders: $e\n$stack');
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
  /// Fetches line items ONLY for a single selected bill (`CNO = cno AND VNO = vno AND TYPE = type`).
  Future<List<PurchaseBillItemModel>> getPurchaseBillLineItems({
    required int cno,
    required int vno,
    required String type,
    required LineItemSourceTable sourceTable,
  }) async {
    try {
      final String tableName = sourceTable == LineItemSourceTable.pinvtrn
          ? 'sq_PINVTRN'
          : (sourceTable == LineItemSourceTable.millrec ? 'sq_MILLREC' : 'sq_BILLDET');

      final itemsResponse = await _db.client
          .schema('IMMBE2627')
          .from(tableName)
          .select('*')
          .eq('CNO', cno)
          .eq('VNO', vno)
          .eq('TYPE', type);

      final List<dynamic> rawItems = itemsResponse as List;
      final items = rawItems
          .map((json) => PurchaseBillItemModel.fromJson(json, sourceTable))
          .toList();

      return items;
    } catch (e, stack) {
      debugPrint('Error in getPurchaseBillLineItems: $e\n$stack');
      return [];
    }
  }

  /// Fetches unique Supplier / Party names from `sq_BILLS.code` for filter dropdowns.
  Future<List<String>> getUniqueSuppliers({PurchaseBillCategory category = PurchaseBillCategory.grey}) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('code')
          .eq('TYPE', category.seriesCode)
          .lt('VNO', 100000)
          .limit(100);

      final Set<String> suppliers = {};
      for (final r in response as List) {
        final code = r['code'] as String?;
        if (code != null && code.trim().isNotEmpty) {
          suppliers.add(code.trim());
        }
      }
      final list = suppliers.toList();
      list.sort();
      return list;
    } catch (e) {
      debugPrint('Error getUniqueSuppliers: $e');
      return [];
    }
  }

  /// Fetches unique Base Qualities for filter dropdowns.
  Future<List<String>> getUniqueQualities({PurchaseBillCategory category = PurchaseBillCategory.grey}) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('QUAL')
          .eq('TYPE', category.seriesCode)
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
      debugPrint('Error getUniqueQualities: $e');
      return [];
    }
  }
}
