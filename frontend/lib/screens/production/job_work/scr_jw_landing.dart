/*
================================================================================
LLM CONTEXT & QUERY SPACE — JOB WORK LANDING SCREEN (scr_jw_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing container screen for Job Work Operations (`jw` / Stage 2 & 3 Production Pipeline).
   - Manages the 8 Job Work submodules: Stitch Desp (O5), Stitch Recd (O6), Diamond Desp (O7), 
     Diamond Recd (O8), Embroidery Desp (O9), Embroidery Recd (O10), Charak Desp (O11), Charak Recd (O12).
   - Built on native DyPageCanvas 4-Shell Architecture (DyShlDash, DyShlDetails, DyShlReports, DyShlTasks).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - PageHeader: Title = 'Job Work', mode = PageHeaderMode.standard, actions = const [] (no trailing buttons for now).
   - Subpages Switcher: PageSubpages with labels ['Dash', 'Details', 'Reports', 'Tasks'].
   - Submodule Switcher: 8 options mapped to JwCategory enum.
   - 3-Tiered Table Mapping: Tier 1 Grouping (Party/Mill), Tier 2 Header (MdlJwHeader), Tier 3 Details (MdlJwLineItem).
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
import '../../../models/production/mdl_jw.dart';
import '../../../services/production/srv_jw.dart';

/// [ScrJwLanding] — Main Landing Container Screen for Job Work.
class ScrJwLanding extends StatefulWidget {
  const ScrJwLanding({super.key});

  @override
  State<ScrJwLanding> createState() => _ScrJwLandingState();
}

class _ScrJwLandingState extends State<ScrJwLanding> {
  final SrvJw _jwService = SrvJw();
  final TextEditingController _searchController = TextEditingController();

  JwCategory _selectedCategory = JwCategory.stitchDesp;
  String _viewMode = 'table';
  int _contextTabIndex = 1; // Default to 'Details' shell (Index 1)
  String _groupingMode = 'none'; // 'none', 'party', 'quality'
  String? _searchQuery;

  // Filter States
  Set<String> _selectedParties = {};
  List<String> _partyOptions = [];
  Set<String> _selectedQualities = {};
  List<String> _qualityOptions = [];
  final Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;

  List<MdlJwHeader> _headers = [];
  MdlJwHeader? _selectedHeader;
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
    _loadFilterOptions();
    _fetchHeaders(resetOffset: true);
  }

  Future<void> _loadFilterOptions() async {
    final parties = await _jwService.getPartyOptions(_selectedCategory);
    final qualities = await _jwService.getQualityOptions(_selectedCategory);
    if (!mounted) return;
    setState(() {
      _partyOptions = parties;
      _qualityOptions = qualities;
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

    final statusFilter = _selectedStatuses.contains('Completed')
        ? 'Completed'
        : (_selectedStatuses.contains('Pending') ? 'Pending' : 'All');

    final dateRange = _selectedDateRange?.toRange();
    final res = await _jwService.getJobWorkHeaders(
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
      _headers = res.data;
      _totalCount = res.totalCount;
      _isLoading = false;
      if (_headers.isNotEmpty && (_selectedHeader == null || !_headers.any((h) => h.id == _selectedHeader!.id))) {
        _selectedHeader = _headers.first;
      }
    });
  }

  void _onCategoryChanged(JwCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedParties.clear();
      _selectedQualities.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedDateLabel = null;
      _selectedHeader = null;
    });
    _loadFilterOptions();
    _fetchHeaders(resetOffset: true);
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
      _groupingMode = 'none';
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

  IconData _getIconForCategory(JwCategory category) {
    switch (category) {
      case JwCategory.stitchDesp:
      case JwCategory.stitchRecd:
        return shad.LucideIcons.scissors;
      case JwCategory.diamondDesp:
      case JwCategory.diamondRecd:
        return shad.LucideIcons.gem;
      case JwCategory.embroideryDesp:
      case JwCategory.embroideryRecd:
        return shad.LucideIcons.sparkles;
      case JwCategory.charakDesp:
      case JwCategory.charakRecd:
        return shad.LucideIcons.shirt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.landing,
      header: PageHeader(
        title: 'Job Work',
        mode: PageHeaderMode.standard,
        actions: const [], // Zero trailing buttons for now as requested
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
      subpageIndex: _contextTabIndex,
      subpageContents: [
        const DyShlDash(title: 'Job Work'),
        _buildDetailsShell(),
        const DyShlReports(title: 'Job Work'),
        const DyShlTasks(),
      ],
    );
  }

  Widget _buildDetailsShell() {
    final hasFilters = _selectedParties.isNotEmpty ||
        _selectedQualities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedDateRange != null;

    return DyShlDetails(
      title: 'Job Work',
      entityName: 'Jobs',
      moduleName: 'job_work',
      selectedViewMode: _viewMode,
      onViewModeChanged: (mode) {
        setState(() {
          _viewMode = mode;
        });
      },
      submoduleWidget: Builder(
        builder: (btnContext) {
          return MicroButton(
            leadingIcon: _getIconForCategory(_selectedCategory),
            label: _selectedCategory.displayName,
            badgeCount: _totalCount,
            trailingIcon: shad.LucideIcons.chevronDown,
            isSelected: true,
            onPressed: () {
              shad.showOverlay(
                btnContext,
                shad.PopoverConfiguration(
                  anchorAlignment: Alignment.bottomLeft,
                  alignment: Alignment.topLeft,
                  offset: const Offset(0, 4),
                  builder: (popContext) => DabSubmodulePopover<JwCategory>(
                    title: 'Job Work Submodule',
                    selectedId: _selectedCategory,
                    items: JwCategory.values
                        .map(
                          (c) => DabSubmoduleItem<JwCategory>(
                            id: c,
                            label: c.displayName,
                            icon: _getIconForCategory(c),
                            count: c == _selectedCategory ? _totalCount : 0,
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
      selectedQualities: _selectedQualities,
      qualityOptions: _qualityOptions,
      onQualityChanged: (set) {
        setState(() {
          _selectedQualities = set;
        });
        _fetchHeaders(resetOffset: true);
      },
      selectedStatuses: _selectedStatuses,
      onStatusChanged: (statuses) {
        setState(() {
          _selectedStatuses.clear();
          _selectedStatuses.addAll(statuses);
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
      selectedGroup: _groupingMode,
      onGroupChanged: (g) {
        setState(() {
          _groupingMode = g;
        });
      },
      groupOptions: const [
        DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
        DabGroupOption(id: 'party', label: 'Party', icon: shad.LucideIcons.user),
        DabGroupOption(id: 'quality', label: 'Fabric', icon: shad.LucideIcons.shirt),
      ],
      isLoading: _isLoading,
      tableColumns: _jwTableColumns,
      tableRows: _buildMappedTableRows(),
      gridItems: _buildMappedGridItems(),
      listItems: _buildMappedListItems(),
      selectedListItem: _selectedHeader != null ? _mapHeaderToListItem(_selectedHeader!) : null,
      selectedGridItem: _selectedHeader != null ? _mapHeaderToGridItem(_selectedHeader!) : null,
      onListItemSelected: (item) {
        if (item == null) return;
        final header = _headers.firstWhere(
          (h) => h.id == item.id,
          orElse: () => _headers.first,
        );
        setState(() {
          _selectedHeader = header;
        });
      },
      onGridItemSelected: (item) {
        if (item == null) return;
        final header = _headers.firstWhere(
          (h) => h.id == item.id,
          orElse: () => _headers.first,
        );
        setState(() {
          _selectedHeader = header;
        });
      },
      summaryTotals: _buildSummaryTotals(),
      totalRecords: _totalCount,
      pageIndex: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchHeaders(resetOffset: false);
      },
    );
  }

  static const List<DyTableColumnSpec> _jwTableColumns = [
    DyTableColumnSpec(key: 'vno', label: 'JW CODE', width: 110, isPinnedLeft: true),
    DyTableColumnSpec(key: 'date', label: 'DATE', width: 105),
    DyTableColumnSpec(key: 'partyName', label: 'JOB WORKER / PARTY', flex: 2),
    DyTableColumnSpec(key: 'designPattern', label: 'FABRIC QUALITY', flex: 2),
    DyTableColumnSpec(key: 'totalPcs', label: 'PIECES', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'totalMtrs', label: 'METERS', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'rate', label: 'JOB RATE', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'amount', label: 'AMOUNT', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'status', label: 'STATUS', width: 110),
  ];

  List<DynamicListItem> _buildMappedListItems() {
    return _headers.map((h) => _mapHeaderToListItem(h)).toList();
  }

  DynamicListItem _mapHeaderToListItem(MdlJwHeader h) {
    return DynamicListItem(
      id: h.id,
      title: h.partyName,
      subtitle: h.quality,
      indexNumber: h.displayVoucherCode,
      amount: h.formattedAmount(),
      topTrailing: h.formattedDate,
      topLeading: h.isPending
          ? const shad.OutlineBadge(child: Text('Pending'))
          : const shad.PrimaryBadge(child: Text('Completed')),
    );
  }

  List<DyGridItem> _buildMappedGridItems() {
    return _headers.map((h) => _mapHeaderToGridItem(h)).toList();
  }

  DyGridItem _mapHeaderToGridItem(MdlJwHeader h) {
    return DyGridItem(
      id: h.id,
      title: h.partyName,
      voucherNo: h.displayVoucherCode,
      partyName: h.partyName,
      designPattern: h.quality,
      quantity: h.totalPieces > 0 ? '${h.totalPieces} Pcs (${h.formattedTotalMeters})' : '-',
      amount: h.formattedAmount(),
      statusBadge: h.isPending
          ? const shad.OutlineBadge(child: Text('PENDING'))
          : const shad.PrimaryBadge(child: Text('COMPLETED')),
    );
  }

  Map<String, String> _buildSummaryTotals() {
    int totalPcs = 0;
    double totalMts = 0;
    double totalAmt = 0;
    for (final h in _headers) {
      totalPcs += h.totalPieces;
      totalMts += h.totalMeters;
      totalAmt += h.netAmount;
    }
    return {
      'designPattern': 'TOTALS',
      'totalPcs': '$totalPcs Pcs',
      'totalMtrs': '${totalMts.toStringAsFixed(1)} Mtr',
      'amount': '₹${totalAmt.toStringAsFixed(2)}',
    };
  }

  List<DyTableRowData> _buildMappedTableRows() {
    if (_groupingMode == 'none') {
      return _headers.map((h) => h.toDyDefRowData()).toList();
    }

    final Map<String, List<MdlJwHeader>> groupedMap = {};
    for (final header in _headers) {
      final groupKey = _groupingMode == 'party'
          ? (header.partyName.isNotEmpty ? header.partyName : 'Unknown Party')
          : (header.quality.isNotEmpty ? header.quality : 'N/A');
      groupedMap.putIfAbsent(groupKey, () => []).add(header);
    }

    final result = <DyTableRowData>[];
    groupedMap.forEach((groupName, groupHeaders) {
      final childDefRows = groupHeaders.map((h) => h.toDyDefRowData()).toList();
      final totalPcs = groupHeaders.fold<int>(0, (sum, h) => sum + h.totalPieces);
      final totalAmt = groupHeaders.fold<double>(0, (sum, h) => sum + h.netAmount);

      result.add(
        DyTableRowData(
          id: 'group_$groupName',
          rowType: DyTableRowType.group,
          partyName: groupName,
          title: '$groupName (${groupHeaders.length} Jobs)',
          data: {
            'vno': '$groupName (${groupHeaders.length} Jobs)',
            'partyName': groupName,
            'totalPcs': '$totalPcs Pcs',
            'amount': '₹${totalAmt.toStringAsFixed(2)}',
          },
          children: childDefRows,
        ),
      );
    });

    return result;
  }
}
