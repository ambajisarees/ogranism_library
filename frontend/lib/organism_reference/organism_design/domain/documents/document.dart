import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../financial/tokens.dart';

/// [DomainDocumentHeader] — Identity block for Vouchers/Challans/Invoices.
///
/// Layout: [Prefix-VoucherID] | [Date] | [PartyName]
class DomainDocumentHeader extends StatelessWidget {
  final String id;
  final String? prefix;
  final DateTime date;
  final String partyName;

  const DomainDocumentHeader({
    super.key,
    required this.id,
    this.prefix,
    required this.date,
    required this.partyName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      decoration: BoxDecoration(
        color: colors.stone800.withValues(alpha: 0.5),
        borderRadius: OrganismTheme.borderSm,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DomainVoucherID(id: id, prefix: prefix),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: OrganismTheme.numericSmall(context).copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const CellGap(1.0),
          Text(
            partyName.toUpperCase(),
            style: OrganismTheme.titleLarge(context).copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// [DomainDocumentRow] — Line item molecule for ERP documents.
///
/// Flexible layout for showing SrNo, Description, and Quantities.
class DomainDocumentRow extends StatelessWidget {
  final int srNo;
  final String description;
  final Widget trailing;

  const DomainDocumentRow({
    super.key,
    required this.srNo,
    required this.description,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: OrganismTheme.spacingSm, 
        horizontal: OrganismTheme.spacingXs
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              srNo.toString().padLeft(2, '0'),
              style: OrganismTheme.monoLabel(context).copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
          const CellGap(0.5),
          Expanded(
            child: Text(
              description.toUpperCase(),
              style: OrganismTheme.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const CellGap(1.0),
          trailing,
        ],
      ),
    );
  }
}
