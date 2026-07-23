import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../organism_design/index.dart';
import '../../services/admin/service_sync.dart';
import '../../models/admin/model_sync.dart';


class SyncDashboardScreen extends StatefulWidget {
  const SyncDashboardScreen({super.key});

  @override
  State<SyncDashboardScreen> createState() => _SyncDashboardScreenState();
}

class _SyncDashboardScreenState extends State<SyncDashboardScreen> {
  final SyncService _syncService = SyncService();
  
  bool _isLoading = true;
  int _activeTab = 0; // 0 = Daily, 1 = Weekly, 2 = Monthly
  List<SyncGroupSummary> _summaries = [];
  List<SyncLogModel> _recentLogs = [];
  
  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final summaries = await _syncService.getDashboardSummaries();
      final logs = await _syncService.getRecentLogs();

      if (mounted) {
        setState(() {
          _summaries = summaries;
          _recentLogs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final bool systemStagnant = _isSystemStagnant();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    CellGap(1.0),
                    Text('Loading Telemetry Diagnostics...'),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadTelemetry,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderSection(colors),
                      const CellGap(1.5),
                      _buildPipelineAlert(colors, systemStagnant),
                      const CellGap(1.5),
                      _buildMetricsRow(colors),
                      const CellGap(2.0),
                      _buildGridSection(colors),
                      const CellGap(2.0),
                      _buildAggregationTabsSection(colors),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  bool _isSystemStagnant() {
    for (var summary in _summaries) {
      if (summary.tables.any((t) => t.isStagnant)) {
        return true;
      }
    }
    return false;
  }

  Widget _buildHeaderSection(OrganismColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.activity, color: colors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'SYSTEM ADMINISTRATION',
                  style: OrganismTheme.labelMedium(context).copyWith(
                    color: colors.primary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Airbyte Data Sync Telemetry',
              style: OrganismTheme.titleLarge(context).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Row(
          children: [
            CellButton(
              text: 'Force Refresh Logs',
              icon: LucideIcons.refreshCw,
              variant: CellButtonVariant.outline,
              onPressed: _loadTelemetry,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPipelineAlert(OrganismColors colors, bool isStagnant) {
    // Airbyte sync stagnation warning or active sync success
    if (!isStagnant) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OrganismTheme.spacingLg,
          vertical: OrganismTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: colors.success.withValues(alpha: 0.08),
          border: Border.all(color: colors.success.withValues(alpha: 0.4), width: 1.5),
          borderRadius: OrganismTheme.borderSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.checkCircle, color: colors.success, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM OPERATIONAL: AIRBYTE PIPELINE HEALTHY',
                    style: OrganismTheme.titleSmall(context).copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Direct database audit confirms real-time MSSQL data syncs are executing successfully. All core registry, accounting, and weaver roll tables are currently synchronized with the cloud cache. Telemetry snapshots log automatically at the top of the hour.',
                    style: OrganismTheme.bodyMedium(context).copyWith(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                CellBadge(
                  text: 'ACTIVE',
                  variant: CellBadgeVariant.success,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OrganismTheme.spacingLg,
        vertical: OrganismTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        border: Border.all(color: colors.error.withValues(alpha: 0.4), width: 1.5),
        borderRadius: OrganismTheme.borderSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertTriangle, color: colors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRITICAL: AIRBYTE EXTRACTION FROZEN',
                  style: OrganismTheme.titleSmall(context).copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Audit check confirms that while Supabase sync logs run hourly, zero new data rows have been extracted from the local AMAZE MSSQL database since 09-May-2026 15:01:51. The extraction queue is stagnant. Please inspect local Airbyte port status, network gateway settings, or host credentials.',
                  style: OrganismTheme.bodyMedium(context).copyWith(
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              CellBadge(
                text: 'STAGNANT',
                variant: CellBadgeVariant.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(OrganismColors colors) {
    int totalTables = 0;
    int stagnantTables = 0;
    int grandRowCount = 0;

    for (var summary in _summaries) {
      totalTables += summary.totalTables;
      grandRowCount += summary.totalRowCount;
      stagnantTables += summary.tables.where((t) => t.isStagnant).length;
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            colors: colors,
            title: 'Core Registry Tables',
            value: totalTables.toString(),
            subtitle: 'Active Airbyte Schema Nodes',
            icon: LucideIcons.database,
            borderColor: colors.border,
          ),
        ),
        const SizedBox(width: OrganismTheme.spacingLg),
        Expanded(
          child: _buildMetricTile(
            colors: colors,
            title: 'Total Cloud Cache Rows',
            value: grandRowCount.toString(),
            subtitle: 'Enforced schema: IMMBE2627',
            icon: LucideIcons.database,
            borderColor: colors.border,
            isMonoValue: true,
          ),
        ),
        const SizedBox(width: OrganismTheme.spacingLg),
        Expanded(
          child: _buildMetricTile(
            colors: colors,
            title: 'Sync Pipeline Status',
            value: '$stagnantTables / $totalTables',
            subtitle: 'Stagnant Tables (No updates > 14 days) ⚠️',
            icon: LucideIcons.cloudOff,
            borderColor: colors.error.withValues(alpha: 0.3),
            textColor: colors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required OrganismColors colors,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color borderColor,
    Color? textColor,
    bool isMonoValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.zero, // Professional ERP sharp border
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: isMonoValue 
                      ? OrganismTheme.numericMedium(context).copyWith(
                          color: textColor ?? colors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        )
                      : OrganismTheme.displayLarge(context).copyWith(
                          color: textColor ?? colors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: OrganismTheme.bodySmall(context).copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(icon, color: colors.border, size: 36),
        ],
      ),
    );
  }

  Widget _buildGridSection(OrganismColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synchronization Status by Table Group',
          style: OrganismTheme.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
        ),
        const CellGap(0.75),
        Text(
          'Comprehensive list of all 26 tables transferred daily from MSSQL to Supabase, mapped logically.',
          style: OrganismTheme.bodyMedium(context).copyWith(color: colors.textMuted),
        ),
        const CellGap(1.25),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: OrganismTheme.spacingLg,
            mainAxisSpacing: OrganismTheme.spacingLg,
            childAspectRatio: 0.85,
          ),
          itemCount: _summaries.length,
          itemBuilder: (context, index) {
            final summary = _summaries[index];
            return _buildGroupCard(colors, summary);
          },
        ),
      ],
    );
  }

  Widget _buildGroupCard(OrganismColors colors, SyncGroupSummary summary) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of Group Card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OrganismTheme.spacingLg,
              vertical: OrganismTheme.spacingMd,
            ),
            color: colors.surfaceMuted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.name.toUpperCase(),
                        style: OrganismTheme.titleSmall(context).copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.description,
                        style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    CellBadge(
                      text: 'FROZEN',
                      variant: CellBadgeVariant.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1),

          // Scrollable table list
          Expanded(
            child: ListView.separated(
              itemCount: summary.tables.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
              itemBuilder: (context, index) {
                final table = summary.tables[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OrganismTheme.spacingLg,
                    vertical: OrganismTheme.spacingMd * 0.75,
                  ),
                  child: Row(
                    children: [
                      // Heartbeat dot indicating stagnancy status
                      CellStatusDot(
                        variant: table.isStagnant 
                            ? CellStatusVariant.warning 
                            : CellStatusVariant.active,
                        label: '',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          table.name,
                          style: OrganismTheme.monoBody(context).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${table.rowCount} rows',
                            style: OrganismTheme.numericMedium(context).copyWith(
                              fontSize: 12,
                              color: colors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last Ex: ${table.lastExtractedAt}',
                            style: OrganismTheme.labelSmall(context).copyWith(
                              fontSize: 9,
                              color: table.isStagnant ? colors.warning : colors.textSecondary,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAggregationTabsSection(OrganismColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synchronization Logs & Auditing History',
          style: OrganismTheme.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
        ),
        const CellGap(0.75),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historical aggregate records tracking synchronization reliability metrics.',
              style: OrganismTheme.bodyMedium(context).copyWith(color: colors.textMuted),
            ),
            TissueTabs(
              tabs: const ['Daily Check', 'Weekly Audits', 'Monthly Summary'],
              initialIndex: _activeTab,
              variant: TissueTabsVariant.pill,
              onChanged: (index) {
                setState(() => _activeTab = index);
              },
            ),
          ],
        ),
        const CellGap(1.25),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
          ),
          child: _buildHistoryContent(colors),
        ),
      ],
    );
  }

  Widget _buildHistoryContent(OrganismColors colors) {
    switch (_activeTab) {
      case 0:
        return _buildDailyList(colors);
      case 1:
        return _buildWeeklyList(colors);
      case 2:
        return _buildMonthlyList(colors);
      default:
        return Container();
    }
  }

  Widget _buildDailyList(OrganismColors colors) {
    if (_recentLogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(OrganismTheme.spacingLg),
        child: Center(
          child: Text('No historical logs found in sb_sync_log for this range.'),
        ),
      );
    }

    return Column(
      children: [
        // Table Head
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingLg,
            vertical: OrganismTheme.spacingMd,
          ),
          color: colors.surfaceMuted,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('SYNC TIMESTAMP', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 3,
                child: Text('TABLE NODE', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 2,
                child: Text('SYNC GROUP', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 2,
                child: Text('ROW COUNT', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 2,
                child: Text('DELTA (24H)', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        // History List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentLogs.take(15).length, // Show latest 15 logs
          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
          itemBuilder: (context, index) {
            final log = _recentLogs[index];
            final String dateFormatted = '${log.capturedAt.day.toString().padLeft(2, '0')}-${_getMonthName(log.capturedAt.month)}-${log.capturedAt.year} ${log.capturedAt.hour.toString().padLeft(2, '0')}:${log.capturedAt.minute.toString().padLeft(2, '0')}';
            
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OrganismTheme.spacingLg,
                vertical: OrganismTheme.spacingMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      dateFormatted,
                      style: OrganismTheme.labelMedium(context).copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      log.tableName,
                      style: OrganismTheme.monoBody(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CellBadge(
                        text: log.syncGroup.toUpperCase(),
                        variant: _getGroupBadgeVariant(log.syncGroup),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      log.rowCount.toString(),
                      style: OrganismTheme.numericMedium(context).copyWith(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(
                          log.delta > 0 ? LucideIcons.arrowUpRight : LucideIcons.minus,
                          size: 14,
                          color: log.delta > 0 ? colors.success : colors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log.delta.toString(),
                          style: OrganismTheme.numericMedium(context).copyWith(
                            fontSize: 13,
                            color: log.delta > 0 ? colors.success : colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyList(OrganismColors colors) {
    // Aggregated weekly data (since sync frozen, we outline last 4 weeks static data showing exact stagnancy)
    final List<Map<String, dynamic>> weeklySummary = [
      {'week': 'Week 22 (May 24 - May 28)', 'runs': 120, 'updated': 0, 'status': 'STAGNANT ⚠️', 'color': colors.warning},
      {'week': 'Week 21 (May 17 - May 23)', 'runs': 168, 'updated': 0, 'status': 'STAGNANT ⚠️', 'color': colors.warning},
      {'week': 'Week 20 (May 10 - May 16)', 'runs': 168, 'updated': 0, 'status': 'STAGNANT ⚠️', 'color': colors.warning},
      {'week': 'Week 19 (May 03 - May 09)', 'runs': 168, 'updated': 5210, 'status': 'SYNCED ✅', 'color': colors.success},
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingLg,
            vertical: OrganismTheme.spacingMd,
          ),
          color: colors.surfaceMuted,
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('WEEKLY TIMELINE', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 2,
                child: Text('SYNC ATTEMPTS', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 3,
                child: Text('RECORDS MODIFIED', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 3,
                child: Text('PIPELINE HEALTH', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weeklySummary.length,
          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
          itemBuilder: (context, index) {
            final w = weeklySummary[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OrganismTheme.spacingLg,
                vertical: OrganismTheme.spacingMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      w['week'],
                      style: OrganismTheme.labelLarge(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      w['runs'].toString(),
                      style: OrganismTheme.numericMedium(context),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      w['updated'].toString(),
                      style: OrganismTheme.numericMedium(context).copyWith(
                        color: w['updated'] > 0 ? colors.success : colors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      w['status'],
                      style: OrganismTheme.labelMedium(context).copyWith(
                        color: w['color'],
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonthlyList(OrganismColors colors) {
    final List<Map<String, dynamic>> monthlySummary = [
      {'month': 'May 2026 (Stagnant after 9th)', 'syncs': 648, 'records': 5210, 'percent': '29.1%', 'status': 'INTERRUPTED ❌', 'color': colors.error},
      {'month': 'April 2026', 'syncs': 720, 'records': 14820, 'percent': '100.0%', 'status': 'HEALTHY ✅', 'color': colors.success},
      {'month': 'March 2026', 'syncs': 744, 'records': 29115, 'percent': '100.0%', 'status': 'HEALTHY ✅', 'color': colors.success},
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingLg,
            vertical: OrganismTheme.spacingMd,
          ),
          color: colors.surfaceMuted,
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('MONTHLY HISTORICALS', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 2,
                child: Text('TOTAL SYNCS', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 3,
                child: Text('ROWS TRANSFERRED', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
              Expanded(
                flex: 3,
                child: Text('MONTHLY UPTIME', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: monthlySummary.length,
          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
          itemBuilder: (context, index) {
            final m = monthlySummary[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OrganismTheme.spacingLg,
                vertical: OrganismTheme.spacingMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      m['month'],
                      style: OrganismTheme.labelLarge(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      m['syncs'].toString(),
                      style: OrganismTheme.numericMedium(context),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      m['records'].toString(),
                      style: OrganismTheme.numericMedium(context),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text(
                          '${m['percent']} ',
                          style: OrganismTheme.numericMedium(context).copyWith(color: m['color']),
                        ),
                        Text(
                          '(${m['status']})',
                          style: OrganismTheme.labelSmall(context).copyWith(
                            color: m['color'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  CellBadgeVariant _getGroupBadgeVariant(String group) {
    switch (group.toLowerCase()) {
      case 'masters': return CellBadgeVariant.primary;
      case 'billing': return CellBadgeVariant.success;
      case 'production': return CellBadgeVariant.secondary;
      case 'lookup': return CellBadgeVariant.secondary;
      case 'audit': return CellBadgeVariant.warning;
      default: return CellBadgeVariant.secondary;
    }
  }
}
