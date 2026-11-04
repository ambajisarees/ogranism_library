/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES REPORT PANE (scr_sales_report_pane.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary analytical focus report screen for Sales module.
   - Renders invoice data grouped by Master Customer, accounting for multiple Hastes
     per biller, sorted strictly by highest amount first.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - 9-Column Tabular Structure:
     1. BILL NO (Voucher/Bill sequence)
     2. DATE (Transaction date)
     3. PARTY NAME (Haste if present, otherwise Main Customer)
     4. AGENT / BILLER (Biller party if haste, otherwise Agent)
     5. TYPE (Haste badge vs Customer badge)
     6. BALES (Package/bales count)
     7. PCS / MTS (Total pieces or meters)
     8. GROSS AMT (Pre-tax value)
     9. BILL AMT (Payable amount, primary highlight)
   - Grouping: Aggregates invoices under collapsible Master Customer headers with
     customer-level subtotals for bales, gross, and net revenue.
   - Dual View Modes: 'Grouped by Customer' (default) vs 'All Invoices (Flat)'.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - S1 dataset can have ~17,900 rows; fetches top 1,000 active records for instant responsiveness.
   - Default sorting: Highest amount first across groups and within nested bills.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Should drill-down to line-item fabric breakdown be expandable on row click? Supported via sheet.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../models/sales/mdl_sales.dart';
import '../../services/sales/srv_sales.dart';
import '../../models/core/sq/sq_billdet.dart';

/// [ScrSalesReportPane] — Comprehensive Tabular Sales Report Surface.
class ScrSalesReportPane extends StatefulWidget {
  const ScrSalesReportPane({super.key});

  @override
  State<ScrSalesReportPane> createState() => _ScrSalesReportPaneState();
}

class _ScrSalesReportPaneState extends State<ScrSalesReportPane> {
  final SrvSales _salesService = SrvSales();
  final TextEditingController _searchController = TextEditingController();

  List<MdlCustomerSalesGroup> _customerGroups = [];
  List<MdlSalesBill> _allBills = [];
  SalesSummaryMetrics _metrics = const SalesSummaryMetrics();
  bool _isLoading = true;
  String _viewMode = 'grouped'; // 'grouped' or 'flat'
  bool _onlyWithHaste = false;
  String? _searchQuery;

  // Set of expanded Master Customers (starts completely empty for collapsed state)
  final Set<String> _expandedCustomers = {};
  // Set of expanded Haste subgroups (key: '${cust}___${haste}')
  final Set<String> _expandedHastes = {};
  int _loadedCount = 0;
  int _totalToLoad = 0;

  @override
  void initState() {
    super.initState();
    _loadSalesData(forceRefresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadedCount = 0;
      _totalToLoad = 0;
      if (forceRefresh) {
        _expandedCustomers.clear();
        _expandedHastes.clear();
      }
    });

    try {
      final groups = await _salesService.getCustomerSalesGroups(
        searchQuery: _searchQuery,
        onlyWithHaste: _onlyWithHaste,
        forceRefresh: forceRefresh,
        onProgress: (loaded, total) {
          if (mounted) {
            setState(() {
              _loadedCount = loaded;
              _totalToLoad = total;
            });
          }
        },
      );

      final List<MdlSalesBill> flatBills = [];
      for (final g in groups) {
        flatBills.addAll(g.bills);
      }
      // Flat bills also strictly sorted latest first (DATE desc, VNO desc)
      flatBills.sort((a, b) {
        final dateComp = (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970));
        if (dateComp != 0) return dateComp;
        return b.vno.compareTo(a.vno);
      });

      final metrics = _salesService.calculateMetrics(flatBills);

      if (!mounted) return;
      setState(() {
        _customerGroups = groups;
        _allBills = flatBills;
        _metrics = metrics;
        _isLoading = false;
        // All customer groups and haste subgroups remain in collapsed state by default
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final theme = shad.Theme.of(context);
      shad.showToast(
        context: context,
        builder: (context, show) => shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0 * theme.scaling),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.triangleAlert, color: theme.colorScheme.destructive, size: 16),
                const SizedBox(width: 8),
                Text('Failed to load sales data: $e', style: theme.typography.textSmall),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _toggleCustomerExpansion(String customerName) {
    setState(() {
      if (_expandedCustomers.contains(customerName)) {
        _expandedCustomers.remove(customerName);
      } else {
        _expandedCustomers.add(customerName);
      }
    });
  }

  void _toggleHasteExpansion(String customerName, String hasteName) {
    final key = '${customerName}___$hasteName';
    setState(() {
      if (_expandedHastes.contains(key)) {
        _expandedHastes.remove(key);
      } else {
        _expandedHastes.add(key);
      }
    });
  }

  void _expandAllGroups() {
    setState(() {
      _expandedCustomers.clear();
      _expandedHastes.clear();
      for (final g in _customerGroups) {
        _expandedCustomers.add(g.customerName);
        for (final h in g.hasteSubgroups) {
          _expandedHastes.add('${g.customerName}___${h.hasteName}');
        }
      }
    });
  }

  void _collapseAllGroups() {
    setState(() {
      _expandedCustomers.clear();
      _expandedHastes.clear();
    });
  }

  void _showBillDetailSheet(BuildContext context, MdlSalesBill bill) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: shad.ModalContainer(
            child: SizedBox(
              width: 520 * theme.scaling,
              height: 640 * theme.scaling,
              child: FutureBuilder<List<SqBilldetModel>>(
                future: _salesService.getLineItemsForBill(bill),
                builder: (context, snapshot) {
                  final lineItems = snapshot.data ?? [];
                  final isLoadingLines = snapshot.connectionState == ConnectionState.waiting;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(shad.LucideIcons.receipt, size: 20 * theme.scaling, color: colors.primary),
                          const shad.DensityGap(shad.gapSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invoice #${bill.billNo}',
                                  style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  bill.formattedDate,
                                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                ),
                              ],
                            ),
                          ),
                          _buildTypeBadge(bill.billType),
                        ],
                      ),
                      const shad.DensityGap(shad.gapMd),
                      const shad.Divider(),
                      const shad.DensityGap(shad.gapMd),

                      // Metadata Cards
                      shad.Card(
                        child: Padding(
                          padding: EdgeInsets.all(12 * theme.scaling),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Master Biller / Customer', bill.billerCode, theme),
                              const shad.DensityGap(shad.gapSm),
                              if (bill.hasHaste) ...[
                                _buildDetailRow('Haste (Dispatch Party)', bill.haste, theme, isHighlight: true),
                                const shad.DensityGap(shad.gapSm),
                              ],
                              _buildDetailRow('Agent / Broker', bill.brokerName.isNotEmpty ? bill.brokerName : 'Direct', theme),
                              const shad.DensityGap(shad.gapSm),
                              _buildDetailRow('Bales / Parcels', '${bill.bales} Bales', theme),
                              const shad.DensityGap(shad.gapSm),
                              _buildDetailRow('Total Pieces', '${bill.totalPieces} Pcs', theme),
                              const shad.DensityGap(shad.gapSm),
                              _buildDetailRow('Total Meters', '${bill.totalMeters.toStringAsFixed(1)} Mts', theme),
                              const shad.DensityGap(shad.gapSm),
                              _buildDetailRow('Gross Amount', bill.formattedGrossAmount, theme),
                              const shad.DensityGap(shad.gapSm),
                              _buildDetailRow('Bill Amount', bill.formattedBillAmount, theme, isBold: true),
                              if (bill.transport.isNotEmpty) ...[
                                const shad.DensityGap(shad.gapSm),
                                _buildDetailRow('Transport', bill.transport, theme),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const shad.DensityGap(shad.gapMd),
                      Text(
                        'Line Items (${lineItems.length})',
                        style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const shad.DensityGap(shad.gapSm),

                      // Line Items List
                      Expanded(
                        child: isLoadingLines
                            ? const Center(child: shad.CircularProgressIndicator())
                            : lineItems.isEmpty
                                ? Center(
                                    child: Text(
                                      'No itemized lines recorded for this voucher.',
                                      style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: lineItems.length,
                                    separatorBuilder: (ctx, i) => const shad.Divider(),
                                    itemBuilder: (ctx, i) {
                                      final item = lineItems[i];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 6 * theme.scaling),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.quality.isNotEmpty ? item.quality : 'Quality Item #${item.srNo}',
                                                    style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600),
                                                  ),
                                                  Text(
                                                    '${item.pieces.toInt()} Pcs • ${item.meters.toStringAsFixed(1)} Mts @ ₹${item.rate.toStringAsFixed(2)}',
                                                    style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '₹${item.amount.toStringAsFixed(0)}',
                                              style: theme.typography.textSmall.copyWith(
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),

                      const shad.DensityGap(shad.gapMd),
                      shad.OutlineButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, shad.ThemeData theme, {bool isHighlight = false, bool isBold = false}) {
    final colors = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
        ),
        const shad.DensityGap(shad.gapMd),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.typography.textSmall.copyWith(
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? colors.primary : colors.foreground,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. TOP STATS BAR
        _buildStatsBar(theme, colors),
        const shad.DensityGap(shad.gapMd),

        // 2. FILTER & ACTION TOOLBAR
        _buildActionToolbar(theme, colors),
        const shad.DensityGap(shad.gapMd),

        // 3. MAIN TABULAR REPORT SURFACE
        Expanded(
          child: shad.OutlinedContainer(
            borderColor: colors.border,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            backgroundColor: colors.card,
            padding: EdgeInsets.zero,
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const shad.CircularProgressIndicator(),
                        const shad.DensityGap(shad.gapMd),
                        Text(
                          _totalToLoad > 0
                              ? 'Loading all sales invoices ($_loadedCount / $_totalToLoad)...'
                              : 'Fetching sales records from database...',
                          style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  )
                : _customerGroups.isEmpty
                    ? _buildEmptyState(theme, colors)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Table Header
                          _buildTableHeader(theme, colors),
                          const shad.Divider(),

                          // Table Body
                          Expanded(
                            child: _viewMode == 'grouped'
                                ? _buildGroupedListView(theme, colors)
                                : _buildFlatListView(theme, colors),
                          ),

                          // Table Footer Totals
                          const shad.Divider(),
                          _buildTableFooter(theme, colors),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TOP KPI STATS BAR
  // ===========================================================================
  Widget _buildStatsBar(shad.ThemeData theme, shad.ColorScheme colors) {
    final spacing = 12.0 * theme.scaling;
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            theme,
            colors,
            title: 'TOTAL SALES REVENUE',
            value: '₹${(_metrics.totalRevenue / 100000).toStringAsFixed(2)} Lakhs',
            subtitle: '${_metrics.totalInvoices} Invoices Issued',
            icon: shad.LucideIcons.indianRupee,
            isPrimary: true,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildMetricCard(
            theme,
            colors,
            title: 'TOTAL BALES DISPATCHED',
            value: '${_metrics.totalBales}',
            subtitle: '${_metrics.totalPieces} Pcs / ${_metrics.totalMeters.toStringAsFixed(0)} Mts',
            icon: shad.LucideIcons.boxes,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildMetricCard(
            theme,
            colors,
            title: 'MASTER CUSTOMERS',
            value: '${_metrics.totalMasterCustomers}',
            subtitle: 'Billing Accounts',
            icon: shad.LucideIcons.users,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildMetricCard(
            theme,
            colors,
            title: 'HASTE DELIVERIES',
            value: '${_metrics.totalHasteDeliveries}',
            subtitle: '${((_metrics.totalHasteDeliveries / (_metrics.totalInvoices > 0 ? _metrics.totalInvoices : 1)) * 100).toStringAsFixed(1)}% of total dispatches',
            icon: shad.LucideIcons.truck,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return shad.Card(
      child: Padding(
        padding: EdgeInsets.all(12 * theme.scaling),
        child: Row(
          children: [
            shad.OutlinedContainer(
              borderColor: isPrimary ? colors.primary.withAlpha(80) : colors.border,
              backgroundColor: isPrimary ? colors.primary.withAlpha(25) : colors.muted.withAlpha(50),
              borderRadius: BorderRadius.circular(theme.radiusMd),
              padding: EdgeInsets.all(10 * theme.scaling),
              child: Icon(
                icon,
                size: 20 * theme.scaling,
                color: isPrimary ? colors.primary : colors.foreground,
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.typography.xSmall.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.typography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? colors.primary : colors.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTION & FILTER TOOLBAR
  // ===========================================================================
  Widget _buildActionToolbar(shad.ThemeData theme, shad.ColorScheme colors) {
    return Row(
      children: [
        // Search Input
        SizedBox(
          width: 320 * theme.scaling,
          child: shad.TextField(
            controller: _searchController,
            placeholder: const Text('Search party, haste, agent, bill...'),
            features: [
              shad.InputFeature.leading(
                Icon(shad.LucideIcons.search, size: 16 * theme.scaling, color: colors.mutedForeground),
              ),
            ],
            onSubmitted: (val) {
              _searchQuery = val.trim();
              _loadSalesData();
            },
          ),
        ),
        const shad.DensityGap(shad.gapSm),

        // Search trigger button
        shad.OutlineButton(
          onPressed: () {
            _searchQuery = _searchController.text.trim();
            _loadSalesData();
          },
          child: const Text('Search'),
        ),
        const shad.DensityGap(shad.gapSm),

        if (_searchQuery != null && _searchQuery!.isNotEmpty)
          shad.GhostButton(
            onPressed: () {
              _searchController.clear();
              _searchQuery = null;
              _loadSalesData();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.x, size: 14),
                shad.DensityGap(shad.gapXs),
                Text('Clear'),
              ],
            ),
          ),

        const Spacer(),

        // Haste Filter Toggle
        _onlyWithHaste
            ? shad.SecondaryButton(
                onPressed: () {
                  setState(() {
                    _onlyWithHaste = false;
                  });
                  _loadSalesData();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.truck, size: 14 * theme.scaling),
                    const shad.DensityGap(shad.gapSm),
                    const Text('Showing Haste Only'),
                  ],
                ),
              )
            : shad.OutlineButton(
                onPressed: () {
                  setState(() {
                    _onlyWithHaste = true;
                  });
                  _loadSalesData();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.truck, size: 14 * theme.scaling),
                    const shad.DensityGap(shad.gapSm),
                    const Text('Filter: Haste Only'),
                  ],
                ),
              ),
        const shad.DensityGap(shad.gapSm),

        // View Mode Toggle (Grouped vs Flat)
        shad.ButtonGroup(
          children: [
            _viewMode == 'grouped'
                ? shad.SecondaryButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(shad.LucideIcons.layers, size: 14),
                        shad.DensityGap(shad.gapXs),
                        Text('Grouped by Customer'),
                      ],
                    ),
                  )
                : shad.OutlineButton(
                    onPressed: () {
                      setState(() {
                        _viewMode = 'grouped';
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(shad.LucideIcons.layers, size: 14),
                        shad.DensityGap(shad.gapXs),
                        Text('Grouped by Customer'),
                      ],
                    ),
                  ),
            _viewMode == 'flat'
                ? shad.SecondaryButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(shad.LucideIcons.list, size: 14),
                        shad.DensityGap(shad.gapXs),
                        Text('All Invoices (Flat)'),
                      ],
                    ),
                  )
                : shad.OutlineButton(
                    onPressed: () {
                      setState(() {
                        _viewMode = 'flat';
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(shad.LucideIcons.list, size: 14),
                        shad.DensityGap(shad.gapXs),
                        Text('All Invoices (Flat)'),
                      ],
                    ),
                  ),
          ],
        ),

        if (_viewMode == 'grouped') ...[
          const shad.DensityGap(shad.gapSm),
          shad.GhostButton(
            onPressed: _expandedCustomers.isNotEmpty || _expandedHastes.isNotEmpty
                ? _collapseAllGroups
                : _expandAllGroups,
            child: Text(
              _expandedCustomers.isNotEmpty || _expandedHastes.isNotEmpty ? 'Collapse All' : 'Expand All',
              style: theme.typography.xSmall,
            ),
          ),
        ],

        const shad.DensityGap(shad.gapSm),
        // Refresh Button with Cache Invalidation
        shad.OutlineButton(
          onPressed: () => _loadSalesData(forceRefresh: true),
          child: const Icon(shad.LucideIcons.refreshCw, size: 14),
        ),
      ],
    );
  }

  // ===========================================================================
  // 9-COLUMN TABLE HEADER
  // ===========================================================================
  Widget _buildTableHeader(shad.ThemeData theme, shad.ColorScheme colors) {
    return Container(
      color: colors.muted.withAlpha(40),
      padding: EdgeInsets.symmetric(horizontal: 16 * theme.scaling, vertical: 10 * theme.scaling),
      child: Row(
        children: [
          SizedBox(
            width: 90 * theme.scaling,
            child: Text(
              'BILL NO',
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          SizedBox(
            width: 105 * theme.scaling,
            child: Text(
              'DATE',
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'PARTY NAME (HASTE / MAIN CUSTOMER)',
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'AGENT / BILLER',
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          SizedBox(
            width: 100 * theme.scaling,
            child: Text(
              'TYPE',
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          SizedBox(
            width: 75 * theme.scaling,
            child: Text(
              'BALES',
              textAlign: TextAlign.right,
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          SizedBox(
            width: 95 * theme.scaling,
            child: Text(
              'PCS / MTS',
              textAlign: TextAlign.right,
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          SizedBox(
            width: 115 * theme.scaling,
            child: Text(
              'GROSS AMT',
              textAlign: TextAlign.right,
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground),
            ),
          ),
          SizedBox(
            width: 130 * theme.scaling,
            child: Text(
              'BILL AMT',
              textAlign: TextAlign.right,
              style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
            ),
          ),
          SizedBox(width: 32 * theme.scaling), // Chevron / Action gap
        ],
      ),
    );
  }

  // ===========================================================================
  // GROUPED BY MASTER CUSTOMER LIST VIEW (WITH HASTE SUBGROUPING)
  // ===========================================================================
  Widget _buildGroupedListView(shad.ThemeData theme, shad.ColorScheme colors) {
    return ListView.builder(
      itemCount: _customerGroups.length,
      itemBuilder: (context, index) {
        final group = _customerGroups[index];
        final isCustomerExpanded = _expandedCustomers.contains(group.customerName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Level 1: Master Customer Group Header
            InkWell(
              onTap: () => _toggleCustomerExpansion(group.customerName),
              hoverColor: colors.accent.withAlpha(50),
              child: Container(
                decoration: BoxDecoration(
                  color: isCustomerExpanded ? colors.accent.withAlpha(30) : colors.card,
                  border: Border(bottom: BorderSide(color: colors.border.withAlpha(80))),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16 * theme.scaling, vertical: 12 * theme.scaling),
                child: Row(
                  children: [
                    Icon(
                      isCustomerExpanded ? shad.LucideIcons.chevronDown : shad.LucideIcons.chevronRight,
                      size: 18 * theme.scaling,
                      color: colors.primary,
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              group.customerName,
                              style: theme.typography.textSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.foreground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const shad.DensityGap(shad.gapSm),
                          shad.OutlineBadge(
                            child: Text('${group.totalBills} Bills'),
                          ),
                          if (group.hasteCount > 0) ...[
                            const shad.DensityGap(shad.gapXs),
                            shad.SecondaryBadge(
                              child: Text('${group.hasteCount} Hastes'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100 * theme.scaling,
                      child: Text(
                        'Total Bales: ${group.totalBales}',
                        style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                      ),
                    ),
                    SizedBox(
                      width: 100 * theme.scaling,
                      child: Text(
                        '${group.totalPieces} Pcs',
                        textAlign: TextAlign.right,
                        style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                      ),
                    ),
                    SizedBox(
                      width: 115 * theme.scaling,
                      child: Text(
                        group.formattedTotalGrossAmt,
                        textAlign: TextAlign.right,
                        style: theme.typography.textSmall.copyWith(
                          color: colors.mutedForeground,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 130 * theme.scaling,
                      child: Text(
                        group.formattedTotalBillAmt,
                        textAlign: TextAlign.right,
                        style: theme.typography.textSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    SizedBox(width: 32 * theme.scaling),
                  ],
                ),
              ),
            ),

            // Level 2: Haste Subgroups under this Master Customer
            if (isCustomerExpanded)
              ...group.hasteSubgroups.map((hasteSubgroup) {
                final hasteKey = '${group.customerName}___${hasteSubgroup.hasteName}';
                final isHasteExpanded = _expandedHastes.contains(hasteKey);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Haste Subgroup Header Row
                    _buildHasteSubgroupHeader(group.customerName, hasteSubgroup, isHasteExpanded, theme, colors),

                    // Level 3: Individual Bills of this Haste (strictly sorted latest first)
                    if (isHasteExpanded)
                      ...hasteSubgroup.bills.map((bill) => _buildInvoiceRow(bill, theme, colors, isNested: true)),
                  ],
                );
              }),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // LEVEL 2: HASTE SUBGROUP HEADER ROW
  // ===========================================================================
  Widget _buildHasteSubgroupHeader(
    String customerName,
    MdlHasteSubgroup hasteSubgroup,
    bool isExpanded,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    return InkWell(
      onTap: () => _toggleHasteExpansion(customerName, hasteSubgroup.hasteName),
      hoverColor: colors.accent.withAlpha(40),
      child: Container(
        decoration: BoxDecoration(
          color: isExpanded ? colors.accent.withAlpha(20) : colors.muted.withAlpha(30),
          border: Border(
            left: BorderSide(
              color: hasteSubgroup.isDirect ? colors.mutedForeground.withAlpha(120) : colors.primary,
              width: 3.5 * theme.scaling,
            ),
            bottom: BorderSide(color: colors.border.withAlpha(50)),
          ),
        ),
        padding: EdgeInsets.only(
          left: 36 * theme.scaling,
          right: 16 * theme.scaling,
          top: 9 * theme.scaling,
          bottom: 9 * theme.scaling,
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? shad.LucideIcons.chevronDown : shad.LucideIcons.chevronRight,
              size: 16 * theme.scaling,
              color: colors.primary,
            ),
            const shad.DensityGap(shad.gapSm),
            Icon(
              hasteSubgroup.isDirect ? shad.LucideIcons.user : shad.LucideIcons.truck,
              size: 14 * theme.scaling,
              color: hasteSubgroup.isDirect ? colors.mutedForeground : colors.primary,
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      hasteSubgroup.hasteName,
                      style: theme.typography.textSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasteSubgroup.isDirect ? colors.foreground : colors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const shad.DensityGap(shad.gapSm),
                  hasteSubgroup.isDirect
                      ? const shad.OutlineBadge(child: Text('Direct Dispatch'))
                      : const shad.SecondaryBadge(child: Text('Haste Subgroup')),
                  const shad.DensityGap(shad.gapXs),
                  shad.OutlineBadge(
                    child: Text('${hasteSubgroup.totalBills} Bills'),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100 * theme.scaling,
              child: Text(
                'Bales: ${hasteSubgroup.totalBales}',
                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              ),
            ),
            SizedBox(
              width: 100 * theme.scaling,
              child: Text(
                '${hasteSubgroup.totalPieces} Pcs',
                textAlign: TextAlign.right,
                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              ),
            ),
            SizedBox(
              width: 115 * theme.scaling,
              child: Text(
                hasteSubgroup.formattedTotalGrossAmt,
                textAlign: TextAlign.right,
                style: theme.typography.textSmall.copyWith(
                  color: colors.mutedForeground,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(
              width: 130 * theme.scaling,
              child: Text(
                hasteSubgroup.formattedTotalBillAmt,
                textAlign: TextAlign.right,
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(width: 32 * theme.scaling),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FLAT INVOICES LIST VIEW
  // ===========================================================================
  Widget _buildFlatListView(shad.ThemeData theme, shad.ColorScheme colors) {
    return ListView.builder(
      itemCount: _allBills.length,
      itemBuilder: (context, index) {
        final bill = _allBills[index];
        return _buildInvoiceRow(bill, theme, colors, isNested: false);
      },
    );
  }

  // ===========================================================================
  // SINGLE INVOICE ROW (9 COLUMNS)
  // ===========================================================================
  Widget _buildInvoiceRow(
    MdlSalesBill bill,
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required bool isNested,
  }) {
    return InkWell(
      onTap: () => _showBillDetailSheet(context, bill),
      hoverColor: colors.accent.withAlpha(40),
      child: Container(
        decoration: BoxDecoration(
          color: isNested ? colors.muted.withAlpha(15) : colors.card,
          border: Border(bottom: BorderSide(color: colors.border.withAlpha(50))),
        ),
        padding: EdgeInsets.only(
          left: isNested ? 52 * theme.scaling : 16 * theme.scaling,
          right: 16 * theme.scaling,
          top: 9 * theme.scaling,
          bottom: 9 * theme.scaling,
        ),
        child: Row(
          children: [
            // 1. BILL NO
            SizedBox(
              width: 90 * theme.scaling,
              child: Text(
                bill.billNo,
                style: theme.typography.mono.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colors.foreground,
                ),
              ),
            ),

            // 2. DATE
            SizedBox(
              width: 105 * theme.scaling,
              child: Text(
                bill.formattedDate,
                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              ),
            ),

            // 3. PARTY NAME (Pick Haste if present, otherwise Master Customer)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bill.effectivePartyName,
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: bill.hasHaste ? colors.primary : colors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (bill.hasHaste)
                    Text(
                      'Biller: ${bill.billerCode}',
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // 4. AGENT / BILLER (Pick Biller Party if haste, otherwise Agent)
            Expanded(
              flex: 2,
              child: Text(
                bill.effectiveAgentOrBiller,
                style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 5. TYPE (Badge)
            SizedBox(
              width: 100 * theme.scaling,
              child: _buildTypeBadge(bill.billType),
            ),

            // 6. BALES
            SizedBox(
              width: 75 * theme.scaling,
              child: Text(
                bill.bales.toString(),
                textAlign: TextAlign.right,
                style: theme.typography.mono.copyWith(fontSize: 13),
              ),
            ),

            // 7. PCS / MTS
            SizedBox(
              width: 95 * theme.scaling,
              child: Text(
                bill.totalPieces > 0 ? '${bill.totalPieces} Pcs' : '${bill.totalMeters.toStringAsFixed(0)} Mts',
                textAlign: TextAlign.right,
                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              ),
            ),

            // 8. GROSS AMT
            SizedBox(
              width: 115 * theme.scaling,
              child: Text(
                bill.formattedGrossAmount,
                textAlign: TextAlign.right,
                style: theme.typography.mono.copyWith(
                  fontSize: 13,
                  color: colors.mutedForeground,
                ),
              ),
            ),

            // 9. BILL AMT
            SizedBox(
              width: 130 * theme.scaling,
              child: Text(
                bill.formattedBillAmount,
                textAlign: TextAlign.right,
                style: theme.typography.mono.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),

            // Action Chevron
            SizedBox(
              width: 32 * theme.scaling,
              child: Icon(
                shad.LucideIcons.chevronRight,
                size: 16 * theme.scaling,
                color: colors.mutedForeground.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(SalesBillType type) {
    if (type == SalesBillType.haste) {
      return const shad.SecondaryBadge(
        child: Text('Haste'),
      );
    }
    return const shad.OutlineBadge(
      child: Text('Customer'),
    );
  }

  // ===========================================================================
  // TABLE FOOTER TOTALS
  // ===========================================================================
  Widget _buildTableFooter(shad.ThemeData theme, shad.ColorScheme colors) {
    return Container(
      color: colors.muted.withAlpha(50),
      padding: EdgeInsets.symmetric(horizontal: 16 * theme.scaling, vertical: 10 * theme.scaling),
      child: Row(
        children: [
          Text(
            'TOTALS (${_metrics.totalInvoices} Invoices across ${_metrics.totalMasterCustomers} Customers)',
            style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'Bales: ${_metrics.totalBales}',
            style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const shad.DensityGap(shad.gapLg),
          Text(
            'Gross: ₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(_metrics.totalGross)}',
            style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const shad.DensityGap(shad.gapLg),
          Text(
            'Net Revenue: ₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(_metrics.totalRevenue)}',
            style: theme.typography.textSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          SizedBox(width: 32 * theme.scaling),
        ],
      ),
    );
  }

  Widget _buildEmptyState(shad.ThemeData theme, shad.ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shad.LucideIcons.receipt, size: 48 * theme.scaling, color: colors.mutedForeground),
            const shad.DensityGap(shad.gapMd),
            Text(
              'No sales invoices match your query',
              style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const shad.DensityGap(shad.gapSm),
            Text(
              'Try adjusting your search query or reset the haste filter.',
              style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
            ),
            const shad.DensityGap(shad.gapMd),
            shad.OutlineButton(
              onPressed: () {
                _searchController.clear();
                _searchQuery = null;
                _onlyWithHaste = false;
                _loadSalesData();
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
