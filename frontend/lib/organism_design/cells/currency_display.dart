import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

/// Visual indication of net status (Negative values print red).
enum CellCurrencyVariant { auto, positive, negative, subdued }

/// [CellCurrencyDisplay] — Hardened formatting atom displaying read-only Indian Rupees.
///
/// Converts doubles like `2450.5` into `₹ 2,450.50` utilizing strictly tabular numeric 
/// typography rendering. Ideal for aligning columns identically without jumping digits.
class CellCurrencyDisplay extends StatelessWidget {
  final double amount;
  final CellCurrencyVariant variant;
  final bool showSymbol;
  
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '₹ ', // Appends a clean trailing space for read flow
    decimalDigits: 2,
  );

  const CellCurrencyDisplay({
    super.key,
    required this.amount,
    this.variant = CellCurrencyVariant.auto,
    this.showSymbol = true,
  });

  Color _determineColor(OrganismColors colors) {
    if (variant == CellCurrencyVariant.subdued) {
      return colors.textMuted;
    }
    if (variant == CellCurrencyVariant.positive || (variant == CellCurrencyVariant.auto && amount > 0)) {
      return colors.textPrimary;
    }
    if (variant == CellCurrencyVariant.negative || (variant == CellCurrencyVariant.auto && amount < 0)) {
      return colors.error;
    }
    return colors.textSecondary; // Exactly 0
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final textStyle = OrganismTheme.codeTabular(context).copyWith(
      color: _determineColor(colors),
      fontWeight: FontWeight.w600,
    );

    // Swap symbol stripping if explicitly demanded.
    final formatted = showSymbol ? _formatter.format(amount) : _formatter.format(amount).replaceAll('₹ ', '');

    return Text(
      formatted,
      style: textStyle,
      textAlign: TextAlign.right, // Currency is right-aligned 99% of the time natively
    );
  }
}
