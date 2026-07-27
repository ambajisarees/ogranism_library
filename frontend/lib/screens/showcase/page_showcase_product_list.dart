import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseProductList extends StatefulWidget {
  const PageShowcaseProductList({super.key});

  @override
  State<PageShowcaseProductList> createState() => _PageShowcaseProductListState();
}

class _PageShowcaseProductListState extends State<PageShowcaseProductList> {
  bool _isGridView = true;

  final List<Map<String, dynamic>> _products = const [
    {
      'code': 'D-4089',
      'title': 'Royal Zari Silk Saree',
      'category': 'Heavy Zari Silk',
      'rate': '₹2,400 / pc',
      'stock': '1,200 Pcs',
      'status': 'IN_STOCK',
      'tags': ['Silk', 'Zari', 'Royal'],
    },
    {
      'code': 'D-3021',
      'title': 'Chiffon Jacquard Printed',
      'category': 'Chiffon Jacquard',
      'rate': '₹1,850 / pc',
      'stock': '850 Pcs',
      'status': 'IN_STOCK',
      'tags': ['Chiffon', 'Jacquard'],
    },
    {
      'code': 'D-5100',
      'title': 'Organza Embroidered Print',
      'category': 'Organza Special',
      'rate': '₹3,200 / pc',
      'stock': '240 Pcs',
      'status': 'LOW_STOCK',
      'tags': ['Organza', 'Embroidery'],
    },
    {
      'code': 'D-2045',
      'title': 'Heavy Satin Border Work',
      'category': 'Satin Border',
      'rate': '₹1,450 / pc',
      'stock': '0 Pcs',
      'status': 'OUT_OF_STOCK',
      'tags': ['Satin', 'Border'],
    },
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
                  Text('Saree Design Catalog & Product List', style: theme.typography.h2),
                  Text('Browse saree patterns, fabric categories, pricing tiers, and stock availability.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              // Grid vs Table Toggle
              Row(
                children: [
                  shad.IconButton.outline(
                    icon: Icon(shad.LucideIcons.layoutGrid, size: 16, color: _isGridView ? colors.primary : colors.mutedForeground),
                    onPressed: () => setState(() => _isGridView = true),
                  ),
                  const SizedBox(width: 4),
                  shad.IconButton.outline(
                    icon: Icon(shad.LucideIcons.list, size: 16, color: !_isGridView ? colors.primary : colors.mutedForeground),
                    onPressed: () => setState(() => _isGridView = false),
                  ),
                ],
              ),
              const shad.DensityGap(shad.gapMd),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.plus, size: 16),
                    SizedBox(width: 8),
                    Text('Add New Design'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // View Content (Grid or Table)
          if (_isGridView)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final item = _products[index];
                return shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.muted,
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                        ),
                        child: Center(
                          child: Icon(shad.LucideIcons.shirt, size: 36, color: colors.primary),
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Row(
                        children: [
                          Text(item['code'], style: theme.typography.mono.copyWith(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          _buildStockBadge(item['status']),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Text(item['title'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(item['category'], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                      const Spacer(),
                      Row(
                        children: [
                          Text(item['rate'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                          const Spacer(),
                          Text(item['stock'], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          else
            shad.Card(
              child: shad.OutlinedContainer(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: colors.muted.withAlpha(120),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('DESIGN CODE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: Text('SAREE TITLE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('CATEGORY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('RATE PRICE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('STOCK LEVEL', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const shad.Divider(),
                    ..._products.map((item) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(item['code'], style: theme.typography.mono.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text(item['title'], style: theme.typography.textSmall)),
                            Expanded(flex: 2, child: Text(item['category'], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground))),
                            Expanded(flex: 2, child: Text(item['rate'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text(item['stock'], style: theme.typography.textSmall)),
                            Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _buildStockBadge(item['status']))),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(String status) {
    switch (status) {
      case 'IN_STOCK':
        return const shad.PrimaryBadge(child: Text('In Stock'));
      case 'LOW_STOCK':
        return const shad.SecondaryBadge(child: Text('Low Stock'));
      default:
        return const shad.DestructiveBadge(child: Text('Out of Stock'));
    }
  }
}
