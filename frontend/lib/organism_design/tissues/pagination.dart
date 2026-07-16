import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/button.dart';
import '../cells/multi_button.dart';
import '../cells/spatial.dart';
import '../cells/input.dart';

/// [TissuePagination] — High-density consolidated registry control bar.
///
/// Implements a unified full-width bar containing range-based record status, 
/// navigation arrows, and action buttons. 
class TissuePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final ValueChanged<int> onPageChanged;

  const TissuePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    // Calculate range: e.g., 1-50 of 1248
    final int start = totalCount == 0 ? 0 : (currentPage - 1) * limit + 1;
    final int end = math.min(currentPage * limit, totalCount);

    return Container(
      height: 48.0,
      padding: const EdgeInsets.all(OrganismTheme.spacingSm).copyWith(
        left: OrganismTheme.spacingMd,
        right: OrganismTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
           bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 1. Labeling
          Text(
            'Page',
            style: OrganismTheme.labelMedium(context).copyWith(color: colors.textSecondary),
          ),
          const SizedBox(width: OrganismTheme.spacingXs),
          
          SizedBox(
            width: 54,
            child: CellInput(
              initialValue: currentPage.toString(),
              isNumeric: true,
              isCompact: true,
              textAlign: TextAlign.center,
              onSubmitted: (val) {
                final page = int.tryParse(val);
                if (page != null && page > 0 && page <= totalPages) {
                  onPageChanged(page);
                }
              },
              textStyle: OrganismTheme.labelMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: OrganismTheme.spacingXs),
          Text(
            'of $totalPages',
            style: OrganismTheme.labelMedium(context).copyWith(color: colors.textSecondary),
          ),
          
          const SizedBox(width: OrganismTheme.spacingMd),

          // 2. Navigation Actions
          CellButton(
            icon: LucideIcons.chevronLeft,
            variant: CellButtonVariant.input,
            isCompact: true,
            onPressed: currentPage <= 1 ? null : () => onPageChanged(currentPage - 1),
          ),
          const SizedBox(width: OrganismTheme.spacingXs),
          CellButton(
            icon: LucideIcons.chevronRight,
            variant: CellButtonVariant.input,
            isCompact: true,
            onPressed: currentPage >= totalPages ? null : () => onPageChanged(currentPage + 1),
          ),

          const Spacer(),

          // 2. Status
          Text(
            '$totalCount records',
            style: OrganismTheme.labelMedium(context).copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
