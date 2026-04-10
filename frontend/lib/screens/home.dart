import 'package:flutter/material.dart';
import '../organism_design/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrganismTheme.background,
      body: Row(
        children: [
          // Global Side Navigation (NavBoat Organ)
          NavBoat(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
          
          // Main Application Content Area
          Expanded(
            child: Column(
              children: [
                // Top Page Header (Tissue)
                _buildTopBar(),
                
                // Page Body (Switch based on selection)
                Expanded(
                  child: Container(
                    color: OrganismTheme.background,
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingLg),
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        border: Border(bottom: BorderSide(color: OrganismTheme.border)),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(),
            style: OrganismTheme.titleMedium,
          ),
          const Spacer(),
          // Global search or actions could go here
          const SizedBox(
            width: 300,
            child: CellInput(
              placeholder: 'Search (Ctrl + K)',
              isSearch: true,
            ),
          ),
          const SizedBox(width: OrganismTheme.spacingMd),
          CellButton(
            text: 'Help',
            variant: CellButtonVariant.ghost,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Placeholder logic for page switching
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Page: ${_getPageTitle()}',
            style: OrganismTheme.displayLarge.copyWith(color: OrganismTheme.stone200),
          ),
          const SizedBox(height: OrganismTheme.spacingMd),
          Text(
            'Ambaji ERP • Phase 5 Kinetic Shell Active',
            style: OrganismTheme.bodyLarge.copyWith(color: OrganismTheme.textMuted),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Parties Master';
      case 2: return 'Item Master';
      case 3: return 'Design Catalog';
      case 4: return 'Transport List';
      case 5: return 'Production Pipeline';
      case 6: return 'Cutting Stage';
      case 7: return 'Job Work Management';
      case 8: return 'Detailed Reports';
      default: return 'AMBAJI ERP';
    }
  }
}
