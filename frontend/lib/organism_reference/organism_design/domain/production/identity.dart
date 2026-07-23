import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainWorkerID] — Semantic identity badge for production staff.
///
/// Renders as a small, mono-font capsule with a user icon.
class DomainWorkerID extends StatelessWidget {
  final String name;
  final bool isCompact;

  const DomainWorkerID({
    super.key,
    required this.name,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 4 : 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.stone800,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.user,
            size: 10,
            color: colors.textSecondary,
          ),
          const CellGap(0.25),
          Text(
            name.toUpperCase(),
            style: OrganismTheme.monoLabel(context).copyWith(
              fontSize: 9,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// [DomainMachineID] — Visual identity for factory floor assets.
///
/// Use for Mapping slips to specific machinery.
class DomainMachineID extends StatelessWidget {
  final String machineNo;

  const DomainMachineID({
    super.key,
    required this.machineNo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.cpu,
            size: 10,
            color: colors.primary,
          ),
          const CellGap(0.25),
          Text(
            'MC-$machineNo',
            style: OrganismTheme.monoLabel(context).copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
