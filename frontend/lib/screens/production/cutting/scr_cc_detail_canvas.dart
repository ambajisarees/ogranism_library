/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Detail Inspection Canvas for Multi-Cutting Cards (`cc`).
   - Renders complete cutting card audit metrics, scanned physical cutting card receipt image 
     preview (`sb_cardpic`), and detail cut pieces line items (`sb_cutdet`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Displays 4 Key Metric Badges: Fresh Sarees Cut, Fresh Yield %, Cost Per Piece (₹), Total Investment (₹).
   - Scanned Card Picture (`sb_cardpic`): Displays physical image receipt uploaded from mill.
   - Clean native `shadcn_flutter` styling (Card, OutlinedContainer, Badge, DensityGap).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - If `sb_cardpic` is null, renders an elegant fallback canvas placeholder with cutting icon.
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../models/production/mdl_cc.dart';
import '../../../dynamic_ai/page/dy_table_pane.dart';

/// [ScrCcDetailCanvas] — Inspector & Detail Canvas for Multi-Cutting Cards.
class ScrCcDetailCanvas extends StatelessWidget {
  final MdlCcHeader card;
  final VoidCallback? onClose;

  const ScrCcDetailCanvas({
    super.key,
    required this.card,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Card & Key Metadata
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
                            shad.LucideIcons.scissors,
                            size: 20,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.displayCcCode,
                              style: theme.typography.h3.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Cut Date: ${card.formattedCutDate}',
                              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        card.isCompleted
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

                // Mill & Quality Info Grid
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MILL / PROCESSOR', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                          const SizedBox(height: 4),
                          Text(card.millName, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GREY FABRIC QUALITY', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                          const SizedBox(height: 4),
                          Text(card.greyQuality, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CUT LENGTH', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                          const SizedBox(height: 4),
                          Text(card.formattedCutLength, style: theme.typography.mono.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Metric Stat Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'FRESH SAREES',
                  value: '${card.totalFreshPcs} Pcs',
                  subValue: '${card.formattedReceivedMeters} Received',
                  icon: shad.LucideIcons.packageCheck,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'FRESH YIELD',
                  value: card.formattedFreshYield,
                  subValue: 'Target: 85.0%',
                  icon: shad.LucideIcons.percent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'COST / SAREE',
                  value: card.formattedCostPerPc,
                  subValue: 'Grey + Processing',
                  icon: shad.LucideIcons.tag,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'TOTAL INVESTMENT',
                  value: card.formattedTotalInvestment,
                  subValue: 'Batch Inventory',
                  icon: shad.LucideIcons.indianRupee,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Scanned Cutting Card Picture Preview Section
          shad.OutlinedContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(shad.LucideIcons.fileImage, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Scanned Physical Cutting Card Receipt',
                      style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (card.cardPicPath != null && card.cardPicPath!.isNotEmpty)
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: colors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://vdprvitkijzxruhcgsin.supabase.co/storage/v1/object/public/${card.cardPicPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildCardPicPlaceholder(theme, colors),
                    ),
                  )
                else
                  _buildCardPicPlaceholder(theme, colors),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Detail Cut Pieces Table
          Text(
            'Detail Cut Pieces Breakdown (${card.lineItems.length} Cut Items)',
            style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (card.lineItems.isEmpty)
            shad.OutlinedContainer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('No detail cut pieces recorded for this card', style: theme.typography.textMuted),
                ),
              ),
            )
          else
            DynamicDenseTable(
              rows: card.lineItems.map((item) {
                return DynamicTableRowData(
                  id: item.vno.toString(),
                  voucherNo: item.vno.toString(),
                  partyName: '',
                  designPattern: item.quality,
                  quantity: '${item.meters.toStringAsFixed(1)} Mtr',
                  amount: item.formattedAmount(),
                  amountValue: item.amount,
                  status: '',
                  rawData: {
                    'pcs': item.pieces > 0 ? item.pieces.toInt().toString() : '-',
                    'rate': item.rate > 0 ? '₹${item.rate.toStringAsFixed(2)}' : '-',
                  },
                );
              }).toList(),
              columns: const [
                DynamicTableColumnSpec(label: 'VOUCHER #', key: 'vno', width: 110),
                DynamicTableColumnSpec(label: 'QUALITY', key: 'fabric', flex: 2),
                DynamicTableColumnSpec(label: 'METERS', key: 'totalMtrs', alignment: Alignment.centerRight, flex: 1),
                DynamicTableColumnSpec(label: 'PCS', key: 'totalPcs', alignment: Alignment.centerRight, flex: 1),
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
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.OutlinedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground, letterSpacing: 0.5)),
              Icon(icon, size: 14, color: colors.mutedForeground),
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

  Widget _buildCardPicPlaceholder(shad.ThemeData theme, shad.ColorScheme colors) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.muted.withAlpha(50),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: colors.border.withAlpha(100)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shad.LucideIcons.fileQuestion, size: 24, color: colors.mutedForeground),
            const SizedBox(width: 8),
            const SizedBox(height: 6),
            Text(
              'No Physical Scanned Receipt Attached',
              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
