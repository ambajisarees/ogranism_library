import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../dynamic_ai/components/root_level/dynamic_shell.dart';
import '../dynamic_ai/components/root_level/sidebar_nav.dart';
import '../dynamic_ai/components/root_level/window_tabs.dart';
import '../main.dart';
import '../services/auth/old/service_auth.dart';
import 'old/admin/demo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DynamicTabItem> _openTabs = [];
  int _selectedTabWorkspaceIndex = 0;
  bool _isSidebarExpanded = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with the Home workspace tab by default
    _openTabs.add(
      DynamicTabItem(
        id: '0',
        title: 'Home',
        icon: shad.LucideIcons.house,
        content: _buildBodyForIndex(0),
      ),
    );
  }

  void _showGlobalSearch() {
    final theme = shad.Theme.of(context);
    shad.showOverlay(
      context,
      shad.PopoverConfiguration(
        alignment: Alignment.center,
        anchorAlignment: Alignment.center,
        builder: (context) {
          return shad.ModalContainer(
            child: SizedBox(
              width: 450 * theme.scaling,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  shad.TextField(
                    placeholder: const Text('Search modules...'),
                    features: [
                      shad.InputFeature.leading(
                        Icon(shad.LucideIcons.search,
                            color: theme.colorScheme.mutedForeground),
                      ),
                    ],
                  ),
                  const shad.DensityGap(shad.gapMd),
                  SizedBox(
                    height: 320 * theme.scaling,
                    child: ListView(
                      children: [
                        _buildCommandItem(
                            context,
                            'Dashboard',
                            'Overview and analytics',
                            shad.LucideIcons.layoutDashboard,
                            0),
                        _buildCommandItem(
                            context,
                            'Parties',
                            'Customer and supplier accounts',
                            shad.LucideIcons.users,
                            1),
                        _buildCommandItem(
                            context,
                            'Items',
                            'Inventory and stock master',
                            shad.LucideIcons.package,
                            2),
                        _buildCommandItem(
                            context,
                            'Designs',
                            'Design library and patterns',
                            shad.LucideIcons.palette,
                            3),
                        _buildCommandItem(
                            context,
                            'Cutting Cards',
                            'Process cutting batches',
                            shad.LucideIcons.scissors,
                            6),
                        _buildCommandItem(
                            context,
                            'Job Work',
                            'Stitching dispatches and receives',
                            shad.LucideIcons.briefcase,
                            7),
                        _buildCommandItem(
                            context,
                            'System Sync',
                            'Airbyte data sync diagnostics',
                            shad.LucideIcons.settings,
                            8),
                        _buildCommandItem(context, 'Media Library',
                            'Photos and documents', shad.LucideIcons.image, 10),
                        _buildCommandItem(
                            context,
                            'Design System',
                            'Organism UI component library',
                            shad.LucideIcons.bookOpen,
                            9),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommandItem(BuildContext context, String title, String subtitle,
      IconData icon, int index) {
    final theme = shad.Theme.of(context);
    return shad.Button.ghost(
      onPressed: () {
        shad.closeOverlay(context);
        _handleModuleSelection(index);
      },
      child: Row(
        children: [
          Icon(icon, size: theme.iconTheme.small.size),
          const shad.DensityGap(shad.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.typography.textSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.foreground)),
                Text(subtitle,
                    style: theme.typography.xSmall
                        .copyWith(color: theme.colorScheme.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleModuleSelection(int index) {
    if (index == 100) {
      _showGlobalSearch();
      return;
    }
    final tabId = index.toString();
    final existingIndex = _openTabs.indexWhere((t) => t.id == tabId);
    if (existingIndex != -1) {
      setState(() {
        _selectedTabWorkspaceIndex = existingIndex;
      });
    } else {
      final newTab = DynamicTabItem(
        id: tabId,
        title: _getPageTitle(index),
        icon: _getIconForIndex(index),
        content: _buildBodyForIndex(index),
      );

      setState(() {
        if (_openTabs.length < 5) {
          _openTabs.add(newTab);
          _selectedTabWorkspaceIndex = _openTabs.length - 1;
        } else {
          // Cap 5 tabs: recycle the 5th tab (index 4)
          _openTabs[4] = newTab;
          _selectedTabWorkspaceIndex = 4;
        }
      });
    }
  }

  void _handleTabClosed(int index) {
    if (_openTabs.length <= 1) {
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Cannot close the last remaining workspace tab.'),
          ),
        ),
      );
      return;
    }
    setState(() {
      _openTabs.removeAt(index);
      if (_selectedTabWorkspaceIndex >= _openTabs.length) {
        _selectedTabWorkspaceIndex = _openTabs.length - 1;
      }
    });
  }

  List<DynamicSidebarNavItem> _buildSidebarItems(int selectedIndex) {
    return [
      // Core Pages
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.house,
        label: 'Home',
        isSelected: selectedIndex == 0,
        onTap: () => _handleModuleSelection(0),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.squareCheck,
        label: 'Tasks',
        isSelected: selectedIndex == 102,
        onTap: () => _handleModuleSelection(102),
      ),

      // Category: Masters
      const DynamicSidebarNavItem(
        label: 'Masters',
        isHeader: true,
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.users,
        label: 'Orgs',
        isSelected: selectedIndex == 1,
        onTap: () => _handleModuleSelection(1),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.package,
        label: 'Items',
        isSelected: selectedIndex == 2,
        onTap: () => _handleModuleSelection(2),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.palette,
        label: 'Designs',
        isSelected: selectedIndex == 3,
        onTap: () => _handleModuleSelection(3),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.soup,
        label: 'Recipes',
        isSelected: selectedIndex == 103,
        onTap: () => _handleModuleSelection(103),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.image,
        label: 'Media',
        isSelected: selectedIndex == 10,
        onTap: () => _handleModuleSelection(10),
      ),

      // Category: Pipeline
      const DynamicSidebarNavItem(
        label: 'Pipeline',
        isHeader: true,
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.fileText,
        label: 'Orders',
        isSelected: selectedIndex == 5,
        onTap: () => _handleModuleSelection(5),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.cpu,
        label: 'Programs',
        isSelected: selectedIndex == 104,
        onTap: () => _handleModuleSelection(104),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.scissors,
        label: 'Cuttings',
        isSelected: selectedIndex == 6,
        onTap: () => _handleModuleSelection(6),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.briefcase,
        label: 'Jobs',
        isSelected: selectedIndex == 7,
        onTap: () => _handleModuleSelection(7),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.receipt,
        label: 'Bills',
        isSelected: selectedIndex == 105,
        onTap: () => _handleModuleSelection(105),
      ),

      // Category: Sales
      const DynamicSidebarNavItem(
        label: 'Sales',
        isHeader: true,
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.boxes,
        label: 'Stock',
        isSelected: selectedIndex == 106,
        onTap: () => _handleModuleSelection(106),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.userCheck,
        label: 'CRM',
        isSelected: selectedIndex == 107,
        onTap: () => _handleModuleSelection(107),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.shoppingBag,
        label: 'Orders',
        isSelected: selectedIndex == 108,
        onTap: () => _handleModuleSelection(108),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.fileSpreadsheet,
        label: 'Challans',
        isSelected: selectedIndex == 109,
        onTap: () => _handleModuleSelection(109),
      ),
      DynamicSidebarNavItem(
        icon: shad.LucideIcons.fileDigit,
        label: 'Invoices',
        isSelected: selectedIndex == 110,
        onTap: () => _handleModuleSelection(110),
      ),
    ];
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return shad.LucideIcons.house;
      case 1:
        return shad.LucideIcons.users;
      case 2:
        return shad.LucideIcons.package;
      case 3:
        return shad.LucideIcons.palette;
      case 10:
        return shad.LucideIcons.image;
      case 5:
        return shad.LucideIcons.fileText;
      case 6:
        return shad.LucideIcons.scissors;
      case 7:
        return shad.LucideIcons.briefcase;
      case 101:
        return shad.LucideIcons.bell;
      case 102:
        return shad.LucideIcons.squareCheck;
      case 103:
        return shad.LucideIcons.soup;
      case 104:
        return shad.LucideIcons.cpu;
      case 105:
        return shad.LucideIcons.receipt;
      case 106:
        return shad.LucideIcons.boxes;
      case 107:
        return shad.LucideIcons.userCheck;
      case 108:
        return shad.LucideIcons.shoppingBag;
      case 109:
        return shad.LucideIcons.fileSpreadsheet;
      case 110:
        return shad.LucideIcons.fileDigit;
      default:
        return shad.LucideIcons.circleHelp;
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Orgs';
      case 2:
        return 'Items';
      case 3:
        return 'Designs';
      case 10:
        return 'Media';
      case 5:
        return 'Orders';
      case 6:
        return 'Cuttings';
      case 7:
        return 'Jobs';
      case 101:
        return 'Notifs';
      case 102:
        return 'Tasks';
      case 103:
        return 'Recipes';
      case 104:
        return 'Programs';
      case 105:
        return 'Bills';
      case 106:
        return 'Stock';
      case 107:
        return 'CRM';
      case 108:
        return 'Orders';
      case 109:
        return 'Challans';
      case 110:
        return 'Invoices';
      default:
        return 'AMBAJI ERP';
    }
  }

  Widget _buildBodyForIndex(int index) {
    switch (index) {
      case 0:
      case 11:
        return const DemoScreen();
      default:
        return FallbackDashboardWidget(
          title: _getPageTitle(index),
        );
    }
  }

  Widget _buildProfilePopoverContent(
      BuildContext context, shad.ThemeData theme, shad.ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('smitt@ambaji.com',
              style: theme.typography.textSmall
                  .copyWith(fontWeight: FontWeight.bold)),
          Text('Admin Session Manager',
              style: theme.typography.textMuted.copyWith(fontSize: 11)),
          const SizedBox(height: 8),
          const shad.Divider(),
          const SizedBox(height: 8),
          shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: () async {
              await AuthService().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = shad.Theme.of(context).colorScheme;
    final theme = shad.Theme.of(context);

    // Dynamic Module index resolver (maps active tab to rail highlights)
    int selectedModuleIndex = -1;
    if (_openTabs.isNotEmpty && _selectedTabWorkspaceIndex < _openTabs.length) {
      selectedModuleIndex =
          int.tryParse(_openTabs[_selectedTabWorkspaceIndex].id) ?? -1;
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _showGlobalSearch,
      },
      child: Focus(
        autofocus: true,
        debugLabel: 'GlobalShortcutRoot',
        child: DynamicWorkspaceShell(
          backgroundColor: colors.background,
          sidebar: DynamicSidebarNav(
            expanded: _isSidebarExpanded,
            expandedWidth: 200.0,
            items: _buildSidebarItems(selectedModuleIndex),
            header: shad.NavigationItem(
              enabled: false,
              label: Text(
                'Ambaji ERP',
                style: theme.typography.textLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                ),
              ),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(
                    shad.LucideIcons.beaker,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          content: DynamicTabWorkspace(
            tabs: _openTabs,
            selectedIndex: _selectedTabWorkspaceIndex,
            onTabSelected: (idx) =>
                setState(() => _selectedTabWorkspaceIndex = idx),
            onTabClosed: _handleTabClosed,
            onSearchTriggered: _showGlobalSearch,
            isSidebarExpanded: _isSidebarExpanded,
            onToggleSidebar: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            trailing: [
              // 1. Global Search Trigger (Ctrl+K)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: _showGlobalSearch,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(shad.LucideIcons.search, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Search...',
                        style: theme.typography.textSmall.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.muted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Ctrl K',
                          style: theme.typography.textMuted.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 2. Notifications Bell Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: shad.IconButton.ghost(
                  size: shad.ButtonSize.small,
                  density: shad.ButtonDensity.iconDense,
                  icon: const Icon(shad.LucideIcons.bell, size: 16),
                  onPressed: () {
                    shad.showToast(
                      context: context,
                      builder: (context, show) => const shad.Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('3 Pending Alerts / Notifications'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 3. Theme Toggle Button
              ValueListenableBuilder<shad.ThemeMode>(
                valueListenable: themeModeNotifier,
                builder: (context, mode, child) {
                  final isDark = mode == shad.ThemeMode.dark;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      density: shad.ButtonDensity.iconDense,
                      icon: Icon(
                        isDark ? shad.LucideIcons.moon : shad.LucideIcons.sun,
                        size: 16,
                      ),
                      onPressed: () {
                        themeModeNotifier.value = isDark
                            ? shad.ThemeMode.light
                            : shad.ThemeMode.dark;
                      },
                    ),
                  );
                },
              ),
              // 4. User Profile Avatar & Popover
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                child: Builder(builder: (context) {
                  return InkWell(
                    onTap: () {
                      shad.showOverlay(
                        context,
                        shad.PopoverConfiguration(
                          alignment: Alignment.bottomRight,
                          offset: const Offset(0, 8),
                          builder: (context) {
                            return shad.ModalContainer(
                              child: SizedBox(
                                width: 220,
                                child: _buildProfilePopoverContent(
                                    context, theme, colors),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: const shad.Avatar(
                      initials: 'SM',
                      size: 24,
                    ),
                  );
                }),
              ),
            ],
            placeholder: Center(
              child: Text(
                'No active workspace tabs open.',
                style: theme.typography.textLarge
                    .copyWith(color: colors.mutedForeground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FallbackDashboardWidget extends StatelessWidget {
  final String title;

  const FallbackDashboardWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Module: $title',
            style: theme.typography.h1.copyWith(color: colors.mutedForeground),
          ),
          const shad.DensityGap(shad.gapMd),
          Text(
            'Ambaji ERP • Kinetic Workspace v1.0',
            style: theme.typography.textMuted
                .copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
