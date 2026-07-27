import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ShowcaseFeedbackStatus extends StatefulWidget {
  const ShowcaseFeedbackStatus({super.key});

  @override
  State<ShowcaseFeedbackStatus> createState() => _ShowcaseFeedbackStatusState();
}

class _ShowcaseFeedbackStatusState extends State<ShowcaseFeedbackStatus> {
  final double _progressVal = 0.65;

  void _triggerSuccessToast(BuildContext context) {
    shad.showToast(
      context: context,
      builder: (context, show) => const shad.Card(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shad.LucideIcons.circleCheck, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('Purchase Order #PO-2026-904 saved successfully.'),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerErrorToast(BuildContext context) {
    shad.showToast(
      context: context,
      builder: (context, show) => const shad.Card(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shad.LucideIcons.circleAlert, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Failed to sync Airbyte mirror view: Network timeout.'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text('Feedback, Badges & Status Indicators', style: theme.typography.h2),
          Text(
            'Alert banners, badge chips, focus-isolated badges (Rule 8), progress bars, skeleton placeholders, and toasts.',
            style: theme.typography.textMuted,
          ),
          const shad.DensityGap(shad.gapLg),

          // 1. Alert Banners
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alert Banner System', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.Alert(
                  title: const Text('Fiscal Year Context Active (FY 26-27)'),
                  content: const Text('All transactions are currently scoped to IMMBE2627 schema with VNO prefix sequence.'),
                  leading: const Icon(shad.LucideIcons.info),
                ),
                const shad.DensityGap(shad.gapMd),
                shad.Alert.destructive(
                  title: const Text('Strict Read-Only Mirror Warning (sq_* Tables)'),
                  content: const Text('Do not mutate sq_* tables directly. Writes must route through Supabase edge functions.'),
                  leading: const Icon(shad.LucideIcons.triangleAlert),
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 2. Badges & Badge Focus Isolation (Rule 8 Compliance)
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Badges & Badge Chip Isolation (Rule 8 Compliance)', style: theme.typography.h3),
                Text(
                  'Badge chips wrapped in Focus(canRequestFocus: false) so focus outlines paint EXCLUSIVELY on outer cards.',
                  style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                ),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 12 * theme.scaling,
                  runSpacing: 12 * theme.scaling,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Badge Chip Isolation Wrappers
                    Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      descendantsAreFocusable: false,
                      child: const shad.PrimaryBadge(child: Text('Primary Status')),
                    ),
                    Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      descendantsAreFocusable: false,
                      child: const shad.SecondaryBadge(child: Text('Secondary Category')),
                    ),
                    Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      descendantsAreFocusable: false,
                      child: const shad.OutlineBadge(child: Text('Outline Neutral')),
                    ),
                    Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      descendantsAreFocusable: false,
                      child: const shad.DestructiveBadge(child: Text('High Priority Alert')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 3. Progress Bars & Loading Skeletons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicators
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress & Loaders', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Text('Batch Progress (${(_progressVal * 100).round()}%)', style: theme.typography.xSmall),
                      const shad.DensityGap(shad.gapSm),
                      shad.Progress(
                        progress: _progressVal,
                      ),
                      const shad.DensityGap(shad.gapLg),
                      Text('Indeterminate Sync Bar', style: theme.typography.xSmall),
                      const shad.DensityGap(shad.gapSm),
                      const shad.Progress(),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // Skeleton Placeholders
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Skeleton Loading States', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.muted,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 140,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: colors.muted,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 200,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colors.muted,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 4. Toast Triggers & Process Timelines
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toast Notifications
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Toast Notification Triggers', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          shad.PrimaryButton(
                            size: shad.ButtonSize.small,
                            onPressed: () => _triggerSuccessToast(context),
                            child: const Text('Trigger Success Toast'),
                          ),
                          shad.DestructiveButton(
                            size: shad.ButtonSize.small,
                            onPressed: () => _triggerErrorToast(context),
                            child: const Text('Trigger Error Toast'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // Vertical Timeline Milestone
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vertical Milestone Timeline', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      _buildTimelineItem(context, '10:00 AM', 'Cutting Batch Created', 'Operator: Rajesh Patel', isFirst: true),
                      _buildTimelineItem(context, '11:30 AM', 'Job Work Dispatched', 'Challan #CH-804', isLast: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String time, String title, String subtitle, {bool isFirst = false, bool isLast = false}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(time, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground, fontWeight: FontWeight.bold)),
        ),
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: colors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
