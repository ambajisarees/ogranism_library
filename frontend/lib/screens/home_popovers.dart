/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Anchored workspace popover builders for `HomeScreen` (`home_popovers.dart`):
     * `QuickAddPopoverContent` (`Alt + Q` rail button)
     * `SearchPopoverContent` (`Alt + K` top bar button)
     * `NotificationsPopoverContent` (`Alt + N` top bar button)
     * `TasksPopoverContent` (`Alt + T` top bar button)
     * `ProfilePopoverContent` (`Alt + U` top bar button)
     * `MobileMoreOptionsPopoverContent` (mobile 3-dots menu)

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses native `shad.OutlineButton`, `shad.Button.ghost`, `shad.TextField`,
     `shad.Divider`, `shad.DensityGap`, and `theme.colorScheme` tokens.
   - Zero ad-hoc Material colors; badge/icon states bind live to `AuthService` and
     `themeModeNotifier`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Always invoke `onClose` cleanly before routing or opening dialogs so overlays
     never stack unexpectedly.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: wire live database query counts into `TasksPopoverContent`.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Divider;
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../models/workspace/mdl_auth.dart';
import '../screens/home_navigation_config.dart';
import '../services/workspace/srv_auth.dart';

class _PopoverDestination {
  final int index;
  final String title;
  final String subtitle;

  const _PopoverDestination(this.index, this.title, this.subtitle);
}

const List<_PopoverDestination> _allSearchDestinations = [
  _PopoverDestination(0, 'Home', 'Executive pulse and module overview'),
  _PopoverDestination(1, 'Parties', 'Customers, suppliers & karigars'),
  _PopoverDestination(11, 'Groups', 'Account groups & party classifications'),
  _PopoverDestination(111, 'Contacts', 'Synced Google contacts & phones'),
  _PopoverDestination(12, 'Sources', 'Brokers, haste & supply sources'),
  _PopoverDestination(13, 'Transports', 'Transport carriers, LR & E-Way Bill IDs'),
  _PopoverDestination(3, 'Designs', 'Saree design catalog & SKUs'),
  _PopoverDestination(2, 'Items', 'Grey qualities & item masters'),
  _PopoverDestination(10, 'Media', 'Photoshoot images & design assets'),
  _PopoverDestination(103, 'Recipes', 'Mill dyeing & printing programs'),
  _PopoverDestination(104, 'Strategy', 'Production & buying forecasts'),
  _PopoverDestination(5, 'Purchase Orders', 'Finish, lace & grey orders'),
  _PopoverDestination(6, 'Cuttings', 'In-house cutting batches'),
  _PopoverDestination(7, 'Jobs', 'Stitching, diamond & embroidery jobs'),
  _PopoverDestination(201, 'Inward', 'Grey & mill inward receipts'),
  _PopoverDestination(202, 'Packing', 'Finished folding & bale packing'),
  _PopoverDestination(105, 'Bills', 'Supplier & job work purchase bills'),
  _PopoverDestination(106, 'Stock', 'Ready stock & WIP inventory'),
  _PopoverDestination(107, 'Marketing', 'CRM leads & WhatsApp outreach'),
  _PopoverDestination(108, 'Sales Orders', 'Customer order bookings'),
  _PopoverDestination(109, 'Dispatch', 'Challans, packing & transport LR'),
  _PopoverDestination(110, 'Invoices', 'GST sales invoices & E-Invoicing'),
  _PopoverDestination(112, 'Maps', 'All-India village, pincode & sales zone GIS map'),
  _PopoverDestination(301, 'Ledgers', 'FAS running party accounts'),
  _PopoverDestination(302, 'Transactions', 'Receipts & payments (RECPAY)'),
  _PopoverDestination(303, 'Reconciliation', 'Bank statement reconciliation'),
  _PopoverDestination(304, 'Journals', 'Contra, journal & internal JVs'),
  _PopoverDestination(305, 'Compliance', 'GST, TDS, E-Way & E-Invoice filings'),
  _PopoverDestination(306, 'Books', 'Trial balance, P&L & daybook'),
  _PopoverDestination(950, 'Admin', 'Firm masters, voucher series & fiscal years'),
  _PopoverDestination(402, 'Logs', 'Deleted items & audit trail'),
  _PopoverDestination(403, 'Users', 'Staff logins & role permissions'),
  _PopoverDestination(999, 'Settings', 'Application preferences & system configuration'),
  _PopoverDestination(405, 'Shell', 'Live DyLandingShl & 2-row DyHeader interactive workbench'),
];

