// plasma.dart
// The 3rd Dimension: Z-Axis Physics and Overlay Logic.
// Standardizes how elements float, anchor, and transition in the Biological ERP.

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'index.dart';

/// The Physics engine for Z-Axis transitions.
class PlasmaPhysics {
  static const Duration fast = OrganismTheme.durationFast;
  static const Duration standard = OrganismTheme.durationStandard;
  static const Duration slow = OrganismTheme.durationSlow;
  
  static const Curve curve = OrganismTheme.curveOut;

  static Widget fade({required Widget child, required Animation<double> animation}) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget slideUp({required Widget child, required Animation<double> animation}) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        )),
        child: child,
      ),
    );
  }

  static Widget scaleIn({required Widget child, required Animation<double> animation}) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        )),
        child: child,
      ),
    );
  }
}

/// A standard Modal Dialog mapping to the Shadcn anatomy.
/// Uses showGeneralDialog to bypass standard Material themes.
class PlasmaDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PlasmaDialog',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: PlasmaPhysics.fast,
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              constraints: const BoxConstraints(maxHeight: 800),
              margin: const EdgeInsets.all(OrganismTheme.spacing2Xl),
              decoration: BoxDecoration(
                color: OrganismTheme.surface,
                borderRadius: OrganismTheme.borderLg,
                border: Border.all(color: OrganismTheme.border),
                boxShadow: OrganismTheme.shadowLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(OrganismTheme.spacing2Xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: OrganismTheme.titleLarge),
                        if (description != null) ...[
                          const SizedBox(height: OrganismTheme.spacingSm),
                          Text(description, style: OrganismTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                  const CellDivider(),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(OrganismTheme.spacing2Xl),
                      child: content,
                    ),
                  ),
                  if (actions != null) ...[
                    const CellDivider(),
                    Padding(
                      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions.map((a) => Padding(
                          padding: const EdgeInsets.only(left: OrganismTheme.spacingMd),
                          child: a,
                        )).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return PlasmaPhysics.scaleIn(child: child, animation: anim1);
      },
    );
  }
}

/// A semantic Destructive/Warning modal.
class PlasmaAlertDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return PlasmaDialog.show<bool>(
      context: context,
      title: title,
      description: message,
      content: const SizedBox.shrink(),
      actions: [
        CellButton(
          text: cancelText,
          variant: CellButtonVariant.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        CellButton(
          text: confirmText,
          variant: isDestructive ? CellButtonVariant.destructive : CellButtonVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

/// The Core Anchor engine for Popovers.
/// Uses LayerLink to tether overlays to triggers.
class PlasmaPopover extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final ScrollController? scrollController;

  const PlasmaPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.scrollController,
  });

  @override
  State<PlasmaPopover> createState() => _PlasmaPopoverState();
}

class _PlasmaPopoverState extends State<PlasmaPopover> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
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

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to detect outside taps
          GestureDetector(
            onTap: _close,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Material(
                color: Colors.transparent,
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: OrganismTheme.surface,
                      borderRadius: OrganismTheme.borderMd,
                      border: Border.all(color: OrganismTheme.border),
                      boxShadow: OrganismTheme.shadowLg,
                    ),
                    child: widget.content,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: widget.trigger,
      ),
    );
  }
}

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
    Color border = OrganismTheme.border;
    if (variant == CellBadgeVariant.error) border = OrganismTheme.error;
    if (variant == CellBadgeVariant.success) border = OrganismTheme.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingXl, vertical: OrganismTheme.spacingLg),
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: border),
        boxShadow: OrganismTheme.shadowLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: OrganismTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: OrganismTheme.spacingLg),
          GestureDetector(
            onTap: onClose,
            child: Icon(
              LucideIcons.x,
              size: OrganismTheme.iconSizeSm,
              color: OrganismTheme.iconMuted,
            ),
          ),
        ],
      ),
    );
  }
}
