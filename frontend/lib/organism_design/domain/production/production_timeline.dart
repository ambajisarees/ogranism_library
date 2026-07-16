import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../types.dart';
import 'stage_icon.dart';
import 'stage_badge.dart';

/// [DomainProductionTimeline] — Linear progression of a Saree Slip.
///
/// Visualizes the flow from O3 → O4 → ... → O45.
/// Highlights the current active stage and completed history.
class DomainProductionTimeline extends StatelessWidget {
  final DomainProductionStage currentStage;
  final List<DomainProductionStage> completedStages;

  const DomainProductionTimeline({
    super.key,
    required this.currentStage,
    this.completedStages = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final stages = DomainProductionStage.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stages.map((stage) {
          final isCurrent = stage == currentStage;
          final isCompleted = completedStages.contains(stage) || stages.indexOf(stage) < stages.indexOf(currentStage);
          final isLast = stage == stages.last;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStageNode(context, stage, isCurrent, isCompleted),
              if (!isLast) _buildConnector(colors, isCompleted),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStageNode(BuildContext context, DomainProductionStage stage, bool isCurrent, bool isCompleted) {
    final colors = OrganismTheme.colorsOf(context);
    
    return Tooltip(
      message: stage.name.toUpperCase(),
      child: Container(
        padding: const EdgeInsets.all(OrganismTheme.spacingXs),
        decoration: BoxDecoration(
          color: isCurrent ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCurrent ? colors.primary : (isCompleted ? colors.success : colors.border),
            width: 2,
          ),
        ),
        child: DomainStageIcon(
          stage: stage,
          size: 16,
          color: isCurrent ? colors.primary : (isCompleted ? colors.success : colors.textMuted),
        ),
      ),
    );
  }

  Widget _buildConnector(OrganismColors colors, bool isCompleted) {
    return Container(
      width: 24,
      height: 2,
      color: isCompleted ? colors.success : colors.border,
    );
  }
}
