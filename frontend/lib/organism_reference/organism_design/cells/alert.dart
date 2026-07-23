import 'package:flutter/material.dart';
import '../theme.dart';
import 'badge.dart'; // Direct import for CellBadgeVariant
import 'box.dart';   // Direct import for CellBox
import 'spatial.dart'; // Direct import for CellGap

/// [CellAlert] — Inline semantic feedback banner.
///
/// Renders a bordered surface with an icon and title, tailored to semantic 
/// variants (success, warning, error, info). Uses [CellBox] as the base surface.
class CellAlert extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final CellBadgeVariant variant;

  const CellAlert({
    super.key,
    required this.title,
    this.message,
    required this.icon,
    this.variant = CellBadgeVariant.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    Color bg = colors.surfaceSubtle;
    Color border = colors.border;
    Color text = colors.textPrimary;

    if (variant == CellBadgeVariant.error) {
      bg = colors.errorSubtle;
      border = colors.error.withValues(alpha: 0.2);
      text = colors.error;
    } else if (variant == CellBadgeVariant.warning) {
      bg = colors.warningSubtle;
      border = colors.warning.withValues(alpha: 0.2);
      text = colors.warning;
    } else if (variant == CellBadgeVariant.success) {
      bg = colors.successSubtle;
      border = colors.success.withValues(alpha: 0.2);
      text = colors.success;
    } else if (variant == CellBadgeVariant.primary) {
      bg = colors.primarySubtle;
      border = colors.primary.withValues(alpha: 0.2);
      text = colors.primary;
    }

    return CellBox(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      backgroundColor: bg,
      border: Border.all(color: border),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: OrganismTheme.iconSizeMd, color: text),
          CellGap.standard,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: OrganismTheme.labelLarge(context).copyWith(color: text, fontWeight: FontWeight.w700)),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(message!, style: OrganismTheme.bodySmall(context).copyWith(color: text.withValues(alpha: 0.8))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
