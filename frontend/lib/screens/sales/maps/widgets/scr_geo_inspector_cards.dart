/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Region [4] (`GeoLocationInspectorBentoCard`) and Region [5]
     (`GeoVillagePartiesBentoCard`) for `ScrGeoZoneMap` (`Sales -> Maps`).
   - Displays complete village/pincode administrative hierarchy (Taluka,
     District, Division, State, GST Code), Surat E-Way Bill distance, Zone
     assignment, sister `B.O` rural villages under the same pincode, inline
     logistics editor (`[E]`), and live `sq_MASTER` + `sq_HASTE` customers.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` widgets, `theme.density.*`,
     `theme.typography.*`, `colors.*`, and `DyColorSystem`.
   - Wraps all badges in `Focus(canRequestFocus: false, skipTraversal: true,
     descendantsAreFocusable: false)` per `GEMINI.md` Rule 8.
   - Always checks `if (!mounted) return;` after awaits.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Allows editing `sb_geo_locations` logistics (`nearest_station`,
     `default_transport`, `distance_from_surat_km`, `pincode`, `zone_code`),
     while leaving `sq_MASTER` and `sq_HASTE` strictly read-only.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Stage 11.2 will also display live GSTN Verified addresses for each pinned
     party directly inside Region [5].
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/sales/model_geo_locations.dart';
import '../../../../services/sales/service_geo_locations.dart';
import 'scr_geo_search_and_kpi.dart';

/// Region [4] (`Flex 8`): Selected Village / Pincode 360° Inspector & Logistics Editor.
class GeoLocationInspectorBentoCard extends StatefulWidget {
  final GeoLocationModel? location;
  final List<GeoZoneModel> zones;
  final List<GeoLocationModel> siblingPincodeLocations;
  final ServiceGeoLocations service;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;
  final VoidCallback onLocationUpdated;
  final ValueChanged<GeoLocationModel> onSelectSiblingLocation;
  final ValueChanged<String> onFetchIndiaPostPincode;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const GeoLocationInspectorBentoCard({
    super.key,
    required this.location,
    required this.zones,
    required this.siblingPincodeLocations,
    required this.service,
    required this.isEditing,
    required this.onEditingChanged,
    required this.onLocationUpdated,
    required this.onSelectSiblingLocation,
    required this.onFetchIndiaPostPincode,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  State<GeoLocationInspectorBentoCard> createState() =>
      _GeoLocationInspectorBentoCardState();
}

class _GeoLocationInspectorBentoCardState
    extends State<GeoLocationInspectorBentoCard> {
  final TextEditingController _pinCtrl = TextEditingController();
  final TextEditingController _talukaCtrl = TextEditingController();
  final TextEditingController _districtCtrl = TextEditingController();
  final TextEditingController _stationCtrl = TextEditingController();
  final TextEditingController _transportCtrl = TextEditingController();
  final TextEditingController _distanceCtrl = TextEditingController();

  String _editZoneCode = 'MH-MARATHWADA-CORE';
  bool _isSaving = false;
  GeoFetchResult? _feedback;

  @override
  void initState() {
    super.initState();
    _syncForm(widget.location);
  }

  @override
  void didUpdateWidget(covariant GeoLocationInspectorBentoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location?.id != widget.location?.id) {
      _feedback = null;
      _syncForm(widget.location);
      if (widget.isEditing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onEditingChanged(false);
        });
      }
    } else if (!oldWidget.isEditing && widget.isEditing) {
      _feedback = null;
      _syncForm(widget.location);
    }
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _talukaCtrl.dispose();
    _districtCtrl.dispose();
    _stationCtrl.dispose();
    _transportCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  void _syncForm(GeoLocationModel? loc) {
    if (loc == null) return;
    _pinCtrl.text = loc.pincode ?? '';
    _talukaCtrl.text = loc.taluka ?? '';
    _districtCtrl.text = loc.district ?? '';
    _stationCtrl.text = loc.nearestStation ?? '';
    _transportCtrl.text = loc.defaultTransport ?? '';
    _distanceCtrl.text =
        loc.distanceFromSuratKm != null ? '${loc.distanceFromSuratKm}' : '';
    _editZoneCode = loc.zoneCode ?? 'MH-MARATHWADA-CORE';
  }

  Future<void> _saveEdits() async {
    final loc = widget.location;
    if (loc == null || _isSaving) return;
    setState(() {
      _isSaving = true;
      _feedback = null;
    });
    final res = await widget.service.upsertCustomLocation(
      existingId: loc.id,
      placeName: loc.placeName,
      pincode: _pinCtrl.text.trim(),
      officeType: loc.officeType,
      taluka: _talukaCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      stateName: loc.stateName,
      zoneCode: _editZoneCode,
      nearestStation: _stationCtrl.text.trim(),
      defaultTransport: _transportCtrl.text.trim(),
      distanceKm: int.tryParse(_distanceCtrl.text.trim()),
      lat: loc.latitude,
      lng: loc.longitude,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _feedback = res;
    });
    if (res.isSuccess) {
      widget.onEditingChanged(false);
      widget.onLocationUpdated();
    }
  }

  Future<void> _reassignZone(String nextZoneCode) async {
    final loc = widget.location;
    if (loc == null) return;
    final match = widget.zones.where((z) => z.zoneCode == nextZoneCode);
    if (match.isEmpty) return;
    final ok = await widget.service.assignLocationToZone(
      locationId: loc.id,
      zone: match.first,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _feedback = GeoFetchResult(
          isSuccess: true,
          count: 1,
          message: 'Assigned "${loc.placeName}" to Zone ${match.first.zoneCode}.',
        );
      });
      widget.onLocationUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final loc = widget.location;

    return DyBentoCard(
      title: 'Village & Pincode Telemetry Inspector',
      subtitle: loc != null
          ? '${loc.placeName} (${loc.pincode ?? 'No PIN'}) • ${loc.stateName}'
          : 'Select a village pin or search result above',
      icon: shad.LucideIcons.mapPin,
      regionNumber: 4,
      isZoomed: widget.isZoomed,
      onToggleZoom: widget.onToggleZoom,
      expandBody: true,
      headerTrailing: loc == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isEditing)
                  shad.OutlineButton(
                    size: shad.ButtonSize.small,
                    onPressed: () => widget.onEditingChanged(false),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        GeoShiftKeyCap(letter: 'E'),
                        Icon(shad.LucideIcons.x, size: 12),
                        shad.DensityGap(shad.gapXs),
                        Text('Cancel'),
                      ],
                    ),
                  )
                else
                  shad.PrimaryButton(
                    size: shad.ButtonSize.small,
                    onPressed: () {
                      _syncForm(loc);
                      widget.onEditingChanged(true);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        GeoShiftKeyCap(letter: 'E', inverted: true),
                        Icon(shad.LucideIcons.pencil, size: 12),
                        shad.DensityGap(shad.gapXs),
                        Text('Edit Logistics'),
                      ],
                    ),
                  ),
              ],
            ),
      child: loc == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(pad * 2),
                child: Text(
                  'Click any village marker on the map or pick a village/pincode from Region [3].',
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(pad * 1.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_feedback != null) ...[
                    _banner(_feedback!, theme, pad),
                    const shad.DensityGap(shad.gapMd),
                  ],
                  if (widget.isEditing)
                    _buildEditForm(theme, colors, pad)
                  else
                    _buildViewMode(loc, theme, colors, pad),
                ],
              ),
            ),
    );
  }

  Widget _buildViewMode(
    GeoLocationModel loc,
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double pad,
  ) {
    final zoneCodes = [for (final z in widget.zones) z.zoneCode];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shad.OutlinedContainer(
          backgroundColor: colors.card,
          borderColor: colors.border,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.placeName, style: theme.typography.h4),
                        Text(
                          '${loc.stateName} (GST State Code: ${loc.gstStateCode})',
                          style: theme.typography.xSmall
                              .copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  _isolated(shad.PrimaryBadge(child: Text(loc.officeTypeLabel))),
                  const shad.DensityGap(shad.gapXs),
                  if (loc.pincode != null && loc.pincode!.isNotEmpty)
                    _isolated(shad.SecondaryBadge(child: Text(loc.pincode!))),
                ],
              ),
              const shad.DensityGap(shad.gapMd),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Taluka / Block', loc.taluka ?? '—', theme, colors),
                        _kv('District', loc.district ?? '—', theme, colors),
                        _kv(
                          'Surat Distance',
                          loc.distanceFromSuratKm != null
                              ? '${loc.distanceFromSuratKm} km (E-Way)'
                              : '—',
                          theme,
                          colors,
                          mono: true,
                        ),
                      ],
                    ),
                  ),
                  const shad.DensityGap(shad.gapMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Nearest Hub', loc.nearestStation ?? '—', theme, colors),
                        _kv('Default Carrier', loc.defaultTransport ?? '—', theme, colors),
                        _kv(
                          'GPS Centroid',
                          loc.hasCoordinates
                              ? '${loc.latitude!.toStringAsFixed(4)}, ${loc.longitude!.toStringAsFixed(4)}'
                              : 'Pending',
                          theme,
                          colors,
                          mono: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (zoneCodes.isNotEmpty) ...[
                const shad.DensityGap(shad.gapMd),
                Row(
                  children: [
                    Text(
                      'Assigned Sales Zone:',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    SizedBox(
                      width: 240 * theme.scaling,
                      child: shad.Select<String>(
                        value: zoneCodes.contains(loc.zoneCode)
                            ? loc.zoneCode
                            : null,
                        placeholder: const Text('Assign Sales Zone'),
                        onChanged: (val) {
                          if (val != null) _reassignZone(val);
                        },
                        itemBuilder: (ctx, val) => Text(val),
                        popup: shad.SelectPopup(
                          items: shad.SelectItemList(
                            children: [
                              for (final code in zoneCodes)
                                shad.SelectItemButton(
                                    value: code, child: Text(code)),
                            ],
                          ),
                        ).call,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const shad.DensityGap(shad.gapMd),
        Row(
          children: [
            Expanded(
              child: Text(
                'SISTER VILLAGES & BRANCH POs UNDER PINCODE ${loc.pincode ?? '—'} (${widget.siblingPincodeLocations.length})',
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.mutedForeground,
                ),
              ),
            ),
            if (loc.pincode != null && loc.pincode!.length == 6)
              shad.OutlineButton(
                size: shad.ButtonSize.small,
                onPressed: () => widget.onFetchIndiaPostPincode(loc.pincode!),
                child: const Text('Fetch Live India Post BOs'),
              ),
          ],
        ),
        const shad.DensityGap(shad.gapXs),
        if (widget.siblingPincodeLocations.isEmpty)
          Text(
            loc.pincode != null
                ? 'Click "Fetch Live India Post BOs" to hydrate every rural village under pincode ${loc.pincode}.'
                : 'Assign a 6-digit pincode to discover sister rural post offices.',
            style:
                theme.typography.xSmall.copyWith(color: colors.mutedForeground),
          )
        else
          Wrap(
            spacing: 6 * theme.scaling,
            runSpacing: 6 * theme.scaling,
            children: [
              for (final sib in widget.siblingPincodeLocations)
                sib.id == loc.id
                    ? shad.PrimaryButton(
                        size: shad.ButtonSize.small,
                        onPressed: () => widget.onSelectSiblingLocation(sib),
                        child: Text('${sib.placeName} (${sib.officeType})'),
                      )
                    : shad.OutlineButton(
                        size: shad.ButtonSize.small,
                        onPressed: () => widget.onSelectSiblingLocation(sib),
                        child: Text('${sib.placeName} (${sib.officeType})'),
                      ),
            ],
          ),
      ],
    );
  }

  Widget _buildEditForm(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double pad,
  ) {
    final zoneCodes = [for (final z in widget.zones) z.zoneCode];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _field(theme, colors, '6-Digit Pincode', _pinCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field(theme, colors, 'Taluka / Tehsil', _talukaCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field(theme, colors, 'District', _districtCtrl)),
          ],
        ),
        const shad.DensityGap(shad.gapSm),
        Row(
          children: [
            Expanded(
                child: _field(theme, colors, 'Nearest Rail/Hub Station', _stationCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(
                child: _field(theme, colors, 'Default Transport', _transportCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(
                child: _field(theme, colors, 'Surat Distance (km)', _distanceCtrl)),
          ],
        ),
        if (zoneCodes.isNotEmpty) ...[
          const shad.DensityGap(shad.gapSm),
          Text('Sales Zone',
              style: theme.typography.xSmall
                  .copyWith(color: colors.mutedForeground)),
          const shad.DensityGap(shad.gapXs),
          shad.Select<String>(
            value: zoneCodes.contains(_editZoneCode)
                ? _editZoneCode
                : zoneCodes.first,
            onChanged: (v) {
              if (v != null) setState(() => _editZoneCode = v);
            },
            itemBuilder: (ctx, v) => Text(v),
            popup: shad.SelectPopup(
              items: shad.SelectItemList(
                children: [
                  for (final zc in zoneCodes)
                    shad.SelectItemButton(value: zc, child: Text(zc)),
                ],
              ),
            ).call,
          ),
        ],
        const shad.DensityGap(shad.gapLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            shad.GhostButton(
              onPressed: _isSaving ? null : () => widget.onEditingChanged(false),
              child: const Text('Cancel'),
            ),
            const shad.DensityGap(shad.gapSm),
            shad.PrimaryButton(
              onPressed: _isSaving ? null : _saveEdits,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(shad.LucideIcons.save, size: 14),
                  const shad.DensityGap(shad.gapXs),
                  Text(_isSaving ? 'Saving...' : 'Save Geo Telemetry'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String label,
    TextEditingController ctrl,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.typography.xSmall
                  .copyWith(color: colors.mutedForeground)),
          const shad.DensityGap(shad.gapXs),
          shad.TextField(controller: ctrl),
        ],
      );

  Widget _kv(
    String label,
    String value,
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    bool mono = false,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 2 * theme.scaling),
        child: Row(
          children: [
            SizedBox(
              width: 105 * theme.scaling,
              child: Text(label,
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground)),
            ),
            Expanded(
              child: Text(
                value,
                style: (mono ? theme.typography.mono : theme.typography.xSmall)
                    .copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _banner(GeoFetchResult res, shad.ThemeData theme, double pad) {
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        res.isSuccess ? DyColorSystem.emerald500 : DyColorSystem.orange500;
    return shad.OutlinedContainer(
      backgroundColor: DyColorSystem.resolveSurface(accent, isDark),
      borderColor: DyColorSystem.resolveBorder(accent, isDark),
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: EdgeInsets.all(pad * 0.75),
      child: Text(res.message, style: theme.typography.xSmall),
    );
  }
}

/// Region [5] (`Flex 4`): Legacy Parties, Textile Prospect Leads & Verified `sb_parties`.
class GeoVillagePartiesBentoCard extends StatefulWidget {
  final GeoLocationModel? location;
  final List<GeoVillagePartyEntry> parties;
  final List<GeoProspectLeadModel> prospects;
  final List<SbVerifiedPartyModel> verifiedParties;
  final bool isLoading;
  final bool isSweepingProspects;
  final ValueChanged<GeoVillagePartyEntry> onVerifyLegacyParty;
  final ValueChanged<GeoProspectLeadModel> onConvertProspect;
  final VoidCallback onSweepTownProspects;
  final VoidCallback onOpenBlankGstinLookup;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const GeoVillagePartiesBentoCard({
    super.key,
    required this.location,
    required this.parties,
    required this.prospects,
    required this.verifiedParties,
    required this.isLoading,
    this.isSweepingProspects = false,
    required this.onVerifyLegacyParty,
    required this.onConvertProspect,
    required this.onSweepTownProspects,
    required this.onOpenBlankGstinLookup,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  State<GeoVillagePartiesBentoCard> createState() =>
      _GeoVillagePartiesBentoCardState();
}

class _GeoVillagePartiesBentoCardState
    extends State<GeoVillagePartiesBentoCard> {
  int _tabIdx = 0;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final typography = theme.typography;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final loc = widget.location;

    final masterCnt =
        widget.parties.where((p) => p.entityKind == 'MASTER').length;
    final hasteCnt =
        widget.parties.where((p) => p.entityKind == 'HASTE').length;

    return DyBentoCard(
      title: 'Parties, Expansion Leads & Verified',
      subtitle:
          '$masterCnt M • $hasteCnt H • ${widget.prospects.length} Leads • ${widget.verifiedParties.length} sb_parties',
      icon: shad.LucideIcons.users,
      regionNumber: 5,
      isZoomed: widget.isZoomed,
      onToggleZoom: widget.onToggleZoom,
      expandBody: true,
      headerTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          shad.OutlineButton(
            size: shad.ButtonSize.xSmall,
            onPressed: (loc == null || widget.isSweepingProspects)
                ? null
                : widget.onSweepTownProspects,
            child: Text(widget.isSweepingProspects ? 'Sweeping...' : 'Sweep Town'),
          ),
          const shad.DensityGap(shad.gapXs),
          shad.OutlineButton(
            size: shad.ButtonSize.xSmall,
            onPressed: widget.onOpenBlankGstinLookup,
            child: const Text('GST'),
          ),
        ],
      ),
      child: widget.isLoading
          ? const Center(child: shad.CircularProgressIndicator())
          : loc == null
              ? _emptyState(
                  'Select a town or village to inspect legacy buyers, unconverted Haste leads, and verified sb_parties.',
                  pad,
                  typography,
                  colors,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          pad * 0.85, pad * 0.6, pad * 0.85, 0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _tabBtn(0, 'Legacy (${widget.parties.length})'),
                            const shad.DensityGap(shad.gapXs),
                            _tabBtn(1, 'Leads (${widget.prospects.length})'),
                            const shad.DensityGap(shad.gapXs),
                            _tabBtn(2,
                                'sb_parties (${widget.verifiedParties.length})'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildActiveList(loc, pad, theme, colors),
                    ),
                  ],
                ),
    );
  }

  Widget _tabBtn(int idx, String label) {
    if (_tabIdx == idx) {
      return shad.PrimaryButton(
        size: shad.ButtonSize.xSmall,
        onPressed: () => setState(() => _tabIdx = idx),
        child: Text(label),
      );
    }
    return shad.OutlineButton(
      size: shad.ButtonSize.xSmall,
      onPressed: () => setState(() => _tabIdx = idx),
      child: Text(label),
    );
  }

  Widget _emptyState(
    String msg,
    double pad,
    shad.Typography typography,
    shad.ColorScheme colors,
  ) =>
      Center(
        child: Padding(
          padding: EdgeInsets.all(pad * 1.5),
          child: Text(
            msg,
            style: typography.xSmall.copyWith(color: colors.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _buildActiveList(
    GeoLocationModel loc,
    double pad,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    if (_tabIdx == 1) {
      if (widget.prospects.isEmpty) {
        return _emptyState(
          'No mined Leads in "${loc.placeName}". Click Sweep Town above to scan unconverted Haste buyers.',
          pad,
          theme.typography,
          colors,
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(pad * 0.85),
        itemCount: widget.prospects.length,
        separatorBuilder: (_, __) => const shad.DensityGap(shad.gapXs),
        itemBuilder: (_, i) =>
            _prospectTile(widget.prospects[i], pad, theme, colors),
      );
    }

    if (_tabIdx == 2) {
      if (widget.verifiedParties.isEmpty) {
        return _emptyState(
          'No human-verified parties in "${loc.placeName}" yet. Click Verify on Legacy or Convert on a Lead.',
          pad,
          theme.typography,
          colors,
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(pad * 0.85),
        itemCount: widget.verifiedParties.length,
        separatorBuilder: (_, __) => const shad.DensityGap(shad.gapXs),
        itemBuilder: (_, i) =>
            _verifiedTile(widget.verifiedParties[i], pad, theme, colors),
      );
    }

    if (widget.parties.isEmpty) {
      return _emptyState(
        'No sq_MASTER or sq_HASTE accounts linked directly to "${loc.placeName}" yet.',
        pad,
        theme.typography,
        colors,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(pad * 0.85),
      itemCount: widget.parties.length,
      separatorBuilder: (_, __) => const shad.DensityGap(shad.gapXs),
      itemBuilder: (_, i) =>
          _legacyTile(widget.parties[i], pad, theme, colors),
    );
  }

  Widget _legacyTile(
    GeoVillagePartyEntry p, double pad, shad.ThemeData theme, shad.ColorScheme colors,
  ) =>
      shad.OutlinedContainer(
        backgroundColor: colors.card, borderColor: colors.border,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        padding: EdgeInsets.all(pad * 0.72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _isolated(p.entityKind == 'HASTE'
                    ? const shad.SecondaryBadge(child: Text('HASTE'))
                    : const shad.PrimaryBadge(child: Text('MASTER'))),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: Text(p.name,
                      style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                ),
                shad.OutlineButton(
                  size: shad.ButtonSize.xSmall,
                  onPressed: () => widget.onVerifyLegacyParty(p),
                  child: const Text('Verify'),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapXs),
            Text(
              'Adatiya: ${p.adatiya}${p.transport.isNotEmpty ? ' • ${p.transport}' : ''}',
              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
            if (p.gstin.isNotEmpty || p.mobile.isNotEmpty)
              Text(
                [if (p.gstin.isNotEmpty) 'GST: ${p.gstin}', if (p.mobile.isNotEmpty) p.mobile].join(' • '),
                style: theme.typography.mono.copyWith(fontSize: 10.5 * theme.scaling, color: colors.mutedForeground),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );

  Widget _prospectTile(
    GeoProspectLeadModel lead, double pad, shad.ThemeData theme, shad.ColorScheme colors,
  ) {
    final adatiya = lead.adatiyaName ?? '', transport = lead.preferredTransport ?? '';
    final gst = lead.gstin ?? '', mob = lead.mobile ?? '';
    return shad.OutlinedContainer(
      backgroundColor: colors.card, borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: EdgeInsets.all(pad * 0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _isolated(shad.OutlineBadge(child: Text('P${lead.priorityScore}'))),
              const shad.DensityGap(shad.gapXs),
              _isolated(lead.isConverted
                  ? const shad.PrimaryBadge(child: Text('CONVERTED'))
                  : const shad.SecondaryBadge(child: Text('UNCONVERTED'))),
              const shad.DensityGap(shad.gapSm),
              Expanded(
                child: Text(lead.shopName,
                    style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
              ),
              if (!lead.isConverted)
                shad.PrimaryButton(
                  size: shad.ButtonSize.xSmall,
                  onPressed: () => widget.onConvertProspect(lead),
                  child: const Text('Convert'),
                ),
            ],
          ),
          const shad.DensityGap(shad.gapXs),
          if (adatiya.isNotEmpty || transport.isNotEmpty)
            Text(
              [if (adatiya.isNotEmpty) 'Via: $adatiya', if (transport.isNotEmpty) transport].join(' • '),
              style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
          if (gst.isNotEmpty || mob.isNotEmpty)
            Text(
              [if (gst.isNotEmpty) 'GST: $gst', if (mob.isNotEmpty) mob].join(' • '),
              style: theme.typography.mono.copyWith(fontSize: 10.5 * theme.scaling, color: colors.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _verifiedTile(
    SbVerifiedPartyModel vp, double pad, shad.ThemeData theme, shad.ColorScheme colors,
  ) {
    final gst = vp.gstin ?? '', pan = vp.panNumber ?? '', adatiya = vp.adatiyaName ?? '';
    return shad.OutlinedContainer(
      backgroundColor: colors.card, borderColor: colors.primary.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: EdgeInsets.all(pad * 0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _isolated(shad.PrimaryBadge(child: Text(vp.partyRole))),
              const shad.DensityGap(shad.gapXs),
              _isolated(shad.SecondaryBadge(child: Text(vp.partyCode))),
              const shad.DensityGap(shad.gapSm),
              Expanded(
                child: Text(vp.tradeName,
                    style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapXs),
          Text(
            '${vp.cityName ?? ''} • ${vp.zoneCode ?? ''}${adatiya.isNotEmpty ? ' • $adatiya' : ''}',
            style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
            overflow: TextOverflow.ellipsis,
          ),
          if (gst.isNotEmpty || pan.isNotEmpty)
            Text(
              [if (gst.isNotEmpty) 'GST: $gst', if (pan.isNotEmpty) 'PAN: $pan', '${vp.creditDays}d Cr'].join(' • '),
              style: theme.typography.mono.copyWith(fontSize: 10.5 * theme.scaling, color: colors.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
        ],
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
