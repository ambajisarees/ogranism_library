import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/purchase_bills/model_purchase_bill_header.dart';

class PurchaseBillsListPane extends StatelessWidget {
  final List<PurchaseBillHeaderModel> bills;
  final PurchaseBillHeaderModel? selectedBill;
  final ValueChanged<PurchaseBillHeaderModel> onSelectBill;
  final bool isLoading;

  const PurchaseBillsListPane({
    super.key,
    required this.bills,
    required this.selectedBill,
    required this.onSelectBill,
    required this.isLoading,
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
                Text('Loading Bills...', style: theme.typography.textMuted),
              ],
            ),
          ),
        ),
      );
    }

    if (bills.isEmpty) {
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
                  Icon(shad.LucideIcons.receipt, size: 28 * theme.scaling, color: colors.mutedForeground),
                  const shad.DensityGap(shad.gapMd),
                  Text(
                    'No Bills Found',
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.mutedForeground,
                    ),
                  ),
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
        itemCount: bills.length,
        separatorBuilder: (context, index) => const shad.DensityGap(shad.gapSm),
        itemBuilder: (context, index) {
          final item = bills[index];
          final isSelected = selectedBill?.vno == item.vno && selectedBill?.cno == item.cno;
          final dateStr = DateFormat('dd MMM yyyy').format(item.billDate);

          return InkWell(
            onTap: () => onSelectBill(item),
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
                    // Row 1: Internal VNO + Weaver/Mill/Party Bill # & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.displayBillNo,
                            style: theme.typography.mono.copyWith(
                              fontSize: theme.typography.textSmall.fontSize,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? colors.primary : colors.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        item.isPaid
                            ? const shad.SecondaryBadge(child: Text('PAID'))
                            : const shad.OutlineBadge(child: Text('PENDING')),
                      ],
                    ),
                    Text(
                      'Internal VNO: ${item.displayInternalVno} • $dateStr',
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),

                    // Row 2: Party Name (from sq_BILLS.code)
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

                    // Row 3: Totals & Net Amount (from sq_BILLS)
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
