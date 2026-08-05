/*
================================================================================
LLM CONTEXT & QUERY SPACE — CUTTING CARDS FORM SCREEN (scr_cc_form.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Cutting Cards Workstation Creation Form Container Screen.
   - Target schemas/tables: `IMMBE2627.sq_MILLREC` (uncut source cards), `sb_cutdet_summary`, `sb_cutdet`.
   - DyShlAdd 2-row layout:
     - Row 1: Flex 7 Left Table (Uncut sq_MILLREC cards) / Flex 3 Right Form ("Details" pane).
     - Row 2 (Fixed 160px): Bottom DySummaryBar for live metrics.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Single Mill Rule: Uncut cards loaded strictly for the Mill selected in DAB AutoComplete.
   - Initial State: No default date range filter, no default grouping levels (flat list).
   - Native Mill AutoComplete: User can type to search and select Mill.
   - FIFO Order: Cards loaded by oldest CUTDATE first.
   - Dynamic Column Shifting: Grouped columns move to Position 1, 2, 3, 4.
   - Nested Group Rows Engine: 1 to 4 levels of single-column group rows down to def rows.
   - Active Checkboxes: Def rows and Group rows have active selection checkboxes.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/page/dy_action_bar.dart';
import '../../../dynamic_ai/page/dy_form_section.dart';
import '../../../dynamic_ai/page/dy_summary_bar.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_page_canvas.dart';
import '../../../dynamic_ai/shells/dy_shl_add.dart';
import '../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../dynamic_ai/micro/dy_micro_button.dart';
import '../../../dynamic_ai/micro/dab/dab_single_date_popover.dart';
import '../../../models/production/mdl_cc.dart';
import '../../../services/production/srv_cc.dart';

/// [ScrCcForm] — Creation Form Screen for Cutting Cards using DyShlAdd.
class ScrCcForm extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;
  final MdlCcHeader? editingHeader;

  const ScrCcForm({
    super.key,
    required this.onBack,
    required this.onSave,
    this.editingHeader,
  });

  @override
  State<ScrCcForm> createState() => _ScrCcFormState();
}

class _ScrCcFormState extends State<ScrCcForm> {
  final SrvCc _ccService = SrvCc();

  // Mill Selection & Uncut Cards State
  String? _selectedMill;
  List<String> _millOptions = [];
  List<Map<String, dynamic>> _uncutCardMaps = [];
  bool _isLoadingCards = false;

  // Filter & Multi-Level Grouping State (No default date or group filter)
  final Set<String> _selectedFabrics = {};
  List<String> _fabricOptions = [];
  List<String> _groupLevels = []; // Flat list by default
  String _searchQuery = '';
  final Set<String> _selectedRowIds = {};

  // Optional Date Range (Null initially)
  shad.CalendarValue? _selectedDateRange;

  // Form Section State & Controllers (Pure Numeric Card No input e.g. 332)
  final TextEditingController _cardNoController = TextEditingController(text: '332');
  final TextEditingController _millSearchController = TextEditingController();
  DateTime _executionDate = DateTime.now();
  String _selectedCutSpec = '5.20';
  final TextEditingController _freshPcsController = TextEditingController(text: '0');
  final TextEditingController _secondPcsController = TextEditingController(text: '0');
  final TextEditingController _sareeWeightController = TextEditingController(text: '350');
  final TextEditingController _fentWeightController = TextEditingController(text: '2500');
  final TextEditingController _notesController = TextEditingController();
  String _selectedProgram = 'OP';

  bool _isSaving = false;
  int _pageIndex = 1;

  final List<String> _cutSpecOptions = const ['5.20', '5.30', '6.00', '6.20'];
  final List<String> _programOptions = const ['OP', 'Padding', 'Print', 'Dyeing'];

  @override
  void initState() {
    super.initState();
    _loadMillOptions();
    if (widget.editingHeader != null) {
      final h = widget.editingHeader!;
      _selectedMill = h.millName;
      _millSearchController.text = h.millName;
      _cardNoController.text = h.multiVno.toString();
      _executionDate = h.cutDate;
      _selectedCutSpec = h.cutLength.toStringAsFixed(2);
      _freshPcsController.text = h.totalFreshPcs.toString();
      _secondPcsController.text = h.totalSecondPcs.toString();
      _sareeWeightController.text = h.avgWeight.toStringAsFixed(0);
      _fentWeightController.text = h.totalFentWt.toStringAsFixed(0);
      _notesController.text = h.notes;
      _selectedRowIds.addAll(h.reccardNos.map((e) => e.toString()));
      _loadUncutCards();
    } else {
      _fetchNextVno();
    }
  }

  @override
  void dispose() {
    _cardNoController.dispose();
    _millSearchController.dispose();
    _freshPcsController.dispose();
    _secondPcsController.dispose();
    _sareeWeightController.dispose();
    _fentWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchNextVno() async {
    if (widget.editingHeader != null) return;
    final vno = await _ccService.getNextMultiVno();
    if (!mounted) return;
    setState(() {
      _cardNoController.text = vno.toString();
    });
  }

  Future<void> _loadMillOptions() async {
    final mills = await _ccService.getMillOptions();
    if (!mounted) return;
    setState(() {
      _millOptions = mills;
    });
  }

  Future<void> _loadUncutCards() async {
    if (_selectedMill == null || _selectedMill!.isEmpty) {
      setState(() {
        _uncutCardMaps = [];
        _isLoadingCards = false;
        _selectedRowIds.clear();
      });
      return;
    }

    setState(() {
      _isLoadingCards = true;
    });

    final dateRange = _selectedDateRange?.toRange();
    final cardMaps = await _ccService.getUncutCardMapsByMill(
      millCode: _selectedMill!,
      selectedFabrics: _selectedFabrics,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      searchQuery: _searchQuery,
      currentBatchRecCardNos: widget.editingHeader?.reccardNos ?? [],
    );

    final fabrics = await _ccService.getFabricOptionsForMill(_selectedMill!);

    if (!mounted) return;

    setState(() {
      _uncutCardMaps = cardMaps;
      _fabricOptions = fabrics;
      _isLoadingCards = false;
    });
  }

  void _onMillSelected(String mill) {
    setState(() {
      _selectedMill = mill;
      _millSearchController.text = mill;
      _selectedFabrics.clear();
      _selectedRowIds.clear();
      _pageIndex = 1;
    });
    _loadUncutCards();
  }

  Future<void> _handleConfirmSave() async {
    if (_selectedMill == null || _selectedMill!.isEmpty) {
      shad.showToast(
        context: context,
        builder: (context, overlay) => const shad.SurfaceCard(
          child: Text('Please select a Processing Mill first.'),
        ),
      );
      return;
    }

    final targetCards = _selectedRowIds.isNotEmpty
        ? _uncutCardMaps.where((c) => _selectedRowIds.contains(c['RECCARDNO'].toString())).toList()
        : _uncutCardMaps;

    if (targetCards.isEmpty) {
      shad.showToast(
        context: context,
        builder: (context, overlay) => const shad.SurfaceCard(
          child: Text('Please select at least one uncut card from the table.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final parsedVno = int.tryParse(_cardNoController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final targetVno = parsedVno ?? (widget.editingHeader?.multiVno ?? await _ccService.getNextMultiVno());

      final startCutCardNo = (widget.editingHeader != null && widget.editingHeader!.cutCardNos.isNotEmpty)
          ? widget.editingHeader!.cutCardNos.first
          : await _ccService.getNextCutCardNo();

      final input = MdlCcBatchInput(
        multiVno: targetVno,
        millName: _selectedMill!,
        cutDate: _executionDate,
        cutLength: double.tryParse(_selectedCutSpec) ?? 5.20,
        totalFreshPcs: int.tryParse(_freshPcsController.text) ?? 0,
        totalSecondPcs: int.tryParse(_secondPcsController.text) ?? 0,
        avgWtGrams: double.tryParse(_sareeWeightController.text) ?? 350.0,
        totalFentWtGrams: double.tryParse(_fentWeightController.text) ?? 0.0,
        notes: _notesController.text.trim(),
        selectedCards: targetCards,
      );

      final details = input.buildDetailRows(
        author: '01113a5f-48f5-41a5-b905-17ce79e46b86',
        startCutCardNo: startCutCardNo,
      );

      final summary = input.buildSummaryRow(
        details,
        author: '01113a5f-48f5-41a5-b905-17ce79e46b86',
      );

      final bool success;
      if (widget.editingHeader != null) {
        success = await _ccService.updateCuttingBatch(
          summaryId: widget.editingHeader!.id,
          summary: summary,
          details: details,
          previousMultiVno: widget.editingHeader!.multiVno,
        );
      } else {
        success = await _ccService.commitCuttingBatch(
          summary: summary,
          details: details,
        );
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (success) {
        final actionText = widget.editingHeader != null ? 'updated' : 'created';
        shad.showToast(
          context: context,
          builder: (context, overlay) => shad.SurfaceCard(
            child: Text('Cutting Card CC-${targetVno.toString().padLeft(4, '0')} $actionText with ${details.length} cards!'),
          ),
        );
        widget.onSave();
      } else {
        shad.showToast(
          context: context,
          builder: (context, overlay) => const shad.SurfaceCard(
            child: Text('Failed to save cutting card batch. Check logs.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      shad.showToast(
        context: context,
        builder: (context, overlay) => shad.SurfaceCard(
          child: Text('Error: $e'),
        ),
      );
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    // Active Selection or All Uncut Cards Metrics
    final targetCards = _selectedRowIds.isNotEmpty
        ? _uncutCardMaps.where((c) => _selectedRowIds.contains(c['RECCARDNO'].toString())).toList()
        : _uncutCardMaps;

    double totalRecMtrs = 0.0;
    double totalWmts = 0.0;
    double totalGreyCost = 0.0;
    double totalJobRateSum = 0.0;

    for (final c in targetCards) {
      final rmts = (c['RMTS'] as num?)?.toDouble() ?? 0.0;
      final wmts = (c['WMTS'] as num?)?.toDouble() ?? 0.0;
      final gRate = (c['RATE'] as num?)?.toDouble() ?? 0.0;
      final jRate = (c['JOBRATE'] as num?)?.toDouble() ?? 0.0;
      totalRecMtrs += rmts;
      totalWmts += wmts;
      totalGreyCost += (wmts * gRate);
      totalJobRateSum += jRate;
    }

    final double avgGreyRate = totalWmts > 0 ? (totalGreyCost / totalWmts) : 0.0;
    final double avgJobRate = targetCards.isNotEmpty ? (totalJobRateSum / targetCards.length) : 0.0;
    final double totalInvestment = (totalWmts * avgGreyRate) + (totalRecMtrs * avgJobRate);

    final double cutLengthVal = double.tryParse(_selectedCutSpec) ?? 5.20;
    final int freshPcsInput = int.tryParse(_freshPcsController.text) ?? 0;
    final int freshPcsVal = freshPcsInput > 0 ? freshPcsInput : (cutLengthVal > 0 ? (totalRecMtrs / cutLengthVal).floor() : 0);
    final double freshMtrs = freshPcsVal * cutLengthVal;
    final double freshYieldPct = totalRecMtrs > 0 ? (freshMtrs / totalRecMtrs) * 100 : 0.0;
    final double costPerPc = freshPcsVal > 0 ? totalInvestment / freshPcsVal : 0.0;

    final hasFilters = _selectedFabrics.isNotEmpty || _searchQuery.isNotEmpty || _selectedDateRange != null || _groupLevels.isNotEmpty;

    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.form,
      header: PageHeader(
        title: widget.editingHeader != null
            ? 'Edit Cutting Card CC-${_cardNoController.text.padLeft(4, '0')}'
            : 'New Cutting Card',
        moduleName: 'Cutting Cards',
        mode: widget.editingHeader != null ? PageHeaderMode.editing : PageHeaderMode.adding,
        onBack: widget.onBack,
        onDiscard: widget.onBack,
        onSaveDraft: () {
          shad.showToast(
            context: context,
            builder: (context, overlay) => const shad.SurfaceCard(
              child: Text('Draft saved successfully.'),
            ),
          );
        },
        onConfirm: _handleConfirmSave,
        isSaving: _isSaving,
      ),
      content: DyShlAdd(
        leftFlex: 8,
        rightFlex: 2,
        // ROW 1 TOP LEFT DAB
        actionBar: DynamicActionBar(
          mode: DabMode.form,
          entityName: 'Uncut Cards',
          supportedViewModes: const [], // Omit View Switcher completely in form mode
          showFilterButtons: true,
          showSearch: true,
          searchQuery: _searchQuery,
          onSearchChanged: (val) {
            _searchQuery = val.trim();
            _loadUncutCards();
          },

          // 1. NATIVE SEARCHABLE AUTOCOMPLETE FOR MILL
          autoCompleteWidget: SizedBox(
            width: 240 * theme.scaling,
            height: 34 * theme.scaling,
            child: Builder(
              builder: (btnContext) => shad.TextField(
                controller: _millSearchController,
                filled: true,
                placeholder: const Text('Search Mill...'),
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * theme.scaling,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  border: Border.all(color: theme.colorScheme.border, width: 1.0),
                ),
                features: [
                  shad.InputFeature.leading(
                    Icon(
                      shad.LucideIcons.warehouse,
                      size: 16 * theme.scaling,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
                onTap: () {
                  shad.showOverlay(
                    btnContext,
                    shad.PopoverConfiguration(
                      anchorAlignment: Alignment.bottomLeft,
                      alignment: Alignment.topLeft,
                      offset: const Offset(0, 4),
                      builder: (context) => _buildMillSearchPopover(context, theme),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. FABRIC MB FILTER
          selectedFabrics: _selectedFabrics,
          fabricOptions: _fabricOptions,
          onFabricChanged: (fabrics) {
            setState(() {
              _selectedFabrics.clear();
              _selectedFabrics.addAll(fabrics);
            });
            _loadUncutCards();
          },

          // 3. DATE RANGE MB (Optional, No Default Filter)
          showDateFilter: true,
          selectedDateRange: _selectedDateRange,
          onDateRangeSelected: (range) {
            setState(() {
              _selectedDateRange = range;
            });
            _loadUncutCards();
          },

          // 4. GROUP POPOVER MICROBUTTON (1 to 4 Levels)
          groupLevels: _groupLevels,
          onGroupLevelsChanged: (levels) {
            setState(() {
              _groupLevels = levels;
            });
          },

          // CLEAR FILTERS BUTTON
          hasActiveFilters: hasFilters,
          onClearAllFilters: () {
            setState(() {
              _selectedFabrics.clear();
              _searchQuery = '';
              _selectedDateRange = null;
              _groupLevels.clear();
            });
            _loadUncutCards();
          },
        ),

        // ROW 1 FLEX 7 TABLE WORKSPACE (Dynamic Column Shifting & Multi-Level Grouping)
        tableWorkspace: DyTable(
          columns: _buildDynamicTableColumns(),
          rows: _buildMappedGroupedTableRows(),
          isLoading: _isLoadingCards,
          showTrailingActions: false,
          selectedRowIds: _selectedRowIds,
          onSelectionChanged: (selectedIds) {
            setState(() {
              _selectedRowIds.clear();
              _selectedRowIds.addAll(selectedIds);
            });
          },
          totalRecords: _uncutCardMaps.length,
          pageIndex: _pageIndex,
          pageSize: 50,
          onPageChanged: (p) {
            setState(() {
              _pageIndex = p;
            });
          },
        ),

        // ROW 1 FLEX 3 SINGLE FORM WORKSPACE ("Details" Pane)
        formWorkspace: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DyFormSection(
              title: 'Details',
              leadingIcon: shad.LucideIcons.fileText,
              fields: [
                // 1. Card No
                DyFormField(
                  colSpan: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card No', style: theme.typography.xSmall),
                      const SizedBox(height: 4),
                      shad.TextField(
                        controller: _cardNoController,
                        placeholder: const Text('332'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),

                // 2. Date
                DyFormField(
                  colSpan: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cutting Date', style: theme.typography.xSmall),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (btnContext) => MicroButton(
                          leadingIcon: shad.LucideIcons.calendar,
                          label: _formatDate(_executionDate),
                          trailingIcon: shad.LucideIcons.chevronDown,
                          onPressed: () {
                            shad.showOverlay(
                              btnContext,
                              shad.PopoverConfiguration(
                                anchorAlignment: Alignment.bottomRight,
                                alignment: Alignment.topRight,
                                offset: const Offset(0, 4),
                                builder: (popContext) => DabSingleDatePopover(
                                  initialDate: _executionDate,
                                  onDateSelected: (date) {
                                    setState(() {
                                      _executionDate = date;
                                    });
                                  },
                                  onClose: () => shad.closeOverlay(popContext),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Cut Spec Chips
                DyFormField(
                  colSpan: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cut Spec (Mtr)', style: theme.typography.xSmall),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _cutSpecOptions.map((spec) {
                          final isSelected = _selectedCutSpec == spec;
                          return MicroButton(
                            label: spec,
                            isSelected: isSelected,
                            isGhost: !isSelected,
                            onPressed: () => setState(() => _selectedCutSpec = spec),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 4. Fresh Pcs & Second Pcs Inputs
                DyFormField(
                  colSpan: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fresh Pcs', style: theme.typography.xSmall),
                      const SizedBox(height: 4),
                      shad.TextField(
                        controller: _freshPcsController,
                        placeholder: const Text('0'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                DyFormField(
                  colSpan: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Second Pcs', style: theme.typography.xSmall),
                      const SizedBox(height: 4),
                      shad.TextField(
                        controller: _secondPcsController,
                        placeholder: const Text('0'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),

                // 5. Saree Weight & Fent Weight Inputs (in Grams)
                DyFormField(
                  colSpan: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saree Wt (g)', style: theme.typography.xSmall),
                      const SizedBox(height: 4),
                      shad.TextField(
                        controller: _sareeWeightController,
                        placeholder: const Text('350'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                DyFormField(
                  colSpan: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fent Wt (g)', style: theme.typography.xSmall),
                      const SizedBox(height: 4),
                      shad.TextField(
                        controller: _fentWeightController,
                        placeholder: const Text('2500'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),

                // 6. Program Chips
                DyFormField(
                  colSpan: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Processing Program', style: theme.typography.xSmall),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _programOptions.map((prog) {
                          final isSelected = _selectedProgram == prog;
                          return MicroButton(
                            label: prog,
                            isSelected: isSelected,
                            isGhost: !isSelected,
                            onPressed: () => setState(() => _selectedProgram = prog),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 7. Notes & Remarks
                DyFormField(
                  colSpan: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes / Remarks', style: theme.typography.xSmall),
                      const SizedBox(height: 4),
                      shad.TextField(
                        controller: _notesController,
                        placeholder: const Text('Add batch remarks or rate notes...'),
                        maxLines: 2,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ROW 2 BOTTOM SUMMARY BAR (Fixed 160px Height)
        summaryHeight: 160.0,
        summaryBar: DySummaryBar(
          height: 160.0,
          metrics: [
            DySummaryMetricTile(
              label: 'Received Fabric',
              value: '${totalRecMtrs.toStringAsFixed(1)} Mtr',
              subValue: 'Selected Cards: ${targetCards.length}',
              icon: shad.LucideIcons.packageCheck,
            ),
            DySummaryMetricTile(
              label: 'Fresh Sarees Cut',
              value: '$freshPcsVal Pcs',
              subValue: 'Spec: $_selectedCutSpec Mtr',
              icon: shad.LucideIcons.scissors,
            ),
            DySummaryMetricTile(
              label: 'Fresh Yield %',
              value: '${freshYieldPct.toStringAsFixed(1)}%',
              subValue: 'Target: 85.0%',
              icon: shad.LucideIcons.percent,
              accentColor: freshYieldPct >= 85.0 ? DyColorSystem.green500 : DyColorSystem.orange500,
            ),
            DySummaryMetricTile(
              label: 'Cost / Saree',
              value: '₹${costPerPc.toStringAsFixed(2)}',
              subValue: 'Grey + Job Work',
              icon: shad.LucideIcons.tag,
            ),
            DySummaryMetricTile(
              label: 'Landed Capital',
              value: '₹${totalInvestment.toStringAsFixed(2)}',
              subValue: 'Batch Investment',
              icon: shad.LucideIcons.indianRupee,
              accentColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  // DYNAMIC COLUMN SHIFTING ENGINE
  List<DyTableColumnSpec> _buildDynamicTableColumns() {
    final Map<String, DyTableColumnSpec> masterColumns = {
      'date': const DyTableColumnSpec(key: 'date', label: 'DATE', flex: 1),
      'reccardno': const DyTableColumnSpec(key: 'reccardno', label: 'RECCARDNO', flex: 1, isPinnedLeft: true),
      'quality': const DyTableColumnSpec(key: 'fabric', label: 'FABRIC', flex: 2),
      'lotNo': const DyTableColumnSpec(key: 'lotno', label: 'LOTNO', flex: 1),
      'sentMtrs': const DyTableColumnSpec(key: 'sentMtrs', label: 'SENT MTRS', flex: 1, isNumeric: true, textAlignment: Alignment.centerRight),
      'recMtrs': const DyTableColumnSpec(key: 'recMtrs', label: 'REC MTRS', flex: 1, isNumeric: true, textAlignment: Alignment.centerRight),
      'rate': const DyTableColumnSpec(key: 'rate', label: 'RATE', flex: 1, isNumeric: true, textAlignment: Alignment.centerRight),
      'despNo': const DyTableColumnSpec(key: 'despno', label: 'DESPNO', flex: 1),
    };

    final List<DyTableColumnSpec> orderedCols = [];

    for (final levelKey in _groupLevels) {
      if (masterColumns.containsKey(levelKey)) {
        orderedCols.add(masterColumns[levelKey]!);
      }
    }

    final defaultOrder = ['date', 'reccardno', 'quality', 'lotNo', 'sentMtrs', 'recMtrs', 'rate'];
    for (final colKey in defaultOrder) {
      if (!_groupLevels.contains(colKey) && masterColumns.containsKey(colKey)) {
        orderedCols.add(masterColumns[colKey]!);
      }
    }

    return orderedCols;
  }

  // RECURSIVE SINGLE-COLUMN MULTI-LEVEL GROUPED ROWS ENGINE
  List<DyTableRowData> _buildMappedGroupedTableRows() {
    if (_uncutCardMaps.isEmpty) return [];

    if (_groupLevels.isEmpty) {
      return _uncutCardMaps.map((c) => _mapCardMapToDefRow(c)).toList();
    }

    return _buildGroupLevelMap(_uncutCardMaps, 0);
  }

  List<DyTableRowData> _buildGroupLevelMap(List<Map<String, dynamic>> items, int levelIndex) {
    if (levelIndex >= _groupLevels.length) {
      return items.map((c) => _mapCardMapToDefRow(c)).toList();
    }

    final currentLevelKey = _groupLevels[levelIndex];
    final String targetColKey = currentLevelKey == 'quality'
        ? 'fabric'
        : (currentLevelKey == 'lotNo' ? 'lotno' : (currentLevelKey == 'despNo' ? 'despno' : currentLevelKey));

    final Map<String, List<Map<String, dynamic>>> groupedMap = {};

    for (final c in items) {
      final keyVal = _getCardMapValueForKey(c, currentLevelKey);
      groupedMap.putIfAbsent(keyVal, () => []).add(c);
    }

    final List<DyTableRowData> groupRows = [];

    groupedMap.forEach((groupVal, groupItems) {
      double grpSentMtrs = 0.0;
      double grpRecMtrs = 0.0;
      double grpJobAmt = 0.0;
      for (final it in groupItems) {
        final wmts = (it['WMTS'] as num?)?.toDouble() ?? 0.0;
        final rmts = (it['RMTS'] as num?)?.toDouble() ?? 0.0;
        final jRate = (it['JOBRATE'] as num?)?.toDouble() ?? 0.0;
        grpSentMtrs += wmts;
        grpRecMtrs += rmts;
        grpJobAmt += rmts * jRate;
      }
      final double avgGrpJobRate = grpRecMtrs > 0 ? (grpJobAmt / grpRecMtrs) : 0.0;

      final subChildren = _buildGroupLevelMap(groupItems, levelIndex + 1);

      final Map<String, dynamic> rowDataMap = {
        'date': targetColKey == 'date' ? groupVal : '',
        'reccardno': targetColKey == 'reccardno' ? groupVal : '',
        'fabric': targetColKey == 'fabric' ? groupVal : '',
        'lotno': targetColKey == 'lotno' ? groupVal : '',
        'despno': targetColKey == 'despno' ? groupVal : '',
        'sentMtrs': '${grpSentMtrs.toStringAsFixed(1)} Mtr',
        'recMtrs': '${grpRecMtrs.toStringAsFixed(1)} Mtr',
        'rate': '₹${avgGrpJobRate.toStringAsFixed(2)}',
      };

      groupRows.add(
        DyTableRowData(
          id: 'group_L${levelIndex}_${currentLevelKey}_$groupVal',
          rowType: DyTableRowType.group,
          voucherNo: groupVal,
          partyName: (groupItems.first['MILL_CODE'] as String?) ?? '',
          children: subChildren,
          data: rowDataMap,
        ),
      );
    });

    return groupRows;
  }

  String _getCardMapValueForKey(Map<String, dynamic> c, String key) {
    switch (key) {
      case 'quality':
      case 'fabric':
        final q = (c['GREYQUAL'] as String?)?.trim() ?? '';
        return q.isNotEmpty ? q : 'Unknown Fabric';
      case 'date':
        final dStr = c['CUTDATE']?.toString() ?? '';
        final dt = DateTime.tryParse(dStr);
        return dt != null ? _formatDate(dt) : 'N/A';
      case 'rate':
        final jRate = (c['JOBRATE'] as num?)?.toDouble() ?? 0.0;
        return '₹${jRate.toStringAsFixed(2)}';
      case 'lotNo':
        final lot = (c['lot'] as String?)?.trim() ?? '';
        return lot.isNotEmpty ? lot : 'No Lot';
      case 'despNo':
        final d = c['DESPNO'];
        return 'Desp $d';
      default:
        return 'Other';
    }
  }

  DyTableRowData _mapCardMapToDefRow(Map<String, dynamic> c) {
    final recNo = (c['RECCARDNO'] as num?)?.toInt() ?? 0;
    final mill = (c['MILL_CODE'] as String?)?.trim() ?? '';
    final qual = (c['GREYQUAL'] as String?)?.trim() ?? '';
    final lot = (c['lot'] as String?)?.trim() ?? '';
    final wmts = (c['WMTS'] as num?)?.toDouble() ?? 0.0;
    final rmts = (c['RMTS'] as num?)?.toDouble() ?? 0.0;
    final jRate = (c['JOBRATE'] as num?)?.toDouble() ?? 0.0;
    final dtStr = c['CUTDATE']?.toString() ?? '';
    final dt = DateTime.tryParse(dtStr);

    return DyTableRowData(
      id: recNo.toString(),
      rowType: DyTableRowType.def,
      voucherNo: '$recNo',
      partyName: mill,
      data: {
        'date': dt != null ? _formatDate(dt) : '-',
        'reccardno': '$recNo',
        'fabric': qual,
        'lotno': lot.isNotEmpty ? lot : '-',
        'sentMtrs': '${wmts.toStringAsFixed(1)} Mtr',
        'recMtrs': '${rmts.toStringAsFixed(1)} Mtr',
        'rate': '₹${jRate.toStringAsFixed(2)}',
      },
    );
  }

  // Searchable Mill Selection Popover
  Widget _buildMillSearchPopover(BuildContext context, shad.ThemeData theme) {
    final filterQuery = _millSearchController.text.trim().toLowerCase();
    final filteredMills = _millOptions
        .where((m) => filterQuery.isEmpty || m.toLowerCase().contains(filterQuery))
        .toList();

    return shad.Card(
      child: Container(
        width: 300 * theme.scaling,
        padding: EdgeInsets.all(12 * theme.scaling),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Processing Mill', style: theme.typography.small.copyWith(fontWeight: FontWeight.bold)),
            const shad.DensityGap(shad.gapSm),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280 * theme.scaling),
              child: filteredMills.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('No mills match "$filterQuery".', style: theme.typography.xSmall),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredMills.length,
                      itemBuilder: (context, index) {
                        final m = filteredMills[index];
                        final isSelected = _selectedMill == m;
                        return shad.GhostButton(
                          onPressed: () {
                            _onMillSelected(m);
                            shad.closeOverlay(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? shad.LucideIcons.check : shad.LucideIcons.warehouse,
                                size: 14,
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  m,
                                  style: theme.typography.small.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
