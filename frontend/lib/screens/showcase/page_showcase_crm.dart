import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseCrm extends StatefulWidget {
  const PageShowcaseCrm({super.key});

  @override
  State<PageShowcaseCrm> createState() => _PageShowcaseCrmState();
}

class _PageShowcaseCrmState extends State<PageShowcaseCrm> {
  int _selectedPartyIndex = 0;

  final List<Map<String, String>> _parties = const [
    {'name': 'Ambaji Traders (Surat)', 'city': 'Surat (HQ)', 'bal': '₹42,80,950', 'lastMsg': 'Please send design catalog PDF.'},
    {'name': 'Shree Ram Sarees (Ahm)', 'city': 'Ahmedabad', 'bal': '₹14,20,400', 'lastMsg': 'Voucher #10492 payment initialized.'},
    {'name': 'Vrindavan Textiles (Jaipur)', 'city': 'Jaipur', 'bal': '₹5,10,000', 'lastMsg': 'Sample lot received.'},
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
                  Text('CRM & Customer WhatsApp Exchange', style: theme.typography.h2),
                  Text('Master-detail customer directory, ledger balances, and WhatsApp chat history.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.messageSquare, size: 16),
                    SizedBox(width: 8),
                    Text('Send Broadcast Message'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Master Detail Split
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Party Directory List
              Expanded(
                flex: 2,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Directory', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      ...List.generate(_parties.length, (idx) {
                        final p = _parties[idx];
                        final isSelected = idx == _selectedPartyIndex;
                        return InkWell(
                          onTap: () => setState(() => _selectedPartyIndex = idx),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.primary.withAlpha(20) : null,
                              borderRadius: BorderRadius.circular(theme.radiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(p['name']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text(p['bal']!, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                                  ],
                                ),
                                Text(p['lastMsg']!, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // Right: WhatsApp Chat Bubbles Pane
              Expanded(
                flex: 3,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          shad.Avatar(initials: _parties[_selectedPartyIndex]['name']!.substring(0, 2), size: 36),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_parties[_selectedPartyIndex]['name']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                              Text(_parties[_selectedPartyIndex]['city']!, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                      const shad.DensityGap(shad.gapMd),
                      const shad.Divider(),
                      const shad.DensityGap(shad.gapMd),
                      // Chat Bubbles
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(theme.radiusMd)),
                          child: Text(_parties[_selectedPartyIndex]['lastMsg']!, style: theme.typography.textSmall),
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(theme.radiusMd)),
                          child: const Text('Catalog PDF & Voucher details sent successfully.', style: TextStyle(color: Colors.white)),
                        ),
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
}
