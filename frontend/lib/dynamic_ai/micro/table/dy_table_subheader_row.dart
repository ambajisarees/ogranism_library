/// LLM NOTE: DyTableSubheaderRow
/// - Level: Core Table Row Component
/// - Specs:
///   - Col 0 width: exact 54px (* theme.scaling) matching parent table header & default row Col 0 slot
///   - Label typography: uppercase, mutedForeground, xSmall font size matching DyTableHeader
///   - Divider: 70px left offset (8px pad + 54px slot + 8px gap) spanning 100% to far right edge

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'dy_table_models.dart';
import '../../specs/dy_color_system.dart';

class DyTableSubheaderRow extends StatelessWidget {
  final List<DyTableColumnSpec> columns;

  const DyTableSubheaderRow({
    super.key,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    final headerBg = DyColorSystem.resolveSurfaceCanvas(isDark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Subheader Data Bar
        Container(
          height: 36 * theme.scaling,
          color: headerBg,
          padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Col 0: Synchronized 54px width slot matching DyTableHeader & DyTableDefRow
              SizedBox(width: 54 * theme.scaling),

              const SizedBox(width: 8),

              // Data Column Labels (Fullcaps xSmall mutedForeground matching DyTableHeader)
              ...columns.map((col) {
                final textStyle = theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.mutedForeground,
                  letterSpacing: 0.5,
                );

                return Expanded(
                  flex: col.flex,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * theme.scaling),
                    alignment: col.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      col.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ),
                );
              }),

              // Col Last: Synchronized 72px blank space matching parent trailing column slot
              SizedBox(
                width: 72 * theme.scaling,
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // Bottom 1px Divider (70px left offset = 8px pad + 54px slot + 8px gap, spanning 100% to far right edge)
        Row(
          children: [
            SizedBox(width: 70 * theme.scaling),
            Expanded(
              child: Container(
                height: 1.0,
                color: colors.border,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
