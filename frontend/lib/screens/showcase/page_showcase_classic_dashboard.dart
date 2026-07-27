import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:fl_chart/fl_chart.dart';

class PageShowcaseClassicDashboard extends StatefulWidget {
  const PageShowcaseClassicDashboard({super.key});

  @override
  State<PageShowcaseClassicDashboard> createState() => _PageShowcaseClassicDashboardState();
}

class _PageShowcaseClassicDashboardState extends State<PageShowcaseClassicDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Executive Classic Dashboard', style: theme.typography.h2),
                  Text('High-level overview of fiscal year revenue, pending vouchers, and real-time operations.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.OutlineButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.calendar, size: 16),
                    SizedBox(width: 8),
                    Text('FY 26-27 (Current)'),
                  ],
                ),
              ),
              const shad.DensityGap(shad.gapSm),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.download, size: 16),
                    SizedBox(width: 8),
                    Text('Export Executive Summary'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 4 Metric KPI Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Total Revenue Velocity',
                  value: '₹1.84 Cr',
                  subtitle: '+18.4% vs last fiscal',
                  isPositive: true,
                  icon: shad.LucideIcons.indianRupee,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Active Cutting Batches',
                  value: '1,482 Batches',
                  subtitle: '840 Mtr in process',
                  isPositive: true,
                  icon: shad.LucideIcons.scissors,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Pending Job Vouchers',
                  value: '42 Vouchers',
                  subtitle: '-4.2% backlog clear rate',
                  isPositive: false,
                  icon: shad.LucideIcons.truck,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Airbyte Mirror Latency',
                  value: '1.2 Sec',
                  subtitle: 'Schema IMMBE2627 sync ok',
                  isPositive: true,
                  icon: shad.LucideIcons.refreshCw,
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Charts Row (60/40 Split)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 6-Month Revenue Velocity Line Chart
              Expanded(
                flex: 3,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Fiscal Revenue Velocity (in Lakhs)', style: theme.typography.h3),
                          const Spacer(),
                          const shad.PrimaryBadge(child: Text('Live Airbyte Stream')),
                        ],
                      ),
                      const shad.DensityGap(shad.gapMd),
                      SizedBox(
                        height: 240,
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
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(months[val.toInt()], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                                      );
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
                                  FlSpot(0, 18),
                                  FlSpot(1, 24),
                                  FlSpot(2, 22),
                                  FlSpot(3, 35),
                                  FlSpot(4, 31),
                                  FlSpot(5, 48),
                                ],
                                isCurved: true,
                                color: colors.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: colors.primary.withAlpha(40),
                                ),
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
              // Monthly Voucher Volume Bar Chart
              Expanded(
                flex: 2,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voucher Generation Count', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      SizedBox(
                        height: 240,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (val) => FlLine(color: colors.border.withAlpha(80), strokeWidth: 1),
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    const months = ['Apr', 'May', 'Jun', 'Jul'];
                                    if (val.toInt() >= 0 && val.toInt() < months.length) {
                                      return Text(months[val.toInt()], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 120, color: colors.primary, width: 18, borderRadius: BorderRadius.circular(4))]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 190, color: colors.primary, width: 18, borderRadius: BorderRadius.circular(4))]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 160, color: colors.primary, width: 18, borderRadius: BorderRadius.circular(4))]),
                              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 240, color: colors.primary, width: 18, borderRadius: BorderRadius.circular(4))]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Recent Executive Vouchers Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Recent High-Value Vouchers', style: theme.typography.h3),
                    const Spacer(),
                    shad.OutlineButton(
                      onPressed: () {},
                      child: const Text('View All Vouchers'),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('VOUCHER NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('PARTY NAME', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('DESIGN PATTERN', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('TOTAL AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      // Table Rows
                      _buildTableRow(context, vno: 'VNO #10491', party: 'Ambaji Traders (Surat)', design: 'D-4089 Royal Silk', amount: '₹2,40,000', status: 'COMPLETED'),
                      const shad.Divider(),
                      _buildTableRow(context, vno: 'VNO #10492', party: 'Shree Ram Sarees (Ahm)', design: 'D-3021 Chiffon', amount: '₹1,70,000', status: 'IN_PROCESS'),
                      const shad.Divider(),
                      _buildTableRow(context, vno: 'VNO #10493', party: 'Vrindavan Textiles (Jaipur)', design: 'D-5100 Organza', amount: '₹5,10,000', status: 'PENDING'),
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

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
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
          Text(
            subtitle,
            style: theme.typography.xSmall.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context, {
    required String vno,
    required String party,
    required String design,
    required String amount,
    required String status,
  }) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(vno, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(party, style: theme.typography.textSmall)),
          Expanded(flex: 2, child: Text(design, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground))),
          Expanded(flex: 2, child: Text(amount, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: status == 'COMPLETED'
                  ? const shad.PrimaryBadge(child: Text('Completed'))
                  : status == 'IN_PROCESS'
                      ? const shad.SecondaryBadge(child: Text('In Process'))
                      : const shad.OutlineBadge(child: Text('Pending')),
            ),
          ),
        ],
      ),
    );
  }
}
