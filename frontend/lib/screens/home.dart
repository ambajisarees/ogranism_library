/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Root ERP workspace container (`HomeScreen`) coordinating the multi-tab `DynamicHeaderTabs`
     top workspace (`Alt+1..9`), 5 top-right utility action popovers (`Alt+K` Search,
     `Alt+N` Notifications, `Alt+T` Tasks, `Alt+D` Theme, `Alt+U` User), and left
     `DynamicSidebarNav` rail (`H`, primary `Q`, plus 5 divider-separated modules
     `M, P, S, F, W` and `Alt+B` toggle).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Capped at 5 simultaneous workspace tabs (recycles tab 5 when adding a 6th module).
   - Quick Add (`Alt+Q`) and Top Utility buttons (`Alt+K/N/T/D/U`) anchor popovers
     directly to their trigger buttons via `_toggleAnchoredPopover`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Rule 7 (`GEMINI.md`): Keep `FocusNode(skipTraversal: true)` directly on `TabPane` trailing
     action buttons rather than wrapping header rows in `Focus(descendantsAreFocusable: false)`.
   - Window focus transitions (`onWindowBlur` / `onWindowFocus`) clear `Alt` and `Tab`-hold
     modifier states and disarm sidebar folders so `Alt + Tab` window switches never stick `Alt`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: persist open workspace tabs across desktop restarts.
================================================================================
*/

