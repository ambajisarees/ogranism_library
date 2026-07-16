import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellBox] — Atomic surface container.
///
/// Implements the standard layout boundaries (1px border, [borderMd] radius).
/// Centralizes surface logic for more complex Tissues and Organs.

/// A geometric primitive handling the standard "Shadcn-style" layout boundary.
/// Centralizes border, surface, radius, and shadow logic for all Tissues/Organs.
class CellBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasShadow;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? width;
  final double? height;

  const CellBox({
    super.key,
    required this.child,
    this.padding,
    this.hasShadow = false,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: borderRadius ?? OrganismTheme.borderMd,
        border: border ?? Border.all(color: colors.border),
        boxShadow: hasShadow ? OrganismTheme.shadowSm : null,
      ),
      child: child,
    );
  }
}
