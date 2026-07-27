import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// MicroButton: Universal reusable button control across PageHeader and DAB.
/// Uses native `shad.FocusOutline` around the outer card container with a subtle
/// `colors.primary.withOpacity(0.4)` focus outline, `colors.border` card stroke,
/// fixed `theme.radiusMd` (6px) corner radius, and dynamic badge tokens.
class MicroButton extends StatefulWidget {
  final String label;
  final IconData? leadingIcon;
  final dynamic badgeCount;
  final IconData? trailingIcon;
  final bool isSelected;
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

    final border = Border.all(
      color: _isFocused
          ? colors.primary.withAlpha(153)
          : colors.border,
      width: _isFocused ? 1.5 : 1.0,
    );

    return shad.Button.card(
      focusNode: _effectiveFocusNode,
      style: const shad.ButtonStyle.card()
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
              Text(
                widget.label,
                style: theme.typography.textSmall.copyWith(
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  color: colors.foreground,
                ),
              ),
            ],

            // 3. Native Badge / Chip (PrimaryBadge when selected, SecondaryBadge when normal)
            if (widget.badgeCount != null) ...[
              if (widget.label.isNotEmpty || widget.leadingIcon != null)
                const shad.DensityGap(shad.gapSm),
              Focus(
                canRequestFocus: false,
                skipTraversal: true,
                descendantsAreFocusable: false,
                child: widget.isSelected
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
      );
  }
}
