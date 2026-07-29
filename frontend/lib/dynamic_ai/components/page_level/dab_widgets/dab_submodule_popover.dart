import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../micro_level/micro_button.dart';

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
/// - Native `shad.Card` surface container
/// - Optional top search bar when item count > 5
/// - Vertical list of `MicroButton` controls with leading icon, label, and trailing count badge
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
        width: 220 * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280 * theme.scaling),
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
                          child: MicroButton(
                            leadingIcon: item.icon,
                            label: item.label,
                            badgeCount: item.count,
                            isSelected: isSelected,
                            onPressed: () {
                              shad.closeOverlay(context);
                              widget.onSelected(item.id);
                            },
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
