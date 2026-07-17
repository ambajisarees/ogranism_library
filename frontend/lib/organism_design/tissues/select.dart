import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/label.dart';    // Direct import for CellLabel
import '../cells/spatial.dart';  // Direct import for CellGap/CellPad
import '../plasma/popover.dart'; // Direct import for PlasmaPopover
import 'list_card.dart';         // Local sister import

/// [TissueSelect] — High-fidelity anchored selection molecule.
///
/// A headless-style Select trigger that uses [PlasmaPopover] to display 
/// a list of options. Implements [itemLabelBuilder] for custom data mapping.

/// A headless-style Select trigger that uses PlasmaPopover.
class TissueSelect<T> extends StatelessWidget {
  final T? value;
  final String label;
  final String? placeholder;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T> onChanged;

  const TissueSelect({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CellLabel(text: label),
        CellGap.small,
        PlasmaPopover(
      trigger: Container(
        height: OrganismTheme.buttonHeightStandard,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: OrganismTheme.borderSm,
          border: Border.all(color: colors.border),
        ),
        child: CellPad(
          horizontalMultiplier: 1.0,
          verticalMultiplier: 0.0,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value != null ? itemLabelBuilder(value as T) : (placeholder ?? 'Select option'),
                  style: OrganismTheme.bodyLarge(context).copyWith(
                    color: value != null ? colors.textPrimary : colors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const CellGap(0.5),
              Icon(
                LucideIcons.chevronsUpDown,
                size: OrganismTheme.iconSizeSm,
                color: OrganismTheme.iconSecondary(context),
              ),
            ],
          ),
        ),
      ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              final isSelected = item == value;
              return TissueListCard(
                isCompact: true,
                isSelected: isSelected,
                onTap: () => onChanged(item),
                title: Text(itemLabelBuilder(item), style: OrganismTheme.labelLarge(context)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
