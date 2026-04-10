// cells.dart
// Smallest controls (buttons, inputs, markers)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';

/// Defines the visual anatomy intent of a CellButton (mirrors shadcn variant concepts).
enum CellButtonVariant { primary, secondary, ghost, destructive, outline }

/// A highly polished, custom-built headless-style Button imitating Shadcn/Radix mechanics.
/// It encapsulates hover, focus, loading, and disabled state machinery using purely 
/// native Flutter composition, injected dynamically with the OrganismTheme.
class CellButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final CellButtonVariant variant;
  final bool isLoading;

  const CellButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.variant = CellButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  State<CellButton> createState() => _CellButtonState();
}

class _CellButtonState extends State<CellButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  void _handleHover(bool isHovered) {
    if (!_isDisabled) {
      setState(() => _isHovered = isHovered);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isDisabled) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isDisabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (!_isDisabled) {
      setState(() => _isPressed = false);
    }
  }

  // --- Theme Interpolation Logic ---

  Color get _backgroundColor {
    if (_isDisabled) return OrganismTheme.stone200;
    
    switch (widget.variant) {
      case CellButtonVariant.primary:
        if (_isPressed) return OrganismTheme.primaryDark;
        return _isHovered ? OrganismTheme.primaryLight : OrganismTheme.primary;
      case CellButtonVariant.destructive:
        if (_isPressed) return OrganismTheme.error.withOpacity(0.8);
        return _isHovered ? OrganismTheme.error.withOpacity(0.9) : OrganismTheme.error;
      case CellButtonVariant.secondary:
        if (_isPressed) return OrganismTheme.stone300;
        return _isHovered ? OrganismTheme.stone200 : OrganismTheme.stone100;
      case CellButtonVariant.ghost:
        if (_isPressed) return OrganismTheme.stone200;
        return _isHovered ? OrganismTheme.stone100 : Colors.transparent;
      case CellButtonVariant.outline:
        if (_isPressed) return OrganismTheme.stone100;
        return _isHovered ? OrganismTheme.stone50 : OrganismTheme.surface;
    }
  }

  Color get _foregroundColor {
    if (_isDisabled) return OrganismTheme.stone400;

    switch (widget.variant) {
      case CellButtonVariant.primary:
      case CellButtonVariant.destructive:
        return Colors.white;
      case CellButtonVariant.secondary:
      case CellButtonVariant.outline:
      case CellButtonVariant.ghost:
        return OrganismTheme.stone900;
    }
  }

  Border? get _border {
    if (widget.variant == CellButtonVariant.outline) {
      return Border.all(color: _isDisabled ? OrganismTheme.stone200 : OrganismTheme.border);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Accessibility semantics (from shadcn headless theory)
    return Semantics(
      button: true,
      enabled: !_isDisabled,
      // 2. Mouse tracking for exact web/desktop hover states
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        cursor: _isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        // 3. Gesture tracking explicitly capturing press physics
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          // 4. Smooth implicit animation wrapper for all interpolated aesthetic shifts
          child: AnimatedContainer(
            duration: OrganismTheme.durationFast,
            curve: OrganismTheme.curveStandard,
            height: OrganismTheme.buttonHeightStandard,
            padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingLg),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: OrganismTheme.borderMd,
              border: _border,
              boxShadow: (widget.variant == CellButtonVariant.primary && !_isDisabled && !_isPressed)
                  ? OrganismTheme.shadowSm
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
                    ),
                  ),
                  const SizedBox(width: OrganismTheme.spacingSm),
                ] else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: OrganismTheme.iconSizeMd,
                    color: _foregroundColor,
                  ),
                  const SizedBox(width: OrganismTheme.spacingSm),
                ],
                Text(
                  widget.text,
                  style: OrganismTheme.labelLarge.copyWith(color: _foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A Headless-inspired raw Text Input primitive.
/// Strips out all heavy Material default decorations in favor of an AnimatedContainer
/// that tracks exact focus and hover states mapped to Stone palettes.
class CellInput extends StatefulWidget {
  final String? placeholder;
  final String? initialValue;
  final bool isNumeric;
  final bool isSearch;
  final bool hasError;
  final bool isDisabled;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CellInput({
    super.key,
    this.placeholder,
    this.initialValue,
    this.isNumeric = false,
    this.isSearch = false,
    this.hasError = false,
    this.isDisabled = false,
    this.onChanged,
    this.controller,
  });

  @override
  State<CellInput> createState() => _CellInputState();
}

class _CellInputState extends State<CellInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shadcn Architectural Matrix Evaluator
    Color borderColor = OrganismTheme.border;
    if (widget.hasError) {
      borderColor = OrganismTheme.error;
    } else if (_isFocused) {
      borderColor = OrganismTheme.focusRing;
    } else if (_isHovered && !widget.isDisabled) {
      borderColor = OrganismTheme.stone400; // Hover slight border darken
    }

    List<BoxShadow>? boxShadow;
    if (_isFocused && !widget.hasError) {
      boxShadow = OrganismTheme.shadowRing;
    }

    return Semantics(
      enabled: !widget.isDisabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
        child: AnimatedContainer(
          duration: OrganismTheme.durationFast,
          curve: OrganismTheme.curveStandard,
          height: OrganismTheme.buttonHeightStandard,
          padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
          decoration: BoxDecoration(
            color: widget.isDisabled ? OrganismTheme.stone100 : OrganismTheme.surface,
            borderRadius: OrganismTheme.borderSm, // Sharp 4.0 radius flat edge
            border: Border.all(color: borderColor),
            boxShadow: boxShadow,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (widget.isSearch) ...[
                Icon(
                  LucideIcons.search,
                  size: OrganismTheme.iconSizeSm,
                  color: OrganismTheme.iconMuted,
                ),
                const SizedBox(width: OrganismTheme.spacingSm),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: !widget.isDisabled,
                  onChanged: widget.onChanged,
                  style: widget.isNumeric ? OrganismTheme.code : OrganismTheme.bodyLarge,
                  cursorColor: OrganismTheme.primary,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.placeholder,
                    hintStyle: OrganismTheme.bodyLarge.copyWith(color: OrganismTheme.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              if (widget.hasError) ...[
                const SizedBox(width: OrganismTheme.spacingSm),
                Icon(
                  LucideIcons.alertCircle,
                  size: OrganismTheme.iconSizeSm,
                  color: OrganismTheme.error,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// Defines the visual intent of a Semantic Badge.
enum CellBadgeVariant { primary, secondary, outline, success, warning, error }

/// A highly dense, non-interactive visual data flag used entirely to communicate state
/// without text clutter (e.g. "PAID", "PENDING", "ACTIVE").
class CellBadge extends StatelessWidget {
  final String text;
  final CellBadgeVariant variant;
  final IconData? icon;

  const CellBadge({
    super.key,
    required this.text,
    this.variant = CellBadgeVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    Border? border;

    switch (variant) {
      case CellBadgeVariant.primary:
        bgColor = OrganismTheme.primary;
        fgColor = Colors.white;
        border = null;
        break;
      case CellBadgeVariant.secondary:
        bgColor = OrganismTheme.stone100;
        fgColor = OrganismTheme.textSecondary;
        border = null;
        break;
      case CellBadgeVariant.outline:
        bgColor = Colors.transparent;
        fgColor = OrganismTheme.textPrimary;
        border = Border.all(color: OrganismTheme.border);
        break;
      // Intense ERP Semantic colors use subtle washing to prevent burning out retinas.
      case CellBadgeVariant.success:
        bgColor = OrganismTheme.successSubtle;
        fgColor = OrganismTheme.success;
        border = Border.all(color: OrganismTheme.success.withValues(alpha: 0.2));
        break;
      case CellBadgeVariant.warning:
        bgColor = OrganismTheme.warningSubtle;
        fgColor = OrganismTheme.warning;
        border = Border.all(color: OrganismTheme.warning.withValues(alpha: 0.2));
        break;
      case CellBadgeVariant.error:
        bgColor = OrganismTheme.errorSubtle;
        fgColor = OrganismTheme.error;
        border = Border.all(color: OrganismTheme.error.withValues(alpha: 0.2));
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: OrganismTheme.borderPill,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.2,
            ).copyWith(color: fgColor),
          ),
        ],
      ),
    );
  }
}

/// A highly physical, naked checkbox toggle mapping exactly to the 
/// primary/focus physics established in the Shadcn architecture.
class CellCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;

  const CellCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
  });

  @override
  State<CellCheckbox> createState() => _CellCheckboxState();
}

class _CellCheckboxState extends State<CellCheckbox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.value;
    
    Color borderColor = OrganismTheme.border;
    Color bgColor = Colors.transparent;
    
    if (widget.isDisabled) {
      borderColor = OrganismTheme.stone200;
      bgColor = isActive ? OrganismTheme.stone200 : OrganismTheme.stone50;
    } else if (isActive) {
      borderColor = OrganismTheme.primary;
      bgColor = OrganismTheme.primary;
    } else if (_isHovered) {
      borderColor = OrganismTheme.primaryLight;
    }

    return Semantics(
      checked: widget.value,
      enabled: !widget.isDisabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (!widget.isDisabled && widget.onChanged != null) {
              widget.onChanged!(!widget.value);
            }
          },
          child: AnimatedContainer(
            duration: OrganismTheme.durationFast,
            curve: OrganismTheme.curveStandard,
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(4),
              boxShadow: _isHovered && !isActive && !widget.isDisabled 
                  ? OrganismTheme.shadowRing 
                  : null,
            ),
            child: isActive
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Shadcn style angular switch. Replaces rounded pills with geometric bounds.
class CellSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;

  const CellSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
  });

  @override
  State<CellSwitch> createState() => _CellSwitchState();
}

