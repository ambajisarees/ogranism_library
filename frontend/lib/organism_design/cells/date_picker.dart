import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../plasma/popover.dart'; // Direct import from plasma submodule
import 'calendar.dart'; // Direct import for CellCalendar
import 'spatial.dart';   // Direct import for CellGap

/// [CellDatePicker] — Inline atomic date picker with segment typing & popover calendar.
class CellDatePicker extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool isCompact;

  const CellDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.isCompact = false, // Default false to match standard form fields height
  });

  @override
  State<CellDatePicker> createState() => _CellDatePickerState();
}

class _CellDatePickerState extends State<CellDatePicker> {
  final GlobalKey<PlasmaPopoverState> _popoverKey = GlobalKey<PlasmaPopoverState>();
  
  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;

  final FocusNode _dayFocusNode = FocusNode();
  final FocusNode _monthFocusNode = FocusNode();
  final FocusNode _yearFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController(
      text: widget.value != null ? widget.value!.day.toString().padLeft(2, '0') : '',
    );
    _monthController = TextEditingController(
      text: widget.value != null ? widget.value!.month.toString().padLeft(2, '0') : '',
    );
    _yearController = TextEditingController(
      text: widget.value != null ? widget.value!.year.toString() : '',
    );

    // Auto-select text on focus to make overwriting easy
    _dayFocusNode.addListener(() {
      if (_dayFocusNode.hasFocus) {
        _dayController.selection = TextSelection(baseOffset: 0, extentOffset: _dayController.text.length);
      }
    });
    _monthFocusNode.addListener(() {
      if (_monthFocusNode.hasFocus) {
        _monthController.selection = TextSelection(baseOffset: 0, extentOffset: _monthController.text.length);
      }
    });
    _yearFocusNode.addListener(() {
      if (_yearFocusNode.hasFocus) {
        _yearController.selection = TextSelection(baseOffset: 0, extentOffset: _yearController.text.length);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CellDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      final date = widget.value!;
      
      // Parse current controller values to compare
      final currentDay = int.tryParse(_dayController.text);
      final currentMonth = int.tryParse(_monthController.text);
      final currentYear = int.tryParse(_yearController.text);
      
      // Only overwrite text if the incoming date value is actually different component-wise
      if (currentDay != date.day || currentMonth != date.month || currentYear != date.year) {
        final dayStr = date.day.toString().padLeft(2, '0');
        final monthStr = date.month.toString().padLeft(2, '0');
        final yearStr = date.year.toString();
        
        if (_dayController.text != dayStr) _dayController.text = dayStr;
        if (_monthController.text != monthStr) _monthController.text = monthStr;
        if (_yearController.text != yearStr) _yearController.text = yearStr;
      }
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocusNode.dispose();
    _monthFocusNode.dispose();
    _yearFocusNode.dispose();
    super.dispose();
  }

  void _updateDate() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);
    if (day != null && month != null && year != null) {
      if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1000 && year <= 9999) {
        try {
          final date = DateTime(year, month, day);
          widget.onChanged(date);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final height = widget.isCompact ? OrganismTheme.buttonHeightCompact : OrganismTheme.buttonHeightStandard;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: OrganismTheme.borderSm,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: OrganismTheme.spacingMd),
          // Day field
          SizedBox(
            width: 36,
            child: TextField(
              controller: _dayController,
              focusNode: _dayFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 2,
              style: OrganismTheme.bodyMedium(context).copyWith(fontFamily: 'Mono'),
              decoration: const InputDecoration(
                hintText: 'DD',
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                if (v.length == 2) {
                  _monthFocusNode.requestFocus();
                }
                _updateDate();
              },
            ),
          ),
          const SizedBox(width: 4),
          Text('/', style: OrganismTheme.bodyMedium(context).copyWith(color: colors.textMuted)),
          const SizedBox(width: 4),
          // Month field
          SizedBox(
            width: 36,
            child: TextField(
              controller: _monthController,
              focusNode: _monthFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 2,
              style: OrganismTheme.bodyMedium(context).copyWith(fontFamily: 'Mono'),
              decoration: const InputDecoration(
                hintText: 'MM',
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                if (v.length == 2) {
                  _yearFocusNode.requestFocus();
                }
                _updateDate();
              },
            ),
          ),
          const SizedBox(width: 4),
          Text('/', style: OrganismTheme.bodyMedium(context).copyWith(color: colors.textMuted)),
          const SizedBox(width: 4),
          // Year field
          SizedBox(
            width: 56,
            child: TextField(
              controller: _yearController,
              focusNode: _yearFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: OrganismTheme.bodyMedium(context).copyWith(fontFamily: 'Mono'),
              decoration: const InputDecoration(
                hintText: 'YYYY',
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                _updateDate();
              },
            ),
          ),
          const Spacer(),
          // Popover Calendar Icon Trigger
          PlasmaPopover(
            key: _popoverKey,
            explicitWidth: 280.0,
            trigger: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd, vertical: 8),
                child: Icon(
                  LucideIcons.calendar,
                  size: OrganismTheme.iconSizeMd,
                  color: OrganismTheme.iconSecondary(context),
                ),
              ),
            ),
            content: CellCalendar(
              value: widget.value,
              onDateSelected: (date) {
                widget.onChanged(date);
                _popoverKey.currentState?.close();
                // Update text controllers
                _dayController.text = date.day.toString().padLeft(2, '0');
                _monthController.text = date.month.toString().padLeft(2, '0');
                _yearController.text = date.year.toString();
              },
            ),
          ),
          const CellGap(0.5),
        ],
      ),
    );
  }
}
