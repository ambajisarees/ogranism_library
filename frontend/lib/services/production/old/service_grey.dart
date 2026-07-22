import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/model_grey.dart';
import '../core/service_supabase.dart';



class GreyService {
  final _db = SupabaseService();
  static final GreyService _instance = GreyService._internal();
  factory GreyService() => _instance;
  GreyService._internal();

  /// Fetch the Grey Purchase (P1) list.
  Future<PaginatedResult<GreyPurchaseModel>> getPurchaseBills({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
  }) async {
    var query = _db.client
        .schema('IMMBE2627')
        .from('sq_BILLS')
        .select('*')
        .eq('TYPE', 'P1')
        .lt('VNO', 100000);

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query = query.or('QUAL.ilike.%$searchTerm%,code.ilike.%$searchTerm%');
    }

    final response = await query
        .order('VNO', ascending: false)
        .range(offset, offset + limit - 1)
        .count(CountOption.exact);

    final data = (response.data as List).map((json) => GreyPurchaseModel.fromJson(json)).toList();
    return PaginatedResult(
      data: data,
      totalCount: response.count,
      offset: offset,
      limit: limit,
    );
  }

  /// Fetch the Mill Dispatch (Pending) list.
  Future<PaginatedResult<GreyProductionCard>> getDispatchRegistry({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('vwsq_milldispatch_pend')
          .select('*');

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('PARTY_NAME.ilike.%$searchTerm%,QUALITY.ilike.%$searchTerm%,WEAVER_BILL_NO.ilike.%$searchTerm%');
      }

      final response = await query
          .range(offset, offset + limit - 1)
          .order('CARDNO', ascending: false)
          .count(CountOption.exact);

      final List<dynamic> data = response.data as List<dynamic>;
      return PaginatedResult(
        data: data.map((json) => GreyProductionCard.fromJson(json)).toList(),
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('GreyService.getDispatchRegistry error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetch the Mill Inward (J1) list from sq_BILLS.
  Future<PaginatedResult<MillInwardModel>> getMillInwardBills({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('*')
          .eq('TYPE', 'J1')
          .lt('VNO', 100000);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('QUAL.ilike.%$searchTerm%,code.ilike.%$searchTerm%');
      }

      final response = await query
          .order('VNO', ascending: false)
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final data = (response.data as List).map((json) => MillInwardModel.fromJson(json)).toList();
      return PaginatedResult(
        data: data,
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('GreyService.getMillInwardBills error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Fetch Bill details (Taka/Items) from sq_PINVTRN.
  Future<List<TakaModel>> getBillDetails(int vno, String type) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_PINVTRN')
          .select('*')
          .eq('VNO', vno)
          .eq('TYPE', type)
          .order('CARDNO', ascending: true);

      return (response as List)
          .map((json) => TakaModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('GreyService.getBillDetails error: $e');
      return [];
    }
  }

  /// Fetch Grey Deals from sb_vw_pur_ord_summary.
  Future<PaginatedResult<GreyDealModel>> getGreyDeals({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
    bool onlyPending = false,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('sb_vw_pur_ord_summary')
          .select('*');

      if (onlyPending) {
        query = query.eq('CLOSED', 'N');
      }

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('QUAL.ilike.%$searchTerm%,gcode.ilike.%$searchTerm%,BCODE.ilike.%$searchTerm%');
      }

      final response = await query
          .order('ORDERNO', ascending: false)
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final data = (response.data as List).map((json) => GreyDealModel.fromJson(json)).toList();
      return PaginatedResult(
        data: data,
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('GreyService.getGreyDeals error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Get list of weavers (from sq_ACGROUP where ATYPE = 2)
  Future<List<Map<String, String>>> getWeavers() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_ACGROUP')
          .select('gcode, NAME')
          .eq('ATYPE', 2)
          .not('NAME', 'is', null)
          .not('NAME', 'eq', '');

      final list = (response as List).map((r) => {
        'code': (r['gcode'] as String).trim(),
        'name': (r['NAME'] as String).trim(),
      }).toList();

      list.sort((a, b) => a['name']!.compareTo(b['name']!));
      return list;
    } catch (e) {
      debugPrint('GreyService.getWeavers error: $e');
      return [];
    }
  }

  /// Get master firms belonging to a weaver group
  Future<List<String>> getFirmsForWeaverGroup(String gcode) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('NAME')
          .eq('GCODE', gcode)
          .eq('ATYPE', 2)
          .not('NAME', 'is', null)
          .not('NAME', 'eq', '');

      final list = (response as List)
          .map((r) => (r['NAME'] as String).trim())
          .toSet()
          .toList();

      list.sort();
      return list;
    } catch (e) {
      debugPrint('GreyService.getFirmsForWeaverGroup error: $e');
      return [];
    }
  }

  /// Get list of brokers (ATYPE = 12)
  Future<List<Map<String, String>>> getBrokers() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('code, NAME')
          .eq('ATYPE', 12)
          .not('NAME', 'is', null)
          .not('NAME', 'eq', '');

      final list = (response as List).map((r) => {
        'code': (r['code'] as String).trim(),
        'name': (r['NAME'] as String).trim(),
      }).toList();

      list.sort((a, b) => a['name']!.compareTo(b['name']!));
      return list;
    } catch (e) {
      debugPrint('GreyService.getBrokers error: $e');
      return [];
    }
  }

  /// Create a new grey order via Supabase Edge Function
  Future<Map<String, dynamic>?> saveGreyOrder(Map<String, dynamic> data) async {
    try {
      final response = await _db.client.functions.invoke(
        'create-grey-order',
        body: data,
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Order creation failed.');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      debugPrint('GreyService.saveGreyOrder error: $e');
      rethrow;
    }
  }

  /// Get matching received grey bills against a deal ORDERNO
  Future<List<Map<String, dynamic>>> getReceivedBillsForDeal(int orderNo) async {
    try {
      final detResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLDET')
          .select('VNO, TYPE, CNO, PCS, MTS, qual, RATE')
          .eq('orderno', orderNo)
          .eq('TYPE', 'P1');

      final details = detResponse as List;
      if (details.isEmpty) return [];

      final vnos = details.map((d) => d['VNO']).toSet().toList();

      final billsResponse = await _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO, TYPE, CNO, BILL, DATE')
          .inFilter('VNO', vnos)
          .eq('TYPE', 'P1');

      final bills = billsResponse as List;
      final billMap = {for (var b in bills) '${b['VNO']}_${b['TYPE']}_${b['CNO']}': b};

      return details.map((det) {
        final key = '${det['VNO']}_${det['TYPE']}_${det['CNO']}';
        final bill = billMap[key];
        return {
          'VNO': det['VNO'],
          'PCS': det['PCS'],
          'MTS': det['MTS'],
          'qual': det['qual'],
          'RATE': det['RATE'],
          'bill_no': bill?['BILL'] ?? 'N/A',
          'bill_date': bill?['DATE'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('GreyService.getReceivedBillsForDeal error: $e');
      return [];
    }
  }
}

// Local PaginatedResult removed in favor of service_supabase.dart version
