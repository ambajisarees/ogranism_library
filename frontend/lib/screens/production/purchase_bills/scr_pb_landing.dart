/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE BILLS LANDING SCREEN (scr_pb_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing workstation container for Purchase Bills (`pb` / Stage 3 of Production Pipeline).
   - Conforms 100% to DyPageCanvas 4-Shell Architecture (`Dash`, `Details`, `Reports`, `Tasks`).
   - Manages 10 Purchase Bill submodules (`P1` to `P10`): Grey, Finish, Lace,
     Mill / Job Work, Stitching / Value Add, Packing, General, Yarn, Store, Capital.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Details Shell (`DyShlDetails`): Uses DabMode.details with 10 Submodules popover,
     View Switcher, Party Filter, Quality Filter, Date Filter, Spacer, Search, 3-Dots.
   - Line Item Source Routing:
     * Grey Purchase (`P1`): `sq_PINVTRN`
     * Mill Purchase (`P4`): `sq_MILLREC`
     * All other submodules (`P2`, `P3`, `P5`–`P10`): `sq_BILLDET`
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/micro/dab/dab_submodule_pop.dart';
import '../../../dynamic_ai/micro/dy_micro_button.dart';
import '../../../dynamic_ai/micro/cards/dy_grid_card.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';
import '../../../dynamic_ai/shells/dy_shl_dash.dart';
import '../../../dynamic_ai/shells/dy_shl_details.dart';
import '../../../dynamic_ai/shells/dy_shl_reports.dart';
import '../../../dynamic_ai/shells/dy_shl_tasks.dart';
import '../../../dynamic_ai/shells/dy_page_canvas.dart';
import '../../../models/production/mdl_pb.dart';
import '../../../services/production/srv_pb.dart';
import 'scr_pb_form_dialog.dart';

/// [ScrPbLanding] — Main Landing Container Screen for Purchase Bills.
class ScrPbLanding extends StatefulWidget {
  const ScrPbLanding({super.key});

  @override
  State<ScrPbLanding> createState() => _ScrPbLandingState();
}

class _ScrPbLandingState extends State<ScrPbLanding> {
  final SrvPb _pbService = SrvPb();
  final TextEditingController _searchController = TextEditingController();

  // Navigation & View State
  int _contextTabIndex = 1; // Default selected: Details (1)
  PbCategory _selectedCategory = PbCategory.grey;
  Map<PbCategory, int> _categoryCounts = {};
  String _viewMode = 'table';
  String? _searchQuery;

  // Filter States
  final Set<String> _selectedParties = {};
  List<String> _partyOptions = [];
  final Set<String> _selectedQualities = {};
  List<String> _qualityOptions = [];
  final Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;

  List<MdlPbHeader> _bills = [];
  MdlPbHeader? _selectedBill;
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
    _loadFilterOptions();
    _fetchBills(resetOffset: true);
  }

  Future<void> _loadCategoryCounts() async {
    final counts = await _pbService.getCategoryCounts();
    if (!mounted) return;
    setState(() {
      _categoryCounts = counts;
    });
  }

  Future<void> _loadFilterOptions() async {
    final parties = await _pbService.getSupplierOptions();
    final qualities = await _pbService.getQualityOptions();
    if (!mounted) return;
    setState(() {
      _partyOptions = parties;
      _qualityOptions = qualities;
    });
  }

  Future<void> _fetchBills({bool resetOffset = false}) async {
    if (resetOffset) {
      setState(() {
        _offset = 0;
      });
    }

    setState(() {
      _isLoading = true;
    });

    final statusFilter = _selectedStatuses.contains('Completed')
        ? 'Completed'
        : (_selectedStatuses.contains('Pending') ? 'Pending' : 'All');

    final dateRange = _selectedDateRange?.toRange();
    final result = await _pbService.getBillsByCategory(
      category: _selectedCategory,
      limit: _limit,
      offset: _offset,
      searchQuery: _searchQuery,
      selectedParties: _selectedParties,
      selectedQualities: _selectedQualities,
      statusFilter: statusFilter,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
    );

    if (!mounted) return;

    setState(() {
      _bills = result.data;
      _totalCount = result.totalCount;
      _isLoading = false;
      if (_bills.isNotEmpty && (_selectedBill == null || !_bills.any((b) => b.id == _selectedBill!.id))) {
        _selectedBill = _bills.first;
      }
    });
  }

  void _onCategoryChanged(PbCategory category) {
    setState(() {
      _selectedCategory = category;
      _selectedParties.clear();
      _selectedQualities.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedDateLabel = null;
      _selectedBill = null;
    });
    _fetchBills(resetOffset: true);
  }

  void _onClearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = null;
      _selectedParties.clear();
      _selectedQualities.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedDateLabel = null;
    });
    _fetchBills(resetOffset: true);
  }

  @override
  Widget build(BuildContext context) {
    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.landing,
      header: PageHeader(
        title: 'Purchase Bills',
        actions: [
          shad.OutlineButton(
            onPressed: () {
              shad.showToast(
                context: context,
                builder: (context, show) => shad.Card(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Print Bills Summary triggered.'),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.printer, size: 16),
                shad.DensityGap(shad.gapSm),
                Text('Print'),
              ],
            ),
          ),
          shad.PrimaryButton(
            onPressed: () => ScrPbFormDialog.show(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.plus, size: 16),
                shad.DensityGap(shad.gapSm),
                Text('New Bill'),
              ],
            ),
          ),
        ],
        subpages: PageSubpages(
          selectedIndex: _contextTabIndex,
          labels: const ['Dash', 'Details', 'Reports', 'Tasks'],
          onSubpageChanged: (idx) {
            setState(() {
              _contextTabIndex = idx;
            });
          },
        ),
      ),
      subpageIndex: _contextTabIndex,
      subpageContents: [
        const DyShlDash(title: 'Purchase Bills'),
        _buildDetailsShell(),
        const DyShlReports(title: 'Purchase Bills'),
        const DyShlTasks(),
      ],
    );
  }

  Widget _buildDetailsShell() {
    final activeCount = _categoryCounts[_selectedCategory] ?? _totalCount;
    final hasFilters = _selectedParties.isNotEmpty ||
        _selectedQualities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedDateRange != null;

    return DyShlDetails(
      title: 'Purchase Bills',
      entityName: 'Bills',
      moduleName: 'purchase_bills',
      selectedViewMode: _viewMode,
      onViewModeChanged: (mode) {
        setState(() {
          _viewMode = mode;
        });
      },
      submoduleWidget: Builder(
        builder: (btnContext) {
          return MicroButton(
            leadingIcon: shad.LucideIcons.fileText,
            label: _selectedCategory.displayName,
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
                  builder: (popContext) => DabSubmodulePopover<PbCategory>(
                    title: 'Submodule',
                    selectedId: _selectedCategory,
                    items: PbCategory.values
                        .map(
                          (c) => DabSubmoduleItem<PbCategory>(
                            id: c,
                            label: c.displayName,
                            icon: shad.LucideIcons.fileText,
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
        _fetchBills(resetOffset: true);
      },
      selectedParties: _selectedParties,
      partyOptions: _partyOptions,
      onPartyChanged: (parties) {
        setState(() {
          _selectedParties.clear();
          _selectedParties.addAll(parties);
        });
        _fetchBills(resetOffset: true);
      },
      selectedQualities: _selectedQualities,
      qualityOptions: _qualityOptions,
      onQualityChanged: (qualities) {
        setState(() {
          _selectedQualities.clear();
          _selectedQualities.addAll(qualities);
        });
        _fetchBills(resetOffset: true);
      },
      selectedStatuses: _selectedStatuses,
      onStatusChanged: (statuses) {
        setState(() {
          _selectedStatuses.clear();
          _selectedStatuses.addAll(statuses);
        });
        _fetchBills(resetOffset: true);
      },
      selectedDateRange: _selectedDateRange,
      selectedDateLabel: _selectedDateLabel,
      onDateRangeSelected: (range) {
        setState(() {
          _selectedDateRange = range;
          _selectedDateLabel = range != null ? 'Selected Date Range' : null;
        });
        _fetchBills(resetOffset: true);
      },
      hasActiveFilters: hasFilters,
      onClearAllFilters: _onClearAllFilters,
      isLoading: _isLoading,
      tableColumns: _pbTableColumns,
      tableRows: _bills.map((b) => b.toDyDefRowData()).toList(),
      gridItems: _buildMappedGridItems(),
      listItems: _buildMappedListItems(),
      selectedListItem: _selectedBill != null ? _mapBillToListItem(_selectedBill!) : null,
      selectedGridItem: _selectedBill != null ? _mapBillToGridItem(_selectedBill!) : null,
      onListItemSelected: (item) {
        if (item == null) return;
        final bill = _bills.firstWhere(
          (b) => b.id == item.id || b.displayVno == item.id,
          orElse: () => _bills.first,
        );
        setState(() {
          _selectedBill = bill;
        });
      },
      onGridItemSelected: (item) {
        if (item == null) return;
        final bill = _bills.firstWhere(
          (b) => b.id == item.id || b.displayVno == item.id,
          orElse: () => _bills.first,
        );
        setState(() {
          _selectedBill = bill;
        });
      },
      summaryTotals: _buildSummaryTotals(),
      totalRecords: _totalCount,
      pageIndex: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchBills(resetOffset: false);
      },
    );
  }

  static const List<DyTableColumnSpec> _pbTableColumns = [
    DyTableColumnSpec(key: 'vno', label: 'BILL NO', width: 110, isPinnedLeft: true),
    DyTableColumnSpec(key: 'date', label: 'DATE', width: 105),
    DyTableColumnSpec(key: 'partyName', label: 'SUPPLIER / PARTY NAME', flex: 2),
    DyTableColumnSpec(key: 'designPattern', label: 'FABRIC QUALITY', flex: 2),
    DyTableColumnSpec(key: 'quantity', label: 'METERS', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'totalPcs', label: 'PCS', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'rate', label: 'RATE', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'amount', label: 'BILL AMOUNT', isNumeric: true, textAlignment: Alignment.centerRight),
  ];

  List<DynamicListItem> _buildMappedListItems() {
    return _bills.map((b) => _mapBillToListItem(b)).toList();
  }

  DynamicListItem _mapBillToListItem(MdlPbHeader b) {
    return DynamicListItem(
      id: b.id.isNotEmpty ? b.id : b.displayVno,
      title: b.partyName.isNotEmpty ? b.partyName : 'Unknown Supplier',
      subtitle: b.primaryFabric,
      indexNumber: b.displayVno,
      amount: b.formattedFinalAmount,
      topTrailing: b.formattedCutDate,
      topLeading: b.isPending
          ? const shad.OutlineBadge(child: Text('Pending'))
          : const shad.PrimaryBadge(child: Text('Completed')),
    );
  }

  List<DyGridItem> _buildMappedGridItems() {
    return _bills.map((b) => _mapBillToGridItem(b)).toList();
  }

  DyGridItem _mapBillToGridItem(MdlPbHeader b) {
    return DyGridItem(
      id: b.id.isNotEmpty ? b.id : b.displayVno,
      title: b.partyName.isNotEmpty ? b.partyName : 'Unknown Supplier',
      voucherNo: b.displayVno,
      partyName: b.partyName.isNotEmpty ? b.partyName : 'Unknown Supplier',
      designPattern: b.primaryFabric,
      quantity: '${b.totalMeters.toStringAsFixed(1)} Mts',
      amount: b.formattedFinalAmount,
      statusBadge: b.isPending
          ? const shad.OutlineBadge(child: Text('PENDING'))
          : const shad.PrimaryBadge(child: Text('COMPLETED')),
    );
  }

  Map<String, String> _buildSummaryTotals() {
    int totalPcs = 0;
    double totalMts = 0;
    double totalAmt = 0;
    for (final b in _bills) {
      totalPcs += b.totalPieces;
      totalMts += b.totalMeters;
      totalAmt += b.finalAmount > 0 ? b.finalAmount : b.billAmount;
    }
    return {
      'designPattern': 'TOTALS',
      'quantity': '${totalMts.toStringAsFixed(1)} Mtr',
      'totalPcs': '$totalPcs Pcs',
      'amount': '₹${totalAmt.toStringAsFixed(2)}',
    };
  }
}
