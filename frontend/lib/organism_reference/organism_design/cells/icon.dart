import 'package:flutter/material.dart';
import '../theme.dart';

/// Semantic token variants enforcing color alignments.
enum CellIconVariant { inherit, primary, error, warning, success, muted }

/// Semantic sizing constraints matching typical grid arrays.
enum CellIconSize { 
  small,    // 14px 
  standard, // 16px 
  large,    // 20px
  huge      // 24px
}

/// [CellIcon] — Standardized native layout primitive for iconography.
///
/// Prevents code bases from scattering arbitrary Icon() declarations with raw sizes 
/// or raw hex codes. Constrains against the active [OrganismTheme].
class CellIcon extends StatelessWidget {
  final IconData icon;
  final CellIconVariant variant;
  final CellIconSize size;

  const CellIcon(
    this.icon, {
    super.key,
    this.variant = CellIconVariant.inherit,
    this.size = CellIconSize.standard,
  });

  double _getSize() {
    switch (size) {
      case CellIconSize.small:
        return 14.0;
      case CellIconSize.standard:
        return OrganismTheme.iconSizeSm; // 16px
      case CellIconSize.large:
        return OrganismTheme.iconSizeMd; // 20px
      case CellIconSize.huge:
        return OrganismTheme.iconSizeLg; // 24px
    }
  }

  Color? _getColor(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    switch (variant) {
      case CellIconVariant.inherit:
        return null; // Leave as native inheritance from textual parents
      case CellIconVariant.primary:
        return colors.primary;
      case CellIconVariant.error:
        return colors.error;
      case CellIconVariant.warning:
        return colors.warning;
      case CellIconVariant.success:
        return colors.success;
      case CellIconVariant.muted:
        return colors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: _getSize(),
      color: _getColor(context),
    );
  }
}
