import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellPad

/// [TissueTabs] — Section navigation control molecule.
///
/// Implements [underline] and [pill] variants for high-density navigation.
/// Centrally manages selection state and theme-aligned animations.


/// Highly compressed navigation list grouping blocks of data dynamically.
enum TissueTabsVariant { pill, underline }
class TissueTabs extends StatefulWidget {
  final List<String> tabs;
  final int initialIndex;
  final TissueTabsVariant variant;
  final ValueChanged<int>? onChanged;

  const TissueTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.variant = TissueTabsVariant.pill,
    this.onChanged,
  });

  @override
  State<TissueTabs> createState() => _TissueTabsState();
}

class _TissueTabsState extends State<TissueTabs> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    if (widget.variant == TissueTabsVariant.underline) {
      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.tabs.asMap().entries.map((entry) {
            final isSelected = _currentIndex == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() => _currentIndex = entry.key);
                if (widget.onChanged != null) widget.onChanged!(entry.key);
              },
              child: CellPad(
                horizontalMultiplier: 1.0,
                verticalMultiplier: 0.5,
                child: AnimatedContainer(
                  duration: OrganismTheme.durationFast,
                  curve: OrganismTheme.curveStandard,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? colors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: OrganismTheme.labelMedium(context).copyWith(
                      color: isSelected ? colors.textPrimary : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Pill variant
    return Container(
      padding: const EdgeInsets.all(OrganismTheme.spacingXs),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: OrganismTheme.borderMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.tabs.asMap().entries.map((entry) {
          final isSelected = _currentIndex == entry.key;
          return GestureDetector(
            onTap: () {
              setState(() => _currentIndex = entry.key);
              if (widget.onChanged != null) widget.onChanged!(entry.key);
            },
            child: CellPad(
              horizontalMultiplier: 1.0,
              verticalMultiplier: 0.25, // Reduced from 0.375
              child: AnimatedContainer(
                duration: OrganismTheme.durationFast,
                curve: OrganismTheme.curveStandard,
                padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd * 0.75, vertical: OrganismTheme.spacingXs * 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? colors.surface : Colors.transparent,
                  borderRadius: OrganismTheme.borderSm,
                  boxShadow: isSelected ? OrganismTheme.shadowSm : null,
                ),
                child: Text(
                  entry.value,
                  style: OrganismTheme.labelLarge(context).copyWith(
                    color: isSelected ? colors.textPrimary : colors.textSecondary,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
