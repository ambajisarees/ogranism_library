import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainAccountBadge] — Typed categorization for Party Masters.
///
/// Variants: Customer, Broker, Weaver, Supplier, Expense.
class DomainAccountBadge extends StatelessWidget {
  final String accountType; // CUSTOMER, BROKER, WEAVER, etc.

  const DomainAccountBadge({
    super.key,
    required this.accountType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    Color color;
    switch (accountType.toUpperCase()) {
      case 'CUSTOMER':
        color = colors.primary;
        break;
      case 'BROKER':
        color = colors.warning;
        break;
      case 'WEAVER':
        color = colors.success;
        break;
      default:
        color = colors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        accountType.toUpperCase(),
        style: OrganismTheme.labelSmall(context).copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// [DomainBalanceDisplay] — High-fidelity financial balance.
///
/// Automatically appends Dr/Cr and applies semantic coloring.
class DomainBalanceDisplay extends StatelessWidget {
  final double amount;
  final bool isCompact;

  const DomainBalanceDisplay({
    super.key,
    required this.amount,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDr = amount > 0;
    final colors = OrganismTheme.colorsOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          amount.abs().toStringAsFixed(2), // Simple format for now, DomainAmount handles better
          style: (isCompact ? OrganismTheme.numericSmall(context) : OrganismTheme.numericMedium(context)).copyWith(
            fontWeight: FontWeight.w700,
            color: isDr ? colors.error : colors.success,
          ),
        ),
        const CellGap(0.25),
        Text(
          isDr ? 'Dr' : 'Cr',
          style: OrganismTheme.labelSmall(context).copyWith(
            fontSize: isCompact ? 8 : 10,
            color: isDr ? colors.error : colors.success,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
