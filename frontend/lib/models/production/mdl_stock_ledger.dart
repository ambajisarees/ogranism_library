/*
================================================================================
LLM CONTEXT & QUERY SPACE — STOCK LEDGER DATA MODELS (mdl_stock_ledger.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Domain Data Models for Finished Saree Stock Ledger (`sb_stock_ledger` & `vw_stock_summary`).
   - Tracks 2-horizon commercial orderability (Firm Sales Orders vs Sales Funnel Pre-Orders).
   - Manages physical shelf inventory (`current_stock`), production pipeline inflows (`stock_at_mill`, `stock_at_job`), and customer order pendencies (`so_pending`, `fl_pending`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Primary Keys: `design_code` (e.g. `VIDHI-101` or `VIDHI-MAIN`), `itemsrno` (`00113`).
   - Formulas:
     - `current_stock` = `stock_in - stock_out`
     - `so_pending` = `so_booked - so_delivered`
     - `fl_pending` = `fl_booked - fl_converted`
     - `so_orderable` = `max(0, current_stock + stock_at_job - so_pending)`
     - `fl_orderable` = `max(0, so_orderable + stock_at_mill - fl_pending)`

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `qty_out` tracks ALL physical shelf outflows (Dispatches + Transfers Out).
   - `qty_delivered` tracks ONLY customer sales order dispatches to preserve pendency math during Stock Transfers.
================================================================================
*/

import 'package:flutter/foundation.dart';

/// Stock Ledger Event Types Enum
enum StockEventType {
  atMill,
  progCancelled,
  jobIssued,
  jobReceived,
  packed,
  funnelOrder,
  funnelConverted,
  salesOrder,
  dispatched,
  stockTransfer,
  salesReturn;

  String get dbValue {
    switch (this) {
      case StockEventType.atMill:
        return 'AT_MILL';
      case StockEventType.progCancelled:
        return 'PROG_CANCELLED';
      case StockEventType.jobIssued:
        return 'JOB_ISSUED';
      case StockEventType.jobReceived:
        return 'JOB_RECEIVED';
      case StockEventType.packed:
        return 'PACKED';
      case StockEventType.funnelOrder:
        return 'FUNNEL_ORDER';
      case StockEventType.funnelConverted:
        return 'FUNNEL_CONVERTED';
      case StockEventType.salesOrder:
        return 'SALES_ORDER';
      case StockEventType.dispatched:
        return 'DISPATCHED';
      case StockEventType.stockTransfer:
        return 'STOCK_TRANSFER';
      case StockEventType.salesReturn:
        return 'SALES_RETURN';
    }
  }

  static StockEventType fromDbValue(String val) {
    switch (val.toUpperCase().trim()) {
      case 'AT_MILL':
        return StockEventType.atMill;
      case 'PROG_CANCELLED':
        return StockEventType.progCancelled;
      case 'JOB_ISSUED':
        return StockEventType.jobIssued;
      case 'JOB_RECEIVED':
        return StockEventType.jobReceived;
      case 'PACKED':
        return StockEventType.packed;
      case 'FUNNEL_ORDER':
        return StockEventType.funnelOrder;
      case 'FUNNEL_CONVERTED':
        return StockEventType.funnelConverted;
      case 'SALES_ORDER':
        return StockEventType.salesOrder;
      case 'DISPATCHED':
        return StockEventType.dispatched;
      case 'STOCK_TRANSFER':
        return StockEventType.stockTransfer;
      case 'SALES_RETURN':
        return StockEventType.salesReturn;
      default:
        return StockEventType.packed;
    }
  }
}

/// [StockLedgerEventModel] — Core Ledger Event Entry representation (`sb_stock_ledger`)
@immutable
class StockLedgerEventModel {
  final String id;
  final String idempotencyHash;
  final String designCode;
  final String itemSrNo;
  final StockEventType eventType;
  final DateTime eventDate;
  final int qtyIn;
  final int qtyOut;
  final int qtyOrdered;
  final int qtyDelivered;
  final int qtyFunnel;
  final int qtyConverted;
  final int qtyAtMill;
  final int qtyAtJob;
  final String? refVno;
  final int? refCno;
  final String? refType;
  final DateTime? createdAt;
  final String? createdBy;

