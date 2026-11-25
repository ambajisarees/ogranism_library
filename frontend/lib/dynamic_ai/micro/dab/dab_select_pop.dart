/// LLM NOTE: DabSelectPopover
/// - Level: DAB Popover Component
/// - Purpose: Native `shad.SelectPopup` multi-select filter popover for DynamicActionBar (Party, Mill, Quality, Fabric, Status).
/// - Widget Composition: `shad.Data<shad.SelectData>` -> `shad.SelectPopup<String>.builder` (when options > 5, with autofocused search) or `shad.SelectPopup<String>` (`<= 5` items), giving built-in `SubFocusScope` arrow/Enter/Esc keyboard navigation.

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../specs/dy_grid_system.dart';

/// Unified Multi-Select Checklist Popover backed natively by [shad.SelectPopup].
class DabSelectPopover extends StatefulWidget {
  final String title;
  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onChanged;

  const DabSelectPopover({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<DabSelectPopover> createState() => _DabSelectPopoverState();
}

class _DabSelectPopoverState extends State<DabSelectPopover> {
  late Set<String> _currentSelected;

  @override
  void initState() {
    super.initState();
    _currentSelected = Set<String>.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final hasSearch = widget.options.length > 5;

    return SizedBox(
      width: 220 * theme.scaling,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: DyGridSystem.popWidthStandard * theme.scaling,
          maxHeight: 300 * theme.scaling,
        ),
        child: shad.Data.inherit(
          data: shad.SelectData(
            enabled: true,
            autoClose: false,
            isSelected: (val) => val is String && _currentSelected.contains(val),
            onChanged: (val, selected) {
              if (val is! String) return false;
              setState(() {
                if (selected) {
                  _currentSelected.add(val);
                } else {
                  _currentSelected.remove(val);
                }
              });
              widget.onChanged(Set<String>.from(_currentSelected));
              return true;
            },
            hasSelection: _currentSelected.isNotEmpty,
            expandIcon: null,
          ),
          child: hasSearch
              ? shad.SelectPopup<String>.builder(
                  shrinkWrap: true,
                  searchPlaceholder: Text('Search ${widget.title}...'),
                  emptyBuilder: (_) => Padding(
                    padding: EdgeInsets.all(12 * theme.scaling),
                    child: Center(
                      child: Text(
                        'No options found',
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                  builder: (context, searchQuery) {
                    final q = (searchQuery ?? '').trim().toLowerCase();
                    final filtered = q.isEmpty
                        ? widget.options
                        : widget.options
                            .where((o) => o.toLowerCase().contains(q))
                            .toList();
                    return shad.SelectItemList(
                      children: [
                        for (final item in filtered)
                          shad.SelectItemButton<String>(
                            value: item,
                            child: Text(item),
                          ),
                      ],
                    );
                  },
                )
              : shad.SelectPopup<String>(
                  items: shad.SelectItemList(
                    children: [
                      for (final item in widget.options)
                        shad.SelectItemButton<String>(
                          value: item,
                          child: Text(item),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
