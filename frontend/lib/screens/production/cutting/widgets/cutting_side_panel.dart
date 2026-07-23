import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/model_cutting.dart';

class CuttingSidePanel extends StatelessWidget {
  final CuttingBatchSummaryModel? selectedBatch;

  const CuttingSidePanel({
    super.key,
    this.selectedBatch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final panelWidth = 360.0 * theme.scaling;
    final padMd = theme.density.baseContainerPadding * theme.scaling * shad.padMd;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    if (selectedBatch == null) {
      return SizedBox(
        width: panelWidth,
        child: shad.Card(
          borderColor: colors.border,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: padMd * 2, horizontal: padSm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shad.LucideIcons.mousePointerClick,
                      size: 28 * theme.scaling, color: colors.mutedForeground),
                  const shad.DensityGap(shad.gapMd),
                  Text(
                    'Select a Cutting Batch',
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const shad.DensityGap(shad.gapSm),
                  Text(
                    'Click any row in the table to view batch analytics.',
                    style: theme.typography.xSmall.copyWith(
                      color: colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final batch = selectedBatch!;
    final dateStr = DateFormat('dd MMM yyyy').format(batch.cutDate);
    final costPerPc = batch.costPerPc ?? 0.0;
    final freshPct = batch.calculatedFreshPct;
    final shortagePct = batch.calculatedShortagePct;

    return SizedBox(
      width: panelWidth,
      child: shad.Card(
        borderColor: colors.border,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: CC Code & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      batch.displayCode,
                      style: theme.typography.mono.copyWith(
                        fontSize: theme.typography.h3.fontSize,
                        fontWeight: FontWeight.bold,
                        color: colors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  batch.sbStatus.toUpperCase() == 'COMPLETED'
                      ? shad.SecondaryBadge(child: Text(batch.sbStatus))
                      : shad.OutlineBadge(child: Text(batch.sbStatus)),
                ],
              ),
              Text(
                'Cut Date: $dateStr',
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),

              // Multi-Image Card Avatars (if present)
              if (batch.cardPics.isNotEmpty) ...[
                const shad.DensityGap(shad.gapMd),
                SizedBox(
                  height: 48 * theme.scaling,
                  child: Row(
                    children: batch.cardPics.map((picUrl) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8 * theme.scaling),
                        child: ClipRRect(
                          borderRadius: theme.borderRadiusSm,
                          child: Container(
                            width: 48 * theme.scaling,
                            height: 48 * theme.scaling,
                            color: colors.muted.withValues(alpha: 0.5),
                            child: Image.network(
                              picUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Center(
                                child: Icon(shad.LucideIcons.image,
                                    size: 18 * theme.scaling, color: colors.mutedForeground),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const shad.DensityGap(shad.gapLg),
              const shad.Divider(),
              const shad.DensityGap(shad.gapLg),

              // Mill & Grey Quality
              _buildDetailLabel(context, 'Mill Name', batch.mill),
              const shad.DensityGap(shad.gapMd),
              _buildDetailLabel(context, 'Grey Quality', batch.greyQual),
              const shad.DensityGap(shad.gapLg),
              const shad.Divider(),
              const shad.DensityGap(shad.gapLg),

              // Metrics Breakdown Section
              Text(
                'Batch Metrics',
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              _buildMetricRow(context, 'Cut Length', '${batch.cutLength.toStringAsFixed(2)} Mts'),
              _buildMetricRow(context, 'Fresh Pieces', '${batch.totalFreshPcs} Pcs'),
              _buildMetricRow(context, 'Dispatched Grey', '${batch.totalDmts.toStringAsFixed(1)} M'),
              _buildMetricRow(context, 'Total Rec Mts', '${batch.totalRmts.toStringAsFixed(1)} M'),
              _buildMetricRow(context, 'Fresh Yield', '${freshPct.toStringAsFixed(1)}%'),
              _buildMetricRow(context, 'Mill Shortage', '${shortagePct.toStringAsFixed(1)}%'),

              const shad.DensityGap(shad.gapLg),
              const shad.Divider(),
              const shad.DensityGap(shad.gapLg),

              // Rates & Financials
              Text(
                'Financials & Rates',
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              if (batch.greyRate > 0)
                _buildMetricRow(context, 'Grey Rate', '₹${batch.greyRate.toStringAsFixed(2)}/m'),
              if (batch.jobRate > 0)
                _buildMetricRow(context, 'Mill Job Rate', '₹${batch.jobRate.toStringAsFixed(2)}/m'),
              _buildMetricRow(
                context,
                'Cost / Pc',
                costPerPc > 0 ? '₹${costPerPc.toStringAsFixed(2)}' : '₹0.00',
                isBold: true,
              ),
              if (batch.totalInvestment != null && batch.totalInvestment! > 0)
                _buildMetricRow(
                  context,
                  'Total Investment',
                  '₹${batch.totalInvestment!.toStringAsFixed(2)}',
                ),

              const shad.DensityGap(shad.gapXl),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: shad.PrimaryButton(
                  size: shad.ButtonSize.small,
                  onPressed: () {},
                  child: const Text('View Batch Details'),
                ),
              ),
              const shad.DensityGap(shad.gapSm),
              SizedBox(
                width: double.infinity,
                child: shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: null,
                  child: const Text('Link Job Card (Pending)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailLabel(BuildContext context, String label, String value) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.typography.xSmall.copyWith(
            color: colors.mutedForeground,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const shad.DensityGap(shad.gapSm),
        Text(
          value,
          style: theme.typography.textSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.foreground,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: theme.density.baseGap * theme.scaling * shad.gapSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: theme.typography.mono.copyWith(
              fontSize: theme.typography.xSmall.fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? colors.primary : colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
