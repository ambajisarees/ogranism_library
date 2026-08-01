/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC LIST PANE (dy_list_pane.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Master vertical list pane component (consolidated from dy_view_list.dart).
   - Encapsulates DynamicList and exports DyListPane alias.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../micro/cards/dy_list_item.dart';

/// Alias type for architectural consistency across dynamic AI pane components.
typedef DyListPane = DynamicList;

class DynamicList extends StatefulWidget {
  final List<DynamicListItem> items;
  final DynamicListItem? selectedItem;
  final ValueChanged<DynamicListItem?> onItemSelected;
  final double? width;
  final bool showHeader;
  final int? totalRecords;

  final bool isLoading;

  const DynamicList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.width,
    this.showHeader = false,
    this.totalRecords,
    this.isLoading = false,
  });

  @override
  State<DynamicList> createState() => _DynamicListState();
}

class _DynamicListState extends State<DynamicList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 25;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _currentPage = 1;
    });
  }

  List<DynamicListItem> _getFilteredItems() {
    if (_searchQuery.isEmpty) return widget.items;
    final query = _searchQuery.toLowerCase();
    return widget.items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query);
      final subtitleMatch = item.subtitle?.toLowerCase().contains(query) ?? false;
      final indexMatch = item.indexNumber?.toLowerCase().contains(query) ?? false;
      final amountMatch = item.amount?.toLowerCase().contains(query) ?? false;
      return titleMatch || subtitleMatch || indexMatch || amountMatch;
    }).toList();
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final filteredItems = _getFilteredItems();
    
    final totalCount = widget.totalRecords ?? filteredItems.length;
    final totalPages = (filteredItems.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredItems.length);
    final paginatedItems = filteredItems.sublist(startIndex, endIndex);

    final startRecordIdx = filteredItems.isNotEmpty ? (startIndex + 1) : 0;
    final endRecordIdx = (startIndex + paginatedItems.length);
    final recordText = widget.isLoading
        ? 'Loading records...'
        : '$startRecordIdx - $endRecordIdx of ${_formatNumber(totalCount)} Records';

    final container = shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      backgroundColor: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            if (widget.showHeader) ...[
              Padding(
                padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
                child: shad.TextField(
                  controller: _searchController,
                  placeholder: const Text('Search items...'),
                  features: [
                    shad.InputFeature.leading(
                      Icon(shad.LucideIcons.search, color: theme.colorScheme.mutedForeground),
                    ),
                    shad.InputFeature.clear(
                      visibility: shad.InputFeatureVisibility.textNotEmpty,
                    ),
                  ],
                ),
              ),
              const shad.Divider(),
            ],
            
            Expanded(
              child: widget.isLoading
                  ? _buildSkeletonList(theme, colors)
                  : (paginatedItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
                            child: Text(
                              'No items found',
                              style: theme.typography.textMuted.copyWith(color: theme.colorScheme.mutedForeground),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: paginatedItems.length,
                          itemBuilder: (context, index) {
                            final item = paginatedItems[index];
                            final isSelected = widget.selectedItem?.id == item.id;
                            return DynamicListCard(
                              item: item,
                              isSelected: isSelected,
                              onTap: () => widget.onItemSelected(item),
                            );
                          },
                        )),
            ),
            
            const shad.Divider(),
            
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * theme.scaling,
                vertical: 10 * theme.scaling,
              ),
              color: theme.colorScheme.brightness == Brightness.dark
                  ? const Color(0xFF141210)
                  : const Color(0xFFFCFDFE),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      recordText,
                      maxLines: 1,
                      softWrap: false,
                      style: theme.typography.textSmall.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  shad.IconButton.ghost(
                    size: shad.ButtonSize.small,
                    icon: const Icon(shad.LucideIcons.chevronLeft, size: 16),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  const SizedBox(width: 4),
                  shad.IconButton.ghost(
                    size: shad.ButtonSize.small,
                    icon: const Icon(shad.LucideIcons.chevronRight, size: 16),
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

    if (widget.width != null) {
      return SizedBox(
        width: widget.width,
        child: container,
      );
    }
    return container;
  }

  Widget _buildSkeletonList(shad.ThemeData theme, shad.ColorScheme colors) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _SkeletonBox(width: 65, height: 16, borderRadius: BorderRadius.circular(theme.radiusSm)),
                  const Spacer(),
                  const _SkeletonBox(width: 45, height: 12),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Expanded(child: _SkeletonBox(height: 16)),
                  SizedBox(width: 12),
                  _SkeletonBox(width: 75, height: 16),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Expanded(child: _SkeletonBox(height: 12)),
                  SizedBox(width: 12),
                  _SkeletonBox(width: 55, height: 12),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const _SkeletonBox({
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = shad.Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.muted.withAlpha(120),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}
