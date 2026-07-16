import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// [OrganismFocus] — Central focus ring and interaction wrapper atom.
///
/// Provides keyboard accessibility (Tab, Enter, Space) and the branded 
/// focus ring (halo) to any child component. Used by all interactive cells.

/// A universal interaction wrapper that provides keyboard accessibility (Tab, Enter, Space)
/// and the branded enterprise Focus Ring (Halo) to any Cell or Tissue component.
class OrganismFocus extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isDisabled;
  final BorderRadius? borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;

  const OrganismFocus({
    super.key,
    required this.child,
    this.onTap,
    this.isDisabled = false,
    this.borderRadius,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<OrganismFocus> createState() => _OrganismFocusState();
}

class _OrganismFocusState extends State<OrganismFocus> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(OrganismFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
    }
  }

  void _handleFocusChange(bool focused) {
    if (mounted && !widget.isDisabled) {
      setState(() => _isFocused = focused);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.isDisabled || widget.onTap == null) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter || 
          event.logicalKey == LogicalKeyboardKey.space) {
        widget.onTap!();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDisabled) return widget.child;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onFocusChange: _handleFocusChange,
      onKeyEvent: _handleKeyEvent,
      child: AnimatedContainer(
        duration: OrganismTheme.durationFast,
        curve: OrganismTheme.curveStandard,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? OrganismTheme.borderSm,
          boxShadow: _isFocused ? OrganismTheme.focusShadows(context) : null,
        ),
        child: widget.child,
      ),
    );
  }
}
