/*
================================================================================
LLM CONTEXT & QUERY SPACE — ORGANIZATIONS MASTER LANDING SCREEN (scr_org_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary Landing Container Screen for Organizations / Party Master (`org` / Master Layer).
   - Uses native `DyPageCanvas` 4-Shell Architecture (`DyShlDash`, `DyShlDetails`, `DyShlReports`, `DyShlTasks`).
   - Displays all 5,502 party ledgers from table `IMMBE2627.sq_MASTER` organized across 6 functional ATYPE submodule barrels.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - PageHeader: Title `'Organizations'`, mode `PageHeaderMode.standard`, actions = const [] (zero trailing buttons), and `PageSubpages` context tabs (`Dash`, `Details`, `Reports`, `Tasks`).
   - Submodule Switcher Popover: `DabSubmodulePopover<OrgCategory>` (`All Orgs`, `Customers`, `Grey Suppliers`, `Job Workers & Mills`, `Brokers & Agents`, `Others & Expenses`).
   - DynamicActionBar (DAB): Integrated context filters for City, Broker, Search Query, Group Switcher (`none`, `atype`, `city`, `broker`), and View Switcher (`table`, `list`, `cards`, `board`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_MASTER` is Airbyte mirror, strictly read-only.
   - `MOBILE` is used for WhatsApp/SMS dispatch notifications.
================================================================================
*/

library;

import 'package:flutter/material.dart' hide Card;
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
import '../../../models/production/orgs/mdl_org.dart';
import '../../../services/production/orgs/srv_org.dart';

/// [ScrOrgLanding] — Main Landing Container Screen for Organizations Master.
class ScrOrgLanding extends StatefulWidget {
  const ScrOrgLanding({super.key});

  @override
  State<ScrOrgLanding> createState() => _ScrOrgLandingState();
}

class _ScrOrgLandingState extends State<ScrOrgLanding> {
  final SrvOrg _orgService = SrvOrg();

  // Subpage State
  int _contextTabIndex = 1; // Default to 'Details' shell (Index 1)

  // Active Category State
  OrgCategory _selectedCategory = OrgCategory.all;

  // View Mode & Pagination State
  String _viewMode = 'table';
  int _offset = 0;
  final int _limit = 50;

  // Filter & Search State
  String? _searchQuery;
  final Set<String> _selectedCities = {};
  final Set<String> _selectedBrokers = {};
  String _groupingMode = 'none';

  // Available Filter Options (Loaded from DB)
  List<String> _cityOptions = [];
  List<String> _brokerOptions = [];

