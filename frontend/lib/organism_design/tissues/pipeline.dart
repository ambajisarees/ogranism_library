import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellGap

/// [TissuePipeline] — Continuous linear stage stepper molecule.
///
/// Handles sequential tracking visualizer with standard stage line traces.
/// Automatically adjusts density and active states based on [PipelineStageData].


class PipelineStageData {
  final String label;
  final bool isCompleted;
  final bool isActive;

  const PipelineStageData({
    required this.label,
    this.isCompleted = false,
    this.isActive = false,
  });
}

/// A sequential tracking visualizer natively handling standard stages line traces.
class TissuePipeline extends StatelessWidget {
  final List<PipelineStageData> stages;

  const TissuePipeline({
    super.key,
    required this.stages,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: List.generate(stages.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Connector Line
              final int prevStageIndex = index ~/ 2;
              final bool isLineActive = stages[prevStageIndex].isCompleted;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isLineActive ? colors.primary : colors.border,
                ),
              );
            } else {
              // Node
              final stageIndex = index ~/ 2;
              final stage = stages[stageIndex];
              
              Color nodeBgColor = colors.surface;
              Color nodeBorderColor = colors.borderSubtle;
              Color nodeTextColor = colors.textSecondary;
              
              if (stage.isCompleted) {
                nodeBgColor = colors.primary;
                nodeBorderColor = colors.primary;
                nodeTextColor = colors.surface;
              } else if (stage.isActive) {
                nodeBgColor = colors.primaryLight;
                nodeBorderColor = colors.primary;
                nodeTextColor = colors.primary;
              }
              
              return Row(
                children: [
                  Container(
                    width: OrganismTheme.spacingLg,
                    height: OrganismTheme.spacingLg,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: nodeBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: nodeBorderColor, width: stage.isActive ? 2 : 1),
                    ),
                    child: stage.isCompleted 
                        ? Icon(
                            LucideIcons.check,
                            size: OrganismTheme.iconSizeXs,
                            color: colors.surface,
                          )
                        : Text('${stageIndex + 1}', style: OrganismTheme.bodySmall(context).copyWith(color: nodeTextColor, fontWeight: FontWeight.w600)),
                  ),
                  CellGap.small,
                  Text(stage.label, style: OrganismTheme.bodyMedium(context).copyWith(color: stage.isActive ? colors.textPrimary : nodeTextColor, fontWeight: stage.isActive ? FontWeight.w600 : FontWeight.w400)),
                ],
              );
            }
          }),
        );
      }
    );
  }
}
