import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../organism_design/index.dart';
import '../../../../services/production/service_tasks.dart';

/// [TasksTab] — Production Pipeline Tasks Dashboard & Smart Row Linker workspace.
class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _service = PipelineTasksService();

  List<CuttingLinkSuggestion> _cuttingSuggestions = [];
  List<JobInwardLinkSuggestion> _inwardSuggestions = [];

  bool _isLoading = false;
  int _unlinkedDispatchesCount = 0;
  int _unlinkedReceivesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final unlinkedDisp = await _service.getUnlinkedDispatchLines();
      final unlinkedRec = await _service.getUnlinkedReceiveLines();
      final cuttingSug = await _service.getCuttingLinkSuggestions();
      final inwardSug = await _service.getJobInwardSuggestions();

      if (mounted) {
        setState(() {
          _unlinkedDispatchesCount = unlinkedDisp.length;
          _unlinkedReceivesCount = unlinkedRec.length;
          _cuttingSuggestions = cuttingSug;
          _inwardSuggestions = inwardSug;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reconcileCuttingLink(CuttingLinkSuggestion sug) async {
    setState(() => _isLoading = true);
    try {
      final success = await _service.linkDispatchToCuttingCard(
        dispatchVno: sug.dispatch.vno,
        cuttingCardNo: sug.cuttingCard.multiVno,
      );

      if (success) {
        // Show success banner toast in workspace
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully linked Job Card #${sug.dispatch.vno} with Cutting Card ${sug.cuttingCard.ccCode}!'),
              backgroundColor: OrganismTheme.colorsOf(context).success,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Reconciliation error: $e');
    } finally {
      _loadSuggestions();
    }
  }

  Future<void> _reconcileJobInwardLink(JobInwardLinkSuggestion sug) async {
    setState(() => _isLoading = true);
    try {
      final success = await _service.linkReceiveToDispatch(
        receiveVno: sug.receive.vno,
        dispatchVno: sug.dispatch.vno,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully linked Inward Receive #${sug.receive.vno} to Dispatch #${sug.dispatch.vno}!'),
              backgroundColor: OrganismTheme.colorsOf(context).success,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Reconciliation error: $e');
    } finally {
      _loadSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner & Workspace Summary KPIs
          _buildWorkspaceHeader(colors),

          // 2. Kanban Board Columns
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingLg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Column 1: Cutting Link Suggestions
                  Expanded(
                    child: _buildKanbanColumn(
                      title: 'Cutting Links',
                      subtitle: 'Pair Stitching Dispatches with Cutting batches',
                      badgeCount: _cuttingSuggestions.length,
                      icon: LucideIcons.scissors,
                      child: _buildCuttingSuggestionsList(colors),
                    ),
                  ),
                  const SizedBox(width: OrganismTheme.spacingLg),

                  // Column 2: Inward Job Work Links
                  Expanded(
                    child: _buildKanbanColumn(
                      title: 'Job Inward Links',
                      subtitle: 'Pair Stitching Receives back to Dispatches',
                      badgeCount: _inwardSuggestions.length,
                      icon: LucideIcons.packageCheck,
                      child: _buildInwardSuggestionsList(colors),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingLg),
        ],
      ),
    );
  }

  Widget _buildWorkspaceHeader(OrganismColors colors) {
    return Container(
      color: colors.surfaceMuted,
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      margin: const EdgeInsets.only(bottom: OrganismTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reconciliation Dashboard',
                      style: OrganismTheme.titleLarge(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart row diagnostics and linking across manufacturing files.',
                      style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              CellButton(
                text: 'Refresh Board',
                icon: LucideIcons.refreshCw,
                variant: CellButtonVariant.outline,
                onPressed: _isLoading ? null : _loadSuggestions,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildKPIBox(
                colors,
                'UNLINKED DISPATCHES',
                '$_unlinkedDispatchesCount',
                colors.error.withValues(alpha: 0.1),
                colors.error,
              ),
              const SizedBox(width: 16),
              _buildKPIBox(
                colors,
                'PENDING RECEIVES',
                '$_unlinkedReceivesCount',
                colors.warning.withValues(alpha: 0.1),
                colors.warning,
              ),
              const SizedBox(width: 16),
              _buildKPIBox(
                colors,
                'AUTO-MATCHED PAIRS',
                '${_cuttingSuggestions.length + _inwardSuggestions.length}',
                colors.primary.withValues(alpha: 0.1),
                colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIBox(
    OrganismColors colors,
    String label,
    String count,
    Color bg,
    Color text,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(OrganismTheme.spacingMd),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count,
                style: OrganismTheme.monoBody(context).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: text,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: OrganismTheme.labelSmall(context).copyWith(
                  color: colors.textMuted,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required String subtitle,
    required int badgeCount,
    required IconData icon,
    required Widget child,
  }) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(OrganismTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: colors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: OrganismTheme.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 10, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    '$badgeCount pending',
                    style: OrganismTheme.labelSmall(context).copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Cards List
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildCuttingSuggestionsList(OrganismColors colors) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_cuttingSuggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.sparkles, size: 28, color: colors.success),
            const SizedBox(height: 12),
            Text(
              'All Cutting Links Reconciled',
              style: OrganismTheme.titleMedium(context).copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              'No unlinked stitching dispatches require matches.',
              style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      itemCount: _cuttingSuggestions.length,
      itemBuilder: (context, index) {
        final sug = _cuttingSuggestions[index];
        final matchPct = (sug.score * 100).toInt();

        Color badgeColor = colors.warning;
        if (sug.score >= 0.85) badgeColor = colors.success;
        if (sug.score < 0.60) badgeColor = colors.error;

        return Container(
          margin: const EdgeInsets.only(bottom: OrganismTheme.spacingMd),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
            boxShadow: OrganismTheme.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Suggestion Header with confidence badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suggested Match',
                      style: OrganismTheme.labelSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$matchPct% Match',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Comparison pane (Side-by-side comparison)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Left: Stitching Dispatch details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'JOB CARD #${sug.dispatch.vno}',
                            style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sug.dispatch.tailorName ?? sug.dispatch.tailorCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            sug.dispatchLine.quality,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: colors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${sug.dispatchLine.pieces.toInt()} PCS • ${sug.dispatch.date.toIso8601String().split('T')[0]}',
                            style: OrganismTheme.monoBody(context).copyWith(fontSize: 10, color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),

                    Icon(LucideIcons.link, size: 14, color: colors.primary),

                    // Right: Cutting Card Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CUTTING CARD ${sug.cuttingCard.ccCode}',
                              style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sug.cuttingCard.mill,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              sug.cuttingCard.greyQual,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: colors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${sug.cuttingCard.totalFreshPcs} PCS • ${sug.cuttingCard.cutDate.toIso8601String().split('T')[0]}',
                              style: OrganismTheme.monoBody(context).copyWith(fontSize: 10, color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Reason bar & Reconcile Button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      sug.matchReason,
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: colors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    CellButton(
                      text: 'Auto Reconcile & Link',
                      icon: LucideIcons.checkCheck,
                      variant: CellButtonVariant.primary,
                      isCompact: true,
                      onPressed: () => _reconcileCuttingLink(sug),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInwardSuggestionsList(OrganismColors colors) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_inwardSuggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.sparkles, size: 28, color: colors.success),
            const SizedBox(height: 12),
            Text(
              'All Inwards Reconciled',
              style: OrganismTheme.titleMedium(context).copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              'No unlinked stitching inward receives require matches.',
              style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      itemCount: _inwardSuggestions.length,
      itemBuilder: (context, index) {
        final sug = _inwardSuggestions[index];
        final matchPct = (sug.score * 100).toInt();

        Color badgeColor = colors.warning;
        if (sug.score >= 0.85) badgeColor = colors.success;
        if (sug.score < 0.60) badgeColor = colors.error;

        return Container(
          margin: const EdgeInsets.only(bottom: OrganismTheme.spacingMd),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
            boxShadow: OrganismTheme.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suggested Match',
                      style: OrganismTheme.labelSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$matchPct% Match',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Left: Stitching Receive (O6)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INWARD RECEIVE #${sug.receive.vno}',
                            style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sug.receive.tailorName ?? sug.receive.tailorCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            sug.receiveLine.quality,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: colors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${sug.receiveLine.pieces.toInt()} PCS • ${sug.receive.date.toIso8601String().split('T')[0]}',
                            style: OrganismTheme.monoBody(context).copyWith(fontSize: 10, color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),

                    Icon(LucideIcons.link, size: 14, color: colors.primary),

                    // Right: Stitching Dispatch (O5)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PARENT DISPATCH #${sug.dispatch.vno}',
                              style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sug.dispatch.tailorName ?? sug.dispatch.tailorCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              sug.dispatchLine.quality,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: colors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${sug.dispatchLine.pieces.toInt()} PCS • ${sug.dispatch.date.toIso8601String().split('T')[0]}',
                              style: OrganismTheme.monoBody(context).copyWith(fontSize: 10, color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      sug.matchReason,
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: colors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    CellButton(
                      text: 'Auto Settle & Link',
                      icon: LucideIcons.checkCheck,
                      variant: CellButtonVariant.primary,
                      isCompact: true,
                      onPressed: () => _reconcileJobInwardLink(sug),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
