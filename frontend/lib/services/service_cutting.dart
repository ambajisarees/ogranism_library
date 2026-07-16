import '../models/model_cutting.dart';
import 'service_supabase.dart';



/// [CuttingService] - Manages data operations for Grey Cutting Cards and summaries.
/// Table: `IMMBE2627`.`sb_cutdet` and `IMMBE2627`.`sb_cutdet_summary`
class CuttingService {
  static final CuttingService _instance = CuttingService._internal();
  factory CuttingService() => _instance;
  CuttingService._internal();

  final _db = SupabaseService();

  /// Fetches paginated cutting batches from sb_cutdet_summary (modern).
  Future<PaginatedResult<CuttingBatchSummaryModel>> getCuttingBatches({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
    String? filterMill,
    String? filterFabric,
    String sortBy = 'DATE_DESC',
  }) async {
    try {
      // 1. Fetch from sb_cutdet_summary (modern)
      var sbQuery = _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('*');

      final sbResponse = await sbQuery;
      List<CuttingBatchSummaryModel> combined = (sbResponse as List)
          .map((json) => CuttingBatchSummaryModel.fromJson(json))
          .toList();

      // Apply Filters
      if (filterMill != null && filterMill.isNotEmpty) {
        combined = combined.where((s) => s.mill.toLowerCase() == filterMill.toLowerCase()).toList();
      }
      if (filterFabric != null && filterFabric.isNotEmpty) {
        combined = combined.where((s) => s.greyQual.toLowerCase().contains(filterFabric.toLowerCase())).toList();
      }

      // Filter by Search Query if present
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryStr = searchQuery.toLowerCase();
        combined = combined.where((s) =>
          s.mill.toLowerCase().contains(queryStr) ||
          s.greyQual.toLowerCase().contains(queryStr) ||
          s.ccCode.toLowerCase().contains(queryStr) ||  // e.g. "CC-0001"
          s.ccNo.contains(queryStr) ||                  // e.g. "0001"
          s.multiVno.toString().contains(queryStr)
        ).toList();
      }

      // Apply Sorting
      if (sortBy == 'DATE_DESC') {
        combined.sort((a, b) => b.cutDate.compareTo(a.cutDate));
      } else if (sortBy == 'DATE_ASC') {
        combined.sort((a, b) => a.cutDate.compareTo(b.cutDate));
      } else if (sortBy == 'CHALLAN_DESC' || sortBy == 'CC_DESC') {
        combined.sort((a, b) => b.multiVno.compareTo(a.multiVno));
      } else if (sortBy == 'CHALLAN_ASC' || sortBy == 'CC_ASC') {
        combined.sort((a, b) => a.multiVno.compareTo(b.multiVno));
      }

      // 2. Paginate
      final int totalCount = combined.length;
      final int start = offset.clamp(0, totalCount);
      final int end = (offset + limit).clamp(0, totalCount);
      final List<CuttingBatchSummaryModel> paginatedData = combined.sublist(start, end);

      return PaginatedResult(
        data: paginatedData,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      print('Error in getCuttingBatches: $e');
      return PaginatedResult(
        data: [],
        totalCount: 0,
        offset: offset,
        limit: limit,
        error: e.toString(),
      );
    }
  }

  /// Fetches unique Base Qualities from sq_QUAL (ISBASEQUAL = 'Y')
  Future<List<String>> getUniqueQualities() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_QUAL')
          .select('NAME')
          .eq('ISBASEQUAL', 'Y')
          .not('NAME', 'is', null)
          .not('NAME', 'eq', '');

