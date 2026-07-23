import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DatePopover extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const DatePopover({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<DatePopover> createState() => _DatePopoverState();
}

class _DatePopoverState extends State<DatePopover> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _parseInitialDates();
  }

  void _parseInitialDates() {
    final today = DateTime.now();
    if (widget.selectedValue != null && widget.selectedValue!.contains(':')) {
      final parts = widget.selectedValue!.split(':');
      if (parts.length == 2) {
        final start = DateTime.tryParse(parts[0]);
        final end = DateTime.tryParse(parts[1]);
        if (start != null && end != null) {
          _startDate = start;
          _endDate = end;
          return;
        }
      }
    }
    // Defaults: Last 7 Days
    _endDate = today;
    _startDate = today.subtract(const Duration(days: 7));
  }

  void _setQuickRange(int days) {
    final today = DateTime.now();
    var start = today.subtract(Duration(days: days));
    final fyStart = DateTime(2026, 4, 1);
    if (start.isBefore(fyStart)) {
      start = fyStart;
    }
    setState(() {
      _endDate = today;
      _startDate = start;
    });
  }

  String _getYearlessRangeString() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final startStr = '${months[_startDate.month - 1]} ${_startDate.day}';
    final endStr = '${months[_endDate.month - 1]} ${_endDate.day}';
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final today = DateTime.now();

    return shad.ModalContainer(
      child: Container(
        width: 620 * theme.scaling,
        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Date Range',
              style: theme.typography.large.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.foreground,
              ),
            ),
            const shad.DensityGap(shad.gapMd),

            // Row of quick chips
            Wrap(
              spacing: theme.density.baseGap * shad.gapSm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                shad.Chip(
                  style: const shad.ButtonStyle.outline(),
                  onPressed: () => _setQuickRange(7),
                  child: const Text('Last 7 Days'),
                ),
                shad.Chip(
                  style: const shad.ButtonStyle.outline(),
                  onPressed: () => _setQuickRange(30),
                  child: const Text('Last 30 Days'),
                ),
                shad.Chip(
                  style: const shad.ButtonStyle.outline(),
                  onPressed: () => _setQuickRange(45),
                  child: const Text('Last 45 Days'),
                ),
                // Dynamic 4th Chip: Always styled as selected, shows the active range
                shad.Chip(
                  style: const shad.ButtonStyle.primary(),
                  child: Text(_getYearlessRangeString()),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapLg),

            // Native DatePickerDialog wrapped in Theme override for text clipping
            shad.Theme(
              data: theme.copyWith(
                typography: () => theme.typography.copyWith(
                  small: () => theme.typography.small.copyWith(
                    height: 1.0,
                  ),
                ),
              ),
              child: shad.DatePickerDialog(
                initialViewType: shad.CalendarViewType.date,
                selectionMode: shad.CalendarSelectionMode.range,
                initialValue: shad.CalendarValue.range(_startDate, _endDate),
                initialView: shad.CalendarView.fromDateTime(_startDate),
                stateBuilder: (date) {
                  final todayClean = DateTime(today.year, today.month, today.day);
                  final dateClean = DateTime(date.year, date.month, date.day);
                  final fyStartClean = DateTime(2026, 4, 1);
                  if (dateClean.isBefore(fyStartClean) || dateClean.isAfter(todayClean)) {
                    return shad.DateState.disabled;
                  }
                  return shad.DateState.enabled;
                },
                onChanged: (val) {
                  if (val is shad.RangeCalendarValue) {
                    setState(() {
                      _startDate = val.start;
                      _endDate = val.end;
                    });
                  } else if (val is shad.SingleCalendarValue) {
                    setState(() {
                      _startDate = val.date;
                      _endDate = val.date;
                    });
                  }
                },
              ),
            ),
            const shad.DensityGap(shad.gapLg),

            // Bottom Actions (Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                shad.OutlineButton(
                  onPressed: () => shad.closeOverlay(context),
                  child: const Text('Cancel'),
                ),
                const shad.DensityGap(shad.gapSm),
                shad.PrimaryButton(
                  onPressed: () {
                    var start = _startDate;
                    var end = _endDate;
                    if (start.isAfter(end)) {
                      final temp = start;
                      start = end;
                      end = temp;
                    }
                    final startStr = start.toIso8601String().substring(0, 10);
                    final endStr = end.toIso8601String().substring(0, 10);
                    widget.onSelected('$startStr:$endStr');
                    shad.closeOverlay(context);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
