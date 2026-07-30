/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE ORDERS MODULE SERVICE (srv_po.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module-level service singleton for Purchase Orders (`po`).
   - Orchestrates PO queries by wrapping canonical core services `SqBillsService` and `SqBilldetService`.
   - Filters target schema `IMMBE2627.sq_BILLS` by PO voucher series (`O13`, `O14`, `O15`, `O16`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Encapsulates PO category counts across `Finish`, `Lace`, `Packing`, `Studio`, and `Grey`.
   - Maps raw `SqBillsModel` and `SqBilldetModel` instances into domain-ready `MdlPoHeader` and `MdlPoLineItem` models.
   - Enforces composite key lookups (`CNO = cno AND VNO = vno AND TYPE = type`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_BILLS` and `sq_BILLDET` are Airbyte-managed read-only mirrors.
   - All write transactions (creating/editing POs) will be delegated via Deno Edge Functions.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should unique supplier filtering query `sq_BILLS.code` or pull strictly from `vwsq_MASTER` with `ATYP = 2` (Suppliers)?
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../models/production/mdl_po.dart';
import '../../models/core/sq/sq_billdet.dart';
import '../core/sq/sq_bills_service.dart';
import '../core/sq/sq_billdet_service.dart';
import '../core/service_supabase.dart';

/// [SrvPo] — Module Service Singleton for Purchase Orders.
class SrvPo {
  static final SrvPo _instance = SrvPo._internal();
  factory SrvPo() => _instance;
  SrvPo._internal();

  final SqBillsService _billsService = SqBillsService();
  final SqBilldetService _billdetService = SqBilldetService();
  final _db = SupabaseService();

  /// Fetches header counts for all 5 PO categories from `sq_BILLS`.
  Future<Map<PoCategory, int>> getCategoryCounts() async {
    try {
      final Map<PoCategory, int> counts = {};

      await Future.wait(PoCategory.values.map((cat) async {
        final code = cat.seriesCode;
        if (code == null) {
          counts[cat] = 0;
          return;
        }

        final res = await _billsService.getPaginatedBills(
          offset: 0,
          limit: 1,
          type: code,
        );
        counts[cat] = res.totalCount;
      }));

      return counts;
    } catch (e) {
      debugPrint('Error in SrvPo.getCategoryCounts: $e');
      final Map<PoCategory, int> fallback = {};
      for (final cat in PoCategory.values) {
        fallback[cat] = 0;
      }
      return fallback;
    }
  }

  /// Fetches paginated PO headers adapted into domain `MdlPoHeader` instances.
  Future<PaginatedResult<MdlPoHeader>> getPurchaseOrders({
    int offset = 0,
    int limit = 50,
    PoCategory category = PoCategory.finish,
    String? searchQuery,
    Set<String>? selectedParties,
    Set<String>? selectedStatuses,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      final seriesCode = category.seriesCode;
      if (seriesCode == null) {
        // Grey raw fabric PO empty state
        return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
      }

      final coreResult = await _billsService.getPaginatedBills(
        offset: offset,
        limit: limit,
        type: seriesCode,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
      );

      List<MdlPoHeader> poHeaders = coreResult.data.map((b) => MdlPoHeader(core: b)).toList();

      // Memory Party filtering if selectedParties is provided
      if (selectedParties != null && selectedParties.isNotEmpty) {
        poHeaders = poHeaders.where((h) => selectedParties.contains(h.partyName)).toList();
      }

      // Memory Status filtering if selectedStatuses is provided
      if (selectedStatuses != null && selectedStatuses.isNotEmpty) {
        poHeaders = poHeaders.where((h) {
          final isPending = h.isPending;
          if (selectedStatuses.contains('Pending') && isPending) return true;
          if (selectedStatuses.contains('Completed') && !isPending) return true;
          if (selectedStatuses.contains('All')) return true;
          return false;
        }).toList();
      }

      // Memory search filtering if search query is passed
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        poHeaders = poHeaders.where((h) {
          return h.displayOrderNo.toLowerCase().contains(q) ||
              h.vno.toString().contains(q) ||
              h.partyName.toLowerCase().contains(q) ||
              h.quality.toLowerCase().contains(q) ||
              h.brokerName.toLowerCase().contains(q);
        }).toList();
      }

      // Batch eager-load line items for active page headers
      if (poHeaders.isNotEmpty) {
        try {
          final vnos = poHeaders.map((h) => h.vno).toList();
          final detailRows = await _db.client
              .schema('IMMBE2627')
              .from('sq_BILLDET')
              .select('*')
              .eq('TYPE', seriesCode)
              .inFilter('VNO', vnos);

          final Map<int, List<MdlPoLineItem>> detailsByVno = {};
          for (final row in detailRows as List) {
            final item = MdlPoLineItem(core: SqBilldetModel.fromJson(row as Map<String, dynamic>));
            detailsByVno.putIfAbsent(item.vno, () => []).add(item);
          }

          poHeaders = poHeaders.map((h) {
            return h.copyWith(lineItems: detailsByVno[h.vno] ?? []);
          }).toList();
        } catch (e) {
          debugPrint('Error batch-loading line items in SrvPo: $e');
        }
      }

      return PaginatedResult(
        data: poHeaders,
        totalCount: poHeaders.length < coreResult.totalCount && (selectedParties?.isNotEmpty == true || selectedStatuses?.isNotEmpty == true)
            ? poHeaders.length
            : coreResult.totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e, stack) {
      debugPrint('Error in SrvPo.getPurchaseOrders: $e\n$stack');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit, error: e.toString());
    }
  }

  /// Fetches detail line items for a specific PO header adapted into `MdlPoLineItem` domain models.
  Future<List<MdlPoLineItem>> getPurchaseOrderLineItems({
    required int vno,
    required String type,
    int cno = 4,
  }) async {
    try {
      final coreItems = await _billdetService.getLineItemsForBill(
        vno: vno,
        type: type,
        cno: cno,
      );

      return coreItems.map((item) => MdlPoLineItem(core: item)).toList();
    } catch (e, stack) {
      debugPrint('Error in SrvPo.getPurchaseOrderLineItems: $e\n$stack');
      return [];
    }
  }

  /// Fetches distinct party/supplier names for filter dropdowns.
  Future<List<String>> getPartyOptions({PoCategory category = PoCategory.finish}) async {
    try {
      final seriesCode = category.seriesCode;
      if (seriesCode == null) return [];

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('code')
          .eq('TYPE', seriesCode)
          .lt('VNO', 100000)
          .limit(100);

      final Set<String> parties = {};
      for (final row in response as List) {
        final code = row['code'] as String?;
        if (code != null && code.trim().isNotEmpty) {
          parties.add(code.trim());
        }
      }
      final list = parties.toList();
      list.sort();
      return list;
    } catch (e) {
      debugPrint('Error in SrvPo.getPartyOptions: $e');
      return [];
    }
  }

  /// Legacy alias for supplier options.
  Future<List<String>> getSupplierOptions({PoCategory category = PoCategory.finish}) => getPartyOptions(category: category);

  /// Fetches distinct quality names for filter dropdowns.
  Future<List<String>> getQualityOptions({PoCategory category = PoCategory.finish}) async {
    try {
      final seriesCode = category.seriesCode;
      if (seriesCode == null) return [];

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('QUAL')
          .eq('TYPE', seriesCode)
          .lt('VNO', 100000)
          .limit(100);

      final Set<String> qualities = {};
      for (final row in response as List) {
        final qual = row['QUAL'] as String?;
        if (qual != null && qual.trim().isNotEmpty) {
          qualities.add(qual.trim());
        }
      }
      final list = qualities.toList();
      list.sort();
      return list;
    } catch (e) {
      debugPrint('Error in SrvPo.getQualityOptions: $e');
      return [];
    }
  }
}
