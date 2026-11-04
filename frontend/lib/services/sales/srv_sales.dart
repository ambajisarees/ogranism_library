/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES MODULE SERVICE (srv_sales.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Module Service Singleton for Sales Invoices (`sales` / `so`).
   - Fetches and aggregates sales data from `sq_BILLS` (Series `S1`) and `sq_BILLDET`.
   - Organizes invoices into Master Customer groups with Haste breakdowns,
     enforcing sorting by highest amount first.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Schemas/Tables: `IMMBE2627.sq_BILLS` (Header), `IMMBE2627.sq_BILLDET` (Line Items).
   - Filter criteria: `TYPE = 'S1'`.
   - Default Sorting: `BILLAMT` Descending (highest amount first).
   - Master Customer Grouping: Groups bills by `billerCode` (`code`), computes
     subtotals for Gross Amount, Bill Amount, Bales (`PARCELS`), and pieces,
     ordered by total customer sales volume descending.
   - Haste Rule:
     * With haste: party = haste, agent/biller = code (biller party).
     * Without haste: party = code, agent/biller = BCODE (agent).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_BILLS` is an Airbyte read-only mirror.
   - Total S1 records across the database is ~17,900.
   - Supabase PostgREST default limit is 1,000 per page; pagination is supported via `.range(offset, offset + limit - 1)`.
   - Safe parsing with defaults (`?? 0.0`, `?? 0`, `?? ''`) prevents null-safety exceptions.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Is series S2/S3 (Sales Returns) needed for net calculations? Currently focusing strictly on S1 as requested.
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/core/sq/sq_bills.dart';
import '../../models/core/sq/sq_billdet.dart';
import '../../models/sales/mdl_sales.dart';
import '../core/service_supabase.dart';
import '../core/sq/sq_billdet_service.dart';

/// Summary statistical metrics for the Sales module dashboard.
class SalesSummaryMetrics {
  final double totalRevenue;
  final double totalGross;
  final int totalInvoices;
  final int totalBales;
  final int totalPieces;
  final double totalMeters;
  final int totalMasterCustomers;
  final int totalHasteDeliveries;

  const SalesSummaryMetrics({
    this.totalRevenue = 0.0,
    this.totalGross = 0.0,
    this.totalInvoices = 0,
    this.totalBales = 0,
    this.totalPieces = 0,
    this.totalMeters = 0.0,
    this.totalMasterCustomers = 0,
    this.totalHasteDeliveries = 0,
  });
}

/// [SrvSales] — Module Service Singleton for Sales & Invoices.
class SrvSales {
  static final SrvSales _instance = SrvSales._internal();
  factory SrvSales() => _instance;
  SrvSales._internal();

  final _db = SupabaseService();
  final _billdetService = SqBilldetService();

  /// Fetches sales invoices with sorting by highest amount first.
  Future<PaginatedResult<MdlSalesBill>> getSalesInvoices({
    int offset = 0,
    int limit = 100,
    String? searchQuery,
    String? customerFilter,
    String? hasteFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool onlyWithHaste = false,
  }) async {
    try {
      // 1. Count query (Enforce current FY active bills: VNO < 100000)
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO')
          .eq('TYPE', 'S1')
          .lt('VNO', 100000);

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        countQuery = countQuery.or(
          'code.ilike.%$q%,haste.ilike.%$q%,BCODE.ilike.%$q%,BILL.ilike.%$q%',
        );
      }

      if (customerFilter != null && customerFilter.isNotEmpty && customerFilter != 'All') {
        countQuery = countQuery.eq('code', customerFilter);
      }

      if (hasteFilter != null && hasteFilter.isNotEmpty && hasteFilter != 'All') {
        countQuery = countQuery.eq('haste', hasteFilter);
      }

      if (onlyWithHaste) {
        countQuery = countQuery.not('haste', 'is', null).neq('haste', '');
      }

      if (startDate != null) {
        countQuery = countQuery.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        countQuery = countQuery.lte('DATE', endDate.toIso8601String());
      }

      final countRes = await countQuery.count(CountOption.exact);
      final int totalCount = countRes.count;

      // 2. Data query sorted by BILLAMT descending (highest amount first)
      dynamic fetchQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'S1')
          .lt('VNO', 100000);

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        fetchQuery = fetchQuery.or(
          'code.ilike.%$q%,haste.ilike.%$q%,BCODE.ilike.%$q%,BILL.ilike.%$q%',
        );
      }

      if (customerFilter != null && customerFilter.isNotEmpty && customerFilter != 'All') {
        fetchQuery = fetchQuery.eq('code', customerFilter);
      }

      if (hasteFilter != null && hasteFilter.isNotEmpty && hasteFilter != 'All') {
        fetchQuery = fetchQuery.eq('haste', hasteFilter);
      }

      if (onlyWithHaste) {
        fetchQuery = fetchQuery.not('haste', 'is', null).neq('haste', '');
      }

      if (startDate != null) {
        fetchQuery = fetchQuery.gte('DATE', startDate.toIso8601String());
      }
      if (endDate != null) {
        fetchQuery = fetchQuery.lte('DATE', endDate.toIso8601String());
      }

      // Default primary order: highest bill amount first
      fetchQuery = fetchQuery
          .order('BILLAMT', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await fetchQuery;
      final List<dynamic> rawList = response as List<dynamic>;

      final bills = rawList.map((j) {
        final sqBill = SqBillsModel.fromJson(j as Map<String, dynamic>);
        return MdlSalesBill.fromSqBills(sqBill);
      }).toList();

      return PaginatedResult(
        data: bills,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e, stack) {
      debugPrint('Error in SrvSales.getSalesInvoices: $e\n$stack');
      return PaginatedResult(
        data: [],
        totalCount: 0,
        offset: offset,
        limit: limit,
        error: e.toString(),
      );
    }
  }

  List<MdlSalesBill>? _cachedBills;
  DateTime? _cacheTimestamp;
  static const Duration _cacheTtl = Duration(minutes: 5);

  /// Clears the in-memory cache to force a fresh fetch from Supabase.
  void clearCache() {
    _cachedBills = null;
    _cacheTimestamp = null;
  }

  /// Fetches ALL sales invoices matching filters (active FY S1 invoices with VNO < 100,000)
  /// using high-concurrency parallel chunked queries, cached in memory for sub-millisecond filtering.
  Future<List<MdlSalesBill>> getAllSalesInvoices({
    String? searchQuery,
    String? customerFilter,
    String? hasteFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool onlyWithHaste = false,
    bool forceRefresh = false,
    void Function(int loaded, int total)? onProgress,
  }) async {
    try {
      final bool isCacheValid = _cachedBills != null &&
          _cachedBills!.isNotEmpty &&
          _cacheTimestamp != null &&
          DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;

      // If cached, valid TTL, and no forced refresh, filter in memory instantly (0ms latency)
      if (!forceRefresh && isCacheValid) {
        return _filterBills(
          _cachedBills!,
          searchQuery: searchQuery,
          customerFilter: customerFilter,
          hasteFilter: hasteFilter,
          startDate: startDate,
          endDate: endDate,
          onlyWithHaste: onlyWithHaste,
        );
      }

      // 1. Get exact total count for active current FY bills (VNO < 100000)
      dynamic countQuery = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO')
          .eq('TYPE', 'S1')
          .lt('VNO', 100000);

      final countRes = await countQuery.count(CountOption.exact);
      final int totalCount = countRes.count;

      if (totalCount == 0) return [];

      const int chunkSize = 1000;
      final int numChunks = (totalCount / chunkSize).ceil();
      final List<MdlSalesBill> allBills = [];

      // Controlled concurrency: fetch in batches of 4 parallel requests to prevent socket exhaustion
      const int batchConcurrency = 4;
      for (int i = 0; i < numChunks; i += batchConcurrency) {
        final int end = (i + batchConcurrency < numChunks) ? i + batchConcurrency : numChunks;
        final List<Future<List<MdlSalesBill>>> batchFutures = [];

        for (int j = i; j < end; j++) {
          final int offset = j * chunkSize;
          batchFutures.add(() async {
            dynamic query = _db.client
                .schema('IMMBE2627')
                .from('sq_BILLS')
                .select(
                  'CNO,VNO,TYPE,BILL,DATE,code,BCODE,cCODE,haste,PARCELS,grossamt,BILLAMT,finalamt,TOTPCS,TOTMTS,TRANSPORT,RRNO,RRDATE,EWB_NO,paid,QUAL',
                )
                .eq('TYPE', 'S1')
                .lt('VNO', 100000)
                .order('DATE', ascending: false)
                .order('VNO', ascending: false)
                .range(offset, offset + chunkSize - 1);

            final response = await query;
            final List<dynamic> rawList = response as List<dynamic>;

            return rawList.map((j) {
              final sqBill = SqBillsModel.fromJson(j as Map<String, dynamic>);
              return MdlSalesBill.fromSqBills(sqBill);
            }).toList();
          }());
        }

        final batchResults = await Future.wait(batchFutures);
        for (final chunk in batchResults) {
          allBills.addAll(chunk);
        }
        if (onProgress != null) {
          onProgress(allBills.length, totalCount);
        }
      }

      // STRICTLY SORT LATEST FIRST (DATE desc, VNO desc)
      allBills.sort((a, b) {
        final dateComp = (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970));
        if (dateComp != 0) return dateComp;
        return b.vno.compareTo(a.vno);
      });

      // Cache raw full dataset in memory with fresh timestamp
      _cachedBills = allBills;
      _cacheTimestamp = DateTime.now();

      return _filterBills(
        allBills,
        searchQuery: searchQuery,
        customerFilter: customerFilter,
        hasteFilter: hasteFilter,
        startDate: startDate,
        endDate: endDate,
        onlyWithHaste: onlyWithHaste,
      );
    } catch (e, stack) {
      debugPrint('Error in SrvSales.getAllSalesInvoices: $e\n$stack');
      rethrow;
    }
  }

  /// In-memory filter pipeline for instant zero-latency searches.
  List<MdlSalesBill> _filterBills(
    List<MdlSalesBill> source, {
    String? searchQuery,
    String? customerFilter,
    String? hasteFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool onlyWithHaste = false,
  }) {
    final q = searchQuery?.trim().toLowerCase();
    return source.where((b) {
      if (onlyWithHaste && !b.hasHaste) return false;
      if (customerFilter != null && customerFilter != 'All' && b.billerCode != customerFilter) {
        return false;
      }
      if (hasteFilter != null && hasteFilter != 'All' && b.haste != hasteFilter) {
        return false;
      }
      if (startDate != null && b.date != null && b.date!.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && b.date != null && b.date!.isAfter(endDate)) {
        return false;
      }
      if (q != null && q.isNotEmpty) {
        final match = b.billerCode.toLowerCase().contains(q) ||
            b.haste.toLowerCase().contains(q) ||
            b.brokerName.toLowerCase().contains(q) ||
            b.billNo.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  /// Fetches all active FY invoices and aggregates them into a 2-level hierarchy:
  /// Level 1: Master Customer (sorted by total bill amount descending)
  /// Level 2: Haste Subgroups (sorted by total bill amount descending)
  /// Level 3: Individual Bills (strictly sorted LATEST FIRST: DATE desc, VNO desc)
  Future<List<MdlCustomerSalesGroup>> getCustomerSalesGroups({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool onlyWithHaste = false,
    bool forceRefresh = false,
    void Function(int loaded, int total)? onProgress,
  }) async {
    try {
      final bills = await getAllSalesInvoices(
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
        onlyWithHaste: onlyWithHaste,
        forceRefresh: forceRefresh,
        onProgress: onProgress,
      );

      // 1. Group by Master Customer (`billerCode`)
      final Map<String, List<MdlSalesBill>> customerMap = {};
      for (final bill in bills) {
        final key = bill.billerCode.isNotEmpty ? bill.billerCode : 'UNKNOWN CUSTOMER';
        customerMap.putIfAbsent(key, () => []).add(bill);
      }

      // 2. Inside each Master Customer, subgroup by Haste
      final List<MdlCustomerSalesGroup> customerGroups = customerMap.entries.map((cEntry) {
        final custBills = cEntry.value;
        final Map<String, List<MdlSalesBill>> hasteMap = {};

        for (final b in custBills) {
          // Key by haste name or empty for direct
          final hKey = b.hasHaste ? b.haste : '';
          hasteMap.putIfAbsent(hKey, () => []).add(b);
        }

        final List<MdlHasteSubgroup> hasteSubgroups = hasteMap.entries.map((hEntry) {
          final isDirect = hEntry.key.isEmpty;
          final hasteName = isDirect ? 'Direct Customer Dispatch (No Haste)' : hEntry.key;
          final hBills = List<MdlSalesBill>.from(hEntry.value);

          // ALWAYS SORT LATEST FIRST, NOT SCATTERED (DATE desc, VNO desc)
          hBills.sort((a, b) {
            final dateComp = (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970));
            if (dateComp != 0) return dateComp;
            return b.vno.compareTo(a.vno);
          });

          return MdlHasteSubgroup(
            hasteName: hasteName,
            isDirect: isDirect,
            bills: hBills,
          );
        }).toList();

        // Sort haste subgroups by highest bill amount first
        hasteSubgroups.sort((a, b) => b.totalBillAmt.compareTo(a.totalBillAmt));

        return MdlCustomerSalesGroup(
          customerName: cEntry.key,
          hasteSubgroups: hasteSubgroups,
        );
      }).toList();

      // Sort Master Customer groups by total sales volume descending (highest amount first)
      customerGroups.sort((a, b) => b.totalBillAmt.compareTo(a.totalBillAmt));

      return customerGroups;
    } catch (e, stack) {
      debugPrint('Error in SrvSales.getCustomerSalesGroups: $e\n$stack');
      rethrow;
    }
  }

  /// Calculates summary metrics across the current invoices dataset.
  SalesSummaryMetrics calculateMetrics(List<MdlSalesBill> bills) {
    double totalRevenue = 0.0;
    double totalGross = 0.0;
    int totalBales = 0;
    int totalPieces = 0;
    double totalMeters = 0.0;
    final Set<String> customers = {};
    int totalHasteDeliveries = 0;

    for (final b in bills) {
      totalRevenue += b.billAmount;
      totalGross += b.grossAmount;
      totalBales += b.bales;
      totalPieces += b.totalPieces;
      totalMeters += b.totalMeters;
      if (b.billerCode.isNotEmpty) customers.add(b.billerCode);
      if (b.hasHaste) totalHasteDeliveries++;
    }

    return SalesSummaryMetrics(
      totalRevenue: totalRevenue,
      totalGross: totalGross,
      totalInvoices: bills.length,
      totalBales: totalBales,
      totalPieces: totalPieces,
      totalMeters: totalMeters,
      totalMasterCustomers: customers.length,
      totalHasteDeliveries: totalHasteDeliveries,
    );
  }

  /// Eager-loads line items for a specific sales invoice using `sq_BILLDET`.
  Future<List<SqBilldetModel>> getLineItemsForBill(MdlSalesBill bill) async {
    return _billdetService.getLineItemsForBill(
      vno: bill.vno,
      type: bill.type,
      cno: bill.cno,
    );
  }
}
