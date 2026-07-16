import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'popover.dart';

/// [PlasmaHoverCard] — Non-destructive data peeking overlay.
///
/// Triggers a popover after a configurable [openDelay] when the user hovers 
/// over the [trigger] widget. Prevents UI fatigue by ignoring rapid mouse movements.
class PlasmaHoverCard extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final Duration openDelay;
  final Duration closeDelay;
  final double? width;

  const PlasmaHoverCard({
    super.key,
    required this.trigger,
    required this.content,
    this.openDelay = const Duration(milliseconds: 500),
    this.closeDelay = const Duration(milliseconds: 200),
    this.width,
  });

  @override
  State<PlasmaHoverCard> createState() => _PlasmaHoverCardState();
}

class _PlasmaHoverCardState extends State<PlasmaHoverCard> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _openTimer;
  Timer? _closeTimer;
  bool _isVisible = false;

  void _onEnter(_) {
    _closeTimer?.cancel();
    if (_isVisible) return;

    _openTimer = Timer(widget.openDelay, () {
      _show();
    });
  }

  void _onExit(_) {
    _openTimer?.cancel();
    if (!_isVisible) return;

    _closeTimer = Timer(widget.closeDelay, () {
      _hide();
    });
  }

  void _show() {
    if (!mounted || _isVisible) return;

    final capturedTheme = Theme.of(context);
    final colors = OrganismTheme.colorsOf(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Theme(
        data: capturedTheme,
        child: Stack(
          children: [
            Positioned(
              width: widget.width ?? 320,
              child: CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 8),
                child: MouseRegion(
                  onEnter: (_) => _closeTimer?.cancel(),
                  onExit: _onExit,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: OrganismTheme.borderMd,
                        border: Border.all(color: colors.border),
                        boxShadow: OrganismTheme.shadowLg,
                      ),
                      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                      child: widget.content,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isVisible = true);
  }

  void _hide() {
    if (!_isVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: widget.trigger,
      ),
    );
  }
}
