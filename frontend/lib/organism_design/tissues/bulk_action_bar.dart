import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart';

class TissueBulkActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClear;
  final List<Widget> actions;

  const TissueBulkActionBar({
    super.key,
    required this.selectedCount,
    required this.onClear,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    final colors = OrganismTheme.colorsOf(context);

    // Floating centered pill
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(bottom: OrganismTheme.spacingXl),
          padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingLg, vertical: OrganismTheme.spacingSm),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: OrganismTheme.borderPill,
            border: Border.all(color: colors.border),
            boxShadow: OrganismTheme.shadowLg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingSm, vertical: OrganismTheme.spacingXs),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: OrganismTheme.borderPill,
                ),
                child: Text(
                  '$selectedCount',
                  style: OrganismTheme.bodySmall(context).copyWith(
                    color: colors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CellGap.small,
              Text('Selected', style: OrganismTheme.bodyMedium(context).copyWith(color: colors.textPrimary, fontWeight: FontWeight.w500)),
              const CellGap(1.5),
              Container(width: 1, height: 20, color: colors.border),
              const CellGap(1.5),
              ...actions,
              const CellGap(1.0),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'Clear',
                  style: OrganismTheme.bodySmall(context).copyWith(
                    color: colors.textMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
