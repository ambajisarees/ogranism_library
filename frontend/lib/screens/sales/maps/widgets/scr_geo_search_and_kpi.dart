/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Region [1] (`GeoTerritoryKpiStrip`) and Region [3] (`GeoVillageSearchBentoCard`)
     plus reactive `GeoShiftKeyCap` badges for `ScrGeoZoneMap` (`Sales -> Maps`).
   - Provides instant server-side search across Pincodes, Villages, Talukas,
     Districts & Legacy `sq_CITIES` aliases, plus live India Post directory
     fetching (`api.postalpincode.in`) to hydrate rural `B.O` villages into Supabase.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` widgets, `theme.density.*`,
     `theme.typography.*`, `colors.*`, and `DyColorSystem`.
   - Wraps all badge & KeyCap chips inside `Focus(canRequestFocus: false,
     skipTraversal: true, descendantsAreFocusable: false)` per Rule 8.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Region [3] displays demo quick-lookup chips (`413512 Latur`, `431515 Parali`,
     `413305 Mangalweda`, `395002 Surat`) to let team test India Post rural `B.O`
     hydration in 1 click.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Full 165k India Post OGD bulk CSV importer can be triggered from Region [3]
     once user chooses offline vs on-demand pincode seeding.
================================================================================
*/

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/sales/model_geo_locations.dart';
import '../../../../services/service_keyboard_shortcuts.dart';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

/// Reactive KeyCap pill displayed beside Geo action labels in `Shift` mode.
class GeoShiftKeyCap extends StatelessWidget {
  final String letter;
  final bool inverted;

  const GeoShiftKeyCap({
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

/// Region [1]: Base-12 `3+3+3+3` Geo & Territory KPI Strip.
class GeoTerritoryKpiStrip extends StatelessWidget {
  final GeoTerritoryKpiCounts counts;
  final GeoFilterMode activeFilter;
  final ValueChanged<GeoFilterMode> onSelectFilter;
  final bool isZoomed;
  final VoidCallback? onZoomToggle;

  const GeoTerritoryKpiStrip({
    super.key,
    required this.counts,
    required this.activeFilter,
    required this.onSelectFilter,
    this.isZoomed = false,
    this.onZoomToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final pad = theme.density.baseContainerPadding * theme.scaling;

    final row = DyFlexRow(
      isKpiRow: true,
      cells: [
        DyFlexCell(
          flex: 3,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DyKpiMetricCard(
                title: 'Geo Places Cached',
                value: '${counts.totalLocations}',
                subtitle: 'Towns, pincodes & rural villages',
                badgeText: 'All India',
                icon: shad.LucideIcons.mapPin,
                tone: DyKpiTone.primary,
                isSelected: activeFilter == GeoFilterMode.all,
                onTap: () => onSelectFilter(GeoFilterMode.all),
              ),
              if (!_isAndroid)
                ValueListenableBuilder<bool>(
                  valueListenable:
                      ServiceKeyboardShortcuts.instance.isTabHeldNotifier,
                  builder: (ctx, held, _) {
                    if (!held) return const SizedBox.shrink();
                    return const Positioned(
                      top: -6,
                      left: -6,
                      child: DyRegionBadge(number: 1),
                    );
                  },
                ),
            ],
          ),
        ),
        DyFlexCell(
          flex: 3,
          child: DyKpiMetricCard(
            title: 'Active ERP Markets',
            value: '${counts.erpMarketsCount}',
            subtitle: 'Cities & towns with sq_MASTER parties',
            badgeText: 'Verified',
            icon: shad.LucideIcons.users,
            tone: DyKpiTone.success,
            isSelected: activeFilter == GeoFilterMode.erpMarkets,
            onTap: () => onSelectFilter(GeoFilterMode.erpMarkets),
          ),
        ),
        DyFlexCell(
          flex: 3,
          child: DyKpiMetricCard(
            title: 'Haste Rural Markets',
            value: '${counts.hasteLocationsCount}',
            subtitle: 'Sub-buyer places from sq_HASTE',
            badgeText: 'Consignee Hubs',
            icon: shad.LucideIcons.truck,
            tone: DyKpiTone.indigo,
            isSelected: activeFilter == GeoFilterMode.hasteTowns,
            onTap: () => onSelectFilter(GeoFilterMode.hasteTowns),
          ),
        ),
        DyFlexCell(
          flex: 3,
          child: DyKpiMetricCard(
            title: 'Sales Zones & Village BOs',
            value: '${counts.activeZonesCount} / ${counts.branchOfficesCount}',
            subtitle: '${counts.activeZonesCount} zones • ${counts.branchOfficesCount} India Post B.O',
            badgeText: 'Branch POs',
            icon: shad.LucideIcons.layers,
            tone: DyKpiTone.warning,
            isSelected: activeFilter == GeoFilterMode.branchOffices,
            onTap: () => onSelectFilter(GeoFilterMode.branchOffices),
          ),
        ),
      ],
    );

    if (!isZoomed) return row;

    return DyBentoCard(
      title: 'Geo & Sales Zone Telemetry',
      subtitle: 'Click any tile to filter Region [3] & Map Pins',
      icon: shad.LucideIcons.activity,
      regionNumber: 1,
      isZoomed: true,
      onToggleZoom: onZoomToggle,
      bodyPadding: EdgeInsets.all(pad),
      child: row,
    );
  }
}

/// Region [3] (`Flex 4`): Village & 6-Digit Pincode Search + India Post Live Hydrator.
class GeoVillageSearchBentoCard extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final GeoFilterMode filterMode;
  final ValueChanged<GeoFilterMode> onFilterChanged;
  final List<GeoLocationModel> locations;
  final GeoLocationModel? selectedLocation;
  final ValueChanged<GeoLocationModel> onSelectLocation;
  final VoidCallback onFetchIndiaPost;
  final ValueChanged<String> onQuickFetchDemoPin;
  final bool isLoading;
  final bool isFetchingIndiaPost;
  final GeoFetchResult? fetchBanner;
  final int currentPage;
  final int totalCount;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const GeoVillageSearchBentoCard({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.filterMode,
    required this.onFilterChanged,
    required this.locations,
    required this.selectedLocation,
    required this.onSelectLocation,
    required this.onFetchIndiaPost,
    required this.onQuickFetchDemoPin,
    required this.isLoading,
    required this.isFetchingIndiaPost,
    this.fetchBanner,
    required this.currentPage,
    required this.totalCount,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrevPage,
    required this.onNextPage,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    return DyBentoCard(
      title: 'Village & Pincode Directory',
      subtitle: '$totalCount matching places',
      icon: shad.LucideIcons.search,
      regionNumber: 3,
      isZoomed: isZoomed,
      onToggleZoom: onToggleZoom,
      expandBody: true,
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
                          'Village, 6-digit PIN, taluka, district...',
                        ),
                        onChanged: onSearchChanged,
                        features: const [
                          shad.InputFeature.leading(
                            Padding(
                              padding: EdgeInsets.only(left: 8, right: 4),
                              child: Icon(shad.LucideIcons.search, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const shad.DensityGap(shad.gapXs),
                    shad.PrimaryButton(
                      size: shad.ButtonSize.small,
                      onPressed:
                          isFetchingIndiaPost ? null : onFetchIndiaPost,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GeoShiftKeyCap(letter: 'F', inverted: true),
                          Icon(
                            shad.LucideIcons.download,
                            size: 13 * theme.scaling,
                          ),
                          const shad.DensityGap(shad.gapXs),
                          Text(
                            isFetchingIndiaPost ? '...' : 'India Post',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapXs),
                Wrap(
                  spacing: 5 * theme.scaling,
                  runSpacing: 5 * theme.scaling,
                  children: [
                    _filterChip('All', GeoFilterMode.all),
                    _filterChip('ERP Markets', GeoFilterMode.erpMarkets),
                    _filterChip('Haste', GeoFilterMode.hasteTowns),
                    _filterChip('Village B.O', GeoFilterMode.branchOffices),
                  ],
                ),
                const shad.DensityGap(shad.gapXs),
                Wrap(
                  spacing: 4 * theme.scaling,
                  runSpacing: 4 * theme.scaling,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Try India Post:',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                    ),
                    for (final pin in const ['413512', '431515', '413305', '395002'])
                      shad.OutlineButton(
                        size: shad.ButtonSize.small,
                        onPressed: () => onQuickFetchDemoPin(pin),
                        child: Text(pin),
                      ),
                  ],
                ),
                if (fetchBanner != null) ...[
                  const shad.DensityGap(shad.gapXs),
                  shad.OutlinedContainer(
                    backgroundColor: DyColorSystem.resolveSurface(
                      fetchBanner!.isSuccess
                          ? DyColorSystem.emerald500
                          : DyColorSystem.orange500,
                      isDark,
                    ),
                    borderColor: DyColorSystem.resolveBorder(
                      fetchBanner!.isSuccess
                          ? DyColorSystem.emerald500
                          : DyColorSystem.orange500,
                      isDark,
                    ),
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                    padding: EdgeInsets.all(pad * 0.6),
                    child: Text(
                      fetchBanner!.message,
                      style: theme.typography.xSmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
          shad.Divider(color: colors.border),
          Expanded(
            child: isLoading && locations.isEmpty
                ? const Center(child: shad.CircularProgressIndicator())
                : locations.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(pad),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'No cached match locally.',
                                style: theme.typography.xSmall
                                    .copyWith(color: colors.mutedForeground),
                              ),
                              const shad.DensityGap(shad.gapSm),
                              shad.PrimaryButton(
                                size: shad.ButtonSize.small,
                                onPressed: isFetchingIndiaPost
                                    ? null
                                    : onFetchIndiaPost,
                                child: const Text('Query Live India Post API'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(pad * 0.75),
                        itemCount: locations.length,
                        separatorBuilder: (_, __) =>
                            const shad.DensityGap(shad.gapXs),
                        itemBuilder: (ctx, idx) =>
                            _buildLocationRow(locations[idx], theme, colors, pad),
                      ),
          ),
          shad.Divider(color: colors.border),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pad * 0.85,
              vertical: pad * 0.45,
            ),
            child: Row(
              children: [
                Text(
                  'Page ${currentPage + 1}',
                  style: theme.typography.xSmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: hasPrev ? onPrevPage : null,
                  child: const Text('Prev'),
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

  Widget _filterChip(String label, GeoFilterMode mode) =>
      filterMode == mode
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

  Widget _buildLocationRow(
    GeoLocationModel loc,
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double pad,
  ) {
    final isSel = selectedLocation?.id == loc.id;
    return GestureDetector(
      onTap: () => onSelectLocation(loc),
      child: shad.OutlinedContainer(
        backgroundColor: isSel ? colors.primary.withAlpha(18) : colors.card,
        borderColor: isSel ? colors.primary : colors.border,
        borderWidth: isSel ? 1.5 : 1.0,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        padding: EdgeInsets.symmetric(
          horizontal: pad * 0.8,
          vertical: pad * 0.55,
        ),
        child: Row(
          children: [
            _isolated(
              loc.officeType == 'BO'
                  ? shad.SecondaryBadge(child: Text(loc.officeType))
                  : shad.OutlineBadge(child: Text(loc.officeType)),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.placeName,
                    style: theme.typography.textSmall
                        .copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    loc.subtitleLocation.isNotEmpty
                        ? loc.subtitleLocation
                        : (loc.zoneCode ?? ''),
                    style: theme.typography.xSmall
                        .copyWith(color: colors.mutedForeground),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (loc.totalErpParties > 0) ...[
              const shad.DensityGap(shad.gapXs),
              _isolated(
                shad.PrimaryBadge(
                  child: Text('${loc.masterPartyCount}M/${loc.hastePartyCount}H'),
                ),
              ),
            ] else if (loc.distanceFromSuratKm != null) ...[
              const shad.DensityGap(shad.gapXs),
              Text(
                '${loc.distanceFromSuratKm} km',
                style: theme.typography.mono.copyWith(
                  fontSize: 11 * theme.scaling,
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _isolated(Widget child) => Focus(
      canRequestFocus: false,
      skipTraversal: true,
      descendantsAreFocusable: false,
      child: child,
    );
