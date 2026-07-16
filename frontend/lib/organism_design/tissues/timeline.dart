import 'package:flutter/material.dart';
import '../theme.dart';

class TimelineNodeData {
  final String title;
  final String description;
  final String timestamp;
  final bool isLast;
  final bool isCompleted;

  const TimelineNodeData({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isLast = false,
    this.isCompleted = true,
  });
}

/// [TissueTimeline] — Vertical chronological audit trails
class TissueTimeline extends StatelessWidget {
  final List<TimelineNodeData> nodes;

  const TissueTimeline({
    super.key,
    required this.nodes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nodes.map((node) => _buildNode(context, node)).toList(),
    );
  }

  Widget _buildNode(BuildContext context, TimelineNodeData node) {
    final colors = OrganismTheme.colorsOf(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic Line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: OrganismTheme.spacingXs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: node.isCompleted ? colors.primary : colors.stone100,
                  border: Border.all(
                    color: node.isCompleted ? colors.primary : colors.border,
                    width: 2,
                  ),
                ),
              ),
              if (!node.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingXs),
                    color: colors.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: OrganismTheme.spacingMd),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: OrganismTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        node.title,
                        style: OrganismTheme.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        node.timestamp,
                        style: OrganismTheme.labelMedium(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: OrganismTheme.spacingXs),
                  Text(
                    node.description,
                    style: OrganismTheme.bodyMedium(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
