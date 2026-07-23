import 'package:flutter/material.dart';
import '../theme.dart';

class TissueKanbanColumnData {
  final String title;
  final Widget headerExtra;
  final List<Widget> items;

  const TissueKanbanColumnData({
    required this.title,
    required this.items,
    this.headerExtra = const SizedBox.shrink(),
  });
}

class TissueKanbanBoard extends StatelessWidget {
  final List<TissueKanbanColumnData> columns;
  final double columnWidth; // Minimum width if fluid, fixed if not fluid

  const TissueKanbanBoard({
    super.key,
    required this.columns,
    this.columnWidth = 320,
  });

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fluid stretch logic: if total intrinsic width < constraints.maxWidth, stretch them
        final bool shouldStretch = (columnWidth * columns.length) < constraints.maxWidth;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: columns.length,
          separatorBuilder: (context, index) => const SizedBox(width: OrganismTheme.spacingLg),
          itemBuilder: (context, index) {
            final col = columns[index];
            final colors = OrganismTheme.colorsOf(context);

            return Container(
              width: shouldStretch ? (constraints.maxWidth - (OrganismTheme.spacingLg * (columns.length - 1))) / columns.length : columnWidth,
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: OrganismTheme.borderLg,
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Column Header
                  Padding(
                    padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          col.title,
                          style: OrganismTheme.labelMedium(context).copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        col.headerExtra,
                      ],
                    ),
                  ),
                  Container(height: 1, color: colors.borderSubtle),
                  // Column Items
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                      itemCount: col.items.length,
                      separatorBuilder: (context, idx) => const SizedBox(height: OrganismTheme.spacingMd),
                      itemBuilder: (context, idx) => col.items[idx],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
