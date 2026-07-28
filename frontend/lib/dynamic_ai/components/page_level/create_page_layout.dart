import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class CreatePageLineItem {
  String name;
  String hsn;
  double qty;
  double rate;

  CreatePageLineItem({
    required this.name,
    required this.hsn,
    required this.qty,
    required this.rate,
  });

  double get amount => qty * rate;
}

class CreatePageLayout extends StatefulWidget {
  final String title;
  final String backLabel;
  final VoidCallback onBack;
  final ValueChanged<Map<String, dynamic>>? onSave;

  const CreatePageLayout({
    super.key,
    required this.title,
    required this.backLabel,
    required this.onBack,
    this.onSave,
  });

  @override
  State<CreatePageLayout> createState() => _CreatePageLayoutState();
}

class _CreatePageLayoutState extends State<CreatePageLayout> {
  final TextEditingController _partyController = TextEditingController(text: 'Ambaji Traders (Surat)');
  final TextEditingController _invoiceController = TextEditingController(text: 'INV-2026-889');
  final TextEditingController _notesController = TextEditingController();

  final List<CreatePageLineItem> _items = [
    CreatePageLineItem(name: 'Royal Silk Grey Fabric (Lot #10485-A)', hsn: '5407', qty: 1200, rate: 180.00),
    CreatePageLineItem(name: 'Chiffon Jacquard Weave (Lot #10485-B)', hsn: '5407', qty: 450, rate: 240.00),
  ];

  double get _subtotal => _items.fold(0.0, (sum, i) => sum + i.amount);
  double get _cgst => _subtotal * 0.025;
  double get _sgst => _subtotal * 0.025;
  double get _grandTotal => _subtotal + _cgst + _sgst;

  void _addItemRow() {
    setState(() {
      _items.add(CreatePageLineItem(
        name: 'New Quality Lot #${_items.length + 1}',
        hsn: '5407',
        qty: 500,
        rate: 200.00,
      ));
    });
  }

  void _removeItemRow(int idx) {
    if (_items.length <= 1) return;
    setState(() => _items.removeAt(idx));
  }

