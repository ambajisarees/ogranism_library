import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/spatial.dart';

class TissueBreadcrumbNode {
  final String label;
  final VoidCallback? onTap;

  const TissueBreadcrumbNode({required this.label, this.onTap});
}

class TissueBreadcrumb extends StatelessWidget {
  final List<TissueBreadcrumbNode> nodes;
  final int maxVisibleNodes;

  const TissueBreadcrumb({
    super.key,
    required this.nodes,
    this.maxVisibleNodes = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    final colors = OrganismTheme.colorsOf(context);
    final List<TissueBreadcrumbNode> displayNodes = [];
    
    if (nodes.length > maxVisibleNodes && nodes.length > 2) {
      displayNodes.add(nodes.first);
      displayNodes.add(const TissueBreadcrumbNode(label: '...'));
      displayNodes.addAll(nodes.sublist(nodes.length - (maxVisibleNodes - 2)));
    } else {
      displayNodes.addAll(nodes);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < displayNodes.length; i++) ...[
          if (i > 0) ...[
            const CellGap(0.5),
            Icon(LucideIcons.chevronRight, size: 14, color: colors.textMuted),
            const CellGap(0.5),
          ],
          GestureDetector(
            onTap: displayNodes[i].onTap,
            child: Text(
              displayNodes[i].label,
              style: OrganismTheme.labelMedium(context).copyWith(
                color: i == displayNodes.length - 1 ? colors.textPrimary : colors.textMuted,
                fontWeight: i == displayNodes.length - 1 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ]
      ],
    );
  }
}
