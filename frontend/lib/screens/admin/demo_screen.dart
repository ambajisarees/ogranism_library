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
import '../../ant_design/widgets/list/form_data_list.dart';

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
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: Padding(
        padding:
            EdgeInsets.all(theme.density.baseContainerPadding * shad.padLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            PageHeader(
              icon: const Icon(shad.LucideIcons.scissors),
              title: 'Demo Workspace',
              subtitle: 'Manage your textile cutting patterns and workspace',
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
                      Text('Add'),
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

                  // Right Detail Column composed of ItemHeader & Details Row
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
                              // Grid of Timeline, Metrics and Form Data lists
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // 1. Timeline Card (Left side)
                                    Timeline(
                                      title: 'Workflow Status',
                                      steps: [
                                        TimelineStep(
                                          title: 'Loom Material Audit',
                                          description:
                                              'Completed successfully by supervisor',
                                          isDone: true,
                                        ),
                                        TimelineStep(
                                          title: 'Pattern Stencil Placement',
                                          description:
                                              'Verified coordinates and offsets',
                                          isDone: true,
                                        ),
                                        TimelineStep(
                                          title: 'Cutting Phase Execution',
                                          description:
                                              'Active process queued on table #4',
                                          isActive: _selectedListItem!.status ==
                                              'active',
                                        ),
                                        TimelineStep(
                                          title: 'Quality Audit Inspection',
                                          description:
                                              'Awaiting batch completion',
                                          isMuted: true,
                                        ),
                                      ],
                                    ),
                                    const shad.DensityGap(shad.gapSm),
                                    // 2. Metrics Card List (Middle side)
                                    MetricCardList(
                                      title: 'Loom Roll Metrics',
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
                                          value: _selectedListItem!.infoNumber,
                                          unit: 'units',
                                        ),
                                        MetricItem(
                                          icon:
                                              const Icon(shad.LucideIcons.hash),
                                          label: 'Loom Roll ID',
                                          value:
                                              'LR-928${_selectedListItem!.infoNumber}',
                                          unit: 'ID',
                                        ),
                                      ],
                                    ),
                                    const shad.DensityGap(shad.gapSm),
                                    // 3. Form Data Card List (Right side, Expanded)
                                    Expanded(
                                      child: FormDataList(
                                        title: 'Plan Information',
                                        fields: [
                                          FormDataItem(
                                            label: 'Plan Title',
                                            value: _selectedListItem!.title,
                                          ),
                                          FormDataItem(
                                            label: 'Loom Details',
                                            value: _selectedListItem!.subtitle,
                                          ),
                                          FormDataItem(
                                            label: 'Index Number',
                                            value:
                                                _selectedListItem!.indexNumber,
                                          ),
                                          FormDataItem(
                                            label: 'Status',
                                            value: _selectedListItem!.status ??
                                                'N/A',
                                            valueWidget: _buildDetailStatusChip(
                                                _selectedListItem!.status ??
                                                    'N/A'),
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
          'Select an item from the list to view its details',
          style: theme.typography.textMuted,
        ),
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
}
