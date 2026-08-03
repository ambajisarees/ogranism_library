/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE ORDERS LANDING SCREEN (scr_po_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing container screen for Purchase Orders (`po`).
   - Manages the 5 PO submodules: Finish (`O13`), Lace (`O14`), Packing (`O15`), Studio (`O16`), Grey.
   - Integrates PageHeader (Details, Reports, Links tabs + Print/Export secondary actions), DynamicActionBar (DAB filters + Grouping selector), and DyShlDetails.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - PageHeader: Details (Def), Reports, Links tabs. Actions: Print & Export (Secondary buttons).
   - Grouping Engine: Default = 2-tiered (def + child). Grouped = 3-tiered (group -> def -> child). Group rows wrap def rows.
   - Consumes module-level service `SrvPo` and module model `MdlPoHeader`.
================================================================================
*/

library;

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/micro/cards/dy_grid_card.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../dynamic_ai/micro/dab/dab_submodule_pop.dart';
import '../../../dynamic_ai/micro/dy_micro_button.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';
import '../../../dynamic_ai/shells/dy_shl_dash.dart';
import '../../../dynamic_ai/shells/dy_shl_details.dart';
import '../../../dynamic_ai/shells/dy_shl_reports.dart';
import '../../../dynamic_ai/shells/dy_shl_tasks.dart';
import '../../../dynamic_ai/shells/dy_page_canvas.dart';
import '../../../dynamic_ai/root/dy_module_tabs.dart';
import '../../../models/production/mdl_po.dart';
import '../../../services/production/srv_po.dart';

typedef PoSubmoduleCategory = PoCategory;

class ScrPoLanding extends StatefulWidget {
  const ScrPoLanding({super.key});

  @override
  State<ScrPoLanding> createState() => _ScrPoLandingState();
}

class _ScrPoLandingState extends State<ScrPoLanding> {
  final SrvPo _poService = SrvPo();
  final TextEditingController _searchController = TextEditingController();

  PoCategory _selectedCategory = PoCategory.finish;
  Map<PoCategory, int> _categoryCounts = {};
  String _viewMode = 'table';
  int _contextTabIndex = 1;
  String _groupingMode = 'none'; // 'none', 'party', 'quality'

  void _onGroupingChanged(String mode) {
    setState(() {
      _groupingMode = mode;
    });
  }
  String? _searchQuery;

  // Filter States
  Set<String> _selectedParties = {};
  List<String> _partyOptions = [];
  final Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;

  List<MdlPoHeader> _orders = [];
  MdlPoHeader? _selectedOrder;
  bool _isLoading = true;
  int _totalCount = 0;
  int _offset = 0;
  final int _limit = 50;

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

  Future<void> _loadInitialData() async {
    _loadCategoryCounts();
    _loadPartyOptions();
    _fetchHeaders(resetOffset: true);
  }

  Future<void> _loadCategoryCounts() async {
    final counts = await _poService.getCategoryCounts();
    if (!mounted) return;
    setState(() {
      _categoryCounts = counts;
    });
  }

  Future<void> _loadPartyOptions() async {
    final parties = await _poService.getPartyOptions(category: _selectedCategory);
    if (!mounted) return;
    setState(() {
      _partyOptions = parties;
    });
  }

  Future<void> _fetchHeaders({bool resetOffset = false}) async {
    if (resetOffset) {
      setState(() {
        _offset = 0;
      });
    }

    setState(() {
      _isLoading = true;
    });

    final dateRange = _selectedDateRange?.toRange();
    final res = await _poService.getPurchaseOrders(
      offset: _offset,
      limit: _limit,
      category: _selectedCategory,
      searchQuery: _searchQuery,
      selectedParties: _selectedParties,
      selectedStatuses: _selectedStatuses,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
    );

    if (!mounted) return;

    setState(() {
      _orders = res.data;
      _totalCount = res.totalCount;
      _isLoading = false;
      if (_orders.isNotEmpty && (_selectedOrder == null || !_orders.any((o) => o.vno == _selectedOrder!.vno))) {
        _selectedOrder = _orders.first;
      }
    });
  }

  void _onCategoryChanged(PoCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedParties.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedDateLabel = null;
      _selectedOrder = null;
    });
    _loadPartyOptions();
    _fetchHeaders(resetOffset: true);
  }

  void _onClearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = null;
      _selectedParties.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedDateLabel = null;
      _onGroupingChanged('none');
    });
    _fetchHeaders(resetOffset: true);
  }

  void _triggerPageLoading() {
    if (mounted) {
      PageLoadingNotification(true).dispatch(context);
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        PageLoadingNotification(false).dispatch(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.landing,
      header: PageHeader(
        title: 'Purchase Orders',
        mode: PageHeaderMode.standard,
        subpages: PageSubpages(
          selectedIndex: _contextTabIndex,
          labels: const ['Dash', 'Details', 'Reports', 'Tasks'],
          onSubpageChanged: (idx) {
            _triggerPageLoading();
            setState(() {
              _contextTabIndex = idx;
            });
          },
        ),
      ),
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(_contextTabIndex),
          child: _buildTabContent(theme),
        ),
      ),
    );
  }

  Widget _buildTabContent(shad.ThemeData theme) {
    if (_contextTabIndex == 0) {
      return const DyShlDash(
        title: 'Purchase Orders',
      );
    }

    if (_contextTabIndex == 2) {
      return const DyShlReports(
        title: 'Purchase Orders',
      );
    }

    if (_contextTabIndex == 3) {
      return const DyShlTasks();
    }

    // Tab 1: Details Shell
    final activeCount = _categoryCounts[_selectedCategory] ?? _totalCount;
    final hasFilters = _selectedParties.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedDateRange != null;

    return DyShlDetails(
      title: 'Purchase Orders',
      entityName: 'Orders',
      moduleName: 'purchase_orders',
      selectedViewMode: _viewMode,
      onViewModeChanged: (mode) {
        setState(() {
          _viewMode = mode;
        });
      },
      submoduleWidget: Builder(
        builder: (btnContext) {
          return MicroButton(
            leadingIcon: _selectedCategory.icon,
            label: _selectedCategory.label,
            badgeCount: activeCount,
            trailingIcon: shad.LucideIcons.chevronDown,
            isSelected: true,
            onPressed: () {
              shad.showOverlay(
                btnContext,
                shad.PopoverConfiguration(
                  anchorAlignment: Alignment.bottomLeft,
                  alignment: Alignment.topLeft,
                  offset: const Offset(0, 4),
                  builder: (popContext) => DabSubmodulePopover<PoCategory>(
                    title: 'Submodule',
                    selectedId: _selectedCategory,
                    items: PoCategory.values
                        .map(
                          (c) => DabSubmoduleItem<PoCategory>(
                            id: c,
                            label: c.label,
                            icon: c.icon,
                            count: _categoryCounts[c] ?? 0,
                          ),
                        )
                        .toList(),
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
        _searchQuery = val?.trim();
        _fetchHeaders(resetOffset: true);
      },
      selectedParties: _selectedParties,
      partyOptions: _partyOptions,
      onPartyChanged: (set) {
        setState(() {
          _selectedParties = set;
        });
        _fetchHeaders(resetOffset: true);
      },
      selectedDateRange: _selectedDateRange,
      selectedDateLabel: _selectedDateLabel,
      onDateRangeSelected: (range) {
        setState(() {
          _selectedDateRange = range;
          _selectedDateLabel = range != null ? 'Selected Date Range' : null;
        });
        _fetchHeaders(resetOffset: true);
      },
      hasActiveFilters: hasFilters,
      onClearAllFilters: _onClearAllFilters,
      tableColumns: const [
        DyTableColumnSpec(key: 'vno', label: 'Voucher No', flex: 1),
        DyTableColumnSpec(key: 'jobLink', label: 'Job Link', flex: 1),
        DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
        DyTableColumnSpec(key: 'status', label: 'Status', flex: 1, isSortable: false),
        DyTableColumnSpec(key: 'partyName', label: 'Party', flex: 2),
        DyTableColumnSpec(key: 'designPattern', label: 'Design', flex: 1),
        DyTableColumnSpec(key: 'pcs', label: 'Pcs', flex: 1, isNumeric: true),
        DyTableColumnSpec(key: 'quantity', label: 'Quantity', flex: 1, isNumeric: true),
        DyTableColumnSpec(key: 'unit', label: 'Unit', flex: 1),
        DyTableColumnSpec(key: 'rate', label: 'Rate', flex: 1, isNumeric: true),
        DyTableColumnSpec(key: 'amount', label: 'Amount', flex: 1, isNumeric: true),
      ],
      tableRows: _buildMappedTableRows(),
      gridItems: _buildMappedGridItems(),
      listItems: _buildMappedListItems(),
      summaryTotals: _buildSummaryTotals(),
      totalRecords: _totalCount,
      pageIndex: (_offset / _limit).floor() + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchHeaders();
      },
      isLoading: _isLoading,
    );
  }

  Map<String, String> _buildSummaryTotals() {
    int totalPcs = 0;
    double totalMts = 0;
    double totalAmt = 0;
    for (final o in _orders) {
      totalPcs += o.totalPieces;
      totalMts += o.totalMeters;
      totalAmt += o.finalAmount > 0 ? o.finalAmount : o.billAmount;
    }
    return {
      'pcs': '$totalPcs Pcs',
      'quantity': '${totalMts.toStringAsFixed(1)} Mts',
      'amount': '₹${totalAmt.toStringAsFixed(2)}',
    };
  }

  String _formatShortDate(DateTime? dt) {
    if (dt == null) return '-';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}';
  }

  List<DyGridItem> _buildMappedGridItems() {
    return _orders.map((o) {
      return DyGridItem(
        id: o.vno.toString(),
        title: o.partyName.isNotEmpty ? o.partyName : 'Unknown Supplier',
        voucherNo: o.displayOrderNo,
        partyName: o.partyName.isNotEmpty ? o.partyName : 'Unknown Supplier',
        designPattern: o.primaryFabric,
        quantity: o.totalMeters > 0 ? '${o.totalMeters.toStringAsFixed(1)} Mts' : '-',
        amount: o.formattedFinalAmount(),
      );
    }).toList();
  }

  List<DynamicListItem> _buildMappedListItems() {
    return _orders.map((o) {
      return DynamicListItem(
        id: o.vno.toString(),
        title: o.partyName.isNotEmpty ? o.partyName : 'Unknown Supplier',
        subtitle: o.primaryFabric,
        indexNumber: o.displayOrderNo,
        amount: o.formattedFinalAmount(),
        topTrailing: _formatShortDate(o.date),
      );
    }).toList();
  }

  /// Maps [MdlPoHeader] orders to 2-tiered (default) or 3-tiered (grouped) row structure
  List<DyTableRowData> _buildMappedTableRows() {
    if (_groupingMode == 'party') {
      // Group by Party / Weaver Name (3-tiered)
      final grouped = <String, List<MdlPoHeader>>{};
      for (final o in _orders) {
        final p = o.partyName.isNotEmpty ? o.partyName : 'Unknown Supplier';
        grouped.putIfAbsent(p, () => []).add(o);
      }

      final result = <DyTableRowData>[];
      grouped.forEach((party, partyOrders) {
        final totalPcs = partyOrders.fold<int>(0, (sum, o) => sum + o.totalPieces);
        final totalMts = partyOrders.fold<double>(0, (sum, o) => sum + o.totalMeters);
        final totalAmt = partyOrders.fold<double>(0, (sum, o) => sum + (o.finalAmount > 0 ? o.finalAmount : o.billAmount));

        result.add(
          DyTableRowData(
            id: 'group-${party.hashCode}',
            rowType: DyTableRowType.group,
            title: '$party (${partyOrders.length} Orders)',
            partyName: party,
            data: {
              'vno': 'GROUP: ${party.toUpperCase()}',
              'jobLink': '-',
              'date': '-',
              'status': 'ACTIVE',
              'partyName': party,
              'designPattern': '${partyOrders.length} Orders Summary',
              'pcs': '$totalPcs Pcs',
              'quantity': '${totalMts.toStringAsFixed(1)} Mts',
              'unit': 'MTR',
              'rate': '-',
              'amount': '₹${totalAmt.toStringAsFixed(2)}',
            },
            children: partyOrders.map((o) => _mapOrderToDefRow(o)).toList(),
          ),
        );
      });
      return result;
    }

    // Default 2-Tiered Structure (def_row + child_rows)
    return _orders.map((o) => _mapOrderToDefRow(o)).toList();
  }

  DyTableRowData _mapOrderToDefRow(MdlPoHeader o) {
    return DyTableRowData(
      id: o.vno.toString(),
      rowType: DyTableRowType.def,
      voucherNo: o.displayOrderNo,
      partyName: o.partyName.isNotEmpty ? o.partyName : 'Unknown Supplier',
      childColumns: const [
        DyTableColumnSpec(key: '_pad1', label: '', flex: 1, isSortable: false),
        DyTableColumnSpec(key: '_pad2', label: '', flex: 1, isSortable: false),
        DyTableColumnSpec(key: '_pad3', label: '', flex: 1, isSortable: false),
        DyTableColumnSpec(key: '_pad4', label: '', flex: 1, isSortable: false),
        DyTableColumnSpec(key: '_pad5', label: '', flex: 2, isSortable: false),
        DyTableColumnSpec(key: 'designPattern', label: 'Design', flex: 1),
        DyTableColumnSpec(key: 'pcs', label: 'Pcs', flex: 1, isNumeric: true),
        DyTableColumnSpec(key: 'quantity', label: 'Quantity', flex: 1, isNumeric: true),
        DyTableColumnSpec(key: 'unit', label: 'Unit', flex: 1),
        DyTableColumnSpec(key: 'rate', label: 'Rate', flex: 1, isNumeric: true),
        DyTableColumnSpec(key: 'amount', label: 'Amount', flex: 1, isNumeric: true),
      ],
      data: {
        'vno': o.displayOrderNo,
        'jobLink': o.jobLink,
        'date': _formatShortDate(o.date),
        'status': o.isPending ? 'PENDING' : 'COMPLETED',
        'partyName': o.partyName.isNotEmpty ? o.partyName : 'Unknown Supplier',
        'designPattern': o.primaryFabric,
        'pcs': o.totalPcsDisplay,
        'quantity': o.totalQtyDisplay,
        'unit': o.primaryUnit,
        'rate': o.formattedRate(),
        'amount': o.formattedFinalAmount(),
      },
      children: o.lineItems.map((item) {
        return DyTableRowData(
          id: '${o.vno}-${item.srNo}',
          rowType: DyTableRowType.child,
          voucherNo: '${o.displayOrderNo}-${item.srNo}',
          partyName: item.quality,
          data: {
            '_pad1': '',
            '_pad2': '',
            '_pad3': '',
            '_pad4': '',
            '_pad5': '',
            'designPattern': item.quality.isNotEmpty ? item.quality : 'Lot #${item.srNo}',
            'pcs': item.pieces > 0 ? '${item.pieces.toInt()}' : '-',
            'quantity': item.meters > 0 ? item.meters.toStringAsFixed(1) : '-',
            'unit': item.unit.isNotEmpty ? item.unit : 'MTR',
            'rate': item.rate > 0 ? '₹${item.rate.toStringAsFixed(2)}' : '-',
            'amount': item.formattedAmount(),
          },
        );
      }).toList(),
    );
  }
}
