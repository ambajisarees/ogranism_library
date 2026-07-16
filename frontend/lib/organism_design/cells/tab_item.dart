import 'package:flutter/material.dart';
import '../theme.dart';
import 'kbd.dart';

/// [CellTabItem] — A high-density interaction atom for page-level navigation.
///
/// Designed to fit seamlessly within a 56px [TissueTabChrome] tray.
/// Implements a Shadcn-inspired minimalist aesthetic with high-contrast active states.
class CellTabItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? kbdShortcut;
  final bool isSelected;
  final VoidCallback onTap;

  const CellTabItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.kbdShortcut,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final textStyle = OrganismTheme.bodyMedium(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.primary.withValues(alpha: 0.1),
        hoverColor: colors.surfaceSubtle,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
          constraints: const BoxConstraints(minWidth: 120),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            color: isSelected ? colors.surface : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? colors.primary : colors.textMuted,
              ),
              const SizedBox(width: OrganismTheme.spacingMd),
              Text(
                title,
                style: textStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? colors.textPrimary : colors.textMuted,
                  letterSpacing: -0.2,
                ),
              ),
              if (kbdShortcut != null) ...[
                const SizedBox(width: OrganismTheme.spacingLg),
                Opacity(
                  opacity: isSelected ? 1.0 : 0.6,
                  child: CellKbd(keyString: kbdShortcut!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
