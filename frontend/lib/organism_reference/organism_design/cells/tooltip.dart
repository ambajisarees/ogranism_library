import 'package:flutter/material.dart';
import '../theme.dart';
import 'spatial.dart'; // Direct import for CellPad

/// [CellTooltip] — High-density context hover layer atom.
///
/// Implements floating Z-axis tooltips with standard [Shadcn] hover behavior.
/// Uses [Overlay] and [CompositedTransformFollower] for exact positioning.

/// Floating Z-Axis tooltip replicating standard Shadcn UI hover interactions natively.
class CellTooltip extends StatefulWidget {
  final String message;
  final Widget child;

  const CellTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  State<CellTooltip> createState() => _CellTooltipState();
}

class _CellTooltipState extends State<CellTooltip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  void _showTooltip() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final colors = OrganismTheme.colorsOf(context);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 250, // Max bounded width for safe word wrapping
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(size.width / 2, size.height + 6), // Anchor bottom-center
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0),
            child: Material(
              color: Colors.transparent,
              child: IntrinsicWidth(
                child: CellPad(
                  horizontalMultiplier: 1.0,
                  verticalMultiplier: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.tooltipBackground,
                      borderRadius: OrganismTheme.borderSm,
                      boxShadow: OrganismTheme.shadowMd,
                    ),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: OrganismTheme.bodySmall(context).copyWith(color: colors.tooltipText),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          Future.delayed(const Duration(milliseconds: 250), () {
            if (_isHovered && mounted) _showTooltip();
          });
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hideTooltip();
        },
        child: widget.child,
      ),
    );
  }
}
