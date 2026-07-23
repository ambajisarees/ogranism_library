import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../models/production/purchase_bills/purchase_bill_category.dart';
import '../../../models/production/purchase_bills/model_purchase_bill_header.dart';
import '../../../services/production/service_purchase_bill.dart';
import 'widgets/purchase_bills_category_select.dart';
import 'widgets/purchase_bills_filter_bar.dart';
import 'widgets/purchase_bills_list_pane.dart';
import 'widgets/purchase_bills_detail_canvas.dart';
import 'widgets/purchase_bills_action_pane.dart';

class ScreenPurchaseBillsLanding extends StatefulWidget {
  const ScreenPurchaseBillsLanding({super.key});

  @override
  State<ScreenPurchaseBillsLanding> createState() => _ScreenPurchaseBillsLandingState();
}

class _ScreenPurchaseBillsLandingState extends State<ScreenPurchaseBillsLanding> {
  final PurchaseBillService _service = PurchaseBillService();
  final TextEditingController _searchController = TextEditingController();

  // Category & Counts State
  PurchaseBillCategory _selectedCategory = PurchaseBillCategory.grey;
  Map<PurchaseBillCategory, int> _categoryCounts = {};

  // Bills Data State
  List<PurchaseBillHeaderModel> _bills = [];
  PurchaseBillHeaderModel? _selectedBill;
  final Set<String> _selectedBillKeys = {};

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

    final res = await _service.getPurchaseBillHeaders(
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
      _bills = res.data;
      _totalCount = res.totalCount;
      _isLoadingHeaders = false;
    });

    // Auto-select first bill if available and fetch line items for it (Phase 2)
    if (_bills.isNotEmpty) {
      _onSelectBillCard(_bills.first);
    } else {
      setState(() {
        _selectedBill = null;
      });
    }
  }

  /// PHASE 2: On-Demand Line Item Fetch (~50ms response time).
  Future<void> _onSelectBillCard(PurchaseBillHeaderModel header) async {
    setState(() {
      _selectedBill = header;
      _isLoadingLineItems = true;
    });

    final items = await _service.getPurchaseBillLineItems(
      cno: header.cno,
      vno: header.vno,
      type: header.type,
      sourceTable: _selectedCategory.lineItemSource,
    );

    if (!mounted) return;
    setState(() {
      if (_selectedBill?.vno == header.vno && _selectedBill?.cno == header.cno) {
        _selectedBill = header.copyWith(items: items);
      }
      _isLoadingLineItems = false;
    });
  }

  void _onCategoryChanged(PurchaseBillCategory newCategory) {
    if (_selectedCategory == newCategory) return;
    setState(() {
      _selectedCategory = newCategory;
      _selectedSupplier = 'All';
      _selectedQuality = 'All';
      _selectedBill = null;
      _selectedBillKeys.clear();
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
      _selectedBillKeys.clear();
    });
    _fetchHeaders(resetOffset: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==========================================
        // 1. TOP HEADER & WORKSTATION TOOLBAR ROW
        // ==========================================
        Row(
          children: [
            Text(
              'Purchase Bills',
              style: theme.typography.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            shad.SecondaryBadge(
              child: Text('${_selectedCategory.label} (${_selectedCategory.seriesCode})'),
            ),

            const Spacer(),

            shad.OutlineButton(
              size: shad.ButtonSize.small,
              onPressed: () {
                shad.showToast(
                  context: context,
                  builder: (context, show) => shad.Card(
                    child: Padding(
                      padding: EdgeInsets.all(
                        theme.density.baseContainerPadding * theme.scaling * shad.padSm,
                      ),
                      child: const Text('Export feature triggered.'),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shad.LucideIcons.download, size: 16 * theme.scaling),
                  const shad.DensityGap(shad.gapSm),
                  const Text('Export'),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            shad.PrimaryButton(
              size: shad.ButtonSize.small,
              onPressed: () {
                shad.showToast(
                  context: context,
                  builder: (context, show) => shad.Card(
                    child: Padding(
                      padding: EdgeInsets.all(
                        theme.density.baseContainerPadding * theme.scaling * shad.padSm,
                      ),
                      child: Text('Add ${_selectedCategory.label} Purchase Bill triggered.'),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shad.LucideIcons.plus, size: 16 * theme.scaling),
                  const shad.DensityGap(shad.gapSm),
                  Text('Add ${_selectedCategory.label} Bill'),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapMd),

        // Filter Bar (Index 0 Category Dropdown Select, Search, Party/Quality Filter, Date Selector)
        PurchaseBillsFilterBar(
          categorySelectWidget: PurchaseBillsCategorySelect(
            selectedCategory: _selectedCategory,
            categoryCounts: _categoryCounts,
            onCategoryChanged: _onCategoryChanged,
          ),
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
          totalRecords: _totalCount > 0 ? _totalCount : _bills.length,
          displayedRecords: _bills.length,
          selectedCount: _selectedBillKeys.length,
        ),
        const shad.DensityGap(shad.gapLg),

        // ==========================================
        // 2. THREE-PANE MASTER DETAIL WORKSTATION LAYOUT
        // ==========================================
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PANE 1 (Left ~300px): List of Bill Cards from sq_BILLS (Loads instantly in Phase 1)
              PurchaseBillsListPane(
                bills: _bills,
                selectedBill: _selectedBill,
                onSelectBill: _onSelectBillCard,
                isLoading: _isLoadingHeaders,
              ),
              const shad.DensityGap(shad.gapLg),

              // PANE 2 (Expanded Middle): Header Canvas & Rich Line Items Table (Phase 2 Lazy Loading)
              PurchaseBillsDetailCanvas(
                selectedBill: _selectedBill,
                isLoadingItems: _isLoadingLineItems,
              ),
              const shad.DensityGap(shad.gapLg),

              // PANE 3 (Right ~320px): Blank Placeholder Action Card
              const PurchaseBillsActionPane(),
            ],
          ),
        ),
      ],
    );
  }
}
