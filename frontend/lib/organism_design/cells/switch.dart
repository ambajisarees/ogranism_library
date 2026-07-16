import 'package:flutter/material.dart';
import '../theme.dart';
import 'focus.dart'; // Direct import for OrganismFocus

/// [CellSwitch] — Sliding capsule binary toggle atom.
///
/// Implements a geometric [Shadcn]-style toggle with angular bounds.
/// Supports selection states, disabled modes, and hover physics.

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
    final colors = OrganismTheme.colorsOf(context);
    Color trackColor = widget.isDisabled 
        ? colors.surface 
        : (widget.value ? colors.primary : colors.surface);
    
    Color borderColor = widget.isDisabled
        ? colors.surfaceActive
        : (widget.value ? colors.primary : colors.border);

    return OrganismFocus(
      onTap: () {
        if (!widget.isDisabled && widget.onChanged != null) {
          widget.onChanged!(!widget.value);
        }
      },
      isDisabled: widget.isDisabled,
      borderRadius: OrganismTheme.borderSm,
      child: Semantics(
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
              padding: const EdgeInsets.all(OrganismTheme.spacing2Xs),
              curve: OrganismTheme.curveStandard,
              decoration: BoxDecoration(
                color: trackColor,
                border: Border.all(color: borderColor),
                borderRadius: OrganismTheme.borderSm, // 2px angular radius
                boxShadow: _isHovered && !widget.isDisabled ? OrganismTheme.shadowsOf(context, elevation: 1) : null,
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
                        ? colors.trackInactive 
                        : (widget.value ? colors.surfaceMuted : colors.textSecondary),
                    borderRadius: BorderRadius.circular(1), // Micro inner radius
                    boxShadow: widget.isDisabled ? null : OrganismTheme.shadowsOf(context, elevation: 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
