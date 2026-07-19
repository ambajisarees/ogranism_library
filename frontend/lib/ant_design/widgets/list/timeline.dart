import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class TimelineStep {
  final String title;
  final String description;
  final bool isDone;
  final bool isActive;
  final bool isMuted;

  const TimelineStep({
    required this.title,
    required this.description,
    this.isDone = false,
    this.isActive = false,
    this.isMuted = false,
  });
}

class Timeline extends StatelessWidget {
  final String title;
  final List<TimelineStep> steps;
  final double width;

  const Timeline({
    super.key,
    required this.title,
    required this.steps,
    this.width = 240.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: width,
      child: shad.Card(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: theme.typography.textLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const shad.DensityGap(shad.gapSm),
            const shad.Divider(),
            const shad.DensityGap(shad.gapSm),
            // Steps column
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: steps.map((step) => _buildStepRow(context, colors, theme, step)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(BuildContext context, shad.ColorScheme colors, shad.ThemeData theme, TimelineStep step) {
    Color dotColor = colors.border;
    if (step.isDone) dotColor = colors.primary;
    if (step.isActive) dotColor = colors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: theme.density.baseGap * shad.gapMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: step.isActive ? Colors.transparent : dotColor,
              shape: BoxShape.circle,
              border: step.isActive ? Border.all(color: colors.primary, width: 3) : null,
            ),
          ),
          const shad.DensityGap(shad.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: step.isMuted ? colors.mutedForeground : colors.foreground,
                  ),
                ),
                Text(
                  step.description,
                  style: theme.typography.textMuted.copyWith(
                    fontSize: 11,
                    color: step.isMuted ? colors.mutedForeground : colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
