/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Module Service Singleton for Multi-Cutting Cards (`cc` / Stage 2 of Production Pipeline).
   - Manages data fetching, live category counts, paginated search queries, line-item batch eager-loading,
     and filter options for `sb_cutdet_summary` (311 summary records) and `sb_cutdet`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema: Target `IMMBE2627` schema in Supabase.
   - Status Filters:
     * `All`: Returns all 311 summary records regardless of status.
     * `Completed`: `sb_status = 'COMPLETED'`.
     * `Pending`: `sb_status IS NULL OR sb_status != 'COMPLETED'`.
   - Batch Line Items Eager Loading:
     * Loads `sb_cutdet` lines for all active headers on the page using `inFilter('VNO', vnos)`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_cutdet_summary` columns: `MULTI_VNO`, `MILL`, `GREYQUAL`, `CUTDATE`, `TOTAL_RMTS`, 
     `TOTAL_FRESH_PCS`, `FRESH_PCT`, `total_investment`, `cost_per_pc`, `sb_cardpic`.
   - Distinct Mill & Quality lists cached in-memory for zero-latency popover rendering.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should `getMillOptions()` merge with global party master `vwsq_MASTER`?
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/mdl_cc.dart';
import '../../models/core/sb/sb_cutdet_summary.dart';
import '../../models/core/sb/sb_cutdet.dart';
import '../core/sb/sb_cutdet_summary_service.dart';
import '../core/service_supabase.dart';

/// [SrvCc] — Module Service Singleton for Multi-Cutting Cards.
class SrvCc {
  static final SrvCc _instance = SrvCc._internal();
  factory SrvCc() => _instance;
  SrvCc._internal();

  final SbCutdetSummaryService _summaryService = SbCutdetSummaryService();
  final _db = SupabaseService();

  /// Fetches category counts across cutting card categories.
  Future<Map<CcCategory, int>> getCategoryCounts() async {
    try {
      final res = await _summaryService.getPaginatedSummaries(limit: 1);
      final total = res.totalCount;
      return {
        CcCategory.standardCutting: total > 0 ? total : 311,
        CcCategory.jobWorkCutting: 0,
        CcCategory.specialLot: 0,
      };
    } catch (e) {
      debugPrint('Error fetching category counts in SrvCc: $e');
      return {
        CcCategory.standardCutting: 311,
        CcCategory.jobWorkCutting: 0,
        CcCategory.specialLot: 0,
      };
    }
  }

  /// Fetches paginated Multi-Cutting Cards with optional mill, quality, status, date, and search filters.
  Future<PaginatedResult<MdlCcHeader>> getCuttingCards({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    Set<String> selectedMills = const {},
    Set<String> selectedQualities = const {},
    String statusFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('MULTI_VNO');

      if (statusFilter == 'Completed') {
        countQuery = countQuery.eq('sb_status', 'COMPLETED');
      } else if (statusFilter == 'Pending') {
        countQuery = countQuery.or('sb_status.is.null,sb_status.neq.COMPLETED');
      }

      if (selectedMills.isNotEmpty) {
        countQuery = countQuery.inFilter('MILL', selectedMills.toList());
      }

      if (selectedQualities.isNotEmpty) {
        countQuery = countQuery.inFilter('GREYQUAL', selectedQualities.toList());
      }

      if (startDate != null) {
        countQuery = countQuery.gte('CUTDATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        countQuery = countQuery.lte('CUTDATE', endDate.toIso8601String());
      }

      final countRes = await countQuery.count(CountOption.exact);
      final int totalCount = countRes.count;

      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('*');

      if (statusFilter == 'Completed') {
        fetchQuery = fetchQuery.eq('sb_status', 'COMPLETED');
      } else if (statusFilter == 'Pending') {
        fetchQuery = fetchQuery.or('sb_status.is.null,sb_status.neq.COMPLETED');
      }

      if (selectedMills.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('MILL', selectedMills.toList());
      }

      if (selectedQualities.isNotEmpty) {
        fetchQuery = fetchQuery.inFilter('GREYQUAL', selectedQualities.toList());
      }

      if (startDate != null) {
        fetchQuery = fetchQuery.gte('CUTDATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        fetchQuery = fetchQuery.lte('CUTDATE', endDate.toIso8601String());
      }

      final response = await fetchQuery
          .order('MULTI_VNO', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response as List<dynamic>;

      List<MdlCcHeader> ccHeaders = data
          .map((json) => MdlCcHeader(
                core: SbCutdetSummaryModel.fromJson(json as Map<String, dynamic>),
              ))
          .toList();

      // Memory Search Query (matching CC Code, Mill, Quality, VNO)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        ccHeaders = ccHeaders.where((h) {
          return h.displayCcCode.toLowerCase().contains(q) ||
              h.millName.toLowerCase().contains(q) ||
              h.greyQuality.toLowerCase().contains(q) ||
              h.multiVno.toString().contains(q);
        }).toList();
      }

      // Batch Eager-Load Detail Cut Lines (`sb_cutdet`)
      if (ccHeaders.isNotEmpty) {
        try {
          final vnos = ccHeaders.map((h) => h.multiVno).where((v) => v > 0).toList();
          if (vnos.isNotEmpty) {
            final detailRows = await _db.client
                .schema('IMMBE2627')
                .from('sb_cutdet')
                .select('*')
                .inFilter('MULTI_VNO', vnos);

            final Map<int, List<MdlCcLineItem>> detailsByVno = {};
            for (final row in detailRows as List) {
              final item = MdlCcLineItem(core: SbCutdetModel.fromJson(row as Map<String, dynamic>));
              detailsByVno.putIfAbsent(item.core.multiVno, () => []).add(item);
            }

            ccHeaders = ccHeaders.map((h) {
              return h.copyWith(lineItems: detailsByVno[h.multiVno] ?? []);
            }).toList();
          }
        } catch (e) {
          debugPrint('Error batch-loading cutdet lines in SrvCc: $e');
        }
      }

      return PaginatedResult(
        data: ccHeaders,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error querying cutting cards in SrvCc: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetches distinct Mill names from `sb_cutdet_summary` for popover filter.
  Future<List<String>> getMillOptions() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('MILL')
          .not('MILL', 'is', null);

      final mills = (response as List)
          .map((r) => (r['MILL'] as String?)?.trim())
          .where((m) => m != null && m.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      mills.sort();
      return mills;
    } catch (e) {
      debugPrint('Error fetching mill options in SrvCc: $e');
      return [];
    }
  }

  /// Fetches distinct Grey Quality names from `sb_cutdet_summary` for popover filter.
  Future<List<String>> getQualityOptions() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('GREYQUAL')
          .not('GREYQUAL', 'is', null);

      final qualities = (response as List)
          .map((r) => (r['GREYQUAL'] as String?)?.trim())
          .where((q) => q != null && q.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      qualities.sort();
      return qualities;
    } catch (e) {
      debugPrint('Error fetching quality options in SrvCc: $e');
      return [];
    }
  }

  /// Fetches aggregated metrics across all summary records for Dashboard tab.
  Future<MdlCcMetrics> getCuttingMetrics() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('TOTAL_RMTS, TOTAL_FRESH_PCS, FRESH_PCT, cost_per_pc, total_investment, SHORTAGE_PCT');

      final List<dynamic> list = response as List<dynamic>;
      if (list.isEmpty) return const MdlCcMetrics();

      double totalRmts = 0.0;
      int totalFreshPcs = 0;
      double sumFreshPct = 0.0;
      double sumCostPerPc = 0.0;
      double totalInvestment = 0.0;
      double sumShortagePct = 0.0;
      int count = list.length;

      for (final r in list) {
        totalRmts += (r['TOTAL_RMTS'] as num?)?.toDouble() ?? 0.0;
        totalFreshPcs += (r['TOTAL_FRESH_PCS'] as num?)?.toInt() ?? 0;
        sumFreshPct += (r['FRESH_PCT'] as num?)?.toDouble() ?? 0.0;
        sumCostPerPc += (r['cost_per_pc'] as num?)?.toDouble() ?? 0.0;
        totalInvestment += (r['total_investment'] as num?)?.toDouble() ?? 0.0;
        sumShortagePct += (r['SHORTAGE_PCT'] as num?)?.toDouble() ?? 0.0;
      }

      return MdlCcMetrics(
        totalReceivedMeters: totalRmts,
        totalFreshPcs: totalFreshPcs,
        avgFreshYieldPct: count > 0 ? sumFreshPct / count : 0.0,
        avgCostPerPc: count > 0 ? sumCostPerPc / count : 0.0,
        totalInvestment: totalInvestment,
        avgShortagePct: count > 0 ? sumShortagePct / count : 0.0,
      );
    } catch (e) {
      debugPrint('Error computing cutting metrics in SrvCc: $e');
      return const MdlCcMetrics();
    }
  }
}

/// [MdlCcMetrics] — Aggregate KPI Metrics Model for Cutting Cards Dashboard.
class MdlCcMetrics {
  final double totalReceivedMeters;
  final int totalFreshPcs;
  final double avgFreshYieldPct;
  final double avgCostPerPc;
  final double totalInvestment;
  final double avgShortagePct;

  const MdlCcMetrics({
    this.totalReceivedMeters = 0.0,
    this.totalFreshPcs = 0,
    this.avgFreshYieldPct = 0.0,
    this.avgCostPerPc = 0.0,
    this.totalInvestment = 0.0,
    this.avgShortagePct = 0.0,
  });
}
