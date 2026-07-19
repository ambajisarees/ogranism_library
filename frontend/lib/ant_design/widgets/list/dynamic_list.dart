import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'dynamic_list_card.dart';

class DynamicList extends StatefulWidget {
  final List<DynamicListItem> items;
  final DynamicListItem? selectedItem;
  final ValueChanged<DynamicListItem?> onItemSelected;
  final double width;

  const DynamicList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.width = 350.0,
  });

  @override
  State<DynamicList> createState() => _DynamicListState();
}

class _DynamicListState extends State<DynamicList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

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
      _currentPage = 1; // Reset to page 1 on search change
    });
  }

  List<DynamicListItem> _getFilteredItems() {
    if (_searchQuery.isEmpty) return widget.items;
    final query = _searchQuery.toLowerCase();
    return widget.items.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.indexNumber.toLowerCase().contains(query) ||
          (item.status?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final filteredItems = _getFilteredItems();
    
    // Pagination math
    final totalPages = (filteredItems.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredItems.length);
    final paginatedItems = filteredItems.sublist(startIndex, endIndex);

    return SizedBox(
      width: widget.width,
      child: shad.Card(
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero, // Padding will be applied to child sections to keep full-width dividers
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sticky Header: Search input
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
            
            // Scrollable Middle List
            Expanded(
              child: paginatedItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
                        child: Text(
                          'No items found',
                          style: theme.typography.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: paginatedItems.length,
                      itemBuilder: (context, index) {
                        final item = paginatedItems[index];
                        final isSelected = widget.selectedItem == item;
                        return DynamicListCard(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => widget.onItemSelected(item),
                        );
                      },
                    ),
            ),
            
            const shad.Divider(),
            
            // Sticky Footer: Pagination controls
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: theme.density.baseContainerPadding * shad.padXs,
                horizontal: theme.density.baseContainerPadding * shad.padSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  shad.Pagination(
                    page: _currentPage,
                    totalPages: totalPages,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    showLabel: false,
                    showSkipToFirstPage: false,
                    showSkipToLastPage: false,
                    maxPages: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