class _CellSwitchState extends State<CellSwitch> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color trackColor = widget.isDisabled 
        ? OrganismTheme.surface 
        : (widget.value ? OrganismTheme.primary : OrganismTheme.surface);
    
    Color borderColor = widget.isDisabled
        ? OrganismTheme.stone200
        : (widget.value ? OrganismTheme.primary : OrganismTheme.border);

    return Semantics(
      toggled: widget.value,
      enabled: !widget.isDisabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (!widget.isDisabled && widget.onChanged != null) {
              widget.onChanged!(!widget.value);
            }
          },
          child: AnimatedContainer(
            duration: OrganismTheme.durationFast,
            width: 36,
            height: 20,
            padding: const EdgeInsets.all(2),
            curve: OrganismTheme.curveStandard,
            decoration: BoxDecoration(
              color: trackColor,
              border: Border.all(color: borderColor),
              borderRadius: OrganismTheme.borderSm, // 2px angular radius
              boxShadow: _isHovered && !widget.isDisabled ? OrganismTheme.shadowSm : null,
            ),
            child: AnimatedAlign(
              duration: OrganismTheme.durationFast,
              curve: OrganismTheme.curveStandard,
              alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedContainer(
                duration: OrganismTheme.durationFast,
                curve: OrganismTheme.curveStandard,
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: widget.isDisabled 
                      ? OrganismTheme.stone300 
                      : (widget.value ? OrganismTheme.stone50 : OrganismTheme.textSecondary),
                  borderRadius: BorderRadius.circular(1), // Micro inner radius
                  boxShadow: widget.isDisabled ? null : OrganismTheme.shadowSm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Headless visual party/user identifier.
class CellAvatar extends StatelessWidget {
  final String name;
  final double size;

  const CellAvatar({super.key, required this.name, this.size = 32});

  @override
  Widget build(BuildContext context) {
    // Generate initials (up to 2 chars)
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    String initials = '';
    if (parts.isNotEmpty) {
      initials += parts[0][0];
      if (parts.length > 1) {
        initials += parts[1][0];
      }
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: OrganismTheme.stone100,
        shape: BoxShape.circle,
        border: Border.all(color: OrganismTheme.stone200),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: OrganismTheme.labelLarge.copyWith(color: OrganismTheme.textPrimary, fontSize: size * 0.35),
      ),
    );
  }
}

/// Barebones structural Shimmer skeleton primitive.
class CellSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CellSkeleton({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: OrganismTheme.skeletonBase,
        borderRadius: borderRadius ?? OrganismTheme.borderSm,
      ),
    );
  }
}