      final list = (response as List).map((r) => r['NAME'] as String).toSet().toList();
      list.sort();
      return list;
    } catch (e) {
      print('Error getUniqueQualities: $e');
      return [];
    }
  }

  /// Fetches unique Processing Mills from sq_MASTER (ATYPE = 14)
  Future<List<String>> getUniqueMills() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('NAME')
          .eq('ATYPE', 14)
          .not('NAME', 'is', null)
          .not('NAME', 'eq', '');

      final list = (response as List).map((r) => r['NAME'] as String).toSet().toList();
      list.sort();
      return list;
    } catch (e) {
      print('Error getUniqueMills: $e');
      return [];
    }
  }

  /// Fetches unique Processing Mills from sq_MILLREC with active uncut cards for the selected quality
  Future<List<String>> getUniqueMillsForQuality(String greyQual) async {
    try {
      final sbCutdetResponse = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .select('reccardno')
          .eq('closed', 'Y')
          .not('reccardno', 'is', null);

      final Set<int> cutCardNos = {
        ...(sbCutdetResponse as List).map((r) => (r['reccardno'] as num?)?.toInt() ?? 0)
      };
      cutCardNos.remove(0);

      var query = _db.client
          .schema('IMMBE2627')
          .from('sq_MILLREC')
          .select('MILL_CODE')
          .eq('GREYQUAL', greyQual)
          .gt('RECCARDNO', -1)
          .lt('VNO', 100000)
          .not('MILL_CODE', 'is', null)
          .not('MILL_CODE', 'eq', '');

      if (cutCardNos.isNotEmpty) {
        query = query.not('RECCARDNO', 'in', cutCardNos.toList());
      }

      final response = await query;
      final list = (response as List).map((r) => r['MILL_CODE'] as String).toSet().toList();
      list.sort();
      return list;
    } catch (e) {
      print('Error getUniqueMillsForQuality: $e');
      return [];
    }
  }

  /// Fetches available uncut cards from sq_MILLREC, mapping columns to frontend signature
  Future<List<Map<String, dynamic>>> getAvailableTakas({
    required List<String> greyQuals,
    required String mill,
    String? designQuery,
    int? editMultiVno,
  }) async {
    if (greyQuals.isEmpty) return [];
    try {
      // Fetch available takas using the database RPC function to bypass limits
      final response = await _db.client
          .schema('IMMBE2627')
          .rpc('get_available_takas', params: {
            'p_grey_quals': greyQuals,
            'p_mill': mill,
            'p_edit_multi_vno': editMultiVno,
          });

      List<dynamic> list = response as List<dynamic>;

      if (designQuery != null && designQuery.isNotEmpty) {
        final q = designQuery.toLowerCase();
        list = list.where((card) {
          final remark = (card['RECRMK'] as String? ?? '').toLowerCase();
          return remark.contains(q);
        }).toList();
      }

      // Map returned fields to match Frontend expectations
      return list.map((r) {
        final row = Map<String, dynamic>.from(r);
        row['CARDNO'] = (row['RECCARDNO'] as num?)?.toInt() ?? 0;
        row['LOT'] = row['lot'] as String? ?? 'N/A';
        row['QUAL'] = row['GREYQUAL'] as String? ?? 'N/A';
        row['MILL'] = row['MILL_CODE'] as String? ?? mill;
        // Map DDATE fallback
        row['DDATE'] = row['CUTDATE'] ?? row['chaldate'] ?? row['CREATETIME'];
        return row;
      }).toList();
    } catch (e) {
      print('Error getAvailableTakas: $e');
      return [];
    }
  }

  /// Invokes the transaction Edge Function to save a cutting batch
  Future<Map<String, dynamic>?> saveCuttingBatch(Map<String, dynamic> batchData) async {
    try {
      final response = await _db.client.functions.invoke(
        'create-cutting-batch',
        body: batchData,
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Batch creation failed.');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      print('Error saveCuttingBatch: $e');
      rethrow;
    }
  }

  /// Fetches the batch summary for a MULTI_VNO
  Future<CuttingBatchSummaryModel?> getBatchSummary(int multiVno) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select()
          .eq('MULTI_VNO', multiVno)
          .maybeSingle();

      if (response == null) return null;
      return CuttingBatchSummaryModel.fromJson(response);
    } catch (e) {
      print('Error getBatchSummary: $e');
      return null;
    }
  }

  /// Fetches sibling cards for a MULTI_VNO in sb_cutdet
  Future<List<CuttingCardModel>> getSiblingCards(int multiVno) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .select('*')
          .eq('MULTI_VNO', multiVno)
          .order('CUTCARDNO', ascending: true);

      return (response as List).map((json) => CuttingCardModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getSiblingCards: $e');
      return [];
    }
  }

  /// Fetches a single card by its CUTCARDNO (or CARDNO)
  Future<CuttingCardModel?> getCardByNo(int cutCardNo) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .select()
          .eq('CUTCARDNO', cutCardNo)
          .maybeSingle();

      if (response != null) {
        return CuttingCardModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching card $cutCardNo: $e');
      return null;
    }
  }

  /// Fetches the next auto-incremental multi card / batch voucher number.
  Future<int> getNextMultiVno() async {
    try {
      final sbResponse = await _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .select('MULTI_VNO')
          .lt('MULTI_VNO', 100000)
          .order('MULTI_VNO', ascending: false)
          .limit(1)
          .maybeSingle();

      int sbMax = 0;
      if (sbResponse != null) {
        sbMax = (sbResponse['MULTI_VNO'] as num?)?.toInt() ?? 0;
      }

      return sbMax > 0 ? sbMax + 1 : 1;
    } catch (e) {
      print('Error getNextMultiVno: $e');
      return 1;
    }
  }
}
