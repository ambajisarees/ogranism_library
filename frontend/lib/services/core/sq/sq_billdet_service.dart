/*
================================================================================
LLM CONTEXT & QUERY SPACE — SQ BILLDET SERVICE (sq_billdet_service.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical core service singleton for table `sq_BILLDET` in target schema `IMMBE2627`.
   - Fetches detail line items for voucher headers (POs, PBs, Sales Invoices).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Always requires 3-key composite join (`CNO = cno AND VNO = vno AND TYPE = type`) to prevent fan-outs.
   - Orders line items sequentially by `SRNO`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_BILLDET` is Airbyte mirror, strictly read-only.
   - Default fallbacks (`?? 0.0`) prevent null unwrapping crashes on missing numeric rates.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should batch queries (fetching line items for 50 headers simultaneously) use RPC procedures?
================================================================================
*/

import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_billdet.dart';
import '../service_supabase.dart';

/// [SqBilldetService] — Canonical Core Service Layer for `sq_BILLDET` (Invoice Line Items).
class SqBilldetService {
  static final SqBilldetService _instance = SqBilldetService._internal();
  factory SqBilldetService() => _instance;
  SqBilldetService._internal();

  final _db = SupabaseService();

  /// Fetches all line items for an invoice/order using strict 3-key composite join (`CNO`, `VNO`, `TYPE`).
  Future<List<SqBilldetModel>> getLineItemsForBill({
    required int vno,
    required String type,
    int cno = 4,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('CNO', cno)
          .eq('VNO', vno)
          .eq('TYPE', type)
          .order('SRNO', ascending: true);

      final List<dynamic> rawList = response as List<dynamic>;
      return rawList.map((j) => SqBilldetModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error in SqBilldetService.getLineItemsForBill: $e');
      return [];
    }
  }

  /// Fetches line items linked to a specific Purchase/Sales Order ID (`orderno`).
  Future<List<SqBilldetModel>> getLineItemsByOrderNo({
    required int orderNo,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('*')
          .eq('orderno', orderNo)
          .order('SRNO', ascending: true);

      final List<dynamic> rawList = response as List<dynamic>;
      return rawList.map((j) => SqBilldetModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error in SqBilldetService.getLineItemsByOrderNo: $e');
      return [];
    }
  }
}
