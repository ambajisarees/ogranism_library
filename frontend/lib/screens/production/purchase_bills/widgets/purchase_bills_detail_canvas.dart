import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/purchase_bills/purchase_bill_category.dart';
import '../../../../models/production/purchase_bills/model_purchase_bill_header.dart';

class PurchaseBillsDetailCanvas extends StatelessWidget {
  final PurchaseBillHeaderModel? selectedBill;
  final bool isLoadingItems;

  const PurchaseBillsDetailCanvas({
    super.key,
    this.selectedBill,
    this.isLoadingItems = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final padMd = theme.density.baseContainerPadding * theme.scaling * shad.padMd;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    if (selectedBill == null) {
      return Expanded(
        child: shad.Card(
          borderColor: colors.border,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.mousePointerClick, size: 36 * theme.scaling, color: colors.mutedForeground),
                const shad.DensityGap(shad.gapMd),
                Text(
                  'Select a Bill to View Details',
                  style: theme.typography.h3.copyWith(color: colors.mutedForeground),
                ),
                const shad.DensityGap(shad.gapSm),
                Text(
                  'Select a card from the left panel to display financial breakdown & underlying line items.',
                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bill = selectedBill!;
    final dateStr = DateFormat('dd MMM yyyy').format(bill.billDate);
    final source = bill.category.lineItemSource;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // 1. BILL HEADER & FINANCIAL CANVAS CARD
          // ==========================================
          shad.Card(
            borderColor: colors.border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Line: Bill #, Category Badge, Internal VNO, Paid Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          bill.displayBillNo,
                          style: theme.typography.mono.copyWith(
                            fontSize: theme.typography.h2.fontSize,
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        const shad.DensityGap(shad.gapMd),
                        shad.PrimaryBadge(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(bill.category.icon, size: 12 * theme.scaling),
                              const shad.DensityGap(shad.gapSm),
                              Text(bill.category.label),
                            ],
                          ),
                        ),
                        const shad.DensityGap(shad.gapSm),
                        shad.OutlineBadge(
                          child: Text('Internal VNO: ${bill.displayInternalVno}'),
                        ),
                      ],
                    ),
                    bill.isPaid
                        ? const shad.SecondaryBadge(child: Text('PAID'))
                        : const shad.OutlineBadge(child: Text('PENDING')),
                  ],
                ),
                Text(
                  'Bill Date: $dateStr • Party / Supplier: ${bill.partyName} • Quality: ${bill.primaryQuality}',
                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                ),
                const shad.DensityGap(shad.gapMd),
                const shad.Divider(),
                const shad.DensityGap(shad.gapMd),

                // Financial Metrics Grid
                Row(
                  children: [
                    _buildMetricTile(context, 'Total Meters', '${bill.totMts.toStringAsFixed(1)} m'),
                    _buildMetricTile(context, 'Total Pieces', '${bill.totPcs} Pcs'),
                    if (bill.billAmt > 0)
                      _buildMetricTile(context, 'Bill Amount', '₹${bill.billAmt.toStringAsFixed(2)}'),
                    if (bill.grossAmt > 0)
                      _buildMetricTile(context, 'Gross Amt', '₹${bill.grossAmt.toStringAsFixed(2)}'),
                    if (bill.vatAmt > 0)
                      _buildMetricTile(context, 'GST (${bill.vatRate.toStringAsFixed(1)}%)', '₹${bill.vatAmt.toStringAsFixed(2)}'),
                    _buildMetricTile(context, 'Net Final Amt', '₹${bill.finalAmt.toStringAsFixed(2)}', isPrimary: true),
                    _buildMetricTile(context, 'Avg Rate/m', '₹${bill.calculatedAvgRate.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapMd),

          // ==========================================
          // 2. UNDERLYING LINE ITEMS DATA TABLE (WITH SKELETON LOADING)
          // ==========================================
          Expanded(
            child: shad.Card(
              borderColor: colors.border,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Header Title Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: padMd, vertical: padSm),
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.4),
                      border: Border(bottom: BorderSide(color: colors.border)),
                    ),
                    child: Row(
                      children: [
                        Icon(shad.LucideIcons.list, size: 16 * theme.scaling, color: colors.mutedForeground),
                        const shad.DensityGap(shad.gapSm),
                        Text(
                          isLoadingItems
                              ? 'Loading Line Items...'
                              : 'Underlying Line Items (${bill.items.length})',
                          style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (isLoadingItems) ...[
                          const shad.DensityGap(shad.gapMd),
                          SizedBox(
                            width: 12 * theme.scaling,
                            height: 12 * theme.scaling,
                            child: const shad.CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ]
                      ],
                    ),
                  ),

                  // Dynamic Table Header Row
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: padMd, vertical: padSm),
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.2),
                      border: Border(bottom: BorderSide(color: colors.border)),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell(context, 'ID / SRNO', width: 75 * theme.scaling),
                        Expanded(flex: 3, child: _buildHeaderCell(context, 'Quality')),
                        Expanded(flex: 3, child: _buildHeaderCell(context, 'Party / Mill')),
                        _buildHeaderCell(context, 'Meters', width: 95 * theme.scaling),
                        _buildHeaderCell(context, 'Pcs', width: 55 * theme.scaling),
                        if (source != LineItemSourceTable.billdet) ...[
                          _buildHeaderCell(context, 'Challan #', width: 90 * theme.scaling),
                          _buildHeaderCell(context, 'Challan Date', width: 90 * theme.scaling),
                          _buildHeaderCell(context, 'Dispatch Date', width: 90 * theme.scaling),
                        ] else ...[
                          Expanded(flex: 2, child: _buildHeaderCell(context, 'Details / HSN')),
                        ],
                        _buildHeaderCell(context, 'Rate', width: 80 * theme.scaling),
                        _buildHeaderCell(context, 'Amount', width: 95 * theme.scaling),
                        _buildHeaderCell(context, 'Status', width: 70 * theme.scaling),
                      ],
                    ),
                  ),

                  // Table Rows or Skeleton Feedback
                  Expanded(
                    child: isLoadingItems
                        ? ListView.builder(
                            itemCount: 4,
                            padding: EdgeInsets.all(padMd),
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(bottom: 12 * theme.scaling),
                              child: Row(
                                children: [
                                  shad.Bone(width: 50 * theme.scaling, height: 16 * theme.scaling),
                                  const shad.DensityGap(shad.gapMd),
                                  Expanded(child: shad.Bone(height: 16 * theme.scaling)),
                                  const shad.DensityGap(shad.gapMd),
                                  shad.Bone(width: 80 * theme.scaling, height: 16 * theme.scaling),
                                  const shad.DensityGap(shad.gapMd),
                                  shad.Bone(width: 60 * theme.scaling, height: 16 * theme.scaling),
                                ],
                              ),
                            ),
                          )
                        : bill.items.isEmpty
                            ? Center(
                                child: Text(
                                  'No underlying line items found for this bill.',
                                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                ),
                              )
                            : ListView.separated(
                                itemCount: bill.items.length,
                                separatorBuilder: (context, index) => shad.Divider(
                                  height: 1,
                                  color: colors.border.withValues(alpha: 0.5),
                                ),
                                itemBuilder: (context, index) {
                                  final item = bill.items[index];
                                  final wchdatStr = item.challanDate != null ? DateFormat('dd MMM').format(item.challanDate!) : '-';
                                  final ddateStr = item.dispatchDate != null ? DateFormat('dd MMM').format(item.dispatchDate!) : '-';

                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: padMd, vertical: padSm),
                                    child: Row(
                                      children: [
                                        // 1. ID / SRNO
                                        SizedBox(
                                          width: 75 * theme.scaling,
                                          child: Text(
                                            '#${item.id}',
                                            style: theme.typography.mono.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: theme.typography.xSmall.fontSize,
                                            ),
                                          ),
                                        ),
                                        // 2. Quality
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.qual,
                                            style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // 3. Party / Mill
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.partyName,
                                            style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // 4. Meters
                                        SizedBox(
                                          width: 95 * theme.scaling,
                                          child: Text(
                                            '${item.meters.toStringAsFixed(1)} m',
                                            style: theme.typography.mono.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: theme.typography.xSmall.fontSize,
                                            ),
                                          ),
                                        ),
                                        // 5. Pcs
                                        SizedBox(
                                          width: 55 * theme.scaling,
                                          child: Text(
                                            '${item.pieces}',
                                            style: theme.typography.mono.copyWith(fontSize: theme.typography.xSmall.fontSize),
                                          ),
                                        ),
                                        // 6-8. Challan & Dispatch Dates (for PINVTRN & MILLREC) or Details (for BILLDET)
                                        if (source != LineItemSourceTable.billdet) ...[
                                          SizedBox(
                                            width: 90 * theme.scaling,
                                            child: Text(
                                              item.challanNo ?? '-',
                                              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 90 * theme.scaling,
                                            child: Text(
                                              wchdatStr,
                                              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 90 * theme.scaling,
                                            child: Text(
                                              ddateStr,
                                              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                            ),
                                          ),
                                        ] else ...[
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.details ?? item.hsnCode ?? '-',
                                              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                        // 9. Rate
                                        SizedBox(
                                          width: 80 * theme.scaling,
                                          child: Text(
                                            '₹${item.rate.toStringAsFixed(2)}',
                                            style: theme.typography.mono.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: theme.typography.xSmall.fontSize,
                                            ),
                                          ),
                                        ),
                                        // 10. Amount
                                        SizedBox(
                                          width: 95 * theme.scaling,
                                          child: Text(
                                            '₹${item.amount.toStringAsFixed(2)}',
                                            style: theme.typography.mono.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: theme.typography.xSmall.fontSize,
                                            ),
                                          ),
                                        ),
                                        // 11. Status
                                        SizedBox(
                                          width: 70 * theme.scaling,
                                          child: item.isClosed
                                              ? const shad.SecondaryBadge(child: Text('Closed'))
                                              : const shad.OutlineBadge(child: Text('Open')),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, {bool isPrimary = false}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const shad.DensityGap(shad.gapSm),
          Text(
            value,
            style: theme.typography.mono.copyWith(
              fontSize: theme.typography.textSmall.fontSize,
              fontWeight: FontWeight.bold,
              color: isPrimary ? colors.primary : colors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String title, {double? width}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final widget = Text(
      title.toUpperCase(),
      style: theme.typography.xSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: colors.mutedForeground,
        letterSpacing: 0.5,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: widget);
    }
    return widget;
  }
}
