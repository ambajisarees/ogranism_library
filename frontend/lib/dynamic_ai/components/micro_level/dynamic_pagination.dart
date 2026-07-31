/// LLM NOTE: DynamicPagination
/// - Level: Micro-Control / Footer Layout Component
/// - Role: Standalone surface-less pagination row using native shadcn_flutter Pagination widget.
/// - Widget Composition: Padding -> Row -> [Start: Record/Selection Status Text] + Spacer + [End: Native shad.Pagination].
/// - Specifications:
///   - Surface: Transparent (no background fill or border)
///   - Padding: `EdgeInsets.symmetric(horizontal: 12 * theme.scaling, vertical: 8 * theme.scaling)`
///   - Status Text Typography: `theme.typography.textSmall` (mutedForeground / foreground when selected)
///   - Page Controls: Pure native `shad.Pagination(page: effectivePage, totalPages: totalPages, maxPages: 3)`

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DynamicPagination] - Surface-less pagination row for tables and lists.
/// Placed outside card surfaces with horizontal: 12px and vertical: 8px padding.
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
    this.recordNoun = 'records',
    this.onPageChanged,
    this.customStatusText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // Math for range
    final int totalPages = (totalRecords / pageSize).ceil().clamp(1, 999999);
    final int effectivePage = currentPage.clamp(1, totalPages);
    final int startIdx = totalRecords > 0 ? (effectivePage - 1) * pageSize + 1 : 0;
    final int endIdx = (effectivePage * pageSize).clamp(0, totalRecords);

    // Resolve Status Text
    final String statusLabel = customStatusText ??
        (selectedCount > 0
            ? '$selectedCount $recordNoun selected'
            : 'Showing $startIdx–$endIdx of $totalRecords $recordNoun');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * theme.scaling,
        vertical: 8 * theme.scaling,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // START: Dynamic Status / Record Count Label
          Text(
            statusLabel,
            style: theme.typography.textSmall.copyWith(
              fontWeight: selectedCount > 0 ? FontWeight.w600 : FontWeight.normal,
              color: selectedCount > 0 ? colors.foreground : colors.mutedForeground,
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
