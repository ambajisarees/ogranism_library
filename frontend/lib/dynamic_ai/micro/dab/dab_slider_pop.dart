/// LLM NOTE: DabSliderPopover
/// - Level: DAB Popover Component
/// - Purpose: Min/Max numeric range slider filter popover for DynamicActionBar with 200px width.
/// - Widget Composition: shad.Card -> Column(2 rows of 36px height each: Start & End range inputs/sliders).

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../specs/dy_grid_system.dart';

/// Range Slider / Numeric Min-Max Filter Popover following standard DAB popover specs:
/// - Width: `DyGridSystem.popWidthStandard` (200px)
/// - Corner Radius: 8px, Inner Card Padding: 8px
/// - Two rows of 36px height each: Start range row & End range row
class DabSliderPopover extends StatefulWidget {
  final String title;
  final double min;
  final double max;
  final double startValue;
  final double endValue;
  final Function(double start, double end) onChanged;

  const DabSliderPopover({
    super.key,
    this.title = 'Range',
    this.min = 0.0,
    this.max = 1000.0,
    required this.startValue,
    required this.endValue,
    required this.onChanged,
  });

  @override
  State<DabSliderPopover> createState() => _DabSliderPopoverState();
}

class _DabSliderPopoverState extends State<DabSliderPopover> {
  late double _currentStart;
  late double _currentEnd;

  @override
  void initState() {
    super.initState();
    _currentStart = widget.startValue;
    _currentEnd = widget.endValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.Card(
      padding: EdgeInsets.all(8 * theme.scaling),
      child: SizedBox(
        width: DyGridSystem.popWidthStandard * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Start Range (36px height)
            SizedBox(
              height: 36 * theme.scaling,
              child: Row(
                children: [
                  Text(
                    'Start',
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  const Spacer(),
                  shad.SecondaryBadge(
                    child: Text(
                      _currentStart.toInt().toString(),
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Start Slider
            shad.Slider(
              value: shad.SliderValue.single(_currentStart),
              min: widget.min,
              max: widget.max,
              onChanged: (val) {
                setState(() {
                  _currentStart = val.value.clamp(widget.min, _currentEnd);
                });
                widget.onChanged(_currentStart, _currentEnd);
              },
            ),

            const shad.DensityGap(shad.gapSm),

            // Row 2: End Range (36px height)
            SizedBox(
              height: 36 * theme.scaling,
              child: Row(
                children: [
                  Text(
                    'End',
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  const Spacer(),
                  shad.SecondaryBadge(
                    child: Text(
                      _currentEnd.toInt().toString(),
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // End Slider
            shad.Slider(
              value: shad.SliderValue.single(_currentEnd),
              min: widget.min,
              max: widget.max,
              onChanged: (val) {
                setState(() {
                  _currentEnd = val.value.clamp(_currentStart, widget.max);
                });
                widget.onChanged(_currentStart, _currentEnd);
              },
            ),
          ],
        ),
      ),
    );
  }
}
