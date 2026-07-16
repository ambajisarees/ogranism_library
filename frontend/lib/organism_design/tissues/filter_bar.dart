import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/button.dart';
import '../cells/filter_chip.dart';
import '../cells/spatial.dart';

class TissueFilterNode {
  final String id;
  final String label;

  const TissueFilterNode({required this.id, required this.label});
}

class TissueFilterBar extends StatelessWidget {
  final List<TissueFilterNode> filters;
  final ValueChanged<String> onFilterRemoved;
  final VoidCallback onClearAll;
  final VoidCallback onAddFilter;

  const TissueFilterBar({
    super.key,
    required this.filters,
    required this.onFilterRemoved,
    required this.onClearAll,
    required this.onAddFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return CellButton(
        text: 'Add Filter',
        icon: LucideIcons.filter,
        variant: CellButtonVariant.outline,
        isCompact: true,
        onPressed: onAddFilter,
      );
    }

    return Container(
      height: OrganismTheme.buttonHeightCompact,
      margin: const EdgeInsets.only(bottom: OrganismTheme.spacingMd),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CellButton(
            text: 'Filters',
            icon: LucideIcons.filter,
            variant: CellButtonVariant.outline,
            isCompact: true,
            onPressed: onAddFilter,
          ),
          const SizedBox(width: OrganismTheme.spacingMd),
          Container(width: 1, color: OrganismTheme.colorsOf(context).border),
          const SizedBox(width: OrganismTheme.spacingMd),
          for (final filter in filters) ...[
            CellFilterChip(
              label: filter.label,
              onDeleted: () => onFilterRemoved(filter.id),
            ),
            CellGap.small,
          ],
          CellGap.small,
          CellButton(
            text: 'Clear All',
            variant: CellButtonVariant.ghost,
            isCompact: true,
            onPressed: onClearAll,
          ),
        ],
      ),
    );
  }
}
