/// LLM NOTE: ReportCard
/// - Level: Page-Level Metric / KPI Card Component
/// - Purpose: Reusable dashboard KPI card featuring large topic icon, title, subtitle, primary metric text, secondary status chip, and active selection border/shadow.
/// - Widget Composition: Focus -> GestureDetector -> Container(BoxDecoration) -> Column(Top Row: Icon + Title + Subtitle + Bottom Row: Metric Text + Status Badge).

library;

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [ReportCard] — Reusable KPI Report Card component with large icon, title,
/// subtitle, bottom metric chips row, and interactive selection state.
class ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryMetric;
  final String? secondaryChipText;
  final bool isSelected;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryMetric,
    this.secondaryChipText,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final borderColor = isSelected ? colors.primary : colors.border;
    final borderWidth = isSelected ? 1.5 : 1.0;
    final bgTint = isSelected ? colors.primary.withAlpha(12) : colors.card;

    return Focus(
      focusNode: FocusNode(skipTraversal: true),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: EdgeInsets.all(14 * theme.scaling),
            decoration: BoxDecoration(
              color: bgTint,
              borderRadius: BorderRadius.circular(theme.radiusMd),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.primary.withAlpha(25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Top Row: Icon + Title & Subtitle + Selection Indicator ─────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8 * theme.scaling),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withAlpha(30)
                            : colors.muted.withAlpha(40),
                        borderRadius: BorderRadius.circular(theme.radiusSm),
                      ),
                      child: Icon(
                        icon,
                        size: 20 * theme.scaling,
                        color: isSelected ? colors.primary : colors.foreground,
                      ),
                    ),
                    SizedBox(width: 10 * theme.scaling),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.typography.textSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.foreground,
                            ),
                          ),
                          SizedBox(height: 2 * theme.scaling),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.xSmall.copyWith(
                              color: colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 4 * theme.scaling),
                      Container(
                        width: 8 * theme.scaling,
                        height: 8 * theme.scaling,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 12 * theme.scaling),

                // ── Bottom Metric Chip Row ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      primaryMetric,
                      style: theme.typography.mono.copyWith(
                        fontSize: 16 * theme.scaling,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? colors.primary : colors.foreground,
                      ),
                    ),
                    const Spacer(),
                    if (secondaryChipText != null) ...[
                      shad.SecondaryBadge(
                        child: Text(
                          secondaryChipText!,
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
