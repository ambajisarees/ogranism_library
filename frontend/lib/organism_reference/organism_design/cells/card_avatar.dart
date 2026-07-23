import 'package:flutter/material.dart';
import '../theme.dart';

enum CellCardAvatarSize { small, medium }

/// [CellCardAvatar] — A signature date/identity capsule.
///
/// Implements the "12-Month Color Logic" where the theme shifts based on the month (1-12).
/// Used in registries to provide immediate temporal context.
class CellCardAvatar extends StatelessWidget {
  final DateTime date;
  final double? size;
  final CellCardAvatarSize sizeVariant;

  const CellCardAvatar({
    super.key,
    required this.date,
    this.size,
    this.sizeVariant = CellCardAvatarSize.small,
  });

  static const List<String> _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  @override
  Widget build(BuildContext context) {
    final monthColor = _getMonthColor(context, date.month);
    
    // Resolve final container dimensions
    final actualSize = size ?? (sizeVariant == CellCardAvatarSize.medium ? 44.0 : 40.0);
    
    // Day string: 01, 02, ..., 31
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = _months[date.month - 1];

    final dayFontSize = actualSize >= 44.0 ? 15.0 : 13.0;
    final monthFontSize = actualSize >= 44.0 ? 9.0 : 8.0;

    return Container(
      width: actualSize,
      height: actualSize,
      decoration: BoxDecoration(
        color: monthColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(OrganismTheme.radiusMd),
        border: Border.all(
          color: monthColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayStr,
            style: TextStyle(
              color: monthColor,
              fontWeight: FontWeight.w800,
              fontSize: dayFontSize,
              height: 1.0,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          const SizedBox(height: 1),
          Text(
            monthStr,
            style: TextStyle(
              color: monthColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              fontSize: monthFontSize,
              height: 1.0,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }

  Color _getMonthColor(BuildContext context, int month) {
    final colors = OrganismTheme.colorsOf(context);
    switch (month) {
      case 1: return colors.chart1;
      case 2: return colors.chart2;
      case 3: return colors.chart3;
      case 4: return colors.chart4;
      case 5: return colors.chart5;
      case 6: return colors.chart6;
      case 7: return colors.chart7;
      case 8: return colors.chart8;
      case 9: return colors.chart9;
      case 10: return colors.chart10;
      case 11: return colors.chart11;
      case 12: return colors.chart12;
      default: return colors.primary;
    }
  }
}
