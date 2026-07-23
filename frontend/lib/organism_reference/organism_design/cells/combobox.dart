import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../plasma/popover.dart'; // Direct import from plasma submodule
import 'input.dart';   // Direct import for CellInput
import 'divider.dart'; // Direct import for CellDivider
import 'spatial.dart'; // Direct import for CellGap/CellPad

/// [CellCombobox] — Heavy-duty virtualized dropdown for ERP datasets.
///
/// Designed to handle 10,000+ items efficiently using [ListView.builder]
/// inside a [PlasmaPopover]. Provides a search interface for fast filtering.

/// Extremely dense, virtualized combobox specifically constructed for massive ERP datasets (e.g. 10k entities).
/// Does NOT use native DropdownButton, directly uses PlasmaPopover over a ListView.builder.
class CellCombobox<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) labelBuilder;
  final String placeholder;
  final bool isCompact;

  const CellCombobox({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
    this.placeholder = "Select...",
    this.isCompact = true,
  });

  @override
  State<CellCombobox<T>> createState() => _CellComboboxState<T>();
}

class _CellComboboxState<T> extends State<CellCombobox<T>> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<T> _filteredItems = [];
  int _highlightedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.onKeyEvent = _handleKeyEvent;
    
    // Auto-focus the search field as soon as the popover mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchFocusNode.canRequestFocus) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(CellCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _onSearchChanged(); // Re-apply filter
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return widget.labelBuilder(item).toLowerCase().contains(query);
        }).toList();
      }
      // Reset keyboard navigation highlighting to top of filtered list
      _highlightedIndex = 0;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        if (_filteredItems.isNotEmpty) {
          _highlightedIndex = (_highlightedIndex + 1) % _filteredItems.length;
          _scrollToHighlighted();
        }
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        if (_filteredItems.isNotEmpty) {
          _highlightedIndex = (_highlightedIndex - 1 + _filteredItems.length) % _filteredItems.length;
          _scrollToHighlighted();
        }
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_filteredItems.isNotEmpty && _highlightedIndex >= 0 && _highlightedIndex < _filteredItems.length) {
        widget.onChanged(_filteredItems[_highlightedIndex]);
        _searchController.clear();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _scrollToHighlighted() {
    if (!_scrollController.hasClients) return;
    const double itemHeight = 36.0; // Fixed padding + text height inside item builder
    final double targetOffset = _highlightedIndex * itemHeight;
    final double currentOffset = _scrollController.offset;
    const double viewportHeight = 240.0; // height of list viewport (300 height - input - padding)

    if (targetOffset < currentOffset) {
      _scrollController.jumpTo(targetOffset);
    } else if (targetOffset + itemHeight > currentOffset + viewportHeight) {
      _scrollController.jumpTo(targetOffset + itemHeight - viewportHeight);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.isCompact ? OrganismTheme.buttonHeightCompact : OrganismTheme.buttonHeightStandard;
    final colors = OrganismTheme.colorsOf(context);

    final selectedLabel = widget.value != null ? widget.labelBuilder(widget.value as T) : widget.placeholder;

    return PlasmaPopover(
      trigger: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: OrganismTheme.borderSm,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (widget.isCompact ? OrganismTheme.bodySmall(context) : OrganismTheme.bodyLarge(context)).copyWith(
                  color: widget.value != null ? colors.textPrimary : colors.textMuted,
                  height: 1.1,
                ),
              ),
            ),
            CellGap.small,
            Icon(
              LucideIcons.chevronsUpDown,
              size: widget.isCompact ? OrganismTheme.iconSizeSm : OrganismTheme.iconSizeMd,
              color: OrganismTheme.iconSecondary(context),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 250, // Standard dropdown width constraint
        height: 300, // Maximum popover extent
        child: Column(
          children: [
            CellPad(
              multiplier: 0.5,
              child: CellInput(
                controller: _searchController,
                focusNode: _searchFocusNode,
                placeholder: "Search...",
                prefixIcon: LucideIcons.search,
              ),
            ),
            CellDivider(),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        "No results.",
                        style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.value == item;
                        final isHighlighted = _highlightedIndex == index;
                        return InkWell(
                          onTap: () {
                            widget.onChanged(item);
                            // Clear search when explicitly selecting
                            _searchController.clear();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            color: isSelected 
                                ? colors.surfaceSubtle 
                                : (isHighlighted ? colors.surfaceHover : Colors.transparent),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.labelBuilder(item),
                                    style: OrganismTheme.bodySmall(context).copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: isSelected || isHighlighted ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(LucideIcons.check, size: 14, color: colors.primary)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
