import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/components/page_level/page_header.dart';
import '../../../dynamic_ai/components/page_level/dynamic_action_bar.dart';
import '../../../dynamic_ai/components/page_level/dab_widgets/dab_submodule_popover.dart';
import '../../../dynamic_ai/components/micro_level/micro_button.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';
import '../../../dynamic_ai/components/page_level/dynamic_list.dart';
import '../../../dynamic_ai/components/page_level/dynamic_list_card.dart';
import '../../../models/core/sq/sq_bills.dart';
import '../../../services/core/sq/sq_bills_service.dart';
import 'scr_po_detail_canvas.dart';

/// Submodule Categories for Purchase Orders
enum PoSubmoduleCategory {
  grey(null, 'Grey', shad.LucideIcons.scroll),
  finish('O13', 'Finish', shad.LucideIcons.packageCheck),
  lace('O14', 'Lace', shad.LucideIcons.sparkles),
  packing('O15', 'Packing', shad.LucideIcons.box),
  studio('O16', 'Studio', shad.LucideIcons.camera);

  final String? seriesCode;
  final String label;
  final IconData icon;

  const PoSubmoduleCategory(this.seriesCode, this.label, this.icon);
}

/// [ScrPoLanding] — Main Landing Container Screen for Purchase Orders.
class ScrPoLanding extends StatefulWidget {
  const ScrPoLanding({super.key});

  @override
  State<ScrPoLanding> createState() => _ScrPoLandingState();
}

class _ScrPoLandingState extends State<ScrPoLanding> {
  final SqBillsService _billsService = SqBillsService();
  final TextEditingController _searchController = TextEditingController();

  PoSubmoduleCategory _selectedCategory = PoSubmoduleCategory.finish;
  String _viewMode = 'table'; // 'table' or 'split'
  String? _searchQuery;

  List<SqBillsModel> _orders = [];
  SqBillsModel? _selectedOrder;
  bool _isLoading = true;
  int _totalCount = 0;
  int _offset = 0;
  final int _limit = 50;

  @override
  void initState() {
    super.initState();
    _fetchHeaders(resetOffset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHeaders({bool resetOffset = false}) async {
    if (resetOffset) {
      setState(() {
        _offset = 0;
      });
    }

    setState(() {
      _isLoading = true;
    });

    final seriesCode = _selectedCategory.seriesCode;
    if (seriesCode == null) {
      // Grey / Empty category
      setState(() {
        _orders = [];
        _totalCount = 0;
        _isLoading = false;
        _selectedOrder = null;
      });
      return;
    }

    final res = await _billsService.getPaginatedBills(
      offset: _offset,
      limit: _limit,
      type: seriesCode,
      partyName: _searchQuery,
    );

    if (!mounted) return;

    setState(() {
      _orders = res.data;
      _totalCount = res.totalCount;
      _isLoading = false;
      if (_orders.isNotEmpty && (_selectedOrder == null || !_orders.any((o) => o.vno == _selectedOrder!.vno))) {
        _selectedOrder = _orders.first;
      }
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Page Header (Title + Breadcrumb/Description)
        PageHeader(
          title: 'Purchase Orders',
        ),

        const shad.DensityGap(shad.gapSm),

        // 2. Dynamic Action Bar (DAB with Submodule MicroButton Popover Caller)
        DynamicActionBar(
          entityName: 'Orders',
          selectedView: _viewMode,
          onViewChanged: (mode) {
            setState(() {
              _viewMode = mode;
            });
          },
          submoduleWidget: Builder(
            builder: (btnContext) {
              return MicroButton(
                leadingIcon: _selectedCategory.icon,
                label: _selectedCategory.label,
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
                      builder: (popContext) => DabSubmodulePopover<PoSubmoduleCategory>(
                        title: 'Submodule',
                        selectedId: _selectedCategory,
                        items: PoSubmoduleCategory.values
                            .map(
                              (c) => DabSubmoduleItem<PoSubmoduleCategory>(
                                id: c,
                                label: c.label,
                                icon: c.icon,
                                count: c == _selectedCategory ? _orders.length : 0,
                              ),
                            )
                            .toList(),
                        onSelected: (cat) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                          _fetchHeaders(resetOffset: true);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          searchQuery: _searchQuery,
          onSearchChanged: (val) {
            _searchQuery = val.trim();
            _fetchHeaders(resetOffset: true);
          },
        ),

        const SizedBox(height: 12),

        // 3. Main Content Area (Tabular vs Split View)
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? Center(
                      child: Text(
                        'No Purchase Orders found for ${_selectedCategory.label}',
                        style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                      ),
                    )
                  : _viewMode == 'table'
                      ? _buildTabularView()
                      : _buildSplitView(),
        ),
      ],
    );
  }

  /// Full-Page Dense Table Grid
  Widget _buildTabularView() {
    return DynamicDenseTable(
      rows: _orders.map((o) => o.toRowData()).toList(),
      columns: SqBillsTableMapper.defaultColumns,
      onRowTap: (row) {
        final order = _orders.firstWhere((o) => o.vno.toString() == row.id, orElse: () => _orders.first);
        setState(() {
          _selectedOrder = order;
          _viewMode = 'split';
        });
      },
    );
  }

  /// Master-Detail Split Pane View
  Widget _buildSplitView() {
    final listItems = _orders
        .map(
          (o) => DynamicListItem(
            id: o.vno.toString(),
            title: 'Order #${o.vno}',
            subtitle: o.partyName.isNotEmpty ? o.partyName : 'Unknown Party',
            topLeading: shad.Chip(child: Text(o.type)),
            topTrailing: _formatDate(o.date),
            amount: o.finalAmount > 0 ? '₹${o.finalAmount.toStringAsFixed(2)}' : null,
            rawData: o.toJson(),
          ),
        )
        .toList();

    final selectedListItem = _selectedOrder != null
        ? listItems.firstWhere((item) => item.id == _selectedOrder!.vno.toString(), orElse: () => listItems.first)
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Master List
        DynamicList(
          items: listItems,
          selectedItem: selectedListItem,
          onItemSelected: (item) {
            if (item == null) return;
            final order = _orders.firstWhere((o) => o.vno.toString() == item.id, orElse: () => _orders.first);
            setState(() {
              _selectedOrder = order;
            });
          },
        ),

        const SizedBox(width: 16),

        // Right Detail Canvas
        Expanded(
          child: _selectedOrder != null
              ? ScrPoDetailCanvas(
                  header: _selectedOrder!,
                  onClose: () {
                    setState(() {
                      _viewMode = 'table';
                    });
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
