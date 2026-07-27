import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ShowcaseCardsContainers extends StatefulWidget {
  const ShowcaseCardsContainers({super.key});

  @override
  State<ShowcaseCardsContainers> createState() => _ShowcaseCardsContainersState();
}

class _ShowcaseCardsContainersState extends State<ShowcaseCardsContainers> {
  bool _isCollapsibleOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text('Cards, Group Containers & Layout Blocks', style: theme.typography.h2),
          Text(
            'Structural cards, KPI stat metric containers, accordions, collapsibles, image cards, and resizable layout splitters.',
            style: theme.typography.textMuted,
          ),
          const shad.DensityGap(shad.gapLg),

          // 1. KPI Stat Metric Cards
          Text('KPI Stat Metric Cards', style: theme.typography.h3),
          const shad.DensityGap(shad.gapMd),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  context,
                  title: 'Total Cutting Batches',
                  value: '1,482 Batches',
                  trend: '+12.4%',
                  isPositive: true,
                  icon: shad.LucideIcons.scissors,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              Expanded(
                child: _buildKpiCard(
                  context,
                  title: 'Pending Job Receipts',
                  value: '840 Meter',
                  trend: '-4.2%',
                  isPositive: false,
                  icon: shad.LucideIcons.truck,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              Expanded(
                child: _buildKpiCard(
                  context,
                  title: 'Current FY Revenue',
                  value: '₹48.60 Lakhs',
                  trend: '+18.9%',
                  isPositive: true,
                  icon: shad.LucideIcons.indianRupee,
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 2. Structured Cards & Card Images
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header-Body-Footer Card
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(shad.LucideIcons.layers, size: 18, color: colors.primary),
                          const SizedBox(width: 8),
                          Text('Structured Header-Body Card', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Text(
                        'Standard card container with built-in border, elevation tokens, and customizable padding.',
                        style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                      ),
                      const shad.DensityGap(shad.gapMd),
                      const shad.Divider(),
                      const shad.DensityGap(shad.gapMd),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          shad.OutlineButton(
                            size: shad.ButtonSize.small,
                            onPressed: () {},
                            child: const Text('Cancel'),
                          ),
                          const shad.DensityGap(shad.gapSm),
                          shad.PrimaryButton(
                            size: shad.ButtonSize.small,
                            onPressed: () {},
                            child: const Text('Save Record'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // Card with Image Header (Design Master Preview)
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: colors.muted,
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(shad.LucideIcons.palette, size: 28, color: colors.primary),
                              const SizedBox(width: 8),
                              Text('Design Preview Image', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const shad.DensityGap(shad.gapMd),
                      Text('Royal Silk Saree #D-4092', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                      Text('Category: Heavy Zari Jacquard Work', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 3. Accordions & Collapsibles
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accordions & Disclosure Blocks', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                // Accordion Demo
                shad.Accordion(
                  items: [
                    shad.AccordionItem(
                      trigger: const Text('Cutting Process Parameters'),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Defines layer thickness limits, wastage allowances (standard 3.5%), and cutter operator assignments.',
                          style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                        ),
                      ),
                    ),
                    shad.AccordionItem(
                      trigger: const Text('Job Worker Rate Cards'),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Stitching rate ₹45/pc, Embroidery rate ₹120/pc, Washing & Ironing rate ₹15/pc.',
                          style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                        ),
                      ),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapLg),
                // Collapsible Demo
                shad.OutlinedContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Collapsible System Configuration', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            shad.IconButton.ghost(
                              size: shad.ButtonSize.small,
                              icon: Icon(_isCollapsibleOpen ? shad.LucideIcons.chevronUp : shad.LucideIcons.chevronDown, size: 16),
                              onPressed: () => setState(() => _isCollapsibleOpen = !_isCollapsibleOpen),
                            ),
                          ],
                        ),
                        if (_isCollapsibleOpen) ...[
                          const shad.DensityGap(shad.gapSm),
                          const shad.Divider(),
                          const shad.DensityGap(shad.gapSm),
                          Text('Airbyte Supabase Mirroring Schema: IMMBE2627', style: theme.typography.xSmall),
                          Text('Read-Only Mirror Views: vwsq_*', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 4. Code Snippet Container & Resizable Layout Mock
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Code Snippet Block
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code Snippet Block', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      shad.OutlinedContainer(
                        child: Container(
                          width: double.infinity,
                          color: colors.muted.withAlpha(100),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "shad.Theme.of(context).colorScheme.primary",
                                style: theme.typography.mono.copyWith(fontSize: 12),
                              ),
                              Text(
                                "theme.density.baseContainerPadding * theme.scaling",
                                style: theme.typography.mono.copyWith(fontSize: 12, color: colors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // Carousel / Horizontal Item Strip
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Carousel / Horizontal Item Strip', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return Container(
                              width: 130,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.muted,
                                borderRadius: BorderRadius.circular(theme.radiusMd),
                                border: Border.all(color: colors.border),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(shad.LucideIcons.shirt, size: 20, color: colors.primary),
                                  const SizedBox(height: 6),
                                  Text('Design #${100 + index}', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
    required IconData icon,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return shad.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
              const Spacer(),
              Icon(icon, size: 16, color: colors.mutedForeground),
            ],
          ),
          const shad.DensityGap(shad.gapSm),
          Text(value, style: theme.typography.h2),
          const shad.DensityGap(shad.gapSm),
          Row(
            children: [
              shad.SecondaryBadge(
                child: Text(
                  trend,
                  style: theme.typography.xSmall.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('vs last month', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}
