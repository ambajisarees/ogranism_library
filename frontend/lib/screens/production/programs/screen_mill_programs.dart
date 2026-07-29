import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../dynamic_ai/components/page_level/page_header.dart';
import '../../../dynamic_ai/components/page_level/report_card.dart';
import '../../../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';
import '../../../models/production/programs/model_mill_program.dart';
import '../../../services/production/service_programs.dart';

/// [ScreenMillPrograms] — Mill Programs & Pending Fabric Stock Management Screen.
/// Schema: `IMMBE2627` (Reads `sq_PINVTRN` sent stock vs `sq_MILLREC` received stock).
class ScreenMillPrograms extends StatefulWidget {
  const ScreenMillPrograms({super.key});

  @override
  State<ScreenMillPrograms> createState() => _ScreenMillProgramsState();
}

class _ScreenMillProgramsState extends State<ScreenMillPrograms> {
  final ProgramsService _programsService = ProgramsService();
  final NumberFormat _currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

  int _contextTabIndex = 0; // 0: Dashboard, 1: Details, 2: Tasks
  int _selectedReportCardIndex = 0; // 0: Mill Pending (Selected by default)
  String _selectedViewMode = 'table';
  String? _searchQuery;

  // Filter states
  Set<String> _selectedMills = {};
  Set<String> _selectedQualities = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;

  // Data states
  List<MillPendingBalanceModel> _items = [];
  bool _isLoading = true;

  final List<String> _millOptions = [
    'Ambaji Processing Mill',
    'Shree Ram Dyeing Mill',
    'Laxmi Textile Processors',
    'Surat Central Digital Mill',
    'Vardhman Silk Mills',
  ];

