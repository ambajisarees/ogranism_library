/// LLM NOTE: MicroButton
/// - Level: Micro-Control UI Token / Action Card (34px Height)
/// - Role: Universal compact button control used across PageHeader, DynamicActionBar (DAB), filter triggers, submodule selectors, and popover checklist items.
/// - Widget Composition: MouseRegion -> shad.Button.outline -> Focus (nullifier: canRequestFocus: false) -> Row(Icon + Text + Badge + Icon).
/// - Specifications:
///   - Base surface: `colors.card` (normal) | `colors.accent` (hover/selected ghost) | transparent (ghost)
///   - Border outline: 1.0px `colors.border` (normal) | 1.0px `colors.primary.withAlpha(153)` (focused)
///   - Border radius: 6px (`theme.radiusMd`)
///   - Padding: EdgeInsets.symmetric(horizontal: 12 * theme.scaling, vertical: 8 * theme.scaling) [Icon-Only: 8px horizontal]
///   - Typography: `theme.typography.textSmall` (label - semibold w600 when selected) & `theme.typography.xSmall` (badge - semibold w600 for all states)
///   - Focus Machine: Focus outlines paint exclusively on outer card border via Focus nullifier wrapper.

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// MicroButton: Universal reusable button control across PageHeader and DAB.
/// Rebuilt from scratch with strict token architecture:
/// - Base surface: `colors.card`
/// - Base border: 1px `colors.border`
/// - Corner radius: `theme.radiusMd` (6px)
/// - Hover state: Only modifies background fill to `colors.accent`
/// - Focus state: 1.0px `colors.primary.withAlpha(153)` outer border
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
            width: _isFocused ? 1.0 : 0.0,
          )
        : Border.all(
            color: _isFocused ? colors.primary.withAlpha(153) : colors.border,
            width: 1.0,
          );

    final backgroundColor = widget.isGhost
        ? ((_isHovered || widget.isSelected) ? colors.accent : const Color(0x00000000))
        : (_isHovered ? colors.accent : colors.card);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: shad.Button.outline(
        focusNode: _effectiveFocusNode,
        style: const shad.ButtonStyle.outline()
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
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: colors.foreground,
                    ),
                  ),
                ),
              ],

              // 3. Native Badge / Chip (PrimaryBadge with semibold when selected, SecondaryBadge with semibold muted when unselected)
              if (widget.badgeCount != null) ...[
                if (widget.label.isNotEmpty || widget.leadingIcon != null)
                  const shad.DensityGap(shad.gapSm),
                widget.isSelected
                    ? shad.PrimaryBadge(
                        child: Text(
                          widget.badgeCount.toString(),
                          style: theme.typography.xSmall.copyWith(
                            fontSize: 10 * theme.scaling,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : shad.SecondaryBadge(
                        child: Text(
                          widget.badgeCount.toString(),
                          style: theme.typography.xSmall.copyWith(
                            fontSize: 10 * theme.scaling,
                            fontWeight: FontWeight.w600,
                            color: colors.mutedForeground,
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
