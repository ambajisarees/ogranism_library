import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/production/model_design.dart';
import '../core/service_supabase.dart';

/// [DesignsService] — Singleton service managing SKU Designs and photoshoot media metadata.
class DesignsService {
  static final DesignsService _instance = DesignsService._internal();
  factory DesignsService() => _instance;
  DesignsService._internal();

  final _db = SupabaseService();

  /// Fetch Designs from Supabase with search, status filtering, and pagination.
  Future<PaginatedResult<DesignModel>> getDesigns({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
    String? filterQuality,
    String? filterStatus,
    bool? filterMaster,
    String? sortBy = 'DESIGN_NO_ASC',
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .select('*');

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('design_no.ilike.%$searchTerm%,item_qcode.ilike.%$searchTerm%');
      }

      if (filterQuality != null && filterQuality.isNotEmpty) {
        query = query.eq('item_qcode', filterQuality);
      }

      if (filterStatus != null && filterStatus.isNotEmpty) {
        query = query.eq('status', filterStatus);
      }

      if (filterMaster != null) {
        query = query.eq('is_master', filterMaster);
      }

      // Apply sorting
      if (sortBy == 'DESIGN_NO_ASC') {
        query = query.order('design_no', ascending: true);
      } else if (sortBy == 'DESIGN_NO_DESC') {
        query = query.order('design_no', ascending: false);
      } else if (sortBy == 'LATEST_FIRST') {
        query = query.order('created_at', ascending: false);
      } else {
        query = query.order('design_no', ascending: true);
      }

      final response = await query
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final List<dynamic> list = response.data as List<dynamic>;
      final int totalCount = response.count;

      final mappedList = list.map((json) => DesignModel.fromJson(json)).toList();

      return PaginatedResult(
        data: mappedList,
        totalCount: totalCount,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('DesignsService.getDesigns error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit);
    }
  }

  /// Create a new Design using the Postgres auto-increment function.
  Future<DesignModel?> createDesign({
    required String itemQCode,
    required String status,
    required bool isMaster,
    required int openingBalance,
    String? remarks,
  }) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .rpc('create_auto_design', params: {
            'p_item_qcode': itemQCode,
            'p_status': status,
            'p_is_master': isMaster,
            'p_opening_balance': openingBalance,
            'p_remarks': remarks ?? '',
          });

      if (response != null) {
        return DesignModel.fromJson(Map<String, dynamic>.from(response));
      }
      return null;
    } catch (e) {
      debugPrint('DesignsService.createDesign error: $e');
      return null;
    }
  }

  /// Update metadata or media paths for a Design card.
  Future<bool> updateDesign(String id, Map<String, dynamic> updateData) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .update(updateData)
          .eq('id', id);

      return true;
    } catch (e) {
      debugPrint('DesignsService.updateDesign error: $e');
      return false;
    }
  }

  /// Remove a Design catalog entry.
  Future<bool> deleteDesign(String id) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      debugPrint('DesignsService.deleteDesign error: $e');
      return false;
    }
  }

  /// Fetch unique finished item qualities from the database to select in forms.
  Future<List<String>> getUniqueItemQCodes() async {
    try {
      // 1. Fetch from seeded designs (main list of finished items)
      final designsResponse = await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .select('item_qcode');
      
      final List<dynamic> list = designsResponse as List<dynamic>;
      final qualities = list
          .map((row) => row['item_qcode']?.toString().trim() ?? '')
          .where((qual) => qual.isNotEmpty)
          .toSet()
          .toList();

      if (qualities.isEmpty) {
        // Fallback: fetch directly from billing history finished qualities
        final billdetResponse = await _db.client
            .schema('IMMBE2627')
            .from('sq_BILLDET')
            .select('qual')
            .eq('TYPE', 'O5')
            .limit(100);

        final List<dynamic> fallbackList = billdetResponse as List<dynamic>;
        qualities.addAll(
          fallbackList
              .map((row) => row['qual']?.toString().trim() ?? '')
              .where((qual) => qual.isNotEmpty)
        );
      }

      final sorted = qualities.toSet().toList()..sort();
      return sorted;
    } catch (e) {
      debugPrint('DesignsService.getUniqueItemQCodes error: $e');
      return [];
    }
  }

  /// Fetch aggregated KPIs for the Designs screen:
  /// - In Production design count
  /// - At Mill design count
  /// - In Stock design count
  /// - Archived design count
  /// - Stock at Shop (Ready sum)
  /// - Stock at Job (Production + Damaged sum)
  Future<Map<String, int>> getDesignsKPIs() async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .select('''
            id,
            status,
            stock_ready,
            stock_production,
            stock_damaged
          ''');

      final List<dynamic> data = response as List<dynamic>;
      int inProd = 0;
      int atMill = 0;
      int inStock = 0;
      int archived = 0;
      int shopStock = 0;
      int jobStock = 0;

      for (final row in data) {
        final status = row['status'] as String?;
        if (status == 'in_production') inProd++;
        if (status == 'at_mill') atMill++;
        if (status == 'in_stock') inStock++;
        if (status == 'archived') archived++;

        shopStock += (row['stock_ready'] as num?)?.toInt() ?? 0;
        jobStock += ((row['stock_production'] as num?)?.toInt() ?? 0) +
            ((row['stock_damaged'] as num?)?.toInt() ?? 0);
      }

      return {
        'in_production': inProd,
        'at_mill': atMill,
        'in_stock': inStock,
        'archived': archived,
        'shop_stock': shopStock,
        'job_stock': jobStock,
      };
    } catch (e) {
      debugPrint('DesignsService.getDesignsKPIs error: $e');
      return {
        'in_production': 0,
        'at_mill': 0,
        'in_stock': 0,
        'archived': 0,
        'shop_stock': 0,
        'job_stock': 0,
      };
    }
  }

  /// Upload a file to Supabase Storage and update the corresponding path in the database.
  /// [bucketName] can be 'Saree_Pics', 'Model_Pics', or 'Model_PDF'.
  /// [columnName] is the column in sb_designs ('set_pic_path', 'set_poster_path', or 'catalog_pdf_path').
  Future<String?> uploadDesignFile({
    required String designId,
    required String designNo,
    required String bucketName,
    required String columnName,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final fileExtension = fileName.split('.').last;
      // Clean path, e.g. "VIDHI-26/set_pic.jpg" or "VIDHI-26/catalog.pdf"
      final storagePath = '$designNo/$columnName.$fileExtension';

      // 1. Upload to Supabase Storage
      await _db.client.storage
          .from(bucketName)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );

      // 2. Update the db row column with the storagePath
      await _db.client
          .schema('IMMBE2627')
          .from('sb_designs')
          .update({columnName: storagePath})
          .eq('id', designId);

      return storagePath;
    } catch (e) {
      debugPrint('DesignsService.uploadDesignFile error: $e');
      return null;
    }
  }

  /// Get the public/signed URL of a storage file.
  String getPublicFileUrl(String bucketName, String path) {
    try {
      return _db.client.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      debugPrint('DesignsService.getPublicFileUrl error: $e');
      return '';
    }
  }
}
