import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:fl_chart/fl_chart.dart';

class PageShowcasePaymentDashboard extends StatefulWidget {
  const PageShowcasePaymentDashboard({super.key});

  @override
  State<PageShowcasePaymentDashboard> createState() => _PageShowcasePaymentDashboardState();
}

class _PageShowcasePaymentDashboardState extends State<PageShowcasePaymentDashboard> {
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
                  Text('Payment & Cashflow Dashboard', style: theme.typography.h2),
                  Text('Monitor bank account balances, incoming party collections, and vendor payout ledgers.', style: theme.typography.textMuted),
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
                    Text('Record New Collection'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Bank Account Cards
          Row(
            children: [
              Expanded(
                child: _buildBankCard(
                  context,
                  bankName: 'HDFC Current Account (Surat)',
                  accountNo: '•••• 4892',
                  balance: '₹42,80,950',
                  type: 'Primary Operating Account',
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              Expanded(
                child: _buildBankCard(
                  context,
                  bankName: 'ICICI GST Cash Ledger',
                  accountNo: '•••• 1049',
                  balance: '₹14,20,400',
                  type: 'Tax & Duty Reserve Account',
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Cashflow Area Chart
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Monthly Cash Inflow vs Outflow Velocity', style: theme.typography.h3),
                    const Spacer(),
                    const shad.OutlineBadge(child: Text('Net Positive Flow (+₹18.2L)')),
                  ],
                ),
                const shad.DensityGap(shad.gapMd),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (val) => FlLine(color: colors.border.withAlpha(80), strokeWidth: 1),
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              const months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
                              if (val.toInt() >= 0 && val.toInt() < months.length) {
                                return Text(months[val.toInt()], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 30),
                            FlSpot(1, 42),
                            FlSpot(2, 38),
                            FlSpot(3, 55),
                            FlSpot(4, 48),
                            FlSpot(5, 68),
                          ],
                          isCurved: true,
                          color: colors.primary,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: true, color: colors.primary.withAlpha(50)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // Payment Transactions Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Payment Receipts & Vendor Disbursals', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('TRANSACTION ID', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('PARTY / VENDOR', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('PAYMENT MODE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      _buildTxRow(context, id: 'TXN #90481', party: 'Ambaji Traders (Surat)', mode: 'NEFT / HDFC', amount: '+ ₹2,40,000', status: 'SUCCESS'),
                      const shad.Divider(),
                      _buildTxRow(context, id: 'TXN #90482', party: 'Saraswati Dyers (Mill)', mode: 'RTGS / ICICI', amount: '- ₹85,000', status: 'SUCCESS'),
                      const shad.Divider(),
                      _buildTxRow(context, id: 'TXN #90483', party: 'Rajlaxmi Fashions (Delhi)', mode: 'UPI Transfer', amount: '+ ₹1,20,000', status: 'PENDING'),
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

  Widget _buildBankCard(
    BuildContext context, {
    required String bankName,
    required String accountNo,
    required String balance,
    required String type,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return shad.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(shad.LucideIcons.creditCard, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(bankName, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(accountNo, style: theme.typography.mono.copyWith(color: colors.mutedForeground)),
            ],
          ),
          const shad.DensityGap(shad.gapMd),
          Text(balance, style: theme.typography.h1),
          const shad.DensityGap(shad.gapSm),
          Text(type, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildTxRow(
    BuildContext context, {
    required String id,
    required String party,
    required String mode,
    required String amount,
    required String status,
  }) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(id, style: theme.typography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(party, style: theme.typography.textSmall)),
          Expanded(flex: 2, child: Text(mode, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground))),
          Expanded(flex: 2, child: Text(amount, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: amount.startsWith('+') ? Colors.green : Colors.red))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: status == 'SUCCESS'
                  ? const shad.PrimaryBadge(child: Text('Settled'))
                  : const shad.OutlineBadge(child: Text('Pending Approval')),
            ),
          ),
        ],
      ),
    );
  }
}