/// The naked 1px membrane separator.
class CellDivider extends StatelessWidget {
  final bool isVertical;
  final double? length;

  const CellDivider({super.key, this.isVertical = false, this.length});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isVertical ? 1 : (length ?? double.infinity),
      height: isVertical ? (length ?? double.infinity) : 1,
      color: OrganismTheme.border,
    );
  }
}

/// Strict input label mapping directly to LabelLarge for consistency 
/// above inputs in form fields.
class CellLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  
  const CellLabel({super.key, required this.text, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: OrganismTheme.labelLarge),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text('*', style: OrganismTheme.labelLarge.copyWith(color: OrganismTheme.error)),
        ]
      ],
    );
  }
}

/// Filter chip for applying and removing datagrid query parameters.
class CellFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final VoidCallback? onDeleted;

  const CellFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = isSelected ? OrganismTheme.primaryLight : OrganismTheme.surface;
    Color border = isSelected ? OrganismTheme.primary : OrganismTheme.border;
    Color text = isSelected ? OrganismTheme.primary : OrganismTheme.textSecondary;

    return MouseRegion(
      cursor: onSelected != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingMd, 
            vertical: onDeleted != null ? 6.0 : 8.0,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(16), // Extra pill rounding
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: OrganismTheme.labelLarge.copyWith(color: text)),
              if (onDeleted != null) ...[
                const SizedBox(width: OrganismTheme.spacingSm),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onDeleted,
                    child: Icon(Icons.close, size: 14, color: text),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// Continuous or determinate linear loading geometry mapping to Shadcn/Progress
class CellProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0

  const CellProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: OrganismTheme.stone100,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: OrganismTheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Keyboard key geometry rendering exact literal keystroke styling
class CellKbd extends StatelessWidget {
  final String keyString;

  const CellKbd({
    super.key,
    required this.keyString,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: OrganismTheme.stone50,
        border: Border.all(color: OrganismTheme.stone200),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: OrganismTheme.stone200,
            offset: Offset(0, 1), // Simulating 3D mechanical key depth slightly
          )
        ]
      ),
      child: Text(
        keyString,
        style: OrganismTheme.code.copyWith(
          color: OrganismTheme.stone500,
          fontWeight: FontWeight.w600,
          fontSize: 12, // Force mini text
        ),
      ),
    );
  }
}

