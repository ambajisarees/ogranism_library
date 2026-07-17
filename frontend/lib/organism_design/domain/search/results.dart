import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainSearchOverlay] — High-density search result molecule.
///
/// Layout: [Type Icon] [Title] [Subtitle] | [Score/Metric]
class DomainSearchOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? metric;
  final VoidCallback? onTap;

  const DomainSearchOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.metric,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return CellMenuItem(
      onTap: onTap,
      icon: icon,
      label: title.toUpperCase(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle.toUpperCase(),
            style: OrganismTheme.labelSmall(context).copyWith(fontSize: 8),
          ),
          if (metric != null) ...[
            const CellGap(0.5),
            Text(
              metric!,
              style: OrganismTheme.numericSmall(context).copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// [DomainFilterPill] — Domain-specific filter tag.
///
/// Use for active filters (e.g. "Stage: O3", "Party: SMIT").
class DomainFilterPill extends StatelessWidget {
  final String category;
  final String value;
  final VoidCallback? onRemove;

  const DomainFilterPill({
    super.key,
    required this.category,
    required this.value,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return CellTag(
      label: '${category.toUpperCase()}: $value',
      variant: CellTagVariant.accent,
      onRemove: onRemove,
    );
  }
}
