import 'package:flutter/material.dart';
import '../theme.dart';
import '../index.dart';
import '../widgets/library_header.dart';

class TissuesView extends StatefulWidget {
  const TissuesView({super.key});

  @override
  State<TissuesView> createState() => _TissuesViewState();
}

class _TissuesViewState extends State<TissuesView> {
  DateTime? _selectedDate;
  String? _selectedValue;

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
                title: 'Density Container (TissueCard)',
                child: Column(
                  children: [
                    Text('Standard ERP data density rules applied here via padding and border tokens.', 
                         style: OrganismTheme.bodyMedium),
                    const SizedBox(height: OrganismTheme.spacingLg),
                    const TissueReadOnlyField(label: 'Unique Hash', value: 'f72-99-A0'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: OrganismTheme.spacing2Xl),
            Expanded(
              child: Column(
                children: [
                  TissueFormField(
                    label: 'Client Legal Entity Name',
                    isRequired: true,
                    child: const CellInput(placeholder: 'e.g. Reliance Retail'),
                  ),
                  const SizedBox(height: OrganismTheme.spacingLg),
                  TissueDropdown<String>(
                    label: 'Fiscal Year Target',
                    value: _selectedValue,
                    items: const ['IMMBE2425', 'IMMBE2526', 'IMMBE2627'],
                    onChanged: (v) => setState(() => _selectedValue = v),
                    placeholder: 'Select Year',
                  ),
                  const SizedBox(height: OrganismTheme.spacingLg),
                  TissueDatePicker(
                    label: 'Bill Date',
                    selectedDate: _selectedDate,
                    onDateChanged: (d) => setState(() => _selectedDate = d),
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
            const SizedBox(
              width: 400,
              child: TissueTabs(
                tabs: ['History', 'Metadata', 'Logs'],
                children: [
                  Padding(padding: EdgeInsets.all(16), child: Text('Audit history will appear here...')),
                  Padding(padding: EdgeInsets.all(16), child: Text('Raw object metadata view.')),
                  Padding(padding: EdgeInsets.all(16), child: Text('Live system sync logs.')),
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
                  child: Padding(
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
                variant: TissueAlertVariant.primary,
              ),
            ),
            const SizedBox(width: OrganismTheme.spacing2Xl),
            const Expanded(
              child: TissueEmptyState(
                title: 'No Invoices Found',
                message: 'Adjust your search parameters or check the selected fiscal year.',
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
                title: 'Mahadev Fashion',
                subtitle: 'VNO: V/000124 | QUALITY: Dola Silk',
                trailing: const CellBadge(text: 'Closed', variant: CellBadgeVariant.success),
                onTap: () {},
                isSelected: true,
              ),
              const SizedBox(height: OrganismTheme.spacingMd),
              TissueListCard(
                title: 'RK Trading Co.',
                subtitle: 'VNO: V/000125 | QUALITY: Vichitra Fancy',
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
