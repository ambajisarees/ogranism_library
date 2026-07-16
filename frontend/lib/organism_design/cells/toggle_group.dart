import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellToggleGroup] — Logical controller for multiple selection states.
///
/// A mutually exclusive segmented control group for high-density settings.
/// Unified borders with internal dividers and selection styling.

/// A mutually exclusive segmented control group for highly dense settings (e.g. List vs Grid).
class CellToggleGroup<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final ValueChanged<T> onChanged;

  const CellToggleGroup({
    super.key,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: OrganismTheme.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final isSelected = entry.value == value;
          final isLast = entry.key == items.length - 1;
          return GestureDetector(
            onTap: () => onChanged(entry.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? colors.surfaceSubtle : Colors.transparent,
                border: Border(
                  right: isLast ? BorderSide.none : BorderSide(color: colors.border),
                ),
              ),
              child: Center(
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: colors.textPrimary),
                  child: itemBuilder(entry.value),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
