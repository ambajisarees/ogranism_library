/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC DETAILS PAGE SHELL (dy_shl_details.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Master details page shell orchestrator for all ERP module landing screens.
   - Framing PageHeader (PH) -> gapLg (16px) -> DynamicActionBar (DAB) -> gapLg (16px) -> View Router.
   - Manages 3 confirmed view modes (`table`, `list`, `cards`) + `board` placeholder.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Enforces exact flex splits for split-view modes:
     - List View: `flex: 2 : 6` (25% DynamicList / 75% DyDetailsPane)
     - Cards View: `flex: 6 : 2` (75% DyViewCard / 25% DyDetailsPane)
   - Encapsulates `AnimatedSwitcher` (150ms Fade) for zero-shift view mode switching.
   - Uses native `shadcn_flutter` color, density, and typography tokens strictly.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../specs/dy_grid_system.dart';
import '../page/dy_page_header.dart';
import '../page/dy_action_bar.dart';
import '../page/dy_table.dart';
import '../page/dy_list_pane.dart';
import '../page/dy_card_pane.dart';
import '../page/dy_kanban_pane.dart';
import '../page/dy_details_pane.dart';
import '../micro/cards/dy_grid_card.dart';
import '../micro/dab/dab_group_switcher.dart';
export '../micro/dab/dab_group_switcher.dart';
import '../micro/cards/dy_list_item.dart';
import '../micro/cards/dy_kanban_item.dart';
import '../specs/dy_color_system.dart';

/// [DyShlDetails] — Master Details Page Shell framing PH -> 16px -> DAB -> 16px -> View Router.
class DyShlDetails extends StatefulWidget {
  // 1. PageHeader Props
  final String title;
  final PageHeaderMode headerMode;
  final Widget? pageTabs;
  final List<Widget> headerActions;
  final String? docId;
  final String? moduleName;

  // 2. DynamicActionBar (DAB) Props
  final String entityName;
  final String selectedViewMode;
  final ValueChanged<String> onViewModeChanged;
  final Widget? submoduleWidget;
  final String? searchQuery;
  final ValueChanged<String?>? onSearchChanged;
  final Set<String> selectedParties;
  final List<String> partyOptions;
  final ValueChanged<Set<String>>? onPartyChanged;
  final Set<String> selectedMills;
  final List<String> millOptions;
  final ValueChanged<Set<String>>? onMillChanged;
  final Set<String> selectedQualities;
  final List<String> qualityOptions;
  final ValueChanged<Set<String>>? onQualityChanged;
  final Set<String> selectedStatuses;
  final ValueChanged<Set<String>>? onStatusChanged;
  final bool showRangeFilter;
  final shad.CalendarValue? selectedDateRange;
  final String? selectedDateLabel;
  final ValueChanged<shad.CalendarValue?>? onDateRangeSelected;
  final bool hasActiveFilters;
  final VoidCallback? onClearAllFilters;
  final String selectedGroup;
  final ValueChanged<String>? onGroupChanged;
  final List<DabGroupOption> groupOptions;
  final Widget? autoCompleteWidget;

  // 3. View Data & Content Props
  final List<DyTableColumnSpec> tableColumns;
  final List<DyTableRowData> tableRows;
  final List<DyGridItem> gridItems;
  final List<DynamicListItem> listItems;
  final DyGridItem? selectedGridItem;
  final ValueChanged<DyGridItem?>? onGridItemSelected;
  final DynamicListItem? selectedListItem;
  final ValueChanged<DynamicListItem?>? onListItemSelected;
  final bool isLoading;
  final int? totalRecords;
  final int pageIndex;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<DyTableRowData>? onEditRow;
  final Map<String, String>? summaryTotals;

  const DyShlDetails({
    super.key,
    required this.title,
    this.headerMode = PageHeaderMode.standard,
    this.pageTabs,
    this.headerActions = const [],
    this.docId,
    this.moduleName,
    required this.entityName,
    required this.selectedViewMode,
    required this.onViewModeChanged,
    this.submoduleWidget,
    this.autoCompleteWidget,
    this.searchQuery,
    this.onSearchChanged,
    this.selectedParties = const {},
    this.partyOptions = const [],
    this.onPartyChanged,
    this.selectedMills = const {},
    this.millOptions = const [],
    this.onMillChanged,
    this.selectedQualities = const {},
    this.qualityOptions = const [],
    this.onQualityChanged,
    this.selectedStatuses = const {},
    this.onStatusChanged,
    this.showRangeFilter = false,
    this.selectedDateRange,
    this.selectedDateLabel,
    this.onDateRangeSelected,
    this.hasActiveFilters = false,
    this.onClearAllFilters,
    this.selectedGroup = 'none',
    this.onGroupChanged,
    this.groupOptions = kDefaultGroupOptions,
    this.tableColumns = const [],
    this.tableRows = const [],
    this.gridItems = const [],
    this.listItems = const [],
    this.selectedGridItem,
    this.onGridItemSelected,
    this.selectedListItem,
    this.onListItemSelected,
    this.isLoading = false,
    this.totalRecords,
    this.pageIndex = 1,
    this.onPageChanged,
    this.onEditRow,
    this.summaryTotals,
  });

  @override
  State<DyShlDetails> createState() => _DyShlDetailsState();
}

class _DyShlDetailsState extends State<DyShlDetails> {
  DynamicListItem? _internalSelectedListItem;
  DyGridItem? _internalSelectedGridItem;
  String _selectedSortField = 'date';
  bool _isSortAscending = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. DYNAMIC ACTION BAR (DAB: Submodules, Search, Filters, View Switcher & Non-Table Sorting)
        DynamicActionBar(
          entityName: widget.entityName,
          selectedView: widget.selectedViewMode,
          onViewChanged: widget.onViewModeChanged,
          submoduleWidget: widget.submoduleWidget,
          searchQuery: widget.searchQuery,
          onSearchChanged: widget.onSearchChanged,
          selectedParties: widget.selectedParties,
          partyOptions: widget.partyOptions,
          onPartyChanged: widget.onPartyChanged,
          selectedMills: widget.selectedMills,
          millOptions: widget.millOptions,
          onMillChanged: widget.onMillChanged,
          selectedQualities: widget.selectedQualities,
          qualityOptions: widget.qualityOptions,
          onQualityChanged: widget.onQualityChanged,
          selectedStatuses: widget.selectedStatuses,
          onStatusChanged: widget.onStatusChanged,
          showRangeFilter: widget.showRangeFilter,
          selectedDateRange: widget.selectedDateRange,
          selectedDateLabel: widget.selectedDateLabel,
          onDateRangeSelected: widget.onDateRangeSelected,
          hasActiveFilters: widget.hasActiveFilters,
          onClearAllFilters: widget.onClearAllFilters,
          selectedGroup: widget.selectedGroup,
          onGroupChanged: widget.onGroupChanged,
          groupOptions: widget.groupOptions,
          autoCompleteWidget: widget.autoCompleteWidget,
          // Non-Table Sorting
          selectedSortField: _selectedSortField,
          isSortAscending: _isSortAscending,
          onSortFieldChanged: (field) {
            setState(() {
              _selectedSortField = field;
            });
          },
          onToggleSortDirection: () {
            setState(() {
              _isSortAscending = !_isSortAscending;
            });
          },
        ),
        const shad.DensityGap(shad.gapMd),

        // 3. DYNAMIC CONTENT AREA VIEW ROUTER (150ms AnimatedSwitcher Fade Transition)
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: KeyedSubtree(
              key: ValueKey<String>(widget.selectedViewMode),
              child: _buildContentView(context, theme, colors),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentView(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    switch (widget.selectedViewMode) {
      case 'table':
        return Align(
          alignment: Alignment.topCenter,
          child: DyTable(
            columns: widget.tableColumns,
            rows: widget.tableRows,
            totalRecords: widget.totalRecords ?? 0,
            pageIndex: widget.pageIndex,
            onPageChanged: widget.onPageChanged,
            onEditRow: widget.onEditRow,
            isLoading: widget.isLoading,
            summaryTotals: widget.summaryTotals,
          ),
        );

      case 'list':
        final sortedListItems = _getSortedListItems();
        final activeListItem = widget.selectedListItem ??
            _internalSelectedListItem ??
            (sortedListItems.isNotEmpty ? sortedListItems.first : null);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Master List (Fixed 360px Width as per DyGridSystem)
            DyListPane(
              width: DyGridSystem.fixedListMasterWidth * theme.scaling,
              items: sortedListItems,
              selectedItem: activeListItem,
              onItemSelected: (item) {
                widget.onListItemSelected?.call(item);
                setState(() => _internalSelectedListItem = item);
              },
              showHeader: false,
              isLoading: widget.isLoading,
              totalRecords: widget.totalRecords,
            ),
            const shad.DensityGap(shad.gapLg),

            // Right Details Inspection Canvas (Expanded to fill 100% of remaining space)
            Expanded(
              child: _buildDetailsPane(
                title: activeListItem?.title ?? 'No Item Selected',
                subtitle: '${activeListItem?.indexNumber ?? ''} • ${activeListItem?.subtitle ?? ''}',
                amount: activeListItem?.amount ?? '₹0',
              ),
            ),
          ],
        );

      case 'cards':
        final sortedGridItems = _getSortedGridItems();
        final activeGridItem = widget.selectedGridItem ??
            _internalSelectedGridItem ??
            (sortedGridItems.isNotEmpty ? sortedGridItems.first : null);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Vertical Cards Grid (Flex 9 = 75% as per DyGridSystem)
            Expanded(
              flex: DyGridSystem.flexCardsGrid,
              child: DyCardPane(
                items: sortedGridItems,
                selectedItem: activeGridItem,
                onItemSelected: (item) {
                  widget.onGridItemSelected?.call(item);
                  setState(() => _internalSelectedGridItem = item);
                },
                isLoading: widget.isLoading,
                totalRecords: widget.totalRecords,
              ),
            ),
            const shad.DensityGap(shad.gapLg),

            // Right Details Inspection Pane (Flex 3 = 25% as per DyGridSystem)
            Expanded(
              flex: DyGridSystem.flexCardsInspector,
              child: _buildDetailsPane(
                title: activeGridItem?.title ?? 'No Card Selected',
                subtitle: '${activeGridItem?.voucherNo ?? ''} • ${activeGridItem?.partyName ?? ''}',
                amount: activeGridItem?.amount ?? '₹0',
              ),
            ),
          ],
        );

      case 'board':
        final sortedGridItems = _getSortedGridItems();
        final kanbanItems = sortedGridItems.map((item) {
          final statusStr = (item.statusBadge is shad.OutlineBadge)
              ? ((item.statusBadge as shad.OutlineBadge).child as Text).data ?? 'UNCUT'
              : 'UNCUT';

          return DyKanbanItem(
            id: item.id,
            title: item.title,
            voucherNo: item.voucherNo,
            partyName: item.partyName,
            designPattern: item.designPattern,
            quantity: item.quantity,
            amount: item.amount,
            status: statusStr,
            statusBadge: item.statusBadge,
          );
        }).toList();

        final stages = [
          {'title': 'UNCUT', 'color': DyColorSystem.indigo500},
          {'title': 'IN CUTTING', 'color': DyColorSystem.orange500},
          {'title': 'MILL DISPATCH', 'color': DyColorSystem.fuchsia500},
          {'title': 'COMPLETED', 'color': DyColorSystem.green500},
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: stages.asMap().entries.map((entry) {
            final idx = entry.key;
            final stage = entry.value;
            final stageTitle = stage['title'] as String;
            final stageColor = stage['color'] as Color;
            final stageItems = kanbanItems.where((i) => i.status == stageTitle).toList();

            return Expanded(
              flex: DyGridSystem.flexBoard4PaneEqual,
              child: Row(
                children: [
                  Expanded(
                    child: DyKanbanPane(
                      stageTitle: stageTitle,
                      stageColor: stageColor,
                      items: stageItems,
                      selectedItem: null,
                      onItemSelected: (_) {},
                      onAddItem: () {},
                    ),
                  ),
                  if (idx < stages.length - 1) const shad.DensityGap(shad.gapLg),
                ],
              ),
            );
          }).toList(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailsPane({
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return DyDetailsPane(
      title: title,
      subtitle: subtitle,
      statusBadge: const shad.SecondaryBadge(child: Text('UNCUT')),
      metadata: {
        'Voucher No': 'CC-1041',
        'Party / Weaver': 'Ambaji Silks & Textiles',
        'Design & Quality': title,
        'Lot Number': 'Lot #101',
        'Quantity': '45.0 Mts',
        'Amount': amount,
        'Date': '01 Aug 2026',
        'Status': 'Pending Cutting',
      },
      imageUrls: const [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=600&auto=format&fit=crop&q=60',
      ],
      onPrint: () {},
      onEdit: () {},
      onDelete: () {},
    );
  }

  List<DynamicListItem> _getSortedListItems() {
    final list = List<DynamicListItem>.from(widget.listItems);
    list.sort((a, b) {
      int comp = 0;
      switch (_selectedSortField) {
        case 'vno':
          comp = (a.indexNumber ?? '').compareTo(b.indexNumber ?? '');
          break;
        case 'party':
          comp = a.title.compareTo(b.title);
          break;
        case 'amount':
          comp = (a.amount ?? '').compareTo(b.amount ?? '');
          break;
        case 'date':
        default:
          comp = (a.topTrailing ?? '').compareTo(b.topTrailing ?? '');
          break;
      }
      return _isSortAscending ? comp : -comp;
    });
    return list;
  }

  List<DyGridItem> _getSortedGridItems() {
    final list = List<DyGridItem>.from(widget.gridItems);
    list.sort((a, b) {
      int comp = 0;
      switch (_selectedSortField) {
        case 'vno':
          comp = a.voucherNo.compareTo(b.voucherNo);
          break;
        case 'party':
          comp = a.partyName.compareTo(b.partyName);
          break;
        case 'amount':
          comp = a.amount.compareTo(b.amount);
          break;
        case 'date':
        default:
          comp = a.title.compareTo(b.title);
          break;
      }
      return _isSortAscending ? comp : -comp;
    });
    return list;
  }
}
