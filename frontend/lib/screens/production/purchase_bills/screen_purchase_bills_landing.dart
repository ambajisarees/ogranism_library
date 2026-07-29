import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../dynamic_ai/components/page_level/page_header.dart';
import '../../../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../../../dynamic_ai/components/page_level/dab_widgets/dab_submodule_popover.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';
import '../../../dynamic_ai/components/page_level/dynamic_list.dart';
import '../../../dynamic_ai/components/page_level/dynamic_list_card.dart';
import '../../../dynamic_ai/components/page_level/dynamic_content_pane.dart';
import '../../../dynamic_ai/components/micro_level/micro_button.dart';
import '../../../dynamic_ai/components/root_level/header_tabs.dart';
import '../../../models/production/purchase_bills/purchase_bill_category.dart';
import '../../../models/production/purchase_bills/model_purchase_bill_header.dart';
import '../../../services/production/service_purchase_bill.dart';

class ScreenPurchaseBillsLanding extends StatefulWidget {
  const ScreenPurchaseBillsLanding({super.key});

  @override
  State<ScreenPurchaseBillsLanding> createState() => _ScreenPurchaseBillsLandingState();
}

class _ScreenPurchaseBillsLandingState extends State<ScreenPurchaseBillsLanding> {
  final PurchaseBillService _service = PurchaseBillService();
  final TextEditingController _searchController = TextEditingController();

  int _contextTabIndex = 1; // Default selected: Details (1)
  String _selectedViewMode = 'table'; // Default selected view: table
  String? _searchQuery;

  // Category & Counts State (Default to Grey)
  PurchaseBillCategory _selectedCategory = PurchaseBillCategory.grey;
  Map<PurchaseBillCategory, int> _categoryCounts = {};

  // Bills Data State
  List<PurchaseBillHeaderModel> _bills = [];
  PurchaseBillHeaderModel? _selectedBill;
  final Set<String> _selectedBillKeys = {};

  bool _isLoadingHeaders = true;
  bool _isLoadingLineItems = false;
  int _totalCount = 0;
  int _offset = 0;
  final int _limit = 50;

  // Filters & Sorting
  String _selectedSupplier = 'All';
  String _selectedQuality = 'All';
  Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;
  List<String> _supplierOptions = [];
  List<String> _qualityOptions = [];
  String _currentSort = 'DATE_DESC';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startLoadingNotification() {
    if (mounted) {
      PageLoadingNotification(true).dispatch(context);
    }
  }

  void _stopLoadingNotification() {
    if (mounted) {
      PageLoadingNotification(false).dispatch(context);
    }
  }

  void _triggerPageLoading() {
    _startLoadingNotification();
    Future.delayed(const Duration(milliseconds: 700), () {
      _stopLoadingNotification();
    });
  }

