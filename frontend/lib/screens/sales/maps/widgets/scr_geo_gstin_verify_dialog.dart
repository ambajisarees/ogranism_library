/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Modal verification workspace (`GeoGstinVerifyAndOnboardDialog`) mounted from
     `Sales -> Maps` (`ScrGeoZoneMap`) implementing Stage 11.2 Part A + Part B:
     * 15-digit GSTIN Lookup & raw `TP` JSON cache inspector (`sb_gstin_cache`).
     * Human-verified staging editor promoting legacy `sq_MASTER`, `sq_HASTE`,
       or `sb_prospect_leads` entries one-by-one into `"IMMBE2627"."sb_parties"`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Pre-fills cleanly from either an existing `GeoVillagePartyEntry` (Region 5
     Legacy tab), a `GeoProspectLeadModel` (Region 5 Leads tab), or blank for
     ad-hoc GSTIN lookup (`Shift + G`).
   - Strictly uses native `shadcn_flutter` tokens (`shad.ModalContainer`,
     `shad.OutlinedContainer`, `shad.Select`, `shad.TextField`, badges wrapped
     in `Focus(canRequestFocus: false, ...)`).
   - Always checks `if (!mounted) return;` after awaits.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Sample GSTIN chips pull live valid 15-char GSTINs from `sb_gstin_cache`
     nearby the active town/state so staff can verify cache behavior with one click.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: add live GSTN GSTR-1/3B filing scorecard panel when an
     external GSP API key is configured.
================================================================================
*/

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/sales/model_geo_locations.dart';
import '../../../../services/sales/service_gstin_and_prospects.dart';

/// Stage 11.2 GSTIN Lookup & Staged Human-Verified Party Onboarding Dialog.
class GeoGstinVerifyAndOnboardDialog extends StatefulWidget {
  final GeoVillagePartyEntry? seedLegacyParty;
  final GeoProspectLeadModel? seedProspect;
  final GeoLocationModel? activeLocation;
  final List<GeoZoneModel> zones;
  final VoidCallback onSaved;
  final VoidCallback onClose;

  const GeoGstinVerifyAndOnboardDialog({
    super.key,
    this.seedLegacyParty,
    this.seedProspect,
    this.activeLocation,
    required this.zones,
    required this.onSaved,
    required this.onClose,
  });

  @override
  State<GeoGstinVerifyAndOnboardDialog> createState() =>
      _GeoGstinVerifyAndOnboardDialogState();
}

