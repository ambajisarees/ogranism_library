import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/badge.dart';   // Direct import for CellBadgeVariant
import '../cells/spatial.dart'; // Direct import for CellGap/CellPad

/// [PlasmaToastManager] — Ephemeral notification system.
///
/// Manages singleton overlay entries for toast notifications. Supports 
/// semantic variants and automatic dismissal after a 3-second TTL.

/// Global Toast Management Service.
class PlasmaToastManager {
  static final PlasmaToastManager instance = PlasmaToastManager._internal();
  PlasmaToastManager._internal();

  OverlayEntry? _currentToast;

  void show(BuildContext context, String message, {CellBadgeVariant variant = CellBadgeVariant.primary}) {
    _currentToast?.remove();
    
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: 64,
        left: 0,
        right: 0,
        child: UnconstrainedBox(
          child: Material(
            color: Colors.transparent,
            child: _PlasmaToastWidget(
              message: message,
              variant: variant,
              onClose: () {
                _currentToast?.remove();
                _currentToast = null;
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentToast!);
    Future.delayed(const Duration(seconds: 3), () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }
}

class _PlasmaToastWidget extends StatelessWidget {
  final String message;
  final CellBadgeVariant variant;
  final VoidCallback onClose;

  const _PlasmaToastWidget({
    required this.message,
    required this.variant,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    Color border = colors.border;
    if (variant == CellBadgeVariant.error) border = colors.error;
    if (variant == CellBadgeVariant.success) border = colors.success;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: border),
        boxShadow: OrganismTheme.shadowLg,
      ),
      child: CellPad(
        horizontalMultiplier: 2.0,
        verticalMultiplier: 1.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Text(message, style: OrganismTheme.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
          const CellGap(1.5),
          GestureDetector(
            onTap: onClose,
            child: Icon(
              LucideIcons.x,
              size: OrganismTheme.iconSizeSm,
              color: OrganismTheme.iconMuted(context),
            ),
          ),
        ],
      ),
    ),
   );
  }
}
