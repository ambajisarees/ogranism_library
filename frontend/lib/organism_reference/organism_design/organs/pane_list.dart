import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';
import '../tissues.dart';

/// [OrganPaneList] — The central scrolling data track for ERP registries.
///
/// Handles structural layout for long lists of registry cards.
/// Includes a sticky Pagination track and the scrollable data grid.
class OrganPaneList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool isLoading;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry padding;

  // Pagination Controls (Sticky Track)
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final ValueChanged<int> onPageChanged;

  // Customization
  final int skeletonCount;
  final double itemSpacing;

  // Empty State Customization
  final Widget? emptyState;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;

  const OrganPaneList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.onPageChanged,
    this.isLoading = false,
    this.scrollController,
    this.padding = EdgeInsets.zero,
    this.skeletonCount = 8,
    this.itemSpacing = 0.0,
    this.emptyState,
    this.emptyTitle = 'No results found',
    this.emptyMessage = 'Try adjusting your search or filters.',
    this.emptyIcon = LucideIcons.search,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── STICKY TRACK 1: Pagination ────────────────────────────────
        TissuePagination(
          currentPage: currentPage,
          totalPages: totalPages,
          totalCount: totalCount,
          limit: limit,
          onPageChanged: onPageChanged,
        ),

        // ── SCROLLABLE TRACK 2: Content ──────────────────────────────
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    if (itemCount == 0) {
      return emptyState ??
          Center(
            child: TissueEmptyState(
              title: emptyTitle,
              message: emptyMessage,
              icon: emptyIcon,
            ),
          );
    }

    return ListView.separated(
      controller: scrollController,
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: itemBuilder,
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skeletonCount,
      separatorBuilder: (context, index) => const SizedBox(height: OrganismTheme.spacingSm),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: OrganismTheme.colorsOf(context).surface,
          border: Border.all(color: OrganismTheme.colorsOf(context).border),
        ),
        padding: const EdgeInsets.all(OrganismTheme.spacingMd),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CellSkeleton(height: 18, width: 140),
            SizedBox(height: 8),
            CellSkeleton(height: 14, width: 220),
          ],
        ),
      ),
    );
  }
}
