import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../dynamic_ai/components/page_level/page_header.dart';
import '../../../models/production/purchase_orders/purchase_order_category.dart';
import '../../../models/production/purchase_orders/model_purchase_order_header.dart';
import '../../../services/production/service_purchase_order.dart';
import 'widgets/purchase_orders_filter_bar.dart';
import 'widgets/purchase_orders_list_pane.dart';
import 'widgets/purchase_orders_detail_canvas.dart';
import 'widgets/purchase_orders_action_pane.dart';

class ScreenPurchaseOrdersLanding extends StatefulWidget {
  const ScreenPurchaseOrdersLanding({super.key});

  @override
  State<ScreenPurchaseOrdersLanding> createState() => _ScreenPurchaseOrdersLandingState();
}

class _ScreenPurchaseOrdersLandingState extends State<ScreenPurchaseOrdersLanding> {
  final PurchaseOrderService _service = PurchaseOrderService();
  final TextEditingController _searchController = TextEditingController();

  // Category & Counts State (Default to Finish O13)
  PurchaseOrderCategory _selectedCategory = PurchaseOrderCategory.finish;
  Map<PurchaseOrderCategory, int> _categoryCounts = {};

  // Orders Data State
  List<PurchaseOrderHeaderModel> _orders = [];
  PurchaseOrderHeaderModel? _selectedOrder;
  final Set<String> _selectedOrderKeys = {};

  bool _isLoadingHeaders = true;
  bool _isLoadingLineItems = false;
  int _totalCount = 0;
  int _offset = 0;
  final int _limit = 50;

