/*
================================================================================
LLM CONTEXT & QUERY SPACE — STOCK LEDGER SERVICE (srv_stock_ledger.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Service Singleton for Finished Saree Stock Ledger Operations (`sb_stock_ledger` & `vw_stock_summary`).
   - Manages data access for design SKU stock summaries, item-level stock aggregations, ledger event posting, and funnel conversions.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Schema isolated via `.schema('IMMBE2627')`.
   - `postStockEvent(...)` enforces idempotency using `idempotency_hash`.
   - `convertFunnelToFirmOrder(...)` posts synchronized `FUNNEL_CONVERTED` events promoting funnel pre-orders to firm sales orders.
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../models/masters/mdl_stock_ledger.dart';
import '../core/service_supabase.dart';

/// [SrvStockLedger] — Module Service Singleton for Stock Ledger Operations.
class SrvStockLedger {
  static final SrvStockLedger _instance = SrvStockLedger._internal();
  factory SrvStockLedger() => _instance;
  SrvStockLedger._internal();

  final _db = SupabaseService();

  /// Fetches stock summary for a specific Design SKU (`design_code`).
  Future<StockSummaryModel?> getStockSummaryByDesignCode(String designCode) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sbvw_stock_summary')
          .select('*')
          .eq('design_code', designCode)
          .maybeSingle();

      if (response == null) return null;
      return StockSummaryModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in SrvStockLedger.getStockSummaryByDesignCode: $e');
      return null;
    }
  }

  /// Fetches aggregated stock summary for an entire Item (`itemsrno`).
  Future<StockSummaryModel?> getStockSummaryByItemSrNo(String itemSrNo) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sbvw_stock_summary')
          .select('*')
          .eq('itemsrno', itemSrNo);

      final list = response as List<dynamic>? ?? [];
      if (list.isEmpty) return null;

      int stockIn = 0, stockOut = 0, currentStock = 0;
      int stockAtMill = 0, stockAtJob = 0;
      int flBooked = 0, flConverted = 0, flPending = 0;
      int soBooked = 0, soDelivered = 0, soPending = 0;
      int soOrderable = 0, flOrderable = 0;

      for (final row in list) {
        final m = StockSummaryModel.fromJson(row as Map<String, dynamic>);
        stockIn += m.stockIn;
        stockOut += m.stockOut;
        currentStock += m.currentStock;
        stockAtMill += m.stockAtMill;
        stockAtJob += m.stockAtJob;
        flBooked += m.flBooked;
        flConverted += m.flConverted;
        flPending += m.flPending;
        soBooked += m.soBooked;
        soDelivered += m.soDelivered;
        soPending += m.soPending;
        soOrderable += m.soOrderable;
        flOrderable += m.flOrderable;
      }

      return StockSummaryModel(
        designCode: 'ITEM-TOTAL',
        itemSrNo: itemSrNo,
        stockIn: stockIn,
        stockOut: stockOut,
        currentStock: currentStock,
        stockAtMill: stockAtMill,
        stockAtJob: stockAtJob,
        flBooked: flBooked,
        flConverted: flConverted,
        flPending: flPending,
        soBooked: soBooked,
        soDelivered: soDelivered,
        soPending: soPending,
        soOrderable: soOrderable,
        flOrderable: flOrderable,
      );
    } catch (e) {
      debugPrint('Error in SrvStockLedger.getStockSummaryByItemSrNo: $e');
      return null;
    }
  }

  /// Posts an immutable Stock Ledger Event into `sb_stock_ledger`.
  Future<bool> postStockEvent({
    required String designCode,
    required String itemSrNo,
    required StockEventType eventType,
    required DateTime eventDate,
    int qtyIn = 0,
    int qtyOut = 0,
    int qtyOrdered = 0,
    int qtyDelivered = 0,
    int qtyFunnel = 0,
    int qtyConverted = 0,
    int qtyAtMill = 0,
    int qtyAtJob = 0,
    String? refVno,
    int? refCno,
    String? refType,
  }) async {
    try {
      final rawKey = '${refType ?? ''}_${refCno ?? 0}_${refVno ?? ''}_${designCode}_${eventType.dbValue}_${eventDate.millisecondsSinceEpoch}';
      final idempotencyHash = 'hash_${rawKey.hashCode.abs()}';

      await _db.client.schema('IMMBE2627').from('sb_stock_ledger').upsert(
        {
          'idempotency_hash': idempotencyHash,
          'design_code': designCode,
          'itemsrno': itemSrNo,
          'event_type': eventType.dbValue,
          'event_date': eventDate.toIso8601String(),
          'qty_in': qtyIn,
          'qty_out': qtyOut,
          'qty_ordered': qtyOrdered,
          'qty_delivered': qtyDelivered,
          'qty_funnel': qtyFunnel,
          'qty_converted': qtyConverted,
          'qty_at_mill': qtyAtMill,
          'qty_at_job': qtyAtJob,
          'ref_vno': refVno,
          'ref_cno': refCno,
          'ref_type': refType,
        },
        onConflict: 'idempotency_hash',
      );

      return true;
    } catch (e) {
      debugPrint('Error in SrvStockLedger.postStockEvent: $e');
      return false;
    }
  }

  /// Converts a Sales Funnel Pre-Order into a Firm Sales Order.
  Future<bool> convertFunnelToFirmOrder({
    required String designCode,
    required String itemSrNo,
    required int convertQty,
    required String salesOrderVno,
    int? refCno,
  }) async {
    return postStockEvent(
      designCode: designCode,
      itemSrNo: itemSrNo,
      eventType: StockEventType.funnelConverted,
      eventDate: DateTime.now(),
      qtyConverted: convertQty,
      qtyOrdered: convertQty,
      refVno: salesOrderVno,
      refCno: refCno,
      refType: 'FUNNEL_CONVERSION',
    );
  }
}
