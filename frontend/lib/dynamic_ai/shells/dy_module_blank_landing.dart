/*
================================================================================
LLM CONTEXT & QUERY SPACE — SHARED BLANK MODULE LANDING (dy_module_blank_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Shared 4-region blank-state module container (`DyModuleBlankLanding`),
     configuration (`DyModuleLandingConfig`), and `showDyLegacyOverlay` modal
     helper built on top of `DyLandingCanvas`, `DyRegionsCanvas`, and
     `DyFormCanvas`.
   - Exported cleanly by `dy_regions_canvas.dart` so Masters, Pipeline, Sales,
     and Finance screens share one reusable scaffold prior to Phase 2 wiring.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Manages 4 `DynamicActionBar` states, `Shift+1..4` zoom state, `[N]` Add Flow
     form rendering via `DyFormCanvas`, and `Shift+P/X/N/Backspace` actions.
   - Exposes `MastersBlankLinearLanding`, `MastersBlankLandingConfig`,
     `MastersKpiSpec`, and `MastersFormFieldSpec` backwards-compatible aliases.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Pure native `shadcn_flutter` tokens only (`theme.colorScheme`,
     `theme.typography`, `theme.density`, `shad.DensityGap`).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Replaced progressively per module by `scr_<mns>_regions.dart` and
     `scr_<mns>_form.dart` during Phase 2 backend integration.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../micro/dab/dab_group_switcher.dart';
import '../page/dy_action_bar.dart';
import '../page/dy_form_section.dart';
import '../page/dy_table.dart';
import '../specs/dy_grid_system.dart';
import '../../services/service_header_toast.dart';
import 'dy_form_canvas.dart';
import 'dy_landing_canvas.dart';
import 'dy_regions_canvas.dart';

/// Backwards-compatible aliases for Masters blank-state screens.
typedef MastersKpiSpec = DyRegionKpiSpec;
typedef MastersFormFieldSpec = DyModuleFormFieldSpec;
typedef MastersBlankLandingConfig = DyModuleLandingConfig;
typedef MastersBlankLinearLanding = DyModuleBlankLanding;
typedef DyModuleKpiSpec = DyRegionKpiSpec;

/// Descriptor for a field inside the auto-generated `[N]` Add Flow `DyFormSection`.
class DyModuleFormFieldSpec {
  final int colSpan;
  final String label;
  final String placeholder;
  final bool isRequired;
  final String? helperText;

  const DyModuleFormFieldSpec({
    required this.colSpan,
    required this.placeholder,
    String? label,
    this.isRequired = false,
    this.helperText,
  }) : label = label ?? placeholder;
}

/// Opens a preserved legacy screen or form inside a native `shadcn_flutter`
/// dialog overlay from any module `PageHeader` `Legacy` button.
Future<void> showDyLegacyOverlay(
  BuildContext context, {
  required String title,
  required Widget Function(VoidCallback close) builder,
}) async {
  final theme = shad.Theme.of(context);
  final colors = theme.colorScheme;
  final scaling = theme.scaling;

  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(barrierDismissible: true),
    builder: (overlayCtx) {
      final vp = MediaQuery.sizeOf(overlayCtx);
      void close() => shad.closeOverlay(overlayCtx);

      return Center(
        child: SizedBox(
          width: (vp.width * 0.92).clamp(320.0, 1220 * scaling),
          height: (vp.height * 0.88).clamp(400.0, 780 * scaling),
          child: shad.OutlinedContainer(
            backgroundColor: colors.card,
            borderColor: colors.border,
            borderRadius: theme.borderRadiusLg,
            padding: EdgeInsets.all(16 * scaling),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      shad.LucideIcons.history,
                      size: 16 * scaling,
                      color: colors.mutedForeground,
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                    shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      density: shad.ButtonDensity.iconDense,
                      icon: const Icon(shad.LucideIcons.x),
                      onPressed: close,
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapSm),
                const shad.Divider(),
                const shad.DensityGap(shad.gapSm),
                Expanded(child: builder(close)),
              ],
            ),
          ),
        ),
      );
    },
  );
  await completer.future;
}

/// Configuration object defining domain-specific blank structure for any ERP module.
class DyModuleLandingConfig {
  final String title;
  final String moduleName;
  final String entityPlural;
  final String targetTable;
  final IconData formIcon;
  final List<DyRegionKpiSpec> kpis;
  final List<DyTableColumnSpec> collapsedColumns;
  final List<DyTableColumnSpec> expandedColumns;
  final String partyFilterLabel;
  final IconData partyFilterIcon;
  final List<String> partyOptions;
  final String millFilterLabel;
  final IconData millFilterIcon;
  final List<String> millOptions;
  final String fabricFilterLabel;
  final IconData fabricFilterIcon;
  final List<String> fabricOptions;
  final List<String> statusOptions;
  final List<DabGroupOption> groupOptions;
  final List<String> taskQueues;
  final List<String> reportLenses;
  final List<DyModuleFormFieldSpec> addFormFields;
  final List<Widget> Function(BuildContext context)? headerExtraActionsBuilder;
  final int dataColumnSpan;

  const DyModuleLandingConfig({
    required this.title,
    required this.moduleName,
    required this.entityPlural,
    required this.targetTable,
    required this.formIcon,
    required this.kpis,
    required this.collapsedColumns,
    required this.expandedColumns,
    this.partyFilterLabel = 'Category',
    this.partyFilterIcon = shad.LucideIcons.tags,
    this.partyOptions = const [],
    this.millFilterLabel = 'Group',
    this.millFilterIcon = shad.LucideIcons.folderTree,
    this.millOptions = const [],
    this.fabricFilterLabel = 'Type',
    this.fabricFilterIcon = shad.LucideIcons.layers,
    this.fabricOptions = const [],
    this.statusOptions = const ['Active', 'Inactive'],
    this.groupOptions = kDefaultGroupOptions,
    this.taskQueues = const ['All', 'Overdue', 'Today'],
    this.reportLenses = const ['Overview', 'Status', 'Ageing'],
    required this.addFormFields,
    this.headerExtraActionsBuilder,
    this.dataColumnSpan = DyGridSystem.flexCardsGrid,
  });
}

/// Shared 4-region `DyLandingCanvas` + `DyRegionsCanvas` + `DyFormCanvas`
/// scaffold for Phase 1 standardized modules prior to backend wiring.
class DyModuleBlankLanding extends StatefulWidget {
  final DyModuleLandingConfig config;

  const DyModuleBlankLanding({
    super.key,
    required this.config,
  });

  @override
  State<DyModuleBlankLanding> createState() => _DyModuleBlankLandingState();
}

class _DyModuleBlankLandingState extends State<DyModuleBlankLanding> {
  final GlobalKey<DyLandingCanvasState> _canvasKey =
      GlobalKey<DyLandingCanvasState>();

  int? _zoomedRegion;

  // Metrics state
  DabTimeHorizon _horizon = DabTimeHorizon.thisYear;
  int? _selectedKpiIdx;
  int _trendMode = 0;

  // Data state
  String _dataViewMode = 'table';
  String _dataGroup = 'none';
  String _dataSearch = '';
  Set<String> _selectedParties = {};
  Set<String> _selectedMills = {};
  Set<String> _selectedFabrics = {};
  Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;
  String _sortField = 'date';
  bool _sortAsc = false;

  // Tasks & Reports state
  int _taskQueueIdx = 0;
  String _taskSearch = '';
  int _reportLensIdx = 0;

  DyModuleLandingConfig get _cfg => widget.config;

  bool get _hasDataFilters =>
      _selectedParties.isNotEmpty ||
      _selectedMills.isNotEmpty ||
      _selectedFabrics.isNotEmpty ||
      _selectedStatuses.isNotEmpty ||
      _selectedDateRange != null;

  bool _handlePageActionKey(String keyChar) {
    switch (keyChar) {
      case 'P':
        ServiceHeaderToast.instance.show('Print queued for ${_cfg.title} [P]');
        return true;
      case 'X':
        ServiceHeaderToast.instance.show(
          'Export queued for ${_cfg.title} [X]',
          tone: HeaderToastTone.success,
        );
        return true;
      default:
        return false;
    }
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
      entityName: _cfg.entityPlural,
      isExpanded: expanded,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(2),
      selectedView: _dataViewMode,
      onViewChanged: (v) => setState(() => _dataViewMode = v),
      searchWidth: expanded ? 220 : 180,
      searchQuery: _dataSearch,
      onSearchChanged: (q) => setState(() => _dataSearch = q),
      showFilterButtons: expanded,
      partyFilterLabel: _cfg.partyFilterLabel,
      partyFilterIcon: _cfg.partyFilterIcon,
      partyOptions: _cfg.partyOptions,
      selectedParties: _selectedParties,
      onPartyChanged: (s) => setState(() => _selectedParties = s),
      millFilterLabel: _cfg.millFilterLabel,
      millFilterIcon: _cfg.millFilterIcon,
      millOptions: _cfg.millOptions,
      selectedMills: _selectedMills,
      onMillChanged: (s) => setState(() => _selectedMills = s),
      fabricFilterLabel: _cfg.fabricFilterLabel,
      fabricFilterIcon: _cfg.fabricFilterIcon,
      fabricOptions: _cfg.fabricOptions,
      selectedFabrics: _selectedFabrics,
      onFabricChanged: (s) => setState(() => _selectedFabrics = s),
      statusOptions: _cfg.statusOptions,
      selectedStatuses: _selectedStatuses,
      onStatusChanged: (s) => setState(() => _selectedStatuses = s),
      showDateFilter: expanded,
      selectedDateRange: _selectedDateRange,
      selectedDateLabel: _selectedDateLabel,
      onDateRangeSelected: (range) {
        setState(() {
          _selectedDateRange = range;
          _selectedDateLabel = range != null ? 'Custom' : null;
        });
      },
      groupOptions: _cfg.groupOptions,
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
        _selectedParties = {};
        _selectedMills = {};
        _selectedFabrics = {};
        _selectedStatuses = {};
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
      taskQueueLabels: _cfg.taskQueues,
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
      reportLensLabels: _cfg.reportLenses,
      selectedReportLensIndex: _reportLensIdx,
      onReportLensChanged: (i) => setState(() => _reportLensIdx = i),
    );
  }

  Widget _buildMetricsRegion({required bool isExpanded}) {
    return DyMetricsRegion(
      kpis: _cfg.kpis,
      selectedKpiIndex: _selectedKpiIdx,
      onKpiSelected: (i) => setState(
        () => _selectedKpiIdx = _selectedKpiIdx == i ? null : i,
      ),
      isExpanded: isExpanded,
      trendTitle: '${_cfg.title} Activity (${_horizon.label})',
      trendSubtitle: 'Awaiting ${_cfg.targetTable} records',
      selectedTrendMode: _trendMode,
      onTrendModeChanged: (m) => setState(() => _trendMode = m),
      donutTitle: '${_cfg.title} Distribution',
      donutSubtitle: 'Schema: ${_cfg.targetTable}',
      donutCenterLabel: _cfg.entityPlural,
    );
  }

  Widget _buildAddForm(BuildContext context) {
    return DyFormCanvas(
      mainColumnSpan: _cfg.dataColumnSpan,
      mainSections: [
        DyFormSection(
          title: 'New ${_cfg.moduleName} (${_cfg.targetTable})',
          leadingIcon: _cfg.formIcon,
          fields: [
            for (final f in _cfg.addFormFields)
              DyFormField(
                colSpan: f.colSpan,
                child: DyFormLabeledField(
                  label: f.label,
                  isRequired: f.isRequired,
                  helperText: f.helperText,
                  child: shad.TextField(placeholder: Text(f.placeholder)),
                ),
              ),
          ],
        ),
      ],
      sideSections: [
        DyFormSection(
          title: 'Backend Staging',
          leadingIcon: shad.LucideIcons.database,
          fields: [
            DyFormField(
              colSpan: 12,
              child: DyEmptyRegionCard(
                icon: shad.LucideIcons.layers,
                title: _cfg.targetTable,
                subtitle:
                    'Form fields are staged for Supabase Edge Function wiring.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeQueue =
        _cfg.taskQueues[_taskQueueIdx.clamp(0, _cfg.taskQueues.length - 1)];
    final activeLens =
        _cfg.reportLenses[_reportLensIdx.clamp(0, _cfg.reportLenses.length - 1)];

    return DyLandingCanvas(
      key: _canvasKey,
      title: _cfg.title,
      moduleName: _cfg.moduleName,
      dataColumnSpan: _cfg.dataColumnSpan,
      showDefaultHeaderActions: true,
      actions: _cfg.headerExtraActionsBuilder?.call(context) ?? const [],
      controlledZoomedRegion: _zoomedRegion,
      onZoomedRegionChanged: (reg) => setState(() => _zoomedRegion = reg),
      onPageActionKey: _handlePageActionKey,
      onPrint: () => ServiceHeaderToast.instance.show(
        'Print queued for ${_cfg.title} [P]',
      ),
      onExport: () => ServiceHeaderToast.instance.show(
        'Exported ${_cfg.title} template [X]',
        tone: HeaderToastTone.success,
      ),
      onAdd: () => _canvasKey.currentState?.openAddFlow(),
      onSaveDraftAdd: () => ServiceHeaderToast.instance.show(
        'Saved ${_cfg.moduleName} draft (backend pending)',
        tone: HeaderToastTone.warning,
      ),
      onConfirmAdd: () {
        ServiceHeaderToast.instance.show(
          '${_cfg.moduleName} staged (backend wiring next)',
          tone: HeaderToastTone.info,
        );
        _canvasKey.currentState?.exitToSnapshot();
      },
      addFlowBuilder: (_) => _buildAddForm(context),
      metricsActionBar: _buildMetricsActionBar(),
      metricsChild: _buildMetricsRegion(isExpanded: false),
      metricsExpandedChild: _buildMetricsRegion(isExpanded: true),
      dataActionBar: _buildDataActionBar(),
      dataChild: DyDataRegion(
        entityPlural: _cfg.entityPlural,
        targetTable: _cfg.targetTable,
        emptyIcon: _cfg.formIcon,
        viewMode: _dataViewMode,
        isExpanded: _zoomedRegion == 2,
        collapsedColumns: _cfg.collapsedColumns,
        expandedColumns: _cfg.expandedColumns,
      ),
      tasksActionBar: _buildTasksActionBar(),
      tasksChild: DyTasksRegion(
        activeQueueLabel: activeQueue,
        targetTable: _cfg.targetTable,
        searchQuery: _taskSearch,
        isExpanded: _zoomedRegion == 3,
      ),
      reportsActionBar: _buildReportsActionBar(),
      reportsChild: DyReportsRegion(
        lensLabel: activeLens,
        targetTable: _cfg.targetTable,
        isExpanded: false,
      ),
      reportsExpandedChild: DyReportsRegion(
        lensLabel: activeLens,
        targetTable: _cfg.targetTable,
        isExpanded: true,
      ),
    );
  }
}
