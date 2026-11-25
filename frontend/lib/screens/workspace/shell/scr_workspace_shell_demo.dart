/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Interactive Stage 3 & Stage 4 workbench mounted under `Workspace -> Shell`
     (index `405`) showcasing `DyLinearLandingCanvas` end-to-end:
     * Desktop (`>= 768px`): Non-scrollable 4-region Base-12 Bento landing
       (`PageHeader` with `>` subpage breadcrumb, Center Toast Zone, trailing
       KeyCap actions `Print [P]`, `Export [X]`, `Add [N]`; Row 1+2 `Metrics`;
       Row 3 `Flex 8` scrollable `Data` with 8->12 column expansion + `Flex 4`
       single-column equal-height `Tasks` & `Reports` scrollable panes).
     * Mobile (`< 768px`): Native `DynamicMobileShell` with 2nd-row
       `shad.TabList`, action-only DAB strips, and `Data` ListView -> Details.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Delegates keyboard shortcuts (`Shift + 1..4`, `P/X/N`, `Backspace`)
     directly through `DyLinearLandingCanvas`'s active-tab `ModuleShortcutBinding`.
   - Zero hardcoded colors or Material chrome; pure `shadcn_flutter` tokens.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Pure client-side interactive preset data (delegated to
     `scr_workspace_shell_demo_regions.dart` to keep both files modular & compact).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Ready to roll the validated 4-region `DyLinearLandingCanvas` contract
     into live `Cuttings` & `Jobs` screens.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/page/dy_action_bar.dart';
import '../../../dynamic_ai/page/dy_details_pane.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../services/service_header_toast.dart';
import 'scr_workspace_shell_demo_regions.dart';

/// Interactive Linear Landing showcase (`Workspace -> Shell`).
class ScrWorkspaceShellDemo extends StatefulWidget {
  const ScrWorkspaceShellDemo({super.key});

  @override
  State<ScrWorkspaceShellDemo> createState() => _ScrWorkspaceShellDemoState();
}

class _ScrWorkspaceShellDemoState extends State<ScrWorkspaceShellDemo> {
  final GlobalKey<DyLinearLandingCanvasState> _canvasKey =
      GlobalKey<DyLinearLandingCanvasState>();

  int? _zoomedRegion;
  DyTableRowData? _mobileInspectedRow;

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

  // Tasks state
  int _taskQueueIdx = 0;
  String _taskSearch = '';
  static const List<String> _taskQueues = ['All', 'Overdue', 'Today'];
  final Set<String> _resolvedTaskIds = {};

  static const List<ShellTaskEntry> _initialTasks = [
    ShellTaskEntry(
      id: 't1',
      title: 'Shrinkage >12% • CC-0288',
      subtitle: 'Laxmi Dyeing • Verify meter balance before fold',
      queue: 'Overdue',
      badgeText: '17d Overdue',
      tone: DyKpiTone.danger,
    ),
    ShellTaskEntry(
      id: 't2',
      title: 'Table 3 Challan Signoff',
      subtitle: 'CC-0294 • 420 Pcs 60Gm Silk waiting gate pass',
      queue: 'Today',
      badgeText: 'Due Today',
      tone: DyKpiTone.warning,
    ),
    ShellTaskEntry(
      id: 't3',
      title: 'Taka #4409 Quality Hold',
      subtitle: 'Suryansh Mill • Stain check requested by Master',
      queue: 'Overdue',
      badgeText: 'Hold',
      tone: DyKpiTone.danger,
    ),
    ShellTaskEntry(
      id: 't4',
      title: 'Allocate Fold Karigar Lot',
      subtitle: 'CC-0292 • Vardhman Prints • 510 Pcs Dola Silk',
      queue: 'Today',
      badgeText: 'Ready',
      tone: DyKpiTone.cyan,
    ),
    ShellTaskEntry(
      id: 't5',
      title: 'Update Packing LR Ref',
      subtitle: 'CC-0289 • Shree Laxmi Prints • Bales staged',
      queue: 'Today',
      badgeText: 'Completed',
      tone: DyKpiTone.success,
    ),
  ];

  // Reports state
  int _reportLensIdx = 0;
  static const List<String> _reportLenses = [
    'By Mill',
    'By Party',
    'By Quality',
    'Ageing',
  ];

