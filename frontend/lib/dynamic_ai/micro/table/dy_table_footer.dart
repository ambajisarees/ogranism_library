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

    return Container(
      height: 36 * theme.scaling,
      decoration: BoxDecoration(
        color: colors.card, // Crisp white header token
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(theme.radiusMd)),
        border: Border(
          top: BorderSide(color: colors.border, width: 1.5),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8 * theme.scaling),
      child: Row(
        children: [
          // Flex 1 (Col 0): Kept BLANK
          SizedBox(width: 54 * theme.scaling),
          const SizedBox(width: 8),

          // Column Totals
          ...columns.asMap().entries.map((entry) {
            final index = entry.key;
            final col = entry.value;

            // Render label "TOTALS" at Column 2 (Master / Party column index 1 or 2)
            String val = summaryTotals[col.key] ?? '';
            if (index == 1 && val.isEmpty) {
              val = 'TOTALS';
            }

            final isTotalsLabel = val.toUpperCase() == 'TOTALS';

            final textStyle = theme.typography.textSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.foreground,
              fontFamily: (col.isNumeric && !isTotalsLabel) ? 'monospace' : null,
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

          // Flex Last (Col Last): Kept BLANK
          SizedBox(width: 40 * theme.scaling),
        ],
      ),
    );
  }
}
