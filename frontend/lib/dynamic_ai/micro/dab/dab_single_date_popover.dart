/*
================================================================================
LLM CONTEXT & QUERY SPACE — DAB SINGLE DATE POPOVER (dab_single_date_popover.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Single date picker popover for form fields and DAB controls.
   - Minus the left preset column (only calendar view + header to pick date and dismiss).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Returns a single selected DateTime via [onDateSelected] callback.
   - Built with native shadcn_flutter controls (shad.Card, shad.Calendar, shad.Button).
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DabSingleDatePopover] — Compact Single Date Picker Popover.
class DabSingleDatePopover extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onClose;

  const DabSingleDatePopover({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    required this.onClose,
  });

  @override
  State<DabSingleDatePopover> createState() => _DabSingleDatePopoverState();
}

class _DabSingleDatePopoverState extends State<DabSingleDatePopover> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String get _formattedSelectedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${_selectedDate.day.toString().padLeft(2, '0')} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.Card(
      child: Container(
        width: 300 * theme.scaling,
        padding: EdgeInsets.all(12 * theme.scaling),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Popover Header
            Row(
              children: [
                Icon(shad.LucideIcons.calendar, size: 16 * theme.scaling, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  _formattedSelectedDate,
                  style: theme.typography.p.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                  ),
                ),
                const Spacer(),
                shad.GhostButton(
                  onPressed: widget.onClose,
                  child: const Icon(shad.LucideIcons.x, size: 14),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),

            // Month Navigation Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shad.OutlineButton(
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                    });
                  },
                  child: const Icon(shad.LucideIcons.arrowLeft, size: 14),
                ),
                Text(
                  '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}',
                  style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
                ),
                shad.OutlineButton(
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                    });
                  },
                  child: const Icon(shad.LucideIcons.arrowRight, size: 14),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),

            // Calendar Picker Widget
            shad.Calendar(
              value: shad.CalendarValue.single(_selectedDate),
              view: shad.CalendarView(_displayedMonth.year, _displayedMonth.month),
              selectionMode: shad.CalendarSelectionMode.single,
              onChanged: (val) {
                if (val != null) {
                  final range = val.toRange();
                  setState(() {
                    _selectedDate = range.start;
                  });
                }
              },
            ),
            const shad.DensityGap(shad.gapMd),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                shad.OutlineButton(
                  onPressed: widget.onClose,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                shad.PrimaryButton(
                  onPressed: () {
                    widget.onDateSelected(_selectedDate);
                    widget.onClose();
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
