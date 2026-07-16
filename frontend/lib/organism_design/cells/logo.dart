import 'package:flutter/material.dart';
import '../theme.dart';
import 'spatial.dart'; // Direct import for CellGap

/// [AmbajiSareeLogo] — Branded wordmark and icon renderer atom.
///
/// Implements the visual identity of Ambaji Sarees. Supports collapsed
/// (icon-only) and expanded (icon + typography) states.

/// A premium, native code-based logo for Ambaji Sarees.
/// Supports a collapsed (Icon-only) and expanded (Text + Icon) state.
class AmbajiSareeLogo extends StatelessWidget {
  final bool isCollapsed;
  final double size;

  const AmbajiSareeLogo({
    super.key,
    this.isCollapsed = false,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    // The "Box" icon built from primitive containers to ensure exact branding.
    final boxIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(size * 0.1),
          ),
        ),
      ),
    );

    if (isCollapsed) return boxIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        boxIcon,
        CellGap.standard,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AMBAJI',
              style: OrganismTheme.titleLarge(context).copyWith(
                fontSize: size * 0.6,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
                color: colors.primary,
                height: 1.0,
              ),
            ),
            Text(
              'SAREES',
              style: OrganismTheme.labelLarge(context).copyWith(
                fontSize: size * 0.3,
                letterSpacing: 4.0,
                color: colors.textMuted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
