import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/purchase_orders/purchase_order_category.dart';
import '../../../../models/production/purchase_orders/model_purchase_order_header.dart';

class PurchaseOrdersDetailCanvas extends StatelessWidget {
  final PurchaseOrderHeaderModel? selectedOrder;
  final bool isLoadingItems;
  final bool isEmptyModule;

  const PurchaseOrdersDetailCanvas({
    super.key,
    this.selectedOrder,
    this.isLoadingItems = false,
    this.isEmptyModule = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final padMd = theme.density.baseContainerPadding * theme.scaling * shad.padMd;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    if (isEmptyModule) {
      return Expanded(
        child: shad.Card(
          borderColor: colors.border,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.packageOpen, size: 36 * theme.scaling, color: colors.mutedForeground),
                const shad.DensityGap(shad.gapMd),
                Text(
                  'Grey Purchase Orders Empty',
                  style: theme.typography.h3.copyWith(color: colors.mutedForeground),
                ),
                const shad.DensityGap(shad.gapSm),
                Text(
                  'The Grey Purchase Order workflow is empty for now. Select Finish, Lace, Studio or Packing to view live purchase orders.',
                  textAlign: TextAlign.center,
                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (selectedOrder == null) {
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
                  'Select a Purchase Order to View Details',
                  style: theme.typography.h3.copyWith(color: colors.mutedForeground),
                ),
                const shad.DensityGap(shad.gapSm),
                Text(
                  'Select a card from the left panel to display financial breakdown & underlying order line items.',
                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final order = selectedOrder!;
    final dateStr = DateFormat('dd MMM yyyy').format(order.orderDate);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // 1. ORDER HEADER & FINANCIAL CANVAS CARD
          // ==========================================
          shad.Card(
            borderColor: colors.border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Line: Order #, Category Badge, Internal VNO, Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.displayOrderNo,
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
                              Icon(order.category.icon, size: 12 * theme.scaling),
                              const shad.DensityGap(shad.gapSm),
                              Text(order.category.label),
                            ],
                          ),
                        ),
                        const shad.DensityGap(shad.gapSm),
                        shad.OutlineBadge(
                          child: Text('VNO: ${order.displayInternalVno}'),
                        ),
                      ],
                    ),
                    const shad.OutlineBadge(child: Text('ACTIVE')),
                  ],
                ),
                Text(
                  'Order Date: $dateStr • Vendor / Supplier: ${order.partyName} • Quality: ${order.primaryQuality}',
                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                ),
                const shad.DensityGap(shad.gapMd),
                const shad.Divider(),
                const shad.DensityGap(shad.gapMd),

                // Financial Metrics Grid
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMetricTile(context, 'Total Meters', '${order.totMts.toStringAsFixed(1)} m'),
                      _buildMetricTile(context, 'Total Pieces', '${order.totPcs} Pcs'),
                      if (order.billAmt > 0)
                        _buildMetricTile(context, 'Order Amount', '₹${order.billAmt.toStringAsFixed(2)}'),
                      if (order.grossAmt > 0)
                        _buildMetricTile(context, 'Gross Amt', '₹${order.grossAmt.toStringAsFixed(2)}'),
                      _buildMetricTile(context, 'Net Final Amt', '₹${order.finalAmt.toStringAsFixed(2)}', isPrimary: true),
                      _buildMetricTile(context, 'Avg Rate/m', '₹${(order.totMts > 0 ? order.finalAmt / order.totMts : order.avgRate).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapMd),

          // ==========================================
          // 2. UNDERLYING LINE ITEMS DATA TABLE
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
                              : 'Order Line Items (${order.items.length})',
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
                        _buildHeaderCell(context, 'SRNO', width: 65 * theme.scaling),
                        Expanded(flex: 3, child: _buildHeaderCell(context, 'Quality')),
                        Expanded(flex: 3, child: _buildHeaderCell(context, 'Description / Details')),
                        _buildHeaderCell(context, 'Meters', width: 95 * theme.scaling),
                        _buildHeaderCell(context, 'Pcs', width: 55 * theme.scaling),
                        _buildHeaderCell(context, 'Rate', width: 85 * theme.scaling),
                        _buildHeaderCell(context, 'Amount', width: 100 * theme.scaling),
                        _buildHeaderCell(context, 'Status', width: 75 * theme.scaling),
                      ],
                    ),
                  ),

                  // Table Rows or Skeleton Feedback
                  Expanded(
                    child: isLoadingItems
                        ? ListView.builder(
                            itemCount: 3,
                            padding: EdgeInsets.all(padMd),
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(bottom: 12 * theme.scaling),
                              child: Row(
                                children: [
                                  Opacity(opacity: 0.35, child: shad.Bone(width: 40 * theme.scaling, height: 16 * theme.scaling)),
                                  const shad.DensityGap(shad.gapMd),
                                  Expanded(child: Opacity(opacity: 0.35, child: shad.Bone(height: 16 * theme.scaling))),
                                  const shad.DensityGap(shad.gapMd),
                                  Opacity(opacity: 0.35, child: shad.Bone(width: 80 * theme.scaling, height: 16 * theme.scaling)),
                                ],
                              ),
                            ),
                          )
                        : order.items.isEmpty
                            ? Center(
                                child: Text(
                                  'No underlying line items found for this order.',
                                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                ),
                              )
                            : ListView.separated(
                                itemCount: order.items.length,
                                separatorBuilder: (context, index) => shad.Divider(
                                  height: 1,
                                  color: colors.border.withValues(alpha: 0.5),
                                ),
                                itemBuilder: (context, index) {
                                  final item = order.items[index];

                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: padMd, vertical: padSm),
                                    child: Row(
                                      children: [
                                        // 1. SRNO
                                        SizedBox(
                                          width: 65 * theme.scaling,
                                          child: Text(
                                            '#${item.srno}',
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
                                        // 3. Details
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.details ?? '-',
                                            style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // 4. Meters
                                        SizedBox(
                                          width: 95 * theme.scaling,
                                          child: Text(
                                            '${item.mts.toStringAsFixed(1)} m',
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
                                            '${item.pcs}',
                                            style: theme.typography.mono.copyWith(fontSize: theme.typography.xSmall.fontSize),
                                          ),
                                        ),
                                        // 6. Rate
                                        SizedBox(
                                          width: 85 * theme.scaling,
                                          child: Text(
                                            '₹${item.rate.toStringAsFixed(2)}',
                                            style: theme.typography.mono.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: theme.typography.xSmall.fontSize,
                                            ),
                                          ),
                                        ),
                                        // 7. Amount
                                        SizedBox(
                                          width: 100 * theme.scaling,
                                          child: Text(
                                            '₹${item.amt.toStringAsFixed(2)}',
                                            style: theme.typography.mono.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: theme.typography.xSmall.fontSize,
                                            ),
                                          ),
                                        ),
                                        // 8. Status
                                        SizedBox(
                                          width: 75 * theme.scaling,
                                          child: item.isPending
                                              ? const shad.OutlineBadge(child: Text('Pending'))
                                              : const shad.SecondaryBadge(child: Text('Closed')),
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
    return Padding(
      padding: EdgeInsets.only(right: 20 * theme.scaling),
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
