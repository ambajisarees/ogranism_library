import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:fl_chart/fl_chart.dart';

class PageShowcaseEcommerceDashboard extends StatefulWidget {
  const PageShowcaseEcommerceDashboard({super.key});

  @override
  State<PageShowcaseEcommerceDashboard> createState() => _PageShowcaseEcommerceDashboardState();
}

class _PageShowcaseEcommerceDashboardState extends State<PageShowcaseEcommerceDashboard> {
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
                  Text('E-Commerce & B2B Sales Dashboard', style: theme.typography.h2),
                  Text('Track monthly recurring revenue, saree catalog metrics, regional sales, and return rates.', style: theme.typography.textMuted),
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
                    Text('28 Jun 2026 - 25 Jul 2026'),
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
                    Text('Download Sales Report'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Top Cards Grid (Best Seller Saree Banner + 3 Stat Cards)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Best Seller Saree Banner
              Expanded(
                flex: 2,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Congratulations Ambaji Team! 🎉', style: theme.typography.h3),
                      Text('Best seller saree design of the month: #D-4089 (Royal Silk)', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                      const shad.DensityGap(shad.gapMd),
                      Text('₹15,23,189', style: theme.typography.h1),
                      Text('+65% from last month sales target', style: theme.typography.xSmall.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                      const shad.DensityGap(shad.gapMd),
                      shad.OutlineButton(
                        onPressed: () {},
                        child: const Text('View Sales Analytics'),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              // 2. MRR Card
              Expanded(
                child: _buildEcomCard(
                  context,
                  title: 'Monthly B2B Revenue',
                  value: '₹34.1 Lakhs',
                  trend: '+6.1%',
                  isPositive: true,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              // 3. Active Buyers
              Expanded(
                child: _buildEcomCard(
                  context,
                  title: 'Verified Buyers',
                  value: '500 Parties',
                  trend: '+19.2%',
                  isPositive: true,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              // 4. Repeat Order Growth
              Expanded(
                child: _buildEcomCard(
                  context,
                  title: 'Repeat Order Rate',
                  value: '68.4%',
                  trend: '+4.5%',
                  isPositive: true,
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Middle Row: Bar Chart (Sales by Location) + Line Chart (Returning Buyer Rate)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sales by Location Bar Chart
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Sales by Key Region (Surat, Ahm, Jaipur, Delhi)', style: theme.typography.h3),
                          const Spacer(),
                          shad.OutlineButton(onPressed: () {}, child: const Text('Export')),
                        ],
                      ),
                      const shad.DensityGap(shad.gapMd),
                      SizedBox(
                        height: 220,
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
                                    const regions = ['Surat', 'Ahmedabad', 'Jaipur', 'Delhi', 'Mumbai'];
                                    if (val.toInt() >= 0 && val.toInt() < regions.length) {
                                      return Text(regions[val.toInt()], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: colors.primary, width: 20, borderRadius: BorderRadius.circular(4))]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 62, color: colors.primary, width: 20, borderRadius: BorderRadius.circular(4))]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 48, color: colors.primary, width: 20, borderRadius: BorderRadius.circular(4))]),
                              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 74, color: colors.primary, width: 20, borderRadius: BorderRadius.circular(4))]),
                              BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 55, color: colors.primary, width: 20, borderRadius: BorderRadius.circular(4))]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // Returning Buyer Trend Line Chart
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Returning Buyer Revenue Rate', style: theme.typography.h3),
                          const Spacer(),
                          const shad.PrimaryBadge(child: Text('+2.5% Growth')),
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
                                    const months = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
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
                                  FlSpot(0, 12),
                                  FlSpot(1, 19),
                                  FlSpot(2, 15),
                                  FlSpot(3, 28),
                                  FlSpot(4, 24),
                                  FlSpot(5, 36),
                                ],
                                isCurved: true,
                                color: colors.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: colors.primary.withAlpha(35),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEcomCard(
    BuildContext context, {
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return shad.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
          const shad.DensityGap(shad.gapSm),
          Text(value, style: theme.typography.h3),
          const shad.DensityGap(shad.gapSm),
          Row(
            children: [
              Text(
                trend,
                style: theme.typography.xSmall.copyWith(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text('View details ->', style: theme.typography.xSmall.copyWith(color: colors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
