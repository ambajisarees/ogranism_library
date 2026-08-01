/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE BILLS LANDING SCREEN (scr_pb_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing workstation container for Purchase Bills (`pb`).
   - Manages all 10 Purchase Bill submodules (`P1` to `P10`): Grey, Finish, Lace,
     Mill / Job Work, Stitching / Value Add, Packing, General, Yarn, Store, Capital.
   - Dual View Modes: Full Dense Table View (`table`) & Master-Detail Split View (`split`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - 2-Row Top Scaffolding:
     * Row 1: `PageHeader` (`Purchase Bills`, `+ New Bill` primary button).
     * Row 2: Native `shad.Tabs` Context Tabs (`Dashboard`, `Details`, `Tasks`).
   - Details Tab (Index 1): `DynamicActionBar` (DAB) with `submoduleWidget` popover overlay
     for 10 categories, Search input, Supplier/Party filter, Quality filter, Status filter,
     Date Range filter, and Clear All.
   - Line Item Source Routing:
     * Grey Purchase (`P1`): `sq_PINVTRN`
     * Mill Purchase (`P4`): `sq_MILLREC`
     * All other submodules (`P2`, `P3`, `P5`–`P10`): `sq_BILLDET`

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Read-only Airbyte mirror tables (`sq_BILLS`, `sq_BILLDET`, `sq_PINVTRN`, `sq_MILLREC`).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/page/dy_action_bar.dart';
import '../../../dynamic_ai/micro/dab/dab_submodule_pop.dart';
import '../../../dynamic_ai/micro/dy_micro_button.dart';
import '../../../dynamic_ai/page/dy_table_pane.dart';
import '../../../dynamic_ai/page/dy_list_pane.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../models/production/mdl_pb.dart';
import '../../../services/production/srv_pb.dart';
import 'scr_pb_detail_canvas.dart';
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
  String _viewMode = 'table'; // 'table' or 'split'
  String? _searchQuery;

  // Filter States
  Set<String> _selectedParties = {};
  List<String> _partyOptions = [];
  Set<String> _selectedQualities = {};
  List<String> _qualityOptions = [];
  Set<String> _selectedStatuses = {};
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
    final parties = await _pbService.getPartyOptions(category: _selectedCategory);
    final qualities = await _pbService.getQualityOptions(category: _selectedCategory);
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

    final dateRange = _selectedDateRange?.toRange();
    final statusFilter = _selectedStatuses.contains('Completed')
        ? 'Completed'
        : (_selectedStatuses.contains('Pending') ? 'Pending' : 'All');

    final result = await _pbService.getPurchaseBills(
      limit: _limit,
      offset: _offset,
      category: _selectedCategory,
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
      if (_bills.isNotEmpty && (_selectedBill == null || !_bills.any((b) => b.vno == _selectedBill!.vno))) {
        _selectedBill = _bills.first;
      }
    });
  }

  void _onCategoryChanged(PbCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedParties.clear();
      _selectedQualities.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedDateLabel = null;
      _selectedBill = null;
    });
    _loadFilterOptions();
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
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final activeCount = _categoryCounts[_selectedCategory] ?? _totalCount;
    final hasFilters = _selectedParties.isNotEmpty ||
        _selectedQualities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedDateRange != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. PAGE HEADER (First Row: Title & Primary Action Button)
        PageHeader(
          title: 'Purchase Bills',
          actions: [
            shad.PrimaryButton(
              onPressed: () => ScrPbFormDialog.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('New Bill'),
                ],
              ),
            ),
          ],
        ),

        const shad.DensityGap(shad.gapSm),

        // 2. CONTEXT TABS (Second Row: Dashboard, Details, Tasks)
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

        // 3. TAB CONTENT
        Expanded(
          child: () {
            switch (_contextTabIndex) {
              case 0:
                // Dashboard Tab (Placeholder)
                return Center(
                  child: Text(
                    'Purchase Bills Dashboard Analytics',
                    style: theme.typography.h4.copyWith(color: colors.mutedForeground),
                  ),
                );
              case 1:
                // Details Tab (DAB + Dense Table Grid or Master-Detail Split View)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DynamicActionBar(
                      entityName: 'Bills',
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
                        _fetchBills(resetOffset: true);
                      },
                      // Filter Slots
                      selectedParties: _selectedParties,
                      partyOptions: _partyOptions,
                      onPartyChanged: (set) {
                        setState(() {
                          _selectedParties = set;
                        });
                        _fetchBills(resetOffset: true);
                      },
                      selectedQualities: _selectedQualities,
                      qualityOptions: _qualityOptions,
                      onQualityChanged: (set) {
                        setState(() {
                          _selectedQualities = set;
                        });
                        _fetchBills(resetOffset: true);
                      },
                      selectedStatuses: _selectedStatuses,
                      onStatusChanged: (statuses) {
                        setState(() {
                          _selectedStatuses = statuses;
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
                    ),

                    const SizedBox(height: 12),

                    // Main Content Area
                    Expanded(
                      child: _isLoading
                          ? const Center(child: shad.CircularProgressIndicator())
                          : _bills.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Purchase Bills found for ${_selectedCategory.displayName}',
                                    style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                                  ),
                                )
                              : _viewMode == 'table'
                                  ? _buildTabularView()
                                  : _buildSplitView(),
                    ),
                  ],
                );
              case 2:
                // Tasks Tab (Placeholder)
                return Center(
                  child: Text(
                    'Purchase Bills Tasks & Alerts (0 Active Tasks)',
                    style: theme.typography.h4.copyWith(color: colors.mutedForeground),
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

  static const List<DynamicTableColumnSpec> _pbTableColumns = [
    DynamicTableColumnSpec(label: 'VOUCHER...', key: 'vno', width: 110),
    DynamicTableColumnSpec(label: 'PARTY', key: 'party', flex: 2),
    DynamicTableColumnSpec(label: 'QUALITY', key: 'fabric', flex: 2),
    DynamicTableColumnSpec(label: 'QUANTITY', key: 'totalPcs', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'AMOUNT', key: 'amount', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'STATUS', key: 'status', width: 90, alignment: Alignment.center),
    DynamicTableColumnSpec(label: '', key: 'actions', width: 72, alignment: Alignment.center),
  ];

  List<DynamicTableRowData> _mapBillsToRows() {
    return _bills.map((b) {
      return DynamicTableRowData(
        id: b.vno.toString(),
        voucherNo: b.vno.toString(),
        partyName: b.partyName,
        designPattern: b.primaryQuality,
        quantity: b.formattedQuantity,
        amount: b.formattedFinalAmount,
        amountValue: b.finalAmount,
        status: b.status.toUpperCase(),
        childRows: b.lineItems.map((item) {
          return DynamicTableRowData(
            id: '${b.vno}_${item.srNo}',
            voucherNo: item.srNo.toString(),
            partyName: '',
            designPattern: item.quality.isNotEmpty ? item.quality : 'N/A',
            quantity: item.meters > 0 ? '${item.meters.toStringAsFixed(1)} Mtr' : '-',
            amount: item.formattedAmount(),
            amountValue: item.amount,
            status: '',
            rawData: {
              'pcs': item.pcs > 0 ? item.pcs.toString() : '-',
              'rate': item.rate > 0 ? '₹${item.rate.toStringAsFixed(2)}' : '-',
            },
          );
        }).toList(),
        rawData: b.core.toJson(),
      );
    }).toList();
  }

  /// Full-Page Dense Data Table Grid
  Widget _buildTabularView() {
    return DynamicDenseTable(
      rows: _mapBillsToRows(),
      columns: _pbTableColumns,
      enableExpansion: true,
      totalRecords: _totalCount,
      currentPage: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchBills(resetOffset: false);
      },
      onRowTap: (row) {
        final bill = _bills.firstWhere((b) => b.vno.toString() == row.id, orElse: () => _bills.first);
        setState(() {
          _selectedBill = bill;
          _viewMode = 'split';
        });
      },
    );
  }

  /// Master-Detail Split Pane View
  Widget _buildSplitView() {
    final listItems = _bills
        .map(
          (b) => DynamicListItem(
            id: b.vno.toString(),
            title: b.partyName,
            subtitle: '${b.displayBillNo} • ${b.primaryQuality}',
            topLeading: b.isPending
                ? const shad.OutlineBadge(child: Text('Pending'))
                : const shad.PrimaryBadge(child: Text('Completed')),
            topTrailing: b.formattedDate,
            amount: b.formattedFinalAmount,
            indexNumber: b.displayBillNo,
            rawData: b.core.toJson(),
          ),
        )
        .toList();

    final selectedListItem = _selectedBill != null
        ? listItems.firstWhere((item) => item.id == _selectedBill!.vno.toString(), orElse: () => listItems.first)
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
            final bill = _bills.firstWhere((b) => b.vno.toString() == item.id, orElse: () => _bills.first);
            setState(() {
              _selectedBill = bill;
            });
          },
        ),

        const SizedBox(width: 16),

        // Right Detail Canvas
        Expanded(
          child: _selectedBill != null
              ? ScrPbDetailCanvas(
                  header: _selectedBill!,
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
