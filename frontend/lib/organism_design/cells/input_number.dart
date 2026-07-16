import 'package:flutter/material.dart';
import '../theme.dart';
import 'input.dart'; // Direct import for CellInput
import '../utils/locale_utils.dart'; // Direct import for OrganismFormat

/// [CellInputNumber] — Numeric entry atom with Indian Lakhs formatting.
///
/// Implements domain-specific blur-rounding logic. Strips formatting for 
/// editing and re-applies en_IN standard formatting on blur.

/// A specialized numeric input for Currency and Technical rates.
/// Implements blur-rounding logic that formats the input to Indian standards (en_IN)
/// once focus is lost.
class CellInputNumber extends StatefulWidget {
  final double? initialValue;
  final int decimals;
  final String? placeholder;
  final String? prefix; // e.g., ₹
  final String? suffix; // e.g., / m
  final ValueChanged<double?>? onChanged;
  final bool isCompact;
  final bool isDisabled;

  const CellInputNumber({
    super.key,
    this.initialValue,
    this.decimals = 2,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.isCompact = false,
    this.isDisabled = false,
  });

  @override
  State<CellInputNumber> createState() => _CellInputNumberState();
}

class _CellInputNumberState extends State<CellInputNumber> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  double? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    
    final displayString = _currentValue != null 
        ? OrganismFormat.number(_currentValue!, decimals: widget.decimals) 
        : '';
        
    _controller = TextEditingController(text: displayString);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // Logic for blur rounding
      final text = _controller.text.replaceAll(',', '');
      final parsed = double.tryParse(text);
      
      setState(() {
        _currentValue = parsed;
        _controller.text = _currentValue != null 
            ? OrganismFormat.number(_currentValue!, decimals: widget.decimals) 
            : '';
      });
      
      if (widget.onChanged != null) {
        widget.onChanged!(_currentValue);
      }
    } else {
      // On focus: strip formatting for easier editing
      final rawText = _controller.text.replaceAll(',', '');
      _controller.text = rawText;
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: rawText.length);
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
    return CellInput(
      controller: _controller,
      focusNode: _focusNode,
      isNumeric: true,
      isDisabled: widget.isDisabled,
      isCompact: widget.isCompact,
      placeholder: widget.placeholder,
      suffixText: widget.suffix,
      prefixIcon: widget.prefix != null ? null : null, // Future: custom text affixes
      onChanged: (val) {
        // We don't update _currentValue here to avoid fighting the formatter while typing
      },
    );
  }
}
