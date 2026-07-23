import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../dynamic_ai/components/page_level/page_header.dart';
import '../models/production/purchase_bills/purchase_bill_category.dart';
import '../dynamic_ai/components/demo/dynamic_action_bar.dart';
import '../dynamic_ai/components/demo/dynamic_table.dart';
import '../dynamic_ai/components/demo/dynamic_metric_row.dart';
import '../dynamic_ai/components/demo/dynamic_list.dart';
import '../dynamic_ai/components/demo/dynamic_list_card.dart';
import '../dynamic_ai/components/demo/item_header.dart';
import '../dynamic_ai/components/demo/dynamic_content_pane.dart';
import '../dynamic_ai/components/demo/dynamic_side_pane.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  PurchaseBillCategory _selectedCategory = PurchaseBillCategory.grey;
  // ignore: prefer_final_fields
  int _tabIndex = 0;
  // ignore: prefer_final_fields
  int _subTabIndex = 0;
  int _currentPage = 1;
  String? _searchQuery;
  String? _selectedMill;
  String? _selectedFabric;
  String? _selectedStatus;
  String? _selectedParty;
  String? _selectedDateValue;
  String? _selectedSortValue;
  Set<int> _selectedRowIndices = {0, 2, 4};

  final List<DynamicListItem> _mockItems = const [
    DynamicListItem(
      status: 'active',
      date: 'Jul 19, 2026',
      title: 'Cutting Plan #01',
      indexNumber: '#01',
      subtitle: 'Silk Saree batch cutting plan',
      infoNumber: '12',
    ),
    DynamicListItem(
      status: 'pending',
      date: 'Jul 18, 2026',
      title: 'Cutting Plan #02',
      indexNumber: '#02',
      subtitle: 'Cotton embroidery batch',
      infoNumber: '6',
    ),
    DynamicListItem(
      status: 'completed',
      date: 'Jul 15, 2026',
      title: 'Cutting Plan #03',
      indexNumber: '#03',
      subtitle: 'Designer georgette sarees',
      infoNumber: '18',
    ),
    DynamicListItem(
      status: 'active',
      date: 'Jul 12, 2026',
      title: 'Cutting Plan #04',
      indexNumber: '#04',
      subtitle: 'Banarasi silk order batches',
      infoNumber: '4',
    ),
    DynamicListItem(
      status: 'pending',
      date: 'Jul 10, 2026',
      title: 'Cutting Plan #05',
      indexNumber: '#05',
      subtitle: 'Chiffon sequence batch',
      infoNumber: '9',
    ),
    DynamicListItem(
      status: 'completed',
      date: 'Jul 08, 2026',
      title: 'Cutting Plan #06',
      indexNumber: '#06',
      subtitle: 'Net border lace batch',
      infoNumber: '15',
    ),
  ];

  DynamicListItem? _selectedListItem;

  @override
  void initState() {
    super.initState();
    _selectedListItem = _mockItems.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upgraded Modular Page Header
        PageHeader<PurchaseBillCategory>(
          title: 'Purchase Bills',
          selectedModuleId: _selectedCategory,
          modules: PurchaseBillCategory.values.map((cat) {
            final counts = const {
              PurchaseBillCategory.grey: 938,
              PurchaseBillCategory.mill: 662,
              PurchaseBillCategory.finish: 303,
              PurchaseBillCategory.stitching: 384,
              PurchaseBillCategory.packingMaterial: 206,
              PurchaseBillCategory.modelling: 33,
              PurchaseBillCategory.diamond: 30,
              PurchaseBillCategory.lace: 18,
              PurchaseBillCategory.embroidery: 75,
              PurchaseBillCategory.charak: 0,
            };
            return ModuleItem<PurchaseBillCategory>(
              id: cat,
              label: cat.label,
              icon: cat.icon,
              count: counts[cat] ?? 0,
            );
          }).toList(),
          onModuleSelected: (cat) {
            setState(() => _selectedCategory = cat);
          },
          actions: [
            shad.OutlineButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(shad.LucideIcons.download),
                  shad.DensityGap(shad.gapSm),
                  Text('Export'),
                ],
              ),
            ),
            shad.PrimaryButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(shad.LucideIcons.plus),
                  shad.DensityGap(shad.gapSm),
                  Text('New Bill'),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapSm),

        // Dynamic Metric KPI Cards Row sitting above DAB
        const DynamicMetricRow(
          cards: [
            DynamicMetricCard(
              title: 'Total Plans',
              value: '6 Plans',
              unit: 'Active',
              icon: shad.LucideIcons.fileText,
              trendBadge: shad.PrimaryBadge(child: Text('Live')),
            ),
            DynamicMetricCard(
              title: 'Fabric Meterage',
              value: '1,120',
              unit: 'meters',
              icon: shad.LucideIcons.scissors,
              subtext: 'Banarasi Silk & Georgette',
            ),
            DynamicMetricCard(
              title: 'Total Units',
              value: '49',
              unit: 'units',
              icon: shad.LucideIcons.package,
              subtext: 'Queued for Cutting',
            ),
            DynamicMetricCard(
              title: 'Loom Efficiency',
              value: '94.5',
              unit: '%',
              icon: shad.LucideIcons.gauge,
              trendBadge: shad.SecondaryBadge(child: Text('+2.1%')),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapSm),

        // Dynamic Action Bar with 5-Index Structure
        DynamicActionBar(
          entityName: 'Cards',
          showPagination: _tabIndex != 2, // Tables show pagination, List view hides it
          loadedCount: 50,
          totalCount: 51,
          selectedCount: _selectedRowIndices.length,
          onPreviousPage: () {
            if (_currentPage > 1) setState(() => _currentPage--);
          },
          onNextPage: () {
            setState(() => _currentPage++);
          },
          searchQuery: _searchQuery,
          onSearchChanged: (val) {
            setState(() => _searchQuery = val);
          },
          filters: [
            DabFilterItem(
              id: 'mill',
              label: 'Mill',
              icon: shad.LucideIcons.warehouse,
              selectedValue: _selectedMill,
            ),
            DabFilterItem(
              id: 'fabric',
              label: 'Quality',
              icon: shad.LucideIcons.scissors,
              selectedValue: _selectedFabric,
            ),
            DabFilterItem(
              id: 'status',
              label: 'Status',
              icon: shad.LucideIcons.circleDot,
              selectedValue: _selectedStatus,
            ),
            DabFilterItem(
              id: 'party',
              label: 'Party',
              icon: shad.LucideIcons.building,
              selectedValue: _selectedParty,
            ),
          ],
          onFilterPressed: (filter) {
            shad.showToast(
              context: context,
              builder: (context, show) => shad.Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Filter ${filter.label} clicked.'),
                ),
              ),
            );
          },
          onOverflowFilterPressed: () {
            shad.showToast(
              context: context,
              builder: (context, show) => const shad.Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Overflow filters (3-dots) clicked.'),
                ),
              ),
            );
          },
          selectedDateLabel: _selectedDateValue,
          onDatePressed: () {
            setState(() {
              _selectedDateValue = _selectedDateValue == null ? 'Jul 2026' : null;
            });
          },
          showSort: _tabIndex == 2, // Only show Sort button in List/Card formats
          selectedSortLabel: _selectedSortValue,
          onSortPressed: () {
            setState(() {
              _selectedSortValue = _selectedSortValue == null ? 'Date Desc' : null;
            });
          },
        ),
        const shad.DensityGap(shad.gapSm),

        // Tab View Switcher (Summary, Details, Links, Metrics)
        Expanded(
          child: () {
            switch (_tabIndex) {
              case 0:
                // 1. Summary Tab: Tabular View
                return _buildDetailsTable(theme);
              case 1:
                // 2. Details Tab: Pane View with List + Content Pane + Side Pane
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Master Pane: DynamicList
                    DynamicList(
                      items: _mockItems,
                      selectedItem: _selectedListItem,
                      onItemSelected: (item) {
                        setState(() {
                          _selectedListItem = item;
                        });
                      },
                    ),

                    const shad.DensityGap(shad.gapSm),

                    // Right Detail Pane
                    Expanded(
                      child: _selectedListItem == null
                          ? _buildPlaceholderDetailCard(theme)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ItemHeader(
                                  title: _selectedListItem!.title,
                                  onEditPressed: () {
                                    // Perform edit details
                                  },
                                ),
                                const shad.DensityGap(shad.gapSm),
                                // Grid using DynamicContentPane and DynamicSidePane
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // 1. Dynamic main tab content area (Left Side)
                                      DynamicContentPane(
                                        child: _buildContentAreaForTab(
                                            _tabIndex,
                                            _selectedListItem!,
                                            theme),
                                      ),
                                      const shad.DensityGap(shad.gapSm),
                                      // 2. Action and Timeline metadata Sidebar (Right Side)
                                      DynamicSidePane(
                                        cards: [
                                          DynamicSideCard(
                                            title: 'Workflow Status',
                                            child: TimelineView(
                                              steps: [
                                                TimelineStep(
                                                  title: 'Loom Material Audit',
                                                  description:
                                                      'Completed successfully by supervisor',
                                                  isDone: true,
                                                ),
                                                TimelineStep(
                                                  title:
                                                      'Pattern Stencil Placement',
                                                  description:
                                                      'Verified coordinates and offsets',
                                                  isDone: true,
                                                ),
                                                TimelineStep(
                                                  title:
                                                      'Cutting Phase Execution',
                                                  description:
                                                      'Active process queued on table #4',
                                                  isActive: _selectedListItem!
                                                          .status ==
                                                      'active',
                                                ),
                                                TimelineStep(
                                                  title:
                                                      'Quality Audit Inspection',
                                                  description:
                                                      'Awaiting batch completion',
                                                  isMuted: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          DynamicSideCard(
                                            title: 'Loom Roll Metrics',
                                            child: MetricsView(
                                              metrics: [
                                                MetricItem(
                                                  icon: const Icon(
                                                      shad.LucideIcons.gauge),
                                                  label: 'Total Length',
                                                  value: '250',
                                                  unit: 'meters',
                                                ),
                                                MetricItem(
                                                  icon: const Icon(
                                                      shad.LucideIcons.package),
                                                  label: 'Total Units count',
                                                  value: _selectedListItem!
                                                      .infoNumber,
                                                  unit: 'units',
                                                ),
                                                MetricItem(
                                                  icon: const Icon(
                                                      shad.LucideIcons.hash),
                                                  label: 'Loom Roll ID',
                                                  value:
                                                      'LR-928${_selectedListItem!.infoNumber}',
                                                  unit: 'ID',
                                                ),
                                                MetricItem(
                                                  icon: const Icon(shad
                                                      .LucideIcons.maximize2),
                                                  label: 'Fabric Width',
                                                  value: '110',
                                                  unit: 'cm',
                                                ),
                                                MetricItem(
                                                  icon: const Icon(shad
                                                      .LucideIcons.activity),
                                                  label: 'Loom Efficiency',
                                                  value: '94.5',
                                                  unit: '%',
                                                ),
                                                MetricItem(
                                                  icon: const Icon(shad
                                                      .LucideIcons.settings),
                                                  label: 'Warp Tension',
                                                  value: '85',
                                                  unit: 'cN',
                                                ),
                                              ],
                                            ),
                                          ),
                                          DynamicSideCard(
                                            title: 'Quick Actions',
                                            child: Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: [
                                                _buildActionButton('Hold'),
                                                _buildActionButton('Complete',
                                                    isPrimary: true),
                                                _buildActionButton('Start'),
                                                _buildActionButton('Audit'),
                                                _buildActionButton('Inspect'),
                                                _buildActionButton('Reject'),
                                                _buildActionButton('Pause'),
                                                _buildActionButton('Resume'),
                                                _buildActionButton('Assign'),
                                                _buildActionButton('Export'),
                                                _buildActionButton('Print'),
                                                _buildActionButton('Cancel'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              case 2:
                // 3. Links Tab: Empty Placeholder
                return Center(
                  child: Text(
                    'Links View (Empty Placeholder)',
                    style: theme.typography.h3
                        .copyWith(color: theme.colorScheme.mutedForeground),
                  ),
                );
              case 3:
                // 4. Metrics Tab: Empty Placeholder
                return Center(
                  child: Text(
                    'Metrics View (Empty Placeholder)',
                    style: theme.typography.h3
                        .copyWith(color: theme.colorScheme.mutedForeground),
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          }(),
        ),
      ],
    );
  }

  Widget _buildPlaceholderDetailCard(shad.ThemeData theme) {
    return shad.Card(
      child: Center(
        child: Text(
          'Select an item from the list to view its details',
          style: theme.typography.textMuted,
        ),
      ),
    );
  }

  // Dynamic tab content switcher
  Widget _buildContentAreaForTab(
      int tabIndex, DynamicListItem item, shad.ThemeData theme) {
    switch (tabIndex) {
      case 0:
        return _buildDashboardSpecsView(theme, item);
      case 1:
        return _buildDetailsRollsView(theme, item);
      case 2:
        return _buildLinksDocumentsView(theme, item);
      default:
        return const SizedBox.shrink();
    }
  }

  // Tab 0: Dashboard (Specs & Visual Saree Cut Layout)
  Widget _buildDashboardSpecsView(shad.ThemeData theme, DynamicListItem item) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'Cutting Specifications & Visual Layout',
          style: theme.typography.textLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.foreground,
          ),
        ),
        const shad.DensityGap(shad.gapSm),
        const shad.Divider(),
        const shad.DensityGap(shad.gapSm),

        // Visual Saree Cut Diagram
        Text(
          'Saree Cutting Pattern Diagram',
          style: theme.typography.textSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.foreground,
          ),
        ),
        const shad.DensityGap(shad.gapSm),
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: theme.borderRadiusSm,
            border: Border.all(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: colors.primary.withValues(alpha: 0.15),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pallu',
                          style: theme.typography.textSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        Text(
                          '1.2m',
                          style: theme.typography.textMuted.copyWith(
                            fontSize: 11,
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              VerticalDivider(width: 1, color: colors.border),
              Expanded(
                flex: 7,
                child: Container(
                  color: colors.muted,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Body',
                          style: theme.typography.textSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        Text(
                          '4.5m',
                          style: theme.typography.textMuted.copyWith(
                            fontSize: 11,
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              VerticalDivider(width: 1, color: colors.border),
              Expanded(
                flex: 1,
                child: Container(
                  color: colors.primary.withValues(alpha: 0.08),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Blouse',
                          style: theme.typography.textSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        Text(
                          '0.6m',
                          style: theme.typography.textMuted.copyWith(
                            fontSize: 11,
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const shad.DensityGap(shad.gapLg),

        // Specification Form Parameters
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFormRow(
                    theme, 'Saree Style Type', 'Banarasi Silk Embroidered'),
                _buildFormRow(theme, 'Pattern Stencil Code', 'PST-SILK-098'),
                _buildFormRow(theme, 'Cutting Master Supervisor', 'Ram Singh'),
                _buildFormRow(theme, 'Target Completion Date', 'Jul 24, 2026'),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: theme.density.baseGap * shad.gapMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plan Status',
                        style: theme.typography.textMuted.copyWith(
                          fontSize: 11,
                          color: colors.mutedForeground,
                        ),
                      ),
                      _buildDetailStatusChip(item.status ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormRow(shad.ThemeData theme, String label, String value) {
    final colors = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: theme.density.baseGap * shad.gapMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.typography.textMuted.copyWith(
              fontSize: 11,
              color: colors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: theme.typography.textSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Details (Allocated Rolls Table)
  Widget _buildDetailsRollsView(shad.ThemeData theme, DynamicListItem item) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'Loom Roll Allocation Table',
          style: theme.typography.textLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.foreground,
          ),
        ),
        const shad.DensityGap(shad.gapSm),
        const shad.Divider(),
        const shad.DensityGap(shad.gapSm),

        // Column Headers
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Roll ID',
                style: theme.typography.textMuted.copyWith(
                  fontSize: 11,
                  color: colors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Length',
                style: theme.typography.textMuted.copyWith(
                  fontSize: 11,
                  color: colors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Lot No',
                style: theme.typography.textMuted.copyWith(
                  fontSize: 11,
                  color: colors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Status',
                style: theme.typography.textMuted.copyWith(
                  fontSize: 11,
                  color: colors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapXs),
        const shad.Divider(),
        const shad.DensityGap(shad.gapSm),

        // Allocation Rows
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAllocationTableRow(
                    theme, colors, 'LR-92801', '80 meters', 'LOT-A', 'Cut',
                    isPrimary: true),
                _buildAllocationTableRow(theme, colors, 'LR-92802', '90 meters',
                    'LOT-B', 'Processing',
                    isWarning: true),
                _buildAllocationTableRow(
                    theme, colors, 'LR-92803', '80 meters', 'LOT-A', 'Pending',
                    isMuted: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationTableRow(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String rollId,
    String length,
    String lot,
    String status, {
    bool isPrimary = false,
    bool isWarning = false,
    bool isMuted = false,
  }) {
    Color textColor = colors.foreground;
    if (isPrimary) textColor = colors.primary;
    if (isWarning) textColor = const Color(0xFFF59E0B); // Amber warning
    if (isMuted) textColor = colors.mutedForeground;

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: theme.density.baseGap * shad.gapSm),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  rollId,
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  length,
                  style: theme.typography.textSmall.copyWith(
                    color: colors.foreground,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  lot,
                  style: theme.typography.textSmall.copyWith(
                    color: colors.foreground,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  status,
                  style: theme.typography.textSmall.copyWith(
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapXs),
          const shad.Divider(),
        ],
      ),
    );
  }

  // Tab 2: Links (Associated Orders)
  Widget _buildLinksDocumentsView(shad.ThemeData theme, DynamicListItem item) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'ERP Document Links',
          style: theme.typography.textLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.foreground,
          ),
        ),
        const shad.DensityGap(shad.gapSm),
        const shad.Divider(),
        const shad.DensityGap(shad.gapSm),

        // Document List
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_subTabIndex == 0 || _subTabIndex == 1)
                  _buildDocLinkItem(theme, colors, shad.LucideIcons.fileText,
                      'Production Order', 'PO-2627-012', 'In Progress'),
                if (_subTabIndex == 0 || _subTabIndex == 1)
                  _buildDocLinkItem(
                      theme,
                      colors,
                      shad.LucideIcons.shoppingCart,
                      'Sales Order',
                      'SO-2627-994',
                      'Released',
                      isSuccess: true),
                if (_subTabIndex == 0 || _subTabIndex == 2)
                  _buildDocLinkItem(theme, colors, shad.LucideIcons.ticket,
                      'Loom Allocation Ticket', 'LAT-552', 'Scheduled',
                      isMuted: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocLinkItem(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    IconData icon,
    String category,
    String docNumber,
    String badgeText, {
    bool isSuccess = false,
    bool isMuted = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: theme.density.baseGap * shad.gapMd),
      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const shad.DensityGap(shad.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: theme.typography.textMuted.copyWith(
                    fontSize: 10,
                    color: colors.mutedForeground,
                  ),
                ),
                Text(
                  docNumber,
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                  ),
                ),
              ],
            ),
          ),
          if (isSuccess) ...[
            const shad.OutlineBadge(child: Text('Released')),
          ] else if (isMuted) ...[
            const shad.SecondaryBadge(child: Text('Scheduled')),
          ] else ...[
            const shad.PrimaryBadge(child: Text('In Progress')),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailStatusChip(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const shad.PrimaryBadge(
          child: Text('Active'),
        );
      case 'pending':
        return const shad.SecondaryBadge(
          child: Text('Pending'),
        );
      case 'completed':
        return const shad.OutlineBadge(
          child: Text('Completed'),
        );
      default:
        return shad.SecondaryBadge(
          child: Text(status),
        );
    }
  }

  Widget _buildActionButton(String label, {bool isPrimary = false}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final buttonChild = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: theme.typography.textSmall.copyWith(
          fontSize: 11,
          color: isPrimary ? colors.primaryForeground : colors.foreground,
        ),
      ),
    );
    if (isPrimary) {
      return shad.PrimaryButton(
        onPressed: () {},
        child: buttonChild,
      );
    }
    return shad.OutlineButton(
      onPressed: () {},
      child: buttonChild,
    );
  }

  Widget _buildDetailsTable(shad.ThemeData theme) {
    final colors = theme.colorScheme;

    return DynamicTable<DynamicListItem>(
      selectable: true,
      selectedIndices: _selectedRowIndices,
      onSelectionChanged: (newIndices) {
        setState(() {
          _selectedRowIndices = newIndices;
        });
      },
      currentPage: _currentPage,
      totalPages: 3,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      showFooter: true,
      items: _mockItems,
      columns: [
        // 1. Pattern Image / Avatar
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Pattern'),
          size: const shad.FixedTableSize(72),
          cellBuilder: (context, item, index) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(theme.radiusSm),
                border: Border.all(color: colors.border),
              ),
              child: Center(
                child: Icon(
                  index % 2 == 0
                      ? shad.LucideIcons.scissors
                      : shad.LucideIcons.layers,
                  size: 14,
                  color: colors.primary,
                ),
              ),
            );
          },
          footerBuilder: (context) => const Text('Total'),
        ),

        // 2. Plan ID
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Plan ID'),
          size: const shad.FlexTableSize(flex: 1.2),
          cellBuilder: (context, item, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                  ),
                ),
                Text(
                  '#${item.infoNumber}',
                  style: theme.typography.textMuted.copyWith(
                    fontSize: 10,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            );
          },
          footerBuilder: (context) => Text('${_mockItems.length} Plans'),
        ),

        // 3. Description & Specifications
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Description & Specifications'),
          size: const shad.FlexTableSize(flex: 2.5),
          cellBuilder: (context, item, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.subtitle,
                  style: theme.typography.textSmall.copyWith(
                    color: colors.foreground,
                  ),
                ),
                Text(
                  'Banarasi Silk • PST-SILK-${100 + index}',
                  style: theme.typography.textMuted.copyWith(
                    fontSize: 10,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            );
          },
        ),

        // 4. Created Date
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Created'),
          size: const shad.FlexTableSize(flex: 1.2),
          cellBuilder: (context, item, index) => Text(item.date),
        ),

        // 5. Meterage (Numeric Right-Aligned)
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Meterage'),
          size: const shad.FlexTableSize(flex: 1.2),
          isNumeric: true,
          cellBuilder: (context, item, index) {
            final meters = (150 + index * 35).toString();
            return Text('$meters m',
                style: const TextStyle(fontWeight: FontWeight.bold));
          },
          footerBuilder: (context) => Text(
            '1,120 m',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: colors.primary),
          ),
        ),

        // 6. Units (Numeric Right-Aligned)
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Units'),
          size: const shad.FlexTableSize(flex: 1.0),
          isNumeric: true,
          cellBuilder: (context, item, index) => Text(item.infoNumber),
          footerBuilder: (context) => const Text('49 units',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        // 7. Status Badge
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Status'),
          size: const shad.FlexTableSize(flex: 1.2),
          cellBuilder: (context, item, index) {
            final safeStatus = (item.status ?? 'active').toLowerCase();
            switch (safeStatus) {
              case 'active':
                return const shad.PrimaryBadge(child: Text('Active'));
              case 'pending':
                return const shad.SecondaryBadge(child: Text('Pending'));
              case 'completed':
                return const shad.OutlineBadge(child: Text('Completed'));
              default:
                return shad.SecondaryBadge(child: Text(safeStatus));
            }
          },
        ),

        // 8. Actions
        DynamicTableColumn<DynamicListItem>(
          header: const Text('Actions'),
          size: const shad.FlexTableSize(flex: 1.2),
          isNumeric: true,
          cellBuilder: (context, item, index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                shad.IconButton.ghost(
                  size: shad.ButtonSize.small,
                  icon: const Icon(shad.LucideIcons.eye, size: 14),
                  onPressed: () {},
                ),
                shad.IconButton.ghost(
                  size: shad.ButtonSize.small,
                  icon: const Icon(shad.LucideIcons.pencil, size: 14),
                  onPressed: () {},
                ),
                shad.IconButton.ghost(
                  size: shad.ButtonSize.small,
                  icon: const Icon(shad.LucideIcons.trash2, size: 14),
                  onPressed: () {},
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
