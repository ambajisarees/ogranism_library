import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../dynamic_ai/components/page_level/page_form_canvas.dart';
import '../dynamic_ai/components/page_level/page_header.dart';
import '../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../dynamic_ai/components/page_level/dab_widgets/dab_submodule_popover.dart';
import '../dynamic_ai/components/page_level/dynamic_dense_table.dart';
import '../dynamic_ai/components/page_level/dynamic_list.dart';
import '../dynamic_ai/components/page_level/dynamic_list_card.dart';
import '../dynamic_ai/components/page_level/dynamic_content_pane.dart';
import '../dynamic_ai/components/micro_level/micro_button.dart';
import '../dynamic_ai/components/root_level/header_tabs.dart';
import 'production/purchase_orders/scr_po_landing.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  // Navigation & View Mode State
  bool _isCreating = false; // Toggles Add Cutting Card workflow
  int _contextTabIndex = 1; // Default selected: Details (1)
  String _selectedViewMode = 'table'; // Default view: table vs list
  String? _searchQuery;

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
  late final List<DynamicTableRowData> _allUncutRolls;

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
      DynamicTableRowData(
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
      DynamicTableRowData(
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
      DynamicTableRowData(
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
      DynamicTableRowData(
        id: 'roll-104',
        voucherNo: '10482',
        partyName: 'Shree Ram Processing',
        designPattern: 'D-3021 (Chiffon Jacquard)',
        quantity: '180.0 Mts',
        amount: '₹36,000',
        amountValue: 36000,
        status: 'UNCUT',
        expandedDetails:
            'Lot #10482-A • Width: 44 Inches • Weaver: Shree Ram Processing • Quality: Chiffon Jacquard',
        rawData: {
          'cardNo': 'C-1004',
          'vno': '10482',
          'mill': 'Shree Ram Processing',
          'qual': 'Chiffon Jacquard',
          'meters': 180.0,
          'status': 'UNCUT'
        },
      ),
      DynamicTableRowData(
        id: 'roll-105',
        voucherNo: '10482',
        partyName: 'Shree Ram Processing',
        designPattern: 'D-5100 (Organza Print)',
        quantity: '240.0 Mts',
        amount: '₹51,000',
        amountValue: 51000,
        status: 'UNCUT',
        expandedDetails:
            'Lot #10482-B • Width: 54 Inches • Weaver: Shree Ram Processing • Quality: Organza Print',
        rawData: {
          'cardNo': 'C-1005',
          'vno': '10482',
          'mill': 'Shree Ram Processing',
          'qual': 'Organza Print',
          'meters': 240.0,
          'status': 'UNCUT'
        },
      ),
      DynamicTableRowData(
        id: 'roll-106',
        voucherNo: '10483',
        partyName: 'Vrindavan Dyeing',
        designPattern: 'D-5100 (Organza Print)',
        quantity: '220.0 Mts',
        amount: '₹46,750',
        amountValue: 46750,
        status: 'UNCUT',
        expandedDetails:
            'Lot #10483-A • Width: 54 Inches • Weaver: Vrindavan Dyeing • Quality: Organza Print',
        rawData: {
          'cardNo': 'C-1006',
          'vno': '10483',
          'mill': 'Vrindavan Dyeing',
          'qual': 'Organza Print',
          'meters': 220.0,
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
    final colors = theme.colorScheme;

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. PAGE HEADER (Title: Cutting Cards + Primary Add Button)
          PageHeader(
            title: 'Cutting Cards',
            mode: PageHeaderMode.standard,
            actions: [
              shad.PrimaryButton(
                onPressed: () => setState(() => _isCreating = true),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(shad.LucideIcons.plus, size: 16),
                    SizedBox(width: 6),
                    Text('New Cutting Card'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapMd),

          // 2. CONTEXT TABS (Dashboard, Details, Tasks)
          Row(
            children: [
              shad.Tabs(
                index: _contextTabIndex,
                onChanged: (int value) {
                  _triggerPageLoading();
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
                            color: colors.destructive,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const shad.DensityGap(shad.gapSm),

          // 3. DYNAMIC ACTION BAR (DAB) WITH SUBMODULE SELECTOR AT INDEX 1
          DynamicActionBar(
            entityName: 'Cutting Cards',
            selectedView: _selectedViewMode,
            onViewChanged: (val) => setState(() => _selectedViewMode = val),
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
                        builder: (context) =>
                            DabSubmodulePopover<PoSubmoduleCategory>(
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
                          onSelected: (cat) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            selectedMills:
                _selectedSupplier != 'All' ? {_selectedSupplier} : {},
            millOptions: _supplierOptions,
            onMillChanged: (set) => setState(
                () => _selectedSupplier = set.isNotEmpty ? set.first : 'All'),
            selectedQualities:
                _selectedQuality != 'All' ? {_selectedQuality} : {},
            qualityOptions: _qualityOptions,
            onQualityChanged: (set) => setState(
                () => _selectedQuality = set.isNotEmpty ? set.first : 'All'),
            selectedStatuses: _selectedStatuses,
            onStatusChanged: (statuses) =>
                setState(() => _selectedStatuses = statuses),
            selectedDateRange: _selectedDateRange,
            selectedDateLabel: _selectedDateLabel,
            onDateRangeSelected: (range) {
              setState(() {
                _selectedDateRange = range;
                _selectedDateLabel =
                    range != null ? 'Selected Date Range' : null;
              });
            },
            hasActiveFilters: _selectedSupplier != 'All' ||
                _selectedQuality != 'All' ||
                _selectedStatuses.isNotEmpty ||
                _selectedDateRange != null,
            onClearAllFilters: _onResetFilters,
          ),
          const shad.DensityGap(shad.gapSm),

          // 4. CONTENT VIEW COMPUTATION (Table vs Split View)
          Expanded(
            child: () {
              switch (_contextTabIndex) {
                case 0:
                  return Center(
                    child: Text(
                      'Cutting Cards Dashboard (Analytics & Insights)',
                      style: theme.typography.h3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  );
                case 1:
                  return _selectedViewMode == 'table'
                      ? _buildLandingTable(theme)
                      : _buildLandingSplitView(theme);
                case 2:
                  return Center(
                    child: Text(
                      'Tasks Placeholder',
                      style: theme.typography.h3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildLandingTable(shad.ThemeData theme) {
    const columns = [
      DynamicTableColumnSpec(key: 'vno', label: 'Voucher No', width: 110),
      DynamicTableColumnSpec(
          key: 'partyName', label: 'Party / Weaver', width: 220),
      DynamicTableColumnSpec(
          key: 'designPattern', label: 'Design & Quality', width: 200),
      DynamicTableColumnSpec(key: 'quantity', label: 'Quantity', width: 130),
      DynamicTableColumnSpec(key: 'amount', label: 'Amount', width: 140),
      DynamicTableColumnSpec(key: 'status', label: 'Status', width: 120),
    ];

    return DynamicDenseTable(
      columns: columns,
      rows: _allUncutRolls,
      enableExpansion: true,
    );
  }

  Widget _buildLandingSplitView(shad.ThemeData theme) {
    final listItems = _allUncutRolls.map((roll) {
      return DynamicListItem(
        id: roll.id,
        topLeading: const shad.OutlineBadge(child: Text('Uncut')),
        topTrailing: '28 Jul',
        title: roll.partyName,
        amount: roll.amount,
        subtitle: roll.designPattern,
        indexNumber: roll.voucherNo,
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DynamicList(
          items: listItems,
          selectedItem: listItems.first,
          onItemSelected: (selected) {},
          width: 340,
          showHeader: false,
        ),
        const SizedBox(width: 12),
        DynamicContentPane(
          title: 'Batch #CC-0041 Details',
          statusBadge: const shad.OutlineBadge(child: Text('UNCUT')),
          primaryAction: shad.PrimaryButton(
            size: shad.ButtonSize.small,
            onPressed: () => setState(() => _isCreating = true),
            child: const Text('Edit Card'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Uncut Roll Item Details',
                  style: theme.typography.h4
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Select a roll card from the left panel to inspect details.',
                  style: theme.typography.textMuted),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // VIEW 2: ADD CUTTING CARD WORKFLOW (MAXWIDTH: 1200px CENTERED)
  // =========================================================================
  Widget _buildAddCuttingCardView(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final displayedRolls = _allUncutRolls.where((roll) {
      if (_selectedFormMill != null && _selectedFormMill!.isNotEmpty) {
        if (roll.partyName.toLowerCase() != _selectedFormMill!.toLowerCase()) {
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

    return PageFormCanvas(
      maxWidth: 1400.0,
      sidePaneWidth: 340.0,
      header: PageHeader(
        title: 'Cutting Card',
        mode: PageHeaderMode.adding,
        onBack: () => setState(() => _isCreating = false),
        onDiscard: () => setState(() => _isCreating = false),
        onConfirm: _handleSaveBatch,
      ),
      mainPane: Column(
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
              rows: displayedRolls,
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
      sidePane: Column(
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