import 'dart:io' show exit;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:window_manager/window_manager.dart';
import '../dynamic_ai/micro/dy_dhaaga_logo.dart';
import '../dynamic_ai/page/dy_page_header.dart';
import '../dynamic_ai/root/dy_shell.dart';
import '../dynamic_ai/root/sidebar_nav.dart';
import '../dynamic_ai/root/dy_module_tabs.dart';
import '../dynamic_ai/specs/dy_color_system.dart';
import '../dynamic_ai/specs/dy_grid_system.dart';
import '../core/keyboard_manager_widget.dart';
import '../services/service_keyboard_shortcuts.dart';
import '../services/service_mobile_shell.dart';
import '../main.dart';
import 'home_navigation_config.dart';
import 'home_popovers.dart';
import '../models/workspace/mdl_auth.dart';
import '../services/workspace/srv_auth.dart';
import 'pipeline/bills/scr_pb_landing.dart';
import 'pipeline/cuttings/scr_cc_landing.dart';
import 'pipeline/inward/scr_mr_landing.dart';
import 'pipeline/jobs/scr_jw_landing.dart';
import 'pipeline/orders/scr_po_landing.dart';
import 'pipeline/packing/scr_pck_landing.dart';
import 'pipeline/recipes/scr_rcp_landing.dart';
import 'pipeline/strategy/scr_str_landing.dart';
import 'masters/contacts/scr_cnt_landing.dart';
import 'masters/designs/scr_dsn_landing.dart';
import 'masters/groups/scr_grp_landing.dart';
import 'masters/items/scr_itm_landing.dart';
import 'masters/media/scr_mda_landing.dart';
import 'masters/parties/scr_pty_landing.dart';
import 'masters/sources/scr_src_landing.dart';
import 'masters/transports/scr_trn_landing.dart';
import 'sales/dispatch/scr_dsp_landing.dart';
import 'sales/invoices/scr_sales_landing.dart';
import 'sales/maps/scr_geo_zone_map.dart';
import 'sales/marketing/scr_mkt_landing.dart';
import 'sales/orders/scr_so_landing.dart';
import 'sales/stock/scr_stk_landing.dart';
import 'finance/books/scr_bks_landing.dart';
import 'finance/compliance/scr_cmp_landing.dart';
import 'finance/journals/scr_jrn_landing.dart';
import 'finance/ledgers/scr_ldg_landing.dart';
import 'finance/reconciliation/scr_rec_landing.dart';
import 'finance/transactions/scr_txn_landing.dart';
import 'workspace/auth/widgets/dia_admin_approvals.dart';
import 'workspace/shell/scr_workspace_shell_demo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  final GlobalKey<DynamicSidebarNavState> _sidebarNavKey =
      GlobalKey<DynamicSidebarNavState>();
  final GlobalKey _searchBtnKey = GlobalKey();
  final GlobalKey _notifBtnKey = GlobalKey();
  final GlobalKey _tasksBtnKey = GlobalKey();
  final GlobalKey _userBtnKey = GlobalKey();

  final List<DynamicTabItem> _openTabs = [];
  int _selectedTabWorkspaceIndex = 0;
  bool _isSidebarExpanded = false;
  bool _isModuleLoading = false;
  bool _isExitDialogOpen = false;
  shad.OverlayCompleter<dynamic>? _activePopover;
  VoidCallback? _closeActiveOverlayCallback;
  OverlayEntry? _mobileNavOverlayEntry;
  String? _activePopoverKey;

  void _triggerModuleLoading() {
    setState(() {
      _isModuleLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isModuleLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
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

  @override
  void dispose() {
    _activePopover?.close();
    _closeMobileNavRail();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowBlur() {
    ServiceKeyboardShortcuts.instance.resetWorkspaceKeyboardState();
    _sidebarNavKey.currentState?.resetSidebarKeyboardState();
  }

  @override
  void onWindowFocus() {
    ServiceKeyboardShortcuts.instance.resetWorkspaceKeyboardState();
  }

  @override
  void onWindowClose() async {
    if (_isExitDialogOpen) return;
    final isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      _isExitDialogOpen = true;
      final completer = shad.showOverlay<void>(
        context,
        const shad.DialogConfiguration(
          alignment: Alignment.center,
        ),
        builder: (overlayContext) {
          Future<void> confirmExit() async {
            shad.closeOverlay(overlayContext);
            await windowManager.setPreventClose(false);
            await windowManager.hide();
            exit(0);
          }

          void cancelExit() => shad.closeOverlay(overlayContext);

          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.keyN): cancelExit,
              const SingleActivator(LogicalKeyboardKey.keyY): confirmExit,
            },
            child: Focus(
              autofocus: true,
              child: shad.AlertDialog(
                title: const Text('Exit?'),
                content: const Text('Any unsaved progress will be lost'),
                actions: [
                  PageHeaderActionButton(
                    label: 'No',
                    keyCap: 'N',
                    onPressed: cancelExit,
                  ),
                  PageHeaderActionButton(
                    label: 'Yes',
                    keyCap: 'Y',
                    isDestructive: true,
                    onPressed: confirmExit,
                  ),
                ],
              ),
            ),
          );
        },
      );
      completer.future.whenComplete(() {
        _isExitDialogOpen = false;
      });
    }
  }

  void _closeActivePopover() {
    if (_closeActiveOverlayCallback != null) {
      final cb = _closeActiveOverlayCallback;
      _closeActiveOverlayCallback = null;
      cb?.call();
    }
    _activePopover?.close();
    _activePopover = null;
    _activePopoverKey = null;
  }

  void _toggleAnchoredPopover({
    required String popoverKey,
    required BuildContext anchorContext,
    required double width,
    required Widget Function(VoidCallback closePopover) contentBuilder,
    bool anchorRightEdge = true,
  }) {
    if (_activePopoverKey == popoverKey && _activePopover != null) {
      _closeActivePopover();
      return;
    }
    _closeActivePopover();
    _activePopoverKey = popoverKey;

    final theme = shad.Theme.of(context);
    final gapUnit = theme.density.baseGap * theme.scaling;

    late final shad.OverlayCompleter<void> completer;
    completer = shad.showOverlay<void>(
      anchorContext,
      shad.PopoverConfiguration(
        alignment: anchorRightEdge
            ? AlignmentDirectional.topEnd
            : AlignmentDirectional.topStart,
        anchorAlignment: anchorRightEdge
            ? AlignmentDirectional.bottomEnd
            : AlignmentDirectional.topEnd,
        offset: anchorRightEdge
            ? Offset(0, gapUnit * shad.gapSm)
            : Offset(gapUnit * shad.gapSm, 0),
        dismissBackdropFocus: true,
        allowInvertVertical: true,
        allowInvertHorizontal: true,
      ),
      builder: (overlayContext) {
        _closeActiveOverlayCallback = () {
          if (overlayContext.mounted) {
            shad.closeOverlay(overlayContext);
          }
        };
        return shad.ModalContainer(
          child: SizedBox(
            width: width,
            child: contentBuilder(() => shad.closeOverlay(overlayContext)),
          ),
        );
      },
    );
    _activePopover = completer;
    completer.future.whenComplete(() {
      if (_activePopover == completer) {
        _activePopover = null;
        _closeActiveOverlayCallback = null;
        _activePopoverKey = null;
      }
    });
  }

  void _toggleRightSideSheet({
    required String sheetKey,
    required Widget Function(VoidCallback closeSheet) contentBuilder,
  }) {
    if (_activePopoverKey == sheetKey && _activePopover != null) {
      _closeActivePopover();
      return;
    }
    _closeActivePopover();
    _activePopoverKey = sheetKey;

    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final padUnit = theme.density.baseContainerPadding * scaling;

    late final shad.OverlayCompleter<void> completer;
    completer = shad.showOverlay<void>(
      context,
      shad.SheetConfiguration(
        position: shad.OverlayPosition.right,
        barrierDismissible: true,
        draggable: true,
        barrierColor: Colors.black.withValues(alpha: 0.35),
      ),
      builder: (overlayContext) {
        _closeActiveOverlayCallback = () {
          if (overlayContext.mounted) {
            shad.closeOverlay(overlayContext);
          }
        };
        return SizedBox(
          width: 380 * scaling,
          child: Padding(
            padding: EdgeInsets.all(padUnit * shad.padMd),
            child: contentBuilder(() => shad.closeOverlay(overlayContext)),
          ),
        );
      },
    );
    _activePopover = completer;
    completer.future.whenComplete(() {
      if (_activePopover == completer) {
        _activePopover = null;
        _closeActiveOverlayCallback = null;
        _activePopoverKey = null;
      }
    });
  }

  void _openQuickAddPopover(BuildContext anchorContext) {
    final theme = shad.Theme.of(context);
    final padUnit = theme.density.baseContainerPadding * theme.scaling;
    _toggleAnchoredPopover(
      popoverKey: 'Q',
      anchorContext: anchorContext,
      width: padUnit * 17,
      anchorRightEdge: false,
      contentBuilder: (close) => QuickAddPopoverContent(
        onSelectModule: _handleModuleSelection,
        onClose: close,
      ),
    );
  }

  void _showGlobalSearch() {
    if (_activePopoverKey == 'K' && _activePopover != null) {
      _closeActivePopover();
      return;
    }
    _closeActivePopover();
    _activePopoverKey = 'K';

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final padUnit = theme.density.baseContainerPadding * scaling;

    late final shad.OverlayCompleter<void> completer;
    completer = shad.showOverlay<void>(
      context,
      shad.DialogConfiguration(
        alignment: Alignment.center,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.45),
      ),
      builder: (overlayContext) {
        _closeActiveOverlayCallback = () {
          if (overlayContext.mounted) {
            shad.closeOverlay(overlayContext);
          }
        };
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 540 * scaling),
            child: shad.OutlinedContainer(
              backgroundColor: colors.card,
              borderColor: colors.border,
              borderRadius: theme.borderRadiusLg,
              padding: EdgeInsets.all(padUnit * shad.padMd),
              child: SearchPopoverContent(
                isDialog: true,
                onSelectModule: _handleModuleSelection,
                onClose: () => shad.closeOverlay(overlayContext),
              ),
            ),
          ),
        );
      },
    );
    _activePopover = completer;
    completer.future.whenComplete(() {
      if (_activePopover == completer) {
        _activePopover = null;
        _closeActiveOverlayCallback = null;
        _activePopoverKey = null;
      }
    });
  }

  void _handleHeaderShortcut(String keyChar) {
    final theme = shad.Theme.of(context);
    final padUnit = theme.density.baseContainerPadding * theme.scaling;
    switch (keyChar.toUpperCase()) {
      case 'K':
        _showGlobalSearch();
        return;
      case 'N':
        _toggleRightSideSheet(
          sheetKey: 'N',
          contentBuilder: (close) => NotificationsPopoverContent(
            isSheet: true,
            onOpenApprovals: () => showAdminApprovalsDialog(context),
            onClose: close,
          ),
        );
        return;
      case 'T':
        _toggleRightSideSheet(
          sheetKey: 'T',
          contentBuilder: (close) => TasksPopoverContent(
            isSheet: true,
            onSelectModule: _handleModuleSelection,
            onClose: close,
          ),
        );
        return;
      case 'D':
        _closeActivePopover();
        themeModeNotifier.value =
            themeModeNotifier.value == shad.ThemeMode.dark
                ? shad.ThemeMode.light
                : shad.ThemeMode.dark;
        return;
      case 'U':
        _toggleAnchoredPopover(
          popoverKey: 'U',
          anchorContext: _userBtnKey.currentContext ?? context,
          width: padUnit * 15,
          contentBuilder: (close) => ProfilePopoverContent(onClose: close),
        );
        return;
    }
  }

  void _closeMobileNavRail() {
    _mobileNavOverlayEntry?.remove();
    _mobileNavOverlayEntry = null;
  }

  void _openMobileNavDrawer(
    BuildContext context,
    Widget expandedHeaderRow,
    int selectedModuleIndex,
    double headerBarHeight,
  ) {
    _closeActivePopover();
    if (_mobileNavOverlayEntry != null) {
      _closeMobileNavRail();
      return;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        final oTheme = shad.Theme.of(overlayContext);
        final oColors = oTheme.colorScheme;
        final isDark = oColors.brightness == Brightness.dark;
        final level0Background = DyColorSystem.resolveRootBackground(isDark);
        final drawerWidth =
            (MediaQuery.sizeOf(overlayContext).width * 0.80).clamp(250.0, 300.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeMobileNavRail,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.25),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  width: drawerWidth,
                  height: double.infinity,
                  child: shad.OutlinedContainer(
                    clipBehavior: Clip.antiAlias,
                    theme: shad.OutlinedContainerTheme(
                      backgroundColor: level0Background,
                      borderColor: oColors.border,
                      borderWidth: 1.0,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(oTheme.radiusMd),
                        bottomRight: Radius.circular(oTheme.radiusMd),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.45 : 0.16),
                        blurRadius: 24 * oTheme.scaling,
                        offset: Offset(6 * oTheme.scaling, 0),
                      ),
                    ],
                    child: DynamicSidebarNav(
                      expanded: true,
                      expandedWidth: drawerWidth,
                      header: SizedBox(
                        height: headerBarHeight,
                        child: expandedHeaderRow,
                      ),
                      items: HomeNavigationConfig.buildSidebarItems(
                        selectedIndex: selectedModuleIndex,
                        onSelectModule: (idx) {
                          _closeMobileNavRail();
                          _handleModuleSelection(idx);
                        },
                        onQuickAddTap: (btnCtx) {
                          _closeMobileNavRail();
                          _openQuickAddPopover(context);
                        },
                      ),
                      footerItems: [
                        const shad.NavigationDivider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: oTheme.density.baseGap *
                                oTheme.scaling *
                                shad.gapXs,
                            vertical: oTheme.density.baseGap *
                                oTheme.scaling *
                                shad.gapXs,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ValueListenableBuilder<AppProfileModel?>(
                                  valueListenable:
                                      AuthService().activeProfileNotifier,
                                  builder: (context, profile, _) {
                                    final displayName =
                                        (profile?.fullName.isNotEmpty ?? false)
                                            ? profile!.fullName
                                            : (profile?.username.isNotEmpty ??
                                                    false)
                                                ? profile!.username
                                                : (AuthService()
                                                        .currentUser
                                                        ?.email ??
                                                    'Admin');
                                    final roleLabel =
                                        profile?.roleName.isNotEmpty == true
                                            ? profile!.roleName
                                            : 'STAFF';
                                    return shad.Button.ghost(
                                      alignment: AlignmentDirectional.centerStart,
                                      onPressed: () {
                                        _closeMobileNavRail();
                                        _handleHeaderShortcut('U');
                                      },
                                      child: Row(
                                        children: [
                                          shad.Avatar(
                                            initials: shad.Avatar.getInitials(
                                              displayName,
                                            ),
                                            theme: shad.AvatarTheme(
                                              size: 28.0 * oTheme.scaling,
                                              borderRadius: oTheme.radiusMd,
                                              backgroundColor: oColors.primary
                                                  .withValues(alpha: 0.14),
                                              textStyle: oTheme
                                                  .typography.xSmall
                                                  .copyWith(
                                                color: oColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const shad.DensityGap(shad.gapSm),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  displayName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: oTheme.typography.small
                                                      .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: oColors.foreground,
                                                  ),
                                                ),
                                                Text(
                                                  '$roleLabel • FY 26-27',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: oTheme
                                                      .typography.xSmall
                                                      .copyWith(
                                                    color:
                                                        oColors.mutedForeground,
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
                              const shad.DensityGap(shad.gapXs),
                              ValueListenableBuilder<shad.ThemeMode>(
                                valueListenable: themeModeNotifier,
                                builder: (context, mode, _) {
                                  final isDarkMode = mode == shad.ThemeMode.dark;
                                  return shad.IconButton.ghost(
                                    focusNode: FocusNode(skipTraversal: true),
                                    size: shad.ButtonSize.normal,
                                    density: shad.ButtonDensity.icon,
                                    icon: Icon(
                                      isDarkMode
                                          ? shad.LucideIcons.sun
                                          : shad.LucideIcons.moon,
                                      size:
                                          oTheme.iconTheme.medium.size ?? 20.0,
                                      color: oColors.foreground,
                                    ),
                                    onPressed: () => _handleHeaderShortcut('D'),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    _mobileNavOverlayEntry = entry;
    overlay.insert(entry);
  }

  void _resetKeyboardAndFocusOnTabChange() {
    _closeActivePopover();
    _sidebarNavKey.currentState?.resetSidebarKeyboardState();
    ServiceKeyboardShortcuts.instance.resetWorkspaceKeyboardState();
    ServiceMobileShell.instance.clear();
  }

  void _handleModuleSelection(int index) {
    if (index == 100) {
      _showGlobalSearch();
      return;
    }
    _resetKeyboardAndFocusOnTabChange();
    _triggerModuleLoading();
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
    _resetKeyboardAndFocusOnTabChange();
    setState(() {
      _openTabs.removeAt(index);
      if (_selectedTabWorkspaceIndex >= _openTabs.length) {
        _selectedTabWorkspaceIndex = _openTabs.length - 1;
      }
    });
  }

  void _addNewTab() {
    _resetKeyboardAndFocusOnTabChange();
    final nextId = DateTime.now().millisecondsSinceEpoch.toString();
    final tabIndex = _openTabs.length + 1;
    setState(() {
      _openTabs.add(
        DynamicTabItem(
          id: nextId,
          title: 'Workspace #$tabIndex',
          icon: shad.LucideIcons.fileText,
          content: FallbackDashboardWidget(title: 'Workspace #$tabIndex'),
        ),
      );
      _selectedTabWorkspaceIndex = _openTabs.length - 1;
    });
  }

  List<DynamicSidebarNavItem> _buildSidebarItems(int selectedIndex) =>
      HomeNavigationConfig.buildSidebarItems(
        selectedIndex: selectedIndex,
        onSelectModule: _handleModuleSelection,
        onQuickAddTap: _openQuickAddPopover,
      );

  IconData _getIconForIndex(int index) =>
      HomeNavigationConfig.getIconForIndex(index);

  String _getPageTitle(int index) =>
      HomeNavigationConfig.getPageTitle(index);

  Widget _buildBodyForIndex(int index) {
    switch (index) {
      case 1:
        return const ScrPtyLanding();
      case 2:
        return const ScrItmLanding();
      case 3:
        return const ScrDsnLanding();
      case 5:
        return const ScrPoLanding();
      case 6:
        return const ScrCcLanding();
      case 7:
        return const ScrJwLanding();
      case 10:
        return const ScrMdaLanding();
      case 11:
        return const ScrGrpLanding();
      case 12:
        return const ScrSrcLanding();
      case 13:
        return const ScrTrnLanding();
      case 103:
        return const ScrRcpLanding();
      case 104:
        return const ScrStrLanding();
      case 105:
        return const ScrPbLanding();
      case 106:
        return const ScrStkLanding();
      case 107:
        return const ScrMktLanding();
      case 108:
        return const ScrSoLanding();
      case 109:
        return const ScrDspLanding();
      case 110:
        return const ScrSalesLanding();
      case 111:
        return const ScrCntLanding();
      case 112:
        return const ScrGeoZoneMap();
      case 201:
        return const ScrMrLanding();
      case 202:
        return const ScrPckLanding();
      case 301:
        return const ScrLdgLanding();
      case 302:
        return const ScrTxnLanding();
      case 303:
        return const ScrRecLanding();
      case 304:
        return const ScrJrnLanding();
      case 305:
        return const ScrCmpLanding();
      case 306:
        return const ScrBksLanding();
      case 405:
        return const ScrWorkspaceShellDemo();
      default:
        return FallbackDashboardWidget(
          title: _getPageTitle(index),
        );
    }
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

    const brandMark = DyDhaagaLogo(animated: true);

    final headerBarHeight =
        (theme.density.baseContainerPadding * theme.scaling * shad.pad2xl) +
            (theme.density.baseGap * theme.scaling * shad.gapXs);

    final expandedHeaderRow = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.density.baseGap * theme.scaling * shad.gapXs,
      ),
      child: Row(
        children: [
          brandMark,
          const shad.DensityGap(shad.gapSm),
          const Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: DyDhaagaWordmark(),
            ),
          ),
        ],
      ),
    );

    return KeyboardManagerWidget(
      onGlobalSearch: _showGlobalSearch,
      onWorkspaceTab: (index) {
        if (index >= 0 && index < _openTabs.length) {
          _resetKeyboardAndFocusOnTabChange();
          setState(() => _selectedTabWorkspaceIndex = index);
        }
      },
      onCycleTab: (forward) {
        if (_openTabs.isEmpty) return;
        _resetKeyboardAndFocusOnTabChange();
        setState(() {
          if (forward) {
            _selectedTabWorkspaceIndex =
                (_selectedTabWorkspaceIndex + 1) % _openTabs.length;
          } else {
            _selectedTabWorkspaceIndex =
                (_selectedTabWorkspaceIndex - 1 + _openTabs.length) %
                    _openTabs.length;
          }
        });
      },
      onSidebarShortcut: (keyChar) =>
          _sidebarNavKey.currentState?.handleShortcutKey(keyChar),
      onHeaderShortcut: _handleHeaderShortcut,
      onSubmoduleShortcut: (keyChar) =>
          _sidebarNavKey.currentState?.handleExpandedSubmoduleKey(keyChar) ??
          false,
      onBackspaceBacktrack: () {
        if (_activePopover != null) {
          _closeActivePopover();
          return;
        }
        _sidebarNavKey.currentState?.cancelArmedFolder();
      },
      onToggleSidebar: () =>
          setState(() => _isSidebarExpanded = !_isSidebarExpanded),
      onEscapeOverlay: () {
        _closeMobileNavRail();
        _closeActivePopover();
        _sidebarNavKey.currentState?.cancelArmedFolder();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile =
              constraints.maxWidth < DyGridSystem.breakpointMobile;

          if (isMobile) {
            final activeTab = _openTabs.isNotEmpty
                ? _openTabs[_selectedTabWorkspaceIndex.clamp(
                    0,
                    _openTabs.length - 1,
                  )]
                : null;

            return DynamicWorkspaceShell(
              isMobile: true,
              content: ValueListenableBuilder<int>(
                valueListenable: AuthService().pendingApprovalsCountNotifier,
                builder: (context, pendingCount, _) {
                  return DynamicMobileShell(
                    title: activeTab?.title ?? 'Home',
                    content: activeTab?.content ??
                        const FallbackDashboardWidget(title: 'Home'),
                    isLoading: _isModuleLoading,
                    onOpenDrawer: () => _openMobileNavDrawer(
                      context,
                      expandedHeaderRow,
                      selectedModuleIndex,
                      headerBarHeight,
                    ),
                    searchBtnKey: _searchBtnKey,
                    onSearchPressed: _showGlobalSearch,
                    notifBtnKey: _notifBtnKey,
                    onNotificationsPressed: () => _handleHeaderShortcut('N'),
                    notificationCount: pendingCount,
                    tasksBtnKey: _tasksBtnKey,
                    onTasksPressed: () => _handleHeaderShortcut('T'),
                    taskCount: 3,
                  );
                },
              ),
            );
          }

          return DynamicWorkspaceShell(
            sidebar: Focus(
              skipTraversal: true,
              descendantsAreFocusable: false,
              child: DynamicSidebarNav(
                key: _sidebarNavKey,
                expanded: _isSidebarExpanded,
                items: _buildSidebarItems(selectedModuleIndex),
                header: SizedBox(
                  height: headerBarHeight,
                  child: !_isSidebarExpanded
                      ? Center(child: brandMark)
                      : expandedHeaderRow,
                ),
                floatingExpandedHeader: SizedBox(
                  height: headerBarHeight,
                  child: expandedHeaderRow,
                ),
              ),
            ),
            content: DynamicHeaderTabs(
              tabs: _openTabs,
              selectedIndex: _selectedTabWorkspaceIndex,
              isLoading: _isModuleLoading,
              onTabSelected: (idx) {
                _resetKeyboardAndFocusOnTabChange();
                _triggerModuleLoading();
                setState(() => _selectedTabWorkspaceIndex = idx);
              },
              onTabClosed: _handleTabClosed,
              onSearchTriggered: _showGlobalSearch,
              isSidebarExpanded: _isSidebarExpanded,
              onToggleSidebar: () =>
                  setState(() => _isSidebarExpanded = !_isSidebarExpanded),
              onNewTabPressed: _addNewTab,
              trailing: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const shad.DensityGap(shad.gapMd),
                    // 1. Search (Alt+K)
                    DynamicHeaderActionButton(
                      key: _searchBtnKey,
                      icon: shad.LucideIcons.search,
                      keyCap: 'K',
                      onPressed: () => _handleHeaderShortcut('K'),
                    ),
                    const shad.DensityGap(shad.gapMd),
                    // 2. Notifications (Alt+N)
                    ValueListenableBuilder<int>(
                      valueListenable:
                          AuthService().pendingApprovalsCountNotifier,
                      builder: (context, pendingCount, _) {
                        return DynamicHeaderActionButton(
                          key: _notifBtnKey,
                          icon: shad.LucideIcons.bell,
                          keyCap: 'N',
                          badgeCount: pendingCount,
                          onPressed: () => _handleHeaderShortcut('N'),
                        );
                      },
                    ),
                    const shad.DensityGap(shad.gapMd),
                    // 3. Tasks (Alt+T)
                    DynamicHeaderActionButton(
                      key: _tasksBtnKey,
                      icon: shad.LucideIcons.listTodo,
                      keyCap: 'T',
                      badgeCount: 3,
                      onPressed: () => _handleHeaderShortcut('T'),
                    ),
                    const shad.DensityGap(shad.gapMd),
                    // 4. Theme Toggle (Alt+D)
                    ValueListenableBuilder<shad.ThemeMode>(
                      valueListenable: themeModeNotifier,
                      builder: (context, mode, _) {
                        final isDark = mode == shad.ThemeMode.dark;
                        return DynamicHeaderActionButton(
                          icon: isDark
                              ? shad.LucideIcons.moon
                              : shad.LucideIcons.sun,
                          keyCap: 'D',
                          onPressed: () => _handleHeaderShortcut('D'),
                        );
                      },
                    ),
                    const shad.DensityGap(shad.gapSm),
                    SizedBox(
                      height: 20.0 * theme.scaling,
                      child: shad.VerticalDivider(
                        color: colors.border,
                        thickness: 1.0,
                        width: 1.0,
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    // 5. User Avatar Profile (Alt+U)
                    ValueListenableBuilder<AppProfileModel?>(
                      valueListenable: AuthService().activeProfileNotifier,
                      builder: (context, profile, _) {
                        final displayName =
                            (profile?.fullName.isNotEmpty ?? false)
                                ? profile!.fullName
                                : (profile?.username.isNotEmpty ?? false)
                                    ? profile!.username
                                    : (AuthService().currentUser?.email ??
                                        'Admin');
                        return DynamicHeaderActionButton(
                          key: _userBtnKey,
                          icon: shad.LucideIcons.user,
                          keyCap: 'U',
                          customPadding: EdgeInsets.all(4.0 * theme.scaling),
                          customChild: shad.Avatar(
                            initials: shad.Avatar.getInitials(displayName),
                            theme: shad.AvatarTheme(
                              size: 28.0 * theme.scaling,
                              borderRadius: theme.radiusMd,
                              backgroundColor:
                                  colors.primary.withValues(alpha: 0.14),
                              textStyle: theme.typography.xSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          onPressed: () => _handleHeaderShortcut('U'),
                        );
                      },
                    ),
                    SizedBox(
                      width: ((theme.density.baseGap *
                                  theme.scaling *
                                  shad.gapMd) -
                              theme.radiusMd)
                          .clamp(0.0, double.infinity),
                    ),
                  ],
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
          );
        },
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
    final scaling = theme.scaling;
    final isDark = colors.brightness == Brightness.dark;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final padUnit = theme.density.baseContainerPadding * scaling;
    final accent = DyColorSystem.cyan500;
    final iconSize = theme.iconTheme.xLarge.size ?? 32.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: padUnit * 32),
        child: shad.OutlinedContainer(
          backgroundColor: colors.card,
          borderColor: colors.border,
          borderWidth: 1.0,
          borderRadius: theme.borderRadiusMd,
          padding: EdgeInsets.all(padUnit * shad.padXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              shad.OutlinedContainer(
                width: padUnit * 4,
                height: padUnit * 4,
                theme: shad.OutlinedContainerTheme(
                  backgroundColor: DyColorSystem.resolveSurface(accent, isDark),
                  borderColor: DyColorSystem.resolveBorder(accent, isDark),
                  borderWidth: 1.0,
                  borderRadius: theme.borderRadiusMd,
                  padding: EdgeInsets.zero,
                ),
                child: Center(
                  child: Icon(
                    shad.LucideIcons.sparkles,
                    size: iconSize,
                    color: accent,
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              shad.SecondaryBadge(child: Text(title)),
              const shad.DensityGap(shad.gapMd),
              Text(
                'Magical things are brewing',
                textAlign: TextAlign.center,
                style: theme.typography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              const shad.DensityGap(shad.gapSm),
              Text(
                isAndroid
                    ? 'We are crafting this workspace module for Dhaaga. Use the navigation rail or top menu to jump to active production and sales modules.'
                    : 'We are crafting this workspace module for Dhaaga. Use the navigation rail or press Alt + K to jump to active production and sales modules.',
                textAlign: TextAlign.center,
                style: theme.typography.textSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
