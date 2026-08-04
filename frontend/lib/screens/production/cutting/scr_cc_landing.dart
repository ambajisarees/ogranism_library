/*
================================================================================
LLM CONTEXT & QUERY SPACE — CUTTING CARDS LANDING SCREEN (scr_cc_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing container screen for Multi-Cutting Cards (`cc` / Stage 2 of Production Pipeline).
   - Utilizes native DyPageCanvas 4-Shell Architecture with built-in subpage switcher.
   - Embeds DyShlDetails (Details shell), DyShlDash (Dashboard), DyShlReports (Reports), and DyShlTasks (4-Column Kanban).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - DynamicActionBar (DAB) begins directly with Search Cards ("Search Cards...") without submodule switcher.
   - Context Filters: Mill, Grey Quality, Status (Completed/Pending), Date Range, and Search Query.
   - 3-Tiered DyTable Engine: Renders 3-tiered table rows via `c.toDyDefRowData()`.
   - Native Token Strictness: Uses `shad.Theme.of(context)`, zero container wrappers, 36px DAB tokens.
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/micro/cards/dy_grid_card.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';
import '../../../dynamic_ai/shells/dy_shl_dash.dart';
import '../../../dynamic_ai/shells/dy_shl_details.dart';
import '../../../dynamic_ai/shells/dy_shl_reports.dart';
import '../../../dynamic_ai/shells/dy_shl_tasks.dart';
import '../../../dynamic_ai/shells/dy_page_canvas.dart';
import '../../../models/production/mdl_cc.dart';
import '../../../services/production/srv_cc.dart';
import 'scr_cc_form.dart';

/// [ScrCcLanding] — Main Landing Container Screen for Multi-Cutting Cards.
class ScrCcLanding extends StatefulWidget {
  const ScrCcLanding({super.key});

  @override
  State<ScrCcLanding> createState() => _ScrCcLandingState();
}

class _ScrCcLandingState extends State<ScrCcLanding> {
  final SrvCc _ccService = SrvCc();
  final TextEditingController _searchController = TextEditingController();

  bool _isCreating = false;
  String _viewMode = 'table';
  int _contextTabIndex = 1; // Default to 'Details' shell (Index 1)
  String _groupingMode = 'none'; // 'none', 'mill', 'quality'
  String? _searchQuery;

  // Filter States
  final Set<String> _selectedMills = {};
  List<String> _millOptions = [];
  final Set<String> _selectedQualities = {};
  List<String> _qualityOptions = [];
  final Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;

  List<MdlCcHeader> _cards = [];
  MdlCcHeader? _selectedCard;
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
    _fetchCards(resetOffset: true);
  }

  Future<void> _loadFilterOptions() async {
    final mills = await _ccService.getMillOptions();
    final qualities = await _ccService.getQualityOptions();
    if (!mounted) return;
    setState(() {
      _millOptions = mills;
      _qualityOptions = qualities;
    });
  }

  Future<void> _fetchCards({bool resetOffset = false}) async {
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
    final result = await _ccService.getCuttingCards(
      limit: _limit,
      offset: _offset,
      searchQuery: _searchQuery,
      selectedMills: _selectedMills,
      selectedQualities: _selectedQualities,
      statusFilter: statusFilter,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
    );

    if (!mounted) return;

    setState(() {
      _cards = result.data;
      _totalCount = result.totalCount;
      _isLoading = false;
      if (_cards.isNotEmpty && (_selectedCard == null || !_cards.any((c) => c.id == _selectedCard!.id))) {
        _selectedCard = _cards.first;
      }
    });
  }

  void _onClearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = null;
      _selectedMills.clear();
      _selectedQualities.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedDateLabel = null;
    });
    _fetchCards(resetOffset: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCreating) {
      return ScrCcForm(
        onBack: () {
          setState(() {
            _isCreating = false;
          });
        },
        onSave: () {
          setState(() {
            _isCreating = false;
          });
          _fetchCards(resetOffset: true);
        },
      );
    }

    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.landing,
      header: PageHeader(
        title: 'Cutting Cards',
        actions: [
          shad.OutlineButton(
            onPressed: () {
              shad.showToast(
                context: context,
                builder: (context, show) => shad.Card(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Print Cutting Report triggered.'),
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
          shad.OutlineButton(
            onPressed: () {
              shad.showToast(
                context: context,
                builder: (context, show) => shad.Card(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Export Cutting Data triggered.'),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.download, size: 16),
                shad.DensityGap(shad.gapSm),
                Text('Export'),
              ],
            ),
          ),
          shad.PrimaryButton(
            onPressed: () {
              setState(() {
                _isCreating = true;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.plus, size: 16),
                shad.DensityGap(shad.gapSm),
                Text('Add'),
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
        const DyShlDash(title: 'Cutting Cards'),
        _buildDetailsShell(),
        const DyShlReports(title: 'Cutting Cards'),
        const DyShlTasks(),
      ],
    );
  }

  Widget _buildDetailsShell() {
    final hasFilters = _selectedMills.isNotEmpty ||
        _selectedQualities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedDateRange != null;

    return DyShlDetails(
      title: 'Cutting Cards',
      entityName: 'Cards',
      moduleName: 'cutting_cards',
      selectedViewMode: _viewMode,
      onViewModeChanged: (mode) {
        setState(() {
          _viewMode = mode;
        });
      },
      searchQuery: _searchQuery,
      onSearchChanged: (val) {
        _searchQuery = val?.trim();
        _fetchCards(resetOffset: true);
      },
      selectedMills: _selectedMills,
      millOptions: _millOptions,
      onMillChanged: (mills) {
        setState(() {
          _selectedMills.clear();
          _selectedMills.addAll(mills);
        });
        _fetchCards(resetOffset: true);
      },
      selectedQualities: _selectedQualities,
      qualityOptions: _qualityOptions,
      onQualityChanged: (qualities) {
        setState(() {
          _selectedQualities.clear();
          _selectedQualities.addAll(qualities);
        });
        _fetchCards(resetOffset: true);
      },
      selectedStatuses: _selectedStatuses,
      onStatusChanged: (statuses) {
        setState(() {
          _selectedStatuses.clear();
          _selectedStatuses.addAll(statuses);
        });
        _fetchCards(resetOffset: true);
      },
      selectedDateRange: _selectedDateRange,
      selectedDateLabel: _selectedDateLabel,
      onDateRangeSelected: (range) {
        setState(() {
          _selectedDateRange = range;
          _selectedDateLabel = range != null ? 'Selected Date Range' : null;
        });
        _fetchCards(resetOffset: true);
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
        DabGroupOption(id: 'mill', label: 'Mill', icon: shad.LucideIcons.warehouse),
        DabGroupOption(id: 'quality', label: 'Fabric', icon: shad.LucideIcons.shirt),
        DabGroupOption(id: 'cut', label: 'Cut', icon: shad.LucideIcons.scissors),
      ],
      isLoading: _isLoading,
      tableColumns: _ccTableColumns,
      tableRows: _buildMappedTableRows(),
      gridItems: _buildMappedGridItems(),
      listItems: _buildMappedListItems(),
      selectedListItem: _selectedCard != null ? _mapCardToListItem(_selectedCard!) : null,
      selectedGridItem: _selectedCard != null ? _mapCardToGridItem(_selectedCard!) : null,
      onListItemSelected: (item) {
        if (item == null) return;
        final card = _cards.firstWhere(
          (c) => c.id == item.id || c.multiVno.toString() == item.id,
          orElse: () => _cards.first,
        );
        setState(() {
          _selectedCard = card;
        });
      },
      onGridItemSelected: (item) {
        if (item == null) return;
        final card = _cards.firstWhere(
          (c) => c.id == item.id || c.multiVno.toString() == item.id,
          orElse: () => _cards.first,
        );
        setState(() {
          _selectedCard = card;
        });
      },
      summaryTotals: _buildSummaryTotals(),
      totalRecords: _totalCount,
      pageIndex: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchCards(resetOffset: false);
      },
    );
  }

  static const List<DyTableColumnSpec> _ccTableColumns = [
    DyTableColumnSpec(key: 'vno', label: 'CC CODE', width: 110, isPinnedLeft: true),
    DyTableColumnSpec(key: 'date', label: 'DATE', width: 105),
    DyTableColumnSpec(key: 'partyName', label: 'MILL / PROCESSOR', flex: 2),
    DyTableColumnSpec(key: 'designPattern', label: 'GREY FABRIC QUALITY', flex: 2),
    DyTableColumnSpec(key: 'cutLength', label: 'CUT LENGTH', textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'totalPcs', label: 'FRESH PCS', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'freshPct', label: 'FRESH %', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'rate', label: 'COST / PC', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'amount', label: 'INVESTMENT', isNumeric: true, textAlignment: Alignment.centerRight),
  ];

  List<DynamicListItem> _buildMappedListItems() {
    return _cards.map((c) => _mapCardToListItem(c)).toList();
  }

  DynamicListItem _mapCardToListItem(MdlCcHeader c) {
    return DynamicListItem(
      id: c.id.isNotEmpty ? c.id : c.multiVno.toString(),
      title: c.millName.isNotEmpty ? c.millName : 'Unknown Mill',
      subtitle: c.greyQuality,
      indexNumber: c.displayCcCode,
      amount: c.formattedCostPerPc,
      topTrailing: c.formattedCutDate,
      topLeading: c.isPending
          ? const shad.OutlineBadge(child: Text('Pending'))
          : const shad.PrimaryBadge(child: Text('Completed')),
    );
  }

  List<DyGridItem> _buildMappedGridItems() {
    return _cards.map((c) => _mapCardToGridItem(c)).toList();
  }

  DyGridItem _mapCardToGridItem(MdlCcHeader c) {
    return DyGridItem(
      id: c.id.isNotEmpty ? c.id : c.multiVno.toString(),
      title: c.millName.isNotEmpty ? c.millName : 'Unknown Mill',
      voucherNo: c.displayCcCode,
      partyName: c.millName.isNotEmpty ? c.millName : 'Unknown Mill',
      designPattern: c.greyQuality,
      quantity: c.totalFreshPcs > 0 ? '${c.totalFreshPcs} Pcs (${c.formattedReceivedMeters})' : '-',
      amount: c.formattedTotalInvestment,
      thumbnailUrl: c.cardPicPath,
      statusBadge: c.isPending
          ? const shad.OutlineBadge(child: Text('PENDING'))
          : const shad.PrimaryBadge(child: Text('COMPLETED')),
    );
  }

  Map<String, String> _buildSummaryTotals() {
    int totalFreshPcs = 0;
    double totalMts = 0;
    double totalInvestment = 0;
    for (final c in _cards) {
      totalFreshPcs += c.totalFreshPcs;
      totalMts += c.totalReceivedMeters;
      totalInvestment += c.totalInvestment;
    }
    return {
      'freshPct': 'TOTALS',
      'totalPcs': '$totalFreshPcs Pcs',
      'cutLength': '${totalMts.toStringAsFixed(1)} Mtr',
      'amount': '₹${totalInvestment.toStringAsFixed(2)}',
    };
  }

  List<DyTableRowData> _buildMappedTableRows() {
    if (_groupingMode == 'none') {
      return _cards.map((c) => c.toDyDefRowData()).toList();
    }

    final Map<String, List<MdlCcHeader>> groupedMap = {};
    for (final card in _cards) {
      final groupKey = _groupingMode == 'mill'
          ? (card.millName.isNotEmpty ? card.millName : 'Unknown Mill')
          : (card.greyQuality.isNotEmpty ? card.greyQuality : 'N/A');
      groupedMap.putIfAbsent(groupKey, () => []).add(card);
    }

    final result = <DyTableRowData>[];
    groupedMap.forEach((groupName, groupCards) {
      final childDefRows = groupCards.map((c) => c.toDyDefRowData()).toList();
      final totalFreshPcs = groupCards.fold<int>(0, (sum, c) => sum + c.totalFreshPcs);
      final totalInvestment = groupCards.fold<double>(0, (sum, c) => sum + c.totalInvestment);

      result.add(
        DyTableRowData(
          id: 'group_$groupName',
          rowType: DyTableRowType.group,
          partyName: groupName,
          title: '$groupName (${groupCards.length} Cards)',
          data: {
            'vno': '$groupName (${groupCards.length} Cards)',
            'partyName': groupName,
            'totalPcs': '$totalFreshPcs Pcs',
            'amount': '₹${totalInvestment.toStringAsFixed(2)}',
          },
          children: childDefRows,
        ),
      );
    });

    return result;
  }
}