class QuickAddPopoverContent extends StatelessWidget {
  final ValueChanged<int> onSelectModule;
  final VoidCallback onClose;

  const QuickAddPopoverContent({
    super.key,
    required this.onSelectModule,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final items = const [
      _PopoverDestination(1, 'New Party / Account', 'Masters > Parties'),
      _PopoverDestination(5, 'New Purchase Order', 'Pipeline > Orders'),
      _PopoverDestination(6, 'New Cutting Card', 'Pipeline > Cuttings'),
      _PopoverDestination(7, 'New Job Work Challan', 'Pipeline > Jobs'),
      _PopoverDestination(110, 'New Sales Invoice', 'Sales > Invoices'),
      _PopoverDestination(302, 'New Receipt / Payment', 'Finance > Transactions'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Add',
          style: theme.typography.small.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.foreground,
          ),
        ),
        const shad.DensityGap(shad.gapXs),
        const shad.Divider(),
        const shad.DensityGap(shad.gapXs),
        for (final item in items)
          shad.Button.ghost(
            alignment: AlignmentDirectional.centerStart,
            onPressed: () {
              onClose();
              onSelectModule(item.index);
            },
            child: Row(
              children: [
                Icon(
                  HomeNavigationConfig.getIconForIndex(item.index),
                  size: theme.iconTheme.small.size,
                  color: colors.foreground,
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.foreground,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SearchPopoverContent extends StatefulWidget {
  final ValueChanged<int> onSelectModule;
  final VoidCallback onClose;
  final bool isDialog;

  const SearchPopoverContent({
    super.key,
    required this.onSelectModule,
    required this.onClose,
    this.isDialog = false,
  });

  @override
  State<SearchPopoverContent> createState() => _SearchPopoverContentState();
}

class _SearchPopoverContentState extends State<SearchPopoverContent> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final padUnit = theme.density.baseContainerPadding * scaling;

    final q = _query.trim().toLowerCase();
    final matches = _allSearchDestinations.where((d) {
      if (q.isEmpty) return true;
      return d.title.toLowerCase().contains(q) ||
          d.subtitle.toLowerCase().contains(q);
    }).toList();

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
            matches.isNotEmpty) {
          widget.onClose();
          widget.onSelectModule(matches.first.index);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isDialog) ...[
            Row(
              children: [
                Icon(
                  shad.LucideIcons.search,
                  size: theme.iconTheme.small.size,
                  color: colors.primary,
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: Text(
                    'Quick Jump & Global Search',
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                ),
                shad.IconButton.ghost(
                  size: shad.ButtonSize.small,
                  density: shad.ButtonDensity.iconDense,
                  icon: Icon(
                    shad.LucideIcons.x,
                    size: theme.iconTheme.small.size,
                    color: colors.mutedForeground,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),
          ],
          shad.TextField(
            controller: _queryController,
            autofocus: true,
            placeholder: const Text('Search modules, ledgers & masters...'),
            onChanged: (v) => setState(() => _query = v),
            features: [
              shad.InputFeature.leading(
                Icon(
                  shad.LucideIcons.search,
                  size: theme.iconTheme.small.size,
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapSm),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.isDialog ? 360 * scaling : padUnit * 18,
            ),
            child: matches.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(padUnit * shad.padSm),
                    child: Text(
                      'No matching modules',
                      style: theme.typography.small.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: matches.length,
                    itemBuilder: (context, idx) {
                      final dest = matches[idx];
                      return shad.Button.ghost(
                        alignment: AlignmentDirectional.centerStart,
                        onPressed: () {
                          widget.onClose();
                          widget.onSelectModule(dest.index);
                        },
                        child: Row(
                          children: [
                            Icon(
                              HomeNavigationConfig.getIconForIndex(dest.index),
                              size: theme.iconTheme.small.size,
                              color: colors.foreground,
                            ),
                            const shad.DensityGap(shad.gapSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dest.title,
                                    style: theme.typography.small.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.foreground,
                                    ),
                                  ),
                                  Text(
                                    dest.subtitle,
                                    style: theme.typography.xSmall.copyWith(
                                      color: colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPopoverContent extends StatelessWidget {
  final VoidCallback onOpenApprovals;
  final VoidCallback onClose;
  final bool isSheet;

  const NotificationsPopoverContent({
    super.key,
    required this.onOpenApprovals,
    required this.onClose,
    this.isSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onClose,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          mainAxisSize: isSheet ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notifications',
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                ),
                if (isSheet)
                  shad.IconButton.ghost(
                    size: shad.ButtonSize.small,
                    density: shad.ButtonDensity.iconDense,
                    icon: Icon(
                      shad.LucideIcons.x,
                      size: theme.iconTheme.small.size,
                      color: colors.mutedForeground,
                    ),
                    onPressed: onClose,
                  ),
              ],
            ),
            const shad.DensityGap(shad.gapXs),
            const shad.Divider(),
            if (isSheet) const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class TasksPopoverContent extends StatelessWidget {
  final ValueChanged<int> onSelectModule;
  final VoidCallback onClose;
  final bool isSheet;

  const TasksPopoverContent({
    super.key,
    required this.onSelectModule,
    required this.onClose,
    this.isSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onClose,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          mainAxisSize: isSheet ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tasks',
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                ),
                if (isSheet)
                  shad.IconButton.ghost(
                    size: shad.ButtonSize.small,
                    density: shad.ButtonDensity.iconDense,
                    icon: Icon(
                      shad.LucideIcons.x,
                      size: theme.iconTheme.small.size,
                      color: colors.mutedForeground,
                    ),
                    onPressed: onClose,
                  ),
              ],
            ),
            const shad.DensityGap(shad.gapXs),
            const shad.Divider(),
            if (isSheet) const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class ProfilePopoverContent extends StatelessWidget {
  final VoidCallback onClose;

  const ProfilePopoverContent({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return ValueListenableBuilder<AppProfileModel?>(
      valueListenable: AuthService().activeProfileNotifier,
      builder: (context, profile, _) {
        final userId = profile?.username ?? '';
        final contact = profile?.mobileNo.isNotEmpty == true
            ? profile!.mobileNo
            : (AuthService().currentUser?.email ?? 'Internal App');
        final name = profile?.fullName ?? 'ERP User';
        final role = profile?.roleName ?? 'STAFF';

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              name,
              style: theme.typography.textSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userId.isNotEmpty ? '$userId • $contact' : contact,
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            const shad.DensityGap(shad.gapXs),
            Row(
              children: [
                shad.PrimaryBadge(
                  child: Text(
                    role,
                    style: theme.typography.xSmall,
                  ),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),
            const shad.Divider(),
            const shad.DensityGap(shad.gapSm),
            shad.OutlineButton(
              size: shad.ButtonSize.small,
              onPressed: () async {
                onClose();
                await AuthService().signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

class MobileMoreOptionsPopoverContent extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onTasks;
  final VoidCallback onProfile;
  final VoidCallback onClose;

  const MobileMoreOptionsPopoverContent({
    super.key,
    required this.onSearch,
    required this.onNotifications,
    required this.onTasks,
    required this.onProfile,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final options = [
      (
        icon: shad.LucideIcons.search,
        label: 'Search Modules',
        action: onSearch,
      ),
      (
        icon: shad.LucideIcons.bell,
        label: 'Notifications',
        action: onNotifications,
      ),
      (
        icon: shad.LucideIcons.listTodo,
        label: 'Pending Tasks',
        action: onTasks,
      ),
      (
        icon: shad.LucideIcons.user,
        label: 'User Profile',
        action: onProfile,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Workspace Options',
          style: theme.typography.small.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.foreground,
          ),
        ),
        const shad.DensityGap(shad.gapXs),
        const shad.Divider(),
        const shad.DensityGap(shad.gapXs),
        for (final opt in options)
          shad.Button.ghost(
            alignment: AlignmentDirectional.centerStart,
            onPressed: () {
              onClose();
              opt.action();
            },
            child: Row(
              children: [
                Icon(
                  opt.icon,
                  size: theme.iconTheme.small.size,
                  color: colors.foreground,
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: Text(
                    opt.label,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
