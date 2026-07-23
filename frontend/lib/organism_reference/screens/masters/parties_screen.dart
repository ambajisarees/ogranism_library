import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../organism_design/index.dart';
import '../../models/masters/model_party.dart';
import '../../services/masters/service_masters.dart';

import '../../constants/legacy_constants.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  final _service = MastersService();
  
  List<PartyModel> _parties = [];
  PartyModel? _selectedParty;
  
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  bool _isLoading = false;
  
  String _searchTerm = '';
  int? _activeAType; // Filter by AType

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final result = await _service.getParties(
      offset: (_currentPage - 1) * _limit,
      limit: _limit,
      searchTerm: _searchTerm,
      accountType: _activeAType,
    );

    if (mounted) {
      setState(() {
        _parties = result.data;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemAppMasterLayout(
      isDetailVisible: _selectedParty != null,
      
      // 1. MASTER HEADER
      paneHeader: OrganPaneHeader(
        title: 'Parties',
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

      // 2. MASTER LIST
      paneList: OrganPaneList(
        isLoading: _isLoading,
        itemCount: _parties.length,
        currentPage: _currentPage,
        totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
        totalCount: _totalCount,
        limit: _limit,
        onPageChanged: (p) {
          setState(() => _currentPage = p);
          _loadData();
        },
        itemBuilder: (context, index) {
          final party = _parties[index];
          
          final city = party.city.trim();
          final station = (party.station ?? '').trim();
          final String location;
          
          if (city.isNotEmpty && station.isNotEmpty) {
            location = (city.toLowerCase() == station.toLowerCase()) 
               ? city 
               : '$station x $city';
          } else {
            location = city.isNotEmpty ? city : (station.isNotEmpty ? station : 'SURAT');
          }

          return TissueListCard(
            isSelected: _selectedParty?.code == party.code,
            onTap: () => setState(() => _selectedParty = party),
            title: Text(party.name),
            subtitle: Row(
              children: [
                Icon(
                  LucideIcons.mapPin, 
                  size: 10, 
                  color: OrganismTheme.colorsOf(context).textSecondary
                ),
                const SizedBox(width: 4),
                Text(location),
              ],
            ),
            trailing: CellBadge(
              text: LegacyConstants.getAccountTypeName(party.accountType),
              customColor: LegacyConstants.getAccountTypeColor(context, party.accountType),
            ),
          );
        },
      ),

      // 3. UNIFIED DETAIL CANVAS
      sectionCanvas: _selectedParty == null 
        ? null 
        : OrganSectionCanvas(
            title: _selectedParty!.name,
            tabs: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   CellButton(
                     text: 'Profile', 
                     variant: CellButtonVariant.input, 
                     isCompact: true, 
                     onPressed: () {}
                   ),
                   const SizedBox(width: 8),
                   CellButton(
                     text: 'Ledger', 
                     variant: CellButtonVariant.ghost, 
                     isCompact: true, 
                     onPressed: () {}
                   ),
                   const SizedBox(width: 8),
                   CellButton(
                     text: 'Logistics', 
                     variant: CellButtonVariant.ghost, 
                     isCompact: true, 
                     onPressed: () {}
                   ),
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
            ],
            children: [
              // Identification & Identity
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Business Identity'),
                  TissueCardContent(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: TissueReadOnlyField(label: 'Party Code', value: _selectedParty!.code)),
                            Expanded(child: TissueReadOnlyField(label: 'Contact Person', value: _selectedParty!.contactPerson ?? 'N/A')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TissueReadOnlyField(label: 'Mobile', value: _selectedParty!.mobile ?? 'N/A')),
                            Expanded(child: TissueReadOnlyField(label: 'Group Link', value: _selectedParty!.groupCode)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Geography & Logistics
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Logistics Hub'),
                  TissueCardContent(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: TissueReadOnlyField(label: 'Station (Hub)', value: _selectedParty!.station ?? 'SURAT')),
                            Expanded(child: TissueReadOnlyField(label: 'Billing City', value: _selectedParty!.city)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TissueReadOnlyField(label: 'Full Address', value: _selectedParty!.fullAddress ?? 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),

              // Compliance & Tax
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Compliance & Tax'),
                  TissueCardContent(
                    child: Row(
                      children: [
                        Expanded(child: TissueReadOnlyField(label: 'GSTIN', value: _selectedParty!.gstin ?? 'UNREGISTERED')),
                        Expanded(child: TissueReadOnlyField(label: 'PNR No', value: _selectedParty!.pnrNo ?? 'N/A')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
      
      emptyTitle: 'No Party Selected',
      emptyMessage: 'Select a business partner from the registry to view their logistics hub and credit profile.',
      emptyIcon: LucideIcons.users,
    );
  }
}
