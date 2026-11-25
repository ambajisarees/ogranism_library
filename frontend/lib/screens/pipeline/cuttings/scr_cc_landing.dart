/*
================================================================================
LLM CONTEXT & QUERY SPACE — CUTTING CARDS LANDING SCREEN (scr_cc_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Live 3-file Linear Landing workstation for Multi-Cutting Cards (`cc`, index `6`)
     backed by `IMMBE2627.sb_cutdet_summary`, `sb_cutdet`, and `sbvw_uncut_millrec`.
   - Connects `DyLandingCanvas` (`9:3` gap-compensated Base-12 Bento grid) to live
     domain regions (`scr_cc_regions.dart`) and the curated 2-pane + summary-bar
     `ScrCcForm` (`scr_cc_form.dart` via `DyShlAdd`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Loads live `SrvCc().getCuttingCards(...)`, `getCuttingMetrics()`, Mill
     options, and Quality options on startup and filter changes.
   - `[N] + Add` and row `Edit` transitions mount `ScrCcForm` directly inside
     `DyLandingCanvas.addFlowBuilder` with header `Confirm` wired to `confirmSave()`.
   - Strictly checks `if (!mounted) return;` after every async Supabase call.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_MILLREC` and `sq_PINVTRN` are strictly read-only Airbyte mirrors; all
     creates/updates persist solely to `sb_cutdet_summary` and `sb_cutdet`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Phase 2 enhancement: direct scan image upload modal inside missing-scan tasks.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_action_bar.dart';
import '../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../models/pipeline/mdl_cc.dart';
import '../../../services/pipeline/srv_cc.dart';
import '../../../services/service_header_toast.dart';
import 'scr_cc_form.dart';
import 'scr_cc_regions.dart';

/// Live 3-file Linear Landing workspace for Multi-Cutting Cards (`cc`).
class ScrCcLanding extends StatefulWidget {
  const ScrCcLanding({super.key});

  @override
  State<ScrCcLanding> createState() => _ScrCcLandingState();
}

class _ScrCcLandingState extends State<ScrCcLanding> {
  final GlobalKey<DyLandingCanvasState> _canvasKey =
      GlobalKey<DyLandingCanvasState>();
  final GlobalKey<ScrCcFormState> _formKey = GlobalKey<ScrCcFormState>();
  final SrvCc _ccService = SrvCc();

  int? _zoomedRegion;
  bool _isFormSaving = false;
  MdlCcHeader? _editingHeader;

  // Metrics state
  DabTimeHorizon _horizon = DabTimeHorizon.thisYear;
  int? _selectedKpiIdx;
  int _trendMode = 0;

  // Data state & server filters
  String _dataViewMode = 'table';
  String _dataGroup = 'none';
  String _dataSearch = '';
  Set<String> _selectedMills = {};
  List<String> _millOptions = [];
  Set<String> _selectedQualities = {};
  List<String> _qualityOptions = [];
  Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;
  String _sortField = 'date';
  bool _sortAsc = false;

  // Fetched data
  List<MdlCcHeader> _cards = [];
  MdlCcHeader? _selectedCard;
  MdlCcMetrics _metrics = const MdlCcMetrics();
  bool _isLoading = true;
  int _totalCount = 0;
  int _offset = 0;
  static const int _limit = 50;

  // Tasks & Reports state
  int _taskQueueIdx = 0;
  String _taskSearch = '';
  final Set<String> _dismissedTaskIds = {};
  int _reportLensIdx = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadFilterOptions(),
      _loadMetrics(),
      _fetchCards(resetOffset: true),
    ]);
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

  Future<void> _loadMetrics() async {
    final metrics = await _ccService.getCuttingMetrics();
    if (!mounted) return;
    setState(() => _metrics = metrics);
  }

  Future<void> _fetchCards({bool resetOffset = false}) async {
    if (resetOffset && mounted) {
      setState(() => _offset = 0);
    }
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final statusFilter = _selectedStatuses.length == 1
        ? _selectedStatuses.first
        : 'All';
    final range = _selectedDateRange?.toRange();

    final result = await _ccService.getCuttingCards(
      limit: _limit,
      offset: _offset,
      searchQuery: _dataSearch,
      selectedMills: _selectedMills,
      selectedQualities: _selectedQualities,
      statusFilter: statusFilter,
      startDate: range?.start,
      endDate: range?.end,
    );

    if (!mounted) return;
    final sorted = _applyInMemorySort(result.data);
    setState(() {
      _cards = sorted;
      _totalCount = result.totalCount;
      _isLoading = false;
      if (_cards.isNotEmpty &&
          (_selectedCard == null ||
              !_cards.any((c) => c.multiVno == _selectedCard!.multiVno))) {
        _selectedCard = _cards.first;
      }
    });
  }

  List<MdlCcHeader> _applyInMemorySort(List<MdlCcHeader> items) {
    final list = List<MdlCcHeader>.from(items);
    list.sort((a, b) {
      final int cmp;
      switch (_sortField) {
        case 'mill':
        case 'party':
          cmp = a.millName.compareTo(b.millName);
        case 'amount':
          cmp = a.totalInvestment.compareTo(b.totalInvestment);
        case 'qty':
          cmp = a.totalFreshPcs.compareTo(b.totalFreshPcs);
        case 'vno':
          cmp = a.multiVno.compareTo(b.multiVno);
        case 'date':
        default:
          cmp = a.cutDate.compareTo(b.cutDate);
      }
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  bool get _hasDataFilters =>
      _selectedMills.isNotEmpty ||
      _selectedQualities.isNotEmpty ||
      _selectedStatuses.isNotEmpty ||
      _selectedDateRange != null;

  bool _handlePageActionKey(String keyChar) {
    switch (keyChar) {
      case 'P':
        ServiceHeaderToast.instance.show('Print queued for Cuttings [P]');
        return true;
      case 'X':
        ServiceHeaderToast.instance.show(
          'Export queued for Cuttings CSV [X]',
          tone: HeaderToastTone.success,
        );
        return true;
      default:
        return false;
    }
  }

  void _openAddBatch() {
    setState(() => _editingHeader = null);
    _canvasKey.currentState?.openAddFlow();
  }

  void _openEditBatch(MdlCcHeader card) {
    setState(() => _editingHeader = card);
    _canvasKey.currentState?.openAddFlow();
  }

  Widget _buildMetricsActionBar() {
    return DynamicActionBar(
      region: DabRegion.metrics,
      isExpanded: _zoomedRegion == 1,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(1),
      selectedHorizon: _horizon,
      onHorizonChanged: (h) {
        setState(() => _horizon = h);
        ServiceHeaderToast.instance.show('Metrics horizon: ${h.label}');
      },
    );
  }

  Widget _buildDataActionBar() {
    final expanded = _zoomedRegion == 2;
    return DynamicActionBar(
      region: DabRegion.data,
      entityName: 'Cards',
      isExpanded: expanded,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(2),
      selectedView: _dataViewMode,
      onViewChanged: (v) => setState(() => _dataViewMode = v),
      searchWidth: expanded ? 220 : 180,
      searchQuery: _dataSearch,
      onSearchChanged: (q) {
        setState(() => _dataSearch = q);
        _fetchCards(resetOffset: true);
      },
      showFilterButtons: expanded,
      millFilterLabel: 'Mill',
      millFilterIcon: shad.LucideIcons.factory,
      millOptions: _millOptions,
      selectedMills: _selectedMills,
      onMillChanged: (s) {
        setState(() => _selectedMills = s);
        _fetchCards(resetOffset: true);
      },
      fabricFilterLabel: 'Quality',
      fabricFilterIcon: shad.LucideIcons.shirt,
      fabricOptions: _qualityOptions,
      selectedFabrics: _selectedQualities,
      onFabricChanged: (s) {
        setState(() => _selectedQualities = s);
        _fetchCards(resetOffset: true);
      },
      statusOptions: ScrCcSpecs.statusOptions,
      selectedStatuses: _selectedStatuses,
      onStatusChanged: (s) {
        setState(() => _selectedStatuses = s);
        _fetchCards(resetOffset: true);
      },
      showDateFilter: expanded,
      selectedDateRange: _selectedDateRange,
      selectedDateLabel: _selectedDateLabel,
      onDateRangeSelected: (range) {
        setState(() {
          _selectedDateRange = range;
          _selectedDateLabel = range != null ? 'Custom' : null;
        });
        _fetchCards(resetOffset: true);
      },
      groupOptions: ScrCcSpecs.groupOptions,
      selectedGroup: expanded ? _dataGroup : 'none',
      onGroupChanged: expanded ? (g) => setState(() => _dataGroup = g) : null,
      selectedSortField: _sortField,
      isSortAscending: _sortAsc,
      onSortFieldChanged: expanded
          ? (f) {
              setState(() {
                _sortField = f;
                _cards = _applyInMemorySort(_cards);
              });
            }
          : null,
      onToggleSortDirection: expanded
          ? () {
              setState(() {
                _sortAsc = !_sortAsc;
                _cards = _applyInMemorySort(_cards);
              });
            }
          : null,
      hasActiveFilters: _hasDataFilters,
      onClearAllFilters: () {
        setState(() {
          _selectedMills = {};
          _selectedQualities = {};
          _selectedStatuses = {};
          _selectedDateRange = null;
          _selectedDateLabel = null;
          _dataSearch = '';
        });
        _fetchCards(resetOffset: true);
      },
    );
  }

  Widget _buildTasksActionBar() {
    final expanded = _zoomedRegion == 3;
    return DynamicActionBar(
      region: DabRegion.tasks,
      entityName: 'Tasks',
      isExpanded: expanded,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(3),
      taskQueueLabels: ScrCcSpecs.taskQueues,
      selectedTaskQueueIndex: _taskQueueIdx,
      onTaskQueueChanged: (i) => setState(() => _taskQueueIdx = i),
      showSearch: expanded,
      onSearchChanged: (q) => setState(() => _taskSearch = q),
    );
  }

  Widget _buildReportsActionBar() {
    return DynamicActionBar(
      region: DabRegion.reports,
      isExpanded: _zoomedRegion == 4,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(4),
      reportLensLabels: ScrCcSpecs.reportLenses,
      selectedReportLensIndex: _reportLensIdx,
      onReportLensChanged: (i) => setState(() => _reportLensIdx = i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = (_offset ~/ _limit) + 1;

    return DyLandingCanvas(
      key: _canvasKey,
      title: 'Cuttings',
      moduleName: 'Cutting Card',
      showDefaultHeaderActions: true,
      controlledZoomedRegion: _zoomedRegion,
      onZoomedRegionChanged: (reg) => setState(() => _zoomedRegion = reg),
      onPageActionKey: _handlePageActionKey,
      isSavingAdd: _isFormSaving,
      isLoading: _isLoading,
      onPrint: () => ServiceHeaderToast.instance.show(
        'Print queued for Cuttings [P]',
      ),
      onExport: () => ServiceHeaderToast.instance.show(
        'Exported ${_cards.length} Cutting Cards [X]',
        tone: HeaderToastTone.success,
      ),
      onAdd: _openAddBatch,
      onSaveDraftAdd: () => ServiceHeaderToast.instance.show(
        'Cutting Card batch draft kept locally.',
        tone: HeaderToastTone.warning,
      ),
      onConfirmAdd: () => _formKey.currentState?.confirmSave(),
      addFlowBuilder: (onBackToSnapshot) => ScrCcForm(
        key: _formKey,
        editingHeader: _editingHeader,
        showHeader: false,
        onSavingChanged: (saving) {
          if (mounted) setState(() => _isFormSaving = saving);
        },
        onBack: () {
          setState(() => _editingHeader = null);
          onBackToSnapshot();
        },
        onSave: () {
          setState(() => _editingHeader = null);
          onBackToSnapshot();
          _loadInitialData();
        },
      ),
      metricsActionBar: _buildMetricsActionBar(),
      metricsChild: ScrCcMetricsPane(
        horizon: _horizon,
        cards: _cards,
        metrics: _metrics,
        totalCount: _totalCount,
        selectedKpiIndex: _selectedKpiIdx,
        onKpiSelected: (i) => setState(
          () => _selectedKpiIdx = _selectedKpiIdx == i ? null : i,
        ),
        isExpanded: false,
        trendMode: _trendMode,
        onTrendModeChanged: (m) => setState(() => _trendMode = m),
      ),
      metricsExpandedChild: ScrCcMetricsPane(
        horizon: _horizon,
        cards: _cards,
        metrics: _metrics,
        totalCount: _totalCount,
        selectedKpiIndex: _selectedKpiIdx,
        onKpiSelected: (i) => setState(
          () => _selectedKpiIdx = _selectedKpiIdx == i ? null : i,
        ),
        isExpanded: true,
        trendMode: _trendMode,
        onTrendModeChanged: (m) => setState(() => _trendMode = m),
      ),
      dataActionBar: _buildDataActionBar(),
      dataChild: ScrCcDataPane(
        cards: _cards,
        isLoading: _isLoading,
        isExpanded: _zoomedRegion == 2,
        viewMode: _dataViewMode,
        groupingMode: _zoomedRegion == 2 ? _dataGroup : 'none',
        totalRecords: _totalCount,
        pageIndex: currentPage,
        pageSize: _limit,
        onPageChanged: (page) {
          setState(() => _offset = (page - 1) * _limit);
          _fetchCards();
        },
        selectedCard: _selectedCard,
        onSelectCard: (c) => setState(() => _selectedCard = c),
        onEditCard: _openEditBatch,
      ),
      tasksActionBar: _buildTasksActionBar(),
      tasksChild: ScrCcTasksPane(
        cards: _cards,
        queueIndex: _taskQueueIdx,
        searchQuery: _taskSearch,
        isExpanded: _zoomedRegion == 3,
        dismissedIds: _dismissedTaskIds,
        onDismissTask: (id) {
          setState(() => _dismissedTaskIds.add(id));
          ServiceHeaderToast.instance.show(
            'Task dismissed',
            tone: HeaderToastTone.success,
          );
        },
      ),
      reportsActionBar: _buildReportsActionBar(),
      reportsChild: ScrCcReportsPane(
        cards: _cards,
        lensIndex: _reportLensIdx,
        isExpanded: false,
        onItemTap: (item) {
          if (_reportLensIdx == 0) {
            setState(() => _selectedMills = {item.label});
            _fetchCards(resetOffset: true);
          } else if (_reportLensIdx == 1) {
            setState(() => _selectedQualities = {item.label});
            _fetchCards(resetOffset: true);
          }
          ServiceHeaderToast.instance.show('Filtered Cuttings: ${item.label}');
        },
      ),
      reportsExpandedChild: ScrCcReportsPane(
        cards: _cards,
        lensIndex: _reportLensIdx,
        isExpanded: true,
      ),
    );
  }
}
