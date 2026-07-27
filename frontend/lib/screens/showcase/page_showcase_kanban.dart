import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseKanban extends StatefulWidget {
  const PageShowcaseKanban({super.key});

  @override
  State<PageShowcaseKanban> createState() => _PageShowcaseKanbanState();
}

class _PageShowcaseKanbanState extends State<PageShowcaseKanban> {
  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
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
                  Text('Production Stage Kanban Board', style: theme.typography.h2),
                  Text('Visual stage tracking for textile cutting, stitching, embroidery, quality audit, and packing.', style: theme.typography.textMuted),
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
                    Text('Create Cutting Card'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 4 Kanban Columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKanbanColumn(
                context,
                title: '1. Cutting Queue',
                count: '3 Batches',
                cards: [
                  {'batch': 'Batch #C-2049', 'design': 'Royal Silk #D-4089', 'qty': '1,200 Mtr', 'assignee': 'SM'},
                  {'batch': 'Batch #C-2050', 'design': 'Chiffon #D-3021', 'qty': '850 Mtr', 'assignee': 'AS'},
                ],
              ),
              const shad.DensityGap(shad.gapMd),
              _buildKanbanColumn(
                context,
                title: '2. Job Stitching',
                count: '2 Batches',
                cards: [
                  {'batch': 'Batch #S-1092', 'design': 'Organza #D-5100', 'qty': '2,400 Mtr', 'assignee': 'RP'},
                ],
              ),
              const shad.DensityGap(shad.gapMd),
              _buildKanbanColumn(
                context,
                title: '3. Embroidery Work',
                count: '4 Batches',
                cards: [
                  {'batch': 'Batch #E-8041', 'design': 'Satin Border #D-2045', 'qty': '600 Mtr', 'assignee': 'DK'},
                  {'batch': 'Batch #E-8042', 'design': 'Zari Special #D-900', 'qty': '1,100 Mtr', 'assignee': 'SM'},
                ],
              ),
              const shad.DensityGap(shad.gapMd),
              _buildKanbanColumn(
                context,
                title: '4. Quality & Packing',
                count: '2 Batches',
                cards: [
                  {'batch': 'Batch #P-3011', 'design': 'Georgette #D-102', 'qty': '500 Mtr', 'assignee': 'AS'},
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context, {
    required String title,
    required String count,
    required List<Map<String, String>> cards,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.muted.withAlpha(80),
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                shad.SecondaryBadge(child: Text(count)),
              ],
            ),
            const shad.DensityGap(shad.gapMd),
            ...cards.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(c['batch']!, style: theme.typography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                          const Spacer(),
                          shad.Avatar(initials: c['assignee']!, size: 24),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Text(c['design']!, style: theme.typography.textSmall),
                      Text('Quantity: ${c['qty']}', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
