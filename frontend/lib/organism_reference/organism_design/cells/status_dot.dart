import 'package:flutter/material.dart';
import '../theme.dart';
import 'spatial.dart'; // Direct import for CellGap

/// [CellStatusDot] — Pulsing live connection/sync state indicator atom.
///
/// Renders an 8px semantic dot with optional animated pulse glow,
/// paired with a label. Used for live connection statuses.

/// Semantic state variants for [CellStatusDot].
enum CellStatusVariant { active, idle, error, warning, syncing }

/// CellStatusDot — Pulsing live connection/sync state indicator.
///
/// Renders an 8px semantic dot with optional animated pulse glow,
/// paired with a label. Used in the NavBoat header, sync status bars,
/// and any "live" data connection indicator in the ERP.
///
/// ```dart
/// CellStatusDot(label: 'Supabase Live', variant: CellStatusVariant.active)
/// CellStatusDot(label: 'Syncing...', variant: CellStatusVariant.syncing)
/// CellStatusDot(label: 'Offline', variant: CellStatusVariant.error)
/// ```
class CellStatusDot extends StatefulWidget {
  /// Label displayed to the right of the dot.
  final String label;

  /// Semantic variant controlling color and pulse behavior.
  final CellStatusVariant variant;

  /// Optional explicit color override (bypasses variant).
  final Color? color;

  /// Whether to animate a pulse glow. Defaults to true for `active` and `syncing`.
  final bool? pulse;

  const CellStatusDot({
    super.key,
    required this.label,
    this.variant = CellStatusVariant.active,
    this.color,
    this.pulse,
  });

  @override
  State<CellStatusDot> createState() => _CellStatusDotState();
}

class _CellStatusDotState extends State<CellStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _shouldPulse =>
      widget.pulse ??
      (widget.variant == CellStatusVariant.active ||
          widget.variant == CellStatusVariant.syncing);

  Color _resolveColor(OrganismColors colors) {
    if (widget.color != null) return widget.color!;
    return switch (widget.variant) {
      CellStatusVariant.active  => colors.success,
      CellStatusVariant.idle    => colors.textMuted,
      CellStatusVariant.error   => colors.error,
      CellStatusVariant.warning => colors.warning,
      CellStatusVariant.syncing => colors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final dotColor = _resolveColor(colors);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: _shouldPulse
                    ? [
                        BoxShadow(
                          color: dotColor.withValues(alpha: _pulseAnimation.value * 0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        CellGap.small,
        Text(
          widget.label,
          style: OrganismTheme.bodySmall(context).copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
