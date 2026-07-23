import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellGap] is a raw spatial utility that enforces strict multiples of OrganismTheme.spacingMd.
/// Replaces the pattern: `SizedBox(width: OrganismTheme.spacingMd)`.
class CellGap extends StatelessWidget {
  final double multiplier;

  const CellGap([this.multiplier = 1.0, Key? key]) : super(key: key);

  /// Predefined constant for a standard 16px gap.
  static const standard = CellGap(1.0);
  
  /// Predefined constant for a small 8px gap.
  static const small = CellGap(0.5);
  
  /// Predefined constant for a large 24px gap.
  static const large = CellGap(1.5);

  @override
  Widget build(BuildContext context) {
    final size = OrganismTheme.spacingMd * multiplier;
    return SizedBox(width: size, height: size);
  }
}

/// [CellPad] is a layout utility that wraps a child in Padding enforced by multiples of OrganismTheme.spacingMd.
/// Replaces the pattern: `Padding(padding: EdgeInsets.all(OrganismTheme.spacingMd))`.
class CellPad extends StatelessWidget {
  final Widget child;
  final double multiplier;
  final double? horizontalMultiplier;
  final double? verticalMultiplier;

  const CellPad({
    required this.child,
    this.multiplier = 1.0,
    this.horizontalMultiplier,
    this.verticalMultiplier,
    super.key,
  });

  /// Factory for standard 16px padding.
  factory CellPad.standard({required Widget child, Key? key}) => 
    CellPad(key: key, multiplier: 1.0, child: child);
    
  /// Factory for small 8px padding.
  factory CellPad.small({required Widget child, Key? key}) => 
    CellPad(key: key, multiplier: 0.5, child: child);
    
  /// Factory for large 24px padding.
  factory CellPad.large({required Widget child, Key? key}) => 
    CellPad(key: key, multiplier: 1.5, child: child);

  @override
  Widget build(BuildContext context) {
    const base = OrganismTheme.spacingMd;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (horizontalMultiplier ?? multiplier) * base,
        vertical: (verticalMultiplier ?? multiplier) * base,
      ),
      child: child,
    );
  }
}
