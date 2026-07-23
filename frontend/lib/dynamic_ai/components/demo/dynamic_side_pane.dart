import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

// Sized configuration data model for accordion cards
class DynamicSideCard {
  final String title;
  final Widget child;

  const DynamicSideCard({
    required this.title,
    required this.child,
  });
}

// Collapsible accordion sidebar stack
class DynamicSidePane extends StatefulWidget {
  final List<DynamicSideCard> cards;
  final double width;

  const DynamicSidePane({
    super.key,
    required this.cards,
    this.width = 280.0,
  });

  @override
  State<DynamicSidePane> createState() => _DynamicSidePaneState();
}

class _DynamicSidePaneState extends State<DynamicSidePane> {
  int _expandedIndex = 0; // Default: first card expanded

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final List<Widget> children = [];
    for (int i = 0; i < widget.cards.length; i++) {
      final isExpanded = i == _expandedIndex;
      final card = widget.cards[i];

      Widget cardWidget = shad.Card(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Header Row (Clickable to toggle expansion)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? -1 : i; // toggle or expand
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      card.title,
                      style: theme.typography.textLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? shad.LucideIcons.chevronDown : shad.LucideIcons.chevronRight,
                    size: theme.iconTheme.small.size,
                    color: colors.mutedForeground,
                  ),
                ],
              ),
            ),
            
            // Content (Expanded scrollable area with NO top divider)
            if (isExpanded) ...[
              const shad.DensityGap(shad.gapSm),
              Expanded(
                child: SingleChildScrollView(
                  child: card.child,
                ),
              ),
            ],
          ],
        ),
      );

      // If expanded, wrap in Expanded so it fills the available column height
      if (isExpanded) {
        children.add(Expanded(child: cardWidget));
      } else {
        children.add(cardWidget);
      }
    }

    // Add gaps between cards
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(const shad.DensityGap(shad.gapSm));
      }
    }

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spacedChildren,
      ),
    );
  }
}

// Helper: Timeline Step Model
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

// Helper: TimelineView (renders only the steps list)
class TimelineView extends StatelessWidget {
  final List<TimelineStep> steps;

  const TimelineView({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: steps
          .map((step) => _buildStepRow(context, colors, theme, step))
          .toList(),
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
            margin: EdgeInsets.only(top: theme.density.baseGap * shad.gapXs),
            width: theme.iconTheme.xSmall.size,
            height: theme.iconTheme.xSmall.size,
            decoration: BoxDecoration(
              color: step.isActive ? Colors.transparent : dotColor,
              shape: BoxShape.circle,
              border: step.isActive ? Border.all(color: colors.primary, width: 2 * theme.scaling) : null,
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
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
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

// Helper: Metric Item Model
class MetricItem {
  final Widget icon;
  final String label;
  final String value;
  final String unit;

  const MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });
}

// Helper: MetricsView (renders only the metrics row list)
class MetricsView extends StatelessWidget {
  final List<MetricItem> metrics;

  const MetricsView({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: metrics
          .map((metric) => _buildMetricRow(context, colors, theme, metric))
          .toList(),
    );
  }

  Widget _buildMetricRow(BuildContext context, shad.ColorScheme colors, shad.ThemeData theme, MetricItem metric) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.density.baseContainerPadding * shad.padXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              size: theme.iconTheme.x2Large.size,
              color: theme.colorScheme.primary,
            ),
            child: metric.icon,
          ),
          const shad.DensityGap(shad.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metric.label,
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                const shad.DensityGap(shad.gapXs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        metric.value,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.textLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      metric.unit,
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
