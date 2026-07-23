import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../cells.dart';

/// [DomainAmount] — Specialized financial data renderer.
///
/// Implements the Indian Numbering System (Lakhs/Crores) and handles 
/// semantic coloring for Debit/Credit (Dr/Cr) balances.
class DomainAmount extends StatelessWidget {
  final double value;
  final bool isCredit;
  final bool showSymbol;
  final bool useSemanticColors;
  final TextStyle? style;

  const DomainAmount({
    super.key,
    required this.value,
    this.isCredit = false,
    this.showSymbol = true,
    this.useSemanticColors = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    // Indian Currency Format
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: showSymbol ? '₹' : '',
      decimalDigits: 2,
    );

    final color = useSemanticColors 
      ? (isCredit ? colors.success : colors.error)
      : colors.textPrimary;

    return Text(
      format.format(value.abs()),
      style: (style ?? OrganismTheme.numericMedium(context)).copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// [DomainQuantity] — Inventory unit renderer.
///
/// Handles "Pcs" vs "Mts" vs "Kgs" formatting with precise decimal scaling.
class DomainQuantity extends StatelessWidget {
  final double value;
  final String unit; // 'PCS', 'MTS', 'KGS'
  final bool isCompact;

  const DomainQuantity({
    super.key,
    required this.value,
    required this.unit,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Standardize to 2 decimals for MTS/KGS, 0 for PCS
    final decimalDigits = (unit.toUpperCase() == 'PCS') ? 0 : 2;
    final format = NumberFormat.decimalPattern('en_IN');
    format.minimumFractionDigits = decimalDigits;
    format.maximumFractionDigits = decimalDigits;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          format.format(value),
          style: (isCompact ? OrganismTheme.numericSmall(context) : OrganismTheme.numericMedium(context)).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const CellGap(0.25),
        Text(
          unit.toUpperCase(),
          style: OrganismTheme.labelSmall(context).copyWith(
            color: OrganismTheme.colorsOf(context).textSecondary,
            fontSize: isCompact ? 8 : 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
