import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_chaltrn.dart';
import '../service_supabase.dart';

/// [SqChaltrnService] — Canonical Core Service Layer for `sq_CHALTRN` (Roll/Taka Details).
class SqChaltrnService {
  static final SqChaltrnService _instance = SqChaltrnService._internal();
  factory SqChaltrnService() => _instance;
  SqChaltrnService._internal();

  final _db = SupabaseService();

  /// Fetches individual taka/roll lines for a sent grey card (`CARDNO`).
  Future<List<SqChaltrnModel>> getTakaLinesByCardNo({
    required int cardNo,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_CHALTRN')
          .select('*')
          .eq('CARDNO', cardNo)
          .order('TAKASRNO', ascending: true);

      final List<dynamic> rawList = response as List<dynamic>;
      return rawList.map((j) => SqChaltrnModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error in SqChaltrnService.getTakaLinesByCardNo: $e');
      return [];
    }
  }

  /// Fetches individual taka/roll lines for a received mill card (`RECCARDNO`).
  Future<List<SqChaltrnModel>> getTakaLinesByRecCardNo({
    required int recCardNo,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_CHALTRN')
          .select('*')
          .eq('RECCARDNO', recCardNo)
          .order('TAKASRNO', ascending: true);

      final List<dynamic> rawList = response as List<dynamic>;
      return rawList.map((j) => SqChaltrnModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error in SqChaltrnService.getTakaLinesByRecCardNo: $e');
      return [];
    }
  }
}
