import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../../tissues.dart';
import '../widgets/library_section.dart';

class TissuesView extends StatefulWidget {
  const TissuesView({super.key});

  @override
  State<TissuesView> createState() => _TissuesViewState();
}

class _TissuesViewState extends State<TissuesView> {
  DateTime? _selectedDate;
  String? _selectedValue;
  String? _selectedSelectValue;
  int _activeTabIndex = 0;
  int _stepperValue = 10;
  
  DateTimeRange? _dashboardDateRange;
  String _inlineEditValue = 'Mahadev Fashion';

  late final List<PlutoColumn> _gridColumns;
  late final List<PlutoRow> _gridRows;

  @override
  void initState() {
    super.initState();
    _gridColumns = [
      PlutoColumn(title: 'Code', field: 'code', type: PlutoColumnType.text(), frozen: PlutoColumnFrozen.start),
      PlutoColumn(title: 'Quality', field: 'quality', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Meters', field: 'meters', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Price', field: 'price', type: PlutoColumnType.currency(symbol: '₹')),
    ];
    _gridRows = [
      PlutoRow(cells: {
        'code': PlutoCell(value: 'S201'),
        'quality': PlutoCell(value: 'Dola Silk'),
        'meters': PlutoCell(value: 80.50),
        'price': PlutoCell(value: 2450.0),
      }),
      PlutoRow(cells: {
        'code': PlutoCell(value: 'S202'),
        'quality': PlutoCell(value: 'Vichitra Fancy'),
        'meters': PlutoCell(value: 120.0),
        'price': PlutoCell(value: 1850.0),
      }),
    ];
  }


  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTissuesSection(colors),
        _buildActionGroupingSection(colors),
        _buildDataMoleculesSection(colors),
        _buildContextDecoratorsSection(colors),
        _buildRegistryControllersSection(colors),
        _buildListCardsSection(colors),
        _buildDashboardSection(colors),
        _buildERPHeavyweightsSection(colors),
        _buildAdvancedWorkflowsSection(colors),
      ],
    );
  }

  Widget _buildTissuesSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Functional Containers & Forms',
      subtitle: 'Higher density layout structures for ERP data entry.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/card.dart',
              description: 'Compound surface aggregating Title, Density standard Padding, and Semantic Layouts.',
              child: TissueCard(
                children: [
                  const TissueCardHeader(
                    title: 'TissueCard (Density Standard)',
                    description: 'Standard ERP surface logic.',
                  ),
                  const TissueCardContent(
                    child: TissueReadOnlyField(
                        label: 'Unique Hash', value: 'f72-99-A0'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/form_field.dart',
              description: 'Higher order composites marrying CellInputs with Label hierarchies and Validation.',
              child: Column(
                children: [
                  const TissueFormField(
                    label: 'Client Legal Entity',
                    isRequired: true,
                    inputCell: CellInput(placeholder: 'e.g. Reliance Retail'),
                  ),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  TissueDateField(
                    label: 'Bill Date',
                    value: _selectedDate,
                    onChanged: (d) => setState(() => _selectedDate = d),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGroupingSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Action Grouping',
      subtitle: 'Higher-level molecules for organizing complex task flows.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TissueButtonBar: Header Layout', style: OrganismTheme.labelLarge(context).copyWith(color: colors.textSecondary)),
          const SizedBox(height: OrganismTheme.spacingMd),
          LibraryComponentDoc(
            filePath: 'organism_design/tissues/button_bar.dart',
            description: 'Horizontal alignment engine for context actions, forcing standard spacing.',
            child: CellBox(
              padding: const EdgeInsets.all(OrganismTheme.spacingMd),
              child: Row(
                children: [
                  const Expanded(child: Text('Registry Navigation')),
                  TissueButtonBar(
                    children: [
                      CellButton(icon: LucideIcons.refreshCw, variant: CellButtonVariant.outline, isCompact: true, onPressed: () {}),
                      CellButton(text: 'Export', icon: LucideIcons.download, variant: CellButtonVariant.outline, isCompact: true, onPressed: () {}),
                      CellButton(text: 'New Entry', icon: LucideIcons.plus, variant: CellButtonVariant.primary, isCompact: true, onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingXl),
          Text('TissueMenu: Floating Context', style: OrganismTheme.labelLarge(context).copyWith(color: colors.textSecondary)),
          const SizedBox(height: OrganismTheme.spacingMd),
          LibraryComponentDoc(
            filePath: 'organism_design/tissues/actions/menu.dart',
            description: 'Popover wrapper mapping standard arrays of actions to a single trigger.',
            child: TissueMenu(
              items: [
                TissueMenuItemData(label: 'Edit Record', icon: LucideIcons.edit2, onTap: () {}),
                TissueMenuItemData(label: 'Archive', icon: LucideIcons.archive, onTap: () {}),
                TissueMenuItemData(label: 'Delete', icon: LucideIcons.trash2, isDestructive: true, onTap: () {}),
              ],
              child: CellButton(
                text: 'Bulk Actions',
                variant: CellButtonVariant.outline,
                trailingIcon: LucideIcons.chevronDown,
                isCompact: true,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataMoleculesSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Analytic Controls',
      subtitle:
          'Complex UI molecules for state navigation and value adjustment.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: OrganismTheme.spacingLg,
            runSpacing: OrganismTheme.spacingLg,
            children: [
              SizedBox(
                width: 420,
                child: LibraryComponentDoc(
                  filePath: 'organism_design/tissues/tabs.dart',
                  description: 'Pill-style layout navigation for high-level sectioning.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tab Navigation',
                          style: OrganismTheme.labelLarge(context)
                              .copyWith(color: colors.textSecondary)),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      TissueTabs(
                        tabs: const ['Overview', 'Invoices', 'Logs'],
                        initialIndex: _activeTabIndex,
                        onChanged: (i) => setState(() => _activeTabIndex = i),
                      ),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: colors.stone100,
                          borderRadius: OrganismTheme.borderSm,
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        child: Text('Viewing Tab: $_activeTabIndex',
                            style: OrganismTheme.bodySmall(context)
                                .copyWith(color: colors.textMuted)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 420,
                child: LibraryComponentDoc(
                  filePath: 'organism_design/tissues/form/select.dart',
                  description: 'Abstracted dropdown orchestrator standardizing choice interfaces.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Value Adjustments',
                          style: OrganismTheme.labelLarge(context)
                              .copyWith(color: colors.textSecondary)),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      TissueStepper(
                        value: _stepperValue,
                        onChanged: (v) => setState(() => _stepperValue = v),
                      ),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      TissueSelect<String>(
                        label: 'Target Scheme',
                        value: _selectedSelectValue,
                        placeholder: 'Choose scheme...',
                        items: const ['IMMBE2627', 'IMMBE2526'],
                        itemLabelBuilder: (s) => s,
                        onChanged: (v) =>
                            setState(() => _selectedSelectValue = v),
                      ),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      Text('High-Fidelity Dropdown (New)',
                          style: OrganismTheme.labelLarge(context)
                               .copyWith(color: colors.textSecondary)),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      TissueDropdown<String>(
                        placeholder: 'Search & Select...',
                        items: const ['Reliance Retail', 'Adani Exports', 'Tata Textiles', 'Ambaji Sarees'],
                        value: _selectedValue,
                        itemLabelBuilder: (s) => s,
                        onChanged: (v) => setState(() => _selectedValue = v),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OrganismTheme.spacingXl),
          LibraryComponentDoc(
            filePath: 'organism_design/tissues/pipeline.dart',
            description: 'Horizontal linear stepper mapping EMPIRE series stages (O3 -> O4 -> etc).',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Process Pipelines',
                    style: OrganismTheme.labelLarge(context)
                        .copyWith(color: colors.textSecondary)),
                const SizedBox(height: OrganismTheme.spacingMd),
                const TissuePipeline(
                  stages: [
                    PipelineStageData(label: 'O3 Cutting', isCompleted: true),
                    PipelineStageData(label: 'O4 In House', isActive: true),
                    PipelineStageData(label: 'O7 Diamond', isCompleted: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextDecoratorsSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Status & Semantics',
      subtitle: 'Informational overlays and placeholders.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          const SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/alert.dart',
              description: 'Callout block for process updates and critical state warnings.',
              child: TissueAlert(
                title: 'Cloud Sync Active',
                message: 'Fetching ledger movements.',
                variant: CellBadgeVariant.primary,
                icon: LucideIcons.refreshCw,
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/empty.dart',
              description: 'Standardized placeholder for no-data states.',
              child: SizedBox(
                height: 220,
                child: TissueEmptyState(
                  title: 'No Data Found',
                  message: 'Check fiscal year selection.',
                  icon: LucideIcons.search,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistryControllersSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Registry Controllers',
      subtitle: 'High-density navigation and filtering molecules.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryComponentDoc(
            filePath: 'organism_design/tissues/pagination.dart',
            description: 'Consolidated 32px bar merging status, navigation, filtering and sorting.',
            child: TissuePagination(
              currentPage: 1,
              totalPages: 50,
              totalCount: 1248,
              limit: 50,
              onPageChanged: (p) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCardsSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Registry Standards',
      subtitle: 'Standard building blocks for registry listing.',
      child: SizedBox(
        width: double.infinity,
        child: LibraryComponentDoc(
          filePath: 'organism_design/tissues/lists/list_card.dart',
          description: 'Elevated list tile variants specialized for grid registries and complex rows.',
          child: Column(
            children: [
              TissueListCard(
                title: Text('Mahadev Fashion',
                    style: OrganismTheme.titleMedium(context)
                        .copyWith(color: colors.textPrimary)),
                subtitle: Text('VNO: V/000124 | QUALITY: Dola Silk',
                    style: OrganismTheme.bodySmall(context)
                        .copyWith(color: colors.textSecondary)),
                trailing: const CellBadge(
                    text: 'Closed', variant: CellBadgeVariant.success),
                onTap: () {},
                isSelected: true,
              ),
              const SizedBox(height: OrganismTheme.spacingMd),
              TissueListCard(
                title: Text('RK Trading Co.',
                    style: OrganismTheme.titleMedium(context)
                        .copyWith(color: colors.textPrimary)),
                subtitle: Text('VNO: V/000125 | QUALITY: Vichitra Fancy',
                    style: OrganismTheme.bodySmall(context)
                        .copyWith(color: colors.textSecondary)),
                trailing: const CellBadge(
                    text: 'Pending', variant: CellBadgeVariant.warning),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Dashboard & Data Display',
      subtitle: 'Analytic markers, chronologies, and data visualization primitives.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/kpi_card.dart',
              description: 'Dashboard KPI tile injected with robust lightweight sparklines.',
              child: const TissueKpiCard(
                label: 'Monthly Sales Volume',
                value: '₹ 1.2M',
                deltaText: '+14%',
                isPositive: true,
                sparklineData: [4, 6, 5, 8, 9, 12, 10, 15, 14],
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/timeline.dart',
              description: 'Chronological event tracer for audit trails and lifecycle tracking.',
              child: const TissueTimeline(
                nodes: [
                  TimelineNodeData(title: 'Order Dispatched', description: 'O7 Diamond Stage via Carrier.', timestamp: '10:00 AM'),
                  TimelineNodeData(title: 'Quality Check', description: 'Passed initial threading check.', timestamp: '12:30 PM', isCompleted: false, isLast: true),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/inline_edit.dart',
              description: 'Rapid-fire Click-To-Edit typography replacing heavy form fields.',
              child: CellBox(
                padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Party Name', style: OrganismTheme.labelMedium(context)),
                    TissueInlineEdit(
                      initialValue: _inlineEditValue,
                      onSave: (v) => setState(() => _inlineEditValue = v),
                      textStyle: OrganismTheme.titleLarge(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/date_range_picker.dart',
              description: 'Preset-driven dual date boundary selector bypassing native fullscreens.',
              child: TissueDateRangeField(
                label: 'Reporting Period',
                value: _dashboardDateRange,
                onChanged: (v) => setState(() => _dashboardDateRange = v),
                presets: [
                  DatePreset(label: 'Today', getRange: () => DateTimeRange(start: DateTime.now(), end: DateTime.now())),
                  DatePreset(label: 'This Month', getRange: () => DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, 1), end: DateTime.now())),
                  DatePreset(label: 'FY 25-26', getRange: () => DateTimeRange(start: DateTime(2025, 4, 1), end: DateTime(2026, 3, 31))),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/comments.dart',
              description: 'Threaded annotation stack for production logging.',
              child: TissueComments(
                comments: const [
                  CommentData(authorName: 'Smit', content: 'Design #A01 sent for Diamond fixing, please verify stitch quality upon return.', timestamp: '2h ago'),
                ],
                onCommentSubmitted: (v) {
                  // Simulate add
                  debugPrint("Submitted: $v");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildERPHeavyweightsSection(OrganismColors colors) {
    return LibrarySection(
      title: 'ERP Heavyweights',
      subtitle: 'Complex foundational engines natively wrapping external robust packages.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          SizedBox(
            width: double.infinity,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/data_grid.dart',
              description: 'Theme-enforced wrapper for pluto_grid allowing virtualized lists.',
              child: SizedBox(
                height: 300,
                child: TissueDataGrid(
                  columns: _gridColumns,
                  rows: _gridRows,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/command_palette.dart',
              description: 'Modal command executor for rapid jumping via Cmd+K.',
              child: CellButton(
                text: 'Launch Command Palette',
                icon: LucideIcons.command,
                onPressed: () {
                  TissueCommandPalette.show(
                    context,
                    actions: [
                      CommandPaletteAction(id: '1', label: 'New Party Entry', subtitle: 'Account Master', icon: LucideIcons.userPlus, onSelect: () {}),
                      CommandPaletteAction(id: '2', label: 'Create Bill', subtitle: 'Sales Master', icon: LucideIcons.fileText, onSelect: () {}),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/file_upload.dart',
              description: 'Cross-platform native drag and drop fallback wrapping desktop_drop.',
              child: TissueFileUpload(
                label: 'Drop Saree Artwork',
                subtitle: 'Accepts JPEG and PNG. Limit 10MB.',
                onFilesSelected: (files) {},
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/image_gallery.dart',
              description: 'Standalone grid of thumbnails expanding into a PhotoView lightbox carousel.',
              child: const TissueImageGallery(
                imageUrls: [
                  'https://picsum.photos/seed/erp1/400/600',
                  'https://picsum.photos/seed/erp2/400/600',
                  'https://picsum.photos/seed/erp3/400/600',
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAdvancedWorkflowsSection(OrganismColors colors) {
    return LibrarySection(
      title: 'Advanced Workflows & Production',
      subtitle: 'Tissues injected to drive EMPIRE stage migrations, scanners, and complex list ops.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          SizedBox(
            width: double.infinity,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/filter_bar.dart',
              description: 'Horizontal filter strip capturing active chips and mass deletion triggers.',
              child: TissueFilterBar(
                filters: const [
                  TissueFilterNode(id: '1', label: 'Last 30 Days'),
                  TissueFilterNode(id: '2', label: 'Party: Reliance'),
                ],
                onFilterRemoved: (id) {},
                onClearAll: () {},
                onAddFilter: () {},
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/bulk_action_bar.dart',
              description: 'Floating pill-dock appearing centrally during datagrid multi-selection.',
              child: Container(
                height: 120, // Give it height so the alignment works visually
                decoration: BoxDecoration(border: Border.all(color: colors.borderSubtle)),
                child: TissueBulkActionBar(
                  selectedCount: 47,
                  onClear: () {},
                  actions: [
                    CellButton(icon: LucideIcons.download, variant: CellButtonVariant.ghost, isCompact: true, onPressed: () {}),
                    CellButton(icon: LucideIcons.trash, variant: CellButtonVariant.ghost, isCompact: true, onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/wizard.dart',
              description: 'PageView driven atomic steps guarded by asynchronous validations.',
              child: SizedBox(
                height: 260,
                child: TissueWizard(
                  steps: [
                    TissueWizardStep(title: 'Basic Context', content: const Center(child: Text('Step 1. Configure the primary data entity.'))),
                    TissueWizardStep(title: 'KYC Checks', content: const Center(child: Text('Step 2. Assign standard compliance logs.'))),
                  ],
                  onFinish: () {},
                  onCancel: () {},
                ),
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/barcode_scanner.dart',
              description: 'Input interceptor mapping wedge gun carriage loops.',
              child: TissueBarcodeScanner(
                onScanned: (s) => debugPrint(s),
              ),
            ),
          ),
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/breadcrumb.dart',
              description: 'Master Detail horizontal deep link stringifier.',
              child: TissueBreadcrumb(
                nodes: [
                  TissueBreadcrumbNode(label: 'Masters', onTap: () {}),
                  TissueBreadcrumbNode(label: 'Inventory', onTap: () {}),
                  const TissueBreadcrumbNode(label: 'SAR-999-DX'),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/kanban.dart',
              description: 'Horizontal stretchy Stage pipeline, mapping dispatch to receive blocks.',
              child: SizedBox(
                height: 300,
                child: TissueKanbanBoard(
                  columns: [
                    TissueKanbanColumnData(
                      title: 'Work In House',
                      items: [CellBox(padding: const EdgeInsets.all(12), child: Text('Slip #1092'))]
                    ),
                    TissueKanbanColumnData(
                      title: 'Diamond Dispatch',
                      items: [CellBox(padding: const EdgeInsets.all(12), child: Text('Slip #1094'))]
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Accordion group
          SizedBox(
            width: 420,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/accordion_group.dart',
              description: 'Controls Single Open states for TissueAccordion elements.',
              child: TissueAccordionGroup(
                children: [
                  TissueAccordion(title: 'Network Setup', content: const Padding(padding: EdgeInsets.all(8), child: Text('IP Configurations'))),
                  TissueAccordion(title: 'Database Syncer', content: const Padding(padding: EdgeInsets.all(8), child: Text('Airbyte Credentials'))),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 380,
            child: LibraryComponentDoc(
              filePath: 'organism_design/tissues/menu_group.dart',
              description: 'Logical grouping of CellMenuItems with optional titles and dividers.',
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: OrganismTheme.borderMd,
                ),
                child: Column(
                  children: [
                    const TissueMenuGroup(
                      title: 'Edit Options',
                      children: [
                        CellMenuItem(label: 'Draft', icon: LucideIcons.fileText),
                        CellMenuItem(label: 'Submit for Approval', icon: LucideIcons.checkCircle2),
                      ],
                    ),
                    const TissueMenuGroup(
                      showDivider: true,
                      children: [
                        CellMenuItem(label: 'Archive', icon: LucideIcons.archive, isDestructive: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
