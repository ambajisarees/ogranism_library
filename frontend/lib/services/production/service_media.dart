import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import '../../models/production/model_media.dart';
import '../../models/production/model_media_suggestion.dart';
import '../core/service_supabase.dart';



/// [MediaService] — Handles media file queries, storage uploads,
/// and metadata entity association calls for the central Media Library.
class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final _db = SupabaseService();

  /// Retrieve paginated media records from `sb_media`.
  Future<PaginatedResult<MediaModel>> getMedia({
    int offset = 0,
    int limit = 50,
    String? bucket,
    String? mediaType,
    bool? isLinked,
    String? entityType,
    String? entityId,
    String? searchTerm,
    String sortBy = 'created_at_desc',
  }) async {
    try {
      dynamic query = _db.client
          .schema('IMMBE2627')
          .from('sb_media')
          .select('*')
          .eq('is_archived', false);

      if (bucket != null && bucket != 'all') {
        query = query.eq('bucket', bucket);
      }
      if (mediaType != null) {
        query = query.eq('media_type', mediaType);
      }
      if (isLinked != null) {
        query = query.eq('is_linked', isLinked);
      }
      if (entityType != null) {
        query = query.eq('entity_type', entityType);
      }
      if (entityId != null) {
        query = query.eq('entity_id', entityId);
      }
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('file_name.ilike.%$searchTerm%,display_name.ilike.%$searchTerm%,entity_label.ilike.%$searchTerm%');
      }

      // Order sorting rules
      if (sortBy == 'created_at_desc') {
        query = query.order('created_at', ascending: false);
      } else if (sortBy == 'file_name_asc') {
        query = query.order('file_name', ascending: true);
      } else if (sortBy == 'file_size_desc') {
        query = query.order('file_size', ascending: false);
      }

      final response = await query
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      final data = (response.data as List)
          .map((json) => MediaModel.fromJson(json))
          .toList();

      return PaginatedResult(
        data: data,
        totalCount: response.count,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      print('MediaService.getMedia error: $e');
      return PaginatedResult(data: [], totalCount: 0, offset: offset, limit: limit, error: e.toString());
    }
  }

  /// Retrieve all active media files attached to a specific business qcode/batch/dispatch.
  Future<List<MediaModel>> getMediaForEntity(String entityType, String entityId) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_media')
          .select('*')
          .eq('entity_type', entityType)
          .eq('entity_id', entityId)
          .eq('is_archived', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MediaModel.fromJson(json))
          .toList();
    } catch (e) {
      print('MediaService.getMediaForEntity error: $e');
      return [];
    }
  }

  /// Uploads binary file data to Supabase Storage, compresses and thumbnails it if it is an image, and records metadata via RPC.
  Future<String> uploadFile(
    Uint8List fileBytes,
    String fileName, {
    required String bucket,
    String? mediaType,
    String? entityType,
    String? entityId,
    String? entityLabel,
  }) async {
    try {
      final currentUser = _db.client.auth.currentUser;
      final userId = currentUser?.id;
      
      // 1. Compute path based on bucket and entity linkages
      final cleanName = fileName.replaceAll(RegExp(r'\s+'), '_');
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      String storagePath = '';
      
      if (bucket == 'sales' && entityId != null) {
        storagePath = 'sales/$entityId/${mediaType ?? "general"}/$cleanName';
      } else if (bucket == 'production') {
        if (entityType == 'cutting_batch' && entityId != null) {
          storagePath = 'production/cutting/$entityId/$cleanName';
        } else if (entityType == 'stitching_dispatch' && entityId != null) {
          storagePath = 'production/jobcard/${entityId}_O5/$cleanName';
        } else if (entityType == 'stitching_receive' && entityId != null) {
          storagePath = 'production/jobcard/${entityId}_O6/$cleanName';
        } else {
          storagePath = 'production/${mediaType ?? "general"}/${entityId ?? "unsorted"}/$cleanName';
        }
      } else if (bucket == 'billing' && entityId != null) {
        storagePath = 'billing/$entityId/$cleanName';
      } else {
        storagePath = 'general/$dateStr/$cleanName';
      }

      final mimeType = _getMimeType(fileName);
      final isImage = mimeType.startsWith('image/');
      
      String? thumbPath;
      Uint8List uploadBytes = fileBytes;
      int? width;
      int? height;
      
      if (isImage) {
        final processed = ImageProcessor.compressAndThumbnail(fileBytes);
        if (processed != null) {
          uploadBytes = processed.mainBytes;
          
          try {
            final decoded = img.decodeImage(processed.mainBytes);
            if (decoded != null) {
              width = decoded.width;
              height = decoded.height;
            }
          } catch (e) {
            print('Failed to decode uploaded image dimensions: $e');
          }
          
          // Generate thumbnail path (e.g. production/cutting/123/thumbnails/01.jpg)
          final pathParts = storagePath.split('/');
          if (pathParts.length > 1) {
            pathParts.insert(pathParts.length - 1, 'thumbnails');
            thumbPath = pathParts.join('/');
          } else {
            thumbPath = 'thumbnails/$storagePath';
          }
          
          // Upload thumbnail to storage
          await _db.client.storage.from('ambaji-media').uploadBinary(
            thumbPath,
            processed.thumbBytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );
        } else {
          try {
            final decoded = img.decodeImage(fileBytes);
            if (decoded != null) {
              width = decoded.width;
              height = decoded.height;
            }
          } catch (e) {
            print('Failed to decode original image dimensions: $e');
          }
        }
      }

      // 2. Upload main compressed bytes to Supabase Storage
      await _db.client.storage.from('ambaji-media').uploadBinary(
        storagePath,
        uploadBytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: true),
      );

      // 3. Invoke custom Postgres insert trigger to persist metadata
      final rpcParams = {
        'p_file_path': storagePath,
        'p_file_name': fileName,
        'p_file_size': uploadBytes.length,
        'p_mime_type': mimeType,
        'p_bucket': bucket,
        'p_media_type': mediaType,
        'p_entity_type': entityType,
        'p_entity_id': entityId,
        'p_entity_label': entityLabel,
        'p_uploaded_by': userId,
        'p_uploader_name': currentUser?.email?.split('@')[0],
        'p_thumb_path': thumbPath,
        'p_width': width,
        'p_height': height,
      };

      final rpcResult = await _db.client
          .schema('IMMBE2627')
          .rpc('insert_media', params: rpcParams);
      final id = rpcResult['id'] as String?;
      if (id == null) {
        throw Exception('Failed to insert metadata into database.');
      }
      return id;
    } catch (e) {
      print('MediaService.uploadFile error: $e');
      rethrow;
    }
  }

  /// Manually link a media entry to an entity.
  Future<void> linkToEntity(String mediaId, String entityType, String entityId, String entityLabel) async {
    try {
      final currentUser = _db.client.auth.currentUser;
      final userId = currentUser?.id;

      await _db.client.schema('IMMBE2627').rpc('link_media_to_entity', params: {
        'p_media_id': mediaId,
        'p_entity_type': entityType,
        'p_entity_id': entityId,
        'p_entity_label': entityLabel,
        'p_linked_by': userId,
      });
    } catch (e) {
      print('MediaService.linkToEntity error: $e');
      rethrow;
    }
  }

  /// Bulk link multiple media files to a single entity.
  Future<void> bulkLinkToEntity(List<String> mediaIds, String entityType, String entityId, String entityLabel) async {
    try {
      final currentUser = _db.client.auth.currentUser;
      final userId = currentUser?.id;

      await _db.client.schema('IMMBE2627').rpc('bulk_link_media_to_entity', params: {
        'p_media_ids': mediaIds,
        'p_entity_type': entityType,
        'p_entity_id': entityId,
        'p_entity_label': entityLabel,
        'p_linked_by': userId,
      });
    } catch (e) {
      print('MediaService.bulkLinkToEntity error: $e');
      rethrow;
    }
  }

  /// Update metadata tags array.
  Future<void> updateTags(String mediaId, List<String> tags) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_media')
          .update({'tags': tags, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', mediaId);
    } catch (e) {
      print('MediaService.updateTags error: $e');
      rethrow;
    }
  }

  /// Reclassify a media file to a new bucket folder.
  Future<void> moveToBucket(String mediaId, String newBucket, String? newMediaType) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_media')
          .update({
            'bucket': newBucket,
            'media_type': newMediaType,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', mediaId);
    } catch (e) {
      print('MediaService.moveToBucket error: $e');
      rethrow;
    }
  }

  /// Soft delete/archive a media item.
  Future<void> archiveMedia(String mediaId) async {
    try {
      await _db.client.schema('IMMBE2627').rpc('archive_media', params: {
        'p_media_id': mediaId,
      });
    } catch (e) {
      print('MediaService.archiveMedia error: $e');
      rethrow;
    }
  }

  /// Soft delete/archive multiple media items in bulk.
  Future<void> bulkArchive(List<String> mediaIds) async {
    try {
      await _db.client.schema('IMMBE2627').rpc('bulk_archive_media', params: {
        'p_media_ids': mediaIds,
      });
    } catch (e) {
      print('MediaService.bulkArchive error: $e');
      rethrow;
    }
  }

  /// Resolve file's public HTTP URL with optional CDN transformations.
  String getPublicUrl(String filePath, {int? width, int? height, int? quality}) {
    if (width != null || height != null) {
      return _db.client.storage.from('ambaji-media').getPublicUrl(
        filePath,
        transform: TransformOptions(
          width: width,
          height: height,
          quality: quality ?? 80,
          resize: ResizeMode.cover,
        ),
      );
    }
    return _db.client.storage.from('ambaji-media').getPublicUrl(filePath);
  }

  /// Generate a secure, time-limited signed URL for viewing private images.
  Future<String> getSignedUrl(String filePath, {Duration expiry = const Duration(hours: 1)}) async {
    try {
      return await _db.client.storage.from('ambaji-media').createSignedUrl(filePath, expiry.inSeconds);
    } catch (e) {
      print('MediaService.getSignedUrl error: $e');
      return getPublicUrl(filePath); // fallback to public URL if signed fails
    }
  }

  String _deriveFolderContext(String filePath) {
    final lowerPath = filePath.toLowerCase();
    if (lowerPath.contains('cutting_card') ||
        lowerPath.contains('cutting card') ||
        lowerPath.contains('cutting_report') ||
        lowerPath.contains('cutting report') ||
        lowerPath.contains('/cutting/')) {
      return 'cutting_report';
    } else if (lowerPath.contains('challan')) {
      return 'challan';
    } else if (lowerPath.contains('bilty')) {
      return 'bilty';
    } else if (lowerPath.contains('job card') || lowerPath.contains('jobcard')) {
      return 'job_card';
    }
    return 'general';
  }

  List<int> _extractNumbers(String fileName, String context) {
    final cleanName = fileName.split('.').first; // strip extension
    final List<int> numbers = [];

    if (context == 'cutting_report') {
      // e.g. "147 (2)" or "147" -> match leading number
      final match = RegExp(r'^(\d+)').firstMatch(cleanName);
      if (match != null) {
        final val = int.tryParse(match.group(1)!);
        if (val != null) numbers.add(val);
      }
    } else if (context == 'bilty') {
      // e.g. "4883+4884+4897+4898" -> split by '+'
      final parts = cleanName.split('+');
      for (final p in parts) {
        final match = RegExp(r'(\d+)').firstMatch(p);
        if (match != null) {
          final val = int.tryParse(match.group(1)!);
          if (val != null) numbers.add(val);
        }
      }
    } else if (context == 'challan') {
      // e.g. "5070.5071.5072..jpg" -> split by '.'
      final parts = cleanName.split('.');
      for (final p in parts) {
        if (p.trim().isNotEmpty) {
          final match = RegExp(r'(\d+)').firstMatch(p);
          if (match != null) {
            final val = int.tryParse(match.group(1)!);
            if (val != null) numbers.add(val);
          }
        }
      }
    } else {
      // Fallback: extract all numbers in the string
      final matches = RegExp(r'(\d+)').allMatches(cleanName);
      for (final m in matches) {
        final val = int.tryParse(m.group(0)!);
        if (val != null) numbers.add(val);
      }
    }
    return numbers;
  }

  /// Fetch unlinked media items and auto-match them against database entities
  Future<List<SmartLinkSuggestion>> getSmartLinkSuggestions() async {
    try {
      // 1. Get all unlinked files
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_media')
          .select('*')
          .eq('is_linked', false)
          .eq('is_archived', false)
          .order('created_at', ascending: false);

      final unlinkedMediaList = (response as List)
          .map((json) => MediaModel.fromJson(json))
          .toList();

      if (unlinkedMediaList.isEmpty) return [];

      // 2. Parse numbers and derive context
      final List<Map<String, dynamic>> mediaWithNumbers = [];
      final Set<int> allNumbers = {};

      for (final media in unlinkedMediaList) {
        final context = _deriveFolderContext(media.filePath);
        final numbers = _extractNumbers(media.fileName, context);
        allNumbers.addAll(numbers);
        mediaWithNumbers.add({
          'media': media,
          'context': context,
          'numbers': numbers,
        });
      }

      if (allNumbers.isEmpty) {
        return unlinkedMediaList.map((m) => SmartLinkSuggestion(
          media: m,
          folderContext: 'general',
          parsedNumbers: [],
          matchOptions: [],
        )).toList();
      }

      final List<int> numbersList = allNumbers.toList();

      // 3. Bulk query sb_cutdet_summary in parallel
      final cuttingFuture = _db.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .select('MULTI_VNO')
          .inFilter('MULTI_VNO', numbersList);
          // Note: no VNO filter here — sb_cutdet_summary uses MULTI_VNO only

      // 4. Bulk query sq_BILLS in parallel
      final billsFuture = _db.client
          .schema('IMMBE2627')
          .from('sq_BILLS')
          .select('VNO, TYPE, code')
          .inFilter('VNO', numbersList)
          .lt('VNO', 100000);

      final results = await Future.wait([cuttingFuture, billsFuture]);
      final cuttingData = results[0] as List;
      final billsData = results[1] as List;

      // Map db responses to matching sets
      final Set<int> existingCuttingVnos = cuttingData
          .map((row) => (row['MULTI_VNO'] as num).toInt())
          .toSet();

      final Map<int, List<Map<String, dynamic>>> existingBillsByVno = {};
      for (final row in billsData) {
        final vno = (row['VNO'] as num).toInt();
        existingBillsByVno.putIfAbsent(vno, () => []).add(row);
      }

      // 5. Construct suggestions
      final List<SmartLinkSuggestion> suggestions = [];

      for (final item in mediaWithNumbers) {
        final media = item['media'] as MediaModel;
        final context = item['context'] as String;
        final numbers = item['numbers'] as List<int>;
        final List<MatchedEntityOption> options = [];

        for (final numVal in numbers) {
          // If context is cutting, prioritize cutting_batch match
          if (context == 'cutting_report' && existingCuttingVnos.contains(numVal)) {
            options.add(MatchedEntityOption(
              entityType: 'cutting_batch',
              entityId: numVal.toString(),
              entityLabel: 'Cutting Card #$numVal',
            ));
          }

          // Look up in bills
          final matchedBills = existingBillsByVno[numVal] ?? [];
          for (final b in matchedBills) {
            final typeCode = b['TYPE'] as String? ?? '';
            final codeLabel = b['code'] as String? ?? 'N/A';
            
            if (typeCode == 'O5') {
              options.add(MatchedEntityOption(
                entityType: 'stitching_dispatch',
                entityId: numVal.toString(),
                entityLabel: 'Stitching Dispatch O5 #$numVal ($codeLabel)',
                typeCode: 'O5',
              ));
            } else if (typeCode == 'O6') {
              options.add(MatchedEntityOption(
                entityType: 'stitching_receive',
                entityId: numVal.toString(),
                entityLabel: 'Stitching Receive O6 #$numVal ($codeLabel)',
                typeCode: 'O6',
              ));
            } else if (context == 'bilty' && ['S1', 'P1', 'S2', 'P2'].contains(typeCode)) {
              options.add(MatchedEntityOption(
                entityType: 'bill',
                entityId: numVal.toString(),
                entityLabel: 'Invoice $typeCode #$numVal ($codeLabel)',
                typeCode: typeCode,
              ));
            }
          }

          // Fallback matches if not matched yet
          if (context != 'cutting_report' && existingCuttingVnos.contains(numVal)) {
            options.add(MatchedEntityOption(
              entityType: 'cutting_batch',
              entityId: numVal.toString(),
              entityLabel: 'Cutting Card #$numVal',
            ));
          }
        }

        // Auto-assign media_type and side classification for cutting cards
        String? classifiedMediaType = media.mediaType;
        String? side;
        if (context == 'cutting_report') {
          final isBack = media.fileName.contains('(2)') ||
                         media.fileName.toLowerCase().contains('_2');
          side = isBack ? 'B' : 'F';
          classifiedMediaType = 'cutting_card';
        }

        suggestions.add(SmartLinkSuggestion(
          media: media.copyWith(mediaType: classifiedMediaType),
          folderContext: context,
          parsedNumbers: numbers,
          matchOptions: options,
          side: side,
        ));
      }

      return suggestions;
    } catch (e) {
      print('MediaService.getSmartLinkSuggestions error: $e');
      rethrow;
    }
  }

  /// Bulk link multiple suggestion mappings.
  Future<void> bulkLinkSuggestions(
    List<SmartLinkSuggestion> mappings, {
    void Function(int current, int total, String status)? onProgress,
  }) async {
    try {
      final currentUser = _db.client.auth.currentUser;
      final userId = currentUser?.id;
      final total = mappings.length;

      for (int i = 0; i < total; i++) {
        final map = mappings[i];
        if (!map.isChecked || map.selectedOption == null) continue;
        
        onProgress?.call(i + 1, total, 'Linking ${map.media.fileName}');
        
        final mediaId = map.media.id;
        final opt = map.selectedOption!;
        
        // Link media
        await _db.client.schema('IMMBE2627').rpc('link_media_to_entity', params: {
          'p_media_id': mediaId,
          'p_entity_type': opt.entityType,
          'p_entity_id': opt.entityId,
          'p_entity_label': opt.entityLabel,
          'p_linked_by': userId,
        });

        // Set correct classification if it's cutting report
        final updatePayload = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (map.media.mediaType != null) {
          updatePayload['media_type'] = map.media.mediaType;
        }
        if (map.side != null) {
          updatePayload['side'] = map.side;
        }
        if (updatePayload.length > 1) {
          await _db.client.schema('IMMBE2627').from('sb_media').update(updatePayload).eq('id', mediaId);
        }
      }

      // Automatically rename and move storage objects to CC-XXXX-F/B layout inside production/cutting/
      try {
        onProgress?.call(total, total, 'Relocating & renaming files in storage...');
        await renameToCcCode(mappings);
      } catch (e) {
        print('Warning: Automatic CC rename failed post-link: $e');
      }
    } catch (e) {
      print('MediaService.bulkLinkSuggestions error: $e');
      rethrow;
    }
  }

  /// Renames linked cutting card files in Storage to the CC code convention:
  ///   CC-XXXX-F.jpg  (front)  and  CC-XXXX-B.jpg  (back)
  ///
  /// For each [suggestion] that is a cutting_batch with a side set, this method:
  ///   1. Copies the existing storage object to the new CC-coded path
  ///   2. Removes the old object
  ///   3. Updates sb_media.file_path, file_name, display_name, thumb_path
  ///
  /// Returns a map of {mediaId: newPath} for successfully renamed files.
  Future<Map<String, String>> renameToCcCode(List<SmartLinkSuggestion> suggestions) async {
    final Map<String, String> renamed = {};
    final List<String> errors = [];

    for (final s in suggestions) {
      // Only process cutting card suggestions with a resolved entity and side
      if (s.selectedOption?.entityType != 'cutting_batch') continue;
      if (s.side == null) continue;
      if (!s.isChecked) continue;

      final entityId = s.selectedOption!.entityId;
      final side = s.side!; // 'F' or 'B'
      final media = s.media;

      // Build the CC code (e.g. CC-0001)
      final multiVno = int.tryParse(entityId) ?? 0;
      final ccCode = 'CC-${multiVno.toString().padLeft(4, '0')}';

      // Preserve original extension
      final ext = media.fileName.contains('.') ? media.fileName.split('.').last.toLowerCase() : 'jpg';
      final newFileName = '$ccCode-$side.$ext';

      // Build new storage path inside production/cutting/$entityId/
      final newFilePath = 'production/cutting/$entityId/$newFileName';

      // Skip if already at the correct name
      if (media.filePath == newFilePath) {
        renamed[media.id] = newFilePath;
        continue;
      }

      try {
        // 1. Copy to new path
        await _db.client.storage.from('ambaji-media').copy(media.filePath, newFilePath);

        // 2. Remove old path
        await _db.client.storage.from('ambaji-media').remove([media.filePath]);

        // 3. Handle thumbnail rename if present
        String? newThumbPath;
        if (media.thumbPath != null && media.thumbPath!.isNotEmpty) {
          newThumbPath = 'production/cutting/$entityId/thumbnails/$newFileName';
          try {
            await _db.client.storage.from('ambaji-media').copy(media.thumbPath!, newThumbPath);
            await _db.client.storage.from('ambaji-media').remove([media.thumbPath!]);
          } catch (_) {
            newThumbPath = null; // thumb rename failed non-critically
          }
        }

        // 4. Update sb_media metadata
        await _db.client.schema('IMMBE2627').from('sb_media').update({
          'file_path': newFilePath,
          'file_name': newFileName,
          'display_name': '$ccCode · ${side == 'F' ? 'Front' : 'Back'}',
          if (newThumbPath != null) 'thumb_path': newThumbPath,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', media.id);

        renamed[media.id] = newFilePath;
      } catch (e) {
        errors.add('${media.fileName}: $e');
        print('renameToCcCode error for ${media.fileName}: $e');
      }
    }

    if (errors.isNotEmpty) {
      print('renameToCcCode completed with ${errors.length} error(s): ${errors.join(', ')}');
    }
    return renamed;
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}

class CompressedMediaResult {
  final Uint8List mainBytes;
  final Uint8List thumbBytes;
  CompressedMediaResult({required this.mainBytes, required this.thumbBytes});
}

class ImageProcessor {
  static CompressedMediaResult? compressAndThumbnail(Uint8List inputBytes) {
    try {
      final decoded = img.decodeImage(inputBytes);
      if (decoded == null) return null;

      // 1. Resize main image if width/height > 1600px
      img.Image mainImage = decoded;
      if (decoded.width > 1600 || decoded.height > 1600) {
        mainImage = img.copyResize(
          decoded,
          width: decoded.width > decoded.height ? 1600 : null,
          height: decoded.height >= decoded.width ? 1600 : null,
        );
      }
      final mainBytes = Uint8List.fromList(img.encodeJpg(mainImage, quality: 80));

      // 2. Generate 400px thumbnail
      final thumbImage = img.copyResize(
        mainImage,
        width: mainImage.width > mainImage.height ? 400 : null,
        height: mainImage.height >= mainImage.width ? 400 : null,
      );
      final thumbBytes = Uint8List.fromList(img.encodeJpg(thumbImage, quality: 80));

      return CompressedMediaResult(mainBytes: mainBytes, thumbBytes: thumbBytes);
    } catch (e) {
      print('Image compression error: $e');
      return null;
    }
  }
}
