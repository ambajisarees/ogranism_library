import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';

class DatePreset {
  final String label;
  final DateTimeRange Function() getRange;

  const DatePreset({required this.label, required this.getRange});
}

/// [TissueDateRangeField] — Custom range selector mapped to ERP reporting
class TissueDateRangeField extends StatefulWidget {
  final String label;
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;
  final List<DatePreset> presets;

  const TissueDateRangeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.presets,
  });

  @override
  State<TissueDateRangeField> createState() => _TissueDateRangeFieldState();
}

class _TissueDateRangeFieldState extends State<TissueDateRangeField> {
  Future<void> _openPicker() async {
    final colors = OrganismTheme.colorsOf(context);

    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 700,
            height: 500,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: OrganismTheme.borderLg,
              border: Border.all(color: colors.border),
              boxShadow: OrganismTheme.shadowLg,
            ),
            child: Row(
              children: [
                // Presets Panel
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingMd),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: colors.border)),
                    color: colors.surfaceSubtle,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingLg),
                        child: Text('Presets', style: OrganismTheme.labelLarge(context)),
                      ),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      ...widget.presets.map((preset) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop(preset.getRange());
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: OrganismTheme.spacingLg,
                              vertical: OrganismTheme.spacingMd,
                            ),
                            child: Text(preset.label, style: OrganismTheme.bodyLarge(context)),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                // Native Picker Override
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: colors.primary,
                          onPrimary: Colors.white,
                          surface: colors.surface,
                          onSurface: colors.textPrimary,
                        ),
                      ),
                      child: DateRangePickerDialog(
                        initialDateRange: widget.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    String display = 'Select Date Range';
    if (widget.value != null) {
      final start = widget.value!.start.toLocal().toString().split(' ')[0];
      final end = widget.value!.end.toLocal().toString().split(' ')[0];
      display = '$start   →   $end';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CellLabel(text: widget.label, isRequired: false),
        CellGap.small,
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _openPicker,
            child: Container(
              height: OrganismTheme.buttonHeightStandard,
              padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
              decoration: BoxDecoration(
                color: colors.inputBackground,
                borderRadius: OrganismTheme.borderSm,
                border: Border.all(color: colors.inputBorder),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.calendar, size: 16, color: colors.textMuted),
                  CellGap.small,
                  Expanded(
                    child: Text(
                      display,
                      style: OrganismTheme.bodyLarge(context).copyWith(
                        color: widget.value == null ? colors.textMuted : colors.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.value != null)
                    GestureDetector(
                      onTap: () => widget.onChanged(null),
                      child: Icon(LucideIcons.x, size: 16, color: colors.textMuted),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
