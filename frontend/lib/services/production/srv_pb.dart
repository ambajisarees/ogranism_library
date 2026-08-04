/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE BILLS MODULE SERVICE (srv_pb.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Service Singleton for Purchase Bills (`pb` / Purchase Invoices).
   - Manages data fetching, live category counts, paginated queries, line-item eager loading,
     and filter options for `sq_BILLS` (headers) and line item detail tables.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema: Target `IMMBE2627` schema in Supabase.
   - Header Table: `sq_BILLS` filtered by `TYPE = category.seriesCode` and `VNO < 100000` (FY 26-27).
   - Line Item Source Table Routing:
     * `PbCategory.grey` (`P1`): `sq_PINVTRN`
     * `PbCategory.jobWork` (`P4`): `sq_MILLREC`
     * All other submodules (`P2`, `P3`, `P5`–`P10`): `sq_BILLDET`
   - Composite Join Keys: `CNO = header.CNO AND VNO = header.VNO AND TYPE = header.TYPE`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Read-only Airbyte mirror tables (`sq_BILLS`, `sq_BILLDET`, `sq_PINVTRN`, `sq_MILLREC`).
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/mdl_pb.dart';
import '../../models/core/sq/sq_bills.dart';
import '../core/service_supabase.dart';

/// [SrvPb] — Module Service Singleton for Purchase Bills.
class SrvPb {
  static final SrvPb _instance = SrvPb._internal();
  factory SrvPb() => _instance;
  SrvPb._internal();

  final _db = SupabaseService();

  /// Fetches exact counts across all 10 Purchase Bill categories.
  Future<Map<PbCategory, int>> getCategoryCounts() async {
    try {
      final Map<PbCategory, int> categoryCounts = {};

      await Future.wait(PbCategory.values.map((cat) async {
        final res = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLS')
            .select('VNO')
            .eq('TYPE', cat.seriesCode)
            .lt('VNO', 100000)
            .count(CountOption.exact);

        categoryCounts[cat] = res.count;
      }));

      return categoryCounts;
    } catch (e) {
      debugPrint('Error fetching category counts in SrvPb: $e');
      final Map<PbCategory, int> fallback = {};
      for (final cat in PbCategory.values) {
        fallback[cat] = 0;
      }
      return fallback;
    }
  }

  /// Fetches paginated Purchase Bills with eager-loaded line items and optional filters.
  Future<PaginatedResult<MdlPbHeader>> getPurchaseBills({
    int limit = 50,
    int offset = 0,
    PbCategory category = PbCategory.grey,
    String? searchQuery,
    Set<String> selectedParties = const {},
    Set<String> selectedQualities = const {},
    String statusFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final seriesCode = category.seriesCode;

      // 1. Total Header Count Query
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO')
          .eq('TYPE', seriesCode)
          .lt('VNO', 100000);

      if (statusFilter == 'Completed') {
        countQuery = countQuery.or('CLOSED.eq.Y,CLOSED.eq.true');
      } else if (statusFilter == 'Pending') {
        countQuery = countQuery.or('CLOSED.is.null,CLOSED.eq.,CLOSED.eq.N');
      }

      if (selectedParties.isNotEmpty) {
        countQuery = countQuery.inFilter('code', selectedParties.toList());
      }

      if (selectedQualities.isNotEmpty) {
        countQuery = countQuery.inFilter('QUAL', selectedQualities.toList());
      }

      if (startDate != null) {
        countQuery = countQuery.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        countQuery = countQuery.lte('DATE', endDate.toIso8601String());
      }

      final countRes = await countQuery.count(CountOption.exact);
      final int totalCount = countRes.count;

      // 2. Fetch Paginated Header Records
      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', seriesCode)
          .lt('VNO', 100000);

      if (statusFilter == 'Completed') {
        fetchQuery = fetchQuery.or('CLOSED.eq.Y,CLOSED.eq.true');
      } else if (statusFilter == 'Pending') {
        fetchQuery = fetchQuery.or('CLOSED.is.null,CLOSED.eq.,CLOSED.eq.N');
      }

      if (selectedParties.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('code', selectedParties.toList());
      }

      if (selectedQualities.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('QUAL', selectedQualities.toList());
      }

      if (startDate != null) {
        fetchQuery = fetchQuery.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        fetchQuery = fetchQuery.lte('DATE', endDate.toIso8601String());
      }

      final response = await fetchQuery
          .order('DATE', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response as List<dynamic>;

      List<MdlPbHeader> pbHeaders = data
          .map((json) => MdlPbHeader(
                core: SqBillsModel.fromJson(json as Map<String, dynamic>),
              ))
          .toList();

      // In-Memory Search Query
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        pbHeaders = pbHeaders.where((h) {
          return h.displayBillNo.toLowerCase().contains(q) ||
              h.partyName.toLowerCase().contains(q) ||
              h.primaryQuality.toLowerCase().contains(q) ||
              h.weaverBillNo.toLowerCase().contains(q) ||
              h.vno.toString().contains(q);
        }).toList();
      }

      // 3. Batch Eager-Load Detail Line Items using Table Routing
      if (pbHeaders.isNotEmpty) {
        try {
          final String lineTableName = category.lineItemTableName;
          final vnos = pbHeaders.map((h) => h.vno).where((v) => v > 0).toList();

          if (vnos.isNotEmpty) {
            final detailRows = await _db.client
                .schema('IMMBE2627')
                .from(lineTableName)
                .select('*')
                .eq('TYPE', seriesCode)
                .inFilter('VNO', vnos);

            final Map<int, List<MdlPbLineItem>> detailsByVno = {};
            for (final row in detailRows as List) {
              final json = row as Map<String, dynamic>;
              final vno = (json['VNO'] as num?)?.toInt() ?? 0;
              final item = MdlPbLineItem.fromJson(json, lineTableName);
              detailsByVno.putIfAbsent(vno, () => []).add(item);
            }

            pbHeaders = pbHeaders.map((h) {
              return h.copyWith(lineItems: detailsByVno[h.vno] ?? []);
            }).toList();
          }
        } catch (e) {
          debugPrint('Error batch-loading purchase bill detail lines in SrvPb: $e');
        }
      }

      return PaginatedResult(
        data: pbHeaders,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error querying purchase bills in SrvPb: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Alias for getPurchaseBills
  Future<PaginatedResult<MdlPbHeader>> getBillsByCategory({
    int limit = 50,
    int offset = 0,
    PbCategory category = PbCategory.grey,
    String? searchQuery,
    Set<String> selectedParties = const {},
    Set<String> selectedQualities = const {},
    String statusFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      getPurchaseBills(
        limit: limit,
        offset: offset,
        category: category,
        searchQuery: searchQuery,
        selectedParties: selectedParties,
        selectedQualities: selectedQualities,
        statusFilter: statusFilter,
        startDate: startDate,
        endDate: endDate,
      );

  /// Alias for getPartyOptions
  Future<List<String>> getSupplierOptions({PbCategory category = PbCategory.grey}) =>
      getPartyOptions(category: category);

  /// Fetches unique Party / Supplier names for popover filter.
  Future<List<String>> getPartyOptions({PbCategory category = PbCategory.grey}) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('code')
          .eq('TYPE', category.seriesCode)
          .lt('VNO', 100000)
          .limit(100);

      final Set<String> parties = {};
      for (final r in response as List) {
        final code = r['code'] as String?;
        if (code != null && code.trim().isNotEmpty) {
          parties.add(code.trim());
        }
      }
      final list = parties.toList();
      list.sort();
      return list;
    } catch (e) {
      debugPrint('Error fetching party options in SrvPb: $e');
      return [];
    }
  }

  /// Fetches unique Quality names for popover filter.
  Future<List<String>> getQualityOptions({PbCategory category = PbCategory.grey}) async {
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
      debugPrint('Error fetching quality options in SrvPb: $e');
      return [];
    }
  }
}
