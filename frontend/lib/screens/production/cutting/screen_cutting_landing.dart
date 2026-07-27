import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../dynamic_ai/components/page_level/page_header.dart';
import '../../../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';
import '../../../models/production/model_cutting.dart';
import '../../../services/production/service_cutting.dart';
import 'widgets/cutting_metric_cards.dart';

class ScreenCuttingLanding extends StatefulWidget {
  const ScreenCuttingLanding({super.key});

  @override
  State<ScreenCuttingLanding> createState() => _ScreenCuttingLandingState();
}

class _ScreenCuttingLandingState extends State<ScreenCuttingLanding> {
  final CuttingService _service = CuttingService();

  // Navigation & View State
  int _contextTabIndex = 1; // Default selected: Details (1)
  String _selectedViewMode = 'table';
  String? _searchQuery;
  int _currentPage = 1;

  // Data Loading State
  List<CuttingBatchSummaryModel> _batches = [];
  int _totalCount = 0;
  CuttingMetricsModel _metrics = const CuttingMetricsModel();
  bool _isLoadingBatches = true;
  bool _isLoadingMetrics = true;

  // Filter State
  Set<String> _selectedMills = {};
  Set<String> _selectedQualities = {};
  Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  List<String> _millOptions = [];
  List<String> _qualityOptions = [];

