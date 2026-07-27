import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ShowcaseDataTables extends StatefulWidget {
  const ShowcaseDataTables({super.key});

  @override
  State<ShowcaseDataTables> createState() => _ShowcaseDataTablesState();
}

class _ShowcaseDataTablesState extends State<ShowcaseDataTables> {
  final Set<int> _selectedRowIndices = {0, 2};
  int _currentPage = 1;
  int _expandedRowIndex = -1;

  final List<Map<String, dynamic>> _tableData = [
    {
      'id': 101,
      'vno': 'VNO #10481',
      'party': 'Ambaji Traders (Surat)',
      'design': 'D-4089 (Royal Silk)',
      'qty': '1,200 Mtr',
      'amount': '₹2,40,000',
      'status': 'PENDING',
      'stage': 2,
    },
    {
      'id': 102,
      'vno': 'VNO #10482',
      'party': 'Shree Ram Sarees (Ahm)',
      'design': 'D-3021 (Chiffon Jacquard)',
      'qty': '850 Mtr',
      'amount': '₹1,70,000',
      'status': 'COMPLETED',
      'stage': 4,
    },
    {
      'id': 103,
      'vno': 'VNO #10483',
      'party': 'Vrindavan Textiles (Jaipur)',
      'design': 'D-5100 (Organza Print)',
      'qty': '2,400 Mtr',
      'amount': '₹5,10,000',
      'status': 'IN_PROCESS',
      'stage': 3,
    },
    {
      'id': 104,
      'vno': 'VNO #10484',
      'party': 'Rajlaxmi Fashions (Delhi)',
      'design': 'D-2045 (Heavy Satin)',
      'qty': '600 Mtr',
      'amount': '₹1,20,000',
      'status': 'PENDING',
      'stage': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text('Tables, Data Display & Process Trackers', style: theme.typography.h2),
          Text(
            'Dense ERP data table scaffolding, checkbox selection, row actions, pagination, process pipeline trackers, avatars, and chat bubbles.',
            style: theme.typography.textMuted,
          ),
          const shad.DensityGap(shad.gapLg),

          // 1. ERP Dense Data Table with Checkbox Row Selection
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('ERP Dense Inventory & Voucher Data Table', style: theme.typography.h3),
                    const Spacer(),
                    if (_selectedRowIndices.isNotEmpty)
                      shad.SecondaryBadge(
                        child: Text('${_selectedRowIndices.length} Rows Selected'),
                      ),
                  ],
                ),
                const shad.DensityGap(shad.gapMd),
                // Table
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: colors.muted.withAlpha(150),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: shad.Checkbox(
                                state: _selectedRowIndices.length == _tableData.length
                                    ? shad.CheckboxState.checked
                                    : _selectedRowIndices.isNotEmpty
                                        ? shad.CheckboxState.indeterminate
                                        : shad.CheckboxState.unchecked,
                                onChanged: (s) {
                                  setState(() {
                                    if (_selectedRowIndices.length == _tableData.length) {
                                      _selectedRowIndices.clear();
                                    } else {
                                      _selectedRowIndices.addAll(List.generate(_tableData.length, (i) => i));
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(flex: 2, child: Text('VOUCHER NO', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('PARTY NAME', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('DESIGN PATTERN', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('QUANTITY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('AMOUNT', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('STATUS', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 80, child: Text('ACTIONS', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      // Data Rows
                      ...List.generate(_tableData.length, (index) {
                        final item = _tableData[index];
                        final isSelected = _selectedRowIndices.contains(index);
                        final isExpanded = _expandedRowIndex == index;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _expandedRowIndex = isExpanded ? -1 : index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                              _selectedRowIndices.remove(index);
                                            } else {
                                              _selectedRowIndices.add(index);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(flex: 2, child: Text(item['vno'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600))),
                                    Expanded(flex: 3, child: Text(item['party'], style: theme.typography.textSmall)),
                                    Expanded(flex: 3, child: Text(item['design'], style: theme.typography.xSmall.copyWith(color: colors.mutedForeground))),
                                    Expanded(flex: 2, child: Text(item['qty'], style: theme.typography.textSmall)),
                                    Expanded(flex: 2, child: Text(item['amount'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold))),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _buildStatusBadge(item['status']),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(isExpanded ? shad.LucideIcons.chevronUp : shad.LucideIcons.chevronDown, size: 16, color: colors.mutedForeground),
                                          const SizedBox(width: 4),
                                          shad.IconButton.ghost(
                                            density: shad.ButtonDensity.iconDense,
                                            size: shad.ButtonSize.small,
                                            icon: const Icon(shad.LucideIcons.ellipsisVertical, size: 14),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                color: colors.muted.withAlpha(80),
                                child: Row(
                                  children: [
                                    const Icon(shad.LucideIcons.cornerDownRight, size: 16),
                                    const SizedBox(width: 8),
                                    Text('Expanded Line Details: Grey Fabric Lot #804 • Station: Surat Warehouse • Dispatcher: Ramesh (Emp #42)', style: theme.typography.xSmall),
                                  ],
                                ),
                              ),
                            if (index < _tableData.length - 1) const shad.Divider(),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const shad.DensityGap(shad.gapMd),
                // Pagination Footer
                Row(
                  children: [
                    Text('Showing 1-4 of 128 records', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    const Spacer(),
                    shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      child: const Text('Previous'),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: () => setState(() => _currentPage++),
                      child: Text('Page $_currentPage'),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: () => setState(() => _currentPage++),
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 2. Process Tracker Display
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ERP Multi-Stage Production Process Tracker', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                _buildTrackerBar(context, currentStage: 3),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 3. Avatars & CRM Chat Bubbles
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatars & Groups
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Avatars & Stacked User Groups', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Wrap(
                        spacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const shad.Avatar(initials: 'SM', size: 36),
                          const shad.Avatar(initials: 'AS', size: 36),
                          const shad.Avatar(initials: 'RP', size: 36),
                          const shad.SecondaryBadge(child: Text('+5 More')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // CRM WhatsApp Chat Bubble Preview
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CRM WhatsApp Chat Exchange Bubbles', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      // Incoming
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.muted,
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ambaji Traders: Please send design catalog PDF.', style: theme.typography.xSmall),
                              Text('10:42 AM', style: theme.typography.xSmall.copyWith(fontSize: 10, color: colors.mutedForeground)),
                            ],
                          ),
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),
                      // Outgoing
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Catalog sent! Check WhatsApp attachment.', style: TextStyle(color: Colors.white, fontSize: 12)),
                              Text('10:45 AM • Sent', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 10)),
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

  Widget _buildTrackerBar(BuildContext context, {required int currentStage}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final stages = ['1. PO Created', '2. Cutting Done', '3. Job Stitching', '4. Purchase Bill'];

    return Row(
      children: List.generate(stages.length, (index) {
        final isDone = index + 1 <= currentStage;
        final isCurrent = index + 1 == currentStage;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDone ? colors.primary : colors.muted,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDone ? shad.LucideIcons.circleCheck : shad.LucideIcons.circle,
                        size: 14,
                        color: isDone ? Colors.white : colors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          stages[index],
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
              ),
              if (index < stages.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(shad.LucideIcons.chevronRight, size: 14, color: colors.mutedForeground),
                ),
            ],
          ),
        );
      }),
    );
  }
}
