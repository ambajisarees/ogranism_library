import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellPad

/// [PlasmaPopover] — Anchored floating layer system.
///
/// Uses [LayerLink] to tether an overlay surface to a specific trigger widget.
/// Implements automatic barrier dismissal and theme-aligned shadows.
class PlasmaPopover extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final ScrollController? scrollController;
  final bool isDisabled;
  final double? explicitWidth;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;

  const PlasmaPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.scrollController,
    this.isDisabled = false,
    this.explicitWidth,
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
    this.offset = const Offset(0, 8),
  });

  @override
  State<PlasmaPopover> createState() => PlasmaPopoverState();
}

class PlasmaPopoverState extends State<PlasmaPopover> {
  void close() {
    _close();
  }

  void toggle() {
    _toggle();
  }

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (widget.isDisabled) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final capturedTheme = Theme.of(context);

    return OverlayEntry(
      builder: (context) {
        final colors = capturedTheme.extension<OrganismColors>() ?? OrganismColors.light();
        return Theme(
          data: capturedTheme,
          child: Stack(
            children: [
          // Invisible barrier to detect outside taps
          GestureDetector(
            onTap: _close,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: widget.explicitWidth ?? (size.width > 0 ? size.width : null),
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: widget.targetAnchor,
              followerAnchor: widget.followerAnchor,
              offset: widget.offset,
              child: Material(
                color: colors.surface,
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: OrganismTheme.borderMd,
                  side: BorderSide(color: colors.border),
                ),
                child: IntrinsicWidth(
                  child: CellPad.standard(
                    child: SizedBox(
                      width: widget.explicitWidth,
                      child: widget.content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: widget.trigger,
      ),
    );
  }
}
