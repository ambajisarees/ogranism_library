import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../organism_design/index.dart';
import '../../models/model_quality.dart';
import '../../services/service_masters.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _service = MastersService();
  
  List<QualityModel> _items = [];
  QualityModel? _selectedItem;
  
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  bool _isLoading = false;
  
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final result = await _service.getQualities(
      offset: (_currentPage - 1) * _limit,
      limit: _limit,
      searchTerm: _searchTerm,
    );

    if (mounted) {
      setState(() {
        _items = result.data;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemAppMasterLayout(
      isDetailVisible: _selectedItem != null,
      
      paneHeader: OrganPaneHeader(
        title: 'Qualities',
        onSearchChanged: (val) {
          setState(() {
            _searchTerm = val;
            _currentPage = 1;
          });
          _loadData();
        },
        onAddPressed: () {},
        onFilterPressed: () {},
        onSortPressed: () {},
      ),

      paneList: OrganPaneList(
        isLoading: _isLoading,
        itemCount: _items.length,
        currentPage: _currentPage,
        totalPages: (_totalCount / _limit).ceil().clamp(1, 999), 
        totalCount: _totalCount,
        limit: _limit,
        onPageChanged: (p) {
          setState(() => _currentPage = p);
          _loadData();
        },
        itemBuilder: (context, index) {
          final item = _items[index];
          return TissueListCard(
            isSelected: _selectedItem?.qcode == item.qcode,
            onTap: () => setState(() => _selectedItem = item),
            title: Text(item.qcode),
            trailing: Text(
              item.sellRate1 > 0 ? '₹${item.sellRate1.toStringAsFixed(0)}' : '-',
              style: OrganismTheme.numericMedium(context),
            ),
          );
        },
      ),

      sectionCanvas: _selectedItem == null 
        ? null 
        : OrganSectionCanvas(
            title: _selectedItem!.name,
            tabs: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   CellButton(text: 'Technical', variant: CellButtonVariant.input, isCompact: true, onPressed: () {}),
                   const SizedBox(width: 8),
                   CellButton(text: 'Pricing', variant: CellButtonVariant.ghost, isCompact: true, onPressed: () {}),
                   const SizedBox(width: 8),
                   CellButton(text: 'History', variant: CellButtonVariant.ghost, isCompact: true, onPressed: () {}),
                ],
              ),
            ),
            actions: [
              CellButton(
                text: 'Edit',
                icon: LucideIcons.edit,
                variant: CellButtonVariant.primary,
                isCompact: true,
                onPressed: () {},
              ),
              CellButton(
                text: 'Print',
                icon: LucideIcons.printer,
                variant: CellButtonVariant.outline,
                isCompact: true,
                onPressed: () {},
              ),
            ],
            children: [
              // Identification Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Fabric Identification'),
                  TissueCardContent(
                    child: Row(
                      children: [
                        Expanded(child: TissueReadOnlyField(label: 'HSN Code', value: _selectedItem!.hsnCode ?? 'N/A')),
                        Expanded(child: TissueReadOnlyField(label: 'GST Rate', value: '${_selectedItem!.gstRate}%')),
                        Expanded(child: TissueReadOnlyField(label: 'Category', value: _selectedItem!.category ?? 'General')),
                      ],
                    ),
                  ),
                ],
              ),

              // Production Specs Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Production Specifications'),
                  TissueCardContent(
                    child: Row(
                      children: [
                        Expanded(child: TissueReadOnlyField(label: 'Standard Cut', value: '${_selectedItem!.standardCut} ${_selectedItem!.unit}', isMono: true)),
                        Expanded(child: TissueReadOnlyField(label: 'Packing Style', value: _selectedItem!.packingStyle ?? 'Standard')),
                      ],
                    ),
                  ),
                ],
              ),

              // Pricing Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Pricing & Commercials'),
                  TissueCardContent(
                    child: Row(
                      children: [
                        Expanded(child: TissueReadOnlyField(label: 'Sale Rate (L1)', value: '₹${_selectedItem!.sellRate1.toStringAsFixed(2)}', isMono: true)),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
      
      emptyTitle: 'No Quality Selected',
      emptyMessage: 'Select a fabric from the registry to view technical specs and pricing tiers.',
      emptyIcon: LucideIcons.packageSearch,
    );
  }
}
