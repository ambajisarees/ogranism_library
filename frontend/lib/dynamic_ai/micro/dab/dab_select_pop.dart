/// LLM NOTE: DabSelectPopover
/// - Level: DAB Popover Component
/// - Purpose: Unified multi-option checklist selection popover for DynamicActionBar (Party, Mill, Quality, Fabric, Status) with 200px width.
/// - Widget Composition: shad.Card -> Column(Search TextField + Scrollable Checkbox List).

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../specs/dy_grid_system.dart';

/// Unified Select Checklist Popover following standard DAB popover specs:
/// - Width: `DyGridSystem.popWidthStandard` (200px)
/// - Corner Radius: 8px, Inner Card Padding: 8px
/// - Max Height: 300px
/// - Search textfield rendered ONLY if options > 5 items
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
        width: DyGridSystem.popWidthStandard * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Search Bar (rendered ONLY if options > 5)
            if (widget.options.length > 5) ...[
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
            ],

            // Scrollable List of Checkbox Items (maxHeight 300px)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300 * theme.scaling),
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
                      padding: EdgeInsets.zero,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
