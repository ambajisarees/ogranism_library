import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'metric_card.dart';

class MetricCardList extends StatelessWidget {
  final String title;
  final List<MetricItem> metrics;
  final double width;
  final Axis orientation;

  const MetricCardList({
    super.key,
    required this.title,
    required this.metrics,
    this.width = 260.0,
    this.orientation = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    Widget content;
    if (orientation == Axis.horizontal) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: metrics
            .map((metric) => Expanded(child: MetricCard(item: metric)))
            .toList(),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: metrics.map((metric) => MetricCard(item: metric)).toList(),
      );
    }

    return SizedBox(
      width: orientation == Axis.vertical ? width : null,
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
            // Metrics content
            content,
          ],
        ),
      ),
    );
  }
}
