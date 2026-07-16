import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells.dart';

/// [TissueInlineEdit] — Click-to-edit smart typography
class TissueInlineEdit extends StatefulWidget {
  final String initialValue;
  final void Function(String) onSave;
  final TextStyle? textStyle;
  final bool isNumeric;

  const TissueInlineEdit({
    super.key,
    required this.initialValue,
    required this.onSave,
    this.textStyle,
    this.isNumeric = false,
  });

  @override
  State<TissueInlineEdit> createState() => _TissueInlineEditState();
}

class _TissueInlineEditState extends State<TissueInlineEdit> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _save();
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _controller.text = widget.initialValue;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _save() {
    if (!_isEditing) return;
    setState(() {
      _isEditing = false;
    });
    if (_controller.text != widget.initialValue) {
      widget.onSave(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return IntrinsicWidth(
        child: CellInput(
          controller: _controller,
          focusNode: _focusNode,
          isNumeric: widget.isNumeric,
          isCompact: true,
          onSubmitted: (_) => _save(),
        ),
      );
    }

    final colors = OrganismTheme.colorsOf(context);
    final displayStyle = widget.textStyle ?? OrganismTheme.bodyLarge(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _startEditing,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingXs, 
            vertical: OrganismTheme.spacingXs / 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: OrganismTheme.borderSm,
          ),
          child: Text(
            widget.initialValue.isEmpty ? 'Click to edit...' : widget.initialValue,
            style: displayStyle.copyWith(
              color: widget.initialValue.isEmpty ? colors.textMuted : displayStyle.color,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
              decorationColor: colors.borderSubtle,
            ),
          ),
        ),
      ),
    );
  }
}
