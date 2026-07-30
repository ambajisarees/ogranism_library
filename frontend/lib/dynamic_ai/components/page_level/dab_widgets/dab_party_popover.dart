import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DabPartyPopover] — Standalone Party / Supplier Selection Popover for DynamicActionBar.
/// Allows multi-selecting suppliers/parties with dynamic live search and quick select/clear options.
class DabPartyPopover extends StatefulWidget {
  final Set<String> selectedParties;
  final List<String> partyOptions;
  final ValueChanged<Set<String>> onChanged;

  const DabPartyPopover({
    super.key,
    required this.selectedParties,
    required this.partyOptions,
    required this.onChanged,
  });

  @override
  State<DabPartyPopover> createState() => _DabPartyPopoverState();
}

class _DabPartyPopoverState extends State<DabPartyPopover> {
  late Set<String> _currentParties;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentParties = Set.from(widget.selectedParties);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final filteredOptions = widget.partyOptions.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final isAllSelected = widget.partyOptions.isNotEmpty && _currentParties.length == widget.partyOptions.length;

    return shad.Card(
      padding: EdgeInsets.all(8 * theme.scaling),
      child: SizedBox(
        width: 240 * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Search Bar (Rendered when options > 5)
            if (widget.partyOptions.length > 5) ...[
              shad.TextField(
                filled: true,
                placeholder: const Text('Search parties...'),
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

            // 2. Select All / Clear Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * theme.scaling, vertical: 2 * theme.scaling),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  shad.GhostButton(
                    density: shad.ButtonDensity.compact,
                    size: shad.ButtonSize.xSmall,
                    onPressed: () {
                      setState(() {
                        if (isAllSelected) {
                          _currentParties.clear();
                        } else {
                          _currentParties = Set.from(widget.partyOptions);
                        }
                      });
                      widget.onChanged(_currentParties);
                    },
                    child: Text(
                      isAllSelected ? 'Deselect All' : 'Select All',
                      style: theme.typography.xSmall.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_currentParties.isNotEmpty)
                    shad.GhostButton(
                      density: shad.ButtonDensity.compact,
                      size: shad.ButtonSize.xSmall,
                      onPressed: () {
                        setState(() {
                          _currentParties.clear();
                        });
                        widget.onChanged(_currentParties);
                      },
                      child: Text(
                        'Reset',
                        style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                      ),
                    ),
                ],
              ),
            ),
            const shad.Divider(),

            // 3. Scrollable List of Checkboxes
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 260 * theme.scaling),
              child: filteredOptions.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(12 * theme.scaling),
                      child: Center(
                        child: Text(
                          'No parties found',
                          style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: filteredOptions.length,
                      itemBuilder: (context, index) {
                        final party = filteredOptions[index];
                        final isChecked = _currentParties.contains(party);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isChecked) {
                                _currentParties.remove(party);
                              } else {
                                _currentParties.add(party);
                              }
                            });
                            widget.onChanged(_currentParties);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isChecked ? colors.accent.withAlpha(100) : const Color(0x00000000),
                              borderRadius: BorderRadius.circular(theme.radiusSm),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * theme.scaling,
                              vertical: 6 * theme.scaling,
                            ),
                            child: Row(
                              children: [
                                shad.Checkbox(
                                  state: isChecked ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
                                  onChanged: (state) {
                                    setState(() {
                                      if (state == shad.CheckboxState.checked) {
                                        _currentParties.add(party);
                                      } else {
                                        _currentParties.remove(party);
                                      }
                                    });
                                    widget.onChanged(_currentParties);
                                  },
                                ),
                                const shad.DensityGap(shad.gapSm),
                                Expanded(
                                  child: Text(
                                    party,
                                    style: theme.typography.textSmall.copyWith(
                                      fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                      color: colors.foreground,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
