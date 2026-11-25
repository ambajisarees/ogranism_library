/*
================================================================================
LLM CONTEXT & QUERY SPACE — DAB SORT POPOVER (dab_sort_popover.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Native `shad.DropdownMenu` sort menu for non-table views (`list`, `cards`, `board`).
   - Uses `shad.MenuRadioGroup<String>` for field selection and
     `shad.MenuRadioGroup<bool>` for sort order (`Ascending` / `Descending`),
     with built-in `SubFocusScope` keyboard navigation and `Esc` dismissal.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Pure native `shadcn_flutter` `DropdownMenu` + `MenuRadioGroup` + `MenuRadio`.
================================================================================
*/

import 'package:flutter/widgets.dart';
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

/// [DabSortPopover] — Native `shad.DropdownMenu` for Non-Table View Sorting.
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
    return shad.DropdownMenu(
      children: [
        const shad.MenuLabel(child: Text('Sort By')),
        const shad.MenuDivider(),
        shad.MenuRadioGroup<String>(
          value: selectedId,
          onChanged: (ctx, val) => onSelected(val),
          children: [
            for (final opt in options)
              shad.MenuRadio<String>(
                value: opt.id,
                trailing: opt.icon != null ? Icon(opt.icon, size: 14) : null,
                child: Text(opt.label),
              ),
          ],
        ),
        const shad.MenuDivider(),
        const shad.MenuLabel(child: Text('Direction')),
        shad.MenuRadioGroup<bool>(
          value: isAscending,
          onChanged: (ctx, val) {
            if (val != isAscending) {
              onToggleDirection();
            }
          },
          children: const [
            shad.MenuRadio<bool>(
              value: true,
              trailing: Icon(shad.LucideIcons.arrowUp, size: 14),
              child: Text('Ascending'),
            ),
            shad.MenuRadio<bool>(
              value: false,
              trailing: Icon(shad.LucideIcons.arrowDown, size: 14),
              child: Text('Descending'),
            ),
          ],
        ),
      ],
    );
  }
}
