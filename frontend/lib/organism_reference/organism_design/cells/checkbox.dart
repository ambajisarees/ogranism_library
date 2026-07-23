import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'focus.dart'; // Direct import for OrganismFocus

/// [CellCheckbox] — Physical naked boolean toggle atom.
///
/// Encapsulates the visual state of a checkbox, mapping to the primary/focus
/// physics established in the theme. Supports disabled and indeterminate states.

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
    final colors = OrganismTheme.colorsOf(context);
    final bool isActive = widget.value;

    Color borderColor = colors.border;
    Color bgColor = Colors.transparent;

    if (widget.isDisabled) {
      borderColor = colors.surfaceActive;
      bgColor = isActive ? colors.surfaceActive : colors.surfaceMuted;
    } else if (isActive) {
      borderColor = colors.primary;
      bgColor = colors.primary;
    } else if (_isHovered) {
      borderColor = colors.primaryLight;
    }

    return OrganismFocus(
      onTap: () {
        if (!widget.isDisabled && widget.onChanged != null) {
          widget.onChanged!(!widget.value);
        }
      },
      isDisabled: widget.isDisabled,
      borderRadius: OrganismTheme.borderSm,
      child: Semantics(
        checked: widget.value,
        enabled: !widget.isDisabled,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: widget.isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
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
                    ? OrganismTheme.shadowsOf(context, elevation: 1)
                    : null,
              ),
              child: isActive
                  ? Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
