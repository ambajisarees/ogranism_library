import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseNotesTasks extends StatefulWidget {
  const PageShowcaseNotesTasks({super.key});

  @override
  State<PageShowcaseNotesTasks> createState() => _PageShowcaseNotesTasksState();
}

class _PageShowcaseNotesTasksState extends State<PageShowcaseNotesTasks> {
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Verify Airbyte schema IMMBE2627 sync logs', 'done': true, 'priority': 'HIGH'},
    {'title': 'Approve dye pigment recipe for Lot #D-2049', 'done': true, 'priority': 'MEDIUM'},
    {'title': 'Send PDF catalog to Ambaji Traders on WhatsApp', 'done': false, 'priority': 'HIGH'},
    {'title': 'Schedule loom maintenance unit #02', 'done': false, 'priority': 'LOW'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mill Operations Notes & Task Checklist', style: theme.typography.h2),
                  Text('Sticky notes board, pending shift tasks, priority tags, and reminders.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.plus, size: 16),
                    SizedBox(width: 8),
                    Text('New Task Note'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Task Checklist
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shift Task Checklist', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                ...List.generate(_tasks.length, (index) {
                  final t = _tasks[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          shad.Checkbox(
                            state: t['done'] ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
                            onChanged: (s) => setState(() => t['done'] = s == shad.CheckboxState.checked),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t['title'],
                              style: theme.typography.textSmall.copyWith(
                                decoration: t['done'] ? TextDecoration.lineThrough : null,
                                color: t['done'] ? colors.mutedForeground : null,
                              ),
                            ),
                          ),
                          _buildPriorityBadge(t['priority']),
                        ],
                      ),
                      if (index < _tasks.length - 1) const shad.Divider(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String p) {
    switch (p) {
      case 'HIGH':
        return const shad.DestructiveBadge(child: Text('High Priority'));
      case 'MEDIUM':
        return const shad.SecondaryBadge(child: Text('Medium'));
      default:
        return const shad.OutlineBadge(child: Text('Low'));
    }
  }
}
