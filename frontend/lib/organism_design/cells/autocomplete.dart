import 'package:flutter/material.dart';
import '../theme.dart';
import 'input.dart';
import 'input_chip.dart';

/// [CellAutocomplete] — Auto-completing search input atom.
///
/// Wraps Flutter's native [RawAutocomplete] inside a styled [CellInput] field view
/// and provides an auto-sizing dropdown popup overlay matching the Organism design tokens.
class CellAutocomplete<T extends Object> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T) labelBuilder;
  final String placeholder;
  final bool isCompact;
  final bool hasError;
  final bool isDisabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  // Multi-select support
  final bool isMultiSelect;
  final List<T>? selectedValues;
  final ValueChanged<List<T>>? onSelectedValuesChanged;

  const CellAutocomplete({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    required this.labelBuilder,
    this.placeholder = "Search...",
    this.isCompact = false,
    this.hasError = false,
    this.isDisabled = false,
    this.focusNode,
    this.controller,
    this.isMultiSelect = false,
    this.selectedValues,
    this.onSelectedValuesChanged,
  });

  @override
  State<CellAutocomplete<T>> createState() => _CellAutocompleteState<T>();
}

class _CellAutocompleteState<T extends Object> extends State<CellAutocomplete<T>> {
  final GlobalKey _fieldKey = GlobalKey();
  late final TextEditingController _effectiveController;
  late final FocusNode _effectiveFocusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
    _syncControllerValue();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(CellAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value || widget.selectedValues != oldWidget.selectedValues) {
      _syncControllerValue();
    }
  }

  void _syncControllerValue() {
    if (widget.isMultiSelect) {
      // In multi-select, search text is separate from chips
      return;
    }
    final expectedText = widget.value != null ? widget.labelBuilder(widget.value!) : '';
    if (_effectiveController.text != expectedText) {
      _effectiveController.text = expectedText;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.controller == null) _effectiveController.dispose();
    if (widget.focusNode == null) _effectiveFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return RawAutocomplete<T>(
      focusNode: _effectiveFocusNode,
      textEditingController: _effectiveController,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          // Filter out already selected values from dropdown options in multi-select mode
          if (widget.isMultiSelect && widget.selectedValues != null) {
            return widget.items.where((T option) => !widget.selectedValues!.contains(option)).take(50);
          }
          return widget.items.take(50);
        }
        final query = textEditingValue.text.toLowerCase();
        final filtered = widget.items.where((T option) {
          return widget.labelBuilder(option).toLowerCase().contains(query);
        });
        if (widget.isMultiSelect && widget.selectedValues != null) {
          return filtered.where((T option) => !widget.selectedValues!.contains(option));
        }
        return filtered;
      },
      displayStringForOption: widget.labelBuilder,
      onSelected: (T selection) {
        if (widget.isMultiSelect) {
          final currentList = List<T>.from(widget.selectedValues ?? []);
          if (!currentList.contains(selection)) {
            currentList.add(selection);
            widget.onSelectedValuesChanged?.call(currentList);
          }
          _effectiveController.clear();
          _effectiveFocusNode.requestFocus();
        } else {
          widget.onChanged?.call(selection);
        }
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        if (widget.isMultiSelect) {
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

          // Build chips
          final chips = (widget.selectedValues ?? []).map((T val) {
            return Padding(
              padding: const EdgeInsets.only(right: 6.0, top: 2.0, bottom: 2.0),
              child: CellInputChip(
                label: widget.labelBuilder(val),
                onDeleted: () {
                  final currentList = List<T>.from(widget.selectedValues ?? []);
                  currentList.remove(val);
                  widget.onSelectedValuesChanged?.call(currentList);
                  _effectiveFocusNode.requestFocus();
                },
              ),
            );
          }).toList();

          return MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
            child: GestureDetector(
              key: _fieldKey,
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!widget.isDisabled) focusNode.requestFocus();
              },
              child: AnimatedContainer(
                duration: OrganismTheme.durationFast,
                curve: OrganismTheme.curveStandard,
                width: double.infinity,
                constraints: BoxConstraints(minHeight: height),
                padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isDisabled ? colors.inputBackgroundDisabled : colors.inputBackground,
                  borderRadius: OrganismTheme.borderSm,
                  border: Border.all(color: borderColor),
                  boxShadow: boxShadow,
                ),
                alignment: Alignment.centerLeft,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 4.0,
                  children: [
                    ...chips,
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 80, maxWidth: 200),
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        enabled: !widget.isDisabled,
                        onChanged: (val) {
                          setState(() {});
                        },
                        onSubmitted: (_) => onFieldSubmitted(),
                        style: widget.isCompact 
                            ? OrganismTheme.bodySmall(context).copyWith(color: colors.textPrimary) 
                            : OrganismTheme.bodyLarge(context).copyWith(color: colors.textPrimary),
                        cursorColor: colors.primary,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          counterText: "",
                          contentPadding: EdgeInsets.zero,
                          hintText: (widget.selectedValues ?? []).isEmpty ? widget.placeholder : "",
                          hintStyle: (widget.isCompact 
                              ? OrganismTheme.bodySmall(context) 
                              : OrganismTheme.bodyLarge(context)).copyWith(color: colors.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          key: _fieldKey,
          child: CellInput(
            controller: textEditingController,
            focusNode: focusNode,
            placeholder: widget.placeholder,
            isCompact: widget.isCompact,
            hasError: widget.hasError,
            isDisabled: widget.isDisabled,
            onSubmitted: (_) => onFieldSubmitted(),
          ),
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
        final double? fieldWidth = (_fieldKey.currentContext?.findRenderObject() as RenderBox?)?.size.width;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: fieldWidth ?? 280,
              constraints: const BoxConstraints(maxHeight: 250),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: OrganismTheme.borderSm,
                border: Border.all(color: colors.border),
                boxShadow: OrganismTheme.focusShadows(context),
              ),
              child: ClipRRect(
                borderRadius: OrganismTheme.borderSm,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final T option = options.elementAt(index);
                    final isSelected = widget.isMultiSelect 
                        ? (widget.selectedValues ?? []).contains(option)
                        : option == widget.value;
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: isSelected ? colors.surfaceSubtle : null,
                        child: Text(
                          widget.labelBuilder(option),
                          style: OrganismTheme.bodySmall(context).copyWith(
                            color: colors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
