/// LLM NOTE: DyTableFooter Refined
/// - Level: Core Table Footer Component
/// - Specs:
///   - Outer padding `horizontal: 8 * theme.scaling` matching header
///   - Data cells: exact 6px horizontal padding matching header
///   - Background: Crisp `colors.card` surface (crisp white)

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'dy_table_models.dart';
import '../../specs/dy_color_system.dart';

class DyTableFooter extends StatelessWidget {
  final List<DyTableColumnSpec> columns;
  final Map<String, String> summaryTotals;

  const DyTableFooter({
    super.key,
    required this.columns,
    required this.summaryTotals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    return Container(
      height: 54 * theme.scaling,
      decoration: BoxDecoration(
        color: DyColorSystem.resolveSurfaceCanvas(isDark),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(theme.radiusMd)),
        border: Border(
          top: BorderSide(color: colors.border, width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Flex 1 (Col 0): Kept BLANK
          SizedBox(width: 54 * theme.scaling),
          const SizedBox(width: 8),

          // Column Summary Totals (No leading icons, 6px horizontal cell padding)
          ...columns.map((col) {
            final val = summaryTotals[col.key] ?? '';

            final textStyle = theme.typography.textSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.foreground,
              fontFamily: col.isNumeric ? 'monospace' : null,
            );

            return Expanded(
              flex: col.flex,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6 * theme.scaling),
                alignment: col.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  val,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
            );
          }),

          // Flex Last (Col Last): Synchronized 72px blank space
          SizedBox(width: 72 * theme.scaling),
        ],
      ),
    );
  }
}
