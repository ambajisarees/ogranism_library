import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseOrderList extends StatefulWidget {
  const PageShowcaseOrderList({super.key});

  @override
  State<PageShowcaseOrderList> createState() => _PageShowcaseOrderListState();
}

class _PageShowcaseOrderListState extends State<PageShowcaseOrderList> {
  final Set<int> _selectedIndices = {0, 1};

  final List<Map<String, dynamic>> _orders = const [
    {'id': '#PO-2026-901', 'party': 'Ambaji Traders', 'date': '24/07/2026', 'qty': '1,200 Mtr', 'amount': '₹2,40,000', 'status': 'COMPLETED'},
    {'id': '#PO-2026-902', 'party': 'Shree Ram Sarees', 'date': '23/07/2026', 'qty': '850 Mtr', 'amount': '₹1,70,000', 'status': 'IN_PROCESS'},
    {'id': '#PO-2026-903', 'party': 'Vrindavan Textiles', 'date': '22/07/2026', 'qty': '2,400 Mtr', 'amount': '₹5,10,000', 'status': 'PENDING'},
    {'id': '#PO-2026-904', 'party': 'Rajlaxmi Fashions', 'date': '20/07/2026', 'qty': '600 Mtr', 'amount': '₹1,20,000', 'status': 'COMPLETED'},
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
                  Text('Purchase & Sales Order Ledger', style: theme.typography.h2),
                  Text('Filter orders, manage row selections, inspect line items, and export ledger summaries.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              if (_selectedIndices.isNotEmpty)
                shad.SecondaryBadge(child: Text('${_selectedIndices.length} Selected')),
              const shad.DensityGap(shad.gapMd),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Text('Export Selected Orders'),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Orders Table Card
          shad.Card(
            child: shad.OutlinedContainer(
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: colors.muted.withAlpha(120),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: shad.Checkbox(
                            state: _selectedIndices.length == _orders.length
                                ? shad.CheckboxState.checked
                                : _selectedIndices.isNotEmpty
                                    ? shad.CheckboxState.indeterminate
                                    : shad.CheckboxState.unchecked,
                            onChanged: (s) {
                              setState(() {
                                if (_selectedIndices.length == _orders.length) {
                                  _selectedIndices.clear();
                                } else {
                                  _selectedIndices.addAll(List.generate(_orders.length, (i) => i));
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: Text('ORDER ID', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                        Expanded(flex: 3, child: Text('PARTY NAME', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('DATE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('QUANTITY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const shad.Divider(),
                  // Data Rows
                  ...List.generate(_orders.length, (index) {
                    final item = _orders[index];
                    final isSelected = _selectedIndices.contains(index);
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: isSelected ? colors.primary.withAlpha(20) : null,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: shad.Checkbox(
                                  state: isSelected ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
                                  onChanged: (s) {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedIndices.remove(index);
                                      } else {
                                        _selectedIndices.add(index);
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: Text(item['id'], style: theme.typography.mono.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text(item['party'], style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(item['date'], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground))),
                              Expanded(flex: 2, child: Text(item['qty'], style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(item['amount'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _buildStatusBadge(item['status']))),
                            ],
                          ),
                        ),
                        if (index < _orders.length - 1) const shad.Divider(),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'COMPLETED':
        return const shad.PrimaryBadge(child: Text('Completed'));
      case 'IN_PROCESS':
        return const shad.SecondaryBadge(child: Text('In Process'));
      default:
        return const shad.OutlineBadge(child: Text('Pending'));
    }
  }
}
