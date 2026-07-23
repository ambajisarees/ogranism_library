import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart';

/// [PlasmaContextMenu] — Desktop-first right-click menu system.
///
/// Wraps any widget and triggers a floating menu at exactly the mouse position 
/// upon receiving a secondary click (right-click).
class PlasmaContextMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> items;
  final double width;

  const PlasmaContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.width = 220,
  });

  @override
  State<PlasmaContextMenu> createState() => _PlasmaContextMenuState();
}

class _PlasmaContextMenuState extends State<PlasmaContextMenu> {
  OverlayEntry? _overlayEntry;

  void _showMenu(BuildContext context, Offset position) {
    _closeMenu(); // Safety first

    final capturedTheme = Theme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Theme(
        data: capturedTheme,
        child: Stack(
          children: [
            // Barrier
            GestureDetector(
              onTap: _closeMenu,
              onSecondaryTap: _closeMenu,
              onPanEnd: (_) => _closeMenu(),
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              left: position.dx,
              top: position.dy,
              child: _ContextMenuOverlay(
                items: widget.items,
                width: widget.width,
                onClose: _closeMenu,
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showMenu(context, details.globalPosition);
      },
      child: widget.child,
    );
  }
}

class _ContextMenuOverlay extends StatelessWidget {
  final List<Widget> items;
  final double width;
  final VoidCallback onClose;

  const _ContextMenuOverlay({
    required this.items,
    required this.width,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Material(
      color: Colors.transparent,
      child: CellPad.standard(
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: OrganismTheme.borderMd,
            border: Border.all(color: colors.border),
            boxShadow: OrganismTheme.shadowLg,
          ),
          child: ClipRRect(
            borderRadius: OrganismTheme.borderMd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                return GestureDetector(
                  onTap: () {
                    onClose();
                    // Item tap bubbles up or is handled by CellMenuItem
                  },
                  child: item,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
