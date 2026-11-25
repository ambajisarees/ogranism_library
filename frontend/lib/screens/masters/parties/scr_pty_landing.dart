/*
================================================================================
LLM CONTEXT & QUERY SPACE — PARTIES MASTER LANDING SCREEN (scr_pty_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Modular 4-Region Bento landing workspace for Commercial Parties
     (`IMMBE2627.sb_parties`, navigation index `1`).
   - Wires `DyLandingCanvas` (`9:3` gap-compensated Base-12 grid) directly to
     domain-modular `ScrPtyRegions` (`ScrPtyMetricsPane`, `ScrPtyDataPane`,
     `ScrPtyTasksPane`, `ScrPtyReportsPane`) and `ScrPtyForm` (`DyFormCanvas`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` controls, `36px` DAB toolbars with
     leading Expand (`Shift+1..4`), and `PageHeader` `Shift+P/X/N/Backspace`
     keyboard navigation.
   - Confirm in `[N]` Add Flow validates `ScrPtyFormState.validateForStage()`
     before returning cleanly to the landing canvas.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_parties` read/write bindings connect via `SrvPty` in Phase 2 backend pass.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Wire direct row edit (`ScrPtyForm` edit mode) & GSTIN portal Edge Function
     when `SrvPty` lands in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_action_bar.dart';
import '../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../services/service_header_toast.dart';
import 'scr_pty_form.dart';
import 'scr_pty_regions.dart';

/// Modular 3-file Landing workspace for Parties (`IMMBE2627.sb_parties`).
class ScrPtyLanding extends StatefulWidget {
  const ScrPtyLanding({super.key});

  @override
  State<ScrPtyLanding> createState() => _ScrPtyLandingState();
}

class _ScrPtyLandingState extends State<ScrPtyLanding> {
  final GlobalKey<DyLandingCanvasState> _canvasKey =
      GlobalKey<DyLandingCanvasState>();
  final GlobalKey<ScrPtyFormState> _formKey = GlobalKey<ScrPtyFormState>();

  int? _zoomedRegion;

  // Metrics state
  DabTimeHorizon _horizon = DabTimeHorizon.thisYear;
  int? _selectedKpiIdx;
  int _trendMode = 0;

  // Data state
  String _dataViewMode = 'table';
  String _dataGroup = 'none';
  String _dataSearch = '';
  Set<String> _selectedRoles = {};
  Set<String> _selectedCities = {};
  Set<String> _selectedGstTypes = {};
  Set<String> _selectedKycStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;
  String _sortField = 'name';
  bool _sortAsc = true;

  // Tasks & Reports state
  int _taskQueueIdx = 0;
  String _taskSearch = '';
  int _reportLensIdx = 0;

  bool get _hasDataFilters =>
      _selectedRoles.isNotEmpty ||
      _selectedCities.isNotEmpty ||
      _selectedGstTypes.isNotEmpty ||
      _selectedKycStatuses.isNotEmpty ||
      _selectedDateRange != null;

  bool _handlePageActionKey(String keyChar) {
    switch (keyChar) {
      case 'P':
        ServiceHeaderToast.instance.show('Print queued for Parties [P]');
        return true;
      case 'X':
        ServiceHeaderToast.instance.show(
          'Export queued for Parties [X]',
          tone: HeaderToastTone.success,
        );
        return true;
      default:
        return false;
    }
  }

  void _handleConfirmAdd() {
    final result = _formKey.currentState?.validateForStage();
    if (result != null && !result.ok) {
      ServiceHeaderToast.instance.show(
        result.message,
        tone: HeaderToastTone.warning,
      );
      return;
    }
    ServiceHeaderToast.instance.show(
      result?.message ?? 'Party staged for ${ScrPtySpecs.targetTable}.',
      tone: HeaderToastTone.info,
    );
    _canvasKey.currentState?.exitToSnapshot();
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
      entityName: 'Parties',
      isExpanded: expanded,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(2),
      selectedView: _dataViewMode,
      onViewChanged: (v) => setState(() => _dataViewMode = v),
      searchWidth: expanded ? 220 : 180,
      searchQuery: _dataSearch,
      onSearchChanged: (q) => setState(() => _dataSearch = q),
      showFilterButtons: expanded,
      partyFilterLabel: 'Role',
      partyFilterIcon: shad.LucideIcons.users,
      partyOptions: ScrPtySpecs.roleOptions,
      selectedParties: _selectedRoles,
      onPartyChanged: (s) => setState(() => _selectedRoles = s),
      millFilterLabel: 'City',
      millFilterIcon: shad.LucideIcons.mapPin,
      millOptions: ScrPtySpecs.cityOptions,
      selectedMills: _selectedCities,
      onMillChanged: (s) => setState(() => _selectedCities = s),
      fabricFilterLabel: 'GST Type',
      fabricFilterIcon: shad.LucideIcons.fileCheck,
      fabricOptions: ScrPtySpecs.gstStatusOptions,
      selectedFabrics: _selectedGstTypes,
      onFabricChanged: (s) => setState(() => _selectedGstTypes = s),
      statusOptions: ScrPtySpecs.kycStatusOptions,
      selectedStatuses: _selectedKycStatuses,
      onStatusChanged: (s) => setState(() => _selectedKycStatuses = s),
      showDateFilter: expanded,
      selectedDateRange: _selectedDateRange,
      selectedDateLabel: _selectedDateLabel,
      onDateRangeSelected: (range) {
        setState(() {
          _selectedDateRange = range;
          _selectedDateLabel = range != null ? 'Custom' : null;
        });
      },
      groupOptions: ScrPtySpecs.groupOptions,
      selectedGroup: expanded ? _dataGroup : 'none',
      onGroupChanged: expanded ? (g) => setState(() => _dataGroup = g) : null,
      selectedSortField: _sortField,
      isSortAscending: _sortAsc,
      onSortFieldChanged:
          expanded ? (f) => setState(() => _sortField = f) : null,
      onToggleSortDirection:
          expanded ? () => setState(() => _sortAsc = !_sortAsc) : null,
      hasActiveFilters: _hasDataFilters,
      onClearAllFilters: () => setState(() {
        _selectedRoles = {};
        _selectedCities = {};
        _selectedGstTypes = {};
        _selectedKycStatuses = {};
        _selectedDateRange = null;
        _selectedDateLabel = null;
      }),
    );
  }

  Widget _buildTasksActionBar() {
    final expanded = _zoomedRegion == 3;
    return DynamicActionBar(
      region: DabRegion.tasks,
      entityName: 'Tasks',
      isExpanded: expanded,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(3),
      taskQueueLabels: ScrPtySpecs.taskQueues,
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
      reportLensLabels: ScrPtySpecs.reportLenses,
      selectedReportLensIndex: _reportLensIdx,
      onReportLensChanged: (i) => setState(() => _reportLensIdx = i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DyLandingCanvas(
      key: _canvasKey,
      title: 'Parties',
      moduleName: 'Party',
      showDefaultHeaderActions: true,
      controlledZoomedRegion: _zoomedRegion,
      onZoomedRegionChanged: (reg) => setState(() => _zoomedRegion = reg),
      onPageActionKey: _handlePageActionKey,
      onPrint: () => ServiceHeaderToast.instance.show(
        'Print queued for Parties [P]',
      ),
      onExport: () => ServiceHeaderToast.instance.show(
        'Exported Parties template [X]',
        tone: HeaderToastTone.success,
      ),
      onAdd: () => _canvasKey.currentState?.openAddFlow(),
      onSaveDraftAdd: () => ServiceHeaderToast.instance.show(
        'Saved Party draft (backend pending)',
        tone: HeaderToastTone.warning,
      ),
      onConfirmAdd: _handleConfirmAdd,
      addFlowBuilder: (_) => ScrPtyForm(key: _formKey),
      metricsActionBar: _buildMetricsActionBar(),
      metricsChild: ScrPtyMetricsPane(
        horizon: _horizon,
        selectedKpiIndex: _selectedKpiIdx,
        onKpiSelected: (i) => setState(
          () => _selectedKpiIdx = _selectedKpiIdx == i ? null : i,
        ),
        isExpanded: false,
        trendMode: _trendMode,
        onTrendModeChanged: (m) => setState(() => _trendMode = m),
      ),
      metricsExpandedChild: ScrPtyMetricsPane(
        horizon: _horizon,
        selectedKpiIndex: _selectedKpiIdx,
        onKpiSelected: (i) => setState(
          () => _selectedKpiIdx = _selectedKpiIdx == i ? null : i,
        ),
        isExpanded: true,
        trendMode: _trendMode,
        onTrendModeChanged: (m) => setState(() => _trendMode = m),
      ),
      dataActionBar: _buildDataActionBar(),
      dataChild: ScrPtyDataPane(
        viewMode: _dataViewMode,
        isExpanded: _zoomedRegion == 2,
      ),
      tasksActionBar: _buildTasksActionBar(),
      tasksChild: ScrPtyTasksPane(
        queueIndex: _taskQueueIdx,
        searchQuery: _taskSearch,
        isExpanded: _zoomedRegion == 3,
      ),
      reportsActionBar: _buildReportsActionBar(),
      reportsChild: ScrPtyReportsPane(
        lensIndex: _reportLensIdx,
        isExpanded: false,
      ),
      reportsExpandedChild: ScrPtyReportsPane(
        lensIndex: _reportLensIdx,
        isExpanded: true,
      ),
    );
  }
}
