/// [SyncLogModel] — Represents a single sync execution log entry from sb_sync_log.
class SyncLogModel {
  final String id;
  final DateTime capturedAt;
  final String tableName;
  final int rowCount;
  final int prevCount;
  final int delta;
  final String syncGroup;
  final String syncMode;

  SyncLogModel({
    required this.id,
    required this.capturedAt,
    required this.tableName,
    required this.rowCount,
    required this.prevCount,
    required this.delta,
    required this.syncGroup,
    required this.syncMode,
  });

  factory SyncLogModel.fromJson(Map<String, dynamic> json) {
    return SyncLogModel(
      id: json['id'] ?? '',
      capturedAt: json['captured_at'] != null 
          ? DateTime.tryParse(json['captured_at']) ?? DateTime.now()
          : DateTime.now(),
      tableName: json['table_name'] ?? '',
      rowCount: (json['row_count'] as num?)?.toInt() ?? 0,
      prevCount: (json['prev_count'] as num?)?.toInt() ?? 0,
      delta: (json['delta'] as num?)?.toInt() ?? 0,
      syncGroup: json['sync_group'] ?? 'general',
      syncMode: json['sync_mode'] ?? 'incremental',
    );
  }
}

/// [SyncGroupSummary] — Combines telemetry for a logical group of tables.
class SyncGroupSummary {
  final String name;
  final String description;
  final int totalTables;
  final int activeTables;
  final int totalRowCount;
  final int totalDelta24h;
  final DateTime? lastSyncTime;
  final List<SyncTableStatus> tables;

  SyncGroupSummary({
    required this.name,
    required this.description,
    required this.totalTables,
    required this.activeTables,
    required this.totalRowCount,
    required this.totalDelta24h,
    this.lastSyncTime,
    required this.tables,
  });
}

/// [SyncTableStatus] — Holds status for a single table in the dashboard.
class SyncTableStatus {
  final String name;
  final int rowCount;
  final int delta24h;
  final DateTime? lastSyncTime;
  final bool isStagnant; // True if no sync extraction updates for a long time
  final String lastExtractedAt;

  SyncTableStatus({
    required this.name,
    required this.rowCount,
    required this.delta24h,
    this.lastSyncTime,
    required this.isStagnant,
    required this.lastExtractedAt,
  });
}
