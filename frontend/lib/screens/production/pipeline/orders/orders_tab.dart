import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../organism_design/index.dart';
import '../../../../models/production/model_jobwork.dart';
import '../../../../models/production/model_media.dart';
import '../../../../services/production/service_orders.dart';
import '../../../../services/production/service_media.dart';
import 'widgets/orders_detail_canvas.dart';

/// [OrdersTab] — Handles Finish (O13), Lace (O14), and Photo (TBD) purchase order pipeline tab.
class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final _service = OrdersService();
  final _mediaService = MediaService();

  int _currentTabIndex = 0; // 0: Finish (O13), 1: Lace (O14), 2: Photo (TBD)
  List<JobReceiveModel> _orders = [];
  JobReceiveModel? _selectedOrder;

  List<JobWorkDetailLineModel> _detailLines = [];
  List<MediaModel> _attachedMedia = [];

  bool _isLoading = false;
  bool _isDetailLoading = false;

  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  String _searchTerm = '';

  // Filter & Sort State
  String? _selectedFilterVendor;
  String? _selectedFilterFabric;
  String _sortBy = 'DATE_DESC';
  List<String> _uniqueFilterVendors = [];
  List<String> _uniqueFilterFabrics = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _currentTypeCode {
    if (_currentTabIndex == 0) return 'O13';
    if (_currentTabIndex == 1) return 'O14';
    return '';
  }

  Future<void> _loadFilterOptions() async {
    final type = _currentTypeCode;
    if (type.isEmpty) {
      setState(() {
        _uniqueFilterVendors = [];
        _uniqueFilterFabrics = [];
      });
      return;
    }

    try {
      final vendors = await _service.getUniqueVendors(type: type);
      final fabrics = await _service.getUniqueFabrics(type: type);
      if (mounted) {
        setState(() {
          _uniqueFilterVendors = vendors;
          _uniqueFilterFabrics = fabrics;
        });
      }
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final type = _currentTypeCode;
    if (type.isEmpty) {
      // Photo Tab (TBD)
      setState(() {
        _orders = [];
        _totalCount = 0;
        _isLoading = false;
        _selectedOrder = null;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _service.getPurchaseOrders(
        type: type,
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        searchTerm: _searchTerm,
        filterKhata: _selectedFilterVendor,
        filterFabric: _selectedFilterFabric,
        sortBy: _sortBy,
      );

      if (mounted) {
        setState(() {
          _orders = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
          // Auto-select first item
          if (_orders.isNotEmpty && _selectedOrder == null) {
            _onOrderSelected(_orders.first);
          }
        });
      }
    } catch (e) {
      debugPrint('Error in OrdersTab._loadData: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onOrderSelected(JobReceiveModel order) async {
    setState(() {
      _selectedOrder = order;
      _isDetailLoading = true;
      _detailLines = [];
      _attachedMedia = [];
    });

    try {
      final lines = await _service.getPurchaseOrderLines(order.vno, order.type);
      final media = await _mediaService.getMediaForEntity('purchase_order', '${order.type}_${order.vno}');

      if (mounted && _selectedOrder?.vno == order.vno && _selectedOrder?.type == order.type) {
        setState(() {
          _detailLines = lines;
          _attachedMedia = media;
          _isDetailLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading details for order #${order.vno}: $e');
      if (mounted && _selectedOrder?.vno == order.vno && _selectedOrder?.type == order.type) {
        setState(() => _isDetailLoading = false);
      }
    }
  }

  Future<void> _attachScan() async {
    if (_selectedOrder == null) return;
    final order = _selectedOrder!;

    try {
      // Yield thread to settle gesture states
      await Future.delayed(Duration.zero);
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes ?? await File(file.path!).readAsBytes();

        setState(() => _isDetailLoading = true);

        // Upload and link to entity
        await _mediaService.uploadFile(
          bytes,
          file.name,
          bucket: 'production',
          mediaType: order.type == 'O13' ? 'job_inward' : 'job_card', // classify automatically
          entityType: 'purchase_order',
          entityId: '${order.type}_${order.vno}',
          entityLabel: '${order.type == 'O13' ? 'Finish PO' : 'Lace PO'} #${order.vno}',
        );

        // Reload details
        final media = await _mediaService.getMediaForEntity('purchase_order', '${order.type}_${order.vno}');
        if (mounted) {
          setState(() {
            _attachedMedia = media;
            _isDetailLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error attaching scan: $e');
      if (mounted) {
        setState(() => _isDetailLoading = false);
      }
    }
  }

  Future<void> _removeScan(String mediaId) async {
    if (_selectedOrder == null) return;
    final order = _selectedOrder!;

    setState(() => _isDetailLoading = true);

    try {
      await _mediaService.delinkFromEntity(mediaId);
      final media = await _mediaService.getMediaForEntity('purchase_order', '${order.type}_${order.vno}');
      if (mounted) {
        setState(() {
          _attachedMedia = media;
          _isDetailLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error removing scan: $e');
      if (mounted) {
        setState(() => _isDetailLoading = false);
      }
    }
  }

  Widget _buildFilterPopover(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setPopoverState) {
        final colors = OrganismTheme.colorsOf(context);
        return CellBox(
          padding: const EdgeInsets.all(OrganismTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FILTER BY KHATA',
                style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 8),
              TissueDropdown<String?>(
                items: [null, ..._uniqueFilterVendors],
                value: _selectedFilterVendor,
                itemLabelBuilder: (val) => val ?? 'All Khatas',
                onChanged: (val) {
                  setState(() {
                    _selectedFilterVendor = val;
                    _currentPage = 1;
                    _selectedOrder = null;
                  });
                  setPopoverState(() {});
                  _loadData();
                },
              ),
              const SizedBox(height: 16),
              Text(
                'FILTER BY FABRIC',
                style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 8),
              TissueDropdown<String?>(
                items: [null, ..._uniqueFilterFabrics],
                value: _selectedFilterFabric,
                itemLabelBuilder: (val) => val ?? 'All Fabrics',
                onChanged: (val) {
                  setState(() {
                    _selectedFilterFabric = val;
                    _currentPage = 1;
                    _selectedOrder = null;
                  });
                  setPopoverState(() {});
                  _loadData();
                },
              ),
              if (_selectedFilterVendor != null || _selectedFilterFabric != null) ...[
                const SizedBox(height: 16),
                CellButton(
                  text: 'Clear Filters',
                  variant: CellButtonVariant.outline,
                  onPressed: () {
                    setState(() {
                      _selectedFilterVendor = null;
                      _selectedFilterFabric = null;
                      _currentPage = 1;
                      _selectedOrder = null;
                    });
                    setPopoverState(() {});
                    _loadData();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortPopover(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setPopoverState) {
        final colors = OrganismTheme.colorsOf(context);
        final List<Map<String, dynamic>> sortOptions = [
          {'label': 'Date: Latest First', 'value': 'DATE_DESC', 'icon': LucideIcons.calendarRange},
          {'label': 'Date: Oldest First', 'value': 'DATE_ASC', 'icon': LucideIcons.calendarRange},
          {'label': 'Job No: High to Low', 'value': 'JOBNO_DESC', 'icon': LucideIcons.hash},
          {'label': 'Job No: Low to High', 'value': 'JOBNO_ASC', 'icon': LucideIcons.hash},
        ];

        return CellBox(
          padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingSm),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sortOptions.map<Widget>((opt) {
                final isSelected = opt['value'] == _sortBy;
                return Container(
                  color: isSelected ? colors.primary.withValues(alpha: 0.04) : null,
                  child: CellListTile(
                    title: opt['label'],
                    leading: Icon(opt['icon'], size: 14, color: isSelected ? colors.primary : colors.textMuted),
                    onTap: () {
                      setState(() {
                        _sortBy = opt['value'];
                        _currentPage = 1;
                        _selectedOrder = null;
                      });
                      setPopoverState(() {});
                      _loadData();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    final showDetail = _selectedOrder != null && _currentTabIndex != 2;

    return SystemAppMasterLayout(
      isDetailVisible: showDetail,
      paneHeader: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrganPaneHeader(
            title: 'Orders',
            searchController: _searchController,
            onSearchChanged: (val) {
              setState(() {
                _searchTerm = val;
                _currentPage = 1;
                _selectedOrder = null;
              });
              _loadData();
            },
            searchPlaceholder: _currentTabIndex == 2 ? 'Search placeholder' : 'Search by Vendor...',
            primaryAction: const CellButton(
              text: 'Add',
              icon: LucideIcons.plus,
              variant: CellButtonVariant.primary,
              isCompact: true,
              onPressed: null, // Disabled
            ),
            filterContent: _currentTabIndex == 2 ? null : _buildFilterPopover(context),
            filterWidth: 260.0,
            sortContent: _currentTabIndex == 2 ? null : _buildSortPopover(context),
            sortWidth: 260.0,
          ),
          Container(
            color: colors.surfaceMuted,
            padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
            alignment: Alignment.centerLeft,
            child: TissueTabs(
              tabs: const ['Finish O13', 'Lace O14', 'Photo'],
              initialIndex: _currentTabIndex,
              variant: TissueTabsVariant.underline,
              onChanged: (index) {
                setState(() {
                  _currentTabIndex = index;
                  _currentPage = 1;
                  _selectedOrder = null;
                  _searchTerm = '';
                  _searchController.clear();
                  _selectedFilterVendor = null;
                  _selectedFilterFabric = null;
                });
                _loadData();
                _loadFilterOptions();
              },
            ),
          ),
        ],
      ),
      paneList: _currentTabIndex == 2
          ? Container(
              padding: const EdgeInsets.all(OrganismTheme.spacingLg),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.camera, size: 32, color: colors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Photo Pipeline TBD',
                      style: OrganismTheme.titleMedium(context).copyWith(color: colors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Photo orders pipeline details and links are currently under active design.',
                      textAlign: TextAlign.center,
                      style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : OrganPaneList(
              isLoading: _isLoading,
              itemCount: _orders.length,
              currentPage: _currentPage,
              totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
              totalCount: _totalCount,
              limit: _limit,
              onPageChanged: (p) {
                setState(() {
                  _currentPage = p;
                  _selectedOrder = null;
                });
                _loadData();
              },
              itemBuilder: (context, index) {
                final item = _orders[index];
                final isSelected = _selectedOrder?.vno == item.vno && _selectedOrder?.type == item.type;

                return TissueListCard.registry(
                  isSelected: isSelected,
                  onTap: () => _onOrderSelected(item),
                  showDivider: true,
                  badgeColor: colors.primary,
                  registryDate: item.date,
                  registryTitle: item.tailorName ?? item.tailorCode,
                  registrySubtitle: item.itemReceived ?? 'No items found',
                  registryBadgeText: '${item.vno}',
                  registryMetricText: '${item.totPcs} PCS',
                );
              },
            ),
      sectionCanvas: showDetail
          ? OrdersDetailCanvas(
              order: _selectedOrder!,
              detailLines: _detailLines,
              attachedMedia: _attachedMedia,
              isDetailLoading: _isDetailLoading,
              onAttachScan: _attachScan,
              onRemoveScan: _removeScan,
            )
          : null,
      emptyTitle: _currentTabIndex == 2 ? 'Photo Pipeline TBD' : 'No Purchase Order Selected',
      emptyMessage: _currentTabIndex == 2
          ? 'Select other tabs to view finish and lace order logs.'
          : 'Select a purchase order from the registry list to view fabric breakdown and challan files.',
      emptyIcon: _currentTabIndex == 2 ? LucideIcons.camera : LucideIcons.receipt,
    );
  }
}
