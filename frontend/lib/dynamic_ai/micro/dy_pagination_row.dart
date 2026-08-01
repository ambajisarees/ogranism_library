/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC PAGINATION ROW (dy_pagination_row.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Standalone surface-less pagination row for tables (DyTablePane) and cards (DyCardPane).
   - Renders record selection/range status text on the left and native `shad.Pagination` on the right.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Displays "Showing X - X of X Records" or "Selected X • Showing X - X of X Records".
   - Spacing: Exactly 1 space before and after dash (" - ").
   - Typography: Rendered in `colors.foreground` in both normal and selected states.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DynamicPagination] — Surface-less pagination row for tables and card grids.
class DynamicPagination extends StatelessWidget {
  final int totalRecords;
  final int currentPage;
  final int pageSize;
  final int selectedCount;
  final String recordNoun;
  final ValueChanged<int>? onPageChanged;
  final String? customStatusText;

  const DynamicPagination({
    super.key,
    required this.totalRecords,
    required this.currentPage,
    this.pageSize = 50,
    this.selectedCount = 0,
    this.recordNoun = 'Records',
    this.onPageChanged,
    this.customStatusText,
  });

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // Range Math
    final int totalPages = (totalRecords / pageSize).ceil().clamp(1, 999999);
    final int effectivePage = currentPage.clamp(1, totalPages);
    final int startIdx = totalRecords > 0 ? (effectivePage - 1) * pageSize + 1 : 0;
    final int endIdx = (effectivePage * pageSize).clamp(0, totalRecords);

    final String startStr = _formatNumber(startIdx);
    final String endStr = _formatNumber(endIdx);
    final String totalStr = _formatNumber(totalRecords);

    final String nounStr = recordNoun.isNotEmpty
        ? '${recordNoun[0].toUpperCase()}${recordNoun.substring(1)}'
        : 'Records';

    // Resolve Status Text
    final String rangeText = 'Showing $startStr - $endStr of $totalStr $nounStr';
    final String statusLabel = customStatusText ??
        (selectedCount > 0 ? 'Selected $selectedCount • $rangeText' : rangeText);

    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // START: Dynamic Status / Record Count Label (Always colors.foreground)
          Text(
            statusLabel,
            style: theme.typography.textSmall.copyWith(
              fontWeight: selectedCount > 0 ? FontWeight.w600 : FontWeight.w500,
              color: colors.foreground,
            ),
          ),

          const Spacer(),

          // END: Pure Native shadcn_flutter Pagination Component
          shad.Pagination(
            page: effectivePage,
            totalPages: totalPages,
            maxPages: 3,
            onPageChanged: (val) => onPageChanged?.call(val),
          ),
        ],
      ),
    );
  }
}

typedef DyPaginationRow = DynamicPagination;
