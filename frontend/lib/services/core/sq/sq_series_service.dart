import 'package:flutter/foundation.dart';
import '../../../models/core/sq/sq_series.dart';
import '../service_supabase.dart';

/// [SqSeriesService] — Canonical Core Service Layer for `sq_SERIES` (Voucher Series Master).
class SqSeriesService {
  static final SqSeriesService _instance = SqSeriesService._internal();
  factory SqSeriesService() => _instance;
  SqSeriesService._internal();

  final _db = SupabaseService();

  // In-Memory Cache to ensure instantaneous (<1ms) label lookups everywhere in the app
  Map<String, SqSeriesModel>? _cachedSeriesMap;

  /// Fetches all active series definitions from `sq_SERIES`.
  Future<List<SqSeriesModel>> getAllSeries() async {
    try {
      if (_cachedSeriesMap != null) {
        return _cachedSeriesMap!.values.toList();
      }

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_SERIES')
          .select('*')
          .order('SERIESCODE', ascending: true);

      final List<dynamic> rawList = response as List<dynamic>;
      final list = rawList.map((j) => SqSeriesModel.fromJson(j as Map<String, dynamic>)).toList();

      _cachedSeriesMap = {for (var item in list) item.seriesCode: item};
      return list;
    } catch (e) {
      debugPrint('Error in SqSeriesService.getAllSeries: $e');
      return [];
    }
  }

  /// Synchronous instant lookup for series code name (e.g. 'O13' -> 'FINISH PURCHASE ORDER').
  String getSeriesName(String seriesCode, {String fallback = 'Unknown Order'}) {
    if (_cachedSeriesMap == null) return fallback;
    final item = _cachedSeriesMap![seriesCode];
    return item != null && item.name.isNotEmpty ? item.name : fallback;
  }

  /// Fetches all series matching a prefix (e.g. prefix 'O' for Order series).
  Future<List<SqSeriesModel>> getSeriesByPrefix(String prefix) async {
    final all = await getAllSeries();
    return all.where((s) => s.seriesCode.startsWith(prefix)).toList();
  }
}
