/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Main Stage 11.1 Workspace Screen (`ScrGeoZoneMap`) mounted under `Sales -> Maps`.
   - Renders the interactive All-India Territory & Sales Zone GIS canvas
     (`DyGeoTerritoryMapCanvas`), live India Post rural village (`B.O`)
     hydrator, village/pincode directory, village 360° telemetry inspector,
     and live `sq_MASTER` + `sq_HASTE` village party overlay inside
     `DyLinearLandingCanvas` (Regions `1..5` + `[N]` Add Custom Market Flow).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly composes 4 header actions (`<= 4` `PageHeader` contract):
       1) `GST Lookup [G]` -> Staged GSTIN Verification & `sb_parties` Onboarder
       2) `Reset Map [R]`
       3) `India Post Fetch [F]`
       4) `+ Add Village [N]`
   - Binds `Shift + 1..5` zoom and `Shift + Letter` actions (`G`, `F`, `E`, `R`, `N`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Always checks `if (!mounted) return;` after async DB/HTTP operations.
   - Leaves `sq_CITIES`, `sq_MASTER`, and `sq_HASTE` strictly read-only.
   - Commits confirmed accounts into `sb_parties` and `sb_gstin_cache` while
     marking converted `sb_prospect_leads` rows cleanly.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Full polygon Zone editor & DataMeet Pincode GeoJSON boundaries can plug
     directly into `DyGeoTerritoryMapCanvas` without changing table contracts.
================================================================================
*/

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../models/sales/model_geo_locations.dart';
import '../../../services/sales/service_geo_locations.dart';
import '../../../services/sales/service_gstin_and_prospects.dart';
import 'widgets/scr_geo_gstin_verify_dialog.dart';
import 'widgets/scr_geo_inspector_cards.dart';
import 'widgets/scr_geo_map_canvas.dart';
import 'widgets/scr_geo_search_and_kpi.dart';

/// Stage 11.1 + 11.2 `Sales -> Maps` Territory GIS, Prospects & GSTIN Console.
class ScrGeoZoneMap extends StatefulWidget {
  const ScrGeoZoneMap({super.key});

  @override
  State<ScrGeoZoneMap> createState() => _ScrGeoZoneMapState();
}

class _ScrGeoZoneMapState extends State<ScrGeoZoneMap> {
  static const int _pageSize = 60;

  final GlobalKey<DyLinearLandingCanvasState> _canvasKey =
      GlobalKey<DyLinearLandingCanvasState>();
  final GlobalKey<DyGeoTerritoryMapCanvasState> _mapKey =
      GlobalKey<DyGeoTerritoryMapCanvasState>();
  final ServiceGeoLocations _service = ServiceGeoLocations();
  final ServiceGstinAndProspects _gstService = ServiceGstinAndProspects();
  final TextEditingController _searchCtrl = TextEditingController();

  // Add-Flow form controllers
  final TextEditingController _addNameCtrl = TextEditingController();
  final TextEditingController _addPinCtrl = TextEditingController();
  final TextEditingController _addTalukaCtrl = TextEditingController();
  final TextEditingController _addDistrictCtrl = TextEditingController();
  final TextEditingController _addStateCtrl =
      TextEditingController(text: 'MAHARASHTRA');
  final TextEditingController _addStationCtrl = TextEditingController();
  final TextEditingController _addTransportCtrl = TextEditingController();
  String _addZoneCode = 'MH-MARATHWADA-CORE';
  String _addOfficeType = 'BO';
  String? _addError;
  bool _isSavingAdd = false;

  Timer? _searchDebounce;

  GeoTerritoryKpiCounts _kpiCounts = const GeoTerritoryKpiCounts();
  List<GeoZoneModel> _zones = const [];
  List<GeoLocationModel> _mapPins = const [];
  List<GeoLocationModel> _directoryRows = const [];
  List<GeoLocationModel> _siblingPinRows = const [];
  List<GeoVillagePartyEntry> _selectedParties = const [];
  List<GeoProspectLeadModel> _selectedProspects = const [];
  List<SbVerifiedPartyModel> _selectedVerifiedParties = const [];

  GeoLocationModel? _selectedLocation;
  GeoFilterMode _filterMode = GeoFilterMode.all;
  String _selectedZoneCode = 'ALL';
  int _currentPage = 0;
  int _totalMatching = 0;

  bool _isLoading = true;
  bool _isLoadingParties = false;
  bool _isSweepingProspects = false;
  bool _isFetchingIndiaPost = false;
  bool _isEditingSelected = false;
  bool _showZonesLayer = true;
  bool _showSpokesLayer = true;
  bool _showLabelsLayer = true;
  GeoFetchResult? _fetchBanner;

  @override
  void initState() {
    super.initState();
    _loadAll(resetPage: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _addNameCtrl.dispose();
    _addPinCtrl.dispose();
    _addTalukaCtrl.dispose();
    _addDistrictCtrl.dispose();
    _addStateCtrl.dispose();
    _addStationCtrl.dispose();
    _addTransportCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll({bool resetPage = false}) async {
    if (resetPage) _currentPage = 0;
    if (mounted) setState(() => _isLoading = true);

    final kpiFut = _service.fetchKpiCounts();
    final zonesFut = _service.fetchZones();
    final pinsFut = _service.fetchMapPins(
      zoneCode: _selectedZoneCode,
      activeMarketsOnly: _filterMode == GeoFilterMode.erpMarkets,
      limit: 950,
    );
    final dirFut = _service.searchLocationsPage(
      searchQuery: _searchCtrl.text,
      zoneCode: _selectedZoneCode,
      filterMode: _filterMode,
      offset: _currentPage * _pageSize,
      limit: _pageSize,
    );

    final kpis = await kpiFut;
    final zones = await zonesFut;
    final pins = await pinsFut;
    final dir = await dirFut;
    if (!mounted) return;

    GeoLocationModel? nextSelected;
    if (_selectedLocation != null) {
      final keepId = _selectedLocation!.id;
      for (final r in dir.items) {
        if (r.id == keepId) {
          nextSelected = r;
          break;
        }
      }
      nextSelected ??= dir.items.isNotEmpty
          ? dir.items.first
          : (pins.isNotEmpty ? pins.first : null);
    } else if (dir.items.isNotEmpty) {
      nextSelected = dir.items.first;
    }

    setState(() {
      _kpiCounts = kpis;
      _zones = zones;
      _mapPins = pins;
      _directoryRows = dir.items;
      _totalMatching = dir.totalCount;
      _selectedLocation = nextSelected;
      _isLoading = false;
    });

    await _loadDetailsForSelection(nextSelected);
  }

  Future<void> _loadDetailsForSelection(GeoLocationModel? loc) async {
    if (loc == null) {
      if (!mounted) return;
      setState(() {
        _siblingPinRows = const [];
        _selectedParties = const [];
        _selectedProspects = const [];
        _selectedVerifiedParties = const [];
        _isLoadingParties = false;
      });
      return;
    }

    if (mounted) setState(() => _isLoadingParties = true);
    final locPin = loc.pincode;
    final sibFut = (locPin != null && locPin.length == 6)
        ? _service.fetchLocationsByPincode(locPin)
        : Future.value(const <GeoLocationModel>[]);
    final partiesFut = _service.fetchPartiesForLocation(loc);
    final prospectsFut = _gstService.fetchProspectsForLocation(loc);
    final verifiedFut = _gstService.fetchVerifiedPartiesForLocation(loc);

    final siblings = await sibFut;
    final parties = await partiesFut;
    final prospects = await prospectsFut;
    final verified = await verifiedFut;
    if (!mounted) return;
    if (_selectedLocation?.id != loc.id) return;

    setState(() {
      _siblingPinRows = siblings;
      _selectedParties = parties;
      _selectedProspects = prospects;
      _selectedVerifiedParties = verified;
      _isLoadingParties = false;
    });
  }

  Future<void> _sweepSelectedTownProspects() async {
    final loc = _selectedLocation;
    if (loc == null || _isSweepingProspects) return;
    setState(() => _isSweepingProspects = true);
    final res = await _gstService.sweepTownProspects(loc);
    if (!mounted) return;
    setState(() {
      _isSweepingProspects = false;
      _fetchBanner = res;
    });
    await _loadDetailsForSelection(loc);
  }

  void _openGstinVerifyDialog({
    GeoVillagePartyEntry? legacyParty,
    GeoProspectLeadModel? prospect,
  }) {
    shad.showOverlay<void>(
      context,
      const shad.DialogConfiguration(
        alignment: Alignment.center,
      ),
      builder: (dialogContext) => GeoGstinVerifyAndOnboardDialog(
        seedLegacyParty: legacyParty,
        seedProspect: prospect,
        activeLocation: _selectedLocation,
        zones: _zones,
        onSaved: () => _loadDetailsForSelection(_selectedLocation),
        onClose: () => shad.closeOverlay(dialogContext),
      ),
    );
  }

  void _selectLocation(GeoLocationModel loc, {bool flyMap = true}) {
    setState(() {
      _selectedLocation = loc;
      _isEditingSelected = false;
    });
    if (flyMap && loc.hasCoordinates) {
      _mapKey.currentState?.flyToLocation(loc);
    }
    _loadDetailsForSelection(loc);
  }

  Future<void> _runIndiaPostFetch([String? explicitQuery]) async {
    final query = (explicitQuery ?? _searchCtrl.text).trim();
    if (_isFetchingIndiaPost) return;
    if (query.length < 3) {
      setState(() {
        _fetchBanner = const GeoFetchResult(
          isSuccess: false,
          count: 0,
          message:
              'Type a village name (e.g. Latur, Parali) or 6-digit pincode first.',
        );
      });
      return;
    }

    if (explicitQuery != null) {
      _searchCtrl.text = explicitQuery;
    }
    setState(() {
      _isFetchingIndiaPost = true;
      _fetchBanner = null;
    });

    final res = await _service.fetchAndCacheIndiaPostVillages(query);
    if (!mounted) return;
    setState(() {
      _isFetchingIndiaPost = false;
      _fetchBanner = res;
    });
    if (res.isSuccess) {
      await _loadAll(resetPage: true);
    }
  }

  void _openAddFlow() {
    _addNameCtrl.clear();
    _addPinCtrl.clear();
    _addTalukaCtrl.clear();
    _addDistrictCtrl.clear();
    _addStationCtrl.clear();
    _addTransportCtrl.clear();
    setState(() => _addError = null);
    _canvasKey.currentState?.openAddFlow();
  }

  Future<void> _submitCustomVillage() async {
    if (_isSavingAdd) return;
    if (_addNameCtrl.text.trim().isEmpty) {
      setState(() => _addError = 'Village / City name is required.');
      return;
    }
    setState(() {
      _isSavingAdd = true;
      _addError = null;
    });
    final res = await _service.upsertCustomLocation(
      placeName: _addNameCtrl.text.trim(),
      pincode: _addPinCtrl.text.trim(),
      officeType: _addOfficeType,
      taluka: _addTalukaCtrl.text.trim(),
      district: _addDistrictCtrl.text.trim(),
      stateName: _addStateCtrl.text.trim().isEmpty
          ? 'MAHARASHTRA'
          : _addStateCtrl.text.trim(),
      zoneCode: _addZoneCode,
      nearestStation: _addStationCtrl.text.trim(),
      defaultTransport: _addTransportCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSavingAdd = false);
    if (res.isSuccess) {
      _canvasKey.currentState?.exitToSnapshot();
      await _loadAll(resetPage: true);
    } else {
      setState(() => _addError = res.message);
    }
  }

  bool _handlePageActionKey(String keyChar) {
    switch (keyChar) {
      case 'G':
        _openGstinVerifyDialog();
        return true;
      case 'F':
        _runIndiaPostFetch();
        return true;
      case 'R':
        _mapKey.currentState?.resetView();
        return true;
      case 'E':
        if (_selectedLocation != null) {
          setState(() => _isEditingSelected = !_isEditingSelected);
          return true;
        }
        return false;
      case 'N':
        _openAddFlow();
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return DyLinearLandingCanvas(
      key: _canvasKey,
      title: 'All-India Territory, Village & Sales Zone Map',
      moduleName: 'Village / Market',
      isLoading: _isLoading || _isFetchingIndiaPost,
      isSavingAdd: _isSavingAdd,
      onPageActionKey: _handlePageActionKey,
      onConfirmAdd: _submitCustomVillage,
      onSaveDraftAdd: _submitCustomVillage,
      actions: [
        shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: () => _openGstinVerifyDialog(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              GeoShiftKeyCap(letter: 'G'),
              Icon(shad.LucideIcons.database, size: 13),
              shad.DensityGap(shad.gapXs),
              Text('GST Lookup'),
            ],
          ),
        ),
        shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: () {
            setState(() => _selectedZoneCode = 'ALL');
            _mapKey.currentState?.resetView();
            _loadAll(resetPage: true);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              GeoShiftKeyCap(letter: 'R'),
              Icon(shad.LucideIcons.refreshCw, size: 13),
              shad.DensityGap(shad.gapXs),
              Text('Reset View'),
            ],
          ),
        ),
        shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: _isFetchingIndiaPost ? null : () => _runIndiaPostFetch(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              GeoShiftKeyCap(letter: 'F'),
              Icon(shad.LucideIcons.download, size: 13),
              shad.DensityGap(shad.gapXs),
              Text('India Post Fetch'),
            ],
          ),
        ),
        shad.PrimaryButton(
          size: shad.ButtonSize.small,
          onPressed: _openAddFlow,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              GeoShiftKeyCap(letter: 'N', inverted: true),
              Icon(shad.LucideIcons.plus, size: 13),
              shad.DensityGap(shad.gapXs),
              Text('Add Village'),
            ],
          ),
        ),
      ],
      snapshotRows: [
        _buildRegion1Kpi(isZoomed: false),
        DyFlexRow(
          desktopRowHeight: 540,
          cells: [
            DyFlexCell(
              flex: 8,
              compactHeight: 420,
              child: _buildRegion2Map(isZoomed: false),
            ),
            DyFlexCell(
              flex: 4,
              compactHeight: 440,
              child: _buildRegion3Search(isZoomed: false),
            ),
          ],
        ),
        DyFlexRow(
          desktopRowHeight: 500,
          cells: [
            DyFlexCell(
              flex: 8,
              compactHeight: 420,
              child: _buildRegion4Inspector(isZoomed: false),
            ),
            DyFlexCell(
              flex: 4,
              compactHeight: 380,
              child: _buildRegion5Parties(isZoomed: false),
            ),
          ],
        ),
      ],
      zoomTargets: [
        DyLinearZoomTarget(
          regionNumber: 1,
          label: 'Geo Territory Telemetry',
          builder: (_) => _buildRegion1Kpi(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 2,
          label: 'India Sales Zone Map',
          builder: (_) => _buildRegion2Map(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 3,
          label: 'Village & Pincode Directory',
          builder: (_) => _buildRegion3Search(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 4,
          label: 'Village Telemetry & Sister BOs',
          builder: (_) => _buildRegion4Inspector(isZoomed: true),
        ),
        DyLinearZoomTarget(
          regionNumber: 5,
          label: 'Village Parties & Haste Buyers',
          builder: (_) => _buildRegion5Parties(isZoomed: true),
        ),
      ],
      addFlowBuilder: (_) => _buildAddCustomVillageFlow(theme, colors),
    );
  }

  Widget _buildRegion1Kpi({required bool isZoomed}) => GeoTerritoryKpiStrip(
        counts: _kpiCounts,
        activeFilter: _filterMode,
        isZoomed: isZoomed,
        onZoomToggle: () => _canvasKey.currentState?.toggleRegion(1),
        onSelectFilter: (m) {
          setState(() => _filterMode = m);
          _loadAll(resetPage: true);
        },
      );

  Widget _buildRegion2Map({required bool isZoomed}) => DyGeoTerritoryMapCanvas(
        key: _mapKey,
        zones: _zones,
        pins: _mapPins,
        selectedZoneCode: _selectedZoneCode,
        selectedLocation: _selectedLocation,
        showZonesLayer: _showZonesLayer,
        showSpokesLayer: _showSpokesLayer,
        showLabelsLayer: _showLabelsLayer,
        onSelectZoneCode: (zc) {
          setState(() => _selectedZoneCode = zc);
          _loadAll(resetPage: true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _mapKey.currentState?.flyToZoneCode(zc);
          });
        },
        onSelectLocation: (loc) => _selectLocation(loc, flyMap: false),
        onToggleZonesLayer: () =>
            setState(() => _showZonesLayer = !_showZonesLayer),
        onToggleSpokesLayer: () =>
            setState(() => _showSpokesLayer = !_showSpokesLayer),
        onToggleLabelsLayer: () =>
            setState(() => _showLabelsLayer = !_showLabelsLayer),
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(2),
      );

  Widget _buildRegion3Search({required bool isZoomed}) =>
      GeoVillageSearchBentoCard(
        searchController: _searchCtrl,
        onSearchChanged: (_) {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 240), () {
            _loadAll(resetPage: true);
          });
        },
        filterMode: _filterMode,
        onFilterChanged: (m) {
          setState(() => _filterMode = m);
          _loadAll(resetPage: true);
        },
        locations: _directoryRows,
        selectedLocation: _selectedLocation,
        onSelectLocation: (loc) => _selectLocation(loc, flyMap: true),
        onFetchIndiaPost: () => _runIndiaPostFetch(),
        onQuickFetchDemoPin: (pin) => _runIndiaPostFetch(pin),
        isLoading: _isLoading,
        isFetchingIndiaPost: _isFetchingIndiaPost,
        fetchBanner: _fetchBanner,
        currentPage: _currentPage,
        totalCount: _totalMatching,
        hasPrev: _currentPage > 0,
        hasNext: ((_currentPage * _pageSize) + _directoryRows.length) <
            _totalMatching,
        onPrevPage: () {
          setState(() => _currentPage--);
          _loadAll(resetPage: false);
        },
        onNextPage: () {
          setState(() => _currentPage++);
          _loadAll(resetPage: false);
        },
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(3),
      );

  Widget _buildRegion4Inspector({required bool isZoomed}) =>
      GeoLocationInspectorBentoCard(
        location: _selectedLocation,
        zones: _zones,
        siblingPincodeLocations: _siblingPinRows,
        service: _service,
        isEditing: _isEditingSelected,
        onEditingChanged: (v) => setState(() => _isEditingSelected = v),
        onLocationUpdated: () => _loadAll(resetPage: false),
        onSelectSiblingLocation: (sib) => _selectLocation(sib, flyMap: true),
        onFetchIndiaPostPincode: (pin) => _runIndiaPostFetch(pin),
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(4),
      );

  Widget _buildRegion5Parties({required bool isZoomed}) =>
      GeoVillagePartiesBentoCard(
        location: _selectedLocation,
        parties: _selectedParties,
        prospects: _selectedProspects,
        verifiedParties: _selectedVerifiedParties,
        isLoading: _isLoadingParties,
        isSweepingProspects: _isSweepingProspects,
        onVerifyLegacyParty: (p) => _openGstinVerifyDialog(legacyParty: p),
        onConvertProspect: (lead) => _openGstinVerifyDialog(prospect: lead),
        onSweepTownProspects: _sweepSelectedTownProspects,
        onOpenBlankGstinLookup: () => _openGstinVerifyDialog(),
        isZoomed: isZoomed,
        onToggleZoom: () => _canvasKey.currentState?.toggleRegion(5),
      );

  Widget _buildAddCustomVillageFlow(
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final zoneCodes = [for (final z in _zones) z.zoneCode];
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: pad * 2),
      child: shad.OutlinedContainer(
        backgroundColor: colors.card,
        borderColor: colors.border,
        borderRadius: theme.borderRadiusLg,
        padding: EdgeInsets.all(pad * 1.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Custom Rural Village, Market or Transit Hub',
              style: theme.typography.h4,
            ),
            const shad.DensityGap(shad.gapXs),
            Text(
              'Saves into IMMBE2627.sb_geo_locations with auto-computed Surat E-Way distance and Sales Zone assignment.',
              style: theme.typography.xSmall
                  .copyWith(color: colors.mutedForeground),
            ),
            if (_addError != null) ...[
              const shad.DensityGap(shad.gapMd),
              Text(_addError!,
                  style: theme.typography.xSmall
                      .copyWith(color: colors.destructive)),
            ],
            const shad.DensityGap(shad.gapMd),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _addField(theme, colors, 'Village / Market Name',
                      _addNameCtrl, 'e.g. Chakur'),
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: _addField(theme, colors, '6-Digit Pincode',
                      _addPinCtrl, '413513'),
                ),
                const shad.DensityGap(shad.gapSm),
                SizedBox(
                  width: 130 * theme.scaling,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type',
                          style: theme.typography.xSmall
                              .copyWith(color: colors.mutedForeground)),
                      const shad.DensityGap(shad.gapXs),
                      shad.Select<String>(
                        value: _addOfficeType,
                        onChanged: (v) {
                          if (v != null) setState(() => _addOfficeType = v);
                        },
                        itemBuilder: (ctx, v) => Text(v),
                        popup: shad.SelectPopup(
                          items: shad.SelectItemList(
                            children: const [
                              shad.SelectItemButton(
                                  value: 'BO', child: Text('BO (Village)')),
                              shad.SelectItemButton(
                                  value: 'SO', child: Text('SO (Town)')),
                              shad.SelectItemButton(
                                  value: 'HUB', child: Text('HUB')),
                            ],
                          ),
                        ).call,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),
            Row(
              children: [
                Expanded(
                  child: _addField(
                      theme, colors, 'Taluka', _addTalukaCtrl, 'Chakur'),
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: _addField(
                      theme, colors, 'District', _addDistrictCtrl, 'Latur'),
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: _addField(
                      theme, colors, 'State', _addStateCtrl, 'MAHARASHTRA'),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),
            Row(
              children: [
                Expanded(
                  child: _addField(theme, colors, 'Nearest Rail / Hub Station',
                      _addStationCtrl, 'LATUR'),
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: _addField(theme, colors, 'Default Transport',
                      _addTransportCtrl, 'SHREE YOGI EXPRESS'),
                ),
                if (zoneCodes.isNotEmpty) ...[
                  const shad.DensityGap(shad.gapSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sales Zone',
                            style: theme.typography.xSmall
                                .copyWith(color: colors.mutedForeground)),
                        const shad.DensityGap(shad.gapXs),
                        shad.Select<String>(
                          value: zoneCodes.contains(_addZoneCode)
                              ? _addZoneCode
                              : zoneCodes.first,
                          onChanged: (v) {
                            if (v != null) setState(() => _addZoneCode = v);
                          },
                          itemBuilder: (ctx, v) => Text(v),
                          popup: shad.SelectPopup(
                            items: shad.SelectItemList(
                              children: [
                                for (final zc in zoneCodes)
                                  shad.SelectItemButton(
                                      value: zc, child: Text(zc)),
                              ],
                            ),
                          ).call,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _addField(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String label,
    TextEditingController ctrl,
    String hint,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.typography.xSmall
                  .copyWith(color: colors.mutedForeground)),
          const shad.DensityGap(shad.gapXs),
          shad.TextField(controller: ctrl, placeholder: Text(hint)),
        ],
      );
}
