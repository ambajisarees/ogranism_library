import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:fl_chart/fl_chart.dart';

class PageShowcaseMillDashboard extends StatefulWidget {
  const PageShowcaseMillDashboard({super.key});

  @override
  State<PageShowcaseMillDashboard> createState() => _PageShowcaseMillDashboardState();
}

class _PageShowcaseMillDashboardState extends State<PageShowcaseMillDashboard> {
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
                  Text('Mill & Dyeing Operations Dashboard', style: theme.typography.h2),
                  Text('Real-time loom capacity, dyeing lot batch processing speeds, and shift meter yields.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              const shad.PrimaryBadge(child: Text('Live Shift: A-Shift (7 AM - 3 PM)')),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Loom Machine Capacity Gauges (4 Cards)
          Row(
            children: [
              Expanded(child: _buildMachineGaugeCard(context, name: 'Loom Unit #01 (Surat)', speed: '1,200 RPM', status: 'ACTIVE', meterYield: '4,800 Mtr')),
              const shad.DensityGap(shad.gapMd),
              Expanded(child: _buildMachineGaugeCard(context, name: 'Loom Unit #02 (Surat)', speed: '1,150 RPM', status: 'ACTIVE', meterYield: '4,200 Mtr')),
              const shad.DensityGap(shad.gapMd),
              Expanded(child: _buildMachineGaugeCard(context, name: 'Dyeing Vessel #01', speed: '90° C Heat', status: 'PROCESSING', meterYield: '2,400 Mtr')),
              const shad.DensityGap(shad.gapMd),
              Expanded(child: _buildMachineGaugeCard(context, name: 'Dyeing Vessel #02', speed: 'Maintenance', status: 'OFFLINE', meterYield: '0 Mtr')),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Fabric Output Distribution (Pie Chart + Shift Production Table)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie Chart Fabric Composition
              Expanded(
                flex: 2,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shift Fabric Output Ratio', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(color: colors.primary, value: 45, title: 'Silk (45%)', radius: 50, titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              PieChartSectionData(color: Colors.blue, value: 25, title: 'Chiffon (25%)', radius: 50, titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              PieChartSectionData(color: Colors.amber, value: 20, title: 'Organza (20%)', radius: 50, titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              PieChartSectionData(color: Colors.purple, value: 10, title: 'Georgette (10%)', radius: 50, titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // Live Shift Dyeing Lots Table
              Expanded(
                flex: 3,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Dyeing Lots & Washing Stations', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      shad.OutlinedContainer(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: colors.muted.withAlpha(120),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: Text('LOT NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 3, child: Text('COLOR SHADE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('QUANTITY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('OPERATOR', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                            const shad.Divider(),
                            _buildLotRow(context, lot: 'LOT #D-2049', shade: 'Crimson Red #E11D48', qty: '1,200 Mtr', operator: 'Ramesh Patel'),
                            const shad.Divider(),
                            _buildLotRow(context, lot: 'LOT #D-2050', shade: 'Royal Blue #2563EB', qty: '850 Mtr', operator: 'Suresh Shah'),
                            const shad.Divider(),
                            _buildLotRow(context, lot: 'LOT #D-2051', shade: 'Emerald Green #059669', qty: '2,400 Mtr', operator: 'Dinesh Kumar'),
                          ],
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

  Widget _buildMachineGaugeCard(
    BuildContext context, {
    required String name,
    required String speed,
    required String status,
    required String meterYield,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isOnline = status != 'OFFLINE';
    return shad.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapSm),
          Text(speed, style: theme.typography.h3),
          const shad.DensityGap(shad.gapSm),
          Text('Yield: $meterYield', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLotRow(
    BuildContext context, {
    required String lot,
    required String shade,
    required String qty,
    required String operator,
  }) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(lot, style: theme.typography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(shade, style: theme.typography.textSmall)),
          Expanded(flex: 2, child: Text(qty, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(operator, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground))),
        ],
      ),
    );
  }
}
