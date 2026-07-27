import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcasePriceMatrix extends StatefulWidget {
  const PageShowcasePriceMatrix({super.key});

  @override
  State<PageShowcasePriceMatrix> createState() => _PageShowcasePriceMatrixState();
}

class _PageShowcasePriceMatrixState extends State<PageShowcasePriceMatrix> {
  final List<Map<String, String>> _priceMatrix = const [
    {'design': 'D-4089 Royal Silk Saree', 'slab1': '₹2,400 (1-50 pcs)', 'slab2': '₹2,250 (51-200 pcs)', 'slab3': '₹2,100 (200+ pcs)', 'wholesaler': '₹2,000 flat'},
    {'design': 'D-3021 Chiffon Jacquard', 'slab1': '₹1,850 (1-50 pcs)', 'slab2': '₹1,720 (51-200 pcs)', 'slab3': '₹1,600 (200+ pcs)', 'wholesaler': '₹1,500 flat'},
    {'design': 'D-5100 Organza Embroidered', 'slab1': '₹3,200 (1-50 pcs)', 'slab2': '₹3,000 (51-200 pcs)', 'slab3': '₹2,850 (200+ pcs)', 'wholesaler': '₹2,700 flat'},
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
                  Text('Tiered Quantity Slab Price List Manager', style: theme.typography.h2),
                  Text('Set volume quantity tier discounts and party category wholesale rate matrices.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.save, size: 16),
                    SizedBox(width: 8),
                    Text('Update Master Price Slabs'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Price Matrix Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Master Quantity Tier Pricing Matrix', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: Text('SAREE DESIGN PATTERN', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('TIER 1 (1-50 PCS)', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('TIER 2 (51-200 PCS)', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('TIER 3 (200+ PCS)', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('WHOLESALER SPECIAL', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      ..._priceMatrix.map((p) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(flex: 4, child: Text(p['design']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text(p['slab1']!, style: theme.typography.textSmall)),
                              Expanded(flex: 3, child: Text(p['slab2']!, style: theme.typography.textSmall)),
                              Expanded(flex: 3, child: Text(p['slab3']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text(p['wholesaler']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary))),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