  // Filters & Sorting
  String _selectedSupplier = 'All';
  String _selectedQuality = 'All';
  List<String> _supplierOptions = [];
  List<String> _qualityOptions = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _currentSort = 'DATE_DESC';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _loadCategoryCounts();
    _loadFilterOptions();
    _fetchHeaders(resetOffset: true);
  }

  Future<void> _loadCategoryCounts() async {
    final counts = await _service.getCategoryHeaderCounts();
    if (!mounted) return;
    setState(() {
      _categoryCounts = counts;
    });
  }

  Future<void> _loadFilterOptions() async {
    final suppliers = await _service.getUniqueSuppliers(category: _selectedCategory);
    final qualities = await _service.getUniqueQualities(category: _selectedCategory);
    if (!mounted) return;
    setState(() {
      _supplierOptions = suppliers;
      _qualityOptions = qualities;
    });
  }

  /// PHASE 1: Fast Header Fetch (<100ms response time).
  Future<void> _fetchHeaders({bool resetOffset = true}) async {
    if (resetOffset) {
      _offset = 0;
    }
    setState(() {
      _isLoadingHeaders = true;
      _isLoadingLineItems = false;
    });

    if (_selectedCategory.isEmptyCategory) {
      if (!mounted) return;
      setState(() {
        _orders = [];
        _totalCount = 0;
        _selectedOrder = null;
        _isLoadingHeaders = false;
      });
      return;
    }

    final res = await _service.getPurchaseOrderHeaders(
      offset: _offset,
      limit: _limit,
      category: _selectedCategory,
      searchQuery: _searchController.text.trim(),
      filterSupplier: _selectedSupplier,
      filterQuality: _selectedQuality,
      startDate: _startDate,
      endDate: _endDate,
      sortBy: _currentSort,
    );

    if (!mounted) return;
    setState(() {
      _orders = res.data;
      _totalCount = res.totalCount;
      _isLoadingHeaders = false;
    });

    // Auto-select first PO if available and fetch line items for it (Phase 2)
    if (_orders.isNotEmpty) {
      _onSelectOrderCard(_orders.first);
    } else {
      setState(() {
        _selectedOrder = null;
      });
    }
  }

  /// PHASE 2: On-Demand Line Item Fetch (~50ms response time).
  Future<void> _onSelectOrderCard(PurchaseOrderHeaderModel header) async {
    setState(() {
      _selectedOrder = header;
      _isLoadingLineItems = true;
    });

    final items = await _service.getPurchaseOrderLineItems(
      cno: header.cno,
      vno: header.vno,
      type: header.type,
    );

    if (!mounted) return;
    setState(() {
      if (_selectedOrder?.vno == header.vno && _selectedOrder?.cno == header.cno) {
        _selectedOrder = header.copyWith(items: items);
      }
      _isLoadingLineItems = false;
    });
  }

  void _onCategoryChanged(PurchaseOrderCategory newCategory) {
    if (_selectedCategory == newCategory) return;
    setState(() {
      _selectedCategory = newCategory;
      _selectedSupplier = 'All';
      _selectedQuality = 'All';
      _selectedOrder = null;
      _selectedOrderKeys.clear();
    });
    _loadFilterOptions();
    _fetchHeaders(resetOffset: true);
  }

  void _onSearchChanged(String query) {
    _fetchHeaders(resetOffset: true);
  }

  void _onResetFilters() {
    _searchController.clear();
    setState(() {
      _selectedSupplier = 'All';
      _selectedQuality = 'All';
      _startDate = null;
      _endDate = null;
      _currentSort = 'DATE_DESC';
      _selectedOrderKeys.clear();
    });
    _fetchHeaders(resetOffset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==========================================
        // 1. TOP HEADER & WORKSTATION TOOLBAR ROW
        // ==========================================
        // Page Header with 5-Module Switcher (Grey, Finish, Lace, Studio, Packing)
        PageHeader<PurchaseOrderCategory>(
          title: 'Purchase Orders',
          selectedModuleId: _selectedCategory,
          modules: PurchaseOrderCategory.values.map((cat) {
            return ModuleItem<PurchaseOrderCategory>(
              id: cat,
              label: cat.label,
              icon: cat.icon,
              count: _categoryCounts[cat] ?? 0,
            );
          }).toList(),
          onModuleSelected: _onCategoryChanged,
          actions: const [],
        ),
        const shad.DensityGap(shad.gapMd),

        // Filter Bar (Search, Party/Quality Filter, Date Selector)
        PurchaseOrdersFilterBar(
          categorySelectWidget: const SizedBox.shrink(),
          searchController: _searchController,
          onSearchChanged: _onSearchChanged,
          selectedSupplier: _selectedSupplier,
          selectedQuality: _selectedQuality,
          supplierOptions: _supplierOptions,
          qualityOptions: _qualityOptions,
          onSupplierChanged: (val) {
            setState(() => _selectedSupplier = val);
            _fetchHeaders(resetOffset: true);
          },
          onQualityChanged: (val) {
            setState(() => _selectedQuality = val);
            _fetchHeaders(resetOffset: true);
          },
          startDate: _startDate,
          endDate: _endDate,
          onDateRangeChanged: (range) {
            setState(() {
              _startDate = range?.start;
              _endDate = range?.end;
            });
            _fetchHeaders(resetOffset: true);
          },
          onResetFilters: _onResetFilters,
          totalRecords: _totalCount > 0 ? _totalCount : _orders.length,
          displayedRecords: _orders.length,
          selectedCount: _selectedOrderKeys.length,
        ),
        const shad.DensityGap(shad.gapLg),

        // ==========================================
        // 2. THREE-PANE MASTER DETAIL WORKSTATION LAYOUT
        // ==========================================
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PANE 1 (Left ~300px): List of Order Cards from sq_BILLS
              PurchaseOrdersListPane(
                orders: _orders,
                selectedOrder: _selectedOrder,
                onSelectOrder: _onSelectOrderCard,
                isLoading: _isLoadingHeaders,
                isEmptyModule: _selectedCategory.isEmptyCategory,
              ),
              const shad.DensityGap(shad.gapLg),

              // PANE 2 (Expanded Middle): Header Canvas & Rich Line Items Table
              PurchaseOrdersDetailCanvas(
                selectedOrder: _selectedOrder,
                isLoadingItems: _isLoadingLineItems,
                isEmptyModule: _selectedCategory.isEmptyCategory,
              ),
              const shad.DensityGap(shad.gapLg),

              // PANE 3 (Right ~320px): Actions & Audit Card
              const PurchaseOrdersActionPane(),
            ],
          ),
        ),
      ],
    );
  }
}
