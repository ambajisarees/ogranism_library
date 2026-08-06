/*
================================================================================
LLM CONTEXT & QUERY SPACE — ITEMS MASTER LANDING SCREEN (scr_itm_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary Landing Container Screen for Items / Quality Master (`itm` / Master Layer).
   - Uses native `DyPageCanvas` 4-Shell Architecture (`DyShlDash`, `DyShlDetails`, `DyShlReports`, `DyShlTasks`).
   - Displays all 1,016 items from table `IMMBE2627.sq_QUAL` organized across 4 functional submodule barrels.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - PageHeader: Title `'Items'`, mode `PageHeaderMode.standard`, actions = const [] (zero trailing buttons for now), and `PageSubpages` context tabs (`Dash`, `Details`, `Reports`, `Tasks`).
   - Submodule Switcher Popover: `DabSubmodulePopover<ItmCategory>` (`All Items`, `Finished Sarees`, `Grey Fabrics`, `Others & Misc`).
   - DynamicActionBar (DAB): Integrated context filters for Cloth Type, Category, Unit, Search Query, Group Switcher (`none`, `clothtype`, `category`, `unit`), and View Switcher (`table`, `list`, `cards`, `board`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_QUAL` is Airbyte mirror, strictly read-only.
   - `SELL1` represents catalog selling rate.
================================================================================
*/

library;

import 'package:flutter/material.dart' hide Card;
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/micro/cards/dy_grid_card.dart';
import '../../../dynamic_ai/micro/cards/dy_list_item.dart';
import '../../../dynamic_ai/micro/dab/dab_submodule_pop.dart';
import '../../../dynamic_ai/micro/dy_micro_button.dart';
import '../../../dynamic_ai/micro/table/dy_table_models.dart';
import '../../../dynamic_ai/shells/dy_shl_dash.dart';
import '../../../dynamic_ai/shells/dy_shl_details.dart';
import '../../../dynamic_ai/shells/dy_shl_reports.dart';
import '../../../dynamic_ai/shells/dy_shl_tasks.dart';
import '../../../dynamic_ai/shells/dy_page_canvas.dart';
import '../../../dynamic_ai/root/dy_module_tabs.dart';
import '../../../models/production/items/mdl_itm.dart';
import '../../../services/production/items/srv_itm.dart';

/// [ScrItmLanding] — Main Landing Container Screen for Items Master.
class ScrItmLanding extends StatefulWidget {
  const ScrItmLanding({super.key});

  @override
  State<ScrItmLanding> createState() => _ScrItmLandingState();
}

class _ScrItmLandingState extends State<ScrItmLanding> {
  final SrvItm _itmService = SrvItm();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

  // Subpage State
  int _contextTabIndex = 1; // Default to 'Details' shell (Index 1)

  // Active Category State
  ItmCategory _selectedCategory = ItmCategory.all;

  // View Mode & Pagination State
  String _viewMode = 'table';
  int _offset = 0;
  final int _limit = 50;

  // Filter & Search State
  String? _searchQuery;
  final Set<String> _selectedClothTypes = {};
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedUnits = {};
  String _groupingMode = 'none';

  // Available Filter Options (Loaded from DB)
  List<String> _clothTypeOptions = [];
  List<String> _categoryOptions = [];
  List<String> _unitOptions = [];

