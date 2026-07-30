/// LLM NOTE: MicroButton
/// - Level: Micro Control
/// - Purpose: Universal high-density (34px height) button control used across PageHeader, DAB toolbars, and popover lists.
/// - Widget Composition: shad.Button.card / shad.Button.ghost -> Focus (nullifier) -> Row(Icon + Text + Badge + Icon).
/// - Tokens: Base colors.card, border colors.border, hover colors.accent, selected colors.primary.

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// MicroButton: Universal reusable button control across PageHeader and DAB.
/// Rebuilt from scratch with strict token architecture:
/// - Base surface: `colors.card`
/// - Base border: 1px `colors.border`
/// - Corner radius: `theme.radiusMd` (6px)
/// - Hover state: Only modifies background fill to `colors.accent`
/// - Focus state: 1.5px `colors.primary.withAlpha(153)` outer border
/// - Selected state: Passes `colors.primary` to leading icon & `FontWeight.bold` to label
/// - Focus Nullifier: Wraps all inner children in `Focus(canRequestFocus: false, skipTraversal: true, descendantsAreFocusable: false)`
class MicroButton extends StatefulWidget {
  final String label;
  final IconData? leadingIcon;
  final dynamic badgeCount;
  final IconData? trailingIcon;
  final bool isSelected;
  final bool isGhost;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  final bool autoFocus;

  const MicroButton({
    super.key,
    this.label = '',
    this.leadingIcon,
    this.badgeCount,
    this.trailingIcon,
    this.isSelected = false,
    this.isGhost = false,
    this.onPressed,
    this.focusNode,
    this.autoFocus = false,
  });

  @override
  State<MicroButton> createState() => _MicroButtonState();
}

class _MicroButtonState extends State<MicroButton> {
  late FocusNode _effectiveFocusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(MicroButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _effectiveFocusNode.removeListener(_handleFocusChange);
      _effectiveFocusNode = widget.focusNode ?? FocusNode();
      _effectiveFocusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    } else {
      _effectiveFocusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // Detect if this is an Icon-Only button (e.g., 3-dots overflow button)
    final bool isIconOnly = widget.label.isEmpty &&
        widget.leadingIcon != null &&
        widget.trailingIcon == null &&
        widget.badgeCount == null;

    final border = widget.isGhost
        ? Border.all(
            color: _isFocused ? colors.primary.withAlpha(153) : const Color(0x00000000),
            width: _isFocused ? 1.5 : 0.0,
          )
        : Border.all(
            color: _isFocused ? colors.primary.withAlpha(153) : colors.border,
            width: _isFocused ? 1.5 : 1.0,
          );

    final backgroundColor = widget.isGhost
        ? ((_isHovered || widget.isSelected) ? colors.accent : const Color(0x00000000))
        : (_isHovered ? colors.accent : colors.card);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: shad.Button.card(
        focusNode: _effectiveFocusNode,
        style: const shad.ButtonStyle.card()
            .withBackgroundColor(
              color: backgroundColor,
            )
            .withPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isIconOnly ? 8 * theme.scaling : 12 * theme.scaling,
                vertical: 8 * theme.scaling,
              ),
            )
            .withBorderRadius(
              borderRadius: BorderRadius.circular(theme.radiusMd),
            )
            .withBorder(
              border: border,
            ),
        onPressed: widget.onPressed,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          descendantsAreFocusable: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Optional Leading Icon
              if (widget.leadingIcon != null) ...[
                Icon(
                  widget.leadingIcon,
                  size: 16 * theme.scaling,
                  color: widget.isSelected ? colors.primary : colors.mutedForeground,
                ),
                if (widget.label.isNotEmpty) const shad.DensityGap(shad.gapSm),
              ],

              // 2. Text Label
              if (widget.label.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                      color: colors.foreground,
                    ),
                  ),
                ),
              ],

              // 3. Native Badge / Chip (PrimaryBadge when selected, SecondaryBadge when normal)
              if (widget.badgeCount != null) ...[
                if (widget.label.isNotEmpty || widget.leadingIcon != null)
                  const shad.DensityGap(shad.gapSm),
                widget.isSelected
                    ? shad.PrimaryBadge(
                        child: Text(
                          widget.badgeCount.toString(),
                          style: theme.typography.xSmall.copyWith(
                            fontSize: 10 * theme.scaling,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : shad.SecondaryBadge(
                        child: Text(
                          widget.badgeCount.toString(),
                          style: theme.typography.xSmall.copyWith(
                            fontSize: 10 * theme.scaling,
                          ),
                        ),
                      ),
              ],

              // 4. Optional Trailing Action Indicator Icon
              if (widget.trailingIcon != null) ...[
                if (widget.label.isNotEmpty || widget.leadingIcon != null || widget.badgeCount != null)
                  const shad.DensityGap(shad.gapSm),
                Icon(
                  widget.trailingIcon,
                  size: 16 * theme.scaling,
                  color: colors.mutedForeground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