class _GeoGstinVerifyAndOnboardDialogState
    extends State<GeoGstinVerifyAndOnboardDialog> {
  final ServiceGstinAndProspects _service = ServiceGstinAndProspects();

  late final TextEditingController _gstinCtrl;
  late final TextEditingController _tradeCtrl;
  late final TextEditingController _legalCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _panCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _pinCtrl;
  late final TextEditingController _adatiyaCtrl;
  late final TextEditingController _transportCtrl;
  late final TextEditingController _stationCtrl;
  late final TextEditingController _creditDaysCtrl;

  String _partyRole = 'CUSTOMER';
  String _zoneCode = 'MH-MARATHWADA-CORE';
  String _gstStatus = 'Active';
  String _taxpayerType = 'Regular';
  String _constitution = 'Proprietorship';
  String _stateName = 'MAHARASHTRA';
  String _gstStateCode = '27';

  List<String> _sampleGstins = const [];
  GstinLookupModel? _lookupResult;
  bool _isLookingUp = false;
  bool _isSaving = false;
  bool _showRawJson = false;
  String? _statusMsg;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    final lp = widget.seedLegacyParty;
    final pr = widget.seedProspect;
    final loc = widget.activeLocation;

    final initGstin =
        (lp != null && lp.gstin.isNotEmpty) ? lp.gstin : (pr?.gstin ?? '');
    final initTrade = lp?.name ?? pr?.shopName ?? '';
    final initCode = (lp != null &&
            lp.code.isNotEmpty &&
            !lp.code.startsWith('HST:'))
        ? lp.code
        : _derivePartyCode(initTrade);
    final initCity = (lp != null && lp.cityOrPlace.isNotEmpty)
        ? lp.cityOrPlace
        : (pr?.placeName ?? loc?.placeName ?? '');
    final initPin = (lp != null && lp.pincode.isNotEmpty)
        ? lp.pincode
        : (pr?.pincode ?? loc?.pincode ?? '');

    _gstinCtrl = TextEditingController(text: initGstin);
    _tradeCtrl = TextEditingController(text: initTrade);
    _legalCtrl = TextEditingController(text: pr?.legalName ?? initTrade);
    _codeCtrl = TextEditingController(text: initCode);
    _panCtrl = TextEditingController(
      text: initGstin.length >= 12 ? initGstin.substring(2, 12) : '',
    );
    _mobileCtrl = TextEditingController(
      text: (lp != null && lp.mobile.isNotEmpty) ? lp.mobile : (pr?.mobile ?? ''),
    );
    _contactCtrl = TextEditingController(text: pr?.contactPerson ?? '');
    _addrCtrl = TextEditingController(text: pr?.address ?? '');
    _cityCtrl = TextEditingController(text: initCity);
    _pinCtrl = TextEditingController(text: initPin);
    _adatiyaCtrl = TextEditingController(
      text: (lp != null && lp.adatiya.isNotEmpty)
          ? lp.adatiya
          : (pr?.adatiyaName ?? ''),
    );
    _transportCtrl = TextEditingController(
      text: (lp != null && lp.transport.isNotEmpty)
          ? lp.transport
          : (pr?.preferredTransport ?? loc?.defaultTransport ?? ''),
    );
    _stationCtrl = TextEditingController(
      text: (lp != null && lp.station.isNotEmpty)
          ? lp.station
          : (loc?.nearestStation ?? ''),
    );
    _creditDaysCtrl = TextEditingController(text: '30');

    if (lp?.entityKind == 'HASTE' || pr != null) {
      _partyRole = 'HASTE_DIRECT';
    }
    _zoneCode = pr?.zoneCode ??
        loc?.zoneCode ??
        (widget.zones.isNotEmpty ? widget.zones.first.zoneCode : 'MH-MARATHWADA-CORE');
    _stateName = pr?.stateName ?? loc?.stateName ?? 'MAHARASHTRA';
    _gstStateCode = pr?.gstStateCode ?? loc?.gstStateCode ?? '27';

    _loadSampleGstins();
    if (initGstin.length == 15) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runLookup());
    }
  }

  @override
  void dispose() {
    for (final c in [
      _gstinCtrl, _tradeCtrl, _legalCtrl, _codeCtrl, _panCtrl,
      _mobileCtrl, _contactCtrl, _addrCtrl, _cityCtrl, _pinCtrl,
      _adatiyaCtrl, _transportCtrl, _stationCtrl, _creditDaysCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _derivePartyCode(String trade) {
    final cleaned = trade.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.isEmpty) return 'SB_${DateTime.now().millisecondsSinceEpoch % 100000}';
    final prefix = cleaned.length > 8 ? cleaned.substring(0, 8) : cleaned;
    return 'SB_$prefix';
  }

  Future<void> _loadSampleGstins() async {
    final samples =
        await _service.fetchSampleGstinsForLocation(widget.activeLocation);
    if (!mounted) return;
    setState(() => _sampleGstins = samples);
  }

  Future<void> _runLookup() async {
    final raw = _gstinCtrl.text.trim().toUpperCase();
    if (_isLookingUp) return;
    if (raw.length != 15) {
      setState(() {
        _statusIsError = true;
        _statusMsg = 'Enter a valid 15-character Indian GSTIN before lookup.';
      });
      return;
    }

    setState(() {
      _isLookingUp = true;
      _statusMsg = null;
      _statusIsError = false;
    });

    final res = await _service.lookupGstin(
      raw,
      contextLocation: widget.activeLocation,
      hintName: _tradeCtrl.text.trim().isNotEmpty ? _tradeCtrl.text.trim() : null,
      hintAddress: _addrCtrl.text.trim().isNotEmpty ? _addrCtrl.text.trim() : null,
    );
    if (!mounted) return;

    if (res == null) {
      setState(() {
        _isLookingUp = false;
        _statusIsError = true;
        _statusMsg = 'GSTIN "$raw" failed Indian 15-digit structural regex check.';
      });
      return;
    }

    setState(() {
      _isLookingUp = false;
      _lookupResult = res;
      _gstinCtrl.text = res.gstin;
      _panCtrl.text = res.panNumber;
      _gstStatus = res.gstStatus;
      _taxpayerType = res.taxpayerType;
      _constitution = res.constitutionOfBusiness;
      _gstStateCode = res.gstStateCode;
      if (res.stateName.isNotEmpty) _stateName = res.stateName;
      if (res.legalName.isNotEmpty) _legalCtrl.text = res.legalName;
      if (_tradeCtrl.text.trim().isEmpty && res.tradeName.isNotEmpty) {
        _tradeCtrl.text = res.tradeName;
      }
      if (_codeCtrl.text.trim().isEmpty) {
        _codeCtrl.text = _derivePartyCode(_tradeCtrl.text);
      }
      if (_addrCtrl.text.trim().isEmpty && res.principalAddress.isNotEmpty) {
        _addrCtrl.text = res.principalAddress;
      }
      if (_cityCtrl.text.trim().isEmpty && res.districtName.isNotEmpty) {
        _cityCtrl.text = res.districtName;
      }
      if (_pinCtrl.text.trim().isEmpty && res.pincode.isNotEmpty) {
        _pinCtrl.text = res.pincode;
      }
      _statusIsError = false;
      _statusMsg =
          'Loaded GSTN telemetry from ${res.sourceProvider} (${res.constitutionOfBusiness}). Review and confirm below.';
    });
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    final trade = _tradeCtrl.text.trim();
    if (trade.isEmpty) {
      setState(() {
        _statusIsError = true;
        _statusMsg = 'Trade / Shop Name is required.';
      });
      return;
    }
    if (_codeCtrl.text.trim().isEmpty) {
      _codeCtrl.text = _derivePartyCode(trade);
    }

    setState(() {
      _isSaving = true;
      _statusMsg = null;
      _statusIsError = false;
    });

    final res = await _service.verifyAndOnboardParty(
      partyCode: _codeCtrl.text.trim(), tradeName: trade,
      legalName: _legalCtrl.text.trim(), partyRole: _partyRole,
      gstin: _gstinCtrl.text.trim(), panNumber: _panCtrl.text.trim(),
      gstStatus: _gstStatus, taxpayerType: _taxpayerType,
      constitutionOfBusiness: _constitution, contactPerson: _contactCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(), addressLine1: _addrCtrl.text.trim(),
      cityName: _cityCtrl.text.trim(), pincode: _pinCtrl.text.trim(),
      districtName: widget.activeLocation?.district ?? _cityCtrl.text.trim(),
      stateName: _stateName, gstStateCode: _gstStateCode,
      locationId: widget.seedProspect?.locationId ?? widget.activeLocation?.id,
      zoneCode: _zoneCode, adatiyaName: _adatiyaCtrl.text.trim(),
      preferredTransport: _transportCtrl.text.trim(),
      nearestStation: _stationCtrl.text.trim(),
      distanceFromSuratKm: widget.seedProspect?.distanceFromSuratKm ??
          widget.activeLocation?.distanceFromSuratKm,
      creditDays: int.tryParse(_creditDaysCtrl.text.trim()) ?? 30,
      legacyMasterCode: widget.seedLegacyParty?.entityKind == 'MASTER'
          ? widget.seedLegacyParty?.code : null,
      legacyHasteName: widget.seedLegacyParty?.entityKind == 'HASTE'
          ? widget.seedLegacyParty?.name : widget.seedProspect?.shopName,
      prospectLeadId: widget.seedProspect?.id,
      gstinRawJson: _lookupResult?.rawJson,
    );

    if (!mounted) return;
    if (res.isSuccess) {
      widget.onSaved();
      widget.onClose();
    } else {
      setState(() {
        _isSaving = false;
        _statusIsError = true;
        _statusMsg = res.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final typography = theme.typography;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;
    final lookupRes = _lookupResult;
    final zoneCodes = [for (final z in widget.zones) z.zoneCode];

    return Center(
      child: shad.ModalContainer(
        child: SizedBox(
          width: 780 * theme.scaling,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 690 * theme.scaling),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(colors, typography),
                const shad.DensityGap(shad.gapSm),
                const shad.Divider(),
                const shad.DensityGap(shad.gapSm),
                _buildGstinLookupBar(theme, colors, typography, pad, isDark),
                if (_statusMsg != null) ...[
                  const shad.DensityGap(shad.gapSm),
                  _buildStatusBanner(theme, pad, isDark),
                ],
                if (lookupRes != null) ...[
                  const shad.DensityGap(shad.gapSm),
                  _buildDecodedTelemetryCard(
                    theme,
                    colors,
                    typography,
                    pad,
                    isDark,
                    lookupRes,
                  ),
                ],
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildFormBody(theme, colors, typography, zoneCodes),
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
                const shad.Divider(),
                const shad.DensityGap(shad.gapSm),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(shad.ColorScheme colors, shad.Typography typography) {
    final sourceLabel = widget.seedProspect != null
        ? 'Converting Haste Prospect -> sb_parties'
        : widget.seedLegacyParty != null
            ? 'Verifying Legacy ${widget.seedLegacyParty?.entityKind} -> sb_parties'
            : 'Verify 15-Digit GSTIN & Onboard Customer';
    return Row(
      children: [
        Icon(shad.LucideIcons.database, size: 18, color: colors.primary),
        const shad.DensityGap(shad.gapSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GSTIN Lookup & Staged Party Verification',
                style: typography.h4.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                sourceLabel,
                style: typography.xSmall.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
        shad.GhostButton(
          size: shad.ButtonSize.small,
          onPressed: widget.onClose,
          child: const Icon(shad.LucideIcons.x, size: 15),
        ),
      ],
    );
  }

  Widget _buildGstinLookupBar(
    shad.ThemeData theme, shad.ColorScheme colors, shad.Typography typography, double pad, bool isDark,
  ) =>
      shad.OutlinedContainer(
        backgroundColor: colors.card, borderColor: colors.border,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        padding: EdgeInsets.all(pad * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: shad.TextField(
                    controller: _gstinCtrl,
                    placeholder: const Text('Enter 15-digit GSTIN (e.g. 27AAACA1234A1Z5)'),
                    onSubmitted: (_) => _runLookup(),
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
                shad.PrimaryButton(
                  size: shad.ButtonSize.small,
                  onPressed: _isLookingUp ? null : _runLookup,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(shad.LucideIcons.search, size: 13),
                      const shad.DensityGap(shad.gapXs),
                      Text(_isLookingUp ? 'Checking...' : 'Lookup GSTIN'),
                    ],
                  ),
                ),
              ],
            ),
            if (_sampleGstins.isNotEmpty) ...[
              const shad.DensityGap(shad.gapXs),
              Wrap(
                spacing: 6 * theme.scaling, runSpacing: 4 * theme.scaling,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Quick test cache:',
                      style: typography.xSmall.copyWith(color: colors.mutedForeground)),
                  for (final g in _sampleGstins)
                    shad.OutlineButton(
                      size: shad.ButtonSize.xSmall,
                      onPressed: () { _gstinCtrl.text = g; _runLookup(); },
                      child: Text(g, style: typography.mono.copyWith(fontSize: 10.5)),
                    ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _buildStatusBanner(shad.ThemeData theme, double pad, bool isDark) {
    final accent =
        _statusIsError ? DyColorSystem.orange500 : DyColorSystem.emerald500;
    return shad.OutlinedContainer(
      backgroundColor: DyColorSystem.resolveSurface(accent, isDark),
      borderColor: DyColorSystem.resolveBorder(accent, isDark),
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: EdgeInsets.all(pad * 0.65),
      child: Text(_statusMsg ?? '', style: theme.typography.xSmall),
    );
  }

  Widget _buildDecodedTelemetryCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    shad.Typography typography,
    double pad,
    bool isDark,
    GstinLookupModel res,
  ) {
    const encoder = JsonEncoder.withIndent('  ');
    return shad.OutlinedContainer(
      backgroundColor: DyColorSystem.resolveSurface(DyColorSystem.cyan500, isDark),
      borderColor: DyColorSystem.resolveBorder(DyColorSystem.cyan500, isDark),
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: EdgeInsets.all(pad * 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _isolated(shad.PrimaryBadge(child: Text(res.gstStatus))),
              const shad.DensityGap(shad.gapXs),
              _isolated(shad.SecondaryBadge(child: Text(res.taxpayerType))),
              const shad.DensityGap(shad.gapXs),
              _isolated(
                shad.OutlineBadge(
                  child: Text(
                    res.isChecksumValid ? 'Checksum OK' : 'Verify Check-Digit',
                  ),
                ),
              ),
              const Spacer(),
              shad.OutlineButton(
                size: shad.ButtonSize.xSmall,
                onPressed: () => setState(() => _showRawJson = !_showRawJson),
                child: Text(_showRawJson ? 'Hide Raw JSON' : 'View Raw GSTN JSON'),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapXs),
          Text(
            'PAN: ${res.panNumber} • ${res.constitutionOfBusiness} • '
            'State: ${res.gstStateCode} (${res.stateName}) • '
            'HSN: ${res.hsnCodes.join(', ')}',
            style: typography.xSmall.copyWith(fontWeight: FontWeight.w600),
          ),
          if (_showRawJson) ...[
            const shad.DensityGap(shad.gapSm),
            shad.OutlinedContainer(
              backgroundColor: colors.card,
              borderColor: colors.border,
              borderRadius: BorderRadius.circular(theme.radiusSm),
              padding: EdgeInsets.all(pad * 0.6),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 130 * theme.scaling),
                child: SingleChildScrollView(
                  child: Text(
                    encoder.convert(res.rawJson),
                    style: typography.mono.copyWith(fontSize: 10.5),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormBody(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    shad.Typography typography,
    List<String> zoneCodes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _field('Trade / Shop Name *', _tradeCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(flex: 2, child: _field('Legal Taxpayer Name', _legalCtrl, typography, colors)),
          ],
        ),
        const shad.DensityGap(shad.gapSm),
        Row(
          children: [
            Expanded(
              child: _selectField(
                label: 'Party Role',
                value: _partyRole,
                options: const ['CUSTOMER', 'HASTE_DIRECT', 'ADATIYA'],
                onChanged: (v) => setState(() => _partyRole = v),
                typography: typography,
                colors: colors,
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('Party Code *', _codeCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('PAN Number', _panCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('Credit Days', _creditDaysCtrl, typography, colors)),
          ],
        ),
        const shad.DensityGap(shad.gapSm),
        Row(
          children: [
            Expanded(child: _field('Mobile / WhatsApp', _mobileCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('Contact Person', _contactCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('City / Town', _cityCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('6-Digit Pincode', _pinCtrl, typography, colors)),
          ],
        ),
        const shad.DensityGap(shad.gapSm),
        _field('Billing Address Line', _addrCtrl, typography, colors),
        const shad.DensityGap(shad.gapSm),
        Row(
          children: [
            if (zoneCodes.isNotEmpty)
              Expanded(
                child: _selectField(
                  label: 'Sales Zone',
                  value: zoneCodes.contains(_zoneCode) ? _zoneCode : zoneCodes.first,
                  options: zoneCodes,
                  onChanged: (v) => setState(() => _zoneCode = v),
                  typography: typography,
                  colors: colors,
                ),
              ),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('Adatiya / Broker', _adatiyaCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('Preferred Transport', _transportCtrl, typography, colors)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _field('Nearest Hub Station', _stationCtrl, typography, colors)),
          ],
        ),
      ],
    );
  }

  Widget _selectField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    required shad.Typography typography,
    required shad.ColorScheme colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: typography.xSmall.copyWith(color: colors.mutedForeground)),
        const shad.DensityGap(shad.gapXs),
        shad.Select<String>(
          value: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          itemBuilder: (_, v) => Text(v),
          popup: shad.SelectPopup(
            items: shad.SelectItemList(
              children: [
                for (final opt in options)
                  shad.SelectItemButton(value: opt, child: Text(opt)),
              ],
            ),
          ).call,
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    shad.Typography typography,
    shad.ColorScheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: typography.xSmall.copyWith(color: colors.mutedForeground)),
        const shad.DensityGap(shad.gapXs),
        shad.TextField(controller: ctrl),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        shad.GhostButton(
          onPressed: _isSaving ? null : widget.onClose,
          child: const Text('Cancel'),
        ),
        const shad.DensityGap(shad.gapSm),
        shad.PrimaryButton(
          onPressed: _isSaving ? null : _submit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(shad.LucideIcons.save, size: 14),
              const shad.DensityGap(shad.gapXs),
              Text(_isSaving ? 'Saving...' : 'Verify & Save to sb_parties'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _isolated(Widget child) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: false,
        child: child,
      );
}
