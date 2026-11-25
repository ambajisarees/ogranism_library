/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC DONUT BREAKDOWN CARD (dy_donut_breakdown_card.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Interactive categorical Donut Chart + Breakdown Legend card in `dynamic_ai`.
   - Visualizes composition shares such as Customer vs Haste Delivery Channel,
     Invoice Value Ticket Bands, Credit Aging Buckets, or Packing Style Mix.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Powered by `fl_chart` `PieChart` (`^1.3.0`) and 100% native `shadcn_flutter`
     tokens (`shad.Card`, `shad.OutlinedContainer`, `MicroButton`) + `DyColorSystem`.
   - Hovering or tapping a donut slice or legend row smoothly highlights that
     segment and updates the center callout metric dynamically!

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Safely handles empty or zero-sum slice lists without NaN percentages.
   - Zero `InkWell` or Material colors; uses `MouseRegion` + `GestureDetector`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: click-to-apply DAB filter directly from slice selection.
================================================================================
*/

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../specs/dy_color_system.dart';
import '../dy_micro_button.dart';

/// Single categorical slice for [DyDonutBreakdownCard].
class DyDonutSlice {
  final String label;
  final double value;
  final String formattedValue;
  final String? subtitle;
  final int? paletteIndex;

  const DyDonutSlice({
    required this.label,
    required this.value,
    required this.formattedValue,
    this.subtitle,
    this.paletteIndex,
  });
}

/// [DyDonutBreakdownCard] — Interactive Donut Chart + Structured Share Legend.
class DyDonutBreakdownCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String centerLabel;
  final String centerValue;
  final List<DyDonutSlice> slices;
  final List<String> tabLabels;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabChanged;

  const DyDonutBreakdownCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.centerLabel,
    required this.centerValue,
    required this.slices,
    this.tabLabels = const [],
    this.selectedTabIndex = 0,
    this.onTabChanged,
  });

  @override
  State<DyDonutBreakdownCard> createState() => _DyDonutBreakdownCardState();
}

class _DyDonutBreakdownCardState extends State<DyDonutBreakdownCard> {
  int _touchedIndex = -1;

  Color _sliceColor(int i, shad.ColorScheme colors) {
    final palette = DyColorSystem.chartPalette;
    final idx = widget.slices[i].paletteIndex ?? i;
    return palette[idx % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;

    final total = widget.slices.fold<double>(0.0, (s, e) => s + e.value);
    final safeTotal = total <= 0 ? 1.0 : total;

    final activeSlice = (_touchedIndex >= 0 && _touchedIndex < widget.slices.length)
        ? widget.slices[_touchedIndex]
        : null;

    return shad.Card(
      theme: shad.CardTheme(padding: EdgeInsets.all(pad)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header + Switcher Pills
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.typography.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.foreground,
                      ),
                    ),
                    const shad.DensityGap(shad.gapXs),
                    Text(
                      widget.subtitle,
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.tabLabels.isNotEmpty) ...[
                const shad.DensityGap(shad.gapSm),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6 * theme.scaling,
                    runSpacing: 6 * theme.scaling,
                    children: [
                      for (int i = 0; i < widget.tabLabels.length; i++)
                        MicroButton(
                          label: widget.tabLabels[i],
                          isSelected: i == widget.selectedTabIndex,
                          isGhost: i != widget.selectedTabIndex,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * theme.scaling,
                            vertical: 5 * theme.scaling,
                          ),
                          onPressed: widget.onTabChanged != null
                              ? () {
                                  setState(() => _touchedIndex = -1);
                                  widget.onTabChanged!(i);
                                }
                              : null,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const shad.DensityGap(shad.gapMd),

          // 2. Donut Ring + Structured Breakdown Table
          if (widget.slices.isEmpty || total <= 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32 * theme.scaling),
              child: Center(
                child: Text(
                  'No composition data available',
                  style: theme.typography.textSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Interactive Donut Ring with Center Metric Callout
                SizedBox(
                  width: 176 * theme.scaling,
                  height: 176 * theme.scaling,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2.5,
                          centerSpaceRadius: 52 * theme.scaling,
                          startDegreeOffset: -90,
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sections: [
                            for (int i = 0; i < widget.slices.length; i++)
                              PieChartSectionData(
                                color: _sliceColor(i, colors),
                                value: widget.slices[i].value,
                                showTitle: false,
                                radius: (i == _touchedIndex ? 30 : 24) * theme.scaling,
                              ),
                          ],
                        ),
                      ),
                      IgnorePointer(
                        child: SizedBox(
                          width: 96 * theme.scaling,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                activeSlice != null
                                    ? activeSlice.label
                                    : widget.centerLabel,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.xSmall.copyWith(
                                  color: colors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2 * theme.scaling),
                              Text(
                                activeSlice != null
                                    ? activeSlice.formattedValue
                                    : widget.centerValue,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.mono.copyWith(
                                  fontSize: 13 * theme.scaling,
                                  fontWeight: FontWeight.w800,
                                  color: colors.foreground,
                                ),
                              ),
                              if (activeSlice != null)
                                Text(
                                  '${((activeSlice.value / safeTotal) * 100).toStringAsFixed(1)}%',
                                  style: theme.typography.xSmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const shad.DensityGap(shad.gapLg),

                // Right Legend Breakdown List
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < widget.slices.length; i++) ...[
                        if (i > 0) const shad.DensityGap(shad.gapSm),
                        _buildLegendItem(
                          theme,
                          colors,
                          widget.slices[i],
                          i,
                          (widget.slices[i].value / safeTotal) * 100.0,
                          _sliceColor(i, colors),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    DyDonutSlice slice,
    int index,
    double pct,
    Color dotColor,
  ) {
    final isHighlighted = index == _touchedIndex;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _touchedIndex = index),
      onExit: (_) => setState(() => _touchedIndex = -1),
      child: shad.OutlinedContainer(
        theme: shad.OutlinedContainerTheme(
          backgroundColor: isHighlighted ? colors.accent : colors.card,
          borderColor: isHighlighted ? dotColor : colors.border,
          borderRadius: BorderRadius.circular(theme.radiusSm),
          padding: EdgeInsets.symmetric(
            horizontal: 10 * theme.scaling,
            vertical: 7 * theme.scaling,
          ),
        ),
        child: Row(
          children: [
            shad.OutlinedContainer(
              width: 10 * theme.scaling,
              height: 10 * theme.scaling,
              theme: shad.OutlinedContainerTheme(
                backgroundColor: dotColor,
                borderColor: dotColor,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const SizedBox.shrink(),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slice.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                    ),
                  ),
                  if (slice.subtitle != null && slice.subtitle!.isNotEmpty)
                    Text(
                      slice.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                        fontSize: 10.5 * theme.scaling,
                      ),
                    ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  slice.formattedValue,
                  style: theme.typography.mono.copyWith(
                    fontSize: 12 * theme.scaling,
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: theme.typography.xSmall.copyWith(
                    color: dotColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