  const StockLedgerEventModel({
    required this.id,
    required this.idempotencyHash,
    required this.designCode,
    required this.itemSrNo,
    required this.eventType,
    required this.eventDate,
    required this.qtyIn,
    required this.qtyOut,
    required this.qtyOrdered,
    required this.qtyDelivered,
    required this.qtyFunnel,
    required this.qtyConverted,
    required this.qtyAtMill,
    required this.qtyAtJob,
    this.refVno,
    this.refCno,
    this.refType,
    this.createdAt,
    this.createdBy,
  });

  factory StockLedgerEventModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    return StockLedgerEventModel(
      id: (json['id'] as String?)?.trim() ?? '',
      idempotencyHash: (json['idempotency_hash'] as String?)?.trim() ?? '',
      designCode: (json['design_code'] as String?)?.trim() ?? '',
      itemSrNo: (json['itemsrno'] as String?)?.trim() ?? '',
      eventType: StockEventType.fromDbValue((json['event_type'] as String?) ?? 'PACKED'),
      eventDate: parseDate(json['event_date']) ?? DateTime.now(),
      qtyIn: (json['qty_in'] as num?)?.toInt() ?? 0,
      qtyOut: (json['qty_out'] as num?)?.toInt() ?? 0,
      qtyOrdered: (json['qty_ordered'] as num?)?.toInt() ?? 0,
      qtyDelivered: (json['qty_delivered'] as num?)?.toInt() ?? 0,
      qtyFunnel: (json['qty_funnel'] as num?)?.toInt() ?? 0,
      qtyConverted: (json['qty_converted'] as num?)?.toInt() ?? 0,
      qtyAtMill: (json['qty_at_mill'] as num?)?.toInt() ?? 0,
      qtyAtJob: (json['qty_at_job'] as num?)?.toInt() ?? 0,
      refVno: (json['ref_vno'] as String?)?.trim(),
      refCno: (json['ref_cno'] as num?)?.toInt(),
      refType: (json['ref_type'] as String?)?.trim(),
      createdAt: parseDate(json['created_at']),
      createdBy: (json['created_by'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
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
      };
}

/// [StockSummaryModel] — Real-Time Stock Summary representation (`vw_stock_summary`)
@immutable
class StockSummaryModel {
  final String designCode;
  final String itemSrNo;
  final int stockIn;
  final int stockOut;
  final int currentStock;
  final int stockAtMill;
  final int stockAtJob;
  final int flBooked;
  final int flConverted;
  final int flPending;
  final int soBooked;
  final int soDelivered;
  final int soPending;
  final int soOrderable;
  final int flOrderable;

  const StockSummaryModel({
    required this.designCode,
    required this.itemSrNo,
    required this.stockIn,
    required this.stockOut,
    required this.currentStock,
    required this.stockAtMill,
    required this.stockAtJob,
    required this.flBooked,
    required this.flConverted,
    required this.flPending,
    required this.soBooked,
    required this.soDelivered,
    required this.soPending,
    required this.soOrderable,
    required this.flOrderable,
  });

  factory StockSummaryModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryModel(
      designCode: (json['design_code'] as String?)?.trim() ?? '',
      itemSrNo: (json['itemsrno'] as String?)?.trim() ?? '',
      stockIn: (json['stock_in'] as num?)?.toInt() ?? 0,
      stockOut: (json['stock_out'] as num?)?.toInt() ?? 0,
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      stockAtMill: (json['stock_at_mill'] as num?)?.toInt() ?? 0,
      stockAtJob: (json['stock_at_job'] as num?)?.toInt() ?? 0,
      flBooked: (json['fl_booked'] as num?)?.toInt() ?? 0,
      flConverted: (json['fl_converted'] as num?)?.toInt() ?? 0,
      flPending: (json['fl_pending'] as num?)?.toInt() ?? 0,
      soBooked: (json['so_booked'] as num?)?.toInt() ?? 0,
      soDelivered: (json['so_delivered'] as num?)?.toInt() ?? 0,
      soPending: (json['so_pending'] as num?)?.toInt() ?? 0,
      soOrderable: (json['so_orderable'] as num?)?.toInt() ?? 0,
      flOrderable: (json['fl_orderable'] as num?)?.toInt() ?? 0,
    );
  }

  /// Empty fallback model
  static const empty = StockSummaryModel(
    designCode: '',
    itemSrNo: '',
    stockIn: 0,
    stockOut: 0,
    currentStock: 0,
    stockAtMill: 0,
    stockAtJob: 0,
    flBooked: 0,
    flConverted: 0,
    flPending: 0,
    soBooked: 0,
    soDelivered: 0,
    soPending: 0,
    soOrderable: 0,
    flOrderable: 0,
  );
}
