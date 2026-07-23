import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../dynamic_ai/components/page_level/page_header.dart';
import '../../../models/production/model_cutting.dart';
import '../../../services/production/service_cutting.dart';
import 'widgets/cutting_metric_cards.dart';
import 'widgets/cutting_filter_bar.dart';
import 'widgets/cutting_side_panel.dart';

class ScreenCuttingLanding extends StatefulWidget {
  const ScreenCuttingLanding({super.key});

  @override
  State<ScreenCuttingLanding> createState() => _ScreenCuttingLandingState();
}

class _ScreenCuttingLandingState extends State<ScreenCuttingLanding> {
  final CuttingService _service = CuttingService();
  final TextEditingController _searchController = TextEditingController();

  // State
  List<CuttingBatchSummaryModel> _batches = [];
  CuttingMetricsModel _metrics = const CuttingMetricsModel();
  CuttingBatchSummaryModel? _selectedBatch;
  final Set<String> _selectedBatchIds = {};

  bool _isLoadingBatches = true;
  bool _isLoadingMetrics = true;
  int _totalCount = 0;
  int _offset = 0;
  final int _limit = 50;

  // Filters & Sorting
  String _selectedMill = 'All';
  String _selectedFabric = 'All';
  List<String> _millOptions = [];
  List<String> _fabricOptions = [];
  DateTime? _startDate;
  DateTime? _endDate;
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
    final fabrics = await _service.getUniqueQualities();
    if (!mounted) return;
    setState(() {
      _millOptions = mills;
      _fabricOptions = fabrics;
    });
  }

  Future<void> _fetchBatches({bool resetOffset = true}) async {
    if (resetOffset) {
      _offset = 0;
    }
    setState(() => _isLoadingBatches = true);

    final res = await _service.getCuttingBatches(
      offset: _offset,
      limit: _limit,
      searchQuery: _searchController.text.trim(),
      filterMill: _selectedMill,
      filterFabric: _selectedFabric,
      startDate: _startDate,
      endDate: _endDate,
      sortBy: _currentSort,
    );

    if (!mounted) return;
    setState(() {
      _batches = res.data;
      _totalCount = res.totalCount;
      _isLoadingBatches = false;
      if (_batches.isNotEmpty && (_selectedBatch == null || !_batches.contains(_selectedBatch))) {
        _selectedBatch = _batches.first;
      }
    });
  }

  void _onSearchChanged(String query) {
    _fetchBatches(resetOffset: true);
  }

  void _onResetFilters() {
    _searchController.clear();
    setState(() {
      _selectedMill = 'All';
      _selectedFabric = 'All';
      _startDate = null;
      _endDate = null;
      _currentSort = 'DATE_DESC';
      _selectedBatchIds.clear();
    });
    _fetchBatches(resetOffset: true);
  }

  void _toggleSort(String field) {
    String newSort;
    if (field == 'DATE') {
      newSort = _currentSort == 'DATE_DESC' ? 'DATE_ASC' : 'DATE_DESC';
    } else if (field == 'CC') {
      newSort = _currentSort == 'CC_DESC' ? 'CC_ASC' : 'CC_DESC';
    } else if (field == 'MILL') {
      newSort = _currentSort == 'MILL_ASC' ? 'MILL_DESC' : 'MILL_ASC';
    } else if (field == 'PCS') {
      newSort = _currentSort == 'PCS_DESC' ? 'PCS_ASC' : 'PCS_DESC';
    } else if (field == 'PCT') {
      newSort = _currentSort == 'PCT_DESC' ? 'PCT_ASC' : 'PCT_DESC';
    } else if (field == 'COST') {
      newSort = _currentSort == 'COST_DESC' ? 'COST_ASC' : 'COST_DESC';
    } else {
      newSort = 'DATE_DESC';
    }

    setState(() => _currentSort = newSort);
    _fetchBatches(resetOffset: false);
  }

  String _truncateMillName(String fullMillName) {
    final words = fullMillName.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) return fullMillName;
    return '${words[0]} ${words[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==========================================
        // 1. HEADER ROW (Title H2, Spacer, Export & Add Buttons)
        // ==========================================
        PageHeader(
          title: 'Cutting',
          actions: [
            shad.OutlineButton(
              onPressed: () {
                shad.showToast(
                  context: context,
                  builder: (context, show) => shad.Card(
                    child: Padding(
                      padding: EdgeInsets.all(
                        theme.density.baseContainerPadding * theme.scaling * shad.padSm,
                      ),
                      child: const Text('Print feature triggered.'),
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
                    child: Padding(
                      padding: EdgeInsets.all(
                        theme.density.baseContainerPadding * theme.scaling * shad.padSm,
                      ),
                      child: const Text('Export feature triggered.'),
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
              onPressed: () {
                shad.showToast(
                  context: context,
                  builder: (context, show) => shad.Card(
                    child: Padding(
                      padding: EdgeInsets.all(
                        theme.density.baseContainerPadding * theme.scaling * shad.padSm,
                      ),
                      child: const Text('Add Cutting Card feature triggered.'),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('Add Cutting Card'),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapLg),

        // ==========================================
        // 2. METRIC ROW (4 Cards Across Full Width)
        // ==========================================
        CuttingMetricCards(
          metrics: _metrics,
          isLoading: _isLoadingMetrics,
        ),
        const shad.DensityGap(shad.gapLg),

        // ==========================================
        // 3. CHILD ROW (2-Column: Left Column Table & Filter Bar; Right Column 360px Detail Card)
        // ==========================================
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1 (Left / Expanded): Filter Bar & Data Table
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter Bar anchored over table width
                    CuttingFilterBar(
                      searchController: _searchController,
                      onSearchChanged: _onSearchChanged,
                      selectedMill: _selectedMill,
                      selectedFabric: _selectedFabric,
                      millOptions: _millOptions,
                      fabricOptions: _fabricOptions,
                      onMillChanged: (val) {
                        setState(() => _selectedMill = val);
                        _fetchBatches(resetOffset: true);
                      },
                      onFabricChanged: (val) {
                        setState(() => _selectedFabric = val);
                        _fetchBatches(resetOffset: true);
                      },
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateRangeChanged: (range) {
                        setState(() {
                          _startDate = range?.start;
                          _endDate = range?.end;
                        });
                        _fetchBatches(resetOffset: true);
                      },
                      onResetFilters: _onResetFilters,
                      totalRecords: _totalCount > 0 ? _totalCount : _batches.length,
                      displayedRecords: _batches.length,
                      selectedCount: _selectedBatchIds.length,
                    ),
                    const shad.DensityGap(shad.gapMd),

                    // Data Table
                    Expanded(
                      child: _buildTableView(context),
                    ),
                  ],
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // Column 2 (Right / Fixed 360px): Detail Side Card
              CuttingSidePanel(
                selectedBatch: _selectedBatch,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableView(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final padMd = theme.density.baseContainerPadding * theme.scaling * shad.padMd;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    if (_isLoadingBatches) {
      return shad.Card(
        borderColor: colors.border,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const shad.CircularProgressIndicator(),
              const shad.DensityGap(shad.gapMd),
              Text(
                'Loading Cutting Cards...',
                style: theme.typography.textMuted,
              ),
            ],
          ),
        ),
      );
    }

    if (_batches.isEmpty) {
      return shad.Card(
        borderColor: colors.border,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shad.LucideIcons.scissors, size: 36 * theme.scaling, color: colors.mutedForeground),
              const shad.DensityGap(shad.gapMd),
              Text(
                'No Cutting Batches Found',
                style: theme.typography.h3.copyWith(color: colors.mutedForeground),
              ),
              const shad.DensityGap(shad.gapSm),
              Text(
                'Try adjusting your search query or filter selection.',
                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
      );
    }

    final bool isAllSelected = _batches.isNotEmpty &&
        _batches.every((b) => _selectedBatchIds.contains(b.id));

    return shad.Card(
      borderColor: colors.border,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Table Header Row (With Checkbox & Clickable Sort Headers)
          Container(
            padding: EdgeInsets.symmetric(horizontal: padMd, vertical: padSm),
            decoration: BoxDecoration(
              color: colors.muted.withValues(alpha: 0.4),
              border: Border(
                bottom: BorderSide(color: colors.border),
              ),
            ),
            child: Row(
              children: [
                // Select All Checkbox
                SizedBox(
                  width: 32 * theme.scaling,
                  child: shad.Checkbox(
                    state: isAllSelected
                        ? shad.CheckboxState.checked
                        : _selectedBatchIds.isNotEmpty
                            ? shad.CheckboxState.indeterminate
                            : shad.CheckboxState.unchecked,
                    onChanged: (state) {
                      setState(() {
                        if (state == shad.CheckboxState.checked) {
                          _selectedBatchIds.addAll(_batches.map((b) => b.id));
                        } else {
                          _selectedBatchIds.clear();
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 8 * theme.scaling),

                // Columns
                _buildSortableHeaderCell(context, 'CC Code', 'CC', width: 95 * theme.scaling),
                _buildSortableHeaderCell(context, 'Date', 'DATE', width: 80 * theme.scaling),
                Expanded(flex: 3, child: _buildSortableHeaderCell(context, 'Mill Name', 'MILL')),
                Expanded(flex: 3, child: _buildHeaderCell(context, 'Grey Qual')),
                _buildHeaderCell(context, 'Cut Len', width: 75 * theme.scaling),
                _buildSortableHeaderCell(context, 'Fresh Pcs', 'PCS', width: 85 * theme.scaling),
                _buildSortableHeaderCell(context, 'Fresh %', 'PCT', width: 120 * theme.scaling),
                _buildSortableHeaderCell(context, 'Cost / Pc', 'COST', width: 95 * theme.scaling),
                _buildHeaderCell(context, 'Job Link', width: 85 * theme.scaling),
              ],
            ),
          ),

          // Table Data Rows
          Expanded(
            child: ListView.separated(
              itemCount: _batches.length,
              separatorBuilder: (context, index) => shad.Divider(
                height: 1,
                color: colors.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final item = _batches[index];
                final isSelectedRow = _selectedBatch?.id == item.id ||
                    (_selectedBatch != null && _selectedBatch!.multiVno == item.multiVno);
                final isChecked = _selectedBatchIds.contains(item.id);

                return InkWell(
                  onTap: () {
                    setState(() => _selectedBatch = item);
                  },
                  child: Container(
                    color: isSelectedRow
                        ? colors.accent.withValues(alpha: 0.3)
                        : Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: padMd, vertical: padSm),
                    child: Row(
                      children: [
                        // Checkbox
                        SizedBox(
                          width: 32 * theme.scaling,
                          child: shad.Checkbox(
                            state: isChecked
                                ? shad.CheckboxState.checked
                                : shad.CheckboxState.unchecked,
                            onChanged: (state) {
                              setState(() {
                                if (state == shad.CheckboxState.checked) {
                                  _selectedBatchIds.add(item.id);
                                } else {
                                  _selectedBatchIds.remove(item.id);
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8 * theme.scaling),

                        // 1. CC Code
                        SizedBox(
                          width: 95 * theme.scaling,
                          child: Text(
                            item.displayCode,
                            style: theme.typography.mono.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelectedRow ? colors.primary : colors.foreground,
                            ),
                          ),
                        ),
                        // 2. Date as "21 Jun"
                        SizedBox(
                          width: 80 * theme.scaling,
                          child: Text(
                            DateFormat('dd MMM').format(item.cutDate),
                            style: theme.typography.xSmall.copyWith(
                              color: colors.mutedForeground,
                            ),
                          ),
                        ),
                        // 3. Mill Name (Truncated to first 2 words)
                        Expanded(
                          flex: 3,
                          child: Text(
                            _truncateMillName(item.mill),
                            style: theme.typography.textSmall.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 4. Grey Qual (ellipsis)
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.greyQual,
                            style: theme.typography.textSmall.copyWith(
                              color: colors.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 5. Cut Length as Chip
                        SizedBox(
                          width: 75 * theme.scaling,
                          child: shad.OutlineBadge(
                            child: Text(
                              '${item.cutLength.toStringAsFixed(2)}m',
                              style: theme.typography.mono.copyWith(
                                fontSize: theme.typography.xSmall.fontSize,
                              ),
                            ),
                          ),
                        ),
                        // 6. Fresh Pcs (Mono font)
                        SizedBox(
                          width: 85 * theme.scaling,
                          child: Text(
                            '${item.totalFreshPcs}',
                            style: theme.typography.mono.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: theme.typography.textSmall.fontSize,
                            ),
                          ),
                        ),
                        // 7. Fresh % Indicator with Center Text Label
                        SizedBox(
                          width: 120 * theme.scaling,
                          child: _buildProgressBarWithCenterLabel(
                            context,
                            (item.calculatedFreshPct / 100.0).clamp(0.0, 1.0),
                            '${item.calculatedFreshPct.toStringAsFixed(1)}%',
                          ),
                        ),
                        // 8. Cost per pc (Mono font, up to 2 decimals)
                        SizedBox(
                          width: 95 * theme.scaling,
                          child: Text(
                            item.costPerPc != null && item.costPerPc! > 0
                                ? '₹${item.costPerPc!.toStringAsFixed(2)}'
                                : '₹0.00',
                            style: theme.typography.mono.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: theme.typography.xSmall.fontSize,
                              color: colors.foreground,
                            ),
                          ),
                        ),
                        // 9. Job Link
                        SizedBox(
                          width: 85 * theme.scaling,
                          child: item.jobCardVnos.isNotEmpty
                              ? shad.SecondaryBadge(
                                  child: Text(
                                    'Linked',
                                    style: theme.typography.xSmall,
                                  ),
                                )
                              : shad.OutlineBadge(
                                  child: Text(
                                    'Pending',
                                    style: theme.typography.xSmall,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeaderCell(
    BuildContext context,
    String title,
    String sortKey, {
    double? width,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final bool isSorted = _currentSort.startsWith(sortKey);
    final bool isAsc = _currentSort == '${sortKey}_ASC';

    final widget = InkWell(
      onTap: () => _toggleSort(sortKey),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title.toUpperCase(),
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isSorted ? colors.primary : colors.mutedForeground,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 2 * theme.scaling),
          Icon(
            isSorted
                ? (isAsc ? shad.LucideIcons.arrowUp : shad.LucideIcons.arrowDown)
                : shad.LucideIcons.arrowUpDown,
            size: 11 * theme.scaling,
            color: isSorted ? colors.primary : colors.mutedForeground.withValues(alpha: 0.5),
          ),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: widget);
    }
    return widget;
  }

  Widget _buildHeaderCell(BuildContext context, String title, {double? width}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final widget = Text(
      title.toUpperCase(),
      style: theme.typography.xSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: colors.mutedForeground,
        letterSpacing: 0.5,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: widget);
    }
    return widget;
  }

  Widget _buildProgressBarWithCenterLabel(BuildContext context, double progressValue, String label) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: theme.borderRadiusSm,
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: colors.muted,
            color: colors.primary,
            minHeight: 16 * theme.scaling,
          ),
        ),
        Text(
          label,
          style: theme.typography.mono.copyWith(
            fontSize: 10 * theme.scaling,
            fontWeight: FontWeight.bold,
            color: colors.primaryForeground,
          ),
        ),
      ],
    );
  }
}
