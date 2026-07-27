import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseOrderDetail extends StatefulWidget {
  const PageShowcaseOrderDetail({super.key});

  @override
  State<PageShowcaseOrderDetail> createState() => _PageShowcaseOrderDetailState();
}

class _PageShowcaseOrderDetailState extends State<PageShowcaseOrderDetail> {
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
              shad.OutlineButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.arrowLeft, size: 16),
                    SizedBox(width: 6),
                    Text('Back to Order Ledger'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Voucher Detail Canvas (#PO-2026-901)', style: theme.typography.h2),
                  Text('Party: Ambaji Traders (Surat) • Created Jul 24, 2026', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              const shad.PrimaryBadge(child: Text('Status: Processing Stage 3')),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 4-Stage Milestone Progress Tracker Bar
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Life-Cycle Multi-Stage Progress Tracker', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Row(
                  children: [
                    _buildTrackerStep(context, step: '1. PO Issued', isDone: true, isCurrent: false),
                    _buildChevron(context),
                    _buildTrackerStep(context, step: '2. Grey Fabric Cutting', isDone: true, isCurrent: false),
                    _buildChevron(context),
                    _buildTrackerStep(context, step: '3. Job Stitching & Dyeing', isDone: true, isCurrent: true),
                    _buildChevron(context),
                    _buildTrackerStep(context, step: '4. Purchase Bill Settled', isDone: false, isCurrent: false),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // Detail Content Split (Line Items + Summary Card)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line Items Grid
              Expanded(
                flex: 3,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voucher Line Items', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      shad.OutlinedContainer(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: colors.muted.withAlpha(120),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text('ITEM DESCRIPTION', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('QUANTITY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('RATE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                            const shad.Divider(),
                            _buildLineRow(context, desc: 'Royal Zari Silk Saree #D-4089', qty: '800 Pcs', rate: '₹2,400', amount: '₹19,20,000'),
                            const shad.Divider(),
                            _buildLineRow(context, desc: 'Chiffon Jacquard Printed #D-3021', qty: '400 Pcs', rate: '₹1,850', amount: '₹7,40,000'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // Summary Card
              Expanded(
                flex: 2,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Summary & Taxes', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      _buildSummaryRow(context, label: 'Subtotal Amount', val: '₹26,60,000'),
                      _buildSummaryRow(context, label: 'SGST (2.5%)', val: '₹66,500'),
                      _buildSummaryRow(context, label: 'CGST (2.5%)', val: '₹66,500'),
                      const shad.Divider(),
                      _buildSummaryRow(context, label: 'Grand Total Amount', val: '₹27,93,000', isBold: true),
                      const shad.DensityGap(shad.gapLg),
                      shad.PrimaryButton(
                        onPressed: () {},
                        child: const Center(child: Text('Download Voucher Tax PDF')),
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

  Widget _buildTrackerStep(BuildContext context, {required String step, required bool isDone, required bool isCurrent}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isDone ? colors.primary : colors.muted,
          borderRadius: BorderRadius.circular(theme.radiusMd),
        ),
        child: Row(
          children: [
            Icon(isDone ? shad.LucideIcons.circleCheck : shad.LucideIcons.circle, size: 16, color: isDone ? Colors.white : colors.mutedForeground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                step,
                style: theme.typography.xSmall.copyWith(
                  color: isDone ? Colors.white : colors.mutedForeground,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChevron(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(shad.LucideIcons.chevronRight, size: 14, color: shad.Theme.of(context).colorScheme.mutedForeground),
    );
  }

  Widget _buildLineRow(BuildContext context, {required String desc, required String qty, required String rate, required String amount}) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(desc, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(qty, style: theme.typography.textSmall)),
          Expanded(flex: 2, child: Text(rate, style: theme.typography.textSmall)),
          Expanded(flex: 2, child: Text(amount, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, {required String label, required String val, bool isBold = false}) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
          const Spacer(),
          Text(val, style: isBold ? theme.typography.h3.copyWith(color: theme.colorScheme.primary) : theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
