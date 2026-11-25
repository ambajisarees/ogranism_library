/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Stage 11.1 Service (`ServiceGeoLocations`) managing `"IMMBE2627"."sb_geo_zones"`,
     `"IMMBE2627"."sb_geo_locations"`, live India Post village/pincode directory
     lookups (`api.postalpincode.in`), Haversine Surat road-distance calculations,
     and live `sq_MASTER` / `sq_HASTE` village party resolution.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `searchLocationsPage`: Server-side paginated directory queries over `sb_geo_locations`
     supporting 6-digit pincode prefix, village/taluka/district search, and Zone filters.
   - `fetchAndCacheIndiaPostVillages`: Queries the free India Post postal directory
     API for any 6-digit pincode OR rural village/town name, computes deterministic
     district coordinates & Surat road distances (1.28x Haversine), and upserts all
     Branch Offices (`B.O`), Sub-Offices (`S.O`), and Head Offices (`H.O`) directly
     into `"IMMBE2627"."sb_geo_locations"` via `fn_upsert_geo_locations_batch`.
   - `fetchPartiesForLocation`: Cross-queries read-only `"IMMBE2627"."sq_MASTER"`
     and `"IMMBE2627"."sq_HASTE"` for a village or Zone without modifying `sq_*`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Never writes to `sq_CITIES`, `sq_MASTER`, or `sq_HASTE`; all geo mutations
     target `sb_geo_zones` and `sb_geo_locations` only.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Full bulk CSV uploader for India Post's 165k OGD directory can batch-call
     `fn_upsert_geo_locations_batch` with 500-row chunks cleanly later.
================================================================================
*/

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/sales/model_geo_locations.dart';
import '../core/service_supabase.dart';

/// Singleton service for All-India Geo Locations, Villages & Sales Zones.
class ServiceGeoLocations {
  static final ServiceGeoLocations _instance = ServiceGeoLocations._internal();
  factory ServiceGeoLocations() => _instance;
  ServiceGeoLocations._internal();

  static const double _suratLat = 21.1702;
  static const double _suratLng = 72.8311;

  final SupabaseService _db = SupabaseService();

  Future<int> _execCount(dynamic query) async {
    final res = await query.count(CountOption.exact);
    return (res.count as num).toInt();
  }

  /// Fetches all Sales Zones ordered by commercial activity.
  Future<List<GeoZoneModel>> fetchZones() async {
    try {
      final rows = await _db.client
          .schema('IMMBE2627')
          .from('sb_geo_zones')
          .select()
          .eq('is_active', true)
          .order('active_masters_count', ascending: false);
      return (rows as List<dynamic>)
          .map((j) => GeoZoneModel.fromJson(Map<String, dynamic>.from(j as Map)))
          .toList();
    } catch (e) {
      debugPrint('[ServiceGeoLocations] fetchZones error: $e');
      return const [];
    }
  }

  /// Fetches KPI summary counts for Region [1].
  Future<GeoTerritoryKpiCounts> fetchKpiCounts() async {
    try {
      final base = _db.client.schema('IMMBE2627').from('sb_geo_locations');
      final results = await Future.wait<int>([
        _execCount(base.select('id')),
        _execCount(base.select('id').gt('master_party_count', 0)),
        _execCount(base.select('id').gt('haste_party_count', 0)),
        _execCount(
          _db.client
              .schema('IMMBE2627')
              .from('sb_geo_zones')
              .select('id')
              .eq('is_active', true),
        ),
        _execCount(base.select('id').eq('office_type', 'BO')),
      ]);
      return GeoTerritoryKpiCounts(
        totalLocations: results[0],
        erpMarketsCount: results[1],
        hasteLocationsCount: results[2],
        activeZonesCount: results[3],
        branchOfficesCount: results[4],
      );
    } catch (e) {
      debugPrint('[ServiceGeoLocations] fetchKpiCounts error: $e');
      return const GeoTerritoryKpiCounts();
    }
  }

