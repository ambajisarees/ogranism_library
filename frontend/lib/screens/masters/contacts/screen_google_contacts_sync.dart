/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Overhauled Stage 9.3 Desktop Workspace (`ScreenGoogleContactsSync`) for
     `design.ambaji@gmail.com` <-> `"IMMBE2627"."sb_contacts"` backed by
     `DyLinearLandingCanvas` (Base-12 Bento Snapshot, Region `1..5` Zoom,
     `[N]` Add Flow, Continuous 5-Minute Delta Sync Tick, and Two-Way Push).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly composes 4 header actions (`<= 4` `PageHeader` contract):
       1) OAuth Status pill (`design.ambaji@gmail.com`)
       2) `Delta Sync [S]`
       3) `Push (pending) [P]`
       4) `New Contact [N]`
   - Binds `Shift + Letter` actions via `DyLinearLandingCanvas.onPageActionKey`:
       - `S` -> Live Delta Pull
       - `P` -> Push Pending (`PENDING_PUSH` / `LOCAL_ONLY`) Queue
       - `I` -> Import Google CSV Modal
       - `E` -> Toggle Inline Two-Way Edit on selected contact
       - `L` -> Open M:N ERP Party / Group Linker Modal
       - `N` -> Open Full-Canvas `[N]` Create & Push Contact Flow
   - Periodic 5-minute continuous delta sync tick silently pulls incremental
     changes via `syncToken` when `isContinuousSyncEnabled && isConnected`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Always checks `if (!mounted) return;` after awaits.
   - `TickerMode.valuesOf(context).enabled` gates the 5-minute background tick so
     hidden tabs never fire redundant network pulls when paused.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Auto-matching engine (`fn_automatch_contacts`) and Caller ID enrichment
     rules are intentionally deferred per user direction.
================================================================================
*/

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../models/masters/model_google_contacts.dart';
import '../../../services/masters/service_google_contacts.dart';
import 'widgets/scr_contacts_add_flow.dart';
import 'widgets/scr_contacts_bento_cards.dart';
import 'widgets/scr_contacts_group_empire.dart';
import 'widgets/scr_contacts_inspector.dart';
import 'widgets/scr_contacts_modals.dart';

/// Stage 9.3 Linear Base-12 Bento Workspace for Google Contacts & ERP 360° Links.
class ScreenGoogleContactsSync extends StatefulWidget {
  const ScreenGoogleContactsSync({super.key});

  @override
  State<ScreenGoogleContactsSync> createState() =>
      _ScreenGoogleContactsSyncState();
}

class _ScreenGoogleContactsSyncState extends State<ScreenGoogleContactsSync> {
  static const int _pageSize = 100;

  final GlobalKey<DyLinearLandingCanvasState> _canvasKey =
      GlobalKey<DyLinearLandingCanvasState>();
  final ServiceGoogleContacts _service = ServiceGoogleContacts();
  final TextEditingController _searchCtrl = TextEditingController();
  final ContactsAddFlowController _addFlowCtrl = ContactsAddFlowController();

  Timer? _searchDebounce;
  Timer? _continuousSyncTimer;

  GoogleSyncStateModel _syncState = const GoogleSyncStateModel();
  ContactsKpiCounts _kpiCounts = const ContactsKpiCounts();
  List<GoogleContact> _contacts = const [];
  GoogleContact? _selectedContact;
  ContactGroupEmpireRollup _selectedRollup = const ContactGroupEmpireRollup();