  List<ShellTaskEntry> get _visibleTasks {
    final q = _taskSearch.trim().toLowerCase();
    return _initialTasks.where((t) {
      if (_resolvedTaskIds.contains(t.id)) return false;
      if (_taskQueueIdx == 1 && t.queue != 'Overdue') return false;
      if (_taskQueueIdx == 2 && t.queue != 'Today') return false;
      if (q.isNotEmpty &&
          !t.title.toLowerCase().contains(q) &&
          !t.subtitle.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get _hasDataFilters =>
      _selectedParties.isNotEmpty ||
      _selectedMills.isNotEmpty ||
      _selectedFabrics.isNotEmpty ||
      _selectedStatuses.isNotEmpty ||
      _selectedDateRange != null;

  bool _handlePageActionKey(String keyChar) {
    switch (keyChar) {
      case 'P':
        ServiceHeaderToast.instance.show('Print queued for Cuttings [P]');
        return true;
      case 'X':
        ServiceHeaderToast.instance.show(
          'Exported Cuttings snapshot CSV [X]',
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
      entityName: 'Cuttings',
      isExpanded: expanded,
      onToggleExpand: () => _canvasKey.currentState?.toggleRegion(2),
      selectedView: _dataViewMode,
      onViewChanged: (v) => setState(() => _dataViewMode = v),
      searchWidth: expanded ? 220 : 170,
      searchQuery: _dataSearch,
      onSearchChanged: (q) => setState(() => _dataSearch = q),
      showFilterButtons: expanded,
      partyOptions: const [
        'Suryansh Mill',
        'Mahadev Dyeing',
        'Vardhman Prints',
        'Ambaji Creation',
        'Shree Laxmi Prints',
        'Rangoli Processors',
        'Laxmi Dyeing',
      ],
      selectedParties: _selectedParties,
      onPartyChanged: (s) => setState(() => _selectedParties = s),
      millOptions: const ['Suryansh Mill', 'Mahadev Dyeing', 'Vardhman Prints'],
      selectedMills: _selectedMills,
      onMillChanged: (s) => setState(() => _selectedMills = s),
      fabricOptions: const ['60Gm Silk', 'Georgette', 'Dola Silk'],
      selectedFabrics: _selectedFabrics,
      onFabricChanged: (s) => setState(() => _selectedFabrics = s),
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
      taskQueueLabels: _taskQueues,
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
      reportLensLabels: _reportLenses,
      selectedReportLensIndex: _reportLensIdx,
      onReportLensChanged: (i) {
        setState(() => _reportLensIdx = i);
        ServiceHeaderToast.instance.show('Reports view: ${_reportLenses[i]}');
      },
    );
  }

  Widget _buildMobileDetailsSubview(DyTableRowData row) {
    return DyDetailsPane(
      title: row.voucherNo ?? row.id,
      subtitle: '${row.partyName ?? ''} • ${row.designPattern ?? ''}',
      statusBadge: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: false,
        child: row.status == 'Completed'
            ? const shad.PrimaryBadge(child: Text('Completed'))
            : const shad.OutlineBadge(child: Text('Pending')),
      ),
      metadata: {
        'Voucher #': row.voucherNo ?? '-',
        'Date': '${row.data['date'] ?? '-'}',
        'Mill / Party': row.partyName ?? '-',
        'Master / Fold': '${row.data['broker'] ?? '-'}',
        'Quality': row.designPattern ?? '-',
        'Design #': '${row.data['designCode'] ?? '-'}',
        'Thans': '${row.data['than'] ?? '-'}',
        'Total Meters': '${row.data['meters'] ?? '-'}',
        'Net Output': row.quantity ?? '-',
        'Est. Value': row.amount ?? '-',
      },
      lineItemsTable: row.children.isEmpty
          ? null
          : DyTable(
              columns: const [
                DyTableColumnSpec(key: 'vno', label: 'Cut #', flex: 1),
                DyTableColumnSpec(key: 'partyName', label: 'Taka / Color', flex: 2),
                DyTableColumnSpec(
                  key: 'quantity',
                  label: 'Pcs',
                  flex: 1,
                  isNumeric: true,
                ),
                DyTableColumnSpec(key: 'status', label: 'Stage', flex: 1),
              ],
              rows: row.children,
              totalRecords: row.children.length,
              showTrailingActions: false,
            ),
      onPrint: () => ServiceHeaderToast.instance.show(
        'Print requested for ${row.voucherNo ?? row.id}',
      ),
      onEdit: () => ServiceHeaderToast.instance.show(
        'Edit requested for ${row.voucherNo ?? row.id}',
      ),
      onClose: () => setState(() => _mobileInspectedRow = null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _visibleTasks;
    final inspected = _mobileInspectedRow;

    return DyLinearLandingCanvas(
      key: _canvasKey,
      title: 'Cuttings',
      moduleName: 'Cutting Card',
      showDefaultHeaderActions: true,
      controlledZoomedRegion: _zoomedRegion,
      onZoomedRegionChanged: (reg) => setState(() => _zoomedRegion = reg),
      onPageActionKey: _handlePageActionKey,
      mobileSubviewTitle: inspected != null
          ? '${inspected.voucherNo ?? inspected.id} • ${inspected.partyName ?? ''}'
          : null,
      onExitMobileSubview: inspected != null
          ? () => setState(() => _mobileInspectedRow = null)
          : null,
      mobileSubviewChild:
          inspected != null ? _buildMobileDetailsSubview(inspected) : null,
      onPrint: () =>
          ServiceHeaderToast.instance.show('Print queued for Cuttings [P]'),
      onExport: () => ServiceHeaderToast.instance.show(
        'Exported Cuttings snapshot CSV [X]',
        tone: HeaderToastTone.success,
      ),
      onAdd: () => _canvasKey.currentState?.openAddFlow(),
      onSaveDraftAdd: () => ServiceHeaderToast.instance.show(
        'Saved Cutting Card draft',
        tone: HeaderToastTone.warning,
      ),
      onConfirmAdd: () {
        ServiceHeaderToast.instance.show(
          'Cutting Card batch confirmed',
          tone: HeaderToastTone.success,
        );
        _canvasKey.currentState?.exitToSnapshot();
      },
      addFlowBuilder: (onBack) => ShellAddCuttingForm(onCancel: onBack),
      metricsActionBar: _buildMetricsActionBar(),
      metricsChild: ShellMetricsKpiRow(
        horizon: _horizon,
        selectedKpiIndex: _selectedKpiIdx,
        onKpiSelected: (idx) {
          setState(
            () => _selectedKpiIdx = _selectedKpiIdx == idx ? null : idx,
          );
          ServiceHeaderToast.instance.show('Filtered by KPI #${idx + 1}');
        },
      ),
      metricsExpandedChild: ShellMetricsExpandedView(
        horizon: _horizon,
        selectedKpiIndex: _selectedKpiIdx,
        onKpiSelected: (idx) =>
            setState(() => _selectedKpiIdx = _selectedKpiIdx == idx ? null : idx),
        trendMode: _trendMode,
        onTrendModeChanged: (m) => setState(() => _trendMode = m),
      ),
      dataActionBar: _buildDataActionBar(),
      dataChild: ShellDataRegionPane(
        isExpanded: _zoomedRegion == 2,
        viewMode: _dataViewMode,
        groupingMode: _zoomedRegion == 2 ? _dataGroup : 'none',
        searchQuery: _dataSearch,
        selectedParties: _selectedParties,
        selectedMills: _selectedMills,
        selectedFabrics: _selectedFabrics,
        selectedStatuses: _selectedStatuses,
        onInspectRowMobile: (row) => setState(() => _mobileInspectedRow = row),
      ),
      tasksActionBar: _buildTasksActionBar(),
      tasksChild: ShellTasksRegionPane(
        tasks: tasks,
        isExpanded: _zoomedRegion == 3,
        onResolveTask: (id) {
          setState(() => _resolvedTaskIds.add(id));
          ServiceHeaderToast.instance.show(
            'Task resolved',
            tone: HeaderToastTone.success,
          );
        },
      ),
      reportsActionBar: _buildReportsActionBar(),
      reportsChild: ShellReportsRegionPane(
        lensIndex: _reportLensIdx,
        isExpanded: false,
      ),
      reportsExpandedChild: ShellReportsRegionPane(
        lensIndex: _reportLensIdx,
        isExpanded: true,
      ),
    );
  }
}