  /// Server-paginated search across villages, towns, talukas, districts & pincodes.
  Future<GeoLocationsPageResult> searchLocationsPage({
    String? searchQuery,
    String? zoneCode,
    GeoFilterMode filterMode = GeoFilterMode.all,
    int offset = 0,
    int limit = 80,
  }) async {
    try {
      dynamic countQ = _applyLocationFilters(
        _db.client.schema('IMMBE2627').from('sb_geo_locations').select('id'),
        searchQuery: searchQuery,
        zoneCode: zoneCode,
        filterMode: filterMode,
      );
      dynamic dataQ = _applyLocationFilters(
        _db.client.schema('IMMBE2627').from('sb_geo_locations').select(),
        searchQuery: searchQuery,
        zoneCode: zoneCode,
        filterMode: filterMode,
      );

      final total = await _execCount(countQ);
      final rows = await dataQ
          .order('master_party_count', ascending: false)
          .order('haste_party_count', ascending: false)
          .order('clean_place_name', ascending: true)
          .range(offset, offset + limit - 1);

      final items = (rows as List<dynamic>)
          .map(
            (j) =>
                GeoLocationModel.fromJson(Map<String, dynamic>.from(j as Map)),
          )
          .toList();

      return GeoLocationsPageResult(
        items: items,
        totalCount: total,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      debugPrint('[ServiceGeoLocations] searchLocationsPage error: $e');
      return GeoLocationsPageResult(
        items: const [],
        totalCount: 0,
        offset: offset,
        limit: limit,
        error: _db.handleDbError(e),
      );
    }
  }

  dynamic _applyLocationFilters(
    dynamic query, {
    String? searchQuery,
    String? zoneCode,
    required GeoFilterMode filterMode,
  }) {
    var q = query;
    if (zoneCode != null && zoneCode.trim().isNotEmpty && zoneCode != 'ALL') {
      q = q.eq('zone_code', zoneCode.trim());
    }
    switch (filterMode) {
      case GeoFilterMode.erpMarkets:
        q = q.eq('is_verified_erp_market', true);
      case GeoFilterMode.hasteTowns:
        q = q.gt('haste_party_count', 0);
      case GeoFilterMode.branchOffices:
        q = q.eq('office_type', 'BO');
      case GeoFilterMode.all:
        break;
    }
    final raw = searchQuery?.trim() ?? '';
    if (raw.isNotEmpty) {
      final safe = raw.replaceAll(RegExp(r'[(),]'), ' ').trim();
      if (safe.isNotEmpty) {
        final upperSafe = safe.toUpperCase();
        q = q.or([
          'place_name.ilike.%$safe%',
          'clean_place_name.ilike.%$safe%',
          'pincode.ilike.$safe%',
          'taluka.ilike.%$safe%',
          'district.ilike.%$safe%',
          'state_name.ilike.%$safe%',
          'legacy_city_aliases.cs.{$upperSafe}',
        ].join(','));
      }
    }
    return q;
  }

  /// Fetches geo-coded locations for rendering pins & spokes on the map canvas.
  Future<List<GeoLocationModel>> fetchMapPins({
    String? zoneCode,
    bool activeMarketsOnly = false,
    int limit = 400,
  }) async {
    try {
      dynamic q = _db.client
          .schema('IMMBE2627')
          .from('sb_geo_locations')
          .select()
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);
      if (zoneCode != null && zoneCode.trim().isNotEmpty && zoneCode != 'ALL') {
        q = q.eq('zone_code', zoneCode.trim());
      }
      if (activeMarketsOnly) {
        q = q.or('master_party_count.gt.0,haste_party_count.gt.0');
      }
      final rows = await q
          .order('master_party_count', ascending: false)
          .order('haste_party_count', ascending: false)
          .limit(limit);
      return (rows as List<dynamic>)
          .map(
            (j) =>
                GeoLocationModel.fromJson(Map<String, dynamic>.from(j as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('[ServiceGeoLocations] fetchMapPins error: $e');
      return const [];
    }
  }

  /// Fetches all sister Branch/Sub Post Offices sharing the same 6-digit [pincode].
  Future<List<GeoLocationModel>> fetchLocationsByPincode(String pincode) async {
    final pin = pincode.trim();
    if (pin.length < 6) return const [];
    try {
      final rows = await _db.client
          .schema('IMMBE2627')
          .from('sb_geo_locations')
          .select()
          .eq('pincode', pin)
          .order('office_type', ascending: true)
          .order('place_name', ascending: true);
      return (rows as List<dynamic>)
          .map(
            (j) =>
                GeoLocationModel.fromJson(Map<String, dynamic>.from(j as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('[ServiceGeoLocations] fetchLocationsByPincode error: $e');
      return const [];
    }
  }

  /// Queries free India Post Public Directory API for any 6-digit pincode OR
  /// rural village name, computes coords + Surat distance, and caches to Supabase!
  Future<GeoFetchResult> fetchAndCacheIndiaPostVillages(
    String queryOrPincode,
  ) async {
    final trimmed = queryOrPincode.trim();
    if (trimmed.length < 3) {
      return const GeoFetchResult(
        isSuccess: false,
        count: 0,
        message: 'Enter at least 3 characters or a 6-digit Indian Pincode.',
      );
    }

    try {
      final isPincode = RegExp(r'^[1-9][0-9]{5}$').hasMatch(trimmed);
      final endpoint = isPincode
          ? 'https://api.postalpincode.in/pincode/$trimmed'
          : 'https://api.postalpincode.in/postoffice/${Uri.encodeComponent(trimmed)}';

      final res = await http
          .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        return GeoFetchResult(
          isSuccess: false,
          count: 0,
          message: 'India Post Directory returned HTTP ${res.statusCode}.',
        );
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List || decoded.isEmpty || decoded.first is! Map) {
        return const GeoFetchResult(
          isSuccess: false,
          count: 0,
          message: 'Unexpected response from India Post directory.',
        );
      }

      final firstObj = Map<String, dynamic>.from(decoded.first as Map);
      final status = firstObj['Status']?.toString() ?? '';
      final postOffices = firstObj['PostOffice'] as List<dynamic>? ?? const [];

      if (status != 'Success' || postOffices.isEmpty) {
        return GeoFetchResult(
          isSuccess: false,
          count: 0,
          message:
              'No villages/post offices found in India Post directory for "$trimmed".',
        );
      }

      final List<Map<String, dynamic>> batchRows = [];
      for (final rawPo in postOffices) {
        if (rawPo is! Map) continue;
        final po = Map<String, dynamic>.from(rawPo);
        final name = po['Name']?.toString().trim() ?? '';
        final pin = po['Pincode']?.toString().trim() ?? '';
        if (name.isEmpty || pin.length != 6) continue;

        final branchType = po['BranchType']?.toString().trim() ?? '';
        final officeType = branchType.toUpperCase().contains('B.O') ||
                branchType.toUpperCase().contains('BRANCH')
            ? 'BO'
            : (branchType.toUpperCase().contains('H.O') ||
                    branchType.toUpperCase().contains('HEAD')
                ? 'HO'
                : 'SO');
        final stateRaw = po['State']?.toString().trim().toUpperCase() ?? 'INDIA';
        final district = po['District']?.toString().trim() ?? '';
        final block = po['Block']?.toString().trim();
        final taluka = (block != null && block != 'NA' && block.isNotEmpty)
            ? block
            : district;
        final coord = _estimateIndianCoords(pin: pin, seedName: '$name:$district');
        final distKm = _haversineRoadKm(coord.lat, coord.lng);
        final gstState = _gstStateCodeFor(stateRaw, pin);
        final zoneCode = _inferZoneCode(pin: pin, stateName: stateRaw);

        batchRows.add({
          'location_key': 'PIN:$pin:${name.toUpperCase()}',
          'pincode': pin,
          'place_name': name,
          'clean_place_name': name.toUpperCase(),
          'office_type': officeType,
          'delivery_status': po['DeliveryStatus']?.toString().trim(),
          'taluka': taluka,
          'district': district,
          'division_name': po['Division']?.toString().trim(),
          'region_name': po['Region']?.toString().trim(),
          'circle_name': po['Circle']?.toString().trim(),
          'state_name': stateRaw,
          'gst_state_code': gstState,
          'latitude': coord.lat.toStringAsFixed(6),
          'longitude': coord.lng.toStringAsFixed(6),
          'distance_from_surat_km': distKm.toString(),
          'zone_code': zoneCode,
          'legacy_city_aliases': [name.toUpperCase()],
          'source_type': 'INDIA_POST_API',
          'is_verified_erp_market': false,
        });
      }

      if (batchRows.isEmpty) {
        return const GeoFetchResult(
          isSuccess: false,
          count: 0,
          message: 'No valid 6-digit Indian pincodes in response.',
        );
      }

      final rpcRes = await _db.client.schema('IMMBE2627').rpc(
        'fn_upsert_geo_locations_batch',
        params: {'p_rows': batchRows},
      );

      final upserted = (rpcRes is Map && rpcRes['upserted'] is num)
          ? (rpcRes['upserted'] as num).toInt()
          : batchRows.length;

      return GeoFetchResult(
        isSuccess: true,
        count: upserted,
        message:
            'Cached $upserted India Post villages/post offices for "$trimmed"!',
      );
    } catch (e) {
      debugPrint('[ServiceGeoLocations] fetchAndCacheIndiaPostVillages: $e');
      return GeoFetchResult(
        isSuccess: false,
        count: 0,
        message: 'India Post lookup failed: $e',
      );
    }
  }

  /// Queries live `sq_MASTER` and `sq_HASTE` parties residing in [loc].
  Future<List<GeoVillagePartyEntry>> fetchPartiesForLocation(
    GeoLocationModel loc,
  ) async {
    final terms = <String>{
      loc.cleanPlaceName.toUpperCase(),
      loc.placeName.toUpperCase(),
      ...loc.legacyCityAliases.map((e) => e.toUpperCase()),
    }.where((s) => s.isNotEmpty).toList();

    if (terms.isEmpty && (loc.pincode == null || loc.pincode!.isEmpty)) {
      return const [];
    }

    try {
      final List<GeoVillagePartyEntry> combined = [];

      // 1. Live sq_MASTER rows matching CITY1 or PINNO
      dynamic masterQ = _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('code,NAME,ATYPE,CITY1,STATION,ADATIYA,TRANSPORT,PINNO,MOBILE,GSTIN');

      if (terms.isNotEmpty) {
        masterQ = masterQ.inFilter('CITY1', terms);
      } else if (loc.pincode != null && loc.pincode!.isNotEmpty) {
        masterQ = masterQ.eq('PINNO', loc.pincode!);
      }
      var masterRows = await masterQ.order('NAME', ascending: true).limit(60);

      if ((masterRows as List<dynamic>).isEmpty &&
          loc.pincode != null &&
          loc.pincode!.isNotEmpty) {
        masterRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_MASTER')
            .select('code,NAME,ATYPE,CITY1,STATION,ADATIYA,TRANSPORT,PINNO,MOBILE,GSTIN')
            .eq('PINNO', loc.pincode!)
            .order('NAME', ascending: true)
            .limit(40);
      }

      for (final r in masterRows) {
        combined.add(GeoVillagePartyEntry(
          entityKind: 'MASTER',
          name: r['NAME']?.toString().trim() ?? '',
          code: r['code']?.toString().trim() ?? '',
          atype: r['ATYPE'] is num ? (r['ATYPE'] as num).toInt() : 1,
          cityOrPlace: r['CITY1']?.toString().trim() ?? '',
          station: r['STATION']?.toString().trim() ?? '',
          adatiya: r['ADATIYA']?.toString().trim() ?? 'SELF',
          transport: r['TRANSPORT']?.toString().trim() ?? '',
          pincode: r['PINNO']?.toString().trim() ?? '',
          mobile: r['MOBILE']?.toString().trim() ?? '',
          gstin: r['GSTIN']?.toString().trim() ?? '',
        ));
      }

      // 2. Live sq_HASTE rows matching PLACE
      if (terms.isNotEmpty) {
        final hasteRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_HASTE')
            .select('HASTE,ADATIYA,PLACE,TRANSPORT,PINNO,MOBILE')
            .inFilter('PLACE', terms)
            .order('HASTE', ascending: true)
            .limit(60);
        for (final h in (hasteRows as List<dynamic>)) {
          final hasteName = h['HASTE']?.toString().trim() ?? '';
          combined.add(GeoVillagePartyEntry(
            entityKind: 'HASTE',
            name: hasteName,
            code: 'HST:$hasteName',
            atype: 1,
            cityOrPlace: h['PLACE']?.toString().trim() ?? '',
            station: loc.nearestStation ?? '',
            adatiya: h['ADATIYA']?.toString().trim() ?? '',
            transport: h['TRANSPORT']?.toString().trim() ?? '',
            pincode: h['PINNO']?.toString().trim() ?? '',
            mobile: h['MOBILE']?.toString().trim() ?? '',
          ));
        }
      }

      return combined;
    } catch (e) {
      debugPrint('[ServiceGeoLocations] fetchPartiesForLocation error: $e');
      return const [];
    }
  }

  /// Assigns a village/city row to a different Sales Zone and refreshes counts.
  Future<bool> assignLocationToZone({
    required String locationId,
    required GeoZoneModel zone,
  }) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_geo_locations')
          .update({
            'zone_id': zone.id,
            'zone_code': zone.zoneCode,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', locationId);
      await _db.client
          .schema('IMMBE2627')
          .rpc('fn_refresh_geo_zone_stats');
      return true;
    } catch (e) {
      debugPrint('[ServiceGeoLocations] assignLocationToZone error: $e');
      return false;
    }
  }

  /// Saves edits to an existing location or inserts a new custom village/hub.
  Future<GeoFetchResult> upsertCustomLocation({
    String? existingId,
    required String placeName,
    String? pincode,
    String officeType = 'SO',
    String? taluka,
    String? district,
    required String stateName,
    required String zoneCode,
    String? nearestStation,
    String? defaultTransport,
    int? distanceKm,
    double? lat,
    double? lng,
  }) async {
    final clean = placeName.trim().toUpperCase();
    final pin = pincode?.trim() ?? '';
    final coord = (lat != null && lng != null)
        ? GeoCoord(lat: lat, lng: lng)
        : _estimateIndianCoords(
            pin: pin.isNotEmpty ? pin : '431001',
            seedName: clean,
          );
    final roadDist = distanceKm ?? _haversineRoadKm(coord.lat, coord.lng);
    final gstState = _gstStateCodeFor(stateName.toUpperCase(), pin);

    try {
      if (existingId != null && existingId.isNotEmpty) {
        final zoneRows = await _db.client
            .schema('IMMBE2627')
            .from('sb_geo_zones')
            .select('id')
            .eq('zone_code', zoneCode)
            .limit(1);
        final zoneList = zoneRows as List<dynamic>;
        final zId = zoneList.isNotEmpty ? zoneList.first['id']?.toString() : null;

        await _db.client
            .schema('IMMBE2627')
            .from('sb_geo_locations')
            .update({
              'place_name': placeName.trim(),
              'clean_place_name': clean,
              if (pin.isNotEmpty) 'pincode': pin,
              'office_type': officeType,
              'taluka': taluka?.trim(),
              'district': district?.trim(),
              'state_name': stateName.trim().toUpperCase(),
              'gst_state_code': gstState,
              'nearest_station': nearestStation?.trim().toUpperCase(),
              'default_transport': defaultTransport?.trim().toUpperCase(),
              'distance_from_surat_km': roadDist,
              'latitude': coord.lat,
              'longitude': coord.lng,
              if (zId != null) 'zone_id': zId,
              'zone_code': zoneCode,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', existingId);
        await _db.client
            .schema('IMMBE2627')
            .rpc('fn_refresh_geo_zone_stats');
        return GeoFetchResult(
          isSuccess: true,
          count: 1,
          message: 'Updated "$placeName" geo telemetry.',
        );
      }

      final key = pin.isNotEmpty ? 'PIN:$pin:$clean' : 'CUSTOM:$clean';
      await _db.client.schema('IMMBE2627').rpc(
        'fn_upsert_geo_locations_batch',
        params: {
          'p_rows': [
            {
              'location_key': key,
              if (pin.isNotEmpty) 'pincode': pin,
              'place_name': placeName.trim(),
              'clean_place_name': clean,
              'office_type': officeType,
              if (taluka != null && taluka.isNotEmpty) 'taluka': taluka.trim(),
              if (district != null && district.isNotEmpty)
                'district': district.trim(),
              'state_name': stateName.trim().toUpperCase(),
              'gst_state_code': gstState,
              'latitude': coord.lat.toStringAsFixed(6),
              'longitude': coord.lng.toStringAsFixed(6),
              'distance_from_surat_km': roadDist.toString(),
              if (nearestStation != null && nearestStation.isNotEmpty)
                'nearest_station': nearestStation.trim().toUpperCase(),
              if (defaultTransport != null && defaultTransport.isNotEmpty)
                'default_transport': defaultTransport.trim().toUpperCase(),
              'zone_code': zoneCode,
              'legacy_city_aliases': [clean],
              'source_type': 'ERP_CUSTOM',
              'is_verified_erp_market': true,
            }
          ]
        },
      );
      return GeoFetchResult(
        isSuccess: true,
        count: 1,
        message: 'Saved custom village/market "$placeName".',
      );
    } catch (e) {
      debugPrint('[ServiceGeoLocations] upsertCustomLocation error: $e');
      return GeoFetchResult(
        isSuccess: false,
        count: 0,
        message: 'Failed to save location: $e',
      );
    }
  }

  static int _haversineRoadKm(double lat, double lng) {
    const double r = 6371.0;
    final dLat = _deg2Rad(lat - _suratLat);
    final dLng = _deg2Rad(lng - _suratLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2Rad(_suratLat)) *
            math.cos(_deg2Rad(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final straight = r * c;
    return math.max(12, (straight * 1.28).round());
  }

  static double _deg2Rad(double deg) => deg * (math.pi / 180.0);

  static GeoCoord _estimateIndianCoords({
    required String pin,
    required String seedName,
  }) {
    final prefix2 = pin.length >= 2 ? pin.substring(0, 2) : '43';
    final base = _prefixCentroids[prefix2] ?? const GeoCoord(lat: 19.35, lng: 76.25);
    final h1 = seedName.codeUnits.fold<int>(17, (a, b) => (a * 31 + b) & 0xFFFF);
    final h2 = pin.codeUnits.fold<int>(29, (a, b) => (a * 37 + b) & 0xFFFF);
    final dLat = ((h1 % 80) - 40) / 100.0;
    final dLng = ((h2 % 80) - 40) / 100.0;
    return GeoCoord(lat: base.lat + dLat, lng: base.lng + dLng);
  }

  static String _gstStateCodeFor(String upperState, String pin) {
    if (upperState.contains('GUJARAT')) return '24';
    if (upperState.contains('MAHARASHTRA')) return '27';
    if (upperState.contains('CHHATTISGARH')) return '22';
    if (upperState.contains('MADHYA')) return '23';
    if (upperState.contains('KARNATAKA')) return '29';
    if (upperState.contains('TELANGANA')) return '36';
    if (upperState.contains('ANDHRA')) return '37';
    if (upperState.contains('JHARKHAND')) return '20';
    if (upperState.contains('BIHAR')) return '10';
    if (upperState.contains('RAJASTHAN')) return '08';
    if (upperState.contains('DELHI')) return '07';
    if (upperState.contains('UTTAR PRADESH')) return '09';
    if (upperState.contains('TAMIL')) return '33';
    if (upperState.contains('BENGAL')) return '19';
    if (upperState.contains('ODISHA')) return '21';
    if (pin.startsWith('39') || pin.startsWith('38') || pin.startsWith('36')) {
      return '24';
    }
    if (pin.startsWith('49')) return '22';
    if (pin.startsWith('58') || pin.startsWith('59') || pin.startsWith('56')) {
      return '29';
    }
    return '27';
  }

  static String _inferZoneCode({
    required String pin,
    required String stateName,
  }) {
    if (pin.startsWith('395')) return 'GJ-SURAT-LOCAL';
    if (stateName.contains('GUJARAT')) return 'GJ-REST-OF-GUJARAT';
    if (pin.startsWith('431')) return 'MH-MARATHWADA-CORE';
    if (pin.startsWith('411') ||
        pin.startsWith('413') ||
        pin.startsWith('414') ||
        pin.startsWith('416')) {
      return 'MH-SOLAPUR-WESTERN';
    }
    if (pin.startsWith('422') ||
        pin.startsWith('423') ||
        pin.startsWith('424') ||
        pin.startsWith('425')) {
      return 'MH-KHANDESH-NASHIK';
    }
    if (pin.startsWith('44')) return 'MH-VIDARBHA';
    if (pin.startsWith('400') || pin.startsWith('401') || pin.startsWith('421')) {
      return 'MH-MUMBAI-KONKAN';
    }
    if (stateName.contains('KARNATAKA')) return 'KA-NORTH-SOUTH';
    if (stateName.contains('CHHATTISGARH')) return 'CG-CHHATTISGARH';
    if (stateName.contains('MADHYA')) return 'MP-CENTRAL-MALWA';
    if (stateName.contains('TELANGANA') ||
        stateName.contains('ANDHRA') ||
        stateName.contains('TAMIL')) {
      return 'SOUTH-AP-TS-TN';
    }
    if (stateName.contains('JHARKHAND') ||
        stateName.contains('BIHAR') ||
        stateName.contains('BENGAL') ||
        stateName.contains('ODISHA')) {
      return 'EAST-JH-BR-OD-WB';
    }
    if (stateName.contains('RAJASTHAN') ||
        stateName.contains('DELHI') ||
        stateName.contains('UTTAR') ||
        stateName.contains('HARYANA') ||
        stateName.contains('PUNJAB')) {
      return 'NORTH-RJ-DL-UP';
    }
    return 'MH-MARATHWADA-CORE';
  }

  static const Map<String, GeoCoord> _prefixCentroids = {
    '11': GeoCoord(lat: 28.6139, lng: 77.2090),
    '12': GeoCoord(lat: 28.9000, lng: 76.6000),
    '14': GeoCoord(lat: 31.1000, lng: 75.5000),
    '20': GeoCoord(lat: 28.3500, lng: 77.8000),
    '22': GeoCoord(lat: 26.8500, lng: 80.9500),
    '28': GeoCoord(lat: 27.1800, lng: 78.0200),
    '30': GeoCoord(lat: 26.9124, lng: 75.7873),
    '31': GeoCoord(lat: 24.5854, lng: 73.7125),
    '34': GeoCoord(lat: 26.2389, lng: 73.0243),
    '36': GeoCoord(lat: 22.3039, lng: 70.8022),
    '38': GeoCoord(lat: 23.0225, lng: 72.5714),
    '39': GeoCoord(lat: 21.1702, lng: 72.8311),
    '40': GeoCoord(lat: 19.0760, lng: 72.8777),
    '41': GeoCoord(lat: 18.2500, lng: 75.2000),
    '42': GeoCoord(lat: 20.4000, lng: 74.5500),
    '43': GeoCoord(lat: 19.2500, lng: 76.3500),
    '44': GeoCoord(lat: 20.8500, lng: 78.1000),
    '45': GeoCoord(lat: 22.7196, lng: 75.8577),
    '46': GeoCoord(lat: 23.2599, lng: 77.4126),
    '49': GeoCoord(lat: 21.7500, lng: 82.1000),
    '50': GeoCoord(lat: 17.6500, lng: 78.8000),
    '56': GeoCoord(lat: 12.9716, lng: 77.5946),
    '58': GeoCoord(lat: 16.8500, lng: 76.7000),
    '59': GeoCoord(lat: 15.8497, lng: 74.4977),
    '60': GeoCoord(lat: 12.8000, lng: 79.9500),
    '70': GeoCoord(lat: 22.5726, lng: 88.3639),
    '75': GeoCoord(lat: 20.2961, lng: 85.8245),
    '80': GeoCoord(lat: 25.5941, lng: 85.1376),
    '83': GeoCoord(lat: 23.3441, lng: 85.3096),
    '84': GeoCoord(lat: 26.1200, lng: 85.3900),
  };
}
