import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/calendar.dart'; // Direct import for CellCalendar
import '../cells/label.dart';    // Direct import for CellLabel
import '../cells/spatial.dart';  // Direct import for CellGap/CellPad
import '../plasma/popover.dart'; // Direct import for PlasmaPopover

/// [TissueDateField] — Anchored date selector molecule.
///
/// Implements a high-density [Shadcn]-style date field. Combines a 
/// trigger button, [CellLabel], and [PlasmaPopover] anchored calendar.

/// A High-Density Shadcn-style DateField.
/// Uses PlasmaPopover to anchor a calendar grid under a form label.
class TissueDateField extends StatefulWidget {
  final DateTime? value;
  final String label;
  final ValueChanged<DateTime> onChanged;

  const TissueDateField({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  State<TissueDateField> createState() => _TissueDateFieldState();
}

class _TissueDateFieldState extends State<TissueDateField> {
  final GlobalKey<PlasmaPopoverState> _popoverKey = GlobalKey<PlasmaPopoverState>();

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final dateStr = widget.value != null 
        ? "${widget.value!.day.toString().padLeft(2, '0')}/${widget.value!.month.toString().padLeft(2, '0')}/${widget.value!.year}"
        : 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CellLabel(text: widget.label),
        CellGap.small,
        PlasmaPopover(
          key: _popoverKey,
          explicitWidth: 320,
          trigger: Container(
            height: OrganismTheme.buttonHeightStandard,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: OrganismTheme.borderSm,
              border: Border.all(color: colors.border),
            ),
            child: CellPad(
              horizontalMultiplier: 1.0,
              verticalMultiplier: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      dateStr,
                      overflow: TextOverflow.ellipsis,
                      style: OrganismTheme.bodyLarge(context).copyWith(
                        color: widget.value != null ? colors.textPrimary : colors.textMuted,
                      ),
                    ),
                  ),
                Icon(
                  LucideIcons.calendar,
                  size: OrganismTheme.iconSizeSm,
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
        ),
      ],
    );
  }
}
