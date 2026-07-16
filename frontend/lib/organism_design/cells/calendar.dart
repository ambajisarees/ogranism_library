import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'spatial.dart';

/// [CellCalendar] — High-density month-grid calendar widget.
///
/// A standalone date picker engine used by [CellDatePicker] and other time-based
/// organisms. Handles month navigation and date selection physics.


/// Private high-density calendar grid.
class CellCalendar extends StatefulWidget {
  final DateTime? value;
  final DateTime? initialViewMonth;
  final ValueChanged<DateTime> onDateSelected;

  const CellCalendar({
    super.key,
    this.value,
    this.initialViewMonth,
    required this.onDateSelected,
  });

  @override
  State<CellCalendar> createState() => _CellCalendarState();
}

class _CellCalendarState extends State<CellCalendar> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    final start = widget.value ?? widget.initialViewMonth ?? DateTime.now();
    _viewMonth = DateTime(start.year, start.month);
  }

  @override
  void didUpdateWidget(CellCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      setState(() {
        _viewMonth = DateTime(widget.value!.year, widget.value!.month);
      });
    }
  }

  void _prevMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1));
  void _nextMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final daysInMonth = DateUtils.getDaysInMonth(_viewMonth.year, _viewMonth.month);
    final firstDayOffset = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    
    final monthName = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_viewMonth.month - 1];

    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(LucideIcons.chevronLeft, size: OrganismTheme.iconSizeMd, color: colors.textPrimary),
                onPressed: _prevMonth,
              ),
              Text('$monthName ${_viewMonth.year}', style: OrganismTheme.labelLarge(context).copyWith(color: colors.textPrimary)),
              IconButton(
                icon: Icon(LucideIcons.chevronRight, size: OrganismTheme.iconSizeMd, color: colors.textPrimary),
                onPressed: _nextMonth,
              ),
            ],
          ),
          CellGap.standard,
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Center(child: Text(d, style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted))))
                .toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox.shrink();
              final day = index - firstDayOffset + 1;
              final date = DateTime(_viewMonth.year, _viewMonth.month, day);
              final isSelected = widget.value != null && DateUtils.isSameDay(date, widget.value!);
              
              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : Colors.transparent,
                    borderRadius: OrganismTheme.borderSm,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: OrganismTheme.bodySmall(context).copyWith(
                        color: isSelected ? Colors.white : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
