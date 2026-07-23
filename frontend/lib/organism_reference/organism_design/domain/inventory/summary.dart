import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../../tissues.dart';
import '../amounts.dart';
import 'identity.dart';

/// [DomainInventorySummary] — Combined Pcs/Mts view.
///
/// Standardized layout for showing total stock/requirements.
class DomainInventorySummary extends StatelessWidget {
  final double pcs;
  final double mts;

  const DomainInventorySummary({
    super.key,
    required this.pcs,
    required this.mts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DomainQuantity(value: pcs, unit: 'PCS', isCompact: true),
        const CellGap(0.125),
        DomainQuantity(value: mts, unit: 'MTS', isCompact: true),
      ],
    );
  }
}

/// [DomainItemMasterCard] — Branded card for Sarees and Qualities.
///
/// Layout: [Quality Badge] [Design ID] [Shade Badge] [Stock Indicator]
class DomainItemMasterCard extends StatelessWidget {
  final String quality;
  final String designNo;
  final String shadeNo;
  final double stock;
  final double maxStock;
  final VoidCallback? onTap;

  const DomainItemMasterCard({
    super.key,
    required this.quality,
    required this.designNo,
    required this.shadeNo,
    required this.stock,
    required this.maxStock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TissueCard(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DomainQualityBadge(quality: quality),
              DomainDesignID(designNo: designNo),
            ],
          ),
          const CellGap(1.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DomainShadeBadge(shadeNo: shadeNo),
              Text(
                '${stock.toInt()} PCS',
                style: OrganismTheme.numericSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const CellGap(0.5),
          const CellDivider(),
          const CellGap(0.5),
          CellProgressBar(
            value: (stock / maxStock).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }
}