/// Exact Shadcn Radio Group primitive mapped natively.
class CellRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;

  const CellRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: OrganismTheme.primary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.minimumDensity,
      ),
    );
  }
}

/// A standard horizontal slider track.
class CellSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const CellSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: OrganismTheme.primary,
        inactiveTrackColor: OrganismTheme.stone200,
        thumbColor: OrganismTheme.primary,
        overlayColor: OrganismTheme.primaryLight.withOpacity(0.5),
        trackHeight: 4.0,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

/// Black, floating Z-Axis tooltip replicating standard Shadcn UI hover interactions.
class CellTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const CellTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      textStyle: OrganismTheme.bodySmall.copyWith(color: OrganismTheme.stone50),
      decoration: BoxDecoration(
        color: OrganismTheme.stone900,
        borderRadius: OrganismTheme.borderSm,
        boxShadow: OrganismTheme.shadowMd,
      ),
      padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd, vertical: OrganismTheme.spacingSm),
      waitDuration: const Duration(milliseconds: 250),
      child: child,
    );
  }
}

/// A mutually exclusive segmented control group for highly dense settings (e.g. List vs Grid).
class CellToggleGroup<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final ValueChanged<T> onChanged;

  const CellToggleGroup({
    super.key,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        border: Border.all(color: OrganismTheme.border),
        borderRadius: OrganismTheme.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final isSelected = entry.value == value;
          final isLast = entry.key == items.length - 1;
          return GestureDetector(
            onTap: () => onChanged(entry.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? OrganismTheme.stone100 : Colors.transparent,
                border: Border(
                  right: isLast ? BorderSide.none : BorderSide(color: OrganismTheme.border),
                ),
              ),
              child: Center(
                child: itemBuilder(entry.value),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// An interactive badge that can be deleted. Standard for multi-select combo boxes.
class CellInputChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const CellInputChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: OrganismTheme.stone100,
        borderRadius: OrganismTheme.borderSm,
        border: Border.all(color: OrganismTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: OrganismTheme.bodySmall),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDeleted,
            hoverColor: OrganismTheme.stone200,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                LucideIcons.x,
                size: OrganismTheme.iconSizeXs,
                color: OrganismTheme.iconSecondary,
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// A premium, native code-based logo for Ambaji Sarees.
/// Supports a collapsed (Icon-only) and expanded (Text + Icon) state.
class AmbajiSareeLogo extends StatelessWidget {
  final bool isCollapsed;
  final double size;

  const AmbajiSareeLogo({
    super.key,
    this.isCollapsed = false,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    // The "Box" icon built from primitive containers to ensure exact branding.
    final boxIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: OrganismTheme.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: OrganismTheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(size * 0.1),
          ),
        ),
      ),
    );

    if (isCollapsed) return boxIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        boxIcon,
        const SizedBox(width: OrganismTheme.spacingMd),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AMBAJI',
              style: OrganismTheme.titleLarge.copyWith(
                fontSize: size * 0.6,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
                color: OrganismTheme.primary,
                height: 1.0,
              ),
            ),
            Text(
              'SAREES',
              style: OrganismTheme.labelLarge.copyWith(
                fontSize: size * 0.3,
                letterSpacing: 4.0,
                color: OrganismTheme.textMuted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
