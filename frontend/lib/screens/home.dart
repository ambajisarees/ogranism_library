import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../organism_design/index.dart';
import 'items/items_screen.dart';
import 'masters/parties_screen.dart';
import 'production/grey_screen.dart';
import 'production/cutting_screen.dart';
import 'production/job_work_screen.dart';
import 'admin/sync_dashboard_screen.dart';
import 'media/media_screen.dart';
import '../services/service_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late KineticWorkspaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KineticWorkspaceController();
    // Rebuild when controller state changes
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Centralized Command Palette launch logic
  void _showGlobalSearch() {
    TissueCommandPalette.show(
      context,
      actions: _getCommandPaletteActions(),
    );
  }

  /// Centralized source of searchable actions
  List<CommandPaletteAction> _getCommandPaletteActions() {
    return [
      CommandPaletteAction(
        id: 'nav_dashboard',
        label: 'Dashboard',
        subtitle: 'Overview and analytics',
        icon: Icons.dashboard_outlined,
        onSelect: () => _controller.setModuleIndex(0),
      ),
      CommandPaletteAction(
        id: 'nav_parties',
        label: 'Parties',
        subtitle: 'Manage customer and supplier accounts',
        icon: Icons.people_outline,
        onSelect: () => _controller.setModuleIndex(1),
      ),
      CommandPaletteAction(
        id: 'nav_items',
        label: 'Items',
        subtitle: 'Inventory and stock master',
        icon: Icons.inventory_2_outlined,
        onSelect: () => _controller.setModuleIndex(2),
      ),
      CommandPaletteAction(
        id: 'nav_library',
        label: 'Design System',
        subtitle: 'Organism UI component library',
        icon: Icons.menu_book_outlined,
        onSelect: () => _controller.setModuleIndex(9),
      ),
      CommandPaletteAction(
        id: 'nav_cutting',
        label: 'Cutting Cards',
        subtitle: 'Process and monitor cutting batches',
        icon: Icons.content_cut_outlined,
        onSelect: () => _controller.setModuleIndex(6),
      ),
      CommandPaletteAction(
        id: 'nav_jobwork',
        label: 'Job Work Management',
        subtitle: 'Track stitching dispatches and receives',
        icon: Icons.work_outline,
        onSelect: () => _controller.setModuleIndex(7),
      ),
      CommandPaletteAction(
        id: 'nav_admin',
        label: 'System Sync & Admin',
        subtitle: 'Airbyte data sync diagnostics',
        icon: Icons.admin_panel_settings_outlined,
        onSelect: () => _controller.setModuleIndex(8),
      ),
      CommandPaletteAction(
        id: 'nav_media',
        label: 'Media Library',
        subtitle: 'Manage all photos and documents',
        icon: Icons.image_outlined,
        onSelect: () => _controller.setModuleIndex(10),
      ),
      CommandPaletteAction(
        id: 'auth_signout',
        label: 'Sign Out',
        subtitle: 'Logout from your session',
        icon: Icons.logout,
        onSelect: () async {
          await AuthService().signOut();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    // BIND GLOBAL KEYBOARD SHORTCUTS
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _showGlobalSearch,
      },
      child: Focus(
        autofocus: true,
        debugLabel: 'GlobalShortcutRoot',
        child: OrganAppShell(
          controller: _controller,
          backgroundColor: colors.background,
          topbar: OrganTopbar(
            controller: _controller,
            onSearchTap: _showGlobalSearch,
          ),
          sidebar: NavBoat(
            selectedIndex: _controller.activeModuleIndex,
            onItemSelected: (index) => _controller.setModuleIndex(index),
            controller: _controller,
          ),
          content: _buildBody(context, colors),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrganismColors colors) {
    switch (_controller.activeModuleIndex) {
      case 1:
        return const PartiesScreen();
      case 2:
        return const ItemsScreen();
      case 5:
        return GreyScreen();
      case 6:
        return const CuttingScreen();
      case 7:
        return const JobWorkScreen();
      case 8:
        return const SyncDashboardScreen();
      case 9:
        return const OrganismLibraryScreen();
      case 10:
        return const MediaScreen();
      default:
        // Placeholder logic for other pages
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Module: ${_getPageTitle()}',
                style: OrganismTheme.displayLarge(context).copyWith(color: colors.stone200),
              ),
              const SizedBox(height: OrganismTheme.spacingMd),
              Text(
                'Ambaji ERP • Kinetic Workspace v1.0',
                style: OrganismTheme.bodyLarge(context).copyWith(color: colors.textMuted),
              ),
            ],
          ),
        );
    }
  }

  String _getPageTitle() {
    switch (_controller.activeModuleIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Parties Master';
      case 2: return 'Item Master';
      case 3: return 'Design Catalog';
      case 4: return 'Transport List';
      case 5: return 'Production Pipeline';
      case 6: return 'Cutting Stage';
      case 7: return 'Job Work Management';
      case 8: return 'System Administration & Sync';
      case 9: return 'Design System Library';
      default: return 'AMBAJI ERP';
    }
  }
}
