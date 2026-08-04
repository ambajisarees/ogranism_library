/// LLM NOTE: DabDatePopover
/// - Level: DAB Popover Component
/// - Purpose: Quick date range picker popover with presets (Today, Yesterday, Last 7 Days, Month-to-date) and custom calendar range selector for DynamicActionBar.

library;
/// - Widget Composition: shad.Card -> Row(Left Column Presets + VerticalDivider + Right Column shad.Calendar & Apply Button).

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Date Range Popover matching Reference 1:
/// Left pane: Quick preset options (Today, This Week, This Month, Last 30 Days, Last 60 Days, Last 90 Days, This Year)
/// Vertical Divider
/// Right pane: Calendar range selection view
class DabDatePopover extends StatefulWidget {
  final shad.CalendarValue? selectedRange;
  final ValueChanged<shad.CalendarValue?> onRangeSelected;
  final VoidCallback onClose;

  const DabDatePopover({
    super.key,
    this.selectedRange,
    required this.onRangeSelected,
    required this.onClose,
  });

  @override
  State<DabDatePopover> createState() => _DabDatePopoverState();
}

class _DabDatePopoverState extends State<DabDatePopover> {
  String? _activePreset = 'Last 30 Days';
  late shad.CalendarValue _currentValue;
  DateTime _displayedMonth = DateTime.now();
  shad.CalendarView get _calendarView => shad.CalendarView(_displayedMonth.year, _displayedMonth.month);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentValue = widget.selectedRange ??
        shad.CalendarValue.range(
          now.subtract(const Duration(days: 29)),
          now,
        );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  void _applyPreset(String preset) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (preset) {
      case 'Today':
        start = now;
        break;
      case 'T-7 Days':
        start = now.subtract(const Duration(days: 6));
        break;
      case 'T-15 Days':
        start = now.subtract(const Duration(days: 14));
        break;
      case 'T-30 Days':
        start = now.subtract(const Duration(days: 29));
        break;
      case 'T-60 Days':
        start = now.subtract(const Duration(days: 59));
        break;
      case 'T-90 Days':
        start = now.subtract(const Duration(days: 89));
        break;
      case 'This Year':
        final fiscalYear = now.month >= 4 ? now.year : now.year - 1;
        start = DateTime(fiscalYear, 4, 1);
        break;
      default:
        start = now.subtract(const Duration(days: 29));
    }

    setState(() {
      _activePreset = preset;
      _currentValue = shad.CalendarValue.range(start, end);
    });
    widget.onRangeSelected(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final presets = [
      'Today',
      'T-7 Days',
      'T-15 Days',
      'T-30 Days',
      'T-60 Days',
      'T-90 Days',
      'This Year',
    ];

    return shad.Card(
      padding: EdgeInsets.all(8 * theme.scaling),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Pane: Quick Presets (Width 140px, top aligned)
            SizedBox(
              width: 140 * theme.scaling,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: presets.map((preset) {
                  final isSelected = _activePreset == preset;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4 * theme.scaling),
                    child: isSelected
                        ? shad.SecondaryButton(
                            onPressed: () => _applyPreset(preset),
                            child: Text(
                              preset,
                              style: theme.typography.textSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.foreground,
                              ),
                            ),
                          )
                        : shad.GhostButton(
                            onPressed: () => _applyPreset(preset),
                            child: Text(
                              preset,
                              style: theme.typography.textSmall.copyWith(
                                color: colors.foreground,
                              ),
                            ),
                          ),
                  );
                }).toList(),
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            Container(
              width: 1.0,
              color: colors.border,
            ),
            const shad.DensityGap(shad.gapMd),

            // Right Pane: Month Navigation Header + Native Calendar (Width 260px)
            SizedBox(
              width: 260 * theme.scaling,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Month Header Navigation Bar (Square Ghost Icon Buttons with 8px padding on all sides)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      shad.IconButton.secondary(
                        icon: Icon(
                          shad.LucideIcons.arrowLeft,
                          size: 14 * theme.scaling,
                        ),
                        onPressed: () {
                          setState(() {
                            _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
                          });
                        },
                      ),
                      Text(
                        '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}',
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.foreground,
                        ),
                      ),
                      shad.IconButton.secondary(
                        icon: Icon(
                          shad.LucideIcons.arrowRight,
                          size: 14 * theme.scaling,
                        ),
                        onPressed: () {
                          setState(() {
                            _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  ),
                  const shad.DensityGap(shad.gapMd),

                  // Calendar View
                  shad.Calendar(
                    value: _currentValue,
                    view: _calendarView,
                    selectionMode: shad.CalendarSelectionMode.range,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _activePreset = null;
                          _currentValue = val;
                        });
                        widget.onRangeSelected(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
