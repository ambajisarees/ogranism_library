import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainVoucherID] — Specific typography for Voucher Numbers.
///
/// Uses monospaced font for sequence alignment in grids.
class DomainVoucherID extends StatelessWidget {
  final String id;
  final String? prefix;

  const DomainVoucherID({
    super.key,
    required this.id,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.stone900,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        '${prefix ?? "VO"}-$id',
        style: OrganismTheme.monoLabel(context).copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

/// [DomainPaymentMode] — Icon + Label for financial instruments.
///
/// Maps CASH, BANK, JOURNAL, etc., to icons.
class DomainPaymentMode extends StatelessWidget {
  final String mode;

  const DomainPaymentMode({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    IconData icon;
    
    switch (mode.toUpperCase()) {
      case 'CASH':
        icon = LucideIcons.banknote;
        break;
      case 'BANK':
        icon = LucideIcons.landmark;
        break;
      case 'JOURNAL':
        icon = LucideIcons.bookOpen;
        break;
      default:
        icon = LucideIcons.creditCard;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textSecondary),
        const CellGap(0.25),
        Text(
          mode.toUpperCase(),
          style: OrganismTheme.labelSmall(context).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

/// [DomainRateTag] — Standardized per-unit rate display.
///
/// Example: ₹45.00 / MTS
class DomainRateTag extends StatelessWidget {
  final double rate;
  final String unit;

  const DomainRateTag({
    super.key,
    required this.rate,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '₹${rate.toStringAsFixed(2)}',
          style: OrganismTheme.numericSmall(context).copyWith(
            fontWeight: FontWeight.w800,
            color: colors.primary,
          ),
        ),
        Text(
          ' / ${unit.toUpperCase()}',
          style: OrganismTheme.labelSmall(context).copyWith(
            fontSize: 8,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}
