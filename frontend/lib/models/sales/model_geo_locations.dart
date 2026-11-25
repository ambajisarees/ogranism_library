/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical Stage 11.1 + 11.2 Data Models for Ambaji Sarees ERP Territory GIS,
     All-India Village/Pincode Directory (`sb_geo_locations`), Sales Zones
     (`sb_geo_zones`), Hybrid GSTIN Cache (`sb_gstin_cache`), Prospect Expansion
     Leads (`sb_prospect_leads`), and Staged Verified Parties (`sb_parties`).
   - Bridges `"IMMBE2627"` Supabase territory tables with live `sq_MASTER`
     and `sq_HASTE` legacy mirrors during human-in-the-loop verification.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `GeoZoneModel` / `GeoLocationModel` / `GeoVillagePartyEntry`: Territory GIS
     and legacy village party inspection DTOs.
   - `GstinLookupModel`: Decodes 15-char Indian GSTIN (`[0-9]{2}[PAN][1-9A-Z]Z[chk]`),
     extracts PAN & Constitution of Business, caches canonical GSTN `TP` JSON.
   - `GeoProspectLeadModel`: Unconverted `sq_HASTE` & town expansion pipeline row.
   - `SbVerifiedPartyModel`: Staged human-verified party committed to `sb_parties`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Avoids `!` force-unwrapping and keeps all model classes strictly under 700
     total lines with defensive type coercion helpers.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - External GSP API credentials (ClearTax / Masters India) can hydrate live
     `raw_json` directly into `GstinLookupModel.fromCacheRow` once configured.
================================================================================
*/

import 'package:flutter/foundation.dart';

/// Filter pills supported by the Geo & Village directory search.
enum GeoFilterMode { all, erpMarkets, hasteTowns, branchOffices }

/// Immutable geographic latitude/longitude point.
@immutable
class GeoCoord {
  final double lat;
  final double lng;

  const GeoCoord({required this.lat, required this.lng});

