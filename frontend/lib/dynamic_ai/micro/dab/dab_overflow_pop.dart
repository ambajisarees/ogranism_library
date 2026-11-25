/// LLM NOTE: DabOverflowPopover
/// - Level: DAB Popover Component
/// - Purpose: Native `shad.DropdownMenu` overflow menu for Three-Dots trailing button in DynamicActionBar providing quick actions (Export View Data, Column Visibility, Density Settings, Reset View Layout).
/// - Widget Composition: `shad.DropdownMenu` -> `MenuLabel`, `MenuDivider`, `MenuButton`.

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Overflow Dropdown Menu for Three-Dots trailing button in DAB.
class DabOverflowPopover extends StatelessWidget {
  final VoidCallback? onExportPressed;
  final VoidCallback? onColumnSpecsPressed;
  final VoidCallback? onDensityPressed;
  final VoidCallback? onResetLayoutPressed;

  const DabOverflowPopover({
    super.key,
    this.onExportPressed,
    this.onColumnSpecsPressed,
    this.onDensityPressed,
    this.onResetLayoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return shad.DropdownMenu(
      children: [
        const shad.MenuLabel(child: Text('Table Actions')),
        const shad.MenuDivider(),
        shad.MenuButton(
          leading: const Icon(shad.LucideIcons.download),
          onPressed: (_) => onExportPressed?.call(),
          child: const Text('Export View Data'),
        ),
        shad.MenuButton(
          leading: const Icon(shad.LucideIcons.columns3),
          onPressed: (_) => onColumnSpecsPressed?.call(),
          child: const Text('Column Visibility'),
        ),
        shad.MenuButton(
          leading: const Icon(shad.LucideIcons.slidersHorizontal),
          onPressed: (_) => onDensityPressed?.call(),
          child: const Text('Density Settings'),
        ),
        const shad.MenuDivider(),
        shad.MenuButton(
          leading: const Icon(shad.LucideIcons.rotateCcw),
          onPressed: (_) => onResetLayoutPressed?.call(),
          child: const Text('Reset View Layout'),
        ),
      ],
    );
  }
}
