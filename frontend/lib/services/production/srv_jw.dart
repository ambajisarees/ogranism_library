/*
================================================================================
LLM CONTEXT & QUERY SPACE — JOB WORK MODULE SERVICE (srv_jw.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Service Layer for Job Work Operations (`jw` / Stage 2 & 3 Production Pipeline).
   - Manages data access and filtering across Supabase tables `IMMBE2627.sq_BILLS` and `sq_BILLDET`.
   - Filters target schema by Job Work series codes (`O5` through `O12`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Default query strategy: `VNO < 100000` (FY 26-27 context).
   - Graceful Fallback: If 0 records are returned for a series (e.g., `O9`, `O10`, `O11`), 
     the service falls back to querying all historical records (`VNO >= 100000`) so historical 
     dispatches and receipts can be inspected seamlessly.
   - Header-Detail Join Contract: Always joins on `CNO = DETAIL.CNO AND VNO = DETAIL.VNO AND TYPE = DETAIL.TYPE`.
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../models/core/sq/sq_bills.dart';
import '../../models/core/sq/sq_billdet.dart';
import '../../models/production/mdl_jw.dart';
import '../core/service_supabase.dart';

/// [SrvJw] — Singleton Module Service Layer for Job Work Operations.
class SrvJw {
  static final SrvJw _instance = SrvJw._internal();
  factory SrvJw() => _instance;
  SrvJw._internal();

  final _db = SupabaseService();

  /// Fetches paginated Job Work header records for [category] with optional filters.
  Future<({List<MdlJwHeader> data, int totalCount})> getJobWorkHeaders({
    required JwCategory category,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    Set<String> selectedParties = const {},
    Set<String> selectedQualities = const {},
    String statusFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final seriesCode = category.seriesCode;

      // 1. Try fetching current FY records (VNO < 100000)
      var result = await _fetchHeadersQuery(
        seriesCode: seriesCode,
        forceFy2627: true,
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        selectedParties: selectedParties,
        selectedQualities: selectedQualities,
        statusFilter: statusFilter,
        startDate: startDate,
        endDate: endDate,
      );

      // 2. Fallback to historical records if current FY count is 0
      if (result.totalCount == 0) {
        result = await _fetchHeadersQuery(
          seriesCode: seriesCode,
          forceFy2627: false,
          limit: limit,
          offset: offset,
          searchQuery: searchQuery,
          selectedParties: selectedParties,
          selectedQualities: selectedQualities,
          statusFilter: statusFilter,
          startDate: startDate,
          endDate: endDate,
        );
      }

      return result;
    } catch (e, stack) {
      debugPrint('Error in SrvJw.getJobWorkHeaders: $e\n$stack');
      return (data: <MdlJwHeader>[], totalCount: 0);
    }
  }

  Future<({List<MdlJwHeader> data, int totalCount})> _fetchHeadersQuery({
    required String seriesCode,
    required bool forceFy2627,
    required int limit,
    required int offset,
    String? searchQuery,
    Set<String> selectedParties = const {},
    Set<String> selectedQualities = const {},
    String statusFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO')
          .eq('TYPE', seriesCode);

      if (forceFy2627) {
        countQuery = countQuery.lt('VNO', 100000);
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

      final countRes = await countQuery.count();
      final int totalCount = countRes.count ?? 0;

      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', seriesCode);

      if (forceFy2627) {
        fetchQuery = fetchQuery.lt('VNO', 100000);
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

      fetchQuery = fetchQuery.order('DATE', ascending: false).order('VNO', ascending: false);

      final response = await fetchQuery.range(offset, offset + limit - 1);
      final rawList = response as List<dynamic>? ?? [];

      if (rawList.isEmpty) {
        return (data: <MdlJwHeader>[], totalCount: 0);
      }

      List<MdlJwHeader> headers = rawList
          .map((j) => MdlJwHeader(core: SqBillsModel.fromJson(j as Map<String, dynamic>)))
          .toList();

      // Memory status filter
      if (statusFilter == 'Pending') {
        headers = headers.where((h) => h.isPending).toList();
      } else if (statusFilter == 'Completed') {
        headers = headers.where((h) => h.isCompleted).toList();
      }

      // Memory search query filter
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        headers = headers.where((h) {
          return h.displayVoucherCode.toLowerCase().contains(q) ||
              h.partyName.toLowerCase().contains(q) ||
              h.quality.toLowerCase().contains(q) ||
              h.challanNo.toLowerCase().contains(q);
        }).toList();
      }

      // Attach Line Items
      final headersWithLines = await _attachLineItems(headers);
      return (data: headersWithLines, totalCount: totalCount);
    } catch (e) {
      debugPrint('Error in _fetchHeadersQuery: $e');
      return (data: <MdlJwHeader>[], totalCount: 0);
    }
  }

  Future<List<MdlJwHeader>> _attachLineItems(List<MdlJwHeader> headers) async {
    if (headers.isEmpty) return headers;

    final vnos = headers.map((h) => h.vno).toSet().toList();
    final types = headers.map((h) => h.type).toSet().toList();

    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .inFilter('TYPE', types)
          .inFilter('VNO', vnos);

      final rawLines = response as List<dynamic>? ?? [];
      final Map<String, List<MdlJwLineItem>> linesGroupedMap = {};

      for (final raw in rawLines) {
        final lineCore = SqBilldetModel.fromJson(raw as Map<String, dynamic>);
        final key = '${lineCore.type}_${lineCore.cno}_${lineCore.vno}';
        linesGroupedMap.putIfAbsent(key, () => []).add(MdlJwLineItem(core: lineCore));
      }

      return headers.map((h) {
        final lines = linesGroupedMap[h.id] ?? [];
        return h.copyWith(lineItems: lines);
      }).toList();
    } catch (e) {
      debugPrint('Error attaching line items in SrvJw: $e');
      return headers;
    }
  }

  /// Distinct Party / Job Worker Names (`code`) for active category
  Future<List<String>> getPartyOptions(JwCategory category) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('code')
          .eq('TYPE', category.seriesCode)
          .not('code', 'is', null)
          .limit(200);

      final list = response as List<dynamic>? ?? [];
      final set = <String>{};
      for (final row in list) {
        final name = (row['code'] as String?)?.trim();
        if (name != null && name.isNotEmpty) {
          set.add(name);
        }
      }
      final sorted = set.toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('Error in SrvJw.getPartyOptions: $e');
      return [];
    }
  }

  /// Distinct Fabric Quality Names (`QUAL`) for active category
  Future<List<String>> getQualityOptions(JwCategory category) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('QUAL')
          .eq('TYPE', category.seriesCode)
          .not('QUAL', 'is', null)
          .limit(200);

      final list = response as List<dynamic>? ?? [];
      final set = <String>{};
      for (final row in list) {
        final qual = (row['QUAL'] as String?)?.trim();
        if (qual != null && qual.isNotEmpty) {
          set.add(qual);
        }
      }
      final sorted = set.toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('Error in SrvJw.getQualityOptions: $e');
      return [];
    }
  }
}