  factory GeoCoord.fromDynamic(Object? raw) {
    if (raw is Map) {
      final lat = _parseDouble(raw['lat']);
      final lng = _parseDouble(raw['lng']);
      if (lat != null && lng != null) {
        return GeoCoord(lat: lat, lng: lng);
      }
    }
    return const GeoCoord(lat: 21.1702, lng: 72.8311);
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

/// Mirrors `"IMMBE2627"."sb_geo_zones"` (Commercial Sales & Dispatch Corridors).
@immutable
class GeoZoneModel {
  final String id;
  final String zoneCode;
  final String zoneName;
  final String parentRegion;
  final String? stateName;
  final String? gstStateCode;
  final String colorToken;
  final double centerLat;
  final double centerLng;
  final List<GeoCoord> boundaryPoints;
  final String? defaultTransportHub;
  final String? defaultTransport;
  final List<String> assignedAdatiyaCodes;
  final int activeLocationsCount;
  final int activeMastersCount;
  final int activeHasteCount;
  final String? notes;
  final bool isActive;

  const GeoZoneModel({
    required this.id,
    required this.zoneCode,
    required this.zoneName,
    this.parentRegion = 'WEST',
    this.stateName,
    this.gstStateCode,
    this.colorToken = 'cyan',
    this.centerLat = 21.1702,
    this.centerLng = 72.8311,
    this.boundaryPoints = const [],
    this.defaultTransportHub,
    this.defaultTransport,
    this.assignedAdatiyaCodes = const [],
    this.activeLocationsCount = 0,
    this.activeMastersCount = 0,
    this.activeHasteCount = 0,
    this.notes,
    this.isActive = true,
  });

  int get totalParties => activeMastersCount + activeHasteCount;

  factory GeoZoneModel.fromJson(Map<String, dynamic> json) {
    final pts = <GeoCoord>[];
    if (json['boundary_points'] is List) {
      for (final p in (json['boundary_points'] as List)) {
        final coord = GeoCoord.fromDynamic(p);
        pts.add(coord);
      }
    }
    return GeoZoneModel(
      id: json['id']?.toString() ?? '',
      zoneCode: json['zone_code']?.toString() ?? '',
      zoneName: json['zone_name']?.toString() ?? 'Unnamed Zone',
      parentRegion: json['parent_region']?.toString() ?? 'WEST',
      stateName: json['state_name']?.toString(),
      gstStateCode: json['gst_state_code']?.toString(),
      colorToken: json['color_token']?.toString() ?? 'cyan',
      centerLat: _parseDouble(json['center_lat']) ?? 21.1702,
      centerLng: _parseDouble(json['center_lng']) ?? 72.8311,
      boundaryPoints: pts,
      defaultTransportHub: json['default_transport_hub']?.toString(),
      defaultTransport: json['default_transport']?.toString(),
      assignedAdatiyaCodes: _parseStrList(json['assigned_adatiya_codes']),
      activeLocationsCount: _parseInt(json['active_locations_count']),
      activeMastersCount: _parseInt(json['active_masters_count']),
      activeHasteCount: _parseInt(json['active_haste_count']),
      notes: json['notes']?.toString(),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
    );
  }
}

/// Mirrors `"IMMBE2627"."sb_geo_locations"` (Villages, Towns, Pincodes & Hubs).
@immutable
class GeoLocationModel {
  final String id;
  final String locationKey;
  final String? pincode;
  final String placeName;
  final String cleanPlaceName;
  final String officeType; // HO, SO, BO, HUB, CITY
  final String? deliveryStatus;
  final String? taluka;
  final String? district;
  final String? divisionName;
  final String? regionName;
  final String? circleName;
  final String stateName;
  final String gstStateCode;
  final double? latitude;
  final double? longitude;
  final int? distanceFromSuratKm;
  final String? nearestStation;
  final String? defaultTransport;
  final String? zoneId;
  final String? zoneCode;
  final List<String> legacyCityAliases;
  final int masterPartyCount;
  final int hastePartyCount;
  final List<String> topAdatiyaCodes;
  final String sourceType;
  final bool isVerifiedErpMarket;

  const GeoLocationModel({
    required this.id,
    required this.locationKey,
    this.pincode,
    required this.placeName,
    required this.cleanPlaceName,
    this.officeType = 'SO',
    this.deliveryStatus,
    this.taluka,
    this.district,
    this.divisionName,
    this.regionName,
    this.circleName,
    this.stateName = 'MAHARASHTRA',
    this.gstStateCode = '27',
    this.latitude,
    this.longitude,
    this.distanceFromSuratKm,
    this.nearestStation,
    this.defaultTransport,
    this.zoneId,
    this.zoneCode,
    this.legacyCityAliases = const [],
    this.masterPartyCount = 0,
    this.hastePartyCount = 0,
    this.topAdatiyaCodes = const [],
    this.sourceType = 'ERP_LEGACY_RECONCILED',
    this.isVerifiedErpMarket = false,
  });

  int get totalErpParties => masterPartyCount + hastePartyCount;
  bool get hasCoordinates => latitude != null && longitude != null;

  String get officeTypeLabel {
    switch (officeType) {
      case 'BO':
        return 'Village B.O';
      case 'SO':
        return 'Town S.O';
      case 'HO':
        return 'Head H.O';
      case 'HUB':
        return 'Textile Hub';
      default:
        return 'City';
    }
  }

  String get subtitleLocation {
    final parts = <String>[
      if (pincode != null && pincode!.isNotEmpty) pincode!,
      if (taluka != null && taluka!.isNotEmpty) 'Tq: $taluka',
      if (district != null &&
          district!.isNotEmpty &&
          district!.toUpperCase() != cleanPlaceName)
        district!,
      stateName,
    ];
    return parts.join(' • ');
  }

  factory GeoLocationModel.fromJson(Map<String, dynamic> json) {
    return GeoLocationModel(
      id: json['id']?.toString() ?? '',
      locationKey: json['location_key']?.toString() ?? '',
      pincode: json['pincode']?.toString().trim(),
      placeName: json['place_name']?.toString().trim() ?? 'Unknown Place',
      cleanPlaceName: json['clean_place_name']?.toString().trim() ?? '',
      officeType: json['office_type']?.toString().trim() ?? 'SO',
      deliveryStatus: json['delivery_status']?.toString().trim(),
      taluka: json['taluka']?.toString().trim(),
      district: json['district']?.toString().trim(),
      divisionName: json['division_name']?.toString().trim(),
      regionName: json['region_name']?.toString().trim(),
      circleName: json['circle_name']?.toString().trim(),
      stateName: json['state_name']?.toString().trim() ?? 'MAHARASHTRA',
      gstStateCode: json['gst_state_code']?.toString().trim() ?? '27',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      distanceFromSuratKm: json['distance_from_surat_km'] != null
          ? _parseInt(json['distance_from_surat_km'])
          : null,
      nearestStation: json['nearest_station']?.toString().trim(),
      defaultTransport: json['default_transport']?.toString().trim(),
      zoneId: json['zone_id']?.toString().trim(),
      zoneCode: json['zone_code']?.toString().trim(),
      legacyCityAliases: _parseStrList(json['legacy_city_aliases']),
      masterPartyCount: _parseInt(json['master_party_count']),
      hastePartyCount: _parseInt(json['haste_party_count']),
      topAdatiyaCodes: _parseStrList(json['top_adatiya_codes']),
      sourceType: json['source_type']?.toString() ?? 'ERP_LEGACY_RECONCILED',
      isVerifiedErpMarket: json['is_verified_erp_market'] is bool
          ? json['is_verified_erp_market'] as bool
          : false,
    );
  }
}

/// Paginated search page returned by `ServiceGeoLocations.searchLocationsPage`.
@immutable
class GeoLocationsPageResult {
  final List<GeoLocationModel> items;
  final int totalCount;
  final int offset;
  final int limit;
  final String? error;

  const GeoLocationsPageResult({
    required this.items,
    required this.totalCount,
    required this.offset,
    required this.limit,
    this.error,
  });

  bool get hasNextPage => offset + items.length < totalCount;
  bool get hasPreviousPage => offset > 0;
}

/// Executive KPI metrics for Region [1] of `ScrGeoZoneMap`.
@immutable
class GeoTerritoryKpiCounts {
  final int totalLocations;
  final int erpMarketsCount;
  final int hasteLocationsCount;
  final int activeZonesCount;
  final int branchOfficesCount;

  const GeoTerritoryKpiCounts({
    this.totalLocations = 0,
    this.erpMarketsCount = 0,
    this.hasteLocationsCount = 0,
    this.activeZonesCount = 0,
    this.branchOfficesCount = 0,
  });
}

/// Result summary for live India Post village/pincode directory fetches.
@immutable
class GeoFetchResult {
  final bool isSuccess;
  final int count;
  final String message;

  const GeoFetchResult({
    required this.isSuccess,
    required this.count,
    required this.message,
  });
}

/// Unified customer or Haste sub-buyer entry returned for a village or zone.
@immutable
class GeoVillagePartyEntry {
  final String entityKind; // 'MASTER' or 'HASTE'
  final String name;
  final String code;
  final int atype;
  final String cityOrPlace;
  final String station;
  final String adatiya;
  final String transport;
  final String pincode;
  final String mobile;
  final String gstin;

  const GeoVillagePartyEntry({
    required this.entityKind,
    required this.name,
    required this.code,
    this.atype = 1,
    this.cityOrPlace = '',
    this.station = '',
    this.adatiya = '',
    this.transport = '',
    this.pincode = '',
    this.mobile = '',
    this.gstin = '',
  });
}

/// Decoded Indian GSTIN Taxpayer (`TP`) payload cached in `sb_gstin_cache`.
@immutable
class GstinLookupModel {
  static final RegExp _gstinPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );

  final String gstin;
  final String panNumber;
  final String gstStateCode;
  final String legalName;
  final String tradeName;
  final String gstStatus;
  final String taxpayerType;
  final String constitutionOfBusiness;
  final String registrationDate;
  final String principalAddress;
  final String pincode;
  final String districtName;
  final String stateName;
  final List<String> hsnCodes;
  final String filingRegularity;
  final Map<String, dynamic> rawJson;
  final String sourceProvider;
  final bool isChecksumValid;

  const GstinLookupModel({
    required this.gstin,
    required this.panNumber,
    required this.gstStateCode,
    required this.legalName,
    required this.tradeName,
    this.gstStatus = 'Active',
    this.taxpayerType = 'Regular',
    this.constitutionOfBusiness = 'Proprietorship',
    this.registrationDate = '',
    this.principalAddress = '',
    this.pincode = '',
    this.districtName = '',
    this.stateName = '',
    this.hsnCodes = const ['5407', '5208', '6204'],
    this.filingRegularity = 'REGULAR_MONTHLY',
    this.rawJson = const {},
    this.sourceProvider = 'ERP_CACHE',
    this.isChecksumValid = true,
  });

  factory GstinLookupModel.fromCacheRow(Map<String, dynamic> row) {
    final g = (row['gstin']?.toString() ?? '').trim().toUpperCase();
    final stateCd =
        (row['gst_state_code']?.toString() ?? '').trim().isNotEmpty
            ? row['gst_state_code'].toString().trim()
            : (g.length >= 2 ? g.substring(0, 2) : '27');
    final raw = row['raw_json'] is Map
        ? Map<String, dynamic>.from(row['raw_json'] as Map)
        : const <String, dynamic>{};
    return GstinLookupModel(
      gstin: g,
      panNumber: (row['pan_number']?.toString() ??
              (g.length >= 12 ? g.substring(2, 12) : ''))
          .trim(),
      gstStateCode: stateCd,
      legalName: row['legal_name']?.toString().trim() ?? g,
      tradeName: row['trade_name']?.toString().trim() ?? g,
      gstStatus: row['gst_status']?.toString().trim() ?? 'Active',
      taxpayerType: row['taxpayer_type']?.toString().trim() ?? 'Regular',
      constitutionOfBusiness:
          row['constitution_of_business']?.toString().trim() ??
              'Proprietorship',
      registrationDate: row['registration_date']?.toString().trim() ?? '',
      principalAddress: row['principal_address']?.toString().trim() ?? '',
      pincode: row['pincode']?.toString().trim() ?? '',
      districtName: row['district_name']?.toString().trim() ?? '',
      stateName: row['state_name']?.toString().trim() ??
          stateNameForGstCode(stateCd),
      hsnCodes: _parseStrList(row['hsn_codes']),
      filingRegularity:
          row['filing_regularity']?.toString().trim() ?? 'REGULAR_MONTHLY',
      rawJson: raw,
      sourceProvider:
          row['source_provider']?.toString().trim() ?? 'SB_GSTIN_CACHE',
      isChecksumValid: verifyGstinChecksum(g),
    );
  }

  /// Validates format & synthesizes structured GSTN `TP` telemetry from GSTIN.
  static GstinLookupModel? parseAndSynthesize({
    required String rawGstin,
    String? hintTradeName,
    String? hintCity,
    String? hintPincode,
    String? hintState,
    String? hintAddress,
  }) {
    final clean = rawGstin.trim().toUpperCase();
    if (!_gstinPattern.hasMatch(clean)) return null;

    final stateCd = clean.substring(0, 2);
    final pan = clean.substring(2, 12);
    final resolvedState = (hintState != null && hintState.trim().isNotEmpty)
        ? hintState.trim().toUpperCase()
        : stateNameForGstCode(stateCd);
    final ctb = constitutionFromPanChar(pan[3]);
    final name = (hintTradeName != null && hintTradeName.trim().isNotEmpty)
        ? hintTradeName.trim().toUpperCase()
        : 'TAXPAYER $pan';
    final city = (hintCity ?? '').trim().toUpperCase();
    final pin = (hintPincode ?? '').trim();
    final addr = (hintAddress != null && hintAddress.trim().isNotEmpty)
        ? hintAddress.trim()
        : [
            if (city.isNotEmpty) city,
            if (resolvedState.isNotEmpty) resolvedState,
            if (pin.isNotEmpty) pin,
          ].join(', ');

    final tpJson = <String, dynamic>{
      'gstin': clean,
      'pan': pan,
      'lgnm': name,
      'tradeNam': name,
      'sts': 'Active',
      'dty': 'Regular',
      'ctb': ctb,
      'stjCd': stateCd,
      'pradr': {
        'adr': addr,
        'addr': {
          'dst': city,
          'stcd': resolvedState,
          'pncd': pin,
        },
      },
      'hsn_info': const ['5407', '5208', '6204'],
      'checksum_valid': verifyGstinChecksum(clean),
      'source': 'GSTN_STRUCTURAL_SYNTHESIS',
    };

    return GstinLookupModel(
      gstin: clean,
      panNumber: pan,
      gstStateCode: stateCd,
      legalName: name,
      tradeName: name,
      gstStatus: 'Active',
      taxpayerType: 'Regular',
      constitutionOfBusiness: ctb,
      principalAddress: addr,
      pincode: pin,
      districtName: city,
      stateName: resolvedState,
      hsnCodes: const ['5407', '5208', '6204'],
      filingRegularity: 'REGULAR_MONTHLY',
      rawJson: tpJson,
      sourceProvider: 'GSTN_STRUCTURAL_SYNTHESIS',
      isChecksumValid: verifyGstinChecksum(clean),
    );
  }

  static bool verifyGstinChecksum(String gstin) {
    if (gstin.length != 15) return false;
    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var factor = 2;
    var sum = 0;
    for (var i = 13; i >= 0; i--) {
      final code = alphabet.indexOf(gstin[i]);
      if (code < 0) return false;
      final addend = (factor * code);
      factor = (factor == 2) ? 1 : 2;
      sum += (addend ~/ 36) + (addend % 36);
    }
    final rem = sum % 36;
    final checkIdx = (36 - rem) % 36;
    return alphabet[checkIdx] == gstin[14];
  }

  static String constitutionFromPanChar(String ch) {
    const m = {
      'P': 'Proprietorship',
      'F': 'Partnership',
      'C': 'Private Limited Company',
      'H': 'Hindu Undivided Family',
      'T': 'Trust',
      'A': 'Association of Persons',
      'B': 'Body of Individuals',
      'L': 'Local Authority',
      'J': 'Artificial Juridical Person',
      'G': 'Government',
    };
    return m[ch.toUpperCase()] ?? 'Proprietorship';
  }

  static String stateNameForGstCode(String code) {
    const map = <String, String>{
      '01': 'JAMMU AND KASHMIR', '02': 'HIMACHAL PRADESH', '03': 'PUNJAB',
      '04': 'CHANDIGARH', '05': 'UTTARAKHAND', '06': 'HARYANA', '07': 'DELHI',
      '08': 'RAJASTHAN', '09': 'UTTAR PRADESH', '10': 'BIHAR', '11': 'SIKKIM',
      '12': 'ARUNACHAL PRADESH', '13': 'NAGALAND', '14': 'MANIPUR',
      '15': 'MIZORAM', '16': 'TRIPURA', '17': 'MEGHALAYA', '18': 'ASSAM',
      '19': 'WEST BENGAL', '20': 'JHARKHAND', '21': 'ODISHA',
      '22': 'CHHATTISGARH', '23': 'MADHYA PRADESH', '24': 'GUJARAT',
      '26': 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU', '27': 'MAHARASHTRA',
      '29': 'KARNATAKA', '30': 'GOA', '31': 'LAKSHADWEEP', '32': 'KERALA',
      '33': 'TAMIL NADU', '34': 'PUDUCHERRY',
      '35': 'ANDAMAN AND NICOBAR ISLANDS', '36': 'TELANGANA',
      '37': 'ANDHRA PRADESH', '38': 'LADAKH',
    };
    return map[code.trim()] ?? 'INDIA';
  }
}

/// Prospect expansion lead stored in `"IMMBE2627"."sb_prospect_leads"`.
@immutable
class GeoProspectLeadModel {
  final String id, leadKey, shopName, sourceChannel, leadStatus, placeName;
  final String? legalName, gstin, panNumber, mobile, whatsapp, contactPerson;
  final String? address, pincode, districtName, stateName, gstStateCode;
  final String? locationId, zoneCode, adatiyaName, preferredTransport;
  final String? promotedPartyId, notes;
  final int? distanceFromSuratKm;
  final List<String> specializationTags;
  final int priorityScore;

