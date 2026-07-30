/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE BILLS DETAIL CANVAS (scr_pb_detail_canvas.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Detailed inspection canvas & line-items table for a selected Purchase Bill header.
   - Renders summary metric tiles (Party, Quality, Supplier Bill No, Total Amount) 
     and eagerly-loaded detail line items (`sq_BILLDET`, `sq_PINVTRN`, or `sq_MILLREC`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Accepts module domain model `MdlPbHeader`.
   - Uses native `shadcn_flutter` components (`shad.Card`, `shad.OutlinedContainer`, `shad.Badge`).
   - Line items table specs: `SR NO`, `QUALITY`, `PCS`, `METERS`, `RATE`, `AMOUNT`.
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../models/production/mdl_pb.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';

/// [ScrPbDetailCanvas] — Inspector & Line-Items Breakdown Canvas for Purchase Bills.
class ScrPbDetailCanvas extends StatelessWidget {
  final MdlPbHeader header;
  final VoidCallback? onClose;

  const ScrPbDetailCanvas({
    super.key,
    required this.header,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final h = header;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Summary Card
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                          ),
                          child: Icon(
                            shad.LucideIcons.fileText,
                            size: 20,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bill ${h.displayBillNo}',
                              style: theme.typography.h3.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Bill Date: ${h.formattedDate}',
                              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        h.isCompleted
                            ? const shad.PrimaryBadge(child: Text('COMPLETED'))
                            : const shad.OutlineBadge(child: Text('PENDING')),
                        if (onClose != null) ...[
                          const SizedBox(width: 8),
                          shad.GhostButton(
                            onPressed: onClose,
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                shad.Divider(color: colors.border),
                const SizedBox(height: 16),

                // Party & Quality Grid
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SUPPLIER / PARTY', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                          const SizedBox(height: 4),
                          Text(h.partyName, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PRIMARY QUALITY', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                          const SizedBox(height: 4),
                          Text(h.primaryQuality, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SUPPLIER BILL NO', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                          const SizedBox(height: 4),
                          Text(h.weaverBillNo.isNotEmpty ? h.weaverBillNo : 'N/A', style: theme.typography.mono.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Financial Summary Stat Tiles
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'TOTAL NET AMOUNT',
                  value: h.formattedFinalAmount,
                  subValue: 'Final Landed Cost',
                  icon: shad.LucideIcons.indianRupee,
                  accentColor: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'TOTAL QUANTITY',
                  value: h.formattedQuantity,
                  subValue: '${h.lineItems.length} Line Items',
                  icon: shad.LucideIcons.packageCheck,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Line Items Breakdown Table
          Text(
            'Line-Items Breakdown (${h.lineItems.length} Items)',
            style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (h.lineItems.isEmpty)
            shad.OutlinedContainer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('No detail line items recorded for this purchase bill', style: theme.typography.textMuted),
                ),
              ),
            )
          else
            DynamicDenseTable(
              rows: h.lineItems.map((item) {
                return DynamicTableRowData(
                  id: item.srNo.toString(),
                  voucherNo: item.srNo.toString(),
                  partyName: '',
                  designPattern: item.quality.isNotEmpty ? item.quality : 'N/A',
                  quantity: item.meters > 0 ? '${item.meters.toStringAsFixed(1)} Mtr' : '-',
                  amount: item.formattedAmount(),
                  amountValue: item.amount,
                  status: '',
                  rawData: {
                    'pcs': item.pcs > 0 ? item.pcs.toString() : '-',
                    'rate': item.rate > 0 ? '₹${item.rate.toStringAsFixed(2)}' : '-',
                  },
                );
              }).toList(),
              columns: const [
                DynamicTableColumnSpec(label: 'SR #', key: 'vno', width: 70),
                DynamicTableColumnSpec(label: 'QUALITY', key: 'fabric', flex: 2),
                DynamicTableColumnSpec(label: 'PCS', key: 'totalPcs', alignment: Alignment.centerRight, flex: 1),
                DynamicTableColumnSpec(label: 'METERS', key: 'totalMtrs', alignment: Alignment.centerRight, flex: 1),
                DynamicTableColumnSpec(label: 'RATE', key: 'rate', alignment: Alignment.centerRight, flex: 1),
                DynamicTableColumnSpec(label: 'AMOUNT', key: 'amount', alignment: Alignment.centerRight, flex: 1),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String subValue,
    required IconData icon,
    Color? accentColor,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final primaryColor = accentColor ?? colors.mutedForeground;

    return shad.OutlinedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground, letterSpacing: 0.5)),
              Icon(icon, size: 14, color: primaryColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subValue, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
        ],
      ),
    );
  }
}
