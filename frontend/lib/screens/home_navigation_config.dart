/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized module navigation registry (`HomeNavigationConfig`) for `HomeScreen`.
   - Uses `shad.LucideIcons` across the NavRail and Top App Bar for clean geometric
     visual alignment across workspace tabs and rail controls.
   - Hierarchy: `Home [H]` | Divider | `Quick Add [Q]` | Divider | 5 divider-
     separated modules (`Masters [M]`, `Pipeline [P]`, `Sales [S]`, `Finance [F]`,
     `Workspace [W]`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `buildSidebarItems`: Builds hierarchical `DynamicSidebarNavItem` tree mapping
     direct actions (`Home`, `Quick Add`) and 5 accordion folders to module indices.
   - `getIconForIndex` / `getPageTitle`: Single source of truth for workspace tab
     icons and titles across all 30+ ERP screens.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Module indices align 1:1 with `HomeScreen._buildBodyForIndex` and `home_popovers.dart`.
   - Option 2 trickle-down scopes submodule keypresses to the single armed folder,
     allowing every submodule to cleanly use its first letter without collision.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: role-based filtering of modules/folders per user role in `IMMBE2627`.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../dynamic_ai/root/sidebar_nav.dart';

/// Static navigation tree and module metadata registry for [HomeScreen].
abstract class HomeNavigationConfig {
  static List<DynamicSidebarNavItem> buildSidebarItems({
    required int selectedIndex,
    required ValueChanged<int> onSelectModule,
    required ValueChanged<BuildContext> onQuickAddTap,
  }) {
    return [
      DynamicSidebarNavItem(
        id: 'home',
        icon: shad.LucideIcons.house,
        label: 'Home',
        shortcutKey: 'H',
        isSelected: selectedIndex == 0,
        hasTrailingDivider: true,
        onTap: () => onSelectModule(0),
      ),
      DynamicSidebarNavItem(
        id: 'quick_add',
        icon: shad.LucideIcons.plus,
        label: 'Quick Add',
        shortcutKey: 'Q',
        isPrimaryAction: true,
        hasTrailingDivider: true,
        onContextTap: onQuickAddTap,
      ),
      DynamicSidebarNavItem(
        id: 'masters',
        icon: shad.LucideIcons.database,
        label: 'Masters',
        shortcutKey: 'M',
        hasTrailingDivider: true,
        children: [
          DynamicSidebarNavItem(
            id: 'parties',
            icon: shad.LucideIcons.users,
            label: 'Parties',
            shortcutKey: 'P',
            isSelected: selectedIndex == 1,
            onTap: () => onSelectModule(1),
          ),
          DynamicSidebarNavItem(
            id: 'groups',
            icon: shad.LucideIcons.folderTree,
            label: 'Groups',
            shortcutKey: 'G',
            isSelected: selectedIndex == 11,
            onTap: () => onSelectModule(11),
          ),
          DynamicSidebarNavItem(
            id: 'contacts',
            icon: shad.LucideIcons.contact,
            label: 'Contacts',
            shortcutKey: 'C',
            isSelected: selectedIndex == 111,
            onTap: () => onSelectModule(111),
          ),
          DynamicSidebarNavItem(
            id: 'sources',
            icon: shad.LucideIcons.compass,
            label: 'Sources',
            shortcutKey: 'S',
            isSelected: selectedIndex == 12,
            onTap: () => onSelectModule(12),
          ),
          DynamicSidebarNavItem(
            id: 'transports',
            icon: shad.LucideIcons.truck,
            label: 'Transports',
            shortcutKey: 'T',
            isSelected: selectedIndex == 13,
            onTap: () => onSelectModule(13),
          ),
          DynamicSidebarNavItem(
            id: 'designs',
            icon: shad.LucideIcons.palette,
            label: 'Designs',
            shortcutKey: 'D',
            isSelected: selectedIndex == 3,
            onTap: () => onSelectModule(3),
          ),
          DynamicSidebarNavItem(
            id: 'items',
            icon: shad.LucideIcons.package,
            label: 'Items',
            shortcutKey: 'I',
            isSelected: selectedIndex == 2,
            onTap: () => onSelectModule(2),
          ),
          DynamicSidebarNavItem(
            id: 'media',
            icon: shad.LucideIcons.image,
            label: 'Media',
            shortcutKey: 'M',
            isSelected: selectedIndex == 10,
            onTap: () => onSelectModule(10),
          ),
        ],
      ),
      DynamicSidebarNavItem(
        id: 'pipeline',
        icon: shad.LucideIcons.workflow,
        label: 'Pipeline',
        shortcutKey: 'P',
        hasTrailingDivider: true,
        children: [
          DynamicSidebarNavItem(
            id: 'recipes',
            icon: shad.LucideIcons.flaskConical,
            label: 'Recipes',
            shortcutKey: 'R',
            isSelected: selectedIndex == 103,
            onTap: () => onSelectModule(103),
          ),
          DynamicSidebarNavItem(
            id: 'strategy',
            icon: shad.LucideIcons.cpu,
            label: 'Strategy',
            shortcutKey: 'S',
            isSelected: selectedIndex == 104,
            onTap: () => onSelectModule(104),
          ),
          DynamicSidebarNavItem(
            id: 'po',
            icon: shad.LucideIcons.clipboardList,
            label: 'Orders',
            shortcutKey: 'O',
            isSelected: selectedIndex == 5,
            onTap: () => onSelectModule(5),
          ),
          DynamicSidebarNavItem(
            id: 'cuttings',
            icon: shad.LucideIcons.scissors,
            label: 'Cuttings',
            shortcutKey: 'C',
            isSelected: selectedIndex == 6,
            onTap: () => onSelectModule(6),
          ),
          DynamicSidebarNavItem(
            id: 'jobs',
            icon: shad.LucideIcons.briefcase,
            label: 'Jobs',
            shortcutKey: 'J',
            isSelected: selectedIndex == 7,
            onTap: () => onSelectModule(7),
          ),
          DynamicSidebarNavItem(
            id: 'inward',
            icon: shad.LucideIcons.packageCheck,
            label: 'Inward',
            shortcutKey: 'I',
            isSelected: selectedIndex == 201,
            onTap: () => onSelectModule(201),
          ),
          DynamicSidebarNavItem(
            id: 'packing',
            icon: shad.LucideIcons.boxes,
            label: 'Packing',
            shortcutKey: 'P',
            isSelected: selectedIndex == 202,
            onTap: () => onSelectModule(202),
          ),
          DynamicSidebarNavItem(
            id: 'bills',
            icon: shad.LucideIcons.receipt,
            label: 'Bills',
            shortcutKey: 'B',
            isSelected: selectedIndex == 105,
            onTap: () => onSelectModule(105),
          ),
        ],
      ),
      DynamicSidebarNavItem(
        id: 'sales',
        icon: shad.LucideIcons.tags,
        label: 'Sales',
        shortcutKey: 'S',
        hasTrailingDivider: true,
        children: [
          DynamicSidebarNavItem(
            id: 'stock',
            icon: shad.LucideIcons.warehouse,
            label: 'Stock',
            shortcutKey: 'S',
            isSelected: selectedIndex == 106,
            onTap: () => onSelectModule(106),
          ),
          DynamicSidebarNavItem(
            id: 'marketing',
            icon: shad.LucideIcons.userCheck,
            label: 'Marketing',
            shortcutKey: 'M',
            isSelected: selectedIndex == 107,
            onTap: () => onSelectModule(107),
          ),
          DynamicSidebarNavItem(
            id: 'sales_orders',
            icon: shad.LucideIcons.shoppingBag,
            label: 'Orders',
            shortcutKey: 'O',
            isSelected: selectedIndex == 108,
            onTap: () => onSelectModule(108),
          ),
          DynamicSidebarNavItem(
            id: 'dispatch',
            icon: shad.LucideIcons.truck,
            label: 'Dispatch',
            shortcutKey: 'D',
            isSelected: selectedIndex == 109,
            onTap: () => onSelectModule(109),
          ),
          DynamicSidebarNavItem(
            id: 'invoices',
            icon: shad.LucideIcons.fileCheck,
            label: 'Invoices',
            shortcutKey: 'I',
            isSelected: selectedIndex == 110,
            onTap: () => onSelectModule(110),
          ),
          DynamicSidebarNavItem(
            id: 'maps',
            icon: shad.LucideIcons.mapPin,
            label: 'Maps',
            shortcutKey: 'G',
            isSelected: selectedIndex == 112,
            onTap: () => onSelectModule(112),
          ),
        ],
      ),
      DynamicSidebarNavItem(
        id: 'finance',
        icon: shad.LucideIcons.landmark,
        label: 'Finance',
        shortcutKey: 'F',
        hasTrailingDivider: true,
        children: [
          DynamicSidebarNavItem(
            id: 'ledgers',
            icon: shad.LucideIcons.bookOpen,
            label: 'Ledgers',
            shortcutKey: 'L',
            isSelected: selectedIndex == 301,
            onTap: () => onSelectModule(301),
          ),
          DynamicSidebarNavItem(
            id: 'transactions',
            icon: shad.LucideIcons.arrowLeftRight,
            label: 'Transactions',
            shortcutKey: 'T',
            isSelected: selectedIndex == 302,
            onTap: () => onSelectModule(302),
          ),
          DynamicSidebarNavItem(
            id: 'reconciliation',
            icon: shad.LucideIcons.scale,
            label: 'Reconciliation',
            shortcutKey: 'R',
            isSelected: selectedIndex == 303,
            onTap: () => onSelectModule(303),
          ),
          DynamicSidebarNavItem(
            id: 'journals',
            icon: shad.LucideIcons.fileSpreadsheet,
            label: 'Journals',
            shortcutKey: 'J',
            isSelected: selectedIndex == 304,
            onTap: () => onSelectModule(304),
          ),
          DynamicSidebarNavItem(
            id: 'compliance',
            icon: shad.LucideIcons.shieldCheck,
            label: 'Compliance',
            shortcutKey: 'C',
            isSelected: selectedIndex == 305,
            onTap: () => onSelectModule(305),
          ),
          DynamicSidebarNavItem(
            id: 'books',
            icon: shad.LucideIcons.library,
            label: 'Books',
            shortcutKey: 'B',
            isSelected: selectedIndex == 306,
            onTap: () => onSelectModule(306),
          ),
        ],
      ),
      DynamicSidebarNavItem(
        id: 'workspace',
        icon: shad.LucideIcons.layers,
        label: 'Workspace',
        shortcutKey: 'W',
        children: [
          DynamicSidebarNavItem(
            id: 'admin',
            icon: shad.LucideIcons.shield,
            label: 'Admin',
            shortcutKey: 'A',
            isSelected: selectedIndex == 950,
            onTap: () => onSelectModule(950),
          ),
          DynamicSidebarNavItem(
            id: 'logs',
            icon: shad.LucideIcons.history,
            label: 'Logs',
            shortcutKey: 'L',
            isSelected: selectedIndex == 402,
            onTap: () => onSelectModule(402),
          ),
          DynamicSidebarNavItem(
            id: 'users',
            icon: shad.LucideIcons.userCog,
            label: 'Users',
            shortcutKey: 'U',
            isSelected: selectedIndex == 403,
            onTap: () => onSelectModule(403),
          ),
          DynamicSidebarNavItem(
            id: 'settings',
            icon: shad.LucideIcons.settings,
            label: 'Settings',
            shortcutKey: 'S',
            isSelected: selectedIndex == 999,
            onTap: () => onSelectModule(999),
          ),
          DynamicSidebarNavItem(
            id: 'shell',
            icon: shad.LucideIcons.panelTop,
            label: 'Shell',
            shortcutKey: 'H',
            isSelected: selectedIndex == 405,
            onTap: () => onSelectModule(405),
          ),
        ],
      ),
    ];
  }

  static IconData getIconForIndex(int index) {
    switch (index) {
      case 0:
        return shad.LucideIcons.house;
      case 1:
        return shad.LucideIcons.users;
      case 2:
        return shad.LucideIcons.package;
      case 3:
        return shad.LucideIcons.palette;
      case 5:
        return shad.LucideIcons.clipboardList;
      case 6:
        return shad.LucideIcons.scissors;
      case 7:
        return shad.LucideIcons.briefcase;
      case 10:
        return shad.LucideIcons.image;
      case 11:
        return shad.LucideIcons.folderTree;
      case 12:
        return shad.LucideIcons.compass;
      case 13:
        return shad.LucideIcons.truck;
      case 101:
        return shad.LucideIcons.bell;
      case 102:
        return shad.LucideIcons.listTodo;
      case 103:
        return shad.LucideIcons.flaskConical;
      case 104:
        return shad.LucideIcons.cpu;
      case 105:
        return shad.LucideIcons.receipt;
      case 106:
        return shad.LucideIcons.warehouse;
      case 107:
        return shad.LucideIcons.userCheck;
      case 108:
        return shad.LucideIcons.shoppingBag;
      case 109:
        return shad.LucideIcons.truck;
      case 110:
        return shad.LucideIcons.fileCheck;
      case 111:
        return shad.LucideIcons.contact;
      case 112:
        return shad.LucideIcons.mapPin;
      case 201:
        return shad.LucideIcons.packageCheck;
      case 202:
        return shad.LucideIcons.boxes;
      case 301:
        return shad.LucideIcons.bookOpen;
      case 302:
        return shad.LucideIcons.arrowLeftRight;
      case 303:
        return shad.LucideIcons.scale;
      case 304:
        return shad.LucideIcons.fileSpreadsheet;
      case 305:
        return shad.LucideIcons.shieldCheck;
      case 306:
        return shad.LucideIcons.library;
      case 402:
        return shad.LucideIcons.history;
      case 403:
        return shad.LucideIcons.userCog;
      case 405:
        return shad.LucideIcons.panelTop;
      case 950:
        return shad.LucideIcons.shield;
      case 999:
        return shad.LucideIcons.settings;
      default:
        return shad.LucideIcons.circleHelp;
    }
  }

  static String getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Parties';
      case 2:
        return 'Items';
      case 3:
        return 'Designs';
      case 5:
        return 'Purchase Orders';
      case 6:
        return 'Cuttings';
      case 7:
        return 'Jobs';
      case 10:
        return 'Media';
      case 11:
        return 'Groups';
      case 12:
        return 'Sources';
      case 13:
        return 'Transports';
      case 101:
        return 'Notifications';
      case 102:
        return 'Tasks';
      case 103:
        return 'Recipes';
      case 104:
        return 'Strategy';
      case 105:
        return 'Bills';
      case 106:
        return 'Stock';
      case 107:
        return 'Marketing';
      case 108:
        return 'Sales Orders';
      case 109:
        return 'Dispatch';
      case 110:
        return 'Invoices';
      case 111:
        return 'Contacts';
      case 112:
        return 'Maps';
      case 201:
        return 'Inward';
      case 202:
        return 'Packing';
      case 301:
        return 'Ledgers';
      case 302:
        return 'Transactions';
      case 303:
        return 'Reconciliation';
      case 304:
        return 'Journals';
      case 305:
        return 'Compliance';
      case 306:
        return 'Books';
      case 402:
        return 'Logs';
      case 403:
        return 'Users';
      case 405:
        return 'Shell';
      case 950:
        return 'Admin';
      case 999:
        return 'Settings';
      default:
        return 'Dhaaga';
    }
  }
}
