import 'dart:math';
import 'package:meta/meta.dart';

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

List<String> _parseTags(dynamic tags) {
  if (tags == null) return [];
  if (tags is List) {
    return tags.map((t) => t.toString()).toList();
  }
  return [];
}

/// [MediaModel] — Represents a media file record from the `sb_media` metadata table.
@immutable
class MediaModel {
  final String id;
  final String filePath;
  final String fileName;
  final String? displayName;
  final int fileSize; // bytes
  final String mimeType;
  final int? width;
  final int? height;
  final String bucket;
  final String? mediaType;
  final List<String> tags;
  final String? entityType;
  final String? entityId;
  final String? entityLabel;
  final bool isLinked;
  final String? thumbPath;
  final String? compressedPath;
  final String? uploaderName;
  final DateTime createdAt;
  final String? side; // 'F' = front, 'B' = back, null = single/other

  const MediaModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    this.displayName,
    required this.fileSize,
    required this.mimeType,
    this.width,
    this.height,
    required this.bucket,
    this.mediaType,
    required this.tags,
    this.entityType,
    this.entityId,
    this.entityLabel,
    required this.isLinked,
    this.thumbPath,
    this.compressedPath,
    this.uploaderName,
    required this.createdAt,
    this.side,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      displayName: json['display_name'] as String?,
      fileSize: _parseInt(json['file_size']),
      mimeType: json['mime_type'] as String? ?? 'application/octet-stream',
      width: json['width'] != null ? _parseInt(json['width']) : null,
      height: json['height'] != null ? _parseInt(json['height']) : null,
      bucket: json['bucket'] as String? ?? 'general',
      mediaType: json['media_type'] as String?,
      tags: _parseTags(json['tags']),
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as String?,
      entityLabel: json['entity_label'] as String?,
      isLinked: json['is_linked'] as bool? ?? false,
      thumbPath: json['thumb_path'] as String?,
      compressedPath: json['compressed_path'] as String?,
      uploaderName: json['uploader_name'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      side: json['side'] as String?,
    );
  }

  MediaModel copyWith({
    String? id,
    String? filePath,
    String? fileName,
    String? displayName,
    int? fileSize,
    String? mimeType,
    int? width,
    int? height,
    String? bucket,
    String? mediaType,
    List<String>? tags,
    String? entityType,
    String? entityId,
    String? entityLabel,
    bool? isLinked,
    String? thumbPath,
    String? compressedPath,
    String? uploaderName,
    DateTime? createdAt,
    Object? side = _sentinel,
  }) {
    return MediaModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      displayName: displayName ?? this.displayName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      bucket: bucket ?? this.bucket,
      mediaType: mediaType ?? this.mediaType,
      tags: tags ?? this.tags,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityLabel: entityLabel ?? this.entityLabel,
      isLinked: isLinked ?? this.isLinked,
      thumbPath: thumbPath ?? this.thumbPath,
      compressedPath: compressedPath ?? this.compressedPath,
      uploaderName: uploaderName ?? this.uploaderName,
      createdAt: createdAt ?? this.createdAt,
      side: side == _sentinel ? this.side : side as String?,
    );
  }

  // Computed getters
  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';
  String get fileSizeFormatted => _formatBytes(fileSize);
  String get bucketLabel => bucket.isEmpty ? 'General' : (bucket[0].toUpperCase() + bucket.substring(1));
  /// Human-readable side label
  String get sideLabel {
    if (side == 'F') return 'FRONT';
    if (side == 'B') return 'BACK';
    return '';
  }

  static const Object _sentinel = Object();

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }
}
