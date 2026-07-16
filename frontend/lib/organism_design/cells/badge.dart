import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'focus.dart'; // Direct import for OrganismFocus

/// [CellBadge] — Non-interactive semantic density pill.
///
/// Communicates state (PAID, PENDING, ACTIVE) using density-standard colors.
/// Supports an optional [onDismiss] action for removable chips.

/// Defines the visual intent of a Semantic Badge.
enum CellBadgeVariant { primary, secondary, outline, success, warning, error }

/// A highly dense, non-interactive visual data flag used entirely to communicate state
/// without text clutter (e.g. "PAID", "PENDING", "ACTIVE").
class CellBadge extends StatelessWidget {
  final String text;
  final CellBadgeVariant variant;
  final IconData? icon;

  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Color? customColor;

  const CellBadge({
    super.key,
    required this.text,
    this.variant = CellBadgeVariant.primary,
    this.icon,
    this.onTap,
    this.onDismiss,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    Color bgColor;
    Color fgColor;
    Border? border;

    if (customColor != null) {
      bgColor = customColor!;
      fgColor = customColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      border = null;
    } else {
      switch (variant) {
        case CellBadgeVariant.primary:
          bgColor = colors.primary;
          fgColor = Colors.white;
          border = null;
          break;
        case CellBadgeVariant.secondary:
          bgColor = colors.surfaceSubtle;
          fgColor = colors.textSecondary;
          border = null;
          break;
        case CellBadgeVariant.outline:
          bgColor = Colors.transparent;
          fgColor = colors.textPrimary;
          border = Border.all(color: colors.border);
          break;
        case CellBadgeVariant.success:
          bgColor = colors.successSubtle;
          fgColor = colors.success;
          border = Border.all(color: colors.success.withValues(alpha: 0.2));
          break;
        case CellBadgeVariant.warning:
          bgColor = colors.warningSubtle;
          fgColor = colors.warning;
          border = Border.all(color: colors.warning.withValues(alpha: 0.2));
          break;
        case CellBadgeVariant.error:
          bgColor = colors.errorSubtle;
          fgColor = colors.error;
          border = Border.all(color: colors.error.withValues(alpha: 0.2));
          break;
      }
    }

    Widget content = Container(
      padding: const EdgeInsets.only(
        left: OrganismTheme.spacingSm,
        right: OrganismTheme.spacingSm,
        top: OrganismTheme.spacing2Xs,
        bottom: OrganismTheme.spacing2Xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: OrganismTheme.borderPill,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: OrganismTheme.iconSizeXs, color: fgColor),
            const SizedBox(width: OrganismTheme.spacingXs),
          ],
          Text(
            text.toUpperCase(),
            style: OrganismTheme.labelMedium(context).copyWith(
              height: 1.2,
              color: fgColor,
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: OrganismTheme.spacingXs),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(OrganismTheme.spacing2Xs),
                decoration: BoxDecoration(
                  color: fgColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                width: OrganismTheme.buttonHeightCompact * 0.75,
                height: OrganismTheme.buttonHeightCompact * 0.75,
                child: Icon(LucideIcons.x, size: OrganismTheme.iconSizeXs, color: fgColor),
              ),
            ),
          ]
        ],
      ),
    );

    if (onTap != null) {
      return OrganismFocus(
        onTap: onTap,
        borderRadius: OrganismTheme.borderPill,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: content,
        ),
      );
    }

    return content;
  }
}