  Future<void> _loadInitialData() async {
    _loadCategoryCounts();
    _loadFilterOptions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHeaders(resetOffset: true);
    });
  }

  Future<void> _loadCategoryCounts() async {
    final counts = await _service.getCategoryHeaderCounts();
    if (!mounted) return;
    setState(() {
      _categoryCounts = counts;
    });
  }

  Future<void> _loadFilterOptions() async {
    final suppliers = await _service.getUniqueSuppliers(category: _selectedCategory);
    final qualities = await _service.getUniqueQualities(category: _selectedCategory);
    if (!mounted) return;
    setState(() {
      _supplierOptions = suppliers;
      _qualityOptions = qualities;
    });
  }

  /// PHASE 1: Fast Header Fetch (<100ms response time).
  Future<void> _fetchHeaders({bool resetOffset = true}) async {
    if (resetOffset) {
      _offset = 0;
    }
    _startLoadingNotification();
    setState(() {
      _isLoadingHeaders = true;
      _isLoadingLineItems = false;
    });

    try {
      final dateRange = _selectedDateRange?.toRange();
      final res = await _service.getPurchaseBillHeaders(
        offset: _offset,
        limit: _limit,
        category: _selectedCategory,
        searchQuery: _searchQuery ?? _searchController.text.trim(),
        filterSupplier: _selectedSupplier,
        filterQuality: _selectedQuality,
        startDate: dateRange?.start,
        endDate: dateRange?.end,
        sortBy: _currentSort,
      );

      if (!mounted) return;
      setState(() {
        _bills = res.data;
        _totalCount = res.totalCount;
        _isLoadingHeaders = false;
      });

      // Auto-select first bill if available and fetch line items for it (Phase 2)
      if (_bills.isNotEmpty) {
        _onSelectBillCard(_bills.first);
      } else {
        setState(() {
          _selectedBill = null;
        });
      }
    } catch (e, stack) {
      debugPrint('Error fetching Purchase Bill headers: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoadingHeaders = false;
        });
      }
    } finally {
      _stopLoadingNotification();
    }
  }

  /// PHASE 2: On-Demand Line Item Fetch (~50ms response time).
  Future<void> _onSelectBillCard(PurchaseBillHeaderModel header) async {
    setState(() {
      _selectedBill = header;
      _isLoadingLineItems = true;
    });

    final items = await _service.getPurchaseBillLineItems(
      cno: header.cno,
      vno: header.vno,
      type: header.type,
      sourceTable: _selectedCategory.lineItemSource,
    );

    if (!mounted) return;
    setState(() {
      if (_selectedBill?.vno == header.vno && _selectedBill?.cno == header.cno) {
        _selectedBill = header.copyWith(items: items);
      }
      _isLoadingLineItems = false;
    });
  }

  void _onCategoryChanged(PurchaseBillCategory newCategory) {
    if (_selectedCategory == newCategory) return;
    setState(() {
      _selectedCategory = newCategory;
      _selectedSupplier = 'All';
      _selectedQuality = 'All';
      _selectedStatuses = {};
      _selectedDateRange = null;
      _selectedDateLabel = null;
      _selectedBill = null;
      _selectedBillKeys.clear();
    });
    _loadFilterOptions();
    _fetchHeaders(resetOffset: true);
  }

  void _onResetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = null;
      _selectedSupplier = 'All';
      _selectedQuality = 'All';
      _selectedStatuses = {};
      _selectedDateRange = null;
      _selectedDateLabel = null;
      _currentSort = 'DATE_DESC';
      _selectedBillKeys.clear();
    });
    _fetchHeaders(resetOffset: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // 1. PAGE HEADER (Title: Purchase Bills + Disabled Add Button)
          // ==========================================
          PageHeader<void>(
            title: 'Purchase Bills',
            mode: PageHeaderMode.standard,
            actions: [
              shad.PrimaryButton(
                onPressed: null, // Disabled Add Button
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(shad.LucideIcons.plus, size: 16),
                    SizedBox(width: 6),
                    Text('New Bill'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapMd),

          // ==========================================
          // 2. CONTEXT TABS ROW (Dashboard, Details, Tasks)
          // ==========================================
          Row(
            children: [
              shad.Tabs(
                index: _contextTabIndex,
                onChanged: (int value) {
                  _triggerPageLoading();
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
                            color: colors.destructive,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const shad.DensityGap(shad.gapSm),

          // ==========================================
          // 3. DYNAMIC ACTION BAR (DAB) WITH SUBMODULE SELECTOR AT INDEX 1
          // ==========================================
          DynamicActionBar(
            entityName: 'Bills',
            selectedView: _selectedViewMode,
            onViewChanged: (val) => setState(() => _selectedViewMode = val),
            submoduleWidget: Builder(
              builder: (btnContext) {
                return MicroButton(
                  leadingIcon: _selectedCategory.icon,
                  label: _selectedCategory.label,
                  badgeCount: _categoryCounts[_selectedCategory] ?? 0,
                  trailingIcon: shad.LucideIcons.chevronDown,
                  isSelected: true,
                  onPressed: () {
                    shad.showOverlay(
                      btnContext,
                      shad.PopoverConfiguration(
                        anchorAlignment: Alignment.bottomLeft,
                        alignment: Alignment.topLeft,
                        offset: const Offset(0, 4),
                        builder: (context) => DabSubmodulePopover<PurchaseBillCategory>(
                          title: 'Submodule',
                          selectedId: _selectedCategory,
                          items: PurchaseBillCategory.values.map((cat) {
                            return DabSubmoduleItem<PurchaseBillCategory>(
                              id: cat,
                              label: cat.label,
                              icon: cat.icon,
                              count: _categoryCounts[cat] ?? 0,
                            );
                          }).toList(),
                          onSelected: _onCategoryChanged,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            searchQuery: _searchQuery,
            onSearchChanged: (val) {
              setState(() => _searchQuery = val);
              _fetchHeaders(resetOffset: true);
            },
            selectedMills: _selectedSupplier != 'All' ? {_selectedSupplier} : {},
            millOptions: _supplierOptions,
            onMillChanged: (set) {
              setState(() {
                _selectedSupplier = set.isNotEmpty ? set.first : 'All';
              });
              _fetchHeaders(resetOffset: true);
            },
            selectedQualities: _selectedQuality != 'All' ? {_selectedQuality} : {},
            qualityOptions: _qualityOptions,
            onQualityChanged: (set) {
              setState(() {
                _selectedQuality = set.isNotEmpty ? set.first : 'All';
              });
              _fetchHeaders(resetOffset: true);
            },
            selectedStatuses: _selectedStatuses,
            onStatusChanged: (statuses) {
              setState(() => _selectedStatuses = statuses);
              _fetchHeaders(resetOffset: true);
            },
            selectedDateRange: _selectedDateRange,
            selectedDateLabel: _selectedDateLabel,
            onDateRangeSelected: (range) {
              setState(() {
                _selectedDateRange = range;
                if (range != null) {
                  _selectedDateLabel = 'Selected Date Range';
                } else {
                  _selectedDateLabel = null;
                }
              });
              _fetchHeaders(resetOffset: true);
            },
            hasActiveFilters: _selectedSupplier != 'All' ||
                _selectedQuality != 'All' ||
                _selectedStatuses.isNotEmpty ||
                _selectedDateRange != null,
            onClearAllFilters: _onResetFilters,
          ),
          const shad.DensityGap(shad.gapSm),

          // ==========================================
          // 4. CONTENT VIEW COMPUTATION (Table View vs Split List View)
          // ==========================================
          Expanded(
            child: () {
              switch (_contextTabIndex) {
                case 0:
                  return Center(
                    child: Text(
                      'Purchase Bills Dashboard (Analytics & Insights)',
                      style: theme.typography.h3.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  );
                case 1:
                  return _selectedViewMode == 'table'
                      ? _buildBillsTable(theme)
                      : _buildBillsSplitView(theme);
                case 2:
                  return Center(
                    child: Text(
                      'Tasks (Empty Placeholder)',
                      style: theme.typography.h3.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsSplitView(shad.ThemeData theme) {
    final listItems = _bills.map((bill) {
      final isPending = bill.paidStatus.toUpperCase() == 'PENDING' || bill.paidStatus.toUpperCase() == 'N';
      return DynamicListItem(
        id: '${bill.cno}_${bill.vno}_${bill.type}',
        topLeading: isPending
            ? const shad.OutlineBadge(child: Text('Pending'))
            : const shad.PrimaryBadge(child: Text('Completed')),
        topTrailing: '${bill.billDate.day}/${bill.billDate.month}',
        title: bill.partyName,
        amount: '₹${bill.billAmt.toStringAsFixed(0)}',
        subtitle: '${bill.displayBillNo} • ${bill.primaryQuality}',
        indexNumber: '${bill.vno}',
        rawData: {
          'cno': bill.cno,
          'vno': bill.vno,
          'type': bill.type,
          'voucherNo': '${bill.vno}',
          'partyName': bill.partyName,
          'status': bill.paidStatus,
          'items': bill.items,
        },
      );
    }).toList();

    final currentSelectedItem = _selectedBill != null && listItems.isNotEmpty
        ? listItems.firstWhere(
            (it) => it.id == '${_selectedBill!.cno}_${_selectedBill!.vno}_${_selectedBill!.type}',
            orElse: () => listItems.first,
          )
        : (listItems.isNotEmpty ? listItems.first : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DynamicList(
          items: listItems,
          selectedItem: currentSelectedItem,
          onItemSelected: (selected) {
            if (selected == null) return;
            final b = _bills.firstWhere(
              (o) => '${o.cno}_${o.vno}_${o.type}' == selected.id,
              orElse: () => _bills.first,
            );
            _onSelectBillCard(b);
          },
          width: 340,
          showHeader: false,
          totalRecords: _totalCount > 0 ? _totalCount : listItems.length,
          isLoading: _isLoadingHeaders,
        ),
        const SizedBox(width: 12),
        DynamicContentPane(
          isLoading: _isLoadingLineItems,
          title: _selectedBill != null ? _selectedBill!.displayBillNo : 'No Bill Selected',
          statusBadge: _selectedBill != null
              ? (_selectedBill!.paidStatus.toUpperCase() == 'PENDING' || _selectedBill!.paidStatus.toUpperCase() == 'N'
                  ? const shad.OutlineBadge(child: Text('PENDING'))
                  : const shad.PrimaryBadge(child: Text('COMPLETED')))
              : null,
          primaryAction: const shad.PrimaryButton(
            size: shad.ButtonSize.small,
            density: shad.ButtonDensity.iconDense,
            onPressed: null, // Disabled edit
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.pencil, size: 14),
                SizedBox(width: 6),
                Text('Edit Bill'),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedBill != null) ...[
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildFieldTile(theme, 'Bill No', _selectedBill!.displayBillNo),
                    _buildFieldTile(theme, 'Internal VNO', '#${_selectedBill!.vno}'),
                    _buildFieldTile(theme, 'Category', _selectedCategory.label),
                    _buildFieldTile(theme, 'Party / Supplier', _selectedBill!.partyName),
                    _buildFieldTile(theme, 'Quality', _selectedBill!.primaryQuality),
                    _buildFieldTile(theme, 'Total Pcs / Mtr', '${_selectedBill!.totPcs} Pcs / ${_selectedBill!.totMts} Mtr'),
                    _buildFieldTile(theme, 'Bill Amount', '₹${_selectedBill!.billAmt.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 16),
                const shad.Divider(),
                const SizedBox(height: 16),
              ],
              Text(
                'Bill Line Items',
                style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _selectedBill != null && _selectedBill!.items.isNotEmpty
                  ? Column(
                      children: _selectedBill!.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(item.qual.isNotEmpty ? item.qual : 'Item #${item.id}')),
                              Text('${item.pieces} Pcs / ${item.meters} Mtr'),
                              const SizedBox(width: 16),
                              Text('₹${item.amount.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Text(
                      'No line items found.',
                      style: theme.typography.textMuted,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldTile(shad.ThemeData theme, String label, String value) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
          const SizedBox(height: 2),
          Text(value, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBillsTable(shad.ThemeData theme) {
    final columns = [
      const DynamicTableColumnSpec(key: 'vno', label: 'Voucher No', width: 110),
      const DynamicTableColumnSpec(key: 'billNo', label: 'Bill No', width: 140),
      const DynamicTableColumnSpec(key: 'partyName', label: 'Supplier / Party', width: 220),
      const DynamicTableColumnSpec(key: 'qual', label: 'Quality', width: 160),
      const DynamicTableColumnSpec(key: 'quantity', label: 'Quantity', width: 130),
      const DynamicTableColumnSpec(key: 'amount', label: 'Amount', width: 140),
      const DynamicTableColumnSpec(key: 'status', label: 'Status', width: 120),
    ];

    final rows = _bills.map((bill) {
      return DynamicTableRowData(
        id: '${bill.cno}_${bill.vno}_${bill.type}',
        voucherNo: '${bill.vno}',
        partyName: bill.partyName,
        designPattern: bill.displayBillNo,
        quantity: '${bill.totPcs} Pcs / ${bill.totMts} Mtr',
        amount: '₹${bill.billAmt.toStringAsFixed(0)}',
        amountValue: bill.billAmt,
        status: bill.paidStatus.toUpperCase() == 'PENDING' || bill.paidStatus.toUpperCase() == 'N' ? 'PENDING' : 'COMPLETED',
        expandedDetails: 'Bill Details: ${bill.displayBillNo} • Supplier: ${bill.partyName} • Creator: ${bill.creator.isNotEmpty ? bill.creator : "Admin"}',
      );
    }).toList();

    return DynamicDenseTable(
      columns: columns,
      rows: rows,
      enableExpansion: true,
      isLoading: _isLoadingHeaders,
    );
  }
}
