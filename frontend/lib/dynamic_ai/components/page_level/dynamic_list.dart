import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'dynamic_list_card.dart';

class DynamicList extends StatefulWidget {
  final List<DynamicListItem> items;
  final DynamicListItem? selectedItem;
  final ValueChanged<DynamicListItem?> onItemSelected;
  final double width;
  final bool showHeader;
  final int? totalRecords;

  const DynamicList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.width = 340.0,
    this.showHeader = false,
    this.totalRecords,
  });

  @override
  State<DynamicList> createState() => _DynamicListState();
}

class _DynamicListState extends State<DynamicList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

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
    
    // Pagination math
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
    final recordText = '$startRecordIdx-$endRecordIdx of ${_formatNumber(totalCount)} Records';

    return SizedBox(
      width: widget.width,
      child: shad.OutlinedContainer(
        borderColor: colors.border,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        backgroundColor: colors.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Optional Sticky Header: Search input
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
            
            // Scrollable Middle List of Cards
            Expanded(
              child: paginatedItems.isEmpty
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
                    ),
            ),
            
            const shad.Divider(),
            
            // Sticky Footer: Compact 2-Button Pagination Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      ),
    );
  }
}
