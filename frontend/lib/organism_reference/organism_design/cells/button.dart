import 'package:flutter/material.dart';
import '../theme.dart';
import 'focus.dart';   // Direct import for OrganismFocus
import 'spatial.dart'; // Direct import for CellGap

/// [CellButton] — Primary action trigger atom.
///
/// Encapsulates hover, focus, loading, and disabled states. Renders across 
/// 5 semantic variants (primary, secondary, ghost, destructive, outline).

/// Defines the visual anatomy intent of a CellButton (mirrors shadcn variant concepts).
enum CellButtonVariant { primary, secondary, ghost, destructive, outline, input }
/// A highly polished, custom-built headless-style Button imitating Shadcn/Radix mechanics.
/// It encapsulates hover, focus, loading, and disabled state machinery using purely 
/// native Flutter composition, injected dynamically with the OrganismTheme.
class CellButton extends StatefulWidget {
  final String? text; // Made nullable for icon-only buttons
  final IconData? icon;
  final IconData? trailingIcon; // New: support for trailing icons
  final VoidCallback? onPressed;
  final CellButtonVariant variant;
  final bool isLoading;
  final bool isCompact; // New: 32px height standard

  const CellButton({
    super.key,
    this.text,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = CellButtonVariant.primary,
    this.isLoading = false,
    this.isCompact = false,
  });

  @override
  State<CellButton> createState() => _CellButtonState();
}

class _CellButtonState extends State<CellButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  void _handleHover(bool isHovered) {
    if (!_isDisabled && mounted) {
      setState(() => _isHovered = isHovered);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isDisabled && mounted) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isDisabled && mounted) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (!_isDisabled && mounted) {
      setState(() => _isPressed = false);
    }
  }

  // --- Theme Interpolation Logic ---

  Color _getBackgroundColor(OrganismColors colors) {
    if (_isDisabled) return colors.trackInactive;
    
    switch (widget.variant) {
      case CellButtonVariant.primary:
        if (_isPressed) return colors.primaryDark;
        return _isHovered ? colors.primaryLight : colors.primary;
      case CellButtonVariant.destructive:
        if (_isPressed) return colors.error.withValues(alpha: 0.8);
        return _isHovered ? colors.error.withValues(alpha: 0.9) : colors.error;
      case CellButtonVariant.secondary:
        if (_isPressed) return colors.surfaceActive;
        return _isHovered ? colors.surfaceActive : colors.surfaceSubtle;
      case CellButtonVariant.ghost:
        if (_isPressed) return colors.surfaceActive;
        return _isHovered ? colors.surfaceSubtle : Colors.transparent;
      case CellButtonVariant.outline:
        if (_isPressed) return colors.surfaceSubtle;
        return _isHovered ? colors.surfaceMuted : colors.surface;
      case CellButtonVariant.input:
        if (_isPressed) return colors.surfaceActive;
        return _isHovered ? colors.surfaceHover : colors.inputBackground;
    }
  }

  Color _getForegroundColor(OrganismColors colors) {
    if (_isDisabled) return colors.textMuted;

    switch (widget.variant) {
      case CellButtonVariant.primary:
      case CellButtonVariant.destructive:
        return Colors.white;
      case CellButtonVariant.secondary:
      case CellButtonVariant.outline:
      case CellButtonVariant.ghost:
      case CellButtonVariant.input:
        return colors.textPrimary;
    }
  }

  Border? _getBorder(OrganismColors colors, Color foregroundColor) {
    if (widget.variant == CellButtonVariant.outline || widget.variant == CellButtonVariant.input) {
      return Border.all(color: _isDisabled ? colors.borderSubtle : (_isHovered ? colors.inputBorderHover : colors.inputBorder));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final bgColor = _getBackgroundColor(colors);
    final fgColor = _getForegroundColor(colors);
    final border = _getBorder(colors, fgColor);

    final bool isIconOnly = widget.text == null || widget.text!.isEmpty;
    final double height = widget.isCompact ? OrganismTheme.buttonHeightCompact : OrganismTheme.buttonHeightStandard;
    
    // Exact sizing for square IconButtons
    final double? width = isIconOnly ? height : null;

    // 1. Accessibility semantics (from shadcn headless theory)
    return Semantics(
      button: true,
      enabled: !_isDisabled,
      // 2. Universal Focus & Keyboard interaction layer
      child: OrganismFocus(
        onTap: widget.onPressed,
        isDisabled: _isDisabled,
        borderRadius: OrganismTheme.borderSm,
        // 3. Mouse tracking for exact web/desktop hover states
        child: MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          cursor: _isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          // 4. Gesture tracking explicitly capturing press physics
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onPressed,
            behavior: HitTestBehavior.opaque,
            // 5. Smooth implicit animation wrapper for all interpolated aesthetic shifts
            child: AnimatedContainer(
              duration: OrganismTheme.durationFast,
              curve: OrganismTheme.curveStandard,
              height: height,
              width: width,
              padding: EdgeInsets.symmetric(
                horizontal: isIconOnly ? 0 : (widget.isCompact ? OrganismTheme.spacingMd : OrganismTheme.spacingLg),
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: OrganismTheme.borderSm,
                border: border,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: fgColor.withValues(alpha: 0.5),
                        ),
                      ),
                      if (!isIconOnly) CellGap.small,
                    ] else ...[
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 16, color: fgColor),
                        if (!isIconOnly) CellGap.small,
                      ],
                      if (!isIconOnly)
                        Text(
                          widget.text!,
                          style: OrganismTheme.labelLarge(context).copyWith(
                            color: fgColor,
                            height: 1.1, // Precision baseline alignment
                          ),
                        ),
                      if (widget.trailingIcon != null && !isIconOnly) ...[
                        CellGap.small,
                        Icon(widget.trailingIcon, size: 16, color: fgColor),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
