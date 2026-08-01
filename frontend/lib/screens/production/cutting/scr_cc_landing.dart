/*
================================================================================
LLM CONTEXT & QUERY SPACE — CUTTING CARDS LANDING SCREEN (scr_cc_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing container screen for Multi-Cutting Cards (`cc`).
   - Standard 1-to-1 alignment with `ScrPoLanding` and legacy Cutting Cards DAB implementation.
   - Supports dual view modes: Full Dense Table View (`table`) and Master-Detail Split View (`split`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Consumes module-level service `SrvCc` and module model `MdlCcHeader`.
   - Core models `SbCutdetSummaryModel` and `SbCutdetModel` remain 100% untouched and immutable.
   - Standard `PageHeader` + `DynamicActionBar` (DAB) architecture with `submoduleWidget` popover overlay.
   - Context-specific DAB filters: Mill Filter (`selectedMills`), Fabric Quality Filter (`selectedQualities`),
     Status Filter (`selectedStatuses`), and Date Range Filter (`selectedDateRange`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - All 311 summary records loaded live from Supabase `IMMBE2627.sb_cutdet_summary`.
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/page/dy_action_bar.dart';
import '../../../dynamic_ai/page/dy_table_pane.dart';
import '../../../dynamic_ai/page/dy_list_pane.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../models/production/mdl_cc.dart';
import '../../../services/production/srv_cc.dart';
import 'scr_cc_detail_canvas.dart';
import 'scr_cc_form_dialog.dart';

/// [ScrCcLanding] — Main Landing Container Screen for Multi-Cutting Cards.
class ScrCcLanding extends StatefulWidget {
  const ScrCcLanding({super.key});

  @override
  State<ScrCcLanding> createState() => _ScrCcLandingState();
}

class _ScrCcLandingState extends State<ScrCcLanding> {
  final SrvCc _ccService = SrvCc();
  final TextEditingController _searchController = TextEditingController();

  String _viewMode = 'table'; // 'table' or 'split'
  String? _searchQuery;

  // Filter States (Cutting Card Context Specific Filters)
  Set<String> _selectedMills = {};
  List<String> _millOptions = [];
  Set<String> _selectedQualities = {};
  List<String> _qualityOptions = [];
  Set<String> _selectedStatuses = {};
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
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final hasFilters = _selectedMills.isNotEmpty ||
        _selectedQualities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedDateRange != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Page Header with Title and Action Buttons
        PageHeader(
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
                  Icon(shad.LucideIcons.printer),
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
                  Icon(shad.LucideIcons.download),
                  shad.DensityGap(shad.gapSm),
                  Text('Export'),
                ],
              ),
            ),
            shad.PrimaryButton(
              onPressed: () => ScrCcFormDialog.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('Add'),
                ],
              ),
            ),
          ],
        ),

        const shad.DensityGap(shad.gapSm),

        // 2. Dynamic Action Bar (DAB) with Context Filters
        DynamicActionBar(
          entityName: 'Cards',
          selectedView: _viewMode,
          onViewChanged: (mode) {
            setState(() {
              _viewMode = mode;
            });
          },
          searchQuery: _searchQuery,
          onSearchChanged: (val) {
            _searchQuery = val.trim();
            _fetchCards(resetOffset: true);
          },
          // Context Specific DAB Filters for Cutting Cards (Mill, Quality, Status, Date)
          selectedMills: _selectedMills,
          millOptions: _millOptions,
          onMillChanged: (mills) {
            setState(() {
              _selectedMills = mills;
            });
            _fetchCards(resetOffset: true);
          },
          selectedQualities: _selectedQualities,
          qualityOptions: _qualityOptions,
          onQualityChanged: (qualities) {
            setState(() {
              _selectedQualities = qualities;
            });
            _fetchCards(resetOffset: true);
          },
          selectedStatuses: _selectedStatuses,
          onStatusChanged: (statuses) {
            setState(() {
              _selectedStatuses = statuses;
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
        ),

        const SizedBox(height: 12),

        // 3. Main Content Area (Tabular vs Split View)
        Expanded(
          child: _isLoading
              ? const Center(child: shad.CircularProgressIndicator())
              : _cards.isEmpty
                  ? Center(
                      child: Text(
                        'No cutting card records found',
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

  static const List<DynamicTableColumnSpec> _ccTableColumns = [
    DynamicTableColumnSpec(label: 'CC CODE', key: 'vno', width: 110),
    DynamicTableColumnSpec(label: 'DATE', key: 'date', width: 95),
    DynamicTableColumnSpec(label: 'MILL / PROCESSOR', key: 'party', flex: 2),
    DynamicTableColumnSpec(label: 'GREY FABRIC QUALITY', key: 'fabric', flex: 2),
    DynamicTableColumnSpec(label: 'CUT LENGTH', key: 'cutLength', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'FRESH PCS', key: 'totalPcs', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'FRESH %', key: 'freshPct', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'COST / PC', key: 'rate', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: 'INVESTMENT', key: 'amount', alignment: Alignment.centerRight, flex: 1),
    DynamicTableColumnSpec(label: '', key: 'actions', width: 72, alignment: Alignment.center),
  ];

  List<DynamicTableRowData> _mapCardsToRows() {
    return _cards.map((c) {
      return DynamicTableRowData(
        id: c.id,
        voucherNo: c.displayCcCode,
        partyName: c.millName,
        designPattern: c.greyQuality,
        quantity: c.formattedCutLength,
        amount: c.formattedTotalInvestment,
        amountValue: c.totalInvestment,
        status: c.isPending ? 'PENDING' : 'COMPLETED',
        childRows: c.lineItems.map((item) {
          return DynamicTableRowData(
            id: item.vno.toString(),
            voucherNo: item.vno.toString(),
            partyName: '',
            designPattern: item.quality.isNotEmpty ? item.quality : 'N/A',
            quantity: item.meters > 0 ? '${item.meters.toStringAsFixed(1)} Mtr' : '-',
            amount: item.formattedAmount(),
            amountValue: item.amount,
            status: '',
            rawData: {
              'pcs': item.pieces > 0 ? '${item.pieces.toInt()}' : '-',
              'rate': item.rate > 0 ? '₹${item.rate.toStringAsFixed(2)}' : '-',
            },
          );
        }).toList(),
        rawData: {
          'date': c.formattedCutDate,
          'totalPcs': c.totalFreshPcs > 0 ? '${c.totalFreshPcs} Pcs' : '-',
          'freshPct': c.formattedFreshYield,
          'rate': c.formattedCostPerPc,
        },
      );
    }).toList();
  }

  /// Full-Page Dense Data Table Grid
  Widget _buildTabularView() {
    return DynamicDenseTable(
      rows: _mapCardsToRows(),
      columns: _ccTableColumns,
      enableExpansion: true,
      totalRecords: _totalCount,
      currentPage: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchCards(resetOffset: false);
      },
      onRowTap: (row) {
        final card = _cards.firstWhere((c) => c.id == row.id, orElse: () => _cards.first);
        setState(() {
          _selectedCard = card;
          _viewMode = 'split';
        });
      },
    );
  }

  /// Master-Detail Split Pane View matching PO Module standard
  Widget _buildSplitView() {
    final listItems = _cards
        .map(
          (c) => DynamicListItem(
            id: c.id,
            title: c.millName.isNotEmpty ? c.millName : 'Unknown Mill',
            subtitle: '${c.displayCcCode} • ${c.greyQuality}',
            topLeading: c.isPending
                ? const shad.OutlineBadge(child: Text('Pending'))
                : const shad.PrimaryBadge(child: Text('Completed')),
            topTrailing: c.formattedCutDate,
            amount: c.formattedCostPerPc,
            indexNumber: c.displayCcCode,
            rawData: c.core.toJson(),
          ),
        )
        .toList();

    final selectedListItem = _selectedCard != null
        ? listItems.firstWhere((item) => item.id == _selectedCard!.id, orElse: () => listItems.first)
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
            final card = _cards.firstWhere((c) => c.id == item.id, orElse: () => _cards.first);
            setState(() {
              _selectedCard = card;
            });
          },
        ),

        const SizedBox(width: 16),

        // Right Detail Canvas
        Expanded(
          child: _selectedCard != null
              ? ScrCcDetailCanvas(
                  card: _selectedCard!,
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
