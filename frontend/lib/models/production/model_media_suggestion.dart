import 'model_media.dart';


/// Represents a matched entity target option (e.g., a specific Cutting Batch or Stitching Dispatch)
class MatchedEntityOption {
  final String entityType; // 'cutting_batch', 'stitching_dispatch', 'stitching_receive', 'bill'
  final String entityId;   // e.g. '147'
  final String entityLabel;// e.g. 'Cutting Card #147' or 'Stitching Dispatch #5040'
  final String? typeCode;  // e.g. 'O5', 'O6', 'S1' (useful for voucher types)

  MatchedEntityOption({
    required this.entityType,
    required this.entityId,
    required this.entityLabel,
    this.typeCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchedEntityOption &&
          runtimeType == other.runtimeType &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          typeCode == other.typeCode;

  @override
  int get hashCode => entityType.hashCode ^ entityId.hashCode ^ typeCode.hashCode;
}

/// Represents the matching status and auto-linking suggestion details for an unlinked file
class SmartLinkSuggestion {
  final MediaModel media;
  final String folderContext; // 'cutting_report', 'bilty', 'challan', 'job_card', 'general'
  final List<int> parsedNumbers;
  final List<MatchedEntityOption> matchOptions;
  
  /// For cutting cards: 'F' = front (no suffix), 'B' = back (has " (2)" suffix), null = other doc types
  final String? side;

  // Selected option by user (defaults to the first/highest priority option if any)
  MatchedEntityOption? selectedOption;
  bool isChecked;

  SmartLinkSuggestion({
    required this.media,
    required this.folderContext,
    required this.parsedNumbers,
    required this.matchOptions,
    this.side,
    this.isChecked = true,
  }) {
    // Automatically select the first option if matches exist
    if (matchOptions.isNotEmpty) {
      selectedOption = matchOptions.first;
    }
  }

  /// Whether this file was successfully auto-matched to at least one entity
  bool get hasMatches => matchOptions.isNotEmpty;

  /// Display label for the side chip
  String get sideLabel {
    if (side == 'F') return 'FRONT';
    if (side == 'B') return 'BACK';
    return '';
  }
}

