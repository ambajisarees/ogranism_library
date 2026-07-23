import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';

/// [CellInputChip] — Tokenized tag entry atom.
///
/// An interactive pill that can be dismissed. Used as results in multi-select 
/// comboboxes and tag entry fields.

/// An interactive badge that can be deleted. Standard for multi-select combo boxes.
class CellInputChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const CellInputChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: OrganismTheme.borderSm,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: OrganismTheme.bodySmall(context).copyWith(color: colors.textPrimary)),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDeleted,
            hoverColor: colors.surfaceActive,
            borderRadius: OrganismTheme.borderSm,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                LucideIcons.x,
                size: OrganismTheme.iconSizeXs,
                color: colors.textSecondary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
