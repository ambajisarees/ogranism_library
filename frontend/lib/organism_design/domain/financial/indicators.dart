import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainDueDateBadge] — Semantic date tracker for financial compliance.
///
/// Turns RED if the date is in the past (overdue).
class DomainDueDateBadge extends StatelessWidget {
  final DateTime date;

  const DomainDueDateBadge({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = date.isBefore(DateTime(now.year, now.month, now.day));
    return CellBadge(
      text: '${date.day}/${date.month}/${date.year}',
      variant: isOverdue ? CellBadgeVariant.error : CellBadgeVariant.secondary,
    );
  }
}

/// [DomainTransactionIcon] — Movement indicator for Dr/Cr flows.
///
/// Visualizes money in (Green Arrow) vs Money Out (Red Arrow).
class DomainTransactionIcon extends StatelessWidget {
  final bool isInbound; // true = Money In (Receipt), false = Money Out (Payment)

  const DomainTransactionIcon({
    super.key,
    required this.isInbound,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Icon(
      isInbound ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
      size: 14,
      color: isInbound ? colors.success : colors.error,
    );
  }
}

/// [DomainDiscountPill] — Semantic percentage badge for sales/purchase.
///
/// Renders as a small Fuchsia pill with percentage text.
class DomainDiscountPill extends StatelessWidget {
  final double percentage;

  const DomainDiscountPill({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}% OFF',
        style: OrganismTheme.labelSmall(context).copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: colors.primary,
        ),
      ),
    );
  }
}
