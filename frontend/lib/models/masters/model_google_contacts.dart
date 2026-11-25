/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical Stage 9.1 CRM data models for the 2-table lossless Google Contacts
     mirror in Ambaji Sarees ERP:
       1) `"IMMBE2627"."sb_google_sync_state"` -> `GoogleSyncStateModel`
       2) `"IMMBE2627"."sb_contacts"`          -> `GoogleContact`
   - Supports 7,000+ contacts from `design.ambaji@gmail.com` imported via Google
     People API v1 or Google Contacts CSV exports, while keeping inline M:N
     links to ERP Account Groups (`sq_ACGROUP`) and Parties (`sq_MASTER`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Preserves complete Google People API `Person` sub-resources (`phone_numbers`
     as full `{value, canonicalForm, type, formattedType}` maps, `email_addresses`,
     `organizations`, `addresses`, `biographies`, `relations`, `events`,
     `birthdays`, `urls`, `memberships`, `user_defined`, `client_data`, `raw_person`)
     never flattening arrays into bare strings.
   - `phone_norms` stores normalized 10-digit Indian / E.164 digit strings indexed
     via PostgreSQL GIN for <0.5ms call-log / WhatsApp caller resolution.
   - `linked_group_codes`, `linked_master_codes`, and `erp_links` store M:N ERP
     associations inline so one contact owner can belong to multiple textile firms
     without separate child junction tables.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_contacts` rows fetched in paginated table views omit heavy `raw_person`
     JSONB payloads by default (`rawPerson` may be empty unless loaded on demand).
   - `sq_MASTER` and `sq_ACGROUP` remain strictly read-only Airbyte mirrors; no FK
     constraints exist between `sb_contacts` and `sq_*` tables.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Auto-matching (`linked_master_codes` / `linked_group_codes` batch suggestions)
     is deferred to the next sub-stage; manual link/unlink stays functional here.
================================================================================
*/

import 'package:flutter/foundation.dart';

/// Typed representation of a Google People API v1 `phoneNumbers` entry.
@immutable
class GooglePhoneEntry {
  final String value;
  final String canonicalForm;
  final String type;
  final String formattedType;

  const GooglePhoneEntry({
    required this.value,
    this.canonicalForm = '',
    this.type = 'mobile',
    this.formattedType = '',
  });

  String get displayLabel => formattedType.isNotEmpty
      ? formattedType
      : (type.isNotEmpty ? type : 'Phone');

  String get preferredNumber =>
      canonicalForm.isNotEmpty ? canonicalForm : value;

  factory GooglePhoneEntry.fromDynamic(Object? raw) {
    if (raw is Map) {
      final value = raw['value']?.toString().trim() ??
          raw['number']?.toString().trim() ??
          '';
      final canonical = raw['canonicalForm']?.toString().trim() ??
          raw['canonical']?.toString().trim() ??
          '';
      final type = raw['type']?.toString().trim() ?? 'mobile';
      final formatted = raw['formattedType']?.toString().trim() ?? '';
      return GooglePhoneEntry(
        value: value.isNotEmpty ? value : canonical,
        canonicalForm: canonical,
        type: type.isNotEmpty ? type : 'mobile',
        formattedType: formatted,
      );
    }
    final str = raw?.toString().trim() ?? '';
    return GooglePhoneEntry(value: str, canonicalForm: str);
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if (canonicalForm.isNotEmpty) 'canonicalForm': canonicalForm,
      'type': type,
      if (formattedType.isNotEmpty) 'formattedType': formattedType,
    };
  }
}

/// Typed representation of a Google People API v1 `emailAddresses` entry.
@immutable
class GoogleEmailEntry {
  final String value;
  final String type;
  final String displayName;

  const GoogleEmailEntry({
    required this.value,
    this.type = 'work',
    this.displayName = '',
  });

  factory GoogleEmailEntry.fromDynamic(Object? raw) {
    if (raw is Map) {
      return GoogleEmailEntry(
        value: raw['value']?.toString().trim() ?? '',
        type: raw['type']?.toString().trim() ?? 'work',
        displayName: raw['displayName']?.toString().trim() ?? '',
      );
    }
    return GoogleEmailEntry(value: raw?.toString().trim() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type,
      if (displayName.isNotEmpty) 'displayName': displayName,
    };
  }
}

/// Typed representation of a Google People API v1 `organizations` entry.
@immutable
class GoogleOrganizationEntry {
  final String name;
  final String title;
  final String department;
  final bool isCurrent;

  const GoogleOrganizationEntry({
    required this.name,
    this.title = '',
    this.department = '',
    this.isCurrent = true,
  });

  factory GoogleOrganizationEntry.fromDynamic(Object? raw) {
    if (raw is Map) {
      return GoogleOrganizationEntry(
        name: raw['name']?.toString().trim() ?? '',
        title: raw['title']?.toString().trim() ?? '',
        department: raw['department']?.toString().trim() ?? '',
        isCurrent: raw['current'] is bool ? raw['current'] as bool : true,
      );
    }
    return GoogleOrganizationEntry(name: raw?.toString().trim() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (title.isNotEmpty) 'title': title,
      if (department.isNotEmpty) 'department': department,
      'current': isCurrent,
    };
  }
}

/// Inline M:N ERP Party or Account Group link metadata stored in `sb_contacts.erp_links`.
@immutable
class ErpContactLink {
  final String kind; // 'PARTY' or 'GROUP'
  final String code;
  final String name;
  final String city;
  final String role;

  const ErpContactLink({
    required this.kind,
    required this.code,
    this.name = '',
    this.city = '',
    this.role = '',
  });

  factory ErpContactLink.fromDynamic(Object? raw) {
    if (raw is Map) {
      return ErpContactLink(
        kind: (raw['kind']?.toString().trim().toUpperCase() ?? 'PARTY'),
        code: raw['code']?.toString().trim() ?? '',
        name: raw['name']?.toString().trim() ?? '',
        city: raw['city']?.toString().trim() ?? '',
        role: raw['role']?.toString().trim() ?? '',
      );
    }
    return const ErpContactLink(kind: 'PARTY', code: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'code': code,
      if (name.isNotEmpty) 'name': name,
      if (city.isNotEmpty) 'city': city,
      if (role.isNotEmpty) 'role': role,
    };
  }
}

/// Sync state & OAuth metadata model mirroring `"IMMBE2627"."sb_google_sync_state"`.
@immutable
class GoogleSyncStateModel {
  static const String defaultEmail = 'design.ambaji@gmail.com';
  static const String defaultClientId =
      '486012291961-nqqh431rt0sobmu8on4nsq3ipqjfral4.apps.googleusercontent.com';

  final String email;
  final String oauthClientId;
  final bool hasClientSecret;
  final bool hasRefreshToken;
  final bool hasAccessToken;
  final DateTime? tokenExpiresAt;
  final String? nextSyncToken;
  final Map<String, String> contactGroupsMap;
  final DateTime? lastFullSyncAt;
  final DateTime? lastDeltaSyncAt;
  final DateTime? lastPushAt;
  final int totalGoogleContacts;
  final bool isContinuousSyncEnabled;
  final String syncHealth;
  final String? lastError;
  final DateTime? updatedAt;

  const GoogleSyncStateModel({
    this.email = defaultEmail,
    this.oauthClientId = defaultClientId,
    this.hasClientSecret = false,
    this.hasRefreshToken = false,
    this.hasAccessToken = false,
    this.tokenExpiresAt,
    this.nextSyncToken,
    this.contactGroupsMap = const {},
    this.lastFullSyncAt,
    this.lastDeltaSyncAt,
    this.lastPushAt,
    this.totalGoogleContacts = 0,
    this.isContinuousSyncEnabled = true,
    this.syncHealth = 'DISCONNECTED',
    this.lastError,
    this.updatedAt,
  });

  bool get isConnected =>
      (hasAccessToken || hasRefreshToken) && syncHealth != 'DISCONNECTED';

  bool get isTokenExpired {
    final exp = tokenExpiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp.subtract(const Duration(minutes: 2)));
  }

  DateTime? get latestSyncAt {
    if (lastDeltaSyncAt == null) return lastFullSyncAt;
    if (lastFullSyncAt == null) return lastDeltaSyncAt;
    return lastDeltaSyncAt!.isAfter(lastFullSyncAt!)
        ? lastDeltaSyncAt
        : lastFullSyncAt;
  }

  factory GoogleSyncStateModel.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['contact_groups_map'];
    final Map<String, String> groupsMap = {};
    if (rawGroups is Map) {
      for (final entry in rawGroups.entries) {
        final k = entry.key?.toString().trim() ?? '';
        final v = entry.value?.toString().trim() ?? '';
        if (k.isNotEmpty && v.isNotEmpty) {
          groupsMap[k] = v;
        }
      }
    }

    bool parsePresence(Object? presenceBool, Object? rawSecret) {
      if (presenceBool is bool) return presenceBool;
      return (rawSecret?.toString().trim().isNotEmpty ?? false);
    }

    int parseInt(Object? val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    return GoogleSyncStateModel(
      email: json['email']?.toString().trim().isNotEmpty == true
          ? json['email'].toString().trim()
          : defaultEmail,
      oauthClientId:
          json['oauth_client_id']?.toString().trim().isNotEmpty == true
              ? json['oauth_client_id'].toString().trim()
              : defaultClientId,
      hasClientSecret: parsePresence(
          json['has_client_secret'], json['oauth_client_secret']),
      hasRefreshToken:
          parsePresence(json['has_refresh_token'], json['refresh_token']),
      hasAccessToken:
          parsePresence(json['has_access_token'], json['access_token']),
      tokenExpiresAt: json['token_expires_at'] != null
          ? DateTime.tryParse(json['token_expires_at'].toString())
          : null,
      nextSyncToken: json['next_sync_token']?.toString(),
      contactGroupsMap: groupsMap,
      lastFullSyncAt: json['last_full_sync_at'] != null
          ? DateTime.tryParse(json['last_full_sync_at'].toString())
          : null,
      lastDeltaSyncAt: json['last_delta_sync_at'] != null
          ? DateTime.tryParse(json['last_delta_sync_at'].toString())
          : null,
      lastPushAt: json['last_push_at'] != null
          ? DateTime.tryParse(json['last_push_at'].toString())
          : null,
      totalGoogleContacts: parseInt(json['total_google_contacts']),
      isContinuousSyncEnabled: json['is_continuous_sync_enabled'] is bool
          ? json['is_continuous_sync_enabled'] as bool
          : true,
      syncHealth: json['sync_health']?.toString() ?? 'DISCONNECTED',
      lastError: json['last_error']?.toString(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

/// Sync pull/import progress & summary outcome for UI overlays.
@immutable
class PullResult {
  final bool isSuccess;
  final int count;
  final int deletedCount;
  final String message;
  final String? detail;

  const PullResult({
    required this.isSuccess,
    required this.count,
    this.deletedCount = 0,
    required this.message,
    this.detail,
  });
}

/// Paginated page response returned by `ServiceGoogleContacts.fetchContactsPage`.
@immutable
class ContactsPageResult {
  final List<GoogleContact> items;
  final int totalCount;
  final int offset;
  final int limit;
  final String? error;

  const ContactsPageResult({
    required this.items,
    required this.totalCount,
    required this.offset,
    required this.limit,
    this.error,
  });

  bool get hasNextPage => offset + items.length < totalCount;
  bool get hasPreviousPage => offset > 0;
}

/// Lossless 1:1 Google People API Contact model mapped to `"IMMBE2627"."sb_contacts"`.
@immutable
class GoogleContact {
  final String id;
  final String googleAccountEmail;
  final String resourceName;
  final String? etag;

  // Lossless Google People API v1 JSON sub-resources
  final Map<String, dynamic> googleMetadata;
  final List<Map<String, dynamic>> names;
  final List<Map<String, dynamic>> nicknames;
  final List<Map<String, dynamic>> photos;
  final List<GooglePhoneEntry> phoneList;
  final List<GoogleEmailEntry> emailList;
  final List<Map<String, dynamic>> addresses;
  final List<GoogleOrganizationEntry> organizationList;
  final List<Map<String, dynamic>> biographies;
  final List<Map<String, dynamic>> relations;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> birthdays;
  final List<Map<String, dynamic>> urls;
  final List<Map<String, dynamic>> memberships;
  final List<Map<String, dynamic>> userDefined;
  final List<Map<String, dynamic>> clientData;
  final Map<String, dynamic> rawPerson;

  // Fast indexed display & lookup columns
  final String displayName;
  final String? givenName;
  final String? familyName;
  final String? companyName;
  final String? jobTitle;
  final String primaryPhone;
  final String? primaryEmail;
  final String? photoUrl;
  final String? notesText;
  final List<String> groupLabels;
  final List<String> phoneNorms;

  // ERP M:N Group & Party Links
  final List<String> linkedGroupCodes;
  final List<String> linkedMasterCodes;
  final List<ErpContactLink> erpLinks;
  final bool isStarred;
  final bool isArchived;

  // Two-Way Sync Lifecycle
  final String syncStatus;
  final List<String> dirtyFields;
  final String importSource;
  final DateTime lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoogleContact({
    required this.id,
    this.googleAccountEmail = GoogleSyncStateModel.defaultEmail,
    required this.resourceName,
    this.etag,
    this.googleMetadata = const {},
    this.names = const [],
    this.nicknames = const [],
    this.photos = const [],
    this.phoneList = const [],
    this.emailList = const [],
    this.addresses = const [],
    this.organizationList = const [],
    this.biographies = const [],
    this.relations = const [],
    this.events = const [],
    this.birthdays = const [],
    this.urls = const [],
    this.memberships = const [],
    this.userDefined = const [],
    this.clientData = const [],
    this.rawPerson = const {},
    required this.displayName,
    this.givenName,
    this.familyName,
    this.companyName,
    this.jobTitle,
    required this.primaryPhone,
    this.primaryEmail,
    this.photoUrl,
    this.notesText,
    this.groupLabels = const [],
    this.phoneNorms = const [],
    this.linkedGroupCodes = const [],
    this.linkedMasterCodes = const [],
    this.erpLinks = const [],
    this.isStarred = false,
    this.isArchived = false,
    this.syncStatus = 'SYNCED',
    this.dirtyFields = const [],
    this.importSource = 'GOOGLE_API',
    required this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLinked =>
      linkedMasterCodes.isNotEmpty ||
      linkedGroupCodes.isNotEmpty ||
      erpLinks.isNotEmpty;

  String? get primaryLinkedMasterCode =>
      linkedMasterCodes.isNotEmpty ? linkedMasterCodes.first : null;

  String get linkedSummaryLabel {
    if (erpLinks.isNotEmpty) {
      return erpLinks
          .map((l) => l.name.isNotEmpty ? '${l.name} (${l.code})' : l.code)
          .join(', ');
    }
    if (linkedMasterCodes.isNotEmpty) {
      return linkedMasterCodes.join(', ');
    }
    if (linkedGroupCodes.isNotEmpty) {
      return linkedGroupCodes.join(', ');
    }
    return 'Unlinked';
  }

  /// Convenience getter for UI compatibility
  List<String> get phoneNumbers =>
      phoneList.map((e) => e.preferredNumber).where((s) => s.isNotEmpty).toList();

  /// Convenience getter for UI compatibility
  List<String> get emails =>
      emailList.map((e) => e.value).where((s) => s.isNotEmpty).toList();

  static List<Map<String, dynamic>> _parseMapList(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    return const [];
  }

  static List<String> _parseStringList(Object? raw) {
    if (raw is List) {
      return raw
          .map((e) => e?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static Map<String, dynamic> _parseMap(Object? raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return const {};
  }

  /// Defensive `fromJson` factory handling Postgres JSONB & TEXT[] shapes cleanly.
  factory GoogleContact.fromJson(Map<String, dynamic> json) {
    final phones = (json['phone_numbers'] is List)
        ? (json['phone_numbers'] as List)
            .map(GooglePhoneEntry.fromDynamic)
            .where((p) => p.value.isNotEmpty || p.canonicalForm.isNotEmpty)
            .toList()
        : const <GooglePhoneEntry>[];

    final emails = (json['email_addresses'] is List)
        ? (json['email_addresses'] as List)
            .map(GoogleEmailEntry.fromDynamic)
            .where((e) => e.value.isNotEmpty)
            .toList()
        : const <GoogleEmailEntry>[];

    final orgs = (json['organizations'] is List)
        ? (json['organizations'] as List)
            .map(GoogleOrganizationEntry.fromDynamic)
            .where((o) => o.name.isNotEmpty || o.title.isNotEmpty)
            .toList()
        : const <GoogleOrganizationEntry>[];

    final erpLinksParsed = (json['erp_links'] is List)
        ? (json['erp_links'] as List)
            .map(ErpContactLink.fromDynamic)
            .where((l) => l.code.isNotEmpty)
            .toList()
        : const <ErpContactLink>[];

    final rawPrimaryPhone = json['primary_phone']?.toString().trim() ?? '';
    final effectivePrimaryPhone = rawPrimaryPhone.isNotEmpty
        ? rawPrimaryPhone
        : (phones.isNotEmpty ? phones.first.preferredNumber : 'N/A');

    final now = DateTime.now();

    return GoogleContact(
      id: json['id']?.toString() ?? '',
      googleAccountEmail:
          json['google_account_email']?.toString().trim().isNotEmpty == true
              ? json['google_account_email'].toString().trim()
              : GoogleSyncStateModel.defaultEmail,
      resourceName: json['resource_name']?.toString() ??
          json['google_resource_name']?.toString() ??
          '',
      etag: json['etag']?.toString(),
      googleMetadata: _parseMap(json['google_metadata']),
      names: _parseMapList(json['names']),
      nicknames: _parseMapList(json['nicknames']),
      photos: _parseMapList(json['photos']),
      phoneList: phones,
      emailList: emails,
      addresses: _parseMapList(json['addresses']),
      organizationList: orgs,
      biographies: _parseMapList(json['biographies']),
      relations: _parseMapList(json['relations']),
      events: _parseMapList(json['events']),
      birthdays: _parseMapList(json['birthdays']),
      urls: _parseMapList(json['urls']),
      memberships: _parseMapList(json['memberships']),
      userDefined: _parseMapList(json['user_defined']),
      clientData: _parseMapList(json['client_data']),
      rawPerson: _parseMap(json['raw_person']),
      displayName: json['display_name']?.toString().trim().isNotEmpty == true
          ? json['display_name'].toString().trim()
          : 'Unnamed Contact',
      givenName: json['given_name']?.toString(),
      familyName: json['family_name']?.toString(),
      companyName: json['company_name']?.toString() ??
          (orgs.isNotEmpty && orgs.first.name.isNotEmpty
              ? orgs.first.name
              : null),
      jobTitle: json['job_title']?.toString() ??
          (orgs.isNotEmpty && orgs.first.title.isNotEmpty
              ? orgs.first.title
              : null),
      primaryPhone: effectivePrimaryPhone,
      primaryEmail: json['primary_email']?.toString() ??
          (emails.isNotEmpty ? emails.first.value : null),
      photoUrl: json['photo_url']?.toString(),
      notesText: json['notes_text']?.toString(),
      groupLabels: _parseStringList(json['group_labels']),
      phoneNorms: _parseStringList(json['phone_norms']),
      linkedGroupCodes: _parseStringList(json['linked_group_codes']),
      linkedMasterCodes: _parseStringList(json['linked_master_codes']),
      erpLinks: erpLinksParsed,
      isStarred: json['is_starred'] is bool ? json['is_starred'] as bool : false,
      isArchived:
          json['is_archived'] is bool ? json['is_archived'] as bool : false,
      syncStatus: json['sync_status']?.toString() ?? 'SYNCED',
      dirtyFields: _parseStringList(json['dirty_fields']),
      importSource: json['import_source']?.toString() ?? 'GOOGLE_API',
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.tryParse(json['last_synced_at'].toString()) ?? now
          : now,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? now
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? now
          : now,
    );
  }

  /// Serializes row payload accepted by `"IMMBE2627"."fn_upsert_google_contacts_batch"`.
  Map<String, dynamic> toUpsertJson() {
    return {
      'resource_name': resourceName,
      if (etag != null && etag!.isNotEmpty) 'etag': etag,
      'google_metadata': googleMetadata,
      'names': names,
      'nicknames': nicknames,
      'photos': photos,
      'phone_numbers': phoneList.map((e) => e.toJson()).toList(),
      'email_addresses': emailList.map((e) => e.toJson()).toList(),
      'addresses': addresses,
      'organizations': organizationList.map((e) => e.toJson()).toList(),
      'biographies': biographies,
      'relations': relations,
      'events': events,
      'birthdays': birthdays,
      'urls': urls,
      'memberships': memberships,
      'user_defined': userDefined,
      'client_data': clientData,
      'raw_person': rawPerson,
      'display_name': displayName,
      if (givenName != null) 'given_name': givenName,
      if (familyName != null) 'family_name': familyName,
      if (companyName != null) 'company_name': companyName,
      if (jobTitle != null) 'job_title': jobTitle,
      'primary_phone': primaryPhone == 'N/A' ? null : primaryPhone,
      if (primaryEmail != null) 'primary_email': primaryEmail,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (notesText != null) 'notes_text': notesText,
      'group_labels': groupLabels,
      'phone_norms': phoneNorms,
      'linked_group_codes': linkedGroupCodes,
      'linked_master_codes': linkedMasterCodes,
      'erp_links': erpLinks.map((e) => e.toJson()).toList(),
      'is_starred': isStarred,
      'is_archived': isArchived,
    };
  }

  GoogleContact copyWith({
    String? id,
    String? googleAccountEmail,
    String? resourceName,
    String? etag,
    Map<String, dynamic>? googleMetadata,
    List<Map<String, dynamic>>? names,
    List<Map<String, dynamic>>? nicknames,
    List<Map<String, dynamic>>? photos,
    List<GooglePhoneEntry>? phoneList,
    List<GoogleEmailEntry>? emailList,
    List<Map<String, dynamic>>? addresses,
    List<GoogleOrganizationEntry>? organizationList,
    List<Map<String, dynamic>>? biographies,
    List<Map<String, dynamic>>? relations,
    List<Map<String, dynamic>>? events,
    List<Map<String, dynamic>>? birthdays,
    List<Map<String, dynamic>>? urls,
    List<Map<String, dynamic>>? memberships,
    List<Map<String, dynamic>>? userDefined,
    List<Map<String, dynamic>>? clientData,
    Map<String, dynamic>? rawPerson,
    String? displayName,
    String? givenName,
    String? familyName,
    String? companyName,
    String? jobTitle,
    String? primaryPhone,
    String? primaryEmail,
    String? photoUrl,
    String? notesText,
    List<String>? groupLabels,
    List<String>? phoneNorms,
    List<String>? linkedGroupCodes,
    List<String>? linkedMasterCodes,
    List<ErpContactLink>? erpLinks,
    bool? isStarred,
    bool? isArchived,
    String? syncStatus,
    List<String>? dirtyFields,
    String? importSource,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoogleContact(
      id: id ?? this.id,
      googleAccountEmail: googleAccountEmail ?? this.googleAccountEmail,
      resourceName: resourceName ?? this.resourceName,
      etag: etag ?? this.etag,
      googleMetadata: googleMetadata ?? this.googleMetadata,
      names: names ?? this.names,
      nicknames: nicknames ?? this.nicknames,
      photos: photos ?? this.photos,
      phoneList: phoneList ?? this.phoneList,
      emailList: emailList ?? this.emailList,
      addresses: addresses ?? this.addresses,
      organizationList: organizationList ?? this.organizationList,
      biographies: biographies ?? this.biographies,
      relations: relations ?? this.relations,
      events: events ?? this.events,
      birthdays: birthdays ?? this.birthdays,
      urls: urls ?? this.urls,
      memberships: memberships ?? this.memberships,
      userDefined: userDefined ?? this.userDefined,
      clientData: clientData ?? this.clientData,
      rawPerson: rawPerson ?? this.rawPerson,
      displayName: displayName ?? this.displayName,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      primaryEmail: primaryEmail ?? this.primaryEmail,
      photoUrl: photoUrl ?? this.photoUrl,
      notesText: notesText ?? this.notesText,
      groupLabels: groupLabels ?? this.groupLabels,
      phoneNorms: phoneNorms ?? this.phoneNorms,
      linkedGroupCodes: linkedGroupCodes ?? this.linkedGroupCodes,
      linkedMasterCodes: linkedMasterCodes ?? this.linkedMasterCodes,
      erpLinks: erpLinks ?? this.erpLinks,
      isStarred: isStarred ?? this.isStarred,
      isArchived: isArchived ?? this.isArchived,
      syncStatus: syncStatus ?? this.syncStatus,
      dirtyFields: dirtyFields ?? this.dirtyFields,
      importSource: importSource ?? this.importSource,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Helper model for Master Party (`sq_MASTER`) selection in ERP Link Picker.
@immutable
class MasterPartyOption {
  final String code;
  final String name;
  final String gcode;
  final String city;
  final String station;
  final String mobile;

  const MasterPartyOption({
    required this.code,
    required this.name,
    this.gcode = '',
    required this.city,
    required this.station,
    required this.mobile,
  });

  factory MasterPartyOption.fromJson(Map<String, dynamic> json) {
    return MasterPartyOption(
      code: json['code']?.toString() ?? '',
      name: json['NAME']?.toString() ?? json['name']?.toString() ?? 'Unknown Party',
      gcode: json['GCODE']?.toString() ?? json['gcode']?.toString() ?? '',
      city: json['CITY1']?.toString() ?? json['city']?.toString() ?? '',
      station: json['STATION']?.toString() ?? json['station']?.toString() ?? '',
      mobile: json['MOBILE']?.toString() ?? json['mobile']?.toString() ?? '',
    );
  }
}

/// Helper model for Account Group (`sq_ACGROUP`) selection in ERP Link Picker.
@immutable
class AccountGroupOption {
  final String gcode;
  final String name;
  final String city;
  final String contact;
  final String mobile;

  const AccountGroupOption({
    required this.gcode,
    required this.name,
    this.city = '',
    this.contact = '',
    this.mobile = '',
  });

  factory AccountGroupOption.fromJson(Map<String, dynamic> json) {
    return AccountGroupOption(
      gcode: json['gcode']?.toString() ?? '',
      name: json['NAME']?.toString() ?? json['name']?.toString() ?? 'Unknown Group',
      city: json['CITY1']?.toString() ?? '',
      contact: json['CONTACT']?.toString() ?? '',
      mobile: json['MOBILE']?.toString() ?? '',
    );
  }
}

/// Sister firm summary under an `sq_ACGROUP` (`GCODE`) read from `sq_MASTER`.
@immutable
class SisterPartySummary {
  final String code;
  final String name;
  final String gcode;
  final String city;
  final String station;
  final String adatiya;
  final int creditDays;
  final String mobile;
  final String flashRmk;
  final bool isDirectlyLinked;

  const SisterPartySummary({
    required this.code,
    required this.name,
    required this.gcode,
    this.city = '',
    this.station = '',
    this.adatiya = '',
    this.creditDays = 0,
    this.mobile = '',
    this.flashRmk = '',
    this.isDirectlyLinked = false,
  });

  factory SisterPartySummary.fromJson(
    Map<String, dynamic> json, {
    required Set<String> directMasterCodes,
  }) {
    final code = json['code']?.toString().trim() ?? '';
    return SisterPartySummary(
      code: code,
      name: json['NAME']?.toString().trim() ?? code,
      gcode: json['GCODE']?.toString().trim() ?? '',
      city: json['CITY1']?.toString().trim() ?? '',
      station: json['STATION']?.toString().trim() ?? '',
      adatiya: json['ADATIYA']?.toString().trim() ?? 'SELF',
      creditDays: json['crdays'] is num ? (json['crdays'] as num).toInt() : 0,
      mobile: json['MOBILE']?.toString().trim() ?? '',
      flashRmk: json['FLASH_RMK']?.toString().trim() ?? '',
      isDirectlyLinked: directMasterCodes.contains(code),
    );
  }
}

/// Owned Account Group & Sister-Firm Rollup displayed in Region [5].
@immutable
class ContactGroupEmpireRollup {
  final List<AccountGroupOption> groups;
  final List<SisterPartySummary> sisterParties;
  final String? error;

  const ContactGroupEmpireRollup({
    this.groups = const [],
    this.sisterParties = const [],
    this.error,
  });

  bool get isEmpty => groups.isEmpty && sisterParties.isEmpty;
}

/// Executive KPI counts for Stage 9.3 Contacts Linear Bento Region [1].
@immutable
class ContactsKpiCounts {
  final int totalActive;
  final int linkedCount;
  final int unlinkedCount;
  final int pendingPushCount;
  final int starredCount;

  const ContactsKpiCounts({
    this.totalActive = 0,
    this.linkedCount = 0,
    this.unlinkedCount = 0,
    this.pendingPushCount = 0,
    this.starredCount = 0,
  });
}
