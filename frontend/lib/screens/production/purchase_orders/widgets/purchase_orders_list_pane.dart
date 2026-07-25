import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/purchase_orders/model_purchase_order_header.dart';

class PurchaseOrdersListPane extends StatelessWidget {
  final List<PurchaseOrderHeaderModel> orders;
  final PurchaseOrderHeaderModel? selectedOrder;
  final ValueChanged<PurchaseOrderHeaderModel> onSelectOrder;
  final bool isLoading;
  final bool isEmptyModule;

  const PurchaseOrdersListPane({
    super.key,
    required this.orders,
    required this.selectedOrder,
    required this.onSelectOrder,
    required this.isLoading,
    this.isEmptyModule = false,
  });

  String _truncateName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) return name;
    return '${words[0]} ${words[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final paneWidth = 300.0 * theme.scaling;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    if (isLoading) {
      return SizedBox(
        width: paneWidth,
        child: shad.Card(
          borderColor: colors.border,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const shad.CircularProgressIndicator(),
                const shad.DensityGap(shad.gapMd),
                Text('Loading Purchase Orders...', style: theme.typography.textMuted),
              ],
            ),
          ),
        ),
      );
    }

    if (isEmptyModule || orders.isEmpty) {
      return SizedBox(
        width: paneWidth,
        child: shad.Card(
          borderColor: colors.border,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(padSm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEmptyModule ? shad.LucideIcons.packageOpen : shad.LucideIcons.fileText,
                    size: 28 * theme.scaling,
                    color: colors.mutedForeground,
                  ),
                  const shad.DensityGap(shad.gapMd),
                  Text(
                    isEmptyModule ? 'Module Empty For Now' : 'No Purchase Orders Found',
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.mutedForeground,
                    ),
                  ),
                  if (isEmptyModule) ...[
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      'Grey Purchase Orders workflow setup pending.',
                      textAlign: TextAlign.center,
                      style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: paneWidth,
      child: ListView.separated(
        itemCount: orders.length,
        separatorBuilder: (context, index) => const shad.DensityGap(shad.gapSm),
        itemBuilder: (context, index) {
          final item = orders[index];
          final isSelected = selectedOrder?.vno == item.vno && selectedOrder?.cno == item.cno;
          final dateStr = DateFormat('dd MMM yyyy').format(item.orderDate);

          return InkWell(
            onTap: () => onSelectOrder(item),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? colors.accent.withValues(alpha: 0.25) : Colors.transparent,
                borderRadius: theme.borderRadiusSm,
              ),
              child: shad.Card(
                borderColor: isSelected ? colors.primary : colors.border,
                padding: EdgeInsets.all(padSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Order # & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.displayOrderNo,
                            style: theme.typography.mono.copyWith(
                              fontSize: theme.typography.textSmall.fontSize,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? colors.primary : colors.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const shad.OutlineBadge(child: Text('ACTIVE')),
                      ],
                    ),
                    Text(
                      'VNO: ${item.displayInternalVno} • $dateStr',
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),

                    // Row 2: Vendor / Party Name
                    Text(
                      _truncateName(item.partyName),
                      style: theme.typography.textSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.primaryQuality,
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const shad.DensityGap(shad.gapSm),
                    const shad.Divider(),
                    const shad.DensityGap(shad.gapSm),

                    // Row 3: Quantities & Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.totMts.toStringAsFixed(1)}m (${item.totPcs} pcs)',
                          style: theme.typography.xSmall.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        Text(
                          '₹${item.finalAmt.toStringAsFixed(2)}',
                          style: theme.typography.mono.copyWith(
                            fontSize: theme.typography.textSmall.fontSize,
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
