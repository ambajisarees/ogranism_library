import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../plasma/popover.dart'; // Direct import from plasma submodule
import 'calendar.dart'; // Direct import for CellCalendar
import 'spatial.dart';   // Direct import for CellGap

/// [CellDatePicker] — Inline atomic date picker popover.
///
/// Wraps a [CellCalendar] in a [PlasmaPopover], designed for high-density 
/// grid cells or compact form rows.

/// Compact inline atomic date picker bounds specifically designed for grid cells.
class CellDatePicker extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool isCompact;

  const CellDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.isCompact = true, // Defaults to true since its an atomic primitive intended for grids
  });

  @override
  State<CellDatePicker> createState() => _CellDatePickerState();
}

class _CellDatePickerState extends State<CellDatePicker> {
  final GlobalKey<PlasmaPopoverState> _popoverKey = GlobalKey<PlasmaPopoverState>();

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final dateStr = widget.value != null 
        ? "${widget.value!.day.toString().padLeft(2, '0')}/${widget.value!.month.toString().padLeft(2, '0')}/${widget.value!.year}"
        : 'Select date';

    final height = widget.isCompact ? OrganismTheme.buttonHeightCompact : OrganismTheme.buttonHeightStandard;

    return PlasmaPopover(
      key: _popoverKey,
      trigger: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: OrganismTheme.borderSm,
          border: Border.all(color: colors.border),
        ),
        child: CellPad(
          horizontalMultiplier: 1.0,
          verticalMultiplier: 0.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  dateStr,
                  overflow: TextOverflow.ellipsis,
                  style: (widget.isCompact ? OrganismTheme.bodySmall(context) : OrganismTheme.bodyLarge(context)).copyWith(
                    color: widget.value != null ? colors.textPrimary : colors.textMuted,
                  ),
                ),
              ),
              const CellGap(1.0),
              Icon(
                LucideIcons.calendar,
                size: widget.isCompact ? OrganismTheme.iconSizeSm : OrganismTheme.iconSizeMd,
                color: OrganismTheme.iconSecondary(context),
              ),
            ],
          ),
        ),
      ),
      content: CellCalendar(
        value: widget.value,
        onDateSelected: (date) {
          widget.onChanged(date);
          _popoverKey.currentState?.close();
        },
      ),
    );
  }
}
