/// LLM NOTE: DabOverflowPopover
/// - Level: DAB Popover Widget
/// - Purpose: Overflow menu for Three-Dots trailing button in DynamicActionBar providing quick actions (Export View Data, Column Visibility, Density Toggle, Reset Layout).
/// - Widget Composition: shad.Card -> Column(Vertical list of action buttons with leading icons).

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Overflow Popover for Three-Dots trailing button in DAB:
/// Displays additional table/data actions (Export, Column Specs, Density, Reset)
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
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final options = [
      _OverflowOption(
        icon: shad.LucideIcons.download,
        label: 'Export View Data',
        onTap: () {
          shad.closeOverlay(context);
          onExportPressed?.call();
        },
      ),
      _OverflowOption(
        icon: shad.LucideIcons.columns3,
        label: 'Column Visibility',
        onTap: () {
          shad.closeOverlay(context);
          onColumnSpecsPressed?.call();
        },
      ),
      _OverflowOption(
        icon: shad.LucideIcons.slidersHorizontal,
        label: 'Density Settings',
        onTap: () {
          shad.closeOverlay(context);
          onDensityPressed?.call();
        },
      ),
      _OverflowOption(
        icon: shad.LucideIcons.rotateCcw,
        label: 'Reset View Layout',
        onTap: () {
          shad.closeOverlay(context);
          onResetLayoutPressed?.call();
        },
      ),
    ];

    return shad.Card(
      padding: EdgeInsets.all(6 * theme.scaling),
      child: SizedBox(
        width: 190 * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * theme.scaling,
                vertical: 4 * theme.scaling,
              ),
              child: Text(
                'TABLE ACTIONS',
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.mutedForeground,
                  fontSize: 10 * theme.scaling,
                ),
              ),
            ),
            const shad.DensityGap(shad.gapXs),
            ...options.map((opt) {
              return GestureDetector(
                onTap: opt.onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * theme.scaling,
                    vertical: 6 * theme.scaling,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        opt.icon,
                        size: 14 * theme.scaling,
                        color: colors.foreground,
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Expanded(
                        child: Text(
                          opt.label,
                          style: theme.typography.textSmall.copyWith(
                            color: colors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OverflowOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OverflowOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