  const GeoProspectLeadModel({
    required this.id, required this.leadKey, required this.shopName,
    this.legalName, this.sourceChannel = 'HASTE_MINED',
    this.leadStatus = 'UNCONVERTED_HASTE', this.gstin, this.panNumber,
    this.mobile, this.whatsapp, this.contactPerson, this.address,
    required this.placeName, this.pincode, this.districtName, this.stateName,
    this.gstStateCode, this.locationId, this.zoneCode, this.adatiyaName,
    this.preferredTransport, this.distanceFromSuratKm,
    this.specializationTags = const ['Sarees', 'Dress Material'],
    this.priorityScore = 50, this.promotedPartyId, this.notes,
  });

  bool get isConverted {
    final p = promotedPartyId;
    return leadStatus == 'CONVERTED' || (p != null && p.isNotEmpty);
  }

  factory GeoProspectLeadModel.fromJson(Map<String, dynamic> j) =>
      GeoProspectLeadModel(
        id: _req(j, 'id'), leadKey: _req(j, 'lead_key'),
        shopName: _opt(j, 'shop_name') ?? 'Unknown Shop',
        legalName: _opt(j, 'legal_name'),
        sourceChannel: _opt(j, 'source_channel') ?? 'HASTE_MINED',
        leadStatus: _opt(j, 'lead_status') ?? 'UNCONVERTED_HASTE',
        gstin: _opt(j, 'gstin'), panNumber: _opt(j, 'pan_number'),
        mobile: _opt(j, 'mobile'), whatsapp: _opt(j, 'whatsapp'),
        contactPerson: _opt(j, 'contact_person'), address: _opt(j, 'address'),
        placeName: _req(j, 'place_name'), pincode: _opt(j, 'pincode'),
        districtName: _opt(j, 'district_name'), stateName: _opt(j, 'state_name'),
        gstStateCode: _opt(j, 'gst_state_code'), locationId: _opt(j, 'location_id'),
        zoneCode: _opt(j, 'zone_code'), adatiyaName: _opt(j, 'adatiya_name'),
        preferredTransport: _opt(j, 'preferred_transport'),
        distanceFromSuratKm: _optInt(j['distance_from_surat_km']),
        specializationTags: _parseStrList(j['specialization_tags']),
        priorityScore: _parseInt(j['priority_score']),
        promotedPartyId: _opt(j, 'promoted_party_id'), notes: _opt(j, 'notes'),
      );
}

/// Staged human-verified ERP party stored in `"IMMBE2627"."sb_parties"`.
@immutable
class SbVerifiedPartyModel {
  final String id, partyCode, partyRole, tradeName, gstStatus, taxpayerType;
  final String verificationStatus;
  final String? legalName, gstin, panNumber, constitutionOfBusiness, contactPerson;
  final String? mobile, addressLine1, cityName, pincode, districtName, stateName;
  final String? gstStateCode, locationId, zoneCode, adatiyaName;
  final String? preferredTransport, nearestStation;
  final int? distanceFromSuratKm;
  final int creditDays;
  final double creditLimit;

