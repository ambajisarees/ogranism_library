import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../plasma/popover.dart';
import '../cells/box.dart';
import '../cells/input.dart';
import '../cells/divider.dart';
import '../cells/spatial.dart';

/// [TissueDropdown] — Standardized scalar selection molecule (Custom High-Fidelity).
///
/// Replaces Material's DropdownButton with a custom PlasmaPopover implementation.
/// Includes integrated search and high-density virtualized listing.
class TissueDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabelBuilder;
  final String? placeholder;
  final bool isDisabled;
  final bool hasError;

  const TissueDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.placeholder,
    this.isDisabled = false,
    this.hasError = false,
  });

  @override
  State<TissueDropdown<T>> createState() => _TissueDropdownState<T>();
}

class _TissueDropdownState<T> extends State<TissueDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<PlasmaPopoverState> _popoverKey = GlobalKey<PlasmaPopoverState>();
  List<T> _filteredItems = [];
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return widget.itemLabelBuilder(item).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    Color borderColor = colors.border;
    if (widget.hasError) {
      borderColor = colors.error;
    } else if (_isHovered && !widget.isDisabled) {
      borderColor = colors.inputBorderHover;
    }

    final selectedLabel = widget.value != null 
        ? widget.itemLabelBuilder(widget.value as T) 
        : (widget.placeholder ?? "Select option");

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: PlasmaPopover(
        key: _popoverKey,
        trigger: CellBox(
          height: OrganismTheme.buttonHeightStandard,
          padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
          backgroundColor: widget.isDisabled ? colors.inputBackgroundDisabled : colors.surface,
          borderRadius: OrganismTheme.borderSm,
          border: Border.all(color: borderColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OrganismTheme.bodyLarge(context).copyWith(
                    color: widget.value != null ? colors.textPrimary : colors.textMuted,
                  ),
                ),
              ),
              CellGap.small,
              Icon(
                LucideIcons.chevronsUpDown,
                size: OrganismTheme.iconSizeSm,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: 280,
          height: 350,
          child: Column(
            children: [
              CellPad(
                multiplier: 0.5,
                child: CellInput(
                  controller: _searchController,
                  placeholder: "Search...",
                  prefixIcon: LucideIcons.search,
                ),
              ),
              const CellDivider(),
              Expanded(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Text("No results.", style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted)),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = item == widget.value;
                            return ListTile(
                              dense: true,
                              onTap: widget.isDisabled ? null : () {
                                _popoverKey.currentState?.close(); // Safe programatic close
                                widget.onChanged(item);
                                _searchController.clear();
                              },
                              tileColor: isSelected ? colors.surfaceSubtle : null,
                              title: Text(
                                widget.itemLabelBuilder(item),
                                style: OrganismTheme.bodyMedium(context).copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected ? Icon(LucideIcons.check, size: 14, color: colors.primary) : null,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
