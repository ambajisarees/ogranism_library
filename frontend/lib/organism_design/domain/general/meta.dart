import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainSyncStatus] — Visual indicator for Airbyte/EMPIRE sync health.
///
/// States: Synced (Success), Pending (Warning), Error (Error).
class DomainSyncStatus extends StatelessWidget {
  final bool isSynced;
  final bool hasError;
  final DateTime? lastSync;

  const DomainSyncStatus({
    super.key,
    required this.isSynced,
    this.hasError = false,
    this.lastSync,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    String label = isSynced ? 'SYNCED' : 'PENDING';
    CellStatusVariant dot = isSynced ? CellStatusVariant.active : CellStatusVariant.syncing;
    Color textColor = isSynced ? colors.success : colors.warning;

    if (hasError) {
      label = 'SYNC ERROR';
      dot = CellStatusVariant.error;
      textColor = colors.error;
    }

    return Tooltip(
      message: lastSync != null ? 'Last Sync: ${lastSync!.hour}:${lastSync!.minute}' : 'Sync in progress',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CellStatusDot(variant: dot, label: ''),
          const CellGap(0.25),
          Text(
            label,
            style: OrganismTheme.labelSmall(context).copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 8,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// [DomainAuditLabel] — Metadata signature for record auditing.
///
/// Layout: [Avatar] [Name] [Timestamp]
class DomainAuditLabel extends StatelessWidget {
  final String userName;
  final DateTime timestamp;

  const DomainAuditLabel({
    super.key,
    required this.userName,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Opacity(
      opacity: 0.7,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CellAvatar(name: userName, size: 16),
          const CellGap(0.25),
          Text(
            '${userName.toUpperCase()} • ${timestamp.hour}:${timestamp.minute}',
            style: OrganismTheme.labelSmall(context).copyWith(
              fontSize: 8,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// [DomainPrintButton] — Branded action for thermal/official printing.
class DomainPrintButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isThermal;

  const DomainPrintButton({
    super.key,
    this.onPressed,
    this.isThermal = true,
  });

  @override
  Widget build(BuildContext context) {
    return CellButton(
      text: isThermal ? 'PRINT SLIP' : 'PRINT A4',
      icon: LucideIcons.printer,
      variant: CellButtonVariant.outline,
      onPressed: onPressed,
    );
  }
}
