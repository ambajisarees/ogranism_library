/*
================================================================================
LLM CONTEXT & QUERY SPACE — DAB SORT POPOVER (dab_sort_popover.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Floating popover menu for non-table view sorting (`list`, `cards`, `board`).
   - Renders a list of available sort fields with active checkmark indicator & direction toggle.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses native `shadcn_flutter` tokens (`colors.card`, `colors.border`, `theme.radiusMd`).
   - Width: 220px fixed popover container.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Item option model for [DabSortPopover].
class DabSortOption {
  final String id;
  final String label;
  final IconData? icon;

  const DabSortOption({
    required this.id,
    required this.label,
    this.icon,
  });
}

/// [DabSortPopover] — Popover Menu Widget for Non-Table View Sorting.
class DabSortPopover extends StatelessWidget {
  final String selectedId;
  final bool isAscending;
  final List<DabSortOption> options;
  final ValueChanged<String> onSelected;
  final VoidCallback onToggleDirection;

  const DabSortPopover({
    super.key,
    required this.selectedId,
    required this.isAscending,
    required this.options,
    required this.onSelected,
    required this.onToggleDirection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.SurfaceCard(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Title + Direction Toggle Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'SORT BY',
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.mutedForeground,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  shad.OutlineButton(
                    density: shad.ButtonDensity.compact,
                    onPressed: onToggleDirection,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAscending ? shad.LucideIcons.arrowUp : shad.LucideIcons.arrowDown,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAscending ? 'Asc' : 'Desc',
                          style: theme.typography.xSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 12),

            // Options List
            ...options.map((opt) {
              final isSelected = opt.id == selectedId;
              return shad.GhostButton(
                density: shad.ButtonDensity.compact,
                onPressed: () {
                  onSelected(opt.id);
                  shad.closeOverlay(context);
                },
                child: Row(
                  children: [
                    if (opt.icon != null) ...[
                      Icon(opt.icon, size: 14, color: isSelected ? colors.primary : colors.mutedForeground),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        opt.label,
                        style: theme.typography.small.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? colors.primary : colors.foreground,
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      Icon(shad.LucideIcons.check, size: 14, color: colors.primary),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
