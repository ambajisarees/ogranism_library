import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../cells.dart';

/// [DomainCuttingTimeline] — Horizontal 6-stage production tracking visualizer for Cutting batches.
/// Stages: Grey Purchase → Print Program → Stock Received → Batch Cut → Job Issued → Job Received
class DomainCuttingTimeline extends StatelessWidget {
  final Map<String, DateTime?> stageDates;

  const DomainCuttingTimeline({
    super.key,
    required this.stageDates,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    // Standard 6 stages definition
    final List<Map<String, dynamic>> stages = [
      {
        'key': 'grey_purchase',
        'label': 'Grey Purchase',
        'icon': LucideIcons.shoppingBag,
      },
      {
        'key': 'print_program',
        'label': 'Print Program',
        'icon': LucideIcons.palette,
      },
      {
        'key': 'stock_received',
        'label': 'Stock Received',
        'icon': LucideIcons.archive,
      },
      {
        'key': 'batch_cut',
        'label': 'Batch Cut',
        'icon': LucideIcons.scissors,
      },
      {
        'key': 'job_issued',
        'label': 'Job Issued',
        'icon': LucideIcons.arrowUpRight,
      },
      {
        'key': 'job_received',
        'label': 'Job Received',
        'icon': LucideIcons.arrowDownLeft,
      },
    ];

    // Determine completion states
    bool printCompleted = stageDates['print_program'] != null;
    bool stockReceivedCompleted = stageDates['stock_received'] != null;
    bool batchCutCompleted = stageDates['batch_cut'] != null;
    bool jobIssuedCompleted = stageDates['job_issued'] != null;
    bool jobReceivedCompleted = stageDates['job_received'] != null;

    // Helper to format date nicely
    String formatDate(DateTime? dt) {
      if (dt == null) return '—';
      return DateFormat('dd MMMM').format(dt);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Horizontal Connector Line Running behind the boxes
            Positioned(
              left: 40,
              right: 40,
              top: 36, // Centered vertically relative to the box node
              child: Container(
                height: 2,
                color: colors.border,
              ),
            ),
            
            // Nodes row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(stages.length, (index) {
                final stage = stages[index];
                final key = stage['key'] as String;
                final label = stage['label'] as String;
                final icon = stage['icon'] as IconData;
                final date = stageDates[key];

                bool isCompleted = date != null;
                // Special checks to make the visual flow logical:
                if (key == 'print_program') {
                  isCompleted = printCompleted || stockReceivedCompleted || batchCutCompleted;
                } else if (key == 'grey_purchase') {
                  isCompleted = date != null || stockReceivedCompleted || batchCutCompleted;
                }

                // If not happened yet, use standard grey/muted outline style
                Color nodeBgColor = colors.surface;
                Color nodeBorderColor = colors.border;
                Color iconColor = colors.textMuted;
                Color labelColor = colors.textSecondary;

                if (isCompleted) {
                  // Solid style for completed lifecycles
                  nodeBgColor = colors.primary;
                  nodeBorderColor = colors.primary;
                  iconColor = colors.surface;
                  labelColor = colors.textPrimary;
                }

                // Highlight the active stage with a distinct indicator or glow if needed
                bool isCurrentActive = false;
                if (key == 'job_received' && jobReceivedCompleted) {
                  isCurrentActive = true;
                } else if (key == 'job_issued' && jobIssuedCompleted && !jobReceivedCompleted) {
                  isCurrentActive = true;
                } else if (key == 'batch_cut' && batchCutCompleted && !jobIssuedCompleted) {
                  isCurrentActive = true;
                } else if (key == 'stock_received' && stockReceivedCompleted && !batchCutCompleted) {
                  isCurrentActive = true;
                }

                if (isCurrentActive) {
                  nodeBgColor = colors.primary;
                  nodeBorderColor = colors.primaryDark;
                  iconColor = colors.surface;
                }

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date Above
                      Text(
                        formatDate(date),
                        style: OrganismTheme.monoLabel(context).copyWith(
                          fontSize: 10,
                          fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                          color: date != null ? colors.textPrimary : colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Rounded Box Node
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: nodeBgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: nodeBorderColor,
                            width: isCurrentActive ? 2.5 : 1.5,
                          ),
                          boxShadow: isCurrentActive ? OrganismTheme.shadowSm : null,
                        ),
                        child: Icon(
                          icon,
                          size: 16,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title Below (Larger font style)
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: OrganismTheme.bodyMedium(context).copyWith(
                          fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
