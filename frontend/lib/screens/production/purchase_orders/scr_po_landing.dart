/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE ORDERS LANDING SCREEN (scr_po_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing container screen for Purchase Orders (`po`).
   - Manages the 5 PO submodules: Grey, Finish (`O13`), Lace (`O14`), Packing (`O15`), Studio (`O16`).
   - Supports dual view modes: Full Dense Table View (`table`) and Master-Detail Split View (`split`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Consumes module-level service `SrvPo` and module model `MdlPoHeader`.
   - Core models `SqBillsModel` and `SqBilldetModel` remain 100% untouched and immutable.
   - Live category counts fetched on startup for all 5 submodules.
   - Default view displays ALL entries, with Status popover filtering for `All`, `Pending`, `Completed`.
   - Dedicated Party Popover filtering powered by `_poService.getPartyOptions()`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_BILLS` is Airbyte-managed read-only mirror.
   - `Grey` category has no series code in legacy `sq_BILLS` (`seriesCode == null`), rendering empty state until raw grey PO table is assigned.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should New Purchase Order creation write via Edge Function to custom `sb_purord` or directly generate `sq_BILLS` equivalent vouchers?
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/components/page_level/page_header.dart';
import '../../../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../../../dynamic_ai/components/page_level/dab_widgets/dab_submodule_popover.dart';
import '../../../dynamic_ai/components/micro_level/micro_button.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';
import '../../../dynamic_ai/components/page_level/dynamic_list.dart';
import '../../../dynamic_ai/components/page_level/dynamic_list_card.dart';
import '../../../models/production/mdl_po.dart';
import '../../../services/production/srv_po.dart';
import 'scr_po_detail_canvas.dart';

/// Alias `PoSubmoduleCategory` to module domain model `PoCategory` for backward compatibility
typedef PoSubmoduleCategory = PoCategory;

/// [ScrPoLanding] — Main Landing Container Screen for Purchase Orders.
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
  String _viewMode = 'table'; // 'table' or 'split'
  String? _searchQuery;

  // Filter States
  Set<String> _selectedParties = {};
  List<String> _partyOptions = [];
  Set<String> _selectedStatuses = {}; // Empty by default = Show ALL entries!
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
    });
    _fetchHeaders(resetOffset: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final activeCount = _categoryCounts[_selectedCategory] ?? _totalCount;
    final hasFilters = _selectedParties.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedDateRange != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Page Header
        PageHeader(
          title: 'Purchase Orders',
        ),

        const shad.DensityGap(shad.gapSm),

        // 2. Dynamic Action Bar
        DynamicActionBar(
          entityName: 'Orders',
          selectedView: _viewMode,
          onViewChanged: (mode) {
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
            _searchQuery = val.trim();
            _fetchHeaders(resetOffset: true);
          },
          // Party Filter Popover Slot
          selectedParties: _selectedParties,
          partyOptions: _partyOptions,
          onPartyChanged: (set) {
            setState(() {
              _selectedParties = set;
            });
            _fetchHeaders(resetOffset: true);
          },
          // Status Filter Slot (All, Pending, Completed)
          selectedStatuses: _selectedStatuses,
          onStatusChanged: (statuses) {
            setState(() {
              _selectedStatuses = statuses;
            });
            _fetchHeaders(resetOffset: true);
          },
          // Date Range Filter Slot
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
        ),

        const SizedBox(height: 12),

        // 3. Main Content Area (Tabular vs Split View)
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? Center(
                      child: Text(
                        'No Purchase Orders found for ${_selectedCategory.label}',
                        style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                      ),
                    )
                  : _viewMode == 'table'
                      ? _buildTabularView()
                      : _buildSplitView(),
        ),
      ],
    );
  }

  static const List<DynamicTableColumnSpec> _poTableColumns = [
    DynamicTableColumnSpec(label: 'ORDER #', key: 'vno', width: 110),
    DynamicTableColumnSpec(label: 'DATE', key: 'date', width: 95),
    DynamicTableColumnSpec(label: 'PARTY / SUPPLIER', key: 'party', flex: 2),
    DynamicTableColumnSpec(label: 'FABRIC', key: 'fabric', flex: 2),
    DynamicTableColumnSpec(label: 'TOTAL MTRS', key: 'totalMtrs', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'TOTAL PCS', key: 'totalPcs', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'RATE', key: 'rate', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'AMOUNT', key: 'amount', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: '', key: 'actions', width: 72, alignment: Alignment.center),
  ];

  List<DynamicTableRowData> _mapOrdersToRows() {
    return _orders.map((o) {
      return DynamicTableRowData(
        id: o.vno.toString(),
        voucherNo: o.displayOrderNo,
        partyName: o.partyName.isNotEmpty ? o.partyName : 'Unknown Party',
        designPattern: o.primaryFabric,
        quantity: o.totalMeters > 0 ? '${o.totalMeters.toStringAsFixed(1)} Mtr' : '-',
        amount: o.formattedFinalAmount(),
        amountValue: o.finalAmount > 0 ? o.finalAmount : o.billAmount,
        status: o.isPending ? 'PENDING' : 'COMPLETED',
        childRows: o.lineItems.map((item) {
          return DynamicTableRowData(
            id: item.srNo.toString(),
            voucherNo: item.srNo.toString(),
            partyName: '',
            designPattern: item.quality.isNotEmpty ? item.quality : 'N/A',
            quantity: item.meters > 0 ? '${item.meters.toStringAsFixed(1)} Mtr' : '-',
            amount: item.formattedAmount(),
            amountValue: item.amount,
            status: '',
            rawData: {
              'pcs': item.pieces > 0 ? '${item.pieces.toInt()}' : '',
              'rate': item.rate > 0 ? item.rate.toStringAsFixed(2) : '',
              'rateFormatted': item.rate > 0 ? '₹${item.rate.toStringAsFixed(2)}' : '-',
            },
          );
        }).toList(),
        rawData: {
          'date': o.formattedDate,
          'totalPcs': o.totalPieces > 0 ? '${o.totalPieces} Pcs' : '-',
          'rate': o.formattedRate(),
        },
      );
    }).toList();
  }

  /// Full-Page Dense Table Grid
  Widget _buildTabularView() {
    return DynamicDenseTable(
      rows: _mapOrdersToRows(),
      columns: _poTableColumns,
      enableExpansion: true,
      totalRecords: _totalCount,
      currentPage: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchHeaders(resetOffset: false);
      },
      onRowTap: (row) {
        final order = _orders.firstWhere((o) => o.vno.toString() == row.id, orElse: () => _orders.first);
        setState(() {
          _selectedOrder = order;
          _viewMode = 'split';
        });
      },
    );
  }

  /// Master-Detail Split Pane View
  Widget _buildSplitView() {
    final listItems = _orders
        .map(
          (o) => DynamicListItem(
            id: o.vno.toString(),
            title: o.partyName.isNotEmpty ? o.partyName : 'Unknown Party',
            subtitle: '${o.displayOrderNo} • ${o.formattedDate}',
            topLeading: o.isPending
                ? const shad.OutlineBadge(child: Text('Pending'))
                : const shad.PrimaryBadge(child: Text('Completed')),
            topTrailing: o.formattedDate,
            amount: o.formattedFinalAmount(),
            indexNumber: '${o.vno}',
            rawData: o.core.toJson(),
          ),
        )
        .toList();

    final selectedListItem = _selectedOrder != null
        ? listItems.firstWhere((item) => item.id == _selectedOrder!.vno.toString(), orElse: () => listItems.first)
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Master List
        DynamicList(
          items: listItems,
          selectedItem: selectedListItem,
          onItemSelected: (item) {
            if (item == null) return;
            final order = _orders.firstWhere((o) => o.vno.toString() == item.id, orElse: () => _orders.first);
            setState(() {
              _selectedOrder = order;
            });
          },
        ),

        const SizedBox(width: 16),

        // Right Detail Canvas
        Expanded(
          child: _selectedOrder != null
              ? ScrPoDetailCanvas(
                  header: _selectedOrder!,
                  onClose: () {
                    setState(() {
                      _viewMode = 'table';
                    });
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
