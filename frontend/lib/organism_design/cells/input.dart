import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'spatial.dart'; // Direct import for CellGap

/// [CellInput] — Universal naked text field atom.
///
/// Strips out default Material decorations in favor of a precision-built
/// density-aware surface with integrated focus and error states.

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
  final bool isCompact;
  final bool obscureText;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isNaked;
  final TextStyle? textStyle;
  final TextEditingController? controller;
  final TextAlign textAlign;
  final String? suffixText;

  const CellInput({
    super.key,
    this.placeholder,
    this.initialValue,
    this.isNumeric = false,
    this.isSearch = false,
    this.hasError = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.obscureText = false,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.keyboardType,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.isNaked = false,
    this.textStyle,
    this.controller,
    this.textAlign = TextAlign.start,
    this.suffixText,
  });

  @override
  State<CellInput> createState() => _CellInputState();
}

class _CellInputState extends State<CellInput> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  TextEditingController? _internalController;
  TextEditingController get _effectiveController => widget.controller ?? (_internalController ??= TextEditingController(text: widget.initialValue));
  
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(CellInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.controller == null) {
      _effectiveController.text = widget.initialValue ?? '';
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    // Dynamic numeric enforcement
    final keyboardType = widget.keyboardType ?? (widget.isNumeric ? const TextInputType.numberWithOptions(decimal: true) : null);
    final inputFormatters = widget.inputFormatters ?? (widget.isNumeric ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null);

    // Shadcn Architectural Matrix Evaluator
    Color borderColor = colors.inputBorder;
    if (widget.hasError) {
      borderColor = colors.error;
    } else if (_isFocused) {
      borderColor = colors.focusRing;
    } else if (_isHovered && !widget.isDisabled) {
      borderColor = colors.inputBorderHover;
    }

    final double height = widget.isCompact ? OrganismTheme.buttonHeightCompact : OrganismTheme.buttonHeightStandard;
    List<BoxShadow>? boxShadow;
    if (_isFocused && !widget.hasError) {
      boxShadow = OrganismTheme.focusShadows(context);
    }

    // Compose Icons
    Widget? prefix;
    if (widget.isSearch) {
      prefix = Icon(LucideIcons.search, color: colors.textMuted, size: 16);
    } else if (widget.prefixIcon != null) {
      prefix = Icon(widget.prefixIcon, color: colors.textMuted, size: 16);
    }

    Widget? suffix;
    if (widget.hasError) {
      suffix = Icon(LucideIcons.alertCircle, color: colors.error, size: 16);
    } else if (widget.suffixIcon != null) {
      suffix = GestureDetector(
        onTap: widget.onSuffixPressed,
        child: MouseRegion(
          cursor: widget.onSuffixPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Icon(widget.suffixIcon, color: colors.textMuted, size: 16),
        ),
      );
    } else if (widget.suffixText != null) {
      suffix = Text(
        widget.suffixText!,
        style: OrganismTheme.bodyMedium(context).copyWith(
          color: colors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final Widget inputRow = Row(
      crossAxisAlignment: widget.maxLines! > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (prefix != null) ...[
          prefix,
          CellGap.small,
        ],
        Expanded(
          child: TextField(
            controller: _effectiveController,
            focusNode: _effectiveFocusNode,
            enabled: !widget.isDisabled,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textAlign: widget.textAlign,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            style: widget.textStyle ?? (widget.isNumeric 
              ? OrganismTheme.codeTabular(context).copyWith(color: colors.textPrimary) 
              : OrganismTheme.bodyLarge(context).copyWith(color: colors.textPrimary)),
            cursorColor: colors.primary,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              counterText: "",
              contentPadding: EdgeInsets.zero,
              hintText: widget.placeholder,
              hintStyle: OrganismTheme.bodyLarge(context).copyWith(color: colors.textMuted),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
        if (suffix != null) ...[
          CellGap.small,
          suffix,
        ]
      ],
    );

    if (widget.isNaked) {
      return inputRow;
    }

    return Semantics(
      enabled: !widget.isDisabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!widget.isDisabled) _effectiveFocusNode.requestFocus();
          },
          child: AnimatedContainer(
            duration: OrganismTheme.durationFast,
            curve: OrganismTheme.curveStandard,
            width: double.infinity,
            height: widget.maxLines! > 1 ? null : height,
            constraints: BoxConstraints(
              minHeight: widget.maxLines! > 1 ? (height * 2) : height,
            ),
            padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isDisabled ? colors.inputBackgroundDisabled : colors.inputBackground,
              borderRadius: OrganismTheme.borderSm,
              border: Border.all(color: borderColor),
              boxShadow: boxShadow,
            ),
            alignment: widget.maxLines! > 1 ? Alignment.topLeft : Alignment.centerLeft,
            child: inputRow,
          ),
        ),
      ),
    );
  }
}