  // Data Loading State
  bool _isLoading = true;
  List<MdlItmHeader> _items = [];
  MdlItmHeader? _selectedItem;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _loadFilterOptions();
    _fetchItems(resetOffset: true);
  }

  Future<void> _loadFilterOptions() async {
    try {
      final clothTypes = await _itmService.getClothTypeOptions();
      final categories = await _itmService.getCategoryOptions();
      final units = await _itmService.getUnitOptions();

      if (mounted) {
        setState(() {
          _clothTypeOptions = clothTypes;
          _categoryOptions = categories;
          _unitOptions = units;
        });
      }
    } catch (e) {
      debugPrint('Error loading filter options in ScrItmLanding: $e');
    }
  }

  Future<void> _fetchItems({bool resetOffset = false}) async {
    if (resetOffset) {
      setState(() {
        _offset = 0;
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _itmService.getItems(
        category: _selectedCategory,
        limit: _limit,
        offset: _offset,
        searchQuery: _searchQuery,
        selectedClothTypes: _selectedClothTypes,
        selectedCategories: _selectedCategories,
        selectedUnits: _selectedUnits,
      );

      if (mounted) {
        setState(() {
          _items = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
          if (_items.isNotEmpty && (_selectedItem == null || !_items.any((i) => i.qcode == _selectedItem!.qcode))) {
            _selectedItem = _items.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading items in ScrItmLanding: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCategoryChanged(ItmCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedClothTypes.clear();
      _selectedCategories.clear();
      _selectedUnits.clear();
      _selectedItem = null;
    });
    _fetchItems(resetOffset: true);
  }

  void _onClearAllFilters() {
    setState(() {
      _searchQuery = null;
      _selectedClothTypes.clear();
      _selectedCategories.clear();
      _selectedUnits.clear();
      _groupingMode = 'none';
    });
    _fetchItems(resetOffset: true);
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

  @override
  Widget build(BuildContext context) {
    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.landing,
      isLoading: _isLoading,
      header: PageHeader(
        title: 'Items',
        mode: PageHeaderMode.standard,
        actions: const [], // Zero trailing buttons for now as requested
        subpages: PageSubpages(
          selectedIndex: _contextTabIndex,
          labels: const ['Dash', 'Details', 'Reports', 'Tasks'],
          onSubpageChanged: (idx) {
            _triggerPageLoading();
            setState(() {
              _contextTabIndex = idx;
            });
          },
        ),
      ),
      subpageIndex: _contextTabIndex,
      subpageContents: [
        const DyShlDash(title: 'Items Master'),
        _buildDetailsShell(),
        const DyShlReports(title: 'Items Master'),
        const DyShlTasks(),
      ],
    );
  }

  Widget _buildDetailsShell() {
    final hasFilters = _selectedClothTypes.isNotEmpty ||
        _selectedCategories.isNotEmpty ||
        _selectedUnits.isNotEmpty ||
        (_searchQuery != null && _searchQuery!.isNotEmpty);

    return DyShlDetails(
      title: 'Items Master',
      entityName: 'Items',
      moduleName: 'items',
      selectedViewMode: _viewMode,
      onViewModeChanged: (mode) {
        setState(() {
          _viewMode = mode;
        });
      },
      submoduleWidget: Builder(
        builder: (btnContext) {
          return MicroButton(
            leadingIcon: _selectedCategory.icon,
            label: _selectedCategory.displayName,
            badgeCount: _totalCount,
            trailingIcon: shad.LucideIcons.chevronDown,
            isSelected: true,
            onPressed: () {
              shad.showOverlay(
                btnContext,
                shad.PopoverConfiguration(
                  anchorAlignment: Alignment.bottomLeft,
                  alignment: Alignment.topLeft,
                  offset: const Offset(0, 4),
                  builder: (popContext) => DabSubmodulePopover<ItmCategory>(
                    title: 'Item Barrel',
                    selectedId: _selectedCategory,
                    items: ItmCategory.values
                        .map(
                          (c) => DabSubmoduleItem<ItmCategory>(
                            id: c,
                            label: c.displayName,
                            icon: c.icon,
                            count: c == _selectedCategory ? _totalCount : 0,
                          ),
                        )
                        .toList(),
                    onSelected: _onCategoryChanged,
                  ),
                ),
              );
            },
          );
        },
      ),
      searchQuery: _searchQuery,
      onSearchChanged: (val) {
        _searchQuery = val?.trim();
        _fetchItems(resetOffset: true);
      },
      autoCompleteWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_clothTypeOptions.isNotEmpty)
            _buildMultiSelectFilterButton(
              context,
              label: 'Cloth Type',
              options: _clothTypeOptions,
              selected: _selectedClothTypes,
              onChanged: (updated) {
                setState(() {
                  _selectedClothTypes.clear();
                  _selectedClothTypes.addAll(updated);
                });
                _fetchItems(resetOffset: true);
              },
            ),
          if (_categoryOptions.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildMultiSelectFilterButton(
              context,
              label: 'Collection',
              options: _categoryOptions,
              selected: _selectedCategories,
              onChanged: (updated) {
                setState(() {
                  _selectedCategories.clear();
                  _selectedCategories.addAll(updated);
                });
                _fetchItems(resetOffset: true);
              },
            ),
          ],
          if (_unitOptions.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildMultiSelectFilterButton(
              context,
              label: 'Unit',
              options: _unitOptions,
              selected: _selectedUnits,
              onChanged: (updated) {
                setState(() {
                  _selectedUnits.clear();
                  _selectedUnits.addAll(updated);
                });
                _fetchItems(resetOffset: true);
              },
            ),
          ],
        ],
      ),
      hasActiveFilters: hasFilters,
      onClearAllFilters: _onClearAllFilters,
      selectedGroup: _groupingMode,
      onGroupChanged: (g) {
        setState(() {
          _groupingMode = g;
        });
      },
      groupOptions: const [
        DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
        DabGroupOption(id: 'clothtype', label: 'Cloth Type', icon: shad.LucideIcons.layers),
        DabGroupOption(id: 'category', label: 'Collection', icon: shad.LucideIcons.folder),
        DabGroupOption(id: 'unit', label: 'Unit', icon: shad.LucideIcons.scale),
      ],
      isLoading: _isLoading,
      tableColumns: _itmTableColumns,
      tableRows: _buildMappedTableRows(),
      gridItems: _buildMappedGridItems(),
      listItems: _buildMappedListItems(),
      selectedListItem: _selectedItem != null ? _mapHeaderToListItem(_selectedItem!) : null,
      selectedGridItem: _selectedItem != null ? _mapHeaderToGridItem(_selectedItem!) : null,
      onListItemSelected: (item) {
        if (item == null) return;
        final itm = _items.firstWhere(
          (i) => i.qcode == item.id,
          orElse: () => _items.first,
        );
        setState(() {
          _selectedItem = itm;
        });
      },
      onGridItemSelected: (item) {
        if (item == null) return;
        final itm = _items.firstWhere(
          (i) => i.qcode == item.id,
          orElse: () => _items.first,
        );
        setState(() {
          _selectedItem = itm;
        });
      },
      summaryTotals: _buildSummaryTotals(),
      totalRecords: _totalCount,
      pageIndex: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchItems(resetOffset: false);
      },
    );
  }

  static const List<DyTableColumnSpec> _itmTableColumns = [
    DyTableColumnSpec(key: 'vno', label: 'ITEM CODE', width: 140, isPinnedLeft: true),
    DyTableColumnSpec(key: 'partyName', label: 'ITEM NAME', flex: 3),
    DyTableColumnSpec(key: 'clothtype', label: 'CLOTH TYPE', flex: 2),
    DyTableColumnSpec(key: 'category', label: 'COLLECTION', flex: 2),
    DyTableColumnSpec(key: 'unit', label: 'UNIT', width: 90, textAlignment: Alignment.center),
    DyTableColumnSpec(key: 'hsn', label: 'HSN', width: 100),
    DyTableColumnSpec(key: 'cut', label: 'STD CUT', width: 100, isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'amount', label: 'SELL PRICE', isNumeric: true, textAlignment: Alignment.centerRight),
    DyTableColumnSpec(key: 'status', label: 'STATUS', width: 100),
  ];

  List<DynamicListItem> _buildMappedListItems() {
    return _items.map((i) => _mapHeaderToListItem(i)).toList();
  }

  DynamicListItem _mapHeaderToListItem(MdlItmHeader i) {
    return DynamicListItem(
      id: i.qcode,
      title: i.name,
      subtitle: i.category.isNotEmpty ? '${i.category} • ${i.clothType}' : i.clothType,
      indexNumber: i.qcode,
      amount: i.formattedSellPrice(_currencyFormat),
      topTrailing: i.unit,
      topLeading: i.isGreyFabric
          ? const shad.OutlineBadge(child: Text('GREY'))
          : const shad.PrimaryBadge(child: Text('ACTIVE')),
    );
  }

  List<DyGridItem> _buildMappedGridItems() {
    return _items.map((i) => _mapHeaderToGridItem(i)).toList();
  }

  DyGridItem _mapHeaderToGridItem(MdlItmHeader i) {
    return DyGridItem(
      id: i.qcode,
      title: i.name,
      voucherNo: i.qcode,
      partyName: i.name,
      designPattern: i.category.isNotEmpty ? i.category : i.clothType,
      quantity: i.cutLength > 0 ? '${i.cutLength.toStringAsFixed(2)} Mtr' : i.unit,
      amount: i.formattedSellPrice(_currencyFormat),
      statusBadge: i.isGreyFabric
          ? const shad.OutlineBadge(child: Text('GREY'))
          : const shad.PrimaryBadge(child: Text('ACTIVE')),
    );
  }

  Map<String, String> _buildSummaryTotals() {
    double totalSell = 0;
    int countPriced = 0;
    for (final i in _items) {
      if (i.sellPrice > 0) {
        totalSell += i.sellPrice;
        countPriced++;
      }
    }
    return {
      'designPattern': 'TOTALS',
      'unit': '${_items.length} Items',
      'amount': countPriced > 0 ? 'Avg: ₹${(totalSell / countPriced).toStringAsFixed(2)}' : '-',
    };
  }

  List<DyTableRowData> _buildMappedTableRows() {
    if (_groupingMode == 'none') {
      return _items.map((i) => i.toDyDefRowData(_currencyFormat)).toList();
    }

    final Map<String, List<MdlItmHeader>> groupedMap = {};
    for (final item in _items) {
      final groupKey = _groupingMode == 'clothtype'
          ? (item.clothType.isNotEmpty ? item.clothType : 'Other')
          : (_groupingMode == 'category'
              ? (item.category.isNotEmpty ? item.category : 'Unassigned')
              : (item.unit.isNotEmpty ? item.unit : 'Standard'));
      groupedMap.putIfAbsent(groupKey, () => []).add(item);
    }

    final result = <DyTableRowData>[];
    groupedMap.forEach((groupName, groupItems) {
      final childDefRows = groupItems.map((i) => i.toDyDefRowData(_currencyFormat)).toList();

      result.add(
        DyTableRowData(
          id: 'group_$groupName',
          rowType: DyTableRowType.group,
          partyName: groupName,
          title: '$groupName (${groupItems.length} Items)',
          data: {
            'vno': '$groupName (${groupItems.length} Items)',
            'partyName': groupName,
            'unit': '${groupItems.length} Items',
          },
          children: childDefRows,
        ),
      );
    });

    return result;
  }

  Widget _buildMultiSelectFilterButton(
    BuildContext context, {
    required String label,
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<Set<String>> onChanged,
  }) {
    final hasSelection = selected.isNotEmpty;

    return MicroButton(
      leadingIcon: shad.LucideIcons.filter,
      label: hasSelection ? '$label (${selected.length})' : label,
      badgeCount: hasSelection ? selected.length : null,
      isSelected: hasSelection,
      onPressed: () {
        shad.showOverlay(
          context,
          shad.PopoverConfiguration(
            alignment: Alignment.topLeft,
            anchorAlignment: Alignment.bottomLeft,
            offset: const Offset(0, 4),
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setPopoverState) {
                  final theme = shad.Theme.of(context);
                  final colors = theme.colorScheme;

                  return shad.Card(
                    padding: EdgeInsets.all(8 * theme.scaling),
                    child: SizedBox(
                      width: 220 * theme.scaling,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter by $label',
                                style: theme.typography.textSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.foreground,
                                ),
                              ),
                              if (selected.isNotEmpty)
                                shad.GhostButton(
                                  density: shad.ButtonDensity.compact,
                                  onPressed: () {
                                    setPopoverState(() => selected.clear());
                                    onChanged(selected);
                                  },
                                  child: Text(
                                    'Clear',
                                    style: theme.typography.xSmall.copyWith(color: colors.primary),
                                  ),
                                ),
                            ],
                          ),
                          const shad.DensityGap(shad.gapSm),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 240 * theme.scaling),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final opt = options[index];
                                final isChecked = selected.contains(opt);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: shad.Checkbox(
                                    state: isChecked ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
                                    onChanged: (state) {
                                      setPopoverState(() {
                                        if (state == shad.CheckboxState.checked) {
                                          selected.add(opt);
                                        } else {
                                          selected.remove(opt);
                                        }
                                      });
                                      onChanged(selected);
                                    },
                                    trailing: Text(
                                      opt,
                                      style: theme.typography.textSmall,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
