import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainQualityBadge] — Specific mono-font code for Textile Qualities.
///
/// Example: "DOLA-SILK", "V-60".
class DomainQualityBadge extends StatelessWidget {
  final String quality;

  const DomainQualityBadge({
    super.key,
    required this.quality,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.stone800,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        quality.toUpperCase(),
        style: OrganismTheme.monoLabel(context).copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

/// [DomainDesignID] — Branded identification for Textile Designs.
///
/// Specific formatting for "Design No".
class DomainDesignID extends StatelessWidget {
  final String designNo;

  const DomainDesignID({
    super.key,
    required this.designNo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DSN',
          style: OrganismTheme.labelSmall(context).copyWith(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: colors.textSecondary,
          ),
        ),
        const CellGap(0.125),
        Text(
          designNo.toUpperCase(),
          style: OrganismTheme.monoLabel(context).copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}

/// [DomainShadeBadge] — Small identity chip for Shade Numbers.
///
/// Composed of a small color indicator (dot) and the shade code.
class DomainShadeBadge extends StatelessWidget {
  final String shadeNo;
  final Color? color;

  const DomainShadeBadge({
    super.key,
    required this.shadeNo,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: themeColors.stone900,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: themeColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color ?? themeColors.primary.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const CellGap(0.25),
          Text(
            shadeNo.toUpperCase(),
            style: OrganismTheme.monoLabel(context).copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
