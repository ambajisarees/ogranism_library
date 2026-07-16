import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellSlider] — Horizontal dragging track atom.
///
/// Bounded to the primary theme accent. Supports custom range [min]/[max] 
/// and precision value [onChanged] selection.

/// A standard horizontal slider track.
class CellSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const CellSlider({
    super.key,
    this.value = 0,
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.trackInactive,
        thumbColor: colors.primary,
        overlayColor: colors.primaryLight.withValues(alpha: 0.5),
        trackHeight: 4.0,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}
