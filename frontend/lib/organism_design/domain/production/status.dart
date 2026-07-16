import 'package:flutter/material.dart';
import '../../cells.dart';
import '../../theme.dart';

/// [DomainSlipStatus] — Compact visual for completion state.
///
/// Combines a pulsing StatusDot with a label (e.g. "PENDING", "COMPLETED").
class DomainSlipStatus extends StatelessWidget {
  final bool isCompleted;
  final bool isCancelled;

  const DomainSlipStatus({
    super.key,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    String label = 'PENDING';
    CellStatusVariant dot = CellStatusVariant.active;

    if (isCancelled) {
      label = 'CANCELLED';
      dot = CellStatusVariant.idle;
    } else if (isCompleted) {
      label = 'COMPLETED';
      dot = CellStatusVariant.idle; // Non-pulsing for terminal state
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CellStatusDot(variant: dot, label: ''),
        const CellGap(0.25),
        Text(
          label.toUpperCase(),
          style: OrganismTheme.labelSmall(context).copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isCancelled 
                ? OrganismTheme.colorsOf(context).error 
                : (isCompleted ? OrganismTheme.colorsOf(context).success : OrganismTheme.colorsOf(context).primary),
          ),
        ),
      ],
    );
  }
}

/// [DomainMendingBadge] — Critical alert for damaged saree goods.
///
/// Specific badge for "Mending" (repair) status.
class DomainMendingBadge extends StatelessWidget {
  final bool hasMending;

  const DomainMendingBadge({
    super.key,
    required this.hasMending,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMending) return const SizedBox.shrink();

    return CellBadge(
      text: 'MENDING REQ',
      variant: CellBadgeVariant.error,
    );
  }
}
