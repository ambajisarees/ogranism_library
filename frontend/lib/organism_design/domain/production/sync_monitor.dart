import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../general/meta.dart';

class OrganSyncMonitor extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSync;
  final Map<String, int> tableCounts;
  final VoidCallback onRefresh;

  const OrganSyncMonitor({
    super.key,
    required this.isSyncing,
    this.lastSync,
    required this.tableCounts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, colors),
          const SizedBox(height: OrganismTheme.spacingLg),
          _buildTableList(context, colors),
          const SizedBox(height: OrganismTheme.spacingLg),
          CellButton(
            text: isSyncing ? 'Syncing...' : 'Force Sync (Airbyte)',
            icon: isSyncing ? LucideIcons.loader2 : LucideIcons.refreshCw,
            variant: CellButtonVariant.outline,
            onPressed: isSyncing ? null : onRefresh,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OrganismColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supabase Heartbeat',
              style: OrganismTheme.titleSmall(context),
            ),
            const SizedBox(height: 4),
            DomainSyncStatus(isSynced: !isSyncing),
          ],
        ),
        if (lastSync != null)
          Text(
            'Refreshed ${lastSync!.hour}:${lastSync!.minute.toString().padLeft(2, '0')}',
            style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
          ),
      ],
    );
  }

  Widget _buildTableList(BuildContext context, OrganismColors colors) {
    return Column(
      children: tableCounts.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: OrganismTheme.monoBody(context).copyWith(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                entry.value.toString(),
                style: OrganismTheme.numericMedium(context).copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