  String _formatCurrency(double val) {
    final str = val.toStringAsFixed(2);
    final parts = str.split('.');
    final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    final formattedInt = parts[0].replaceAllMapped(reg, (m) => '${m[1]},');
    return '₹$formattedInt.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT COLUMN (PRIMARY FORM CONTENT - 68%) ───────────
        Expanded(
          flex: 68,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                            // Card 1: Bill Information
                            _buildSectionCard(
                              theme,
                              colors,
                              title: 'Bill & Supplier Information',
                              icon: shad.LucideIcons.receipt,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('SUPPLIER / PARTY NAME', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                            const SizedBox(height: 6),
                                            shad.TextField(
                                              controller: _partyController,
                                              placeholder: const Text('Enter supplier name'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('INVOICE VOUCHER NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                            const SizedBox(height: 6),
                                            shad.TextField(
                                              controller: _invoiceController,
                                              placeholder: const Text('Invoice No'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('BILL DATE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                            const SizedBox(height: 6),
                                            shad.TextField(
                                              initialValue: '28/07/2026',
                                              placeholder: const Text('DD/MM/YYYY'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('DUE DATE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                            const SizedBox(height: 6),
                                            shad.TextField(
                                              initialValue: '27/08/2026 (Net 30)',
                                              placeholder: const Text('DD/MM/YYYY'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Card 2: Line Items & Fabric Lots
                            _buildSectionCard(
                              theme,
                              colors,
                              title: 'Line Item Entries & Fabric Lots',
                              icon: shad.LucideIcons.layers,
                              trailingAction: shad.PrimaryButton(
                                size: shad.ButtonSize.small,
                                density: shad.ButtonDensity.iconDense,
                                onPressed: _addItemRow,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(shad.LucideIcons.plus, size: 14),
                                    SizedBox(width: 4),
                                    Text('Add Row'),
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  ..._items.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final item = entry.value;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colors.muted.withAlpha(25),
                                        borderRadius: BorderRadius.circular(theme.radiusMd),
                                        border: Border.all(color: colors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 28,
                                            child: Text('#${idx + 1}', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(item.name, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 70,
                                            child: Text('HSN ${item.hsn}', style: theme.typography.mono.copyWith(fontSize: 12 * theme.scaling)),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 90,
                                            child: Text('${item.qty.toInt()} Mtr', style: theme.typography.mono.copyWith(fontSize: 12.5 * theme.scaling, fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 90,
                                            child: Text('₹${item.rate.toStringAsFixed(2)}', style: theme.typography.mono.copyWith(fontSize: 12.5 * theme.scaling, fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 110,
                                            child: Text(
                                              _formatCurrency(item.amount),
                                              textAlign: TextAlign.right,
                                              style: theme.typography.mono.copyWith(fontSize: 13 * theme.scaling, fontWeight: FontWeight.bold, color: colors.primary),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          shad.IconButton.ghost(
                                            size: shad.ButtonSize.small,
                                            icon: Icon(shad.LucideIcons.trash2, size: 16, color: colors.destructive),
                                            onPressed: () => _removeItemRow(idx),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Card 3: Notes & Attachment Dropzone
                            _buildSectionCard(
                              theme,
                              colors,
                              title: 'Remarks & Document Scans',
                              icon: shad.LucideIcons.paperclip,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('INTERNAL REMARKS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                  const SizedBox(height: 6),
                                  shad.TextArea(
                                    controller: _notesController,
                                    placeholder: const Text('Add payment or mill quality notes...'),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: colors.border, style: BorderStyle.solid),
                                      borderRadius: BorderRadius.circular(theme.radiusMd),
                                      color: colors.muted.withAlpha(20),
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(shad.LucideIcons.upload, size: 28, color: colors.primary),
                                          const SizedBox(height: 8),
                                          Text('Drop Bill Copy / Invoice Scans Here', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text('Supports PDF, PNG, JPG (Max 10MB)', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // ── RIGHT COLUMN (METADATA, STATUS & COMPUTATION - 32%) ────
                      Expanded(
                        flex: 32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Right Card 1: Status & Location Hub
                            _buildSectionCard(
                              theme,
                              colors,
                              title: 'Status & Location',
                              icon: shad.LucideIcons.mapPin,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PAYMENT STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                  const SizedBox(height: 6),
                                  const shad.OutlineBadge(child: Text('Pending Approval')),
                                  const SizedBox(height: 14),

                                  Text('WAREHOUSE HUB', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                  const SizedBox(height: 6),
                                  shad.TextField(
                                    initialValue: 'Surat Central Warehouse',
                                    readOnly: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Right Card 2: Financial Calculation
                            _buildSectionCard(
                              theme,
                              colors,
                              title: 'Voucher Computation',
                              icon: shad.LucideIcons.calculator,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSummaryRow(theme, colors, 'Sub Total', _formatCurrency(_subtotal)),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow(theme, colors, 'CGST (2.5%)', _formatCurrency(_cgst)),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow(theme, colors, 'SGST (2.5%)', _formatCurrency(_sgst)),
                                  const SizedBox(height: 12),
                                  const shad.Divider(),
                                  const SizedBox(height: 12),

                                  Text('GRAND TOTAL', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCurrency(_grandTotal),
                                    style: theme.typography.mono.copyWith(
                                      fontSize: 20 * theme.scaling,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Right Card 3: Vendor History Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(theme.radiusMd),
                                border: Border.all(color: colors.primary.withAlpha(50)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(shad.LucideIcons.shieldCheck, size: 16, color: colors.primary),
                                      const SizedBox(width: 8),
                                      Text('Vendor Verified', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ambaji Traders is a 5-star verified mill with 0 pending quality disputes.',
                                    style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
  }

  Widget _buildSectionCard(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailingAction,
  }) {
    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: const EdgeInsets.all(12),
      backgroundColor: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (trailingAction != null) trailingAction,
            ],
          ),
          const SizedBox(height: 6),
          const shad.Divider(),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(shad.ThemeData theme, shad.ColorScheme colors, String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.typography.textSmall.copyWith(color: colors.mutedForeground)),
        Text(val, style: theme.typography.mono.copyWith(fontSize: 13 * theme.scaling, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
