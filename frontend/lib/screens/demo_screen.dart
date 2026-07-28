import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../dynamic_ai/components/page_level/page_header.dart';
import '../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../dynamic_ai/components/page_level/dynamic_dense_table.dart';
import '../dynamic_ai/components/page_level/dynamic_list.dart';
import '../dynamic_ai/components/page_level/dynamic_list_card.dart';
import '../dynamic_ai/components/page_level/dynamic_content_pane.dart';
import '../dynamic_ai/components/page_level/create_page_layout.dart';
import '../dynamic_ai/components/page_level/page_form_canvas.dart';

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

  DynamicListItem? _selectedListItem;

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

  final List<DynamicListItem> _mockListItems = [
    DynamicListItem(
      id: 'item-101',
      topLeading: const shad.OutlineBadge(child: Text('Pending')),
      topTrailing: '28 Jul',
      title: 'Ambaji Traders (Surat)',
      amount: '₹2,40,000',
      subtitle: 'D-4089 (Royal Silk) • 1,200 Mtr',
      indexNumber: '10481',
      rawData: {
        'voucherNo': '10481',
        'partyName': 'Ambaji Traders (Surat)',
        'status': 'PENDING',
        'items': [
          {'name': 'Royal Silk Grey Fabric', 'desc': 'Lot #10481-A • 54 Inch Width • Grade A1', 'hsn': '5407', 'qty': '800', 'unit': 'Mtr', 'rate': '180.00', 'amount': '1,44,000.00'},
          {'name': 'Chiffon Jacquard Weave', 'desc': 'Lot #10481-B • 44 Inch Width • Soft Finish', 'hsn': '5407', 'qty': '400', 'unit': 'Mtr', 'rate': '240.00', 'amount': '96,000.00'},
        ],
      },
    ),
    DynamicListItem(
      id: 'item-102',
      topLeading: const shad.PrimaryBadge(child: Text('Completed')),
      topTrailing: '26 Jul',
      title: 'Shree Ram Sarees (Ahm)',
      amount: '₹1,70,000',
      subtitle: 'D-3021 (Chiffon Jacquard) • 850 Mtr',
      indexNumber: '10482',
      rawData: {
        'voucherNo': '10482',
        'partyName': 'Shree Ram Sarees (Ahm)',
        'status': 'COMPLETED',
        'items': [
          {'name': 'Chiffon Jacquard Premium', 'desc': 'Lot #10482-A • 44 Inch • Export Quality', 'hsn': '5407', 'qty': '850', 'unit': 'Mtr', 'rate': '200.00', 'amount': '1,70,000.00'},
        ],
      },
    ),
    DynamicListItem(
      id: 'item-103',
      topLeading: const shad.SecondaryBadge(child: Text('In Process')),
      topTrailing: '24 Jul',
      title: 'Vrindavan Textiles (Jaipur)',
      amount: '₹5,10,000',
      subtitle: 'D-5100 (Organza Print) • 2,400 Mtr',
      indexNumber: '10483',
      rawData: {
        'voucherNo': '10483',
        'partyName': 'Vrindavan Textiles (Jaipur)',
        'status': 'IN_PROCESS',
        'items': [
          {'name': 'Organza Digital Print', 'desc': 'Lot #10483-A • 54 Inch • Multi Color', 'hsn': '5407', 'qty': '2,400', 'unit': 'Mtr', 'rate': '212.50', 'amount': '5,10,000.00'},
        ],
      },
    ),
    DynamicListItem(
      id: 'item-104',
      topLeading: const shad.OutlineBadge(child: Text('Pending')),
      topTrailing: '22 Jul',
      title: 'Rajlaxmi Fashions (Delhi)',
      amount: '₹1,20,000',
      subtitle: 'D-2045 (Heavy Satin) • 600 Mtr',
      indexNumber: '10484',
      rawData: {
        'voucherNo': '10484',
        'partyName': 'Rajlaxmi Fashions (Delhi)',
        'status': 'PENDING',
        'items': [
          {'name': 'Heavy Satin Dyeing', 'desc': 'Lot #10484-A • 44 Inch • Gloss Finish', 'hsn': '5407', 'qty': '600', 'unit': 'Mtr', 'rate': '200.00', 'amount': '1,20,000.00'},
        ],
      },
    ),
  ];

  int _contentViewIndex = 0; // 0: Tabular View, 1: PDF Layout

  @override
  void initState() {
    super.initState();
    _selectedListItem = _mockListItems.first;
  }

  PageHeaderMode _headerMode = PageHeaderMode.standard;
  String? _editingDocId;

  void _switchHeaderMode(PageHeaderMode mode, {String? docId}) {
    setState(() {
      _headerMode = mode;
      _editingDocId = docId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    if (_headerMode == PageHeaderMode.adding || _headerMode == PageHeaderMode.editing) {
      return PageFormCanvas(
        maxWidth: 1200,
        header: PageHeader<void>(
          title: 'Purchase Bills',
          mode: _headerMode,
          moduleName: 'Purchase Bill',
          docId: _editingDocId ?? 'PB-10485',
          onBack: () => _switchHeaderMode(PageHeaderMode.standard),
          onDiscard: () {
            _switchHeaderMode(PageHeaderMode.standard);
            shad.showToast(
              context: context,
              builder: (context, show) => const shad.Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Changes discarded.'),
                ),
              ),
            );
          },
          onSaveDraft: () {
            _switchHeaderMode(PageHeaderMode.standard);
            shad.showToast(
              context: context,
              builder: (context, show) => const shad.Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Draft saved successfully!'),
                ),
              ),
            );
          },
          onConfirm: () {
            final isAdding = _headerMode == PageHeaderMode.adding;
            final doc = _editingDocId ?? 'PB-10485';
            _switchHeaderMode(PageHeaderMode.standard);
            shad.showToast(
              context: context,
              builder: (context, show) => shad.Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(isAdding
                      ? 'New Purchase Bill created & confirmed!'
                      : 'Purchase Bill $doc updated successfully!'),
                ),
              ),
            );
          },
        ),
        child: CreatePageLayout(
          title: _headerMode == PageHeaderMode.adding ? 'Create Purchase Bill' : 'Edit Bill ${_editingDocId ?? 'PB-10485'}',
          backLabel: 'Purchase Bills',
          onBack: () => _switchHeaderMode(PageHeaderMode.standard),
          onSave: (val) {
            _switchHeaderMode(PageHeaderMode.standard);
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upgraded Page Header without module switcher
        PageHeader<void>(
          title: 'Purchase Bills',
          actions: [
            shad.PrimaryButton(
              onPressed: () => _switchHeaderMode(PageHeaderMode.adding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('New Bill (Adding Mode)'),
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
                // Details tab (Dynamic Action Bar + Table OR List View)
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
                    Expanded(
                      child: _selectedViewMode == 'table'
                          ? _buildDetailsTable(theme)
                          : _buildDetailsListView(theme),
                    ),
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

  Widget _buildDetailsListView(shad.ThemeData theme) {
    final colors = theme.colorScheme;
    final item = _selectedListItem;

    final rawData = item?.rawData ?? {};
    final partyName = rawData['partyName']?.toString() ?? item?.title ?? '';
    final voucherNo = item?.indexNumber ?? '10481';
    final amountStr = item?.amount ?? '₹0.00';
    final statusStr = rawData['status']?.toString() ?? 'PENDING';
    final itemsList = (rawData['items'] as List<Map<String, dynamic>>?) ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DynamicList(
          items: _mockListItems,
          selectedItem: _selectedListItem,
          onItemSelected: (selected) {
            setState(() => _selectedListItem = selected);
          },
          width: 340,
          showHeader: false,
          totalRecords: _mockListItems.length,
        ),
        const SizedBox(width: 12),
        DynamicContentPane(
          title: 'PB-$voucherNo',
          statusBadge: _buildStatusBadge(statusStr),
          toolbarActions: [
            shad.Tabs(
              index: _contentViewIndex,
              onChanged: (val) => setState(() => _contentViewIndex = val),
              children: const [
                shad.TabItem(child: Text('Tabular View')),
                shad.TabItem(child: Text('PDF Layout')),
              ],
            ),
            shad.IconButton.outline(
              size: shad.ButtonSize.small,
              icon: const Icon(shad.LucideIcons.printer, size: 16),
              onPressed: () {},
            ),
            shad.IconButton.outline(
              size: shad.ButtonSize.small,
              icon: const Icon(shad.LucideIcons.download, size: 16),
              onPressed: () {},
            ),
          ],
          primaryAction: shad.PrimaryButton(
            size: shad.ButtonSize.small,
            density: shad.ButtonDensity.iconDense,
            onPressed: () {
              _switchHeaderMode(PageHeaderMode.editing, docId: 'PB-$voucherNo');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.pencil, size: 14),
                SizedBox(width: 4),
                Text('Edit'),
              ],
            ),
          ),
          footerLeading: Row(
            children: [
              Text(
                '${itemsList.length} Line Items',
                style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600, color: colors.foreground),
              ),
              const SizedBox(width: 16),
              Text('Total Payable:', style: theme.typography.textSmall.copyWith(color: colors.mutedForeground)),
              const SizedBox(width: 6),
              Text(
                amountStr,
                style: theme.typography.mono.copyWith(
                  fontSize: 13 * theme.scaling,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          footerAction: shad.PrimaryButton(
            size: shad.ButtonSize.small,
            density: shad.ButtonDensity.iconDense,
            onPressed: () {},
            child: const Text('Approve & Pay'),
          ),
          child: _contentViewIndex == 0
              ? _buildTabularBody(theme, colors, voucherNo, partyName, itemsList)
              : _buildZohoPdfBody(theme, colors, voucherNo, partyName, itemsList, amountStr),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'PAID':
        return const shad.PrimaryBadge(child: Text('Completed'));
      case 'PENDING':
      case 'UNPAID':
        return const shad.OutlineBadge(child: Text('Pending'));
      case 'IN_PROCESS':
      case 'IN PROCESS':
        return const shad.SecondaryBadge(child: Text('In Process'));
      default:
        return shad.SecondaryBadge(child: Text(status));
    }
  }

  Widget _buildTabularBody(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String voucherNo,
    String partyName,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildMetaBox(theme, colors, 'VOUCHER NO', 'PB-$voucherNo')),
            const SizedBox(width: 12),
            Expanded(child: _buildMetaBox(theme, colors, 'BILL DATE', '28 Jul 2026')),
            const SizedBox(width: 12),
            Expanded(child: _buildMetaBox(theme, colors, 'PAYMENT TERMS', 'Net 30 Days')),
            const SizedBox(width: 12),
            Expanded(child: _buildMetaBox(theme, colors, 'STATION / HUB', 'Surat Warehouse')),
          ],
        ),
        const SizedBox(height: 16),
        shad.OutlinedContainer(
          borderColor: colors.border,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: colors.muted.withAlpha(80),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('SR', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('ITEM / FABRIC QUALITY', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('HSN CODE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 90, child: Text('QUANTITY', textAlign: TextAlign.right, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 90, child: Text('RATE', textAlign: TextAlign.right, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 110, child: Text('AMOUNT', textAlign: TextAlign.right, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const shad.Divider(),
              ...items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 40, child: Text('$idx', style: theme.typography.textSmall.copyWith(color: colors.mutedForeground))),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? '', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600)),
                                Text(item['desc'] ?? '', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                              ],
                            ),
                          ),
                          Expanded(flex: 2, child: Text(item['hsn'] ?? '5407', style: theme.typography.mono.copyWith(fontSize: 12 * theme.scaling))),
                          SizedBox(
                            width: 90,
                            child: Text(
                              '${item['qty']} ${item['unit'] ?? 'Mtr'}',
                              textAlign: TextAlign.right,
                              style: theme.typography.mono.copyWith(fontSize: 13 * theme.scaling, fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: 90,
                            child: Text(
                              '₹${item['rate']}',
                              textAlign: TextAlign.right,
                              style: theme.typography.mono.copyWith(fontSize: 13 * theme.scaling, fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: Text(
                              '₹${item['amount']}',
                              textAlign: TextAlign.right,
                              style: theme.typography.mono.copyWith(fontSize: 13 * theme.scaling, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (idx < items.length) const shad.Divider(),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZohoPdfBody(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String voucherNo,
    String partyName,
    List<Map<String, dynamic>> items,
    String amountStr,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820),
        decoration: BoxDecoration(
          color: theme.colorScheme.brightness == Brightness.dark ? const Color(0xFF1C1A17) : Colors.white,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AMBAJI SAREES PRIVATE LIMITED',
                        style: theme.typography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Plot #104, Ring Road Textile Market, Surat - 395002', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                      Text('GSTIN: 24AAACA1234B1Z9 | Phone: +91 98251 00000', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PURCHASE BILL',
                      style: theme.typography.h2.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.foreground.withAlpha(180),
                      ),
                    ),
                    Text('# PB-$voucherNo', style: theme.typography.mono.copyWith(fontSize: 14 * theme.scaling, fontWeight: FontWeight.bold, color: colors.primary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: colors.border, thickness: 1),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.muted.withAlpha(40),
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VENDOR / SUPPLIER:', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                        const SizedBox(height: 6),
                        Text(partyName, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.foreground)),
                        Text('Station Road, Industrial Estate, Surat', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                        Text('GSTIN: 24BBBPB9876C1Z4', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildZohoInfoRow(theme, colors, 'Bill Date:', '28 Jul 2026'),
                      _buildZohoInfoRow(theme, colors, 'Due Date:', '28 Aug 2026'),
                      _buildZohoInfoRow(theme, colors, 'Payment Terms:', 'Net 30 Days'),
                      _buildZohoInfoRow(theme, colors, 'Place of Supply:', '24 - Gujarat'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Table(
              border: TableBorder.all(color: colors.border, width: 0.8),
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FlexColumnWidth(4),
                2: FixedColumnWidth(70),
                3: FixedColumnWidth(80),
                4: FixedColumnWidth(90),
                5: FixedColumnWidth(110),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: colors.muted.withAlpha(120)),
                  children: [
                    _buildTableCell(theme, 'SR', isHeader: true, align: TextAlign.center),
                    _buildTableCell(theme, 'ITEM & DESCRIPTION', isHeader: true),
                    _buildTableCell(theme, 'HSN', isHeader: true, align: TextAlign.center),
                    _buildTableCell(theme, 'QTY', isHeader: true, align: TextAlign.right),
                    _buildTableCell(theme, 'RATE', isHeader: true, align: TextAlign.right),
                    _buildTableCell(theme, 'AMOUNT', isHeader: true, align: TextAlign.right),
                  ],
                ),
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  return TableRow(
                    children: [
                      _buildTableCell(theme, '$idx', align: TextAlign.center),
                      _buildTableCell(theme, '${item['name']}\n${item['desc']}'),
                      _buildTableCell(theme, '${item['hsn'] ?? '5407'}', isMono: true, align: TextAlign.center),
                      _buildTableCell(theme, '${item['qty']} ${item['unit'] ?? 'Mtr'}', isMono: true, align: TextAlign.right),
                      _buildTableCell(theme, '₹${item['rate']}', isMono: true, align: TextAlign.right),
                      _buildTableCell(theme, '₹${item['amount']}', isMono: true, isBold: true, align: TextAlign.right),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BANK DETAILS:', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                      const SizedBox(height: 4),
                      Text('Bank: HDFC Bank Ltd • A/C: 50200012345678', style: theme.typography.xSmall.copyWith(color: colors.foreground)),
                      Text('IFSC: HDFC0000124 • Branch: Ring Road Surat', style: theme.typography.xSmall.copyWith(color: colors.foreground)),
                      const SizedBox(height: 12),
                      Text('TERMS & CONDITIONS:', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
                      Text('1. Goods once sold will not be taken back.', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                      Text('2. Subject to Surat Jurisdiction only.', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.muted.withAlpha(40),
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      children: [
                        _buildTotalRow(theme, colors, 'Sub Total', amountStr),
                        const SizedBox(height: 6),
                        _buildTotalRow(theme, colors, 'CGST (2.5%)', '₹6,000.00'),
                        const SizedBox(height: 6),
                        _buildTotalRow(theme, colors, 'SGST (2.5%)', '₹6,000.00'),
                        const SizedBox(height: 8),
                        Divider(color: colors.border),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grand Total', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              amountStr,
                              style: theme.typography.mono.copyWith(
                                fontSize: 15 * theme.scaling,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaBox(shad.ThemeData theme, shad.ColorScheme colors, String label, String value) {
    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.foreground)),
        ],
      ),
    );
  }

  Widget _buildZohoInfoRow(shad.ThemeData theme, shad.ColorScheme colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
          Text(value, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600, color: colors.foreground)),
        ],
      ),
    );
  }

  Widget _buildTableCell(
    shad.ThemeData theme,
    String text, {
    bool isHeader = false,
    bool isMono = false,
    bool isBold = false,
    TextAlign align = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: align,
        style: isMono
            ? theme.typography.mono.copyWith(
                fontSize: 12.5 * theme.scaling,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              )
            : (isHeader
                ? theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)
                : theme.typography.xSmall.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildTotalRow(shad.ThemeData theme, shad.ColorScheme colors, String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
        Text(val, style: theme.typography.mono.copyWith(fontSize: 12.5 * theme.scaling, fontWeight: FontWeight.w500)),
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
