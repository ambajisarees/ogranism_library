import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../plasma/popover.dart';
import 'spatial.dart';
import 'input.dart';

class CellTimePicker extends StatefulWidget {
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final bool isCompact;

  const CellTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.isCompact = true,
  });

  @override
  State<CellTimePicker> createState() => _CellTimePickerState();
}

class _CellTimePickerState extends State<CellTimePicker> {
  @override
  Widget build(BuildContext context) {
    final timeStr = widget.value != null 
        ? "${widget.value!.hourOfPeriod == 0 ? 12 : widget.value!.hourOfPeriod.toString().padLeft(2, '0')}:${widget.value!.minute.toString().padLeft(2, '0')} ${widget.value!.period == DayPeriod.am ? 'AM' : 'PM'}"
        : 'Select time';

    final height = widget.isCompact ? OrganismTheme.buttonHeightCompact : OrganismTheme.buttonHeightStandard;
    final colors = OrganismTheme.colorsOf(context);

    return PlasmaPopover(
      explicitWidth: 260,
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
                  timeStr,
                  overflow: TextOverflow.ellipsis,
                  style: (widget.isCompact ? OrganismTheme.bodySmall(context) : OrganismTheme.bodyLarge(context)).copyWith(
                    color: widget.value != null ? colors.textPrimary : colors.textMuted,
                  ),
                ),
              ),
              const CellGap(1.0),
              Icon(
                LucideIcons.clock,
                size: widget.isCompact ? OrganismTheme.iconSizeSm : OrganismTheme.iconSizeMd,
                color: OrganismTheme.iconSecondary(context),
              ),
            ],
          ),
        ),
      ),
      content: _ShadcnTimeSelector(
        initialValue: widget.value ?? TimeOfDay.now(),
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _ShadcnTimeSelector extends StatefulWidget {
  final TimeOfDay initialValue;
  final ValueChanged<TimeOfDay> onChanged;

  const _ShadcnTimeSelector({required this.initialValue, required this.onChanged});

  @override
  State<_ShadcnTimeSelector> createState() => _ShadcnTimeSelectorState();
}

class _ShadcnTimeSelectorState extends State<_ShadcnTimeSelector> {
  late TextEditingController _hourCtrl;
  late TextEditingController _minCtrl;
  late DayPeriod _period;

  @override
  void initState() {
    super.initState();
    _hourCtrl = TextEditingController(text: (widget.initialValue.hourOfPeriod == 0 ? 12 : widget.initialValue.hourOfPeriod).toString().padLeft(2, '0'));
    _minCtrl = TextEditingController(text: widget.initialValue.minute.toString().padLeft(2, '0'));
    _period = widget.initialValue.period;
  }

  void _commit() {
    int h = int.tryParse(_hourCtrl.text) ?? 12;
    int m = int.tryParse(_minCtrl.text) ?? 0;
    
    // Bounds limit
    if (h > 12) h = 12;
    if (h < 1) h = 1;
    if (m > 59) m = 59;
    if (m < 0) m = 0;

    _hourCtrl.text = h.toString().padLeft(2, '0');
    _minCtrl.text = m.toString().padLeft(2, '0');

    int finalHour = h;
    if (_period == DayPeriod.pm && h != 12) finalHour += 12;
    if (_period == DayPeriod.am && h == 12) finalHour = 0;

    widget.onChanged(TimeOfDay(hour: finalHour, minute: m));
  }

  Widget _buildInput(BuildContext context, OrganismColors colors, String label, TextEditingController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            border: Border.all(color: colors.border),
            borderRadius: OrganismTheme.borderSm,
          ),
          child: Center(
            child: CellInput(
              controller: controller,
              isNaked: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
              textStyle: OrganismTheme.displayLarge(context).copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              onSubmitted: (_) => _commit(),
              // CellInput handles focus change logic internally but we still want _commit on outside tap
            ),
          ),
        ),
        const CellGap(0.25),
        Text(label, style: OrganismTheme.bodySmall(context).copyWith(color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildPeriodToggle(OrganismColors colors) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        border: Border.all(color: colors.border),
        borderRadius: OrganismTheme.borderSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton(colors, DayPeriod.am, 'AM'),
          Container(height: 1, color: colors.border),
          _buildPeriodButton(colors, DayPeriod.pm, 'PM'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(OrganismColors colors, DayPeriod periodTarget, String label) {
    final isSelected = _period == periodTarget;
    return GestureDetector(
      onTap: () {
        setState(() => _period = periodTarget);
        _commit();
      },
      child: Container(
        height: 39,
        color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colors.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Padding(
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInput(context, colors, 'Hour', _hourCtrl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(':', style: OrganismTheme.displayLarge(context).copyWith(
              fontWeight: FontWeight.normal,
              color: colors.textSecondary,
            )),
          ),
          _buildInput(context, colors, 'Minute', _minCtrl),
          const CellGap(1.5),
          _buildPeriodToggle(colors),
        ],
      ),
    );
  }
}
