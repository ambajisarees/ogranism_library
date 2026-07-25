import 'package:flutter/foundation.dart';

/// Immutable Data Model for a Google Contact entry linked to ERP Master Party (`sq_MASTER`).
@immutable
class GoogleContact {
  final String id;
  final String googleResourceName;
  final String? etag;
  final String? masterCode; // ERP sq_MASTER.code
  final String displayName;
  final String? givenName;
  final String? familyName;
  final String? companyName;
  final String? jobTitle;
  final String? photoUrl;
  final List<String> phoneNumbers;
  final String primaryPhone;
  final List<String> emails;
  final List<dynamic> addresses;
  final List<dynamic> userDefinedFields;
  final List<dynamic> groupMemberships;
  final String? notes;
  final Map<String, dynamic>? rawData; // 100% complete unaltered raw Google People API JSON
  final String syncStatus; // 'synced', 'pending_push', 'pending_pull', 'unlinked'
  final DateTime lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined Master Party fields from `vw_sb_people_linker`
  final String? masterName;
  final String? masterCity;
  final String? masterStation;
  final String? masterMobile;
  final String? masterAdatiya;
  final int? masterCrdays;
  final String? masterFlashRmk;

  const GoogleContact({
    required this.id,
    required this.googleResourceName,
    this.etag,
    this.masterCode,
    required this.displayName,
    this.givenName,
    this.familyName,
    this.companyName,
    this.jobTitle,
    this.photoUrl,
    this.phoneNumbers = const [],
    required this.primaryPhone,
    this.emails = const [],
    this.addresses = const [],
    this.userDefinedFields = const [],
    this.groupMemberships = const [],
    this.notes,
    this.rawData,
    this.syncStatus = 'synced',
    required this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
    this.masterName,
    this.masterCity,
    this.masterStation,
    this.masterMobile,
    this.masterAdatiya,
    this.masterCrdays,
    this.masterFlashRmk,
  });

  bool get isLinked => masterCode != null && masterCode!.isNotEmpty;

  /// Defensive `fromJson` factory handling nulls gracefully.
  factory GoogleContact.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.map((e) {
          if (e is Map && e.containsKey('number')) {
            return e['number']?.toString() ?? '';
          }
          return e?.toString() ?? '';
        }).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    List<dynamic> parseJsonList(dynamic value) {
      if (value is List) return value;
      return const [];
    }

    final phones = parseStringList(json['phone_numbers']);
    final emailsList = parseStringList(json['emails']);
    final rawPrimaryPhone = json['primary_phone']?.toString() ?? '';
    final effectivePrimaryPhone = rawPrimaryPhone.isNotEmpty
        ? rawPrimaryPhone
        : (phones.isNotEmpty ? phones.first : 'N/A');

    return GoogleContact(
      id: json['id']?.toString() ?? '',
      googleResourceName: json['google_resource_name']?.toString() ?? '',
      etag: json['etag']?.toString(),
      masterCode: json['master_code']?.toString(),
      displayName: json['display_name']?.toString() ?? 'Unnamed Contact',
      givenName: json['given_name']?.toString(),
      familyName: json['family_name']?.toString(),
      companyName: json['company_name']?.toString(),
      jobTitle: json['job_title']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      phoneNumbers: phones,
      primaryPhone: effectivePrimaryPhone,
      emails: emailsList,
      addresses: parseJsonList(json['addresses']),
      userDefinedFields: parseJsonList(json['user_defined_fields']),
      groupMemberships: parseJsonList(json['group_memberships']),
      notes: json['notes']?.toString(),
      rawData: json['raw_data'] is Map<String, dynamic>
          ? json['raw_data'] as Map<String, dynamic>
          : null,
      syncStatus: json['sync_status']?.toString() ?? 'synced',
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.tryParse(json['last_synced_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      masterName: json['master_name']?.toString(),
      masterCity: json['master_city']?.toString(),
      masterStation: json['master_station']?.toString(),
      masterMobile: json['master_mobile']?.toString(),
      masterAdatiya: json['master_adatiya']?.toString(),
      masterCrdays: json['master_crdays'] is num
          ? (json['master_crdays'] as num).toInt()
          : null,
      masterFlashRmk: json['master_flash_rmk']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_resource_name': googleResourceName,
      'etag': etag,
      'master_code': masterCode,
      'display_name': displayName,
      'given_name': givenName,
      'family_name': familyName,
      'company_name': companyName,
      'job_title': jobTitle,
      'photo_url': photoUrl,
      'phone_numbers': phoneNumbers,
      'primary_phone': primaryPhone,
      'emails': emails,
      'addresses': addresses,
      'user_defined_fields': userDefinedFields,
      'group_memberships': groupMemberships,
      'notes': notes,
      'raw_data': rawData,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GoogleContact copyWith({
    String? id,
    String? googleResourceName,
    String? etag,
    String? masterCode,
    String? displayName,
    String? givenName,
    String? familyName,
    String? companyName,
    String? jobTitle,
    String? photoUrl,
    List<String>? phoneNumbers,
    String? primaryPhone,
    List<String>? emails,
    List<dynamic>? addresses,
    List<dynamic>? userDefinedFields,
    List<dynamic>? groupMemberships,
    String? notes,
    Map<String, dynamic>? rawData,
    String? syncStatus,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? masterName,
    String? masterCity,
    String? masterStation,
    String? masterMobile,
    String? masterAdatiya,
    int? masterCrdays,
    String? masterFlashRmk,
  }) {
    return GoogleContact(
      id: id ?? this.id,
      googleResourceName: googleResourceName ?? this.googleResourceName,
      etag: etag ?? this.etag,
      masterCode: masterCode ?? this.masterCode,
      displayName: displayName ?? this.displayName,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      emails: emails ?? this.emails,
      addresses: addresses ?? this.addresses,
      userDefinedFields: userDefinedFields ?? this.userDefinedFields,
      groupMemberships: groupMemberships ?? this.groupMemberships,
      notes: notes ?? this.notes,
      rawData: rawData ?? this.rawData,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      masterName: masterName ?? this.masterName,
      masterCity: masterCity ?? this.masterCity,
      masterStation: masterStation ?? this.masterStation,
      masterMobile: masterMobile ?? this.masterMobile,
      masterAdatiya: masterAdatiya ?? this.masterAdatiya,
      masterCrdays: masterCrdays ?? this.masterCrdays,
      masterFlashRmk: masterFlashRmk ?? this.masterFlashRmk,
    );
  }
}

/// Helper model for Master Party lookup selection in UI
class MasterPartyOption {
  final String code;
  final String name;
  final String city;
  final String station;
  final String mobile;

  const MasterPartyOption({
    required this.code,
    required this.name,
    required this.city,
    required this.station,
    required this.mobile,
  });

  factory MasterPartyOption.fromJson(Map<String, dynamic> json) {
    return MasterPartyOption(
      code: json['code']?.toString() ?? '',
      name: json['NAME']?.toString() ?? json['name']?.toString() ?? 'Unknown Party',
      city: json['CITY1']?.toString() ?? json['city']?.toString() ?? '',
      station: json['STATION']?.toString() ?? json['station']?.toString() ?? '',
      mobile: json['MOBILE']?.toString() ?? json['mobile']?.toString() ?? '',
    );
  }
}
