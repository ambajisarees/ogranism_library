import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'spatial.dart'; // Direct import for CellPad/CellGap

/// [CellTag] — Removable labeled tag chip atom.
///
/// Distinct from [CellBadge] (status only). [CellTag] represents an applied 
/// value (like a filter) and exposes an optional [onRemove] button.

/// Visual style variants for [CellTag].
enum CellTagVariant { neutral, accent, success, warning, error }

/// CellTag — Removable labeled tag chip.
///
/// Distinct from [CellFilterChip] (boolean toggle) and [CellBadge] (non-interactive status).
/// CellTag is an **interactive object**: it represents an applied value,
/// and optionally exposes a remove (×) button via [onRemove].
///
/// Use cases:
/// - Applied filter labels ("Quality: Dola Silk")
/// - Multi-select chosen values
/// - Party account type labels with removal
/// - Search tag collections
///
/// ```dart
/// // Static tag
/// CellTag(label: 'Dola Silk')
///
/// // Accent variant with remove
/// CellTag(
///   label: 'Quality: DS',
///   variant: CellTagVariant.accent,
///   onRemove: () => removeFilter(),
/// )
///
/// // Error state
/// CellTag(label: 'Invalid', variant: CellTagVariant.error)
/// ```
class CellTag extends StatelessWidget {
  /// The text label displayed inside the tag.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Visual intent variant. Defaults to neutral.
  final CellTagVariant variant;

  /// If provided, renders a × dismiss button on the trailing edge.
  final VoidCallback? onRemove;

  /// If provided, makes the entire tag tappable.
  final VoidCallback? onTap;

  const CellTag({
    super.key,
    required this.label,
    this.icon,
    this.variant = CellTagVariant.neutral,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final (bgColor, borderColor, textColor) = _resolveColors(colors);

    final content = Container(
      padding: EdgeInsets.only(
        left: icon != null ? OrganismTheme.spacingSm : OrganismTheme.spacingSm + OrganismTheme.spacing2Xs,
        right: onRemove != null ? OrganismTheme.spacingXs : OrganismTheme.spacingSm + OrganismTheme.spacing2Xs,
        top: OrganismTheme.spacingXs - OrganismTheme.spacing2Xs,
        bottom: OrganismTheme.spacingXs - OrganismTheme.spacing2Xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: OrganismTheme.borderPill,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading icon
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],

          // Label
          Text(
            label,
            style: OrganismTheme.bodySmall(context).copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),

          // Remove button
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(OrganismTheme.spacing2Xs),
                child: Icon(
                  LucideIcons.x,
                  size: OrganismTheme.iconSizeXs,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  /// Returns (background, border, text) colors for the given variant.
  (Color, Color, Color) _resolveColors(OrganismColors colors) {
    return switch (variant) {
      CellTagVariant.neutral => (
          colors.stone100,
          colors.border,
          colors.textSecondary,
        ),
      CellTagVariant.accent => (
          colors.primary.withValues(alpha: 0.08),
          colors.primary.withValues(alpha: 0.25),
          colors.primary,
        ),
      CellTagVariant.success => (
          colors.successSubtle,
          colors.success.withValues(alpha: 0.3),
          colors.success,
        ),
      CellTagVariant.warning => (
          colors.warningSubtle,
          colors.warning.withValues(alpha: 0.3),
          colors.warning,
        ),
      CellTagVariant.error => (
          colors.errorSubtle,
          colors.error.withValues(alpha: 0.3),
          colors.error,
        ),
    };
  }
}
