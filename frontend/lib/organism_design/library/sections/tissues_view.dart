import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../index.dart';
import '../widgets/library_header.dart';

class TissuesView extends StatefulWidget {
  const TissuesView({super.key});

  @override
  State<TissuesView> createState() => _TissuesViewState();
}

class _TissuesViewState extends State<TissuesView> {
  DateTime? _selectedDate;
  String? _selectedValue;
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LibraryHeader(
          title: 'Level 3: Tissues (Molecular Layouts)',
          description: 'Combining raw Cells into composable structural boundaries and data modules.',
        ),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildTissuesSection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildDataMoleculesSection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildContextDecoratorsSection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildListCardsSection(),
      ],
    );
  }

  Widget _buildTissuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Functional Containers & Forms', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TissueCard(
                children: [
                   const TissueCardHeader(
                    title: 'Density Container (TissueCard)',
                    description: 'Standard ERP data density rules applied here.',
                  ),
                  const TissueCardContent(
                    child: TissueReadOnlyField(label: 'Unique Hash', value: 'f72-99-A0'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: OrganismTheme.spacing2Xl),
            Expanded(
              child: Column(
                children: [
                  const TissueFormField(
                    label: 'Client Legal Entity Name',
                    isRequired: true,
                    inputCell: CellInput(placeholder: 'e.g. Reliance Retail'),
                  ),
                  const SizedBox(height: OrganismTheme.spacingLg),
                  TissueFormField(
                    label: 'Fiscal Year Target',
                    inputCell: TissueDropdown<String>(
                      value: _selectedValue,
                      items: const ['IMMBE2425', 'IMMBE2526', 'IMMBE2627'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedValue = v),
                      placeholder: 'Select Year',
                    ),
                  ),
                  const SizedBox(height: OrganismTheme.spacingLg),
                  TissueDatePicker(
                    label: 'Bill Date',
                    value: _selectedDate,
                    onChanged: (d) => setState(() => _selectedDate = d),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDataMoleculesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Complex UI Controls', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TissueTabs(
                    tabs: const ['History', 'Metadata', 'Logs'],
                    initialIndex: _activeTabIndex,
                    onChanged: (i) => setState(() => _activeTabIndex = i),
                  ),
                  IndexedStack(
                    index: _activeTabIndex,
                    children: const [
                      Padding(padding: EdgeInsets.all(16), child: Text('Audit history will appear here...')),
                      Padding(padding: EdgeInsets.all(16), child: Text('Raw object metadata view.')),
                      Padding(padding: EdgeInsets.all(16), child: Text('Live system sync logs.')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: OrganismTheme.spacing2Xl),
            Column(
              children: [
                TissuePagination(
                  currentPage: 1,
                  totalPages: 10,
                  totalRecords: 1391,
                  itemsPerPage: 10,
                  onPageChanged: (p) {},
                ),
                const SizedBox(height: OrganismTheme.spacing2Xl),
                const TissueAccordion(
                  title: 'Advanced Filtering Settings',
                  content: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Toggle advanced search parameters to refine grid results.'),
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget _buildContextDecoratorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Semantic Overlays & Empty States', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: TissueAlert(
                title: 'Data Synchronization In Progress',
                message: 'The system is currently fetching latest ledger movements from Supabase Cloud.',
                variant: CellBadgeVariant.primary,
                icon: LucideIcons.refreshCw,
              ),
            ),
            const SizedBox(width: OrganismTheme.spacing2Xl),
            const Expanded(
              child: TissueEmptyState(
                title: 'No Invoices Found',
                message: 'Adjust your search parameters or check the selected fiscal year.',
                icon: LucideIcons.search,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildListCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ERP Registry Items (TissueListCard)', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingMd),
        Text('The fundamental building block for list-based data entry and identification.', style: OrganismTheme.bodyMedium),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        SizedBox(
          width: 500,
          child: Column(
            children: [
              TissueListCard(
                title: Text('Mahadev Fashion', style: OrganismTheme.titleMedium),
                subtitle: Text('VNO: V/000124 | QUALITY: Dola Silk', style: OrganismTheme.bodySmall),
                trailing: const CellBadge(text: 'Closed', variant: CellBadgeVariant.success),
                onTap: () {},
                isSelected: true,
              ),
              const SizedBox(height: OrganismTheme.spacingMd),
              TissueListCard(
                title: Text('RK Trading Co.', style: OrganismTheme.titleMedium),
                subtitle: Text('VNO: V/000125 | QUALITY: Vichitra Fancy', style: OrganismTheme.bodySmall),
                trailing: const CellBadge(text: 'Pending', variant: CellBadgeVariant.warning),
                onTap: () {},
              ),
            ],
          ),
        )
      ],
    );
  }
}
