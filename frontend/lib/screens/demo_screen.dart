import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../dynamic_ai/components/page_level/page_header.dart';
import '../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../dynamic_ai/components/page_level/dynamic_dense_table.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _contextTabIndex = 1; // Default selected: Details (1)
  String _selectedViewMode = 'table'; // Default selected view: table
  String? _searchQuery;

  // Filter selection state (Default: NO active filters)
  Set<String> _selectedMills = {};
  Set<String> _selectedQualities = {};
  Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;

  final List<String> _millOptions = [
    'Ambaji Mills',
    'Shree Ram Processing',
    'Vrindavan Dyeing',
    'Rajlaxmi Print House',
    'Surat Textile Park',
  ];

  final List<String> _qualityOptions = [
    'Royal Silk',
    'Chiffon Jacquard',
    'Organza Print',
    'Heavy Satin',
    'Cotton Dobby',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upgraded Page Header without module switcher
        PageHeader<void>(
          title: 'Purchase Bills',
          actions: [
            shad.OutlineButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(shad.LucideIcons.download),
                  shad.DensityGap(shad.gapSm),
                  Text('Export'),
                ],
              ),
            ),
            shad.PrimaryButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('New Bill'),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapMd),

        // Native CONTEXT_TABS row + Spacer (Dashboard, Details, Tasks with Red Dot)
        Row(
          children: [
            shad.Tabs(
              index: _contextTabIndex,
              onChanged: (int value) {
                setState(() => _contextTabIndex = value);
              },
              children: [
                const shad.TabItem(child: Text('Dashboard')),
                const shad.TabItem(child: Text('Details')),
                shad.TabItem(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tasks'),
                      const shad.DensityGap(shad.gapXs),
                      Container(
                        width: 6 * theme.scaling,
                        height: 6 * theme.scaling,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.destructive,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
        const shad.DensityGap(shad.gapSm),

        // Bottom Area controlled by CONTEXT_TABS
        Expanded(
          child: () {
            switch (_contextTabIndex) {
              case 0:
                // Dashboard tab (Empty Placeholder)
                return Center(
                  child: Text(
                    'Dashboard (Empty Placeholder)',
                    style: theme.typography.h3.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                );
              case 1:
                // Details tab (Default: Dynamic Action Bar + Table)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DynamicActionBar(
                      entityName: 'Cards',
                      selectedView: _selectedViewMode,
                      onViewChanged: (viewMode) {
                        setState(() => _selectedViewMode = viewMode);
                      },
                      searchQuery: _searchQuery,
                      onSearchChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                      // Mill Filter
                      selectedMills: _selectedMills,
                      millOptions: _millOptions,
                      onMillChanged: (mills) {
                        setState(() => _selectedMills = mills);
                      },
                      // Quality Filter
                      selectedQualities: _selectedQualities,
                      qualityOptions: _qualityOptions,
                      onQualityChanged: (qualities) {
                        setState(() => _selectedQualities = qualities);
                      },
                      // Status Filter
                      selectedStatuses: _selectedStatuses,
                      onStatusChanged: (statuses) {
                        setState(() => _selectedStatuses = statuses);
                      },
                      // Date Filter
                      selectedDateRange: _selectedDateRange,
                      selectedDateLabel: _selectedDateLabel,
                      onDateRangeSelected: (range) {
                        setState(() {
                          _selectedDateRange = range;
                          if (range != null) {
                            _selectedDateLabel = 'Selected Date Range';
                          }
                        });
                      },
                      // Clear All Action
                      hasActiveFilters: _selectedMills.isNotEmpty ||
                          _selectedQualities.isNotEmpty ||
                          _selectedStatuses.isNotEmpty ||
                          _selectedDateRange != null,
                      onClearAllFilters: () {
                        setState(() {
                          _selectedMills = {};
                          _selectedQualities = {};
                          _selectedStatuses = {};
                          _selectedDateRange = null;
                          _selectedDateLabel = null;
                        });
                      },
                      onOverflowFilterPressed: () {
                        shad.showToast(
                          context: context,
                          builder: (context, show) => shad.Card(
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Overflow filters (3-dots) clicked.'),
                            ),
                          ),
                        );
                      },
                    ),
                    const shad.DensityGap(shad.gapSm),
                    _buildDetailsTable(theme),
                  ],
                );
              case 2:
                // Tasks tab (Empty Placeholder)
                return Center(
                  child: Text(
                    'Tasks (Empty Placeholder)',
                    style: theme.typography.h3.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          }(),
        ),
      ],
    );
  }

  Widget _buildDetailsTable(shad.ThemeData theme) {
    const columns = [
      DynamicTableColumnSpec(label: 'VOUCHER NO', key: 'voucherNo', isSortable: true, flex: 2),
      DynamicTableColumnSpec(label: 'PARTY NAME', key: 'partyName', isSortable: true, flex: 3),
      DynamicTableColumnSpec(label: 'DESIGN PATTERN', key: 'designPattern', isSortable: false, flex: 3),
      DynamicTableColumnSpec(label: 'QUANTITY', key: 'quantity', isSortable: true, flex: 2),
      DynamicTableColumnSpec(label: 'AMOUNT', key: 'amount', isSortable: true, flex: 2),
      DynamicTableColumnSpec(label: 'STATUS', key: 'status', isSortable: true, flex: 2),
      DynamicTableColumnSpec(label: '', key: 'actions', isSortable: false, width: 80, alignment: Alignment.centerRight),
    ];

    const rows = [
      DynamicTableRowData(
        id: 'row-101',
        voucherNo: '10481',
        partyName: 'Ambaji Traders (Surat)',
        designPattern: 'D-4089 (Royal Silk)',
        quantity: '1,200 Mtr',
        amount: '₹2,40,000',
        amountValue: 240000,
        status: 'PENDING',
        expandedDetails: 'Expanded Line Details: Grey Fabric Lot #10481 • Station: Surat Warehouse • Dispatcher: Ramesh (Emp #42)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=150&auto=format&fit=crop&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=800&auto=format&fit=crop&q=80',
        ],
      ),
      DynamicTableRowData(
        id: 'row-102',
        voucherNo: '10482',
        partyName: 'Shree Ram Sarees (Ahm)',
        designPattern: 'D-3021 (Chiffon Jacquard)',
        quantity: '850 Mtr',
        amount: '₹1,70,000',
        amountValue: 170000,
        status: 'COMPLETED',
        expandedDetails: 'Expanded Line Details: Grey Fabric Lot #10482 • Station: Ahmedabad Depot • Dispatcher: Suresh (Emp #19)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=150&auto=format&fit=crop&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop&q=80',
        ],
      ),
      DynamicTableRowData(
        id: 'row-103',
        voucherNo: '10483',
        partyName: 'Vrindavan Textiles (Jaipur)',
        designPattern: 'D-5100 (Organza Print)',
        quantity: '2,400 Mtr',
        amount: '₹5,10,000',
        amountValue: 510000,
        status: 'IN_PROCESS',
        expandedDetails: 'Expanded Line Details: Grey Fabric Lot #10483 • Station: Jaipur Facility • Dispatcher: Mahesh (Emp #88)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=150&auto=format&fit=crop&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=800&auto=format&fit=crop&q=80',
        ],
      ),
      DynamicTableRowData(
        id: 'row-104',
        voucherNo: '10484',
        partyName: 'Rajlaxmi Fashions (Delhi)',
        designPattern: 'D-2045 (Heavy Satin)',
        quantity: '600 Mtr',
        amount: '₹1,20,000',
        amountValue: 120000,
        status: 'PENDING',
        expandedDetails: 'Expanded Line Details: Grey Fabric Lot #10484 • Station: Delhi Hub • Dispatcher: Dinesh (Emp #14)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=150&auto=format&fit=crop&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop&q=80',
        ],
      ),
    ];

    return DynamicDenseTable(
      columns: columns,
      rows: rows,
      enableExpansion: true, // Optional expandable toggle enabled!
    );
  }
}
