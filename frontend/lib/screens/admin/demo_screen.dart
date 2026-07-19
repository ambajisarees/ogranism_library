import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../ant_design/widgets/page_header.dart';
import '../../ant_design/widgets/dab/dynamic_action_bar.dart';
import '../../ant_design/widgets/list/dynamic_list.dart';
import '../../ant_design/widgets/list/dynamic_list_card.dart';
import '../../ant_design/widgets/list/item_header.dart';
import '../../ant_design/widgets/list/timeline.dart';
import '../../ant_design/widgets/list/metric_card.dart';
import '../../ant_design/widgets/list/metric_card_list.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _tabIndex = 0;
  String? _selectedFilterValue;
  String? _selectedDateValue;
  String? _selectedSortValue;

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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: Padding(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            PageHeader(
              icon: const Icon(shad.LucideIcons.scissors),
              title: 'Demo Workspace (H3)',
              subtitle: 'Manage your textile cutting patterns and workspace (small.muted)',
              actions: [
                shad.OutlineButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(shad.LucideIcons.download),
                      shad.DensityGap(shad.gapSm),
                      Text('Export (textSmall)'),
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
                      Text('Add (textSmall)'),
                    ],
                  ),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),
            
            // Dynamic Action Bar
            DynamicActionBar(
              tabIndex: _tabIndex,
              onTabChanged: (val) {
                setState(() => _tabIndex = val);
              },
              selectedDateValue: _selectedDateValue,
              onDateChanged: (val) {
                setState(() => _selectedDateValue = val);
              },
              selectedFilterValue: _selectedFilterValue,
              onFilterChanged: (val) {
                setState(() => _selectedFilterValue = val);
              },
              selectedSortValue: _selectedSortValue,
              onSortChanged: (val) {
                setState(() => _selectedSortValue = val);
              },
            ),
            const shad.DensityGap(shad.gapSm),

            // Master-Detail Row (Aligned Left)
            Expanded(
              child: Row(
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
                  
                  // Right Detail Pane (Option B: Main content on Left, Sidebar on Right)
                  Expanded(
                    child: _selectedListItem == null
                        ? _buildPlaceholderDetailCard(theme)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ItemHeader(
                                title: '${_selectedListItem!.title} (H3)',
                                onEditPressed: () {
                                  // Perform edit details
                                },
                              ),
                              const shad.DensityGap(shad.gapSm),
                              // Option B Grid
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // 1. Dynamic main tab content area (Left Side)
                                    Expanded(
                                      child: _buildContentAreaForTab(_tabIndex, _selectedListItem!, theme),
                                    ),
                                    const shad.DensityGap(shad.gapSm),
                                    // 2. Action and Timeline metadata Sidebar (Right Side)
                                    SizedBox(
                                      width: 280,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Timeline Card (Expanded to take remaining height)
                                          Expanded(
                                            child: Timeline(
                                              title: 'Workflow Status (textLarge.bold)',
                                              steps: [
                                                TimelineStep(
                                                  title: 'Loom Material Audit (textSmall.bold)',
                                                  description: 'Completed successfully by supervisor (textMuted 11)',
                                                  isDone: true,
                                                ),
                                                TimelineStep(
                                                  title: 'Pattern Stencil Placement (textSmall.bold)',
                                                  description: 'Verified coordinates and offsets (textMuted 11)',
                                                  isDone: true,
                                                ),
                                                TimelineStep(
                                                  title: 'Cutting Phase Execution (textSmall.bold)',
                                                  description: 'Active process queued on table #4 (textMuted 11)',
                                                  isActive: _selectedListItem!.status == 'active',
                                                ),
                                                TimelineStep(
                                                  title: 'Quality Audit Inspection (textSmall.bold)',
                                                  description: 'Awaiting batch completion (textMuted 11)',
                                                  isMuted: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const shad.DensityGap(shad.gapSm),
                                          // Metrics Card List
                                          MetricCardList(
                                            title: 'Loom Roll Metrics (textLarge.bold)',
                                            metrics: [
                                              MetricItem(
                                                icon: const Icon(shad.LucideIcons.gauge),
                                                label: 'Total Length (textMuted 11)',
                                                value: '250 (textLarge.bold)',
                                                unit: 'meters (textMuted 12)',
                                              ),
                                              MetricItem(
                                                icon: const Icon(shad.LucideIcons.package),
                                                label: 'Total Units count (textMuted 11)',
                                                value: '${_selectedListItem!.infoNumber} (textLarge.bold)',
                                                unit: 'units (textMuted 12)',
                                              ),
                                              MetricItem(
                                                icon: const Icon(shad.LucideIcons.hash),
                                                label: 'Loom Roll ID (textMuted 11)',
                                                value: 'LR-928${_selectedListItem!.infoNumber} (textLarge.bold)',
                                                unit: 'ID (textMuted 12)',
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
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderDetailCard(shad.ThemeData theme) {
    return shad.Card(
      child: Center(
        child: Text(
          'Select an item from the list to view its details (textMuted)',
          style: theme.typography.textMuted,
        ),
      ),
    );
  }

  // Dynamic tab content switcher
  Widget _buildContentAreaForTab(int tabIndex, DynamicListItem item, shad.ThemeData theme) {
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
    return shad.Card(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Cutting Specifications & Visual Layout (textLarge.bold)',
            style: theme.typography.textLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const shad.DensityGap(shad.gapSm),
          const shad.Divider(),
          const shad.DensityGap(shad.gapSm),
          
          // Visual Saree Cut Diagram
          Text(
            'Saree Cutting Pattern Diagram (textSmall.bold)',
            style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
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
                          Text('Pallu (textSmall.bold)', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                          Text('1.2m (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11)),
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
                          Text('Body (textSmall.bold)', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                          Text('4.5m (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11)),
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
                          Text('Blouse (textSmall.bold)', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                          Text('0.6m (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11)),
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
                  _buildFormRow(theme, 'Saree Style Type (textMuted 11)', 'Banarasi Silk Embroidered (textSmall.bold)'),
                  _buildFormRow(theme, 'Pattern Stencil Code (textMuted 11)', 'PST-SILK-098 (textSmall.bold)'),
                  _buildFormRow(theme, 'Cutting Master Supervisor (textMuted 11)', 'Ram Singh (textSmall.bold)'),
                  _buildFormRow(theme, 'Target Completion Date (textMuted 11)', 'Jul 24, 2026 (textSmall.bold)'),
                  Padding(
                    padding: EdgeInsets.only(bottom: theme.density.baseGap * shad.gapMd),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan Status (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11)),
                        _buildDetailStatusChip(item.status ?? 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(shad.ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: theme.density.baseGap * shad.gapMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.typography.textMuted.copyWith(fontSize: 11)),
          Text(value, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Tab 1: Details (Allocated Rolls Table)
  Widget _buildDetailsRollsView(shad.ThemeData theme, DynamicListItem item) {
    final colors = theme.colorScheme;
    return shad.Card(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Loom Roll Allocation Table (textLarge.bold)',
            style: theme.typography.textLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const shad.DensityGap(shad.gapSm),
          const shad.Divider(),
          const shad.DensityGap(shad.gapSm),
          
          // Column Headers
          Row(
            children: [
              Expanded(flex: 3, child: Text('Roll ID (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11))),
              Expanded(flex: 2, child: Text('Length (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11))),
              Expanded(flex: 2, child: Text('Lot No (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11))),
              Expanded(flex: 2, child: Text('Status (textMuted 11)', style: theme.typography.textMuted.copyWith(fontSize: 11))),
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
                  _buildAllocationTableRow(theme, colors, 'LR-92801 (textSmall.bold)', '80 meters (textSmall)', 'LOT-A (textSmall)', 'Cut (textSmall)', isPrimary: true),
                  _buildAllocationTableRow(theme, colors, 'LR-92802 (textSmall.bold)', '90 meters (textSmall)', 'LOT-B (textSmall)', 'Processing (textSmall)', isWarning: true),
                  _buildAllocationTableRow(theme, colors, 'LR-92803 (textSmall.bold)', '80 meters (textSmall)', 'LOT-A (textSmall)', 'Pending (textSmall)', isMuted: true),
                ],
              ),
            ),
          ),
        ],
      ),
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
      padding: EdgeInsets.symmetric(vertical: theme.density.baseGap * shad.gapSm),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: Text(rollId, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: textColor))),
              Expanded(flex: 2, child: Text(length, style: theme.typography.textSmall)),
              Expanded(flex: 2, child: Text(lot, style: theme.typography.textSmall)),
              Expanded(flex: 2, child: Text(status, style: theme.typography.textSmall.copyWith(color: textColor))),
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
    return shad.Card(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'ERP Document Links (textLarge.bold)',
            style: theme.typography.textLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const shad.DensityGap(shad.gapSm),
          const shad.Divider(),
          const shad.DensityGap(shad.gapSm),
          
          // Document List
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDocLinkItem(theme, colors, shad.LucideIcons.fileText, 'Production Order (textMuted 11)', 'PO-2627-012 (textSmall.bold)', 'In Progress (badge)'),
                  _buildDocLinkItem(theme, colors, shad.LucideIcons.shoppingCart, 'Sales Order (textMuted 11)', 'SO-2627-994 (textSmall.bold)', 'Released (badge)', isSuccess: true),
                  _buildDocLinkItem(theme, colors, shad.LucideIcons.ticket, 'Loom Allocation Ticket (textMuted 11)', 'LAT-552 (textSmall.bold)', 'Scheduled (badge)', isMuted: true),
                ],
              ),
            ),
          ),
        ],
      ),
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
                Text(category, style: theme.typography.textMuted.copyWith(fontSize: 10)),
                Text(docNumber, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isSuccess) ...[
            const shad.OutlineBadge(child: Text('Released (badge)')),
          ] else if (isMuted) ...[
            const shad.SecondaryBadge(child: Text('Scheduled (badge)')),
          ] else ...[
            const shad.PrimaryBadge(child: Text('In Progress (badge)')),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailStatusChip(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const shad.PrimaryBadge(
          child: Text('Active (textSmall)'),
        );
      case 'pending':
        return const shad.SecondaryBadge(
          child: Text('Pending (textSmall)'),
        );
      case 'completed':
        return const shad.OutlineBadge(
          child: Text('Completed (textSmall)'),
        );
      default:
        return shad.SecondaryBadge(
          child: Text('$status (textSmall)'),
        );
    }
  }
}
