import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../amounts.dart';

/// [DomainLedgerEntry] — Dense row molecule for financial ledgers.
///
/// Layout: [Date] [Particulars] [Amount (Dr or Cr)]
class DomainLedgerEntry extends StatelessWidget {
  final DateTime date;
  final String particulars;
  final double amount;
  final bool isDr;

  const DomainLedgerEntry({
    super.key,
    required this.date,
    required this.particulars,
    required this.amount,
    required this.isDr,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          // Date Column
          SizedBox(
            width: 80,
            child: Text(
              '${date.day}/${date.month}/${date.year}',
              style: OrganismTheme.numericSmall(context).copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const CellGap(1.0),
          // Particulars
          Expanded(
            child: Text(
              particulars.toUpperCase(),
              style: OrganismTheme.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const CellGap(1.0),
          // Amount
          DomainAmount(
            value: amount,
            isCredit: !isDr,
            style: OrganismTheme.numericMedium(context),
          ),
        ],
      ),
    );
  }
}

/// [DomainGSTBreakdown] — Tabular summary for GST tiers.
///
/// Displays 5%, 12%, 18% tiers in a dense grid.
class DomainGSTBreakdown extends StatelessWidget {
  final Map<double, double> taxMap; // TaxRate -> Amount

  const DomainGSTBreakdown({
    super.key,
    required this.taxMap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.all(OrganismTheme.spacingSm),
      decoration: BoxDecoration(
        color: colors.stone800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: taxMap.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GST ${e.key.toInt()}%',
                  style: OrganismTheme.labelSmall(context).copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DomainAmount(
                  value: e.value,
                  showSymbol: false,
                  useSemanticColors: false,
                  style: OrganismTheme.numericSmall(context),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
