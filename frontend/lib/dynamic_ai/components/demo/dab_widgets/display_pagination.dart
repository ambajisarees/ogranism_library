import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Index 0 Pagination widget for Data Action Bar (DAB).
/// Used in Table views; omitted in List views.
class DisplayPagination extends StatelessWidget {
  final int loadedCount;
  final int totalCount;
  final int selectedCount;
  final String entityName;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final double? width;

  const DisplayPagination({
    super.key,
    required this.loadedCount,
    required this.totalCount,
    this.selectedCount = 0,
    this.entityName = 'Cards',
    this.onPrevious,
    this.onNext,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final targetWidth = width ?? 300 * theme.scaling;

    final String textLabel = selectedCount > 0
        ? '$selectedCount of $totalCount Selected'
        : '$loadedCount of $totalCount $entityName';

    return SizedBox(
      width: targetWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Previous Page Button Card
          shad.Button.card(
            style: const shad.ButtonStyle.card()
                .withPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * theme.scaling,
                    vertical: 8 * theme.scaling,
                  ),
                )
                .withBorderRadius(
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
            onPressed: onPrevious,
            child: Icon(
              shad.LucideIcons.chevronLeft,
              size: 16 * theme.scaling,
              color: onPrevious != null ? colors.foreground : colors.mutedForeground,
            ),
          ),

          // Dynamic Info Text in the Middle
          Expanded(
            child: Text(
              textLabel,
              textAlign: TextAlign.center,
              style: theme.typography.textSmall.copyWith(
                fontWeight: selectedCount > 0 ? FontWeight.bold : FontWeight.w500,
                color: selectedCount > 0 ? colors.primary : colors.foreground,
              ),
            ),
          ),

          // Next Page Button Card
          shad.Button.card(
            style: const shad.ButtonStyle.card()
                .withPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * theme.scaling,
                    vertical: 8 * theme.scaling,
                  ),
                )
                .withBorderRadius(
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
            onPressed: onNext,
            child: Icon(
              shad.LucideIcons.chevronRight,
              size: 16 * theme.scaling,
              color: onNext != null ? colors.foreground : colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
