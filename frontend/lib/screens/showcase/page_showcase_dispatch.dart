import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseDispatch extends StatefulWidget {
  const PageShowcaseDispatch({super.key});

  @override
  State<PageShowcaseDispatch> createState() => _PageShowcaseDispatchState();
}

class _PageShowcaseDispatchState extends State<PageShowcaseDispatch> {
  final List<Map<String, String>> _dispatches = const [
    {'gatePass': 'GP-2026-801', 'transporter': 'V-Trans Logistics (Surat)', 'lrNo': 'LR #904812', 'vehicle': 'GJ-05-BX-4912', 'bales': '12 Bales', 'party': 'Ambaji Traders', 'status': 'IN_TRANSIT'},
    {'gatePass': 'GP-2026-802', 'transporter': 'ARC Freight Services', 'lrNo': 'LR #904813', 'vehicle': 'GJ-01-CZ-1029', 'bales': '8 Bales', 'party': 'Shree Ram Sarees', 'status': 'DISPATCHED'},
    {'gatePass': 'GP-2026-803', 'transporter': 'Local Tempo Service', 'lrNo': 'LR #904814', 'vehicle': 'GJ-05-AA-8810', 'bales': '25 Cartons', 'party': 'Vrindavan Textiles', 'status': 'DELIVERED'},
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
                  Text('Dispatch Gate Pass & Transport LR Loading Sheet', style: theme.typography.h2),
                  Text('Manage transporter bookings, lorry receipts (LR), bale/carton counts, and gate pass approvals.', style: theme.typography.textMuted),
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
                    Text('Create Gate Pass'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Gate Pass List Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Dispatch Loading Sheets', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('GATE PASS NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('TRANSPORTER / LR NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('VEHICLE NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('DESTINATION PARTY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('BALES COUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      ..._dispatches.map((d) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(d['gatePass']!, style: theme.typography.mono.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(d['transporter']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                    Text(d['lrNo']!, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 2, child: Text(d['vehicle']!, style: theme.typography.mono.copyWith(fontSize: 12))),
                              Expanded(flex: 3, child: Text(d['party']!, style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(d['bales']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _buildDispatchStatus(d['status']!))),
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

  Widget _buildDispatchStatus(String status) {
    switch (status) {
      case 'DELIVERED':
        return const shad.PrimaryBadge(child: Text('Delivered'));
      case 'IN_TRANSIT':
        return const shad.SecondaryBadge(child: Text('In Transit'));
      default:
        return const shad.OutlineBadge(child: Text('Dispatched'));
    }
  }
}
