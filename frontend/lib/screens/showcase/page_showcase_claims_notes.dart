import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseClaimsNotes extends StatefulWidget {
  const PageShowcaseClaimsNotes({super.key});

  @override
  State<PageShowcaseClaimsNotes> createState() => _PageShowcaseClaimsNotesState();
}

class _PageShowcaseClaimsNotesState extends State<PageShowcaseClaimsNotes> {
  final List<Map<String, String>> _claims = const [
    {'noteNo': 'CN-2026-104', 'type': 'CREDIT NOTE', 'party': 'Ambaji Traders', 'origInv': 'INV #90481', 'reason': 'Shade Variation (Crimson Red)', 'amount': '₹48,000', 'status': 'ISSUED'},
    {'noteNo': 'DN-2026-202', 'type': 'DEBIT NOTE', 'party': 'Saraswati Dyers (Mill)', 'origInv': 'BILL #40192', 'reason': 'Damaged Border Claim', 'amount': '₹24,500', 'status': 'SETTLED'},
  ];

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Goods Return, Credit Note & Debit Note Canvas', style: theme.typography.h2),
                  Text('Process RTV return vouchers, dye house damage claims, and GST credit/debit adjustments.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.plus, size: 16),
                    SizedBox(width: 8),
                    Text('Create Credit / Debit Note'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Claims & Notes Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Credit & Debit Note Ledger', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('NOTE NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('NOTE TYPE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('PARTY / MILL', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('ORIG INVOICE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('CLAIM REASON', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      ..._claims.map((c) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(c['noteNo']!, style: theme.typography.mono.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _buildNoteTypeBadge(c['type']!))),
                              Expanded(flex: 3, child: Text(c['party']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(c['origInv']!, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground))),
                              Expanded(flex: 3, child: Text(c['reason']!, style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(c['amount']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary))),
                              Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _buildStatusBadge(c['status']!))),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteTypeBadge(String type) {
    if (type == 'CREDIT NOTE') {
      return const shad.SecondaryBadge(child: Text('Credit Note'));
    }
    return const shad.OutlineBadge(child: Text('Debit Note'));
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'SETTLED') {
      return const shad.PrimaryBadge(child: Text('Settled'));
    }
    return const shad.SecondaryBadge(child: Text('Issued'));
  }
}
