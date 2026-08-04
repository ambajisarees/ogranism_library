/*
================================================================================
LLM CONTEXT & QUERY SPACE — DAB GROUP SWITCHER (dab_group_switcher.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Grouping switcher button group component for DynamicActionBar (DAB).
   - Exact visual replica of View Switcher button group with 4 grouping modes.
   - First option is ALWAYS 'None' (id: 'none', label: 'None', icon: LucideIcons.layoutList).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Built with 34px height `MicroButton` controls matching native DAB button group tokens.
   - Native `shadcn_flutter` color scheme (`colors.card`, `colors.border`, `theme.radiusMd`).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../dy_micro_button.dart';

/// Grouping option model for [DabGroupSwitcher].
class DabGroupOption {
  final String id;
  final String label;
  final IconData icon;

  const DabGroupOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Default grouping options (First option is ALWAYS 'None').
const List<DabGroupOption> kDefaultGroupOptions = [
  DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
  DabGroupOption(id: 'mill', label: 'Mill', icon: shad.LucideIcons.warehouse),
  DabGroupOption(id: 'fabric', label: 'Fabric', icon: shad.LucideIcons.shirt),
  DabGroupOption(id: 'cut', label: 'Cut', icon: shad.LucideIcons.scissors),
];

/// [DabGroupSwitcher] — 4-Option Grouping Switcher Button Group for DAB.
class DabGroupSwitcher extends StatelessWidget {
  final String selectedGroup;
  final ValueChanged<String> onGroupChanged;
  final List<DabGroupOption> groups;

  const DabGroupSwitcher({
    super.key,
    required this.selectedGroup,
    required this.onGroupChanged,
    this.groups = kDefaultGroupOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: shad.OutlinedContainer(
        borderRadius: BorderRadius.circular(theme.radiusMd),
        borderColor: colors.border,
        backgroundColor: colors.card,
        padding: const EdgeInsets.all(2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: groups.map((g) {
            final bool isSelected = selectedGroup == g.id;

            return shad.Tooltip(
              anchorAlignment: Alignment.bottomCenter,
              alignment: Alignment.topCenter,
              tooltip: (context) => shad.TooltipContainer(
                child: Text('Group by: ${g.label}'),
              ),
              child: MicroButton(
                label: isSelected ? g.label : '',
                leadingIcon: g.icon,
                isSelected: isSelected,
                isGhost: !isSelected,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 10 * theme.scaling : 8 * theme.scaling,
                  vertical: 6 * theme.scaling,
                ),
                onPressed: () => onGroupChanged(g.id),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