  // Data Loading State
  bool _isLoading = true;
  List<MdlOrgHeader> _orgs = [];
  MdlOrgHeader? _selectedOrg;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _loadFilterOptions();
    _fetchOrgs(resetOffset: true);
  }

  Future<void> _loadFilterOptions() async {
    try {
      final cities = await _orgService.getCityOptions();
      final brokers = await _orgService.getBrokerOptions();

      if (mounted) {
        setState(() {
          _cityOptions = cities;
          _brokerOptions = brokers;
        });
      }
    } catch (e) {
      debugPrint('Error loading filter options in ScrOrgLanding: $e');
    }
  }

  Future<void> _fetchOrgs({bool resetOffset = false}) async {
    if (resetOffset) {
      setState(() {
        _offset = 0;
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _orgService.getOrganizations(
        category: _selectedCategory,
        limit: _limit,
        offset: _offset,
        searchQuery: _searchQuery,
        selectedCities: _selectedCities,
        selectedBrokers: _selectedBrokers,
      );

      if (mounted) {
        setState(() {
          _orgs = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
          if (_orgs.isNotEmpty && (_selectedOrg == null || !_orgs.any((o) => o.code == _selectedOrg!.code))) {
            _selectedOrg = _orgs.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading orgs in ScrOrgLanding: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCategoryChanged(OrgCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedCities.clear();
      _selectedBrokers.clear();
      _selectedOrg = null;
    });
    _fetchOrgs(resetOffset: true);
  }

  void _onClearAllFilters() {
    setState(() {
      _searchQuery = null;
      _selectedCities.clear();
      _selectedBrokers.clear();
      _groupingMode = 'none';
    });
    _fetchOrgs(resetOffset: true);
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
        title: 'Organizations',
        mode: PageHeaderMode.standard,
        actions: const [], // Zero trailing buttons as requested
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
        const DyShlDash(title: 'Organizations Master'),
        _buildDetailsShell(),
        const DyShlReports(title: 'Organizations Master'),
        const DyShlTasks(),
      ],
    );
  }

  Widget _buildDetailsShell() {
    final hasFilters = _selectedCities.isNotEmpty ||
        _selectedBrokers.isNotEmpty ||
        (_searchQuery != null && _searchQuery!.isNotEmpty);

    return DyShlDetails(
      title: 'Organizations Master',
      entityName: 'Orgs',
      moduleName: 'orgs',
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
                  builder: (popContext) => DabSubmodulePopover<OrgCategory>(
                    title: 'Org Silo Barrel',
                    selectedId: _selectedCategory,
                    items: OrgCategory.values
                        .map(
                          (c) => DabSubmoduleItem<OrgCategory>(
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
        _fetchOrgs(resetOffset: true);
      },
      autoCompleteWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_cityOptions.isNotEmpty)
            _buildMultiSelectFilterButton(
              context,
              label: 'City',
              options: _cityOptions,
              selected: _selectedCities,
              onChanged: (updated) {
                setState(() {
                  _selectedCities.clear();
                  _selectedCities.addAll(updated);
                });
                _fetchOrgs(resetOffset: true);
              },
            ),
          if (_brokerOptions.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildMultiSelectFilterButton(
              context,
              label: 'Broker',
              options: _brokerOptions,
              selected: _selectedBrokers,
              onChanged: (updated) {
                setState(() {
                  _selectedBrokers.clear();
                  _selectedBrokers.addAll(updated);
                });
                _fetchOrgs(resetOffset: true);
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
        DabGroupOption(id: 'atype', label: 'Account Type', icon: shad.LucideIcons.layers),
        DabGroupOption(id: 'city', label: 'City', icon: shad.LucideIcons.mapPin),
        DabGroupOption(id: 'broker', label: 'Broker', icon: shad.LucideIcons.userCheck),
      ],
      isLoading: _isLoading,
      tableColumns: _orgTableColumns,
      tableRows: _buildMappedTableRows(),
      gridItems: _buildMappedGridItems(),
      listItems: _buildMappedListItems(),
      selectedListItem: _selectedOrg != null ? _mapHeaderToListItem(_selectedOrg!) : null,
      selectedGridItem: _selectedOrg != null ? _mapHeaderToGridItem(_selectedOrg!) : null,
      onListItemSelected: (item) {
        if (item == null) return;
        final org = _orgs.firstWhere(
          (o) => o.code == item.id,
          orElse: () => _orgs.first,
        );
        setState(() {
          _selectedOrg = org;
        });
      },
      onGridItemSelected: (item) {
        if (item == null) return;
        final org = _orgs.firstWhere(
          (o) => o.code == item.id,
          orElse: () => _orgs.first,
        );
        setState(() {
          _selectedOrg = org;
        });
      },
      summaryTotals: _buildSummaryTotals(),
      totalRecords: _totalCount,
      pageIndex: (_offset ~/ _limit) + 1,
      onPageChanged: (page) {
        setState(() {
          _offset = (page - 1) * _limit;
        });
        _fetchOrgs(resetOffset: false);
      },
    );
  }

  static const List<DyTableColumnSpec> _orgTableColumns = [
    DyTableColumnSpec(key: 'vno', label: 'CODE', width: 110, isPinnedLeft: true),
    DyTableColumnSpec(key: 'partyName', label: 'LEGAL PARTY NAME', flex: 3),
    DyTableColumnSpec(key: 'atype', label: 'ACCOUNT TYPE', flex: 2),
    DyTableColumnSpec(key: 'city', label: 'CITY', flex: 2),
    DyTableColumnSpec(key: 'station', label: 'STATION HUB', flex: 2),
    DyTableColumnSpec(key: 'broker', label: 'BROKER / AGENT', flex: 2),
    DyTableColumnSpec(key: 'gstin', label: 'GSTIN', width: 160),
    DyTableColumnSpec(key: 'mobile', label: 'MOBILE / WHATSAPP', width: 130),
    DyTableColumnSpec(key: 'status', label: 'STATUS', width: 90),
  ];

  List<DynamicListItem> _buildMappedListItems() {
    return _orgs.map((o) => _mapHeaderToListItem(o)).toList();
  }

  DynamicListItem _mapHeaderToListItem(MdlOrgHeader o) {
    return DynamicListItem(
      id: o.code,
      title: o.name,
      subtitle: '${o.atypeDescription} • ${o.city.isNotEmpty ? o.city : 'Local'}',
      indexNumber: o.code,
      amount: o.mobile.isNotEmpty ? o.mobile : '-',
      topTrailing: o.broker,
      topLeading: o.gstin.isNotEmpty
          ? const shad.PrimaryBadge(child: Text('GST'))
          : const shad.OutlineBadge(child: Text('NON-GST')),
    );
  }

  List<DyGridItem> _buildMappedGridItems() {
    return _orgs.map((o) => _mapHeaderToGridItem(o)).toList();
  }

  DyGridItem _mapHeaderToGridItem(MdlOrgHeader o) {
    return DyGridItem(
      id: o.code,
      title: o.name,
      voucherNo: o.code,
      partyName: o.name,
      designPattern: o.atypeDescription,
      quantity: o.city.isNotEmpty ? o.city : 'Local',
      amount: o.mobile.isNotEmpty ? o.mobile : '-',
      statusBadge: o.gstin.isNotEmpty
          ? const shad.PrimaryBadge(child: Text('GST'))
          : const shad.OutlineBadge(child: Text('NON-GST')),
    );
  }

  Map<String, String> _buildSummaryTotals() {
    int countGst = 0;
    int countMobile = 0;
    for (final o in _orgs) {
      if (o.gstin.isNotEmpty) countGst++;
      if (o.mobile.isNotEmpty) countMobile++;
    }
    return {
      'designPattern': 'TOTALS',
      'city': '${_orgs.length} Orgs',
      'gstin': '$countGst GST Registered',
      'mobile': '$countMobile Contacts',
    };
  }

  List<DyTableRowData> _buildMappedTableRows() {
    if (_groupingMode == 'none') {
      return _orgs.map((o) => o.toDyDefRowData()).toList();
    }

    final Map<String, List<MdlOrgHeader>> groupedMap = {};
    for (final org in _orgs) {
      final groupKey = _groupingMode == 'atype'
          ? org.atypeDescription
          : (_groupingMode == 'city'
              ? (org.city.isNotEmpty ? org.city : 'Other City')
              : (org.broker.isNotEmpty ? org.broker : 'SELF'));
      groupedMap.putIfAbsent(groupKey, () => []).add(org);
    }

    final result = <DyTableRowData>[];
    groupedMap.forEach((groupName, groupOrgs) {
      final childDefRows = groupOrgs.map((o) => o.toDyDefRowData()).toList();

      result.add(
        DyTableRowData(
          id: 'group_$groupName',
          rowType: DyTableRowType.group,
          partyName: groupName,
          title: '$groupName (${groupOrgs.length} Orgs)',
          data: {
            'vno': '$groupName (${groupOrgs.length} Orgs)',
            'partyName': groupName,
            'city': '${groupOrgs.length} Orgs',
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
