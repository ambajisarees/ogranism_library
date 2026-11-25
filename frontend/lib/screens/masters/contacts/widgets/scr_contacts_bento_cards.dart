/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Stage 9.3 Contacts Linear Workspace Bento Card widgets built on top of
     `DyLinearLandingCanvas`, `DyFlexRow`, `DyKpiMetricCard`, and `DyBentoCard`:
       1) `ContactsShiftKeyCap`: Reactive `Shift` KeyCap pill (`[S]`, `[P]`,
          `[I]`, `[E]`, `[L]`, `[N]`) shown on action controls in Shift mode.
       2) `ContactsKpiMetricsStrip` (Region [1]): Base-12 3+3+3+3 KPI tiles
          with click-to-filter (`All`, `Linked`, `Unlinked`, `Push Queue`).
       3) `ContactsDirectoryBentoCard` (Region [2], Flex 8): Search bar,
          filter pills, Google Label selector, virtualized dense directory list,
          and server pagination controls.
       4) `ContactsSyncAndLabelsBentoCard` (Region [3], Flex 4): OAuth health,
          Continuous 5-Min Auto-Sync toggle, quick sync/push triggers, and
          clickable Google Contact Labels breakdown.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` controls, `theme.density.*`,
     `theme.typography.*`, `colors.*`, and `DyColorSystem` semantic colors.
   - All badge & keycap chips are wrapped in `Focus(canRequestFocus: false,
     skipTraversal: true, descendantsAreFocusable: false)` per Rule 8.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - ListView inside `ContactsDirectoryBentoCard` receives bounded height via
     `DyBentoCard(expandBody: true)` inside `DyFlexRow(desktopRowHeight: ...)`
     or inside zoomed full-canvas view.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Auto-match batch engine (`fn_automatch_contacts`) will plug into Region [3]
     after Stage 9.3 two-way sync validation.
================================================================================
*/

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/masters/model_google_contacts.dart';
import '../../../../services/masters/service_google_contacts.dart';
import '../../../../services/service_keyboard_shortcuts.dart';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

/// Reactive KeyCap pill displayed beside button labels when `Shift` mode is active.
class ContactsShiftKeyCap extends StatelessWidget {
  final String letter;
  final bool inverted;

  const ContactsShiftKeyCap({
    super.key,
    required this.letter,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (_isAndroid) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: ServiceKeyboardShortcuts.instance.isTabHeldNotifier,
      builder: (context, active, _) {
        if (!active) return const SizedBox.shrink();
        final theme = shad.Theme.of(context);
        final colors = theme.colorScheme;
        final extent = 16 * theme.scaling;

        return Focus(
          canRequestFocus: false,
          skipTraversal: true,
          descendantsAreFocusable: false,
          child: Padding(
            padding: EdgeInsets.only(right: 5 * theme.scaling),
            child: shad.OutlinedContainer(
              width: extent,
              height: extent,
              theme: shad.OutlinedContainerTheme(
                backgroundColor:
                    inverted ? colors.primaryForeground : colors.primary,
                borderColor:
                    inverted ? colors.primaryForeground : colors.primary,
                borderWidth: 1.0,
                borderRadius: BorderRadius.circular(theme.radiusSm),
                padding: EdgeInsets.zero,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: theme.typography.xSmall
                      .merge(theme.typography.mono)
                      .copyWith(
                        fontSize: 9.5 * theme.scaling,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        color:
                            inverted ? colors.primary : colors.primaryForeground,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Region [1]: Base-12 `3+3+3+3` Executive KPI Strip with click-to-filter.
class ContactsKpiMetricsStrip extends StatelessWidget {
  final ContactsKpiCounts kpiCounts;
  final GoogleSyncStateModel syncState;
  final ContactsFilterMode activeFilter;
  final ValueChanged<ContactsFilterMode> onSelectFilter;
  final VoidCallback? onZoomToggle;
  final bool isZoomed;

  const ContactsKpiMetricsStrip({
    super.key,
    required this.kpiCounts,
    required this.syncState,
    required this.activeFilter,
    required this.onSelectFilter,
    this.onZoomToggle,
    this.isZoomed = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = kpiCounts.totalActive > 0
        ? kpiCounts.totalActive
        : syncState.totalGoogleContacts;
    final linkedPct = total > 0 ? (kpiCounts.linkedCount / total) : 0.0;
    final hasQueue = kpiCounts.pendingPushCount > 0;

    final row = DyFlexRow(
      isKpiRow: true,
      cells: [
        DyFlexCell(
          flex: 3,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DyKpiMetricCard(
                title: 'Google Contacts',
                value: '$total',
                subtitle: '${kpiCounts.starredCount} starred in directory',
                badgeText: '${syncState.contactGroupsMap.length} Labels',
                icon: shad.LucideIcons.users,
                tone: DyKpiTone.primary,
                isSelected: activeFilter == ContactsFilterMode.all,
                onTap: () => onSelectFilter(ContactsFilterMode.all),
              ),
              if (!_isAndroid)
                ValueListenableBuilder<bool>(
                  valueListenable:
                      ServiceKeyboardShortcuts.instance.isTabHeldNotifier,
                  builder: (ctx, held, _) {
                    if (!held) return const SizedBox.shrink();
                    return Positioned(
                      top: -6,
                      left: -6,
                      child: const DyRegionBadge(number: 1),
                    );
                  },
                ),
            ],
          ),
        ),
        DyFlexCell(
          flex: 3,
          child: DyKpiMetricCard(
            title: 'ERP Linked Parties',
            value: '${kpiCounts.linkedCount}',
            subtitle: '${(linkedPct * 100).toStringAsFixed(1)}% M:N mapped',
            badgeText: 'M:N Linked',
            icon: shad.LucideIcons.link2,
            tone: DyKpiTone.success,
            progress: linkedPct,
            isSelected: activeFilter == ContactsFilterMode.linked,
            onTap: () => onSelectFilter(ContactsFilterMode.linked),
          ),
        ),
        DyFlexCell(
          flex: 3,
          child: DyKpiMetricCard(
            title: 'Unlinked Directory',
            value: '${kpiCounts.unlinkedCount}',
            subtitle: 'Pending manual ERP group/party link',
            badgeText: 'Unlinked',
            icon: shad.LucideIcons.userSearch,
            tone: DyKpiTone.warning,
            isSelected: activeFilter == ContactsFilterMode.unlinked,
            onTap: () => onSelectFilter(ContactsFilterMode.unlinked),
          ),
        ),
        DyFlexCell(
          flex: 3,
          child: DyKpiMetricCard(
            title: 'Two-Way Push Queue',
            value: '${kpiCounts.pendingPushCount}',
            subtitle: syncState.latestSyncAt != null
                ? 'Last sync ${_fmtRelative(syncState.latestSyncAt!)}'
                : 'Awaiting initial sync',
            badgeText: hasQueue ? 'Queued' : syncState.syncHealth,
            icon: shad.LucideIcons.arrowUpDown,
            tone: hasQueue ? DyKpiTone.danger : DyKpiTone.indigo,
            isSelected: activeFilter == ContactsFilterMode.pendingPush,
            onTap: () => onSelectFilter(ContactsFilterMode.pendingPush),
          ),
        ),
      ],
    );

    if (!isZoomed) return row;

    return DyBentoCard(
      title: 'Contacts & Sync KPI Telemetry',
      subtitle: 'Click any tile to filter the directory',
      icon: shad.LucideIcons.activity,
      regionNumber: 1,
      isZoomed: true,
      onToggleZoom: onZoomToggle,
      bodyPadding: EdgeInsets.all(
        shad.Theme.of(context).density.baseContainerPadding *
            shad.Theme.of(context).scaling,
      ),
      child: row,
    );
  }
}

/// Region [2] (`Flex 8`): Server-paginated Google Contacts Directory Workbench.
class ContactsDirectoryBentoCard extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ContactsFilterMode filterMode;
  final ValueChanged<ContactsFilterMode> onFilterChanged;
  final String selectedLabel;
  final ValueChanged<String> onLabelChanged;
  final Map<String, String> contactGroupsMap;
  final List<GoogleContact> contacts;
  final GoogleContact? selectedContact;
  final ValueChanged<GoogleContact> onSelectContact;
  final ValueChanged<GoogleContact> onToggleStar;
  final int currentPage;
  final int pageSize;
  final int totalMatching;
  final bool isLoading;
  final bool isRefreshing;
  final String? loadError;
  final VoidCallback onRefresh;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;
  final VoidCallback onOpenCsvImport;
  final VoidCallback onOpenOAuth;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const ContactsDirectoryBentoCard({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.filterMode,
    required this.onFilterChanged,
    required this.selectedLabel,
    required this.onLabelChanged,
    required this.contactGroupsMap,
    required this.contacts,
    required this.selectedContact,
    required this.onSelectContact,
    required this.onToggleStar,
    required this.currentPage,
    required this.pageSize,
    required this.totalMatching,
    required this.isLoading,
    required this.isRefreshing,
    required this.loadError,
    required this.onRefresh,
    required this.onPrevPage,
    required this.onNextPage,
    required this.onOpenCsvImport,
    required this.onOpenOAuth,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;

    final startIdx = totalMatching == 0 ? 0 : (currentPage * pageSize) + 1;
    final endIdx = (currentPage * pageSize) + contacts.length;
    final hasPrev = currentPage > 0;
    final hasNext = endIdx < totalMatching;

    final availableLabels = <String>{
      'ALL',
      ...contactGroupsMap.values.where((l) => l.isNotEmpty && l != 'myContacts'),
    }.toList();

    return DyBentoCard(
      title: 'Google Contacts Directory',
      subtitle: '$totalMatching matching • 100-row paginated mirror',
      icon: shad.LucideIcons.bookUser,
      regionNumber: 2,
      isZoomed: isZoomed,
      onToggleZoom: onToggleZoom,
      expandBody: true,
      headerTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRefreshing) ...[
            SizedBox(
              width: 14 * theme.scaling,
              height: 14 * theme.scaling,
              child: const shad.CircularProgressIndicator(strokeWidth: 2),
            ),
            const shad.DensityGap(shad.gapSm),
          ],
          shad.IconButton.ghost(
            size: shad.ButtonSize.small,
            density: shad.ButtonDensity.iconDense,
            icon: Icon(shad.LucideIcons.refreshCw, size: 14 * theme.scaling),
            onPressed: onRefresh,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(pad * 0.85),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: shad.TextField(
                        controller: searchController,
                        placeholder: const Text(
                          'Search name, 10-digit phone, company, email or notes...',
                        ),
                        features: const [
                          shad.InputFeature.leading(
                            Padding(
                              padding: EdgeInsets.only(left: 8, right: 6),
                              child: Icon(shad.LucideIcons.search, size: 14),
                            ),
                          ),
                        ],
                        onChanged: onSearchChanged,
                      ),
                    ),
                    if (availableLabels.length > 1) ...[
                      const shad.DensityGap(shad.gapSm),
                      SizedBox(
                        width: 165 * theme.scaling,
                        child: shad.Select<String>(
                          value: availableLabels.contains(selectedLabel)
                              ? selectedLabel
                              : 'ALL',
                          onChanged: (val) {
                            if (val != null) onLabelChanged(val);
                          },
                          itemBuilder: (ctx, val) => Text(
                            val == 'ALL' ? 'All Labels' : val,
                            overflow: TextOverflow.ellipsis,
                          ),
                          popup: shad.SelectPopup(
                            items: shad.SelectItemList(
                              children: [
                                for (final lbl in availableLabels)
                                  shad.SelectItemButton(
                                    value: lbl,
                                    child: Text(
                                      lbl == 'ALL' ? 'All Google Labels' : lbl,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ).call,
                        ),
                      ),
                    ],
                  ],
                ),
                const shad.DensityGap(shad.gapSm),
                Wrap(
                  spacing: 6 * theme.scaling,
                  runSpacing: 6 * theme.scaling,
                  children: [
                    _filterPill('All', ContactsFilterMode.all),
                    _filterPill('Unlinked', ContactsFilterMode.unlinked),
                    _filterPill('Linked', ContactsFilterMode.linked),
                    _filterPill('Push Queue', ContactsFilterMode.pendingPush),
                    _filterPill('Starred', ContactsFilterMode.starred),
                  ],
                ),
              ],
            ),
          ),
          shad.Divider(color: colors.border),
          Expanded(
            child: isLoading && contacts.isEmpty
                ? const Center(child: shad.CircularProgressIndicator())
                : loadError != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(pad * 1.5),
                          child: Text(
                            loadError!,
                            style: theme.typography.xSmall
                                .copyWith(color: colors.destructive),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : contacts.isEmpty
                        ? _buildEmptyState(theme, colors, pad)
                        : ListView.separated(
                            padding: EdgeInsets.all(pad * 0.8),
                            itemCount: contacts.length,
                            separatorBuilder: (_, __) =>
                                const shad.DensityGap(shad.gapXs),
                            itemBuilder: (ctx, idx) =>
                                _buildContactRow(contacts[idx], theme, colors),
                          ),
          ),
          shad.Divider(color: colors.border),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pad,
              vertical: pad * 0.55,
            ),
            child: Row(
              children: [
                Text(
                  'Showing $startIdx–$endIdx of $totalMatching',
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground),
                ),
                const Spacer(),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: hasPrev ? onPrevPage : null,
                  child: const Text('Prev'),
                ),
                const shad.DensityGap(shad.gapXs),
                Text(
                  'Page ${currentPage + 1}',
                  style: theme.typography.xSmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const shad.DensityGap(shad.gapXs),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: hasNext ? onNextPage : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill(String label, ContactsFilterMode mode) {
    final active = filterMode == mode;
    return active
        ? shad.PrimaryButton(
            size: shad.ButtonSize.small,
            onPressed: () => onFilterChanged(mode),
            child: Text(label),
          )
        : shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: () => onFilterChanged(mode),
            child: Text(label),
          );
  }

  Widget _buildContactRow(
    GoogleContact contact,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedContact?.id == contact.id;
    final extraPhoneCount =
        contact.phoneList.length > 1 ? contact.phoneList.length - 1 : 0;
    final isPending = contact.syncStatus == 'PENDING_PUSH' ||
        contact.syncStatus == 'LOCAL_ONLY';

    return GestureDetector(
      onTap: () => onSelectContact(contact),
      child: shad.OutlinedContainer(
        backgroundColor: isSelected ? colors.primary.withAlpha(18) : colors.card,
        borderColor: isSelected ? colors.primary : colors.border,
        borderWidth: isSelected ? 1.5 : 1.0,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        padding: EdgeInsets.symmetric(
          horizontal: pad * 0.9,
          vertical: pad * 0.65,
        ),
        child: Row(
          children: [
            shad.IconButton.ghost(
              size: shad.ButtonSize.small,
              density: shad.ButtonDensity.iconDense,
              icon: Icon(
                shad.LucideIcons.star,
                size: 14 * theme.scaling,
                color: contact.isStarred
                    ? DyColorSystem.orange500
                    : colors.mutedForeground.withAlpha(110),
              ),
              onPressed: () => onToggleStar(contact),
            ),
            const shad.DensityGap(shad.gapXs),
            shad.OutlinedContainer(
              width: 26 * theme.scaling,
              height: 26 * theme.scaling,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: colors.primary.withAlpha(22),
              borderColor: colors.primary.withAlpha(70),
              child: Center(
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName[0].toUpperCase()
                      : 'C',
                  style: theme.typography.xSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    style: theme.typography.textSmall
                        .copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((contact.companyName ?? '').isNotEmpty ||
                      (contact.primaryEmail ?? '').isNotEmpty)
                    Text(
                      contact.companyName ?? contact.primaryEmail ?? '',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      contact.primaryPhone,
                      style: theme.typography.mono
                          .copyWith(fontSize: 12 * theme.scaling),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (extraPhoneCount > 0) ...[
                    const shad.DensityGap(shad.gapXs),
                    _isolated(
                      shad.SecondaryBadge(child: Text('+$extraPhoneCount')),
                    ),
                  ],
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPending) ...[
                    _isolated(
                      shad.SecondaryBadge(
                        child: Text(
                          contact.syncStatus == 'LOCAL_ONLY'
                              ? 'Local'
                              : 'Queue',
                          style: theme.typography.xSmall.copyWith(
                            color: isDark
                                ? DyColorSystem.orange500
                                : DyColorSystem.orange600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const shad.DensityGap(shad.gapXs),
                  ],
                  Flexible(
                    child: _isolated(
                      contact.isLinked
                          ? shad.PrimaryBadge(
                              child: Text(
                                '${contact.erpLinks.length} Linked',
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : const shad.OutlineBadge(child: Text('Unlinked')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double pad,
  ) =>
      Center(
        child: Padding(
          padding: EdgeInsets.all(pad * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shad.LucideIcons.users,
                  size: 36 * theme.scaling, color: colors.mutedForeground),
              const shad.DensityGap(shad.gapSm),
              Text('No contacts match current filters',
                  style: theme.typography.textSmall),
              const shad.DensityGap(shad.gapMd),
              Wrap(
                spacing: 8 * theme.scaling,
                children: [
                  shad.OutlineButton(
                    size: shad.ButtonSize.small,
                    onPressed: onOpenCsvImport,
                    child: const Text('Import Google CSV'),
                  ),
                  shad.PrimaryButton(
                    size: shad.ButtonSize.small,
                    onPressed: onOpenOAuth,
                    child: const Text('OAuth Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Region [3] (`Flex 4`): Two-Way Continuous Sync Console & Google Labels.
class ContactsSyncAndLabelsBentoCard extends StatelessWidget {
  final GoogleSyncStateModel syncState;
  final int pendingPushCount;
  final String selectedLabel;
  final ValueChanged<String> onSelectLabel;
  final ValueChanged<bool> onToggleContinuousSync;
  final VoidCallback onDeltaPull;
  final VoidCallback onFullPull;
  final VoidCallback onPushPending;
  final VoidCallback onImportCsv;
  final VoidCallback onOpenOAuth;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const ContactsSyncAndLabelsBentoCard({
    super.key,
    required this.syncState,
    required this.pendingPushCount,
    required this.selectedLabel,
    required this.onSelectLabel,
    required this.onToggleContinuousSync,
    required this.onDeltaPull,
    required this.onFullPull,
    required this.onPushPending,
    required this.onImportCsv,
    required this.onOpenOAuth,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    final sortedLabels = syncState.contactGroupsMap.values
        .where((v) => v.isNotEmpty && v != 'myContacts')
        .toSet()
        .toList()
      ..sort();

    final healthAccent = syncState.isConnected
        ? DyColorSystem.emerald500
        : DyColorSystem.orange500;

    return DyBentoCard(
      title: 'Two-Way Sync & Labels',
      subtitle: '${sortedLabels.length} Google groups',
      icon: shad.LucideIcons.refreshCw,
      regionNumber: 3,
      isZoomed: isZoomed,
      onToggleZoom: onToggleZoom,
      expandBody: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            shad.OutlinedContainer(
              backgroundColor: DyColorSystem.resolveSurface(healthAccent, isDark),
              borderColor: DyColorSystem.resolveBorder(healthAccent, isDark),
              borderRadius: BorderRadius.circular(theme.radiusSm),
              padding: EdgeInsets.all(pad * 0.85),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        syncState.isConnected
                            ? shad.LucideIcons.check
                            : shad.LucideIcons.triangleAlert,
                        size: 14 * theme.scaling,
                        color: healthAccent,
                      ),
                      const shad.DensityGap(shad.gapXs),
                      Expanded(
                        child: Text(
                          syncState.email,
                          style: theme.typography.xSmall
                              .copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      shad.OutlineButton(
                        size: shad.ButtonSize.small,
                        onPressed: onOpenOAuth,
                        child: const Text('OAuth'),
                      ),
                    ],
                  ),
                  const shad.DensityGap(shad.gapXs),
                  Text(
                    'Last Delta: ${_fmtTimestamp(syncState.lastDeltaSyncAt)}',
                    style: theme.typography.xSmall
                        .copyWith(color: colors.mutedForeground),
                  ),
                  Text(
                    'Last Push: ${_fmtTimestamp(syncState.lastPushAt)}',
                    style: theme.typography.xSmall
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            shad.OutlinedContainer(
              backgroundColor: colors.card,
              borderColor: colors.border,
              borderRadius: BorderRadius.circular(theme.radiusSm),
              padding: EdgeInsets.symmetric(
                horizontal: pad * 0.85,
                vertical: pad * 0.65,
              ),
              child: Row(
                children: [
                  shad.Checkbox(
                    state: syncState.isContinuousSyncEnabled
                        ? shad.CheckboxState.checked
                        : shad.CheckboxState.unchecked,
                    onChanged: (state) => onToggleContinuousSync(
                      state == shad.CheckboxState.checked,
                    ),
                  ),
                  const shad.DensityGap(shad.gapSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5-Min Continuous Delta Tick',
                          style: theme.typography.xSmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          syncState.isContinuousSyncEnabled
                              ? 'Active while workspace is open'
                              : 'Paused (manual sync only)',
                          style: theme.typography.xSmall
                              .copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            Wrap(
              spacing: 6 * theme.scaling,
              runSpacing: 6 * theme.scaling,
              children: [
                shad.PrimaryButton(
                  size: shad.ButtonSize.small,
                  onPressed: onDeltaPull,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      ContactsShiftKeyCap(letter: 'S', inverted: true),
                      Icon(shad.LucideIcons.arrowDownLeft, size: 13),
                      shad.DensityGap(shad.gapXs),
                      Text('Delta Pull'),
                    ],
                  ),
                ),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: onPushPending,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ContactsShiftKeyCap(letter: 'P'),
                      const Icon(shad.LucideIcons.upload, size: 13),
                      const shad.DensityGap(shad.gapXs),
                      Text('Push ($pendingPushCount)'),
                    ],
                  ),
                ),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: onImportCsv,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      ContactsShiftKeyCap(letter: 'I'),
                      Icon(shad.LucideIcons.fileSpreadsheet, size: 13),
                      shad.DensityGap(shad.gapXs),
                      Text('Import CSV'),
                    ],
                  ),
                ),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: onFullPull,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(shad.LucideIcons.refreshCw, size: 13),
                      shad.DensityGap(shad.gapXs),
                      Text('Full Re-Sync'),
                    ],
                  ),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapLg),
            Text(
              'GOOGLE CONTACT LABELS (${sortedLabels.length})',
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.mutedForeground,
              ),
            ),
            const shad.DensityGap(shad.gapXs),
            if (sortedLabels.isEmpty)
              Text(
                'Run Sync to populate Google Contact Labels.',
                style: theme.typography.xSmall
                    .copyWith(color: colors.mutedForeground),
              )
            else
              Wrap(
                spacing: 6 * theme.scaling,
                runSpacing: 6 * theme.scaling,
                children: [
                  _labelChip('ALL', 'All Labels'),
                  for (final lbl in sortedLabels) _labelChip(lbl, lbl),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _labelChip(String value, String label) {
    final active = selectedLabel == value;
    return active
        ? shad.PrimaryButton(
            size: shad.ButtonSize.small,
            onPressed: () => onSelectLabel(value),
            child: Text(label),
          )
        : shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: () => onSelectLabel(value),
            child: Text(label),
          );
  }
}

Widget _isolated(Widget child) => Focus(
      canRequestFocus: false,
      skipTraversal: true,
      descendantsAreFocusable: false,
      child: child,
    );

String _fmtRelative(DateTime dt) {
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String _fmtTimestamp(DateTime? dt) {
  if (dt == null) return 'Never';
  final local = dt.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month} $hh:$mm (${_fmtRelative(local)})';
}
