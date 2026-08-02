/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC CARD PANE (dy_card_pane.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Cards grid pane component (consolidated from dy_view_card.dart).
   - Encapsulates DyViewCard and exports DyCardPane alias.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../micro/cards/dy_grid_card.dart';
import '../micro/dy_pagination_row.dart';

/// Alias type for architectural consistency across dynamic AI pane components.
typedef DyCardPane = DyViewCard;

/// [DyViewCard] — Responsive Cards / Grid View Layout Engine.
class DyViewCard extends StatefulWidget {
  final List<DyGridItem> items;
  final DyGridItem? selectedItem;
  final ValueChanged<DyGridItem?> onItemSelected;
  final bool isLoading;
  final int? totalRecords;
  final ValueChanged<int>? onPageChanged;
  final int currentPage;

  const DyViewCard({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.isLoading = false,
    this.totalRecords,
    this.onPageChanged,
    this.currentPage = 1,
  });

  @override
  State<DyViewCard> createState() => _DyViewCardState();
}

class _DyViewCardState extends State<DyViewCard> {
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
  }

  @override
  void didUpdateWidget(covariant DyViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      _currentPage = widget.currentPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final selectedCount = widget.selectedItem != null ? 1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: widget.isLoading
              ? _buildSkeletonGrid(theme, colors)
              : (widget.items.isEmpty
                  ? Center(
                      child: Text(
                        'No cards available',
                        style: theme.typography.textSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 320 * theme.scaling,
                        mainAxisExtent: 240 * theme.scaling,
                        crossAxisSpacing: 16 * theme.scaling,
                        mainAxisSpacing: 16 * theme.scaling,
                      ),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final isSelected = widget.selectedItem?.id == item.id;

                        return DyGridCard(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => widget.onItemSelected(item),
                        );
                      },
                    )),
        ),
        const shad.DensityGap(shad.gapSm),

        DyPaginationRow(
          totalRecords: widget.totalRecords ?? widget.items.length,
          currentPage: _currentPage,
          selectedCount: selectedCount,
          onPageChanged: (newPage) {
            setState(() => _currentPage = newPage);
            widget.onPageChanged?.call(newPage);
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonGrid(shad.ThemeData theme, shad.ColorScheme colors) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320 * theme.scaling,
        mainAxisExtent: 240 * theme.scaling,
        crossAxisSpacing: 16 * theme.scaling,
        mainAxisSpacing: 16 * theme.scaling,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: colors.muted.withAlpha(80),
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(color: colors.border),
          ),
        );
      },
    );
  }
}
