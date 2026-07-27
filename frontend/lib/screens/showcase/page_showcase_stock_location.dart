import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseStockLocation extends StatefulWidget {
  const PageShowcaseStockLocation({super.key});

  @override
  State<PageShowcaseStockLocation> createState() => _PageShowcaseStockLocationState();
}

class _PageShowcaseStockLocationState extends State<PageShowcaseStockLocation> {
  final List<Map<String, dynamic>> _locations = const [
    {'rack': 'Rack A-01', 'warehouse': 'Surat Central Warehouse', 'capacity': '85%', 'rolls': '1,420 Rolls', 'type': 'Grey Fabric Storage'},
    {'rack': 'Rack A-02', 'warehouse': 'Surat Central Warehouse', 'capacity': '62%', 'rolls': '980 Rolls', 'type': 'Dyeing Lot Holding'},
    {'rack': 'Rack B-01', 'warehouse': 'Ahmedabad Depot', 'capacity': '94%', 'rolls': '2,100 Rolls', 'type': 'Finished Saree Stock'},
    {'rack': 'Rack B-02', 'warehouse': 'Jaipur Regional Facility', 'capacity': '40%', 'rolls': '450 Rolls', 'type': 'Packing & Material'},
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
                  Text('Warehouse Stock & Location Grid', style: theme.typography.h2),
                  Text('Rack/Bin location assignments, warehouse capacity utilization, and roll tracking.', style: theme.typography.textMuted),
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
                    Text('Add Rack Location'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Location Grid (2x2 Cards)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemCount: _locations.length,
            itemBuilder: (context, index) {
              final item = _locations[index];
              return shad.Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(shad.LucideIcons.building2, size: 20, color: colors.primary),
                        const SizedBox(width: 8),
                        Text(item['rack'], style: theme.typography.h3),
                        const Spacer(),
                        const shad.PrimaryBadge(child: Text('Active Rack')),
                      ],
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Text(item['warehouse'], style: theme.typography.textSmall.copyWith(color: colors.mutedForeground)),
                    Text(item['type'], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    const Spacer(),
                    const shad.Divider(),
                    const shad.DensityGap(shad.gapSm),
                    Row(
                      children: [
                        Text('Capacity: ${item['capacity']}', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(item['rolls'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
