import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseAddProduct extends StatefulWidget {
  const PageShowcaseAddProduct({super.key});

  @override
  State<PageShowcaseAddProduct> createState() => _PageShowcaseAddProductState();
}

class _PageShowcaseAddProductState extends State<PageShowcaseAddProduct> {
  final TextEditingController _voucherNoController = TextEditingController(text: 'VNO #10495');
  final TextEditingController _partyController = TextEditingController(text: 'Ambaji Traders (Surat)');
  final TextEditingController _notesController = TextEditingController(text: 'Special embroidery processing required for design batch.');

  final List<Map<String, String>> _lineItems = [
    {'design': 'D-4089 Royal Silk Saree', 'qty': '500 Pcs', 'rate': '₹2,400', 'amount': '₹12,000,00'},
    {'design': 'D-3021 Chiffon Jacquard', 'qty': '250 Pcs', 'rate': '₹1,850', 'amount': '₹4,62,500'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Design Voucher Entry (Add Form)', style: theme.typography.h2),
                  Text('Create new purchase/sales voucher with multi-line item grid, GST terms, and design attachments.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.OutlineButton(
                onPressed: () {},
                child: const Text('Cancel Entry'),
              ),
              const shad.DensityGap(shad.gapSm),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.save, size: 16),
                    SizedBox(width: 8),
                    Text('Save & Issue Voucher'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Header Inputs (Party, Voucher No, Dates)
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Voucher Header Information', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 20 * theme.scaling,
                  runSpacing: 16 * theme.scaling,
                  children: [
                    _buildFormInput(
                      label: 'Voucher Number (Disabled)',
                      width: 240,
                      child: shad.TextField(controller: _voucherNoController, enabled: false),
                    ),
                    _buildFormInput(
                      label: 'Party Name / Customer',
                      width: 300,
                      child: shad.TextField(
                        controller: _partyController,
                        features: [
                          shad.InputFeature.trailing(
                            Icon(shad.LucideIcons.search, size: 16, color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    _buildFormInput(
                      label: 'Voucher Date',
                      width: 240,
                      child: const shad.TextField(
                        placeholder: Text('25/07/2026'),
                        features: [
                          shad.InputFeature.trailing(
                            Icon(shad.LucideIcons.calendar, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // Multi-Line Item Table Grid
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Line Items Entry Grid', style: theme.typography.h3),
                    const Spacer(),
                    shad.OutlineButton(
                      onPressed: () {
                        setState(() {
                          _lineItems.add({
                            'design': 'D-5100 Organza Print',
                            'qty': '100 Pcs',
                            'rate': '₹3,200',
                            'amount': '₹3,20,000',
                          });
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(shad.LucideIcons.plus, size: 14),
                          SizedBox(width: 6),
                          Text('Add Item Row'),
                        ],
                      ),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: Text('DESIGN PATTERN / DESCRIPTION', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('QUANTITY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('RATE PRICE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 48, child: Text('ACTION', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      ..._lineItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(flex: 4, child: Text(item['design']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text(item['qty']!, style: theme.typography.textSmall)),
                                  Expanded(flex: 2, child: Text(item['rate']!, style: theme.typography.textSmall)),
                                  Expanded(flex: 2, child: Text(item['amount']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                                  SizedBox(
                                    width: 48,
                                    child: IconButton(
                                      icon: const Icon(shad.LucideIcons.trash2, size: 16, color: Colors.red),
                                      onPressed: () => setState(() => _lineItems.removeAt(idx)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (idx < _lineItems.length - 1) const shad.Divider(),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // Bottom Split: Notes & File Upload Dropzone
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notes
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voucher Remarks & Special Terms', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      shad.TextArea(controller: _notesController, maxLines: 4),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // File Drop Zone
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Design Attachments & Invoice PDF', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: colors.muted.withAlpha(100),
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          border: Border.all(color: colors.border, style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(shad.LucideIcons.upload, size: 28, color: colors.primary),
                              const SizedBox(height: 6),
                              Text('Click or Drag & Drop Design Artworks / PDF Files', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                            ],
                          ),
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

  Widget _buildFormInput({required String label, required double width, required Widget child}) {
    final theme = shad.Theme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.mutedForeground)),
          const shad.DensityGap(shad.gapSm),
          child,
        ],
      ),
    );
  }
}
