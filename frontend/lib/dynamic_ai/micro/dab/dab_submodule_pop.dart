/// LLM NOTE: DabSubmodulePopover & DabSubmoduleItem
/// - Level: DAB Popover Widget
/// - Purpose: Submodule switcher popover menu for DynamicActionBar with live search filter when items > 5 and vertical list of MicroButtons.
/// - Widget Composition: shad.Card -> Column(Search TextField + Scrollable MicroButton list).

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../specs/dy_grid_system.dart';

/// Data item model for [DabSubmodulePopover].
class DabSubmoduleItem<T> {
  final T id;
  final String label;
  final IconData icon;
  final int count;

  const DabSubmoduleItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.count,
  });
}

/// Standalone DAB Submodule Switcher Popover following standard DAB popover specs:
/// - Width: `DyGridSystem.popWidthStandard` (200px)
/// - Corner Radius: 8px, Inner Padding: 8px
/// - Max Height: 300px
/// - Top search textfield when item count > 5 with 8px gap
/// - Crisp 36px height `SecondaryButton` for selected state, `GhostButton` for unselected state
class DabSubmodulePopover<T> extends StatefulWidget {
  final String title;
  final T selectedId;
  final List<DabSubmoduleItem<T>> items;
  final ValueChanged<T> onSelected;

  const DabSubmodulePopover({
    super.key,
    this.title = 'Submodule',
    required this.selectedId,
    required this.items,
    required this.onSelected,
  });

  @override
  State<DabSubmodulePopover<T>> createState() => _DabSubmodulePopoverState<T>();
}

class _DabSubmodulePopoverState<T> extends State<DabSubmodulePopover<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final filteredItems = widget.items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.label.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return shad.Card(
      padding: EdgeInsets.all(8 * theme.scaling),
      child: SizedBox(
        width: DyGridSystem.popWidthStandard * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Clean Top Search Field (if items > 5)
            if (widget.items.length > 5) ...[
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
                onChanged: (val) => setState(() => _searchQuery = val),
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

            // 2. Scrollable List Container (maxHeight 300px)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300 * theme.scaling),
              child: filteredItems.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(12 * theme.scaling),
                      child: Center(
                        child: Text(
                          'No submodules found',
                          style: theme.typography.xSmall.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = item.id == widget.selectedId;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 4 * theme.scaling),
                          child: isSelected
                              ? shad.SecondaryButton(
                                  onPressed: () {
                                    shad.closeOverlay(context);
                                    widget.onSelected(item.id);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 14 * theme.scaling,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.typography.textSmall.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.foreground,
                                          ),
                                        ),
                                      ),
                                      if (item.count > 0)
                                        shad.PrimaryBadge(
                                          child: Text('${item.count}'),
                                        ),
                                    ],
                                  ),
                                )
                              : shad.GhostButton(
                                  onPressed: () {
                                    shad.closeOverlay(context);
                                    widget.onSelected(item.id);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 14 * theme.scaling,
                                        color: colors.mutedForeground,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.typography.textSmall.copyWith(
                                            color: colors.foreground,
                                          ),
                                        ),
                                      ),
                                      if (item.count > 0)
                                        shad.SecondaryBadge(
                                          child: Text('${item.count}'),
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
