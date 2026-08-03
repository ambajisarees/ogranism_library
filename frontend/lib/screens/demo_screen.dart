import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../dynamic_ai/shells/dy_page_canvas.dart';
import '../dynamic_ai/page/dy_page_header.dart';
import '../dynamic_ai/page/dy_action_bar.dart';
import '../dynamic_ai/micro/dab/dab_submodule_pop.dart';
import '../dynamic_ai/page/dy_table_pane.dart';
import '../dynamic_ai/micro/cards/dy_grid_card.dart';
import '../dynamic_ai/micro/cards/dy_list_item.dart';
import '../dynamic_ai/shells/dy_shl_details.dart';
import '../dynamic_ai/shells/dy_shl_dash.dart';
import '../dynamic_ai/shells/dy_shl_reports.dart';
import '../dynamic_ai/shells/dy_shl_tasks.dart';
import '../dynamic_ai/micro/dy_micro_button.dart';
import '../dynamic_ai/micro/table/dy_table_models.dart';
import '../dynamic_ai/root/dy_module_tabs.dart';
import 'production/purchase_orders/scr_po_landing.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  // Navigation & View Mode State
  bool _isCreating = false; // Toggles Add Cutting Card workflow
  int _contextTabIndex = 0; // Default selected: Details (0)
  String _selectedViewMode = 'table'; // Default view: table vs list
  String? _searchQuery;
  DyGridItem? _selectedCardItem;
  DynamicListItem? _selectedListItem;

  // Submodule Category Selector State
  PoSubmoduleCategory _selectedCategory = PoSubmoduleCategory.finish;
  final Map<PoSubmoduleCategory, int> _categoryCounts = {
    PoSubmoduleCategory.grey: 0,
    PoSubmoduleCategory.finish: 13,
    PoSubmoduleCategory.lace: 0,
    PoSubmoduleCategory.studio: 0,
    PoSubmoduleCategory.packing: 0,
  };

  // Base Landing Page Filter State
  String _selectedSupplier = 'All';
  String _selectedQuality = 'All';
  Set<String> _selectedStatuses = {};
  shad.CalendarValue? _selectedDateRange;
  String? _selectedDateLabel;

  final List<String> _supplierOptions = [
    'Ambaji Traders (Surat)',
    'Shree Ram Sarees (Ahm)',
    'Vrindavan Textiles (Jaipur)',
    'Rajlaxmi Fashions (Delhi)',
  ];

  final List<String> _qualityOptions = [
    'Royal Silk',
    'Chiffon Jacquard',
    'Organza Print',
    'Heavy Satin',
  ];

  // ------------------------------------------
  // ADD CUTTING CARD STATE (Form & Filters)
  // ------------------------------------------
  final TextEditingController _millController = TextEditingController();
  final TextEditingController _qualityController = TextEditingController();
  String? _selectedFormMill;
  String? _selectedFormQuality;
  String _groupByKey =
      'mill'; // Default grouping: Mill ('none', 'mill', 'qual', 'vno')

  final List<String> _millOptions = [
    'Ambaji Mills',
    'Shree Ram Processing',
    'Vrindavan Dyeing',
    'Rajlaxmi Print House',
    'Surat Textile Park',
  ];
  List<String> _filteredMillSuggestions = [];

  final List<String> _formQualityOptions = [
    'Royal Silk',
    'Chiffon Jacquard',
    'Organza Print',
    'Heavy Satin',
    'Cotton Dobby',
  ];
  List<String> _filteredQualitySuggestions = [];

  // Batch Specs Form Data
  final DateTime _cutDate = DateTime.now();
  final String _batchNo = 'CC-0042';
  double _selectedCutLength = 6.00;
  int _freshPcs = 95;
  int _secondPcs = 4;
  int _sareeWtGrams = 400;
  double _fentWtGrams = 250;

  // Selected Uncut Rolls for Batch Creation
  final Set<String> _selectedRollIds = {'roll-101', 'roll-102', 'roll-103'};
  late final List<DyTableRowData> _allUncutRolls;

  @override
  void initState() {
    super.initState();
    _initMockUncutRolls();
  }

  @override
  void dispose() {
    _millController.dispose();
    _qualityController.dispose();
    super.dispose();
  }

  void _initMockUncutRolls() {
    _allUncutRolls = [
      DyTableRowData(
        id: 'roll-101',
        voucherNo: '10481',
        partyName: 'Ambaji Mills',
        designPattern: 'D-4089 (Royal Silk)',
        quantity: '210.5 Mts',
        amount: '₹37,890',
        amountValue: 37890,
        status: 'UNCUT',
        expandedDetails:
            'Lot #10481-A • Width: 54 Inches • Weaver: Ambaji Mills • Quality: Royal Silk',
        rawData: {
          'cardNo': 'C-1001',
          'vno': '10481',
          'mill': 'Ambaji Mills',
          'qual': 'Royal Silk',
          'meters': 210.5,
          'status': 'UNCUT'
        },
      ),
      DyTableRowData(
        id: 'roll-102',
        voucherNo: '10481',
        partyName: 'Ambaji Mills',
        designPattern: 'D-4089 (Royal Silk)',
        quantity: '195.0 Mts',
        amount: '₹35,100',
        amountValue: 35100,
        status: 'UNCUT',
        expandedDetails:
            'Lot #10481-B • Width: 54 Inches • Weaver: Ambaji Mills • Quality: Royal Silk',
        rawData: {
          'cardNo': 'C-1002',
          'vno': '10481',
          'mill': 'Ambaji Mills',
          'qual': 'Royal Silk',
          'meters': 195.0,
          'status': 'UNCUT'
        },
      ),
      DyTableRowData(
        id: 'roll-103',
        voucherNo: '10481',
        partyName: 'Ambaji Mills',
        designPattern: 'D-3021 (Chiffon Jacquard)',
        quantity: '215.0 Mts',
        amount: '₹43,000',
        amountValue: 43000,
        status: 'UNCUT',
        expandedDetails:
            'Lot #10481-C • Width: 44 Inches • Weaver: Ambaji Mills • Quality: Chiffon Jacquard',
        rawData: {
          'cardNo': 'C-1003',
          'vno': '10481',
          'mill': 'Ambaji Mills',
          'qual': 'Chiffon Jacquard',
          'meters': 215.0,
          'status': 'UNCUT'
        },
      ),
    ];
  }

  void _triggerPageLoading() {
    if (mounted) {
      PageLoadingNotification(true).dispatch(context);
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        PageLoadingNotification(false).dispatch(context);
      }
    });
  }

  void _onResetFilters() {
    setState(() {
      _searchQuery = null;
      _selectedSupplier = 'All';
      _selectedQuality = 'All';
      _selectedStatuses = {};
      _selectedDateRange = null;
      _selectedDateLabel = null;
    });
  }

  void _updateMillSuggestions(String query) {
    if (query.isEmpty) {
      setState(() => _filteredMillSuggestions = []);
      return;
    }
    setState(() {
      _filteredMillSuggestions = _millOptions
          .where((m) => m.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateQualitySuggestions(String query) {
    if (query.isEmpty) {
      setState(() => _filteredQualitySuggestions = []);
      return;
    }
    setState(() {
      _filteredQualitySuggestions = _formQualityOptions
          .where((q) => q.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleSaveBatch() {
    shad.showOverlay(
      context,
      shad.PopoverConfiguration(
        alignment: Alignment.center,
        builder: (context) => shad.Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(shad.LucideIcons.check, color: Colors.green),
                const SizedBox(width: 8),
                Text('Batch $_batchNo saved successfully!'),
              ],
            ),
          ),
        ),
      ),
    );
    setState(() => _isCreating = false);
  }

  double get _totalReceivedMts {
    double total = 0.0;
    for (final roll in _allUncutRolls) {
      if (_selectedRollIds.contains(roll.id)) {
        if (roll.rawData != null && roll.rawData!['meters'] != null) {
          total += (roll.rawData!['meters'] as num).toDouble();
        }
      }
    }
    return total;
  }

  double get _freshMts => _freshPcs * _selectedCutLength;
  double get _secondMts => _secondPcs * _selectedCutLength;
  double get _fentMts => (_fentWtGrams / 1000.0) * 2.5;

  double get _freshPct => _totalReceivedMts > 0
      ? ((_freshMts / _totalReceivedMts) * 100).clamp(0, 100)
      : 0;
  double get _secondPct => _totalReceivedMts > 0
      ? ((_secondMts / _totalReceivedMts) * 100).clamp(0, 100)
      : 0;
  double get _fentPct => _totalReceivedMts > 0
      ? ((_fentMts / _totalReceivedMts) * 100).clamp(0, 100)
      : 0;
  double get _shortagePct =>
      (100 - (_freshPct + _secondPct + _fentPct)).clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    // Toggles between Base Landing Page and Add Cutting Card Workflow
    if (_isCreating) {
      return _buildAddCuttingCardView(context);
    }
    return _buildLandingView(context);
  }

  // =========================================================================
  // VIEW 1: BASE LANDING PAGE (Cutting Cards Landing View with + New Button)
  // =========================================================================
  Widget _buildLandingView(BuildContext context) {
    final theme = shad.Theme.of(context);
    // Generate standardized 25 sample dataset items shared across all 3 view modes
    final List<DyGridItem> gridItems = List.generate(25, (index) {
      final vno = 1041 + index;
      final weavers = [
        'Ambaji Silks & Textiles',
        'Vardhman Synthetics',
        'Kothari Weavers Surat',
        'Laxmi Digital Prints',
        'Shree Ram Rayon Mills',
        'Mahavir Silk Heritage',
      ];
      final designs = [
        'D-4089 Royal Silk Saree',
        'D-9012 Banarasi Zari Jaal',
        'D-1055 Organza Floral Print',
        'D-3301 Kanjivaram Border',
        'D-7740 Chanderi Tissue',
        'D-5512 Bandhani Dupatta',
      ];
      final statuses = ['UNCUT', 'IN CUTTING', 'MILL DISPATCH', 'COMPLETED'];
      final weaver = weavers[index % weavers.length];
      final design = designs[index % designs.length];
      final status = statuses[index % statuses.length];
      final qty = '${(20 + (index * 3.5)).toStringAsFixed(1)} Mts';
      final amt = '₹${(25000 + (index * 1450)).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

      return DyGridItem(
        id: 'item-$index',
        title: design,
        voucherNo: 'CC-$vno',
        partyName: weaver,
        designPattern: 'Lot #${100 + index}',
        quantity: qty,
        amount: amt,
        statusBadge: shad.OutlineBadge(child: Text(status)),
      );
    });

    final List<DynamicListItem> listItems = gridItems.map((item) {
      return DynamicListItem(
        id: item.id,
        topLeading: item.statusBadge,
        topTrailing: '28 Jul',
        title: item.partyName,
        amount: item.amount,
        subtitle: item.title,
        indexNumber: item.voucherNo,
      );
    }).toList();

    Widget activeShell;
    switch (_contextTabIndex) {
      case 0:
        activeShell = const DyShlDash(title: 'Cutting Cards Dashboard');
        break;
      case 1:
        activeShell = DyShlDetails(
          title: 'Cutting Cards',
          entityName: 'Cutting Cards',
          selectedViewMode: _selectedViewMode,
          onViewModeChanged: (val) => setState(() => _selectedViewMode = val),
          submoduleWidget: Builder(
            builder: (btnContext) {
              return MicroButton(
                leadingIcon: _selectedCategory.icon,
                label: _selectedCategory.label,
                badgeCount: _categoryCounts[_selectedCategory] ?? 0,
                trailingIcon: shad.LucideIcons.chevronDown,
                isSelected: true,
                onPressed: () {
                  shad.showOverlay(
                    btnContext,
                    shad.PopoverConfiguration(
                      anchorAlignment: Alignment.bottomLeft,
                      alignment: Alignment.topLeft,
                      offset: const Offset(0, 4),
                      builder: (context) => DabSubmodulePopover<PoSubmoduleCategory>(
                        title: 'Submodule',
                        selectedId: _selectedCategory,
                        items: PoSubmoduleCategory.values.map((cat) {
                          return DabSubmoduleItem<PoSubmoduleCategory>(
                            id: cat,
                            label: cat.label,
                            icon: cat.icon,
                            count: _categoryCounts[cat] ?? 0,
                          );
                        }).toList(),
                        onSelected: (cat) => setState(() => _selectedCategory = cat),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          searchQuery: _searchQuery,
          onSearchChanged: (val) => setState(() => _searchQuery = val),
          selectedMills: _selectedSupplier != 'All' ? {_selectedSupplier} : {},
          millOptions: _supplierOptions,
          onMillChanged: (set) => setState(
              () => _selectedSupplier = set.isNotEmpty ? set.first : 'All'),
          selectedQualities: _selectedQuality != 'All' ? {_selectedQuality} : {},
          qualityOptions: _qualityOptions,
          onQualityChanged: (set) => setState(
              () => _selectedQuality = set.isNotEmpty ? set.first : 'All'),
          selectedStatuses: _selectedStatuses,
          onStatusChanged: (statuses) => setState(() => _selectedStatuses = statuses),
          selectedDateRange: _selectedDateRange,
          selectedDateLabel: _selectedDateLabel,
          onDateRangeSelected: (range) {
            setState(() {
              _selectedDateRange = range;
              _selectedDateLabel = range != null ? 'Selected Date Range' : null;
            });
          },
          hasActiveFilters: _selectedSupplier != 'All' ||
              _selectedQuality != 'All' ||
              _selectedStatuses.isNotEmpty ||
              _selectedDateRange != null,
          onClearAllFilters: _onResetFilters,
          tableColumns: const [
            DyTableColumnSpec(key: 'vno', label: 'Voucher No', width: 110),
            DyTableColumnSpec(key: 'partyName', label: 'Party / Weaver', width: 220),
            DyTableColumnSpec(key: 'designPattern', label: 'Design & Quality', width: 200),
            DyTableColumnSpec(key: 'quantity', label: 'Quantity', width: 130),
            DyTableColumnSpec(key: 'amount', label: 'Amount', width: 140),
            DyTableColumnSpec(key: 'status', label: 'Status', width: 120, isSortable: false),
          ],
          tableRows: _allUncutRolls,
          gridItems: gridItems,
          listItems: listItems,
          selectedGridItem: _selectedCardItem,
          onGridItemSelected: (item) => setState(() => _selectedCardItem = item),
          selectedListItem: _selectedListItem,
          onListItemSelected: (item) => setState(() => _selectedListItem = item),
          totalRecords: 250,
        );
        break;
      case 2:
        activeShell = const DyShlReports(title: 'Cutting Cards Reports');
        break;
      case 3:
        activeShell = const DyShlTasks();
        break;
      default:
        activeShell = const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. TOP PAGE HEADER (Rendered directly at top of page, outside shells)
        PageHeader(
          title: 'Cutting Cards',
          mode: PageHeaderMode.standard,
          subpages: PageSubpages(
            selectedIndex: _contextTabIndex,
            onSubpageChanged: (int value) {
              _triggerPageLoading();
              setState(() => _contextTabIndex = value);
            },
          ),
          actions: [
            shad.PrimaryButton(
              onPressed: () {
                _triggerPageLoading();
                setState(() => _isCreating = true);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shad.LucideIcons.plus, size: 16 * theme.scaling),
                  const shad.DensityGap(shad.gapSm),
                  const Text('New Cutting Card'),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapLg),

        // 2. ACTIVE PAGE SHELL LAYOUT (Dash, Details, Reports, or Tasks)
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey<int>(_contextTabIndex),
              child: activeShell,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // VIEW 2: ADD CUTTING CARD WORKFLOW (STRICT FLEX 10 FORM CANVAS)
  // =========================================================================
  Widget _buildAddCuttingCardView(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final displayedRolls = _allUncutRolls.where((roll) {
      if (_selectedFormMill != null && _selectedFormMill!.isNotEmpty) {
        if ((roll.partyName ?? '').toLowerCase() != _selectedFormMill!.toLowerCase()) {
          return false;
        }
      }
      if (_selectedFormQuality != null && _selectedFormQuality!.isNotEmpty) {
        final qual = roll.rawData?['qual'] as String? ?? '';
        if (qual.toLowerCase() != _selectedFormQuality!.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();

    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.form,
      header: PageHeader(
        title: 'Cutting Card',
        mode: PageHeaderMode.adding,
        onBack: () {
          _triggerPageLoading();
          setState(() => _isCreating = false);
        },
        onDiscard: () {
          _triggerPageLoading();
          setState(() => _isCreating = false);
        },
        onSaveDraft: () {
          shad.showToast(
            context: context,
            builder: (context, overlay) => const shad.SurfaceCard(
              child: Text('Draft saved successfully!'),
            ),
          );
        },
        onConfirm: _handleSaveBatch,
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          // DYNAMIC ACTION BAR FOR ADD FLOW (Top of Pane 1)
          DynamicActionBar(
            entityName: 'Uncut Rolls',
            selectedView: _selectedViewMode,
            onViewChanged: (mode) => setState(() => _selectedViewMode = mode),
            supportedViewModes: const ['table', 'cards'],
            showSearch: false,
            showFilterButtons: false,
            showDateFilter: false,
            millAutoComplete: SizedBox(
              width: 170 * theme.scaling,
              child: shad.AutoComplete(
                suggestions: _filteredMillSuggestions,
                child: shad.TextField(
                  filled: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * theme.scaling,
                    vertical: 7 * theme.scaling,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    border: Border.all(color: colors.border),
                  ),
                  controller: _millController,
                  placeholder: const Text('Select Mill'),
                  onChanged: (val) {
                    _updateMillSuggestions(val);
                    setState(
                        () => _selectedFormMill = val.isEmpty ? null : val);
                  },
                  features: const [shad.InputFeature.clear()],
                ),
              ),
            ),
            qualityAutoComplete: SizedBox(
              width: 170 * theme.scaling,
              child: shad.AutoComplete(
                suggestions: _filteredQualitySuggestions,
                child: shad.TextField(
                  filled: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * theme.scaling,
                    vertical: 7 * theme.scaling,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    border: Border.all(color: colors.border),
                  ),
                  controller: _qualityController,
                  placeholder: const Text('Select Fabrics'),
                  onChanged: (val) {
                    _updateQualitySuggestions(val);
                    setState(
                        () => _selectedFormQuality = val.isEmpty ? null : val);
                  },
                  features: const [shad.InputFeature.clear()],
                ),
              ),
            ),
            groupingSwitcher: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Group by:',
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 8),
                shad.ButtonGroup(
                  children: [
                    _buildGroupIconButtonWithTooltip(
                        'none', 'None', shad.LucideIcons.ban),
                    _buildGroupIconButtonWithTooltip(
                        'vno', 'Date', shad.LucideIcons.calendar),
                    _buildGroupIconButtonWithTooltip(
                        'mill', 'Rate', shad.LucideIcons.tag),
                    _buildGroupIconButtonWithTooltip(
                        'qual', 'Design No', shad.LucideIcons.fileText),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapSm),

          // UNCUT ROLLS DENSE DATA TABLE WITH GROUPING (enableExpansion = false)
          Expanded(
            child: DynamicDenseTable(
              groupByKey: _groupByKey == 'none' ? null : _groupByKey,
              enableExpansion: false,
              columns: const [
                DynamicTableColumnSpec(
                    key: 'cardNo', label: 'Roll / Card No', width: 130),
                DynamicTableColumnSpec(
                    key: 'vno', label: 'Voucher No', width: 110),
                DynamicTableColumnSpec(
                    key: 'partyName', label: 'Mill / Weaver', width: 190),
                DynamicTableColumnSpec(
                    key: 'designPattern',
                    label: 'Design & Quality',
                    width: 200),
                DynamicTableColumnSpec(
                    key: 'quantity', label: 'Available Mts', width: 130),
                DynamicTableColumnSpec(
                    key: 'status', label: 'Status', width: 100),
              ],
              rows: displayedRolls.map((r) => DynamicTableRowData(
                id: r.id,
                voucherNo: r.voucherNo ?? '',
                partyName: r.partyName ?? '',
                designPattern: r.designPattern ?? '',
                quantity: r.quantity ?? '',
                amount: r.amount ?? '',
                amountValue: 0.0,
                status: r.status ?? '',
                rawData: r.rawData,
              )).toList(),
              selectedRowIds: _selectedRollIds,
              onSelectionChanged: (set) {
                setState(() {
                  _selectedRollIds.clear();
                  _selectedRollIds.addAll(set);
                });
              },
            ),
          ),
        ],
      ),
    ),
    SizedBox(width: 16 * theme.scaling),
    SizedBox(
      width: 340 * theme.scaling,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BATCH SPECS FORM CARD
          shad.Card(
            padding: EdgeInsets.all(14 * theme.scaling),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(shad.LucideIcons.scissors,
                        size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'BATCH SPECIFICATIONS',
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const shad.Divider(),
                const shad.DensityGap(shad.gapSm),
                Text('Cut Date',
                    style: theme.typography.xSmall
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                shad.TextField(
                  readOnly: true,
                  initialValue:
                      '${_cutDate.day}/${_cutDate.month}/${_cutDate.year}',
                  features: const [
                    shad.InputFeature.trailing(Icon(shad.LucideIcons.calendar))
                  ],
                ),
                const shad.DensityGap(shad.gapSm),
                Text('Batch No (Auto)',
                    style: theme.typography.xSmall
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                shad.TextField(
                  readOnly: true,
                  initialValue: '#$_batchNo',
                ),
                const shad.DensityGap(shad.gapSm),
                Text('Cut Length (Mts)',
                    style: theme.typography.xSmall
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [5.20, 5.35, 6.00, 6.25].map((len) {
                    final isSelected = len == _selectedCutLength;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: isSelected
                            ? shad.PrimaryButton(
                                density: shad.ButtonDensity.compact,
                                onPressed: () =>
                                    setState(() => _selectedCutLength = len),
                                child: Text(len.toStringAsFixed(2)),
                              )
                            : shad.OutlineButton(
                                density: shad.ButtonDensity.compact,
                                onPressed: () =>
                                    setState(() => _selectedCutLength = len),
                                child: Text(len.toStringAsFixed(2)),
                              ),
                      ),
                    );
                  }).toList(),
                ),
                const shad.DensityGap(shad.gapSm),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fresh Pcs',
                              style: theme.typography.xSmall
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          shad.TextField(
                            initialValue: '$_freshPcs',
                            onChanged: (val) {
                              final p = int.tryParse(val) ?? 0;
                              setState(() => _freshPcs = p);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Second Pcs',
                              style: theme.typography.xSmall
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          shad.TextField(
                            initialValue: '$_secondPcs',
                            onChanged: (val) {
                              final p = int.tryParse(val) ?? 0;
                              setState(() => _secondPcs = p);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapSm),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saree Wt (g)',
                              style: theme.typography.xSmall
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          shad.TextField(
                            initialValue: '$_sareeWtGrams',
                            onChanged: (val) {
                              final w = int.tryParse(val) ?? 0;
                              setState(() => _sareeWtGrams = w);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fent Wt (g)',
                              style: theme.typography.xSmall
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          shad.TextField(
                            initialValue: '${_fentWtGrams.toInt()}',
                            onChanged: (val) {
                              final w = double.tryParse(val) ?? 0;
                              setState(() => _fentWtGrams = w);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapSm),

          // LIVE PERFORMANCE RECOVERY METRICS CARD
          shad.Card(
            padding: EdgeInsets.all(14 * theme.scaling),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL RECEIVED METERS',
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalReceivedMts.toStringAsFixed(1)} Mts',
                  style: theme.typography.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _totalReceivedMts > 0
                        ? colors.primary
                        : colors.mutedForeground,
                  ),
                ),
                Text(
                  '${_selectedRollIds.length} rolls selected for cutting',
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground),
                ),
                const shad.Divider(),
                const shad.DensityGap(shad.gapSm),
                _buildRecoveryProgressBar(
                  theme,
                  colors,
                  label: 'Shortage (Input / Rec)',
                  percentage: _shortagePct,
                  color: colors.mutedForeground,
                  subtitle:
                      '${(_totalReceivedMts - (_freshMts + _secondMts + _fentMts)).clamp(0, 9999).toStringAsFixed(1)} Mts',
                ),
                _buildRecoveryProgressBar(
                  theme,
                  colors,
                  label: 'Fresh Recovery',
                  percentage: _freshPct,
                  color: colors.primary,
                  subtitle:
                      '${_freshMts.toStringAsFixed(1)} Mts ($_freshPcs Pcs)',
                ),
                _buildRecoveryProgressBar(
                  theme,
                  colors,
                  label: 'Seconds Recovery',
                  percentage: _secondPct,
                  color: colors.destructive,
                  subtitle:
                      '${_secondMts.toStringAsFixed(1)} Mts ($_secondPcs Pcs)',
                ),
                _buildRecoveryProgressBar(
                  theme,
                  colors,
                  label: 'Fents (By Weight)',
                  percentage: _fentPct,
                  color: Colors.amber,
                  subtitle:
                      '${_fentMts.toStringAsFixed(1)} Mts (${_fentWtGrams.toInt()}g)',
                ),
                const shad.DensityGap(shad.gapMd),
                SizedBox(
                  width: double.infinity,
                  child: shad.PrimaryButton(
                    onPressed:
                        _selectedRollIds.isEmpty ? null : _handleSaveBatch,
                    child: const Text('Confirm & Save Cutting Card'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
),
);
}

  Widget _buildRecoveryProgressBar(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String label,
    required double percentage,
    required Color color,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: theme.typography.xSmall
                      .copyWith(fontWeight: FontWeight.bold)),
              Text('${percentage.toStringAsFixed(1)}%',
                  style: theme.typography.xSmall
                      .copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle,
              style: theme.typography.xSmall
                  .copyWith(color: colors.mutedForeground, fontSize: 10)),
          const SizedBox(height: 4),
          shad.Progress(
            progress: (percentage / 100.0).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupIconButtonWithTooltip(
      String key, String label, IconData icon) {
    final isSelected = _groupByKey == key;
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return shad.Tooltip(
      tooltip: (context) => shad.TooltipContainer(
        child: Text('Group by $label'),
      ),
      child: shad.IconButton.outline(
        density: shad.ButtonDensity.normal,
        icon: Icon(
          icon,
          size: 16 * theme.scaling,
          color: isSelected ? colors.primary : colors.mutedForeground,
        ),
        onPressed: () => setState(() => _groupByKey = key),
      ),
    );
  }
}