  ContactsFilterMode _filterMode = ContactsFilterMode.all;
  String _selectedLabel = 'ALL';
  int _currentPage = 0;
  int _totalMatching = 0;

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isBackgroundSyncing = false;
  bool _isLoadingRollup = false;
  bool _isEditingSelected = false;
  bool _isSavingAdd = false;
  String? _addFlowError;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _refreshAll(resetPage: true);
    _continuousSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _runBackgroundDeltaTick(),
    );
  }

  @override
  void dispose() {
    _continuousSyncTimer?.cancel();
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _addFlowCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshAll({bool resetPage = false}) async {
    if (resetPage) _currentPage = 0;
    if (mounted) {
      setState(() {
        if (_contacts.isEmpty) {
          _isLoading = true;
        } else {
          _isRefreshing = true;
        }
        _loadError = null;
      });
    }

    final offset = _currentPage * _pageSize;
    final stateFuture = _service.getSyncState();
    final kpiFuture = _service.fetchContactKpiCounts();
    final pageFuture = _service.fetchContactsPage(
      accountEmail: ServiceGoogleContacts.defaultGoogleEmail,
      searchQuery: _searchCtrl.text,
      filterMode: _filterMode,
      groupLabel: _selectedLabel,
      offset: offset,
      limit: _pageSize,
    );

    final state = await stateFuture;
    final kpis = await kpiFuture;
    final page = await pageFuture;
    if (!mounted) return;

    GoogleContact? nextSelected;
    if (page.items.isNotEmpty) {
      final currentId = _selectedContact?.id;
      nextSelected = currentId != null
          ? page.items.cast<GoogleContact?>().firstWhere(
                (c) => c?.id == currentId,
                orElse: () => page.items.first,
              )
          : page.items.first;
    }

    setState(() {
      _syncState = state;
      _kpiCounts = kpis;
      _contacts = page.items;
      _totalMatching = page.totalCount;
      _selectedContact = nextSelected;
      _loadError = page.error;
      _isLoading = false;
      _isRefreshing = false;
    });

    await _loadRollupForContact(nextSelected);
  }

  Future<void> _loadRollupForContact(GoogleContact? contact) async {
    if (contact == null || !contact.isLinked) {
      if (!mounted) return;
      setState(() {
        _selectedRollup = const ContactGroupEmpireRollup();
        _isLoadingRollup = false;
      });
      return;
    }
    if (mounted) setState(() => _isLoadingRollup = true);
    final rollup = await _service.fetchSisterPartiesForContact(contact);
    if (!mounted) return;
    if (_selectedContact?.id != contact.id) return;
    setState(() {
      _selectedRollup = rollup;
      _isLoadingRollup = false;
    });
  }

  Future<void> _runBackgroundDeltaTick() async {
    if (!mounted ||
        _isBackgroundSyncing ||
        !_syncState.isContinuousSyncEnabled ||
        !_syncState.isConnected ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    _isBackgroundSyncing = true;
    try {
      final res = await _service.pullFromGoogleWithProgress(
        email: _syncState.email,
        forceFullSync: false,
        onProgress: (_, __) {},
      );
      if (mounted && (res.count > 0 || res.deletedCount > 0)) {
        await _refreshAll(resetPage: false);
      } else if (mounted) {
        final refreshedState = await _service.getSyncState();
        if (mounted) setState(() => _syncState = refreshedState);
      }
    } finally {
      _isBackgroundSyncing = false;
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 260), () {
      _refreshAll(resetPage: true);
    });
  }

  void _selectContact(GoogleContact contact) {
    if (_selectedContact?.id == contact.id) return;
    setState(() {
      _selectedContact = contact;
      _isEditingSelected = false;
    });
    _loadRollupForContact(contact);
  }

  Future<void> _toggleStar(GoogleContact contact) async {
    final ok = await _service.toggleStarContact(contact);
    if (ok && mounted) {
      await _refreshAll(resetPage: false);
    }
  }

  Future<void> _toggleContinuousSync(bool enabled) async {
    final ok = await _service.toggleContinuousSync(
      enabled: enabled,
      email: _syncState.email,
    );
    if (ok && mounted) {
      final state = await _service.getSyncState();
      if (mounted) setState(() => _syncState = state);
    }
  }

  Future<void> _openOAuthModal() async {
    final changed = await showContactsOAuthModal(
      context: context,
      syncState: _syncState,
      service: _service,
    );
    if (changed && mounted) {
      await _refreshAll(resetPage: false);
      if (mounted && _syncState.isConnected) {
        await _openGooglePullModal(forceFullSync: false);
      }
    }
  }

  Future<void> _openCsvImportModal() async {
    final imported = await showContactsCsvImportModal(
      context: context,
      accountEmail: _syncState.email,
      service: _service,
    );
    if (imported && mounted) {
      await _refreshAll(resetPage: true);
    }
  }

  Future<void> _openGooglePullModal({required bool forceFullSync}) async {
    if (!_syncState.isConnected) {
      await _openOAuthModal();
      return;
    }
    await showContactsSyncProgressModal(
      context: context,
      accountEmail: _syncState.email,
      forceFullSync: forceFullSync,
      isPushMode: false,
      service: _service,
    );
    if (mounted) await _refreshAll(resetPage: false);
  }

  Future<void> _openGooglePushModal() async {
    if (!_syncState.isConnected) {
      await _openOAuthModal();
      return;
    }
    await showContactsSyncProgressModal(
      context: context,
      accountEmail: _syncState.email,
      forceFullSync: false,
      isPushMode: true,
      service: _service,
    );
    if (mounted) await _refreshAll(resetPage: false);
  }

  Future<void> _openLinkModalForSelected() async {
    final contact = _selectedContact;
    if (contact == null) return;
    final link = await showContactsErpLinkPickerModal(
      context: context,
      contactName: contact.displayName,
      service: _service,
    );
    if (link == null || !mounted) return;
    final ok = await _service.addErpLink(contact: contact, link: link);
    if (ok && mounted) {
      await _refreshAll(resetPage: false);
    }
  }

  void _openAddContactFlow() {
    _addFlowCtrl.reset();
    setState(() => _addFlowError = null);
    _canvasKey.currentState?.openAddFlow();
  }

  Future<void> _submitNewContact({required bool pushImmediately}) async {
    if (_isSavingAdd) return;
    if (!_addFlowCtrl.hasMinimumIdentity) {
      setState(() {
        _addFlowError =
            'Enter at least a Name, Company, or Phone Number before saving.';
      });
      return;
    }
    setState(() {
      _isSavingAdd = true;
      _addFlowError = null;
    });
    final draft = _addFlowCtrl.buildDraftContact(accountEmail: _syncState.email);
    final res = await _service.createContactAndPush(
      draft: draft,
      pushImmediately: pushImmediately,
    );
    if (!mounted) return;
    setState(() => _isSavingAdd = false);
    if (res.isSuccess) {
      _addFlowCtrl.reset();
      _canvasKey.currentState?.exitToSnapshot();
      await _refreshAll(resetPage: true);
    } else {
      setState(() => _addFlowError = res.detail ?? res.message);
    }
  }

  bool _handlePageActionKey(String keyChar) {
    switch (keyChar) {
      case 'S':
        _openGooglePullModal(forceFullSync: false);
        return true;
      case 'P':
        _openGooglePushModal();
        return true;
      case 'I':
        _openCsvImportModal();
        return true;
      case 'E':
        if (_selectedContact != null) {
          setState(() => _isEditingSelected = !_isEditingSelected);
          return true;
        }
        return false;
      case 'L':
        if (_selectedContact != null) {
          _openLinkModalForSelected();
          return true;
        }
        return false;
      case 'N':
        _openAddContactFlow();
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final statusAccent = _syncState.isConnected
        ? DyColorSystem.emerald500
        : DyColorSystem.orange500;

    return DyLinearLandingCanvas(
      key: _canvasKey,
      title: 'Google Contacts & Party 360° Hub',
      moduleName: 'Contact',
      isLoading: _isLoading || _isRefreshing,
      isSavingAdd: _isSavingAdd,
      onPageActionKey: _handlePageActionKey,
      onSaveDraftAdd: () => _submitNewContact(pushImmediately: false),
      onConfirmAdd: () => _submitNewContact(pushImmediately: true),
      actions: [
        shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: _openOAuthModal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _syncState.isConnected
                    ? shad.LucideIcons.circleCheck
                    : shad.LucideIcons.triangleAlert,
                size: 13 * theme.scaling,
                color: statusAccent,
              ),
              const shad.DensityGap(shad.gapXs),
              Text(
                _syncState.isConnected
                    ? '${_syncState.totalGoogleContacts} Synced'
                    : 'Connect OAuth',
                style: theme.typography.xSmall.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: () => _openGooglePullModal(forceFullSync: false),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ContactsShiftKeyCap(letter: 'S'),
              Icon(shad.LucideIcons.arrowDownLeft, size: 13),
              shad.DensityGap(shad.gapXs),
              Text('Sync Delta'),
            ],
          ),
        ),
        shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: _openGooglePushModal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ContactsShiftKeyCap(letter: 'P'),
              const Icon(shad.LucideIcons.upload, size: 13),
              const shad.DensityGap(shad.gapXs),
              Text('Push (${_kpiCounts.pendingPushCount})'),
            ],
          ),
        ),
        shad.PrimaryButton(
          size: shad.ButtonSize.small,
          onPressed: _openAddContactFlow,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ContactsShiftKeyCap(letter: 'N', inverted: true),
              Icon(shad.LucideIcons.userPlus, size: 13),
              shad.DensityGap(shad.gapXs),
              Text('New Contact'),
            ],
          ),
        ),
      ],
      snapshotRows: [
        _buildRegion1KpiStrip(isZoomed: false),
        DyFlexRow(
          desktopRowHeight: 500,
          cells: [
            DyFlexCell(
              flex: 8,
              compactHeight: 460,
              child: _buildRegion2Directory(isZoomed: false),
            ),
            DyFlexCell(
              flex: 4,
              compactHeight: 390,
              child: _buildRegion3SyncConsole(isZoomed: false),
            ),
          ],
        ),
        DyFlexRow(
          desktopRowHeight: 560,
          cells: [
            DyFlexCell(
              flex: 8,
              compactHeight: 500,
              child: _buildRegion4Inspector(isZoomed: false),
            ),
            DyFlexCell(
              flex: 4,
              compactHeight: 400,
              child: _buildRegion5GroupEmpire(isZoomed: false),
            ),
          ],
        ),
      ],
      zoomTargets: [
        DyLinearZoomTarget(
          regionNumber: 1,
          label: 'Contacts & Sync Telemetry',
          builder: (_) => _buildRegion1KpiStrip(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 2,
          label: 'Google Contacts Directory',
          builder: (_) => _buildRegion2Directory(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 3,
          label: 'Two-Way Sync & Google Labels',
          builder: (_) => _buildRegion3SyncConsole(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 4,
          label: 'Person 360° Inspector & Editor',
          builder: (_) => _buildRegion4Inspector(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 5,
          label: 'Owned Group & Sister Firms',
          builder: (_) => _buildRegion5GroupEmpire(isZoomed: true),
        ),
      ],
      addFlowBuilder: (onBack) => ContactsAddFlowPanel(
        controller: _addFlowCtrl,
        service: _service,
        errorBanner: _addFlowError,
        onCancel: onBack,
      ),
    );
  }

  Widget _buildRegion1KpiStrip({required bool isZoomed}) =>
      ContactsKpiMetricsStrip(
        kpiCounts: _kpiCounts,
        syncState: _syncState,
        activeFilter: _filterMode,
        isZoomed: isZoomed,
        onZoomToggle: () => _canvasKey.currentState?.toggleRegion(1),
        onSelectFilter: (mode) {
          setState(() => _filterMode = mode);
          _refreshAll(resetPage: true);
        },
      );

  Widget _buildRegion2Directory({required bool isZoomed}) =>
      ContactsDirectoryBentoCard(
        searchController: _searchCtrl,
        onSearchChanged: _onSearchChanged,
        filterMode: _filterMode,
        onFilterChanged: (mode) {
          setState(() => _filterMode = mode);
          _refreshAll(resetPage: true);
        },
        selectedLabel: _selectedLabel,
        onLabelChanged: (val) {
          setState(() => _selectedLabel = val);
          _refreshAll(resetPage: true);
        },
        contactGroupsMap: _syncState.contactGroupsMap,
        contacts: _contacts,
        selectedContact: _selectedContact,
        onSelectContact: _selectContact,
        onToggleStar: _toggleStar,
        currentPage: _currentPage,
        pageSize: _pageSize,
        totalMatching: _totalMatching,
        isLoading: _isLoading,
        isRefreshing: _isRefreshing,
        loadError: _loadError,
        onRefresh: () => _refreshAll(resetPage: false),
        onPrevPage: () {
          setState(() => _currentPage--);
          _refreshAll(resetPage: false);
        },
        onNextPage: () {
          setState(() => _currentPage++);
          _refreshAll(resetPage: false);
        },
        onOpenCsvImport: _openCsvImportModal,
        onOpenOAuth: _openOAuthModal,
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(2),
      );

  Widget _buildRegion3SyncConsole({required bool isZoomed}) =>
      ContactsSyncAndLabelsBentoCard(
        syncState: _syncState,
        pendingPushCount: _kpiCounts.pendingPushCount,
        selectedLabel: _selectedLabel,
        onSelectLabel: (lbl) {
          setState(() => _selectedLabel = lbl);
          _refreshAll(resetPage: true);
        },
        onToggleContinuousSync: _toggleContinuousSync,
        onDeltaPull: () => _openGooglePullModal(forceFullSync: false),
        onFullPull: () => _openGooglePullModal(forceFullSync: true),
        onPushPending: _openGooglePushModal,
        onImportCsv: _openCsvImportModal,
        onOpenOAuth: _openOAuthModal,
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(3),
      );

  Widget _buildRegion4Inspector({required bool isZoomed}) =>
      ContactDetailInspectorBentoCard(
        contact: _selectedContact,
        contactGroupsMap: _syncState.contactGroupsMap,
        service: _service,
        isEditing: _isEditingSelected,
        onEditingChanged: (val) => setState(() => _isEditingSelected = val),
        onContactUpdated: () => _refreshAll(resetPage: false),
        onRequestLinkErp: _openLinkModalForSelected,
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(4),
      );

  Widget _buildRegion5GroupEmpire({required bool isZoomed}) =>
      ContactOwnedGroupEmpireBentoCard(
        contact: _selectedContact,
        rollup: _selectedRollup,
        isLoading: _isLoadingRollup,
        onLinkErp: _openLinkModalForSelected,
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(5),
      );
}
