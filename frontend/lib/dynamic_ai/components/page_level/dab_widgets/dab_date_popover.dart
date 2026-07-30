/// LLM NOTE: DabDatePopover
/// - Level: DAB Popover Widget
/// - Purpose: Split-pane date range picker popover with quick presets list (Today, Yesterday, Last 28 Days, etc.) on the left and full calendar picker on the right.
/// - Widget Composition: shad.Card -> Row(Left Column Presets + VerticalDivider + Right Column shad.Calendar & Apply Button).

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Date Range Popover matching Reference 1:
/// Left pane: Quick preset options (Today, Yesterday, This Week, Last 7 Days, Last 28 Days, This Month, Last Month, This Year)
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
  String? _activePreset = 'Last 28 Days';
  late shad.CalendarValue _currentValue;
  final shad.CalendarView _calendarView = shad.CalendarView.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentValue = widget.selectedRange ??
        shad.CalendarValue.range(
          now.subtract(const Duration(days: 27)),
          now,
        );
  }

  void _applyPreset(String preset) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (preset) {
      case 'Today':
        start = now;
        break;
      case 'Yesterday':
        start = now.subtract(const Duration(days: 1));
        end = start;
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Last 7 Days':
        start = now.subtract(const Duration(days: 6));
        break;
      case 'Last 28 Days':
        start = now.subtract(const Duration(days: 27));
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = now.subtract(const Duration(days: 27));
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
      'Yesterday',
      'This Week',
      'Last 7 Days',
      'Last 28 Days',
      'This Month',
      'Last Month',
      'This Year',
    ];

    return shad.Card(
      padding: EdgeInsets.all(12 * theme.scaling),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Pane: Quick Presets
            SizedBox(
              width: 140 * theme.scaling,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: presets.map((preset) {
                  final isSelected = _activePreset == preset;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2 * theme.scaling),
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

            // Right Pane: Native Calendar
            SizedBox(
              width: 280 * theme.scaling,
              child: shad.Calendar(
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
            ),
          ],
        ),
      ),
    );
  }
}
