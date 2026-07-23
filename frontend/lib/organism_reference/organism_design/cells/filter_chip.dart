import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'spatial.dart'; // Direct import for CellGap

/// [CellFilterChip] — Toggle metadata chip for grid filtering.
///
/// A pill-shaped interactive atom used to toggle query parameters in list views.
/// Provides a clear visual "selected" state and optional removal action.

/// Filter chip for applying and removing datagrid query parameters.
class CellFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final VoidCallback? onDeleted;

  const CellFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    Color bg = isSelected
        ? colors.primaryLight.withValues(alpha: 0.1)
        : colors.surface;
    Color border = isSelected ? colors.primary : colors.border;
    Color text = isSelected ? colors.primary : colors.textSecondary;

    return MouseRegion(
      cursor: onSelected != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingMd,
            vertical: onDeleted != null ? 6.0 : 8.0,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: OrganismTheme.borderXl, // Extra pill rounding
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style:
                      OrganismTheme.labelLarge(context).copyWith(color: text)),
              if (onDeleted != null) ...[
                CellGap.small,
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onDeleted,
                    child: Icon(LucideIcons.x, size: 14, color: text),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
