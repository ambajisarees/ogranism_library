/// LLM NOTE: DabFilterPopover
/// - Level: DAB Popover Widget
/// - Purpose: Generic searchable multi-select popover for custom filter parameters with top search bar and checkbox options.
/// - Widget Composition: shad.Card -> Column(Title + Search TextField + Scrollable Checkbox list).

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Searchable Filter Popover matching Reference 2:
/// - Top Search Bar with search icon
/// - Scrollable list of selectable options with Checkbox
class DabFilterPopover extends StatefulWidget {
  final String title;
  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onChanged;

  const DabFilterPopover({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<DabFilterPopover> createState() => _DabFilterPopoverState();
}

class _DabFilterPopoverState extends State<DabFilterPopover> {
  String _searchQuery = '';
  late Set<String> _currentSelected;

  @override
  void initState() {
    super.initState();
    _currentSelected = Set.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final filteredOptions = widget.options.where((option) {
      if (_searchQuery.isEmpty) return true;
      return option.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return shad.Card(
      padding: EdgeInsets.all(8 * theme.scaling),
      child: SizedBox(
        width: 220 * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Search Bar
            shad.TextField(
              filled: true,
              placeholder: Text('Search ${widget.title}...'),
              padding: EdgeInsets.symmetric(
                horizontal: 8 * theme.scaling,
                vertical: 6 * theme.scaling,
              ),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(color: colors.border),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              features: [
                shad.InputFeature.leading(
                  Icon(
                    shad.LucideIcons.search,
                    size: 14 * theme.scaling,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),

            // Scrollable List of Checkbox Items
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200 * theme.scaling),
              child: filteredOptions.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(12 * theme.scaling),
                      child: Center(
                        child: Text(
                          'No options found',
                          style: theme.typography.xSmall.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredOptions.length,
                      itemBuilder: (context, index) {
                        final item = filteredOptions[index];
                        final isChecked = _currentSelected.contains(item);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isChecked) {
                                _currentSelected.remove(item);
                              } else {
                                _currentSelected.add(item);
                              }
                            });
                            widget.onChanged(_currentSelected);
                          },
                          child: Container(
                            color: isChecked
                                ? colors.accent.withAlpha(100)
                                : const Color(0x00000000),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * theme.scaling,
                              vertical: 6 * theme.scaling,
                            ),
                            child: Row(
                              children: [
                                shad.Checkbox(
                                  state: isChecked
                                      ? shad.CheckboxState.checked
                                      : shad.CheckboxState.unchecked,
                                  onChanged: (state) {
                                    setState(() {
                                      if (state == shad.CheckboxState.checked) {
                                        _currentSelected.add(item);
                                      } else {
                                        _currentSelected.remove(item);
                                      }
                                    });
                                    widget.onChanged(_currentSelected);
                                  },
                                ),
                                const shad.DensityGap(shad.gapSm),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: theme.typography.textSmall.copyWith(
                                      fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                      color: colors.foreground,
                                    ),
                                  ),
                                ),
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
