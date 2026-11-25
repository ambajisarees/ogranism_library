/*
================================================================================
LLM CONTEXT & QUERY SPACE — DAB GROUP SWITCHER (dab_group_switcher.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Grouping switcher native `shad.ButtonGroup` component for DynamicActionBar (DAB).
   - Connected 36px outline segments using `shad.SelectedButton` with `ButtonStyle.outline`.
   - First option is ALWAYS 'None' (id: 'none', label: 'None', icon: LucideIcons.layoutList).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Built strictly with native `shad.ButtonGroup` + `shad.SelectedButton` controls
     inheriting global `OutlineButtonTheme` (`colors.background` / `colors.accent` / `radiusMd`).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

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

/// [DabGroupSwitcher] — Native `shad.ButtonGroup` Grouping Switcher for DAB.
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
    final scaling = theme.scaling;
    final iconSmSize = theme.iconTheme.small.size ?? 16.0;

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: SizedBox(
        height: 36 * scaling,
        child: shad.ButtonGroup(
          children: groups.map((g) {
            final bool isSelected = selectedGroup == g.id;
            final segmentStyle = const shad.ButtonStyle.outline().withPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12 * scaling : 10 * scaling,
              ),
            );

            return shad.FocusToFront(
              child: shad.Tooltip(
                anchorAlignment: Alignment.bottomCenter,
                alignment: Alignment.topCenter,
                tooltip: (context) => shad.TooltipContainer(
                  child: Text('Group by: ${g.label}'),
                ),
                child: shad.SelectedButton(
                  value: isSelected,
                  alignment: Alignment.center,
                  style: segmentStyle,
                  selectedStyle: segmentStyle,
                  onChanged: (_) => onGroupChanged(g.id),
                  child: Focus(
                    canRequestFocus: false,
                    skipTraversal: true,
                    descendantsAreFocusable: false,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          g.icon,
                          size: iconSmSize,
                          color: colors.mutedForeground,
                        ),
                        if (isSelected) ...[
                          const shad.DensityGap(shad.gapSm),
                          Text(
                            g.label,
                            style: theme.typography.textSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