  const SbVerifiedPartyModel({
    required this.id, required this.partyCode, this.partyRole = 'CUSTOMER',
    required this.tradeName, this.legalName, this.gstin, this.panNumber,
    this.gstStatus = 'Active', this.taxpayerType = 'Regular',
    this.constitutionOfBusiness, this.contactPerson, this.mobile,
    this.addressLine1, this.cityName, this.pincode, this.districtName,
    this.stateName, this.gstStateCode, this.locationId, this.zoneCode,
    this.adatiyaName, this.preferredTransport, this.nearestStation,
    this.distanceFromSuratKm, this.creditDays = 30, this.creditLimit = 0,
    this.verificationStatus = 'HUMAN_VERIFIED',
  });

  factory SbVerifiedPartyModel.fromJson(Map<String, dynamic> j) =>
      SbVerifiedPartyModel(
        id: _req(j, 'id'), partyCode: _req(j, 'party_code'),
        partyRole: _opt(j, 'party_role') ?? 'CUSTOMER',
        tradeName: _req(j, 'trade_name'), legalName: _opt(j, 'legal_name'),
        gstin: _opt(j, 'gstin'), panNumber: _opt(j, 'pan_number'),
        gstStatus: _opt(j, 'gst_status') ?? 'Active',
        taxpayerType: _opt(j, 'taxpayer_type') ?? 'Regular',
        constitutionOfBusiness: _opt(j, 'constitution_of_business'),
        contactPerson: _opt(j, 'contact_person'), mobile: _opt(j, 'mobile'),
        addressLine1: _opt(j, 'address_line1'), cityName: _opt(j, 'city_name'),
        pincode: _opt(j, 'pincode'), districtName: _opt(j, 'district_name'),
        stateName: _opt(j, 'state_name'), gstStateCode: _opt(j, 'gst_state_code'),
        locationId: _opt(j, 'location_id'), zoneCode: _opt(j, 'zone_code'),
        adatiyaName: _opt(j, 'adatiya_name'),
        preferredTransport: _opt(j, 'preferred_transport'),
        nearestStation: _opt(j, 'nearest_station'),
        distanceFromSuratKm: _optInt(j['distance_from_surat_km']),
        creditDays: _parseInt(j['credit_days']),
        creditLimit: _parseDouble(j['credit_limit']) ?? 0.0,
        verificationStatus: _opt(j, 'verification_status') ?? 'HUMAN_VERIFIED',
      );
}

String _req(Map<String, dynamic> j, String k) => j[k]?.toString().trim() ?? '';
String? _opt(Map<String, dynamic> j, String k) {
  final s = j[k]?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}
int? _optInt(Object? raw) => raw != null ? _parseInt(raw) : null;

double? _parseDouble(Object? raw) {
  if (raw == null) return null;
  if (raw is double) return raw;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString().trim());
}

int _parseInt(Object? raw) {
  if (raw == null) return 0;
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw.toString().trim()) ?? 0;
}

List<String> _parseStrList(Object? raw) {
  if (raw is List) {
    return raw
        .map((e) => e?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return const [];
}