  Set<String> _selectedBatchIds = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _loadMetrics();
    _loadFilterOptions();
    _fetchBatches();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoadingMetrics = true);
    final metrics = await _service.getCuttingMetrics();
    if (!mounted) return;
    setState(() {
      _metrics = metrics;
      _isLoadingMetrics = false;
    });
  }

  Future<void> _loadFilterOptions() async {
    final mills = await _service.getUniqueMills();
    final qualities = await _service.getUniqueQualities();
    if (!mounted) return;
    setState(() {
      _millOptions = mills;
      _qualityOptions = qualities;
    });
  }

  // Sort State
  String _activeSortKey = 'ccno';
  bool _isSortAscending = false;

  void _onSortChanged(String sortKey, bool isAscending) {
    setState(() {
      _activeSortKey = sortKey;
      _isSortAscending = isAscending;
    });
    _fetchBatches();
  }

  Future<void> _fetchBatches() async {
    setState(() => _isLoadingBatches = true);

    String? filterMill = _selectedMills.isNotEmpty ? _selectedMills.first : null;
    String? filterFabric = _selectedQualities.isNotEmpty ? _selectedQualities.first : null;
    DateTime? startDate;
    DateTime? endDate;

    if (_selectedDateRange is shad.RangeCalendarValue) {
      final range = _selectedDateRange as shad.RangeCalendarValue;
      startDate = range.start;
      endDate = range.end;
    } else if (_selectedDateRange is shad.SingleCalendarValue) {
      final single = _selectedDateRange as shad.SingleCalendarValue;
      startDate = single.date;
      endDate = single.date;
    }

    String sortBy;
    switch (_activeSortKey) {
      case 'ccno':
        sortBy = _isSortAscending ? 'CC_ASC' : 'CC_DESC';
        break;
      case 'cutdate':
        sortBy = _isSortAscending ? 'DATE_ASC' : 'DATE_DESC';
        break;
      case 'freshpcs':
        sortBy = _isSortAscending ? 'PCS_ASC' : 'PCS_DESC';
        break;
      case 'costperpc':
        sortBy = _isSortAscending ? 'COST_ASC' : 'COST_DESC';
        break;
      case 'freshpct':
        sortBy = _isSortAscending ? 'PCT_ASC' : 'PCT_DESC';
        break;
      default:
        sortBy = 'CC_DESC';
    }

    final res = await _service.getCuttingBatches(
      offset: (_currentPage - 1) * 50,
      limit: 50,
      searchQuery: _searchQuery,
      filterMill: filterMill,
      filterFabric: filterFabric,
      startDate: startDate,
      endDate: endDate,
      sortBy: sortBy,
    );

    if (!mounted) return;
    setState(() {
      _batches = res.data;
      _totalCount = res.totalCount;
      _isLoadingBatches = false;
    });
  }

  void _onResetFilters() {
    setState(() {
      _currentPage = 1;
      _searchQuery = null;
      _selectedMills.clear();
      _selectedQualities.clear();
      _selectedStatuses.clear();
      _selectedDateRange = null;
      _selectedBatchIds.clear();
      _activeSortKey = 'ccno';
      _isSortAscending = false;
    });
    _fetchBatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. PAGE HEADER (First Row)
        PageHeader<void>(
          title: 'Cutting Process',
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
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('New Batch'),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapMd),

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
                // Dashboard Tab (Metric Cards Row)
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      CuttingMetricCards(
                        metrics: _metrics,
                        isLoading: _isLoadingMetrics,
                      ),
                    ],
                  ),
                );
              case 1:
                // Details Tab (Dynamic Action Bar + Cutting Dense Table)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DynamicActionBar(
                      entityName: 'Batches',
                      selectedView: _selectedViewMode,
                      onViewChanged: (mode) => setState(() => _selectedViewMode = mode),
                      searchQuery: _searchQuery,
                      onSearchChanged: (val) {
                        setState(() => _searchQuery = val);
                        _fetchBatches();
                      },
                      selectedMills: _selectedMills,
                      millOptions: _millOptions,
                      onMillChanged: (mills) {
                        setState(() => _selectedMills = mills);
                        _fetchBatches();
                      },
                      selectedQualities: _selectedQualities,
                      qualityOptions: _qualityOptions,
                      onQualityChanged: (qualities) {
                        setState(() => _selectedQualities = qualities);
                        _fetchBatches();
                      },
                      selectedStatuses: _selectedStatuses,
                      onStatusChanged: (statuses) {
                        setState(() => _selectedStatuses = statuses);
                        _fetchBatches();
                      },
                      selectedDateRange: _selectedDateRange,
                      onDateRangeSelected: (range) {
                        setState(() => _selectedDateRange = range);
                        _fetchBatches();
                      },
                      onClearAllFilters: _onResetFilters,
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Expanded(
                      child: _buildCuttingTable(theme),
                    ),
                  ],
                );
              case 2:
                // Tasks Tab (Placeholder)
                return Center(
                  child: Text(
                    'Cutting Tasks (Empty Placeholder)',
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

  Widget _buildCuttingTable(shad.ThemeData theme) {
    final columns = [
      DynamicTableColumnSpec(label: 'CC NO', key: 'ccno', isSortable: true, width: 95 * theme.scaling),
      DynamicTableColumnSpec(label: 'DATE', key: 'cutdate', isSortable: true, width: 80 * theme.scaling),
      const DynamicTableColumnSpec(label: 'MILL', key: 'mill', isSortable: true, flex: 3),
      const DynamicTableColumnSpec(label: 'QUALITY', key: 'quality', isSortable: true, flex: 3),
      DynamicTableColumnSpec(label: 'CUT', key: 'cutlength', isSortable: true, width: 75 * theme.scaling),
      DynamicTableColumnSpec(label: 'FRESH PCS', key: 'freshpcs', isSortable: true, width: 90 * theme.scaling),
      DynamicTableColumnSpec(label: 'COST/PC', key: 'costperpc', isSortable: true, width: 95 * theme.scaling),
      DynamicTableColumnSpec(label: 'FRESH%', key: 'freshpct', isSortable: true, width: 85 * theme.scaling),
      DynamicTableColumnSpec(label: '', key: 'actions', isSortable: false, width: 80 * theme.scaling, alignment: Alignment.centerRight),
    ];

    final rows = _batches.map((b) {
      final formattedDate = DateFormat('dd MMM').format(b.cutDate);
      final costStr = b.costPerPc != null && b.costPerPc! > 0
          ? '₹${b.costPerPc!.toStringAsFixed(2)}'
          : '₹240.50';
      final costNum = b.costPerPc ?? 240.50;
      final freshPctStr = '${b.calculatedFreshPct.toStringAsFixed(1)}%';

      return DynamicTableRowData(
        id: b.id,
        voucherNo: b.multiVno.toString(),
        partyName: b.mill,
        designPattern: b.greyQual,
        quantity: '${b.totalFreshPcs}',
        amount: costStr,
        amountValue: costNum,
        status: b.sbStatus.isNotEmpty ? b.sbStatus : 'COMPLETED',
        thumbnailUrl: b.sbCardPic ?? (b.cardPics.isNotEmpty ? b.cardPics.first : null),
        imageUrls: b.cardPics,
        rawData: {
          'ccno': b.multiVno.toString(),
          'cutdate': formattedDate,
          'mill': b.mill,
          'quality': b.greyQual,
          'cutlength': b.cutLength.toStringAsFixed(2),
          'freshpcs': '${b.totalFreshPcs}',
          'freshpcs_num': b.totalFreshPcs,
          'costperpc': costStr,
          'costperpc_num': costNum,
          'freshpct': freshPctStr,
          'freshpct_num': b.calculatedFreshPct,
        },
      );
    }).toList();

    return DynamicDenseTable(
      columns: columns,
      rows: rows,
      isLoading: _isLoadingBatches,
      totalRecords: _totalCount,
      currentPage: _currentPage,
      onPageChanged: (page) {
        setState(() => _currentPage = page);
        _fetchBatches();
      },
      selectedRowIds: _selectedBatchIds,
      enableExpansion: false,
      initialSortKey: _activeSortKey,
      initialSortAscending: _isSortAscending,
      onSortChanged: _onSortChanged,
      onSelectionChanged: (selected) {
        setState(() => _selectedBatchIds = selected);
      },
    );
  }
}
