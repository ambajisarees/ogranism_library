import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../../tissues.dart';
import '../types.dart';
import '../amounts.dart';
import 'stage_badge.dart';

/// [DomainChallanCard] — Summary molecule for Production Slips/Challans.
///
/// Combines Slip No, Production Stage, Date, and Quantities (PCS/MTS).
class DomainChallanCard extends StatelessWidget {
  final String slipNo;
  final DomainProductionStage stage;
  final DateTime date;
  final double pcs;
  final double? mts;
  final String partyName;
  final bool isSelected;
  final VoidCallback? onTap;

  const DomainChallanCard({
    super.key,
    required this.slipNo,
    required this.stage,
    required this.date,
    required this.pcs,
    this.mts,
    required this.partyName,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return TissueListCard(
      isSelected: isSelected,
      onTap: onTap,
      leading: DomainStageBadge(stage: stage, isCompact: true),
      title: Text('SLIP — #$slipNo'),
      subtitle: Text(partyName.toUpperCase()),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DomainQuantity(value: pcs, unit: 'PCS', isCompact: true),
          if (mts != null) ...[
            const CellGap(0.125),
            DomainQuantity(value: mts!, unit: 'MTS', isCompact: true),
          ],
        ],
      ),
    );
  }
}
