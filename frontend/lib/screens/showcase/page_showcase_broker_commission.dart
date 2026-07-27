import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseBrokerCommission extends StatefulWidget {
  const PageShowcaseBrokerCommission({super.key});

  @override
  State<PageShowcaseBrokerCommission> createState() => _PageShowcaseBrokerCommissionState();
}

class _PageShowcaseBrokerCommissionState extends State<PageShowcaseBrokerCommission> {
  final List<Map<String, String>> _brokerLedger = const [
    {'broker': 'Kishore Bhai Agent (Surat)', 'rate': '2.0%', 'clearedSales': '₹84,20,000', 'commissionDue': '₹1,68,400', 'paid': '₹1,00,000', 'pending': '₹68,400'},
    {'broker': 'Manish Textiles Broker (Ahm)', 'rate': '1.5%', 'clearedSales': '₹42,00,000', 'commissionDue': '₹63,000', 'paid': '₹63,000', 'pending': '₹0'},
    {'broker': 'Rajesh Shah Agencies (Delhi)', 'rate': '2.0%', 'clearedSales': '₹25,10,000', 'commissionDue': '₹50,200', 'paid': '₹0', 'pending': '₹50,200'},
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
                  Text('Agent & Broker Commission Settlement Ledger', style: theme.typography.h2),
                  Text('Calculate broker commissions based on cleared payment realizations and issue payout vouchers.', style: theme.typography.textMuted),
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
                    Text('Issue Payout Voucher'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Broker Ledger Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brokerage Realization Ledger', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: Text('BROKER / AGENT NAME', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('COMM RATE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('CLEARED SALES', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('COMMISSION DUE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('PAID AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('PENDING PAYOUT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      ..._brokerLedger.map((b) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(flex: 4, child: Text(b['broker']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(b['rate']!, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground))),
                              Expanded(flex: 3, child: Text(b['clearedSales']!, style: theme.typography.textSmall)),
                              Expanded(flex: 3, child: Text(b['commissionDue']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(b['paid']!, style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(b['pending']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary))),
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
