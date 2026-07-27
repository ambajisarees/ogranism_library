import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseAgingAnalysis extends StatefulWidget {
  const PageShowcaseAgingAnalysis({super.key});

  @override
  State<PageShowcaseAgingAnalysis> createState() => _PageShowcaseAgingAnalysisState();
}

class _PageShowcaseAgingAnalysisState extends State<PageShowcaseAgingAnalysis> {
  final List<Map<String, dynamic>> _agingData = const [
    {'party': 'Ambaji Traders (Surat)', 'limit': '₹50.0L', 'current': '₹12.4L', 'd30': '₹18.2L', 'd60': '₹8.0L', 'd90': '₹4.2L', 'total': '₹42.8L', 'risk': 'MEDIUM'},
    {'party': 'Shree Ram Sarees (Ahm)', 'limit': '₹20.0L', 'current': '₹8.0L', 'd30': '₹6.2L', 'd60': '₹0.0L', 'd90': '₹0.0L', 'total': '₹14.2L', 'risk': 'LOW'},
    {'party': 'Vrindavan Textiles (Jaipur)', 'limit': '₹10.0L', 'current': '₹1.0L', 'd30': '₹0.0L', 'd60': '₹4.0L', 'd90': '₹12.1L', 'total': '₹17.1L', 'risk': 'HIGH_BREACH'},
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
                  Text('Party Outstanding 30-60-90 Day Aging Analysis', style: theme.typography.h2),
                  Text('Track party credit age buckets, interest penalties, and credit limit breach risk levels.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.mail, size: 16),
                    SizedBox(width: 8),
                    Text('Send Payment Reminders'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Aging Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Credit Age Bucket Breakdown (FY 26-27)', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text('PARTY NAME', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('CREDIT LIMIT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('0-30 DAYS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('31-60 DAYS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('61-90 DAYS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('90+ OVERDUE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('TOTAL DUE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('RISK LEVEL', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      ..._agingData.map((row) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text(row['party'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(row['limit'], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground))),
                              Expanded(flex: 2, child: Text(row['current'], style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(row['d30'], style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(row['d60'], style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(row['d90'], style: theme.typography.textSmall.copyWith(color: Colors.red, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(row['total'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary))),
                              Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _buildRiskBadge(row['risk']!))),
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

  Widget _buildRiskBadge(String risk) {
    switch (risk) {
      case 'HIGH_BREACH':
        return const shad.DestructiveBadge(child: Text('Limit Breached'));
      case 'MEDIUM':
        return const shad.SecondaryBadge(child: Text('Watch List'));
      default:
        return const shad.PrimaryBadge(child: Text('Good Standing'));
    }
  }
}
