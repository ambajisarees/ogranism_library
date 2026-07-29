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