  final List<String> _qualityOptions = [
    'Royal Silk Grey 60x60',
    'Chiffon Jacquard Weave',
    'Organza Satin Border 50x50',
    'Georgette Foil Base 44"',
    'Heavy Jacquard Dola Silk',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final filterMill = _selectedMills.isNotEmpty ? _selectedMills.first : null;
    final res = await _programsService.getMillPendingBalances(
      searchQuery: _searchQuery,
      filterMill: filterMill,
    );
    if (!mounted) return;
    setState(() {
      _items = res;
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. TOP PAGE HEADER ────────────────────────────────────────────────
        PageHeader<void>(
          title: 'Mill Programs',
          actions: [
            shad.OutlineButton(
              onPressed: () {
                shad.showToast(
                  context: context,
                  builder: (context, show) => const shad.Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Exporting Mill Programs report...'),
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
                  builder: (context, show) => const shad.Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Add Program flow opening...'),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('Add Program'),
                ],
              ),
            ),
          ],
        ),

        const shad.DensityGap(shad.gapMd),

        // ── 2. CONTEXT TABS (Dashboard, Details, Tasks) ───────────────────────
        Row(
          children: [
            shad.Tabs(
              index: _contextTabIndex,
              onChanged: (int val) => setState(() => _contextTabIndex = val),
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
            const Spacer(),
          ],
        ),

        const shad.DensityGap(shad.gapSm),

        // ── 3. MAIN TAB CONTENT ───────────────────────────────────────────────
        Expanded(
          child: IndexedStack(
            index: _contextTabIndex,
            children: [
              _buildDashboardTab(theme, colors),
              _buildDetailsTab(theme, colors),
              _buildTasksTab(theme, colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab(shad.ThemeData theme, shad.ColorScheme colors) {
    final totalPendingMtrs = _items.fold(0.0, (sum, i) => sum + i.pendingMtrs);

    // Map un-grouped pending lot cards to DynamicTableRowData
    final List<DynamicTableRowData> rows = _items.map((i) {
      return DynamicTableRowData(
        id: i.cardNo.toString(),
        voucherNo: i.lastCutDateStr,
        partyName: i.millName,
        designPattern: i.greyQuality,
        quantity: '${i.pendingMtrs.toInt()} Mtr',
        amount: _currencyFmt.format(i.totalPendingValue),
        amountValue: i.totalPendingValue,
        status: i.isCarriedForward ? 'CF' : 'Active',
        rawData: i.toJson(),
      );
    }).toList();

    final uniqueMillsCount = _items.map((i) => i.millName).toSet().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── ROW 1: 4 REPORT CARDS GRID ────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: ReportCard(
                icon: shad.LucideIcons.factory,
                title: 'Mill Pending',
                subtitle: '$uniqueMillsCount Active Mills',
                primaryMetric: '${totalPendingMtrs.toInt()} Mtr',
                secondaryChipText: '${_items.length} Cards',
                isSelected: _selectedReportCardIndex == 0,
                onTap: () => setState(() => _selectedReportCardIndex = 0),
              ),
            ),
            SizedBox(width: 12 * theme.scaling),
            Expanded(
              child: ReportCard(
                icon: shad.LucideIcons.truck,
                title: 'In Transit',
                subtitle: 'Dispatched to Mill',
                primaryMetric: '14,250 Mtr',
                secondaryChipText: '8 Lots',
                isSelected: _selectedReportCardIndex == 1,
                onTap: () => setState(() => _selectedReportCardIndex = 1),
              ),
            ),
            SizedBox(width: 12 * theme.scaling),
            Expanded(
              child: ReportCard(
                icon: shad.LucideIcons.percent,
                title: 'Processing Shortage',
                subtitle: 'Avg Mill Shrinkage',
                primaryMetric: '3.42%',
                secondaryChipText: 'Normal Range',
                isSelected: _selectedReportCardIndex == 2,
                onTap: () => setState(() => _selectedReportCardIndex = 2),
              ),
            ),
            SizedBox(width: 12 * theme.scaling),
            Expanded(
              child: ReportCard(
                icon: shad.LucideIcons.scissors,
                title: 'Ready for Cutting',
                subtitle: 'Uncut Received Cards',
                primaryMetric: '530 Cards',
                secondaryChipText: 'High Priority',
                isSelected: _selectedReportCardIndex == 3,
                onTap: () => setState(() => _selectedReportCardIndex = 3),
              ),
            ),
          ],
        ),

        const shad.DensityGap(shad.gapSm),

        // ── ROW 2: TABULAR DYNAMIC ACTION BAR (DAB) ───────────────────────────
        DynamicActionBar(
          entityName: 'Programs',
          selectedView: _selectedViewMode,
          onViewChanged: (mode) => setState(() => _selectedViewMode = mode),
          onSearchChanged: _onSearch,
          millOptions: _millOptions,
          selectedMills: _selectedMills,
          onMillChanged: (mills) {
            setState(() => _selectedMills = mills);
            _fetchData();
          },
          qualityOptions: _qualityOptions,
          selectedQualities: _selectedQualities,
          onQualityChanged: (qualities) {
            setState(() => _selectedQualities = qualities);
            _fetchData();
          },
          selectedDateRange: _selectedDateRange,
          selectedDateLabel: _selectedDateLabel,
          onDateRangeSelected: (range) {
            setState(() {
              _selectedDateRange = range;
            });
            _fetchData();
          },
          onClearAllFilters: () {
            setState(() {
              _selectedMills = {};
              _selectedQualities = {};
              _selectedDateRange = null;
              _selectedDateLabel = null;
              _searchQuery = null;
            });
            _fetchData();
          },
        ),

        const shad.DensityGap(shad.gapSm),

        // ── ROW 3: PENDING FABRIC STOCK TABLE ──────────────────────────────────
        Expanded(
          child: DynamicDenseTable(
            columns: const [
              DynamicTableColumnSpec(label: 'CARD NO', key: 'id', flex: 2),
              DynamicTableColumnSpec(label: 'MILL NAME', key: 'partyName', flex: 3),
              DynamicTableColumnSpec(label: 'GREY QUALITY', key: 'designPattern', flex: 3),
              DynamicTableColumnSpec(label: 'PENDING MTRS', key: 'quantity', flex: 2),
              DynamicTableColumnSpec(label: 'PENDING VALUE', key: 'amount', flex: 3),
              DynamicTableColumnSpec(label: 'STATUS', key: 'status', flex: 2),
              DynamicTableColumnSpec(label: 'DISPATCH DATE', key: 'voucherNo', flex: 2),
            ],
            rows: rows,
            isLoading: _isLoading,
            totalRecords: rows.length,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(shad.ThemeData theme, shad.ColorScheme colors) {
    return Center(
      child: Text(
        'Mill Programs Details (Under Construction)',
        style: theme.typography.h3.copyWith(color: colors.mutedForeground),
      ),
    );
  }

  Widget _buildTasksTab(shad.ThemeData theme, shad.ColorScheme colors) {
    return Center(
      child: Text(
        'Mill Programs Tasks (Under Construction)',
        style: theme.typography.h3.copyWith(color: colors.mutedForeground),
      ),
    );
  }
}
