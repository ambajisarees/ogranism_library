import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/purchase_bills/model_purchase_bill_header.dart';

class PurchaseBillsSidePanel extends StatelessWidget {
  final PurchaseBillHeaderModel? selectedBill;

  const PurchaseBillsSidePanel({
    super.key,
    this.selectedBill,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final panelWidth = 360.0 * theme.scaling;
    final padMd = theme.density.baseContainerPadding * theme.scaling * shad.padMd;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    if (selectedBill == null) {
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
                  Icon(
                    shad.LucideIcons.mousePointerClick,
                    size: 28 * theme.scaling,
                    color: colors.mutedForeground,
                  ),
                  const shad.DensityGap(shad.gapMd),
                  Text(
                    'Select a Purchase Bill',
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const shad.DensityGap(shad.gapSm),
                  Text(
                    'Click any bill row in the table to view detailed financial breakdown & line items.',
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

    final bill = selectedBill!;
    final dateStr = DateFormat('dd MMM yyyy').format(bill.billDate);

    return SizedBox(
      width: panelWidth,
      child: shad.Card(
        borderColor: colors.border,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Internal VNO / Weaver Bill Code & Paid/Pending Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.displayBillNo,
                          style: theme.typography.mono.copyWith(
                            fontSize: theme.typography.h3.fontSize,
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Internal Bill VNO: ${bill.displayInternalVno}',
                          style: theme.typography.xSmall.copyWith(
                            color: colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  bill.isPaid
                      ? const shad.SecondaryBadge(child: Text('PAID'))
                      : const shad.OutlineBadge(child: Text('PENDING')),
                ],
              ),
              const shad.DensityGap(shad.gapSm),
              Text(
                'Bill Date: $dateStr',
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),

              const shad.DensityGap(shad.gapLg),
              const shad.Divider(),
              const shad.DensityGap(shad.gapLg),

              // Supplier & Broker Metadata
              _buildDetailLabel(context, 'Party / Supplier', bill.partyName),
              const shad.DensityGap(shad.gapMd),
              _buildDetailLabel(context, 'Broker / Agent', bill.brokerCode.isNotEmpty ? bill.brokerCode : 'Direct'),
              if (bill.transport != null && bill.transport!.isNotEmpty) ...[
                const shad.DensityGap(shad.gapMd),
                _buildDetailLabel(context, 'Transport', bill.transport!),
              ],
              if (bill.hsnCode != null && bill.hsnCode!.isNotEmpty) ...[
                const shad.DensityGap(shad.gapMd),
                _buildDetailLabel(context, 'HSN Code', bill.hsnCode!),
              ],

              const shad.DensityGap(shad.gapLg),
              const shad.Divider(),
              const shad.DensityGap(shad.gapLg),

              // Financial Breakdown Section
              Text(
                'Financial Breakdown',
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              if (bill.billAmt > 0)
                _buildMetricRow(context, 'Total Bill Amount', '₹${bill.billAmt.toStringAsFixed(2)}'),
              if (bill.grossAmt > 0)
                _buildMetricRow(context, 'Gross Amount', '₹${bill.grossAmt.toStringAsFixed(2)}'),
              if (bill.vatAmt > 0)
                _buildMetricRow(
                  context,
                  'GST / Tax (${bill.vatRate.toStringAsFixed(1)}%)',
                  '₹${bill.vatAmt.toStringAsFixed(2)}',
                ),
              if (bill.freight > 0)
                _buildMetricRow(context, 'Freight / Charges', '₹${bill.freight.toStringAsFixed(2)}'),
              if (bill.discount > 0)
                _buildMetricRow(context, 'Discount / Less', '₹${bill.discount.toStringAsFixed(2)}'),
              _buildMetricRow(
                context,
                'Net Final Amount',
                '₹${bill.finalAmt.toStringAsFixed(2)}',
                isBold: true,
              ),
              _buildMetricRow(
                context,
                'Avg Purchase Rate',
                '₹${bill.calculatedAvgRate.toStringAsFixed(2)} / m',
              ),

              const shad.DensityGap(shad.gapLg),
              const shad.Divider(),
              const shad.DensityGap(shad.gapLg),

              // Stock Totals
              Text(
                'Stock & Meters Summary',
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              _buildMetricRow(context, 'Parcels / Bales', '${bill.parcels}'),
              _buildMetricRow(context, 'Total Pieces', '${bill.totPcs} Pcs'),
              _buildMetricRow(context, 'Total Meters', '${bill.totMts.toStringAsFixed(1)} Mts'),
              _buildMetricRow(context, 'Base Quality', bill.primaryQuality),

              // Line Items
              if (bill.items.isNotEmpty) ...[
                const shad.DensityGap(shad.gapLg),
                const shad.Divider(),
                const shad.DensityGap(shad.gapLg),
                Text(
                  'Underlying Line Items (${bill.items.length})',
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                  ),
                ),
                const shad.DensityGap(shad.gapMd),
                SizedBox(
                  height: 180 * theme.scaling,
                  child: ListView.separated(
                    itemCount: bill.items.length,
                    separatorBuilder: (context, index) => const shad.Divider(),
                    itemBuilder: (context, index) {
                      final item = bill.items[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4 * theme.scaling),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${item.id} • ${item.qual}',
                                  style: theme.typography.xSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.foreground,
                                  ),
                                ),
                                Text(
                                  '${item.partyName} • ${item.meters.toStringAsFixed(1)}m (${item.pieces} pcs)',
                                  style: theme.typography.xSmall.copyWith(
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${item.rate.toStringAsFixed(2)}',
                                  style: theme.typography.mono.copyWith(
                                    fontSize: theme.typography.xSmall.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                item.isClosed
                                    ? const shad.SecondaryBadge(child: Text('Closed'))
                                    : const shad.OutlineBadge(child: Text('Open')),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const shad.DensityGap(shad.gapXl),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: shad.PrimaryButton(
                  size: shad.ButtonSize.small,
                  onPressed: () {},
                  child: const Text('View Full Invoice'),
                ),
              ),
              const shad.DensityGap(shad.gapSm),
              SizedBox(
                width: double.infinity,
                child: shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: () {},
                  child: const Text('Print / Export PDF'),
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
