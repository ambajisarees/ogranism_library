/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Stage 11.2 Service (`ServiceGstinAndProspects`) powering:
     * Hybrid GSTIN lookup & raw JSON caching (`"IMMBE2627"."sb_gstin_cache"`).
     * Textile expansion lead mining (`"IMMBE2627"."sb_prospect_leads"`).
     * Human-verified party staging (`"IMMBE2627"."sb_parties"`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `lookupGstin`: Checks `sb_gstin_cache` first -> falls back to legacy
     `sq_MASTER.GSTIN` / `sq_HASTE.EXCISEREG` -> synthesizes structured `TP`
     telemetry via `GstinLookupModel.parseAndSynthesize` and caches it so any
     GSTIN lookup is fast, idempotent, and offline-resilient.
   - `sweepTownProspects`: Mines unconverted `sq_HASTE` sub-buyers for a
     selected town/pincode into `sb_prospect_leads` with Surat logistics metadata.
   - `verifyAndOnboardParty`: Saves human-confirmed party rows into `sb_parties`,
     archives GSTIN payload to `sb_gstin_cache`, and marks linked prospect leads
     as `CONVERTED`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Legacy `sq_MASTER` and `sq_HASTE` remain strictly read-only.
   - PostgREST `.or(...)` values strip double-quotes cleanly before building
     exact-match / case-insensitive filters.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Adding a live ClearTax / Sandbox / MasterGST HTTP adapter requires only one
     API call block inside `lookupGstin` right before structural synthesis.
================================================================================
*/

import 'package:flutter/foundation.dart';

import '../../models/sales/model_geo_locations.dart';
import '../core/service_supabase.dart';

/// Singleton service for Hybrid GSTIN Caching, Prospect Leads & `sb_parties`.
class ServiceGstinAndProspects {
  static final ServiceGstinAndProspects _instance =
      ServiceGstinAndProspects._internal();
  factory ServiceGstinAndProspects() => _instance;
  ServiceGstinAndProspects._internal();

  final SupabaseService _db = SupabaseService();

  /// Looks up a 15-digit GSTIN across `sb_gstin_cache`, `sq_MASTER`, `sq_HASTE`,
  /// or synthesizes & caches structural GSTN Taxpayer (`TP`) telemetry.
  Future<GstinLookupModel?> lookupGstin(
    String inputGstin, {
    GeoLocationModel? contextLocation,
    String? hintName,
    String? hintAddress,
  }) async {
    final clean = inputGstin.trim().toUpperCase();
    if (clean.length != 15) return null;

    try {
      final cached = await _db.client
          .schema('IMMBE2627')
          .from('sb_gstin_cache')
          .select()
          .eq('gstin', clean)
          .maybeSingle();

      if (cached != null) {
        return GstinLookupModel.fromCacheRow(Map<String, dynamic>.from(cached));
      }

      // Check legacy sq_MASTER
      final masterRows = await _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('code,NAME,GSTIN,CITY1,STATE1,PINNO,ADDRESS1,ADDRESS2')
          .eq('GSTIN', clean)
          .limit(1);

      String? name = hintName;
      String? city = contextLocation?.placeName;
      String? state = contextLocation?.stateName;
      String? pin = contextLocation?.pincode;
      String? addr = hintAddress;
      var provider = 'GSTN_STRUCTURAL_SYNTHESIS';

      final masterList = masterRows as List;
      if (masterList.isNotEmpty && masterList.first is Map) {
        final m = Map<String, dynamic>.from(masterList.first as Map);
        name = m['NAME']?.toString().trim();
        city = m['CITY1']?.toString().trim();
        state = m['STATE1']?.toString().trim();
        pin = m['PINNO']?.toString().trim();
        addr = [
          m['ADDRESS1']?.toString().trim() ?? '',
          m['ADDRESS2']?.toString().trim() ?? '',
          city ?? '',
          state ?? '',
          pin ?? '',
        ].where((s) => s.isNotEmpty).join(', ');
        provider = 'SQ_MASTER_MIRROR';
      } else {
        final hasteRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_HASTE')
            .select('HASTE,EXCISEREG,PLACE,PINNO,ADDRESS1,ADDRESS2')
            .eq('EXCISEREG', clean)
            .limit(1);
        final hasteList = hasteRows as List;
        if (hasteList.isNotEmpty && hasteList.first is Map) {
          final h = Map<String, dynamic>.from(hasteList.first as Map);
          name = h['HASTE']?.toString().trim();
          city = h['PLACE']?.toString().trim();
          pin = h['PINNO']?.toString().trim();
          addr = [
            h['ADDRESS1']?.toString().trim() ?? '',
            h['ADDRESS2']?.toString().trim() ?? '',
            city ?? '',
            pin ?? '',
          ].where((s) => s.isNotEmpty).join(', ');
          provider = 'SQ_HASTE_EXCISEREG';
        }
      }

      final synth = GstinLookupModel.parseAndSynthesize(
        rawGstin: clean,
        hintTradeName: name,
        hintCity: city,
        hintPincode: pin,
        hintState: state,
        hintAddress: addr,
      );
      if (synth == null) return null;

      await _cacheGstinModel(synth, sourceProvider: provider);
      return GstinLookupModel(
        gstin: synth.gstin,
        panNumber: synth.panNumber,
        gstStateCode: synth.gstStateCode,
        legalName: synth.legalName,
        tradeName: synth.tradeName,
        gstStatus: synth.gstStatus,
        taxpayerType: synth.taxpayerType,
        constitutionOfBusiness: synth.constitutionOfBusiness,
        registrationDate: synth.registrationDate,
        principalAddress: synth.principalAddress,
        pincode: synth.pincode,
        districtName: synth.districtName,
        stateName: synth.stateName,
        hsnCodes: synth.hsnCodes,
        filingRegularity: synth.filingRegularity,
        rawJson: synth.rawJson,
        sourceProvider: provider,
        isChecksumValid: synth.isChecksumValid,
      );
    } catch (e) {
      debugPrint('[ServiceGstinAndProspects] lookupGstin error: $e');
      return GstinLookupModel.parseAndSynthesize(
        rawGstin: clean,
        hintTradeName: hintName,
        hintCity: contextLocation?.placeName,
        hintPincode: contextLocation?.pincode,
        hintState: contextLocation?.stateName,
        hintAddress: hintAddress,
      );
    }
  }

  /// Returns sample cached GSTINs near [loc] to help test GSTIN lookup quickly.
  Future<List<String>> fetchSampleGstinsForLocation(
    GeoLocationModel? loc, {
    int limit = 4,
  }) async {
    try {
      if (loc != null) {
        final escPlace = loc.cleanPlaceName.replaceAll('"', '');
        final stCode = loc.gstStateCode;
        final localRows = await _db.client
            .schema('IMMBE2627')
            .from('sb_gstin_cache')
            .select('gstin')
            .or(
              [
                if (escPlace.isNotEmpty) 'district_name.ilike."$escPlace"',
                if (stCode.isNotEmpty) 'gst_state_code.eq."$stCode"',
              ].join(','),
            )
            .limit(limit);
        final list = [
          for (final r in (localRows as List))
            if (r is Map && r['gstin'] != null) r['gstin'].toString().trim(),
        ].where((s) => s.length == 15).toList();
        if (list.isNotEmpty) return list;
      }

      final fallback = await _db.client
          .schema('IMMBE2627')
          .from('sb_gstin_cache')
          .select('gstin')
          .limit(limit);
      return [
        for (final r in (fallback as List))
          if (r is Map && r['gstin'] != null) r['gstin'].toString().trim(),
      ].where((s) => s.length == 15).toList();
    } catch (e) {
      debugPrint('[ServiceGstinAndProspects] fetchSampleGstins error: $e');
      return const [];
    }
  }

  /// Fetches textile prospect leads (`sb_prospect_leads`) for a village/zone.
  Future<List<GeoProspectLeadModel>> fetchProspectsForLocation(
    GeoLocationModel? loc, {
    String zoneCode = 'ALL',
    int limit = 80,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('sb_prospect_leads')
          .select();

      if (loc != null) {
        final orParts = <String>['location_id.eq.${loc.id}'];
        final escClean = loc.cleanPlaceName.replaceAll('"', '');
        if (escClean.isNotEmpty) {
          orParts.add('place_name.ilike."$escClean"');
        }
        final pin = loc.pincode?.trim();
        if (pin != null && pin.isNotEmpty) {
          orParts.add('pincode.eq."${pin.replaceAll('"', '')}"');
        }
        query = query.or(orParts.join(','));
      } else if (zoneCode != 'ALL') {
        query = query.eq('zone_code', zoneCode);
      }

      final rows = await query
          .order('priority_score', ascending: false)
          .order('shop_name', ascending: true)
          .limit(limit);

      return [
        for (final r in (rows as List))
          if (r is Map)
            GeoProspectLeadModel.fromJson(Map<String, dynamic>.from(r)),
      ];
    } catch (e) {
      debugPrint('[ServiceGstinAndProspects] fetchProspects error: $e');
      return const [];
    }
  }

  /// Fetches human-verified staged parties (`sb_parties`) for a village/zone.
  Future<List<SbVerifiedPartyModel>> fetchVerifiedPartiesForLocation(
    GeoLocationModel? loc, {
    String zoneCode = 'ALL',
    int limit = 60,
  }) async {
    try {
      var query =
          _db.client.schema('IMMBE2627').from('sb_parties').select();

      if (loc != null) {
        final orParts = <String>['location_id.eq.${loc.id}'];
        final escClean = loc.cleanPlaceName.replaceAll('"', '');
        if (escClean.isNotEmpty) {
          orParts.add('city_name.ilike."$escClean"');
        }
        final pin = loc.pincode?.trim();
        if (pin != null && pin.isNotEmpty) {
          orParts.add('pincode.eq."${pin.replaceAll('"', '')}"');
        }
        query = query.or(orParts.join(','));
      } else if (zoneCode != 'ALL') {
        query = query.eq('zone_code', zoneCode);
      }

      final rows =
          await query.order('created_at', ascending: false).limit(limit);

      return [
        for (final r in (rows as List))
          if (r is Map)
            SbVerifiedPartyModel.fromJson(Map<String, dynamic>.from(r)),
      ];
    } catch (e) {
      debugPrint('[ServiceGstinAndProspects] fetchVerifiedParties error: $e');
      return const [];
    }
  }

  /// Mines unconverted `sq_HASTE` sub-buyers for [loc] into `sb_prospect_leads`.
  Future<GeoFetchResult> sweepTownProspects(GeoLocationModel loc) async {
    final terms = <String>{
      loc.cleanPlaceName.toUpperCase(),
      loc.placeName.toUpperCase(),
      ...loc.legacyCityAliases.map((e) => e.toUpperCase()),
    }.where((s) => s.isNotEmpty).toList();

    try {
      var hasteQ = _db.client
          .schema('IMMBE2627')
          .from('sq_HASTE')
          .select('HASTE,PLACE,PINNO,ADDRESS1,ADDRESS2,MOBILE,PHONE1,ADATIYA,TRANSPORT,EXCISEREG,CONTACT');

      final locPin = loc.pincode;
      if (terms.isNotEmpty) {
        hasteQ = hasteQ.inFilter('PLACE', terms);
      } else if (locPin != null && locPin.isNotEmpty) {
        hasteQ = hasteQ.eq('PINNO', locPin);
      }
      final hasteRows = await hasteQ.limit(120) as List;

      // Cross-check direct sq_MASTER parties in same place/pincode
      final masterNames = <String>{};
      if (terms.isNotEmpty) {
        final mRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_MASTER')
            .select('NAME')
            .inFilter('CITY1', terms)
            .limit(200) as List;
        for (final m in mRows) {
          if (m is Map) {
            final n = m['NAME']?.toString().trim().toUpperCase() ?? '';
            if (n.isNotEmpty) masterNames.add(n);
          }
        }
      }

      final upserts = <Map<String, dynamic>>[];
      final seenKeys = <String>{};
      for (final h in hasteRows) {
        if (h is! Map) continue;
        final shop = h['HASTE']?.toString().trim() ?? '';
        if (shop.isEmpty) continue;
        if (masterNames.contains(shop.toUpperCase())) continue;

        final place = (h['PLACE']?.toString().trim() ?? loc.placeName).trim();
        final leadKey = 'HASTE:${shop.toUpperCase()}:${place.toUpperCase()}';
        if (!seenKeys.add(leadKey)) continue;

        final rawExcise = h['EXCISEREG']?.toString().trim().toUpperCase() ?? '';
        final validGst = rawExcise.length == 15 ? rawExcise : null;
        final mobile = (h['MOBILE']?.toString().trim().isNotEmpty ?? false)
            ? h['MOBILE'].toString().trim()
            : h['PHONE1']?.toString().trim();

        final addr = [
          h['ADDRESS1']?.toString().trim() ?? '',
          h['ADDRESS2']?.toString().trim() ?? '',
          place,
        ].where((s) => s.isNotEmpty).join(', ');

        upserts.add({
          'lead_key': leadKey,
          'shop_name': shop,
          'legal_name': shop,
          'source_channel': 'HASTE_MINED',
          'lead_status': 'UNCONVERTED_HASTE',
          if (validGst != null) 'gstin': validGst,
          if (validGst != null) 'pan_number': validGst.substring(2, 12),
          if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
          if (mobile != null && mobile.isNotEmpty) 'whatsapp': mobile,
          if ((h['CONTACT']?.toString().trim() ?? '').isNotEmpty)
            'contact_person': h['CONTACT'].toString().trim(),
          if (addr.isNotEmpty) 'address': addr,
          'place_name': place,
          'pincode': (h['PINNO']?.toString().trim().isNotEmpty ?? false)
              ? h['PINNO'].toString().trim()
              : loc.pincode,
          'district_name': loc.district ?? place,
          'state_name': loc.stateName,
          'gst_state_code': validGst?.substring(0, 2) ?? loc.gstStateCode,
          'location_id': loc.id,
          'zone_code': loc.zoneCode,
          'adatiya_name': h['ADATIYA']?.toString().trim(),
          'preferred_transport': h['TRANSPORT']?.toString().trim(),
          'distance_from_surat_km': loc.distanceFromSuratKm,
          'priority_score': 60 +
              (validGst != null ? 25 : 0) +
              ((mobile != null && mobile.length >= 10) ? 10 : 0) +
              5,
          'notes': 'Swept from ${loc.placeName} sq_HASTE consignees',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      if (upserts.isEmpty) {
        return GeoFetchResult(
          isSuccess: true,
          count: 0,
          message:
              'Sweep complete for ${loc.placeName}: all Haste sub-buyers already tracked.',
        );
      }

      await _db.client
          .schema('IMMBE2627')
          .from('sb_prospect_leads')
          .upsert(upserts, onConflict: 'lead_key');

      return GeoFetchResult(
        isSuccess: true,
        count: upserts.length,
        message:
            'Swept ${upserts.length} unconverted Haste prospect(s) in ${loc.placeName}.',
      );
    } catch (e) {
      debugPrint('[ServiceGstinAndProspects] sweepTownProspects error: $e');
      return GeoFetchResult(
        isSuccess: false,
        count: 0,
        message: 'Prospect sweep failed: $e',
      );
    }
  }

  /// Verifies and commits a party to `sb_parties`, updating cache & lead state.
  Future<GeoFetchResult> verifyAndOnboardParty({
    required String partyCode,
    required String tradeName,
    String? legalName,
    String partyRole = 'CUSTOMER',
    String? gstin,
    String? panNumber,
    String gstStatus = 'Active',
    String taxpayerType = 'Regular',
    String? constitutionOfBusiness,
    String? contactPerson,
    String? mobile,
    String? addressLine1,
    String? cityName,
    String? pincode,
    String? districtName,
    String? stateName,
    String? gstStateCode,
    String? locationId,
    String? zoneCode,
    String? adatiyaName,
    String? preferredTransport,
    String? nearestStation,
    int? distanceFromSuratKm,
    int creditDays = 30,
    String? legacyMasterCode,
    String? legacyHasteName,
    String? prospectLeadId,
    Map<String, dynamic>? gstinRawJson,
  }) async {
    final cleanCode = partyCode.trim().toUpperCase();
    final cleanTrade = tradeName.trim();
    if (cleanCode.isEmpty || cleanTrade.isEmpty) {
      return const GeoFetchResult(
        isSuccess: false,
        count: 0,
        message: 'Party Code and Trade Name are required.',
      );
    }

    final cleanGst = gstin?.trim().toUpperCase() ?? '';
    final effectivePan = (panNumber != null && panNumber.trim().isNotEmpty)
        ? panNumber.trim().toUpperCase()
        : (cleanGst.length == 15 ? cleanGst.substring(2, 12) : null);
    final effectiveStateCode =
        (gstStateCode != null && gstStateCode.trim().isNotEmpty)
            ? gstStateCode.trim()
            : (cleanGst.length >= 2 ? cleanGst.substring(0, 2) : null);

    try {
      if (cleanGst.length == 15) {
        await _db.client.schema('IMMBE2627').from('sb_gstin_cache').upsert(
          {
            'gstin': cleanGst,
            'pan_number': effectivePan,
            'gst_state_code': effectiveStateCode,
            'legal_name':
                (legalName?.trim().isNotEmpty ?? false)
                    ? legalName!.trim()
                    : cleanTrade,
            'trade_name': cleanTrade,
            'gst_status': gstStatus,
            'taxpayer_type': taxpayerType,
            if (constitutionOfBusiness != null &&
                constitutionOfBusiness.isNotEmpty)
              'constitution_of_business': constitutionOfBusiness,
            if (addressLine1 != null && addressLine1.isNotEmpty)
              'principal_address': addressLine1.trim(),
            if (pincode != null && pincode.isNotEmpty)
              'pincode': pincode.trim(),
            if (districtName != null && districtName.isNotEmpty)
              'district_name': districtName.trim(),
            if (stateName != null && stateName.isNotEmpty)
              'state_name': stateName.trim(),
            if (gstinRawJson != null && gstinRawJson.isNotEmpty)
              'raw_json': gstinRawJson,
            'source_provider': 'HUMAN_VERIFIED_ONBOARD',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'gstin',
        );
      }

      final inserted = await _db.client
          .schema('IMMBE2627')
          .from('sb_parties')
          .upsert(
            {
              'party_code': cleanCode,
              if (legacyMasterCode != null && legacyMasterCode.isNotEmpty)
                'legacy_master_code': legacyMasterCode,
              if (legacyHasteName != null && legacyHasteName.isNotEmpty)
                'legacy_haste_name': legacyHasteName,
              'party_role': partyRole,
              'trade_name': cleanTrade,
              'legal_name':
                  (legalName?.trim().isNotEmpty ?? false)
                      ? legalName!.trim()
                      : cleanTrade,
              if (cleanGst.isNotEmpty) 'gstin': cleanGst,
              if (effectivePan != null) 'pan_number': effectivePan,
              'gst_status': gstStatus,
              'taxpayer_type': taxpayerType,
              if (constitutionOfBusiness != null &&
                  constitutionOfBusiness.isNotEmpty)
                'constitution_of_business': constitutionOfBusiness,
              if (contactPerson != null && contactPerson.isNotEmpty)
                'contact_person': contactPerson.trim(),
              if (mobile != null && mobile.isNotEmpty) 'mobile': mobile.trim(),
              if (addressLine1 != null && addressLine1.isNotEmpty)
                'address_line1': addressLine1.trim(),
              if (cityName != null && cityName.isNotEmpty)
                'city_name': cityName.trim().toUpperCase(),
              if (pincode != null && pincode.isNotEmpty)
                'pincode': pincode.trim(),
              if (districtName != null && districtName.isNotEmpty)
                'district_name': districtName.trim(),
              if (stateName != null && stateName.isNotEmpty)
                'state_name': stateName.trim().toUpperCase(),
              if (effectiveStateCode != null)
                'gst_state_code': effectiveStateCode,
              if (locationId != null && locationId.isNotEmpty)
                'location_id': locationId,
              if (zoneCode != null && zoneCode.isNotEmpty)
                'zone_code': zoneCode,
              if (adatiyaName != null && adatiyaName.isNotEmpty)
                'adatiya_name': adatiyaName.trim().toUpperCase(),
              if (preferredTransport != null && preferredTransport.isNotEmpty)
                'preferred_transport': preferredTransport.trim().toUpperCase(),
              if (nearestStation != null && nearestStation.isNotEmpty)
                'nearest_station': nearestStation.trim().toUpperCase(),
              if (distanceFromSuratKm != null)
                'distance_from_surat_km': distanceFromSuratKm,
              'credit_days': creditDays,
              'verification_status': 'HUMAN_VERIFIED',
              if (gstinRawJson != null && gstinRawJson.isNotEmpty)
                'gstin_snapshot_json': gstinRawJson,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            },
            onConflict: 'party_code',
          )
          .select('id')
          .single();

      final promotedId = inserted['id']?.toString();
      if (prospectLeadId != null &&
          prospectLeadId.isNotEmpty &&
          promotedId != null &&
          promotedId.isNotEmpty) {
        await _db.client
            .schema('IMMBE2627')
            .from('sb_prospect_leads')
            .update({
              'lead_status': 'CONVERTED',
              'promoted_party_id': promotedId,
              if (cleanGst.isNotEmpty) 'gstin': cleanGst,
              if (effectivePan != null) 'pan_number': effectivePan,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', prospectLeadId);
      }

      return GeoFetchResult(
        isSuccess: true,
        count: 1,
        message: 'Verified "$cleanTrade" ($cleanCode) committed to sb_parties.',
      );
    } catch (e) {
      debugPrint('[ServiceGstinAndProspects] verifyAndOnboardParty error: $e');
      return GeoFetchResult(
        isSuccess: false,
        count: 0,
        message: 'Failed to onboard party: $e',
      );
    }
  }

  Future<void> _cacheGstinModel(
    GstinLookupModel model, {
    required String sourceProvider,
  }) async {
    await _db.client.schema('IMMBE2627').from('sb_gstin_cache').upsert(
      {
        'gstin': model.gstin,
        'pan_number': model.panNumber,
        'gst_state_code': model.gstStateCode,
        'legal_name': model.legalName,
        'trade_name': model.tradeName,
        'gst_status': model.gstStatus,
        'taxpayer_type': model.taxpayerType,
        'constitution_of_business': model.constitutionOfBusiness,
        if (model.principalAddress.isNotEmpty)
          'principal_address': model.principalAddress,
        if (model.pincode.isNotEmpty) 'pincode': model.pincode,
        if (model.districtName.isNotEmpty) 'district_name': model.districtName,
        if (model.stateName.isNotEmpty) 'state_name': model.stateName,
        'hsn_codes': model.hsnCodes,
        'filing_regularity': model.filingRegularity,
        'raw_json': model.rawJson,
        'source_provider': sourceProvider,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'gstin',
    );
  }
}
