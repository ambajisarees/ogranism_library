import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';

enum DomainPartyType { debtor, creditor, supplier, haste, transport }

class DomainPartyTypeBadge extends StatelessWidget {
  final DomainPartyType type;

  const DomainPartyTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    String label;
    CellBadgeVariant variant;

    switch (type) {
      case DomainPartyType.debtor:
        label = 'Customer / Debtor';
        variant = CellBadgeVariant.warning; // Amber
        break;
      case DomainPartyType.creditor:
        label = 'Supplier / Creditor';
        variant = CellBadgeVariant.primary; // Fuchsia/Sunset
        break;
      case DomainPartyType.supplier:
        label = 'Material Supplier';
        variant = CellBadgeVariant.success; // Emerald
        break;
      case DomainPartyType.haste:
        label = 'Intermediary / Haste';
        variant = CellBadgeVariant.secondary; // Muted
        break;
      case DomainPartyType.transport:
        label = 'Transport Partner';
        variant = CellBadgeVariant.outline;
        break;
    }

    return CellBadge(
      text: label,
      variant: variant,
    );
  }
}

class DomainGstBadge extends StatelessWidget {
  final String gstin;

  const DomainGstBadge({super.key, required this.gstin});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    // Extract State Code (First 2 digits)
    final stateCode = gstin.length >= 2 ? gstin.substring(0, 2) : '??';

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: OrganismTheme.borderSm,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(OrganismTheme.radiusSm),
                bottomLeft: Radius.circular(OrganismTheme.radiusSm),
              ),
            ),
            child: Text(
              stateCode,
              style: OrganismTheme.labelSmall(context).copyWith(
                fontWeight: FontWeight.w900,
                color: colors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              gstin,
              style: OrganismTheme.monoBody(context).copyWith(
                fontSize: 12,
                letterSpacing: 0.5,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
