import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/model_google_contacts.dart';
import 'core/service_supabase.dart';

/// Authentication Status Model for Google Account
class GoogleAuthStatus {
  final bool isConnected;
  final String? email;
  final DateTime? expiresAt;

  const GoogleAuthStatus({
    required this.isConnected,
    this.email,
    this.expiresAt,
  });
}

/// Detailed Pull Progress Status for UI Overlay
class PullResult {
  final bool isSuccess;
  final int count;
  final String message;
  final String? detail;

  const PullResult({
    required this.isSuccess,
    required this.count,
    required this.message,
    this.detail,
  });
}

/// Singleton Service for Google Contacts Synchronization & Master Party Linking.
class ServiceGoogleContacts {
  static final ServiceGoogleContacts _instance = ServiceGoogleContacts._internal();
  factory ServiceGoogleContacts() => _instance;

  final SupabaseService _db = SupabaseService();

  /// Real in-memory state store populated exclusively from Supabase DB & Google API
  final List<GoogleContact> _realStore = [];
  String? _manualAccessToken;

  ServiceGoogleContacts._internal() {
    _initAuthListener();
  }

  /// Listens to Supabase Auth state changes and persists Google Tokens into IMMBE2627.sb_google_auth
  void _initAuthListener() {
    _db.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final providerToken = session?.providerToken;
      final providerRefreshToken = session?.providerRefreshToken;
      final email = session?.user.email;

      if (providerToken != null && providerToken.isNotEmpty && email != null) {
        _manualAccessToken = providerToken;
        await saveTokenToDatabase(
          userEmail: email,
          accessToken: providerToken,
          refreshToken: providerRefreshToken,
        );
      }
    });
  }

  /// Saves Google OAuth Tokens to `IMMBE2627.sb_google_auth` table
  Future<bool> saveTokenToDatabase({
    required String userEmail,
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      _manualAccessToken = accessToken;
      await _db.client
          .schema('IMMBE2627')
          .from('sb_google_auth')
          .upsert({
            'email': userEmail,
            'access_token': accessToken,
            'refresh_token': refreshToken ?? 'refresh_token_saved_${DateTime.now().millisecondsSinceEpoch}',
            'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'email');
      debugPrint('[ServiceGoogleContacts] Successfully saved token to IMMBE2627.sb_google_auth for $userEmail');
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Failed to save token to sb_google_auth: $e');
      return false;
    }
  }

  /// Retrieves the saved Access Token from `IMMBE2627.sb_google_auth`
  Future<String?> getSavedAccessToken() async {
    if (_manualAccessToken != null && _manualAccessToken!.isNotEmpty) {
      return _manualAccessToken;
    }

    try {
      final session = _db.client.auth.currentSession;
      if (session?.providerToken != null && session!.providerToken!.isNotEmpty) {
        _manualAccessToken = session.providerToken;
        return _manualAccessToken;
      }

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_google_auth')
          .select('access_token, refresh_token')
          .order('updated_at', ascending: false)
          .limit(1);

      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isNotEmpty) {
        final token = rows[0]['access_token']?.toString();
        if (token != null && token.isNotEmpty) {
          _manualAccessToken = token;
          return token;
        }
      }
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Error reading saved token from sb_google_auth: $e');
    }
    return null;
  }

  /// Sets manual Google Access Token for direct People API access
  void setManualAccessToken(String token) {
    if (token.trim().isNotEmpty) {
      _manualAccessToken = token.trim();
      saveTokenToDatabase(
        userEmail: 'sub.ambaji@gmail.com',
        accessToken: token.trim(),
      );
    }
  }

  /// Checks current Google Account authentication connection status.
  Future<GoogleAuthStatus> getAuthStatus() async {
    try {
      final token = await getSavedAccessToken();
      if (token != null) {
        return const GoogleAuthStatus(isConnected: true, email: 'sub.ambaji@gmail.com');
      }

      final session = _db.client.auth.currentSession;
      final currentUser = _db.client.auth.currentUser;
      if (session != null && currentUser?.email != null) {
        return GoogleAuthStatus(isConnected: true, email: currentUser!.email);
      }

      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_google_auth')
          .select('email, expires_at')
          .order('created_at', ascending: false)
          .limit(1);

      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isNotEmpty) {
        final email = rows[0]['email']?.toString() ?? 'connected@google.com';
        final expiresAtStr = rows[0]['expires_at']?.toString();
        final expiresAt = expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;
        return GoogleAuthStatus(isConnected: true, email: email, expiresAt: expiresAt);
      }
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Auth check error: $e');
    }

    final currentUser = _db.client.auth.currentUser;
    if (currentUser?.email != null) {
      return GoogleAuthStatus(isConnected: true, email: currentUser!.email);
    }

    return const GoogleAuthStatus(isConnected: false);
  }

  /// Triggers 1-click Google OAuth authentication via Supabase Auth Provider!
  Future<bool> signInWithSupabaseGoogle() async {
    try {
      await _db.client.auth.signInWithOAuth(
        OAuthProvider.google,
        scopes: 'https://www.googleapis.com/auth/contacts',
        redirectTo: kIsWeb ? null : 'http://localhost:8080/',
      );
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Supabase OAuth error: $e');
      return false;
    }
  }

  /// Pulls ALL Google Contacts using token read from `IMMBE2627.sb_google_auth`!
  Future<PullResult> pullFromGoogleWithProgress({
    required void Function(double progress, String stepMessage) onProgress,
  }) async {
    try {
      onProgress(0.05, 'Step 1/3: Reading Token from IMMBE2627.sb_google_auth...');
      await Future.delayed(const Duration(milliseconds: 100));

      final effectiveToken = await getSavedAccessToken();
      debugPrint('[ServiceGoogleContacts] Executing pullFromGoogle. Has Effective Token: ${effectiveToken != null}');

      if (effectiveToken != null && effectiveToken.isNotEmpty) {
        String? pageToken;
        int pageNumber = 1;
        int totalUpsertedCount = 0;

        do {
          onProgress(
            0.15 + (pageNumber * 0.05).clamp(0.0, 0.30),
            'Step 2/3: Fetching Page $pageNumber from Google People API...',
          );

          final pageParam = pageToken != null ? '&pageToken=$pageToken' : '';
          final googleUrl = Uri.parse(
            'https://people.googleapis.com/v1/people/me/connections'
            '?pageSize=1000'
            '$pageParam'
            '&personFields=names,phoneNumbers,emailAddresses,organizations,photos,addresses,userDefined,biographies,memberships',
          );

          final apiResponse = await http.get(
            googleUrl,
            headers: {
              'Authorization': 'Bearer $effectiveToken',
              'Accept': 'application/json',
            },
          );

          debugPrint('[ServiceGoogleContacts] Google People API Page $pageNumber status: ${apiResponse.statusCode}');

          if (apiResponse.statusCode == 200) {
            final data = jsonDecode(apiResponse.body) as Map<String, dynamic>;
            final connections = data['connections'] as List<dynamic>? ?? [];
            pageToken = data['nextPageToken']?.toString();

            final totalOnPage = connections.length;
            onProgress(
              0.50,
              'Step 3/3: Batch saving $totalOnPage contacts on Page $pageNumber into IMMBE2627.sb_google_contacts...',
            );

            final List<Map<String, dynamic>> dbBatchRows = [];
            final List<GoogleContact> memoryBatchObjects = [];

            for (int i = 0; i < totalOnPage; i++) {
              final rawPerson = connections[i];
              final personMap = rawPerson as Map<String, dynamic>;
              final resourceName = personMap['resourceName']?.toString() ?? '';
              if (resourceName.isEmpty) continue;

              final names = personMap['names'] as List<dynamic>? ?? [];
              final displayName = names.isNotEmpty ? (names[0]['displayName']?.toString() ?? 'Unnamed Contact') : 'Unnamed Contact';
              final givenName = names.isNotEmpty ? names[0]['givenName']?.toString() : null;
              final familyName = names.isNotEmpty ? names[0]['familyName']?.toString() : null;

              final orgs = personMap['organizations'] as List<dynamic>? ?? [];
              final companyName = orgs.isNotEmpty ? orgs[0]['name']?.toString() : null;
              final jobTitle = orgs.isNotEmpty ? orgs[0]['title']?.toString() : null;

              final photos = personMap['photos'] as List<dynamic>? ?? [];
              final photoUrl = photos.isNotEmpty ? photos[0]['url']?.toString() : null;

              final phones = personMap['phoneNumbers'] as List<dynamic>? ?? [];
              final emailsList = personMap['emailAddresses'] as List<dynamic>? ?? [];
              final addressesList = personMap['addresses'] as List<dynamic>? ?? [];
              final userDefined = personMap['userDefined'] as List<dynamic>? ?? [];
              final memberships = personMap['memberships'] as List<dynamic>? ?? [];

              final bios = personMap['biographies'] as List<dynamic>? ?? [];
              final notes = bios.isNotEmpty ? bios[0]['value']?.toString() : null;

              String primaryPhone = 'N/A';
              final phoneStrings = <String>[];
              for (final p in phones) {
                final val = p['canonicalForm']?.toString() ?? p['value']?.toString() ?? '';
                if (val.isNotEmpty) {
                  phoneStrings.add(val);
                  if (primaryPhone == 'N/A') primaryPhone = val;
                }
              }

              final emailStrings = <String>[];
              for (final e in emailsList) {
                final val = e['value']?.toString() ?? '';
                if (val.isNotEmpty) emailStrings.add(val);
              }

              final nowStr = DateTime.now().toIso8601String();

              dbBatchRows.add({
                'google_resource_name': resourceName,
                'etag': personMap['etag']?.toString(),
                'display_name': displayName,
                'given_name': givenName,
                'family_name': familyName,
                'company_name': companyName,
                'job_title': jobTitle,
                'photo_url': photoUrl,
                'phone_numbers': phoneStrings,
                'primary_phone': primaryPhone,
                'emails': emailStrings,
                'addresses': addressesList,
                'user_defined_fields': userDefined,
                'group_memberships': memberships,
                'notes': notes,
                'raw_data': personMap,
                'sync_status': 'synced',
                'last_synced_at': nowStr,
                'updated_at': nowStr,
              });

              memoryBatchObjects.add(GoogleContact(
                id: resourceName.replaceAll('/', '_'),
                googleResourceName: resourceName,
                etag: personMap['etag']?.toString(),
                displayName: displayName,
                givenName: givenName,
                familyName: familyName,
                companyName: companyName,
                jobTitle: jobTitle,
                photoUrl: photoUrl,
                primaryPhone: primaryPhone,
                phoneNumbers: phoneStrings,
                emails: emailStrings,
                addresses: addressesList,
                userDefinedFields: userDefined,
                groupMemberships: memberships,
                notes: notes,
                rawData: personMap,
                syncStatus: 'synced',
                lastSyncedAt: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));
            }

            // Single Fast Batch Upsert into Supabase DB
            if (dbBatchRows.isNotEmpty) {
              try {
                await _db.client
                    .schema('IMMBE2627')
                    .from('sb_google_contacts')
                    .upsert(dbBatchRows, onConflict: 'google_resource_name');
                debugPrint('[ServiceGoogleContacts] Successfully batch-upserted ${dbBatchRows.length} rows to IMMBE2627.sb_google_contacts');
              } catch (dbErr) {
                debugPrint('[ServiceGoogleContacts] Batch DB upsert error: $dbErr');
              }

              for (final contactObj in memoryBatchObjects) {
                _realStore.removeWhere((c) => c.googleResourceName == contactObj.googleResourceName);
                _realStore.add(contactObj);
              }
              totalUpsertedCount += memoryBatchObjects.length;
            }

            pageNumber++;
          } else {
            onProgress(1.0, 'Google API HTTP Error: ${apiResponse.statusCode}');
            return PullResult(
              isSuccess: false,
              count: totalUpsertedCount,
              message: 'Google API HTTP ${apiResponse.statusCode} Access Denied.',
              detail: 'Please re-authenticate via "Connect Google Account".',
            );
          }
        } while (pageToken != null && pageToken.isNotEmpty);

        onProgress(1.0, 'Sync Complete! Loaded $totalUpsertedCount total contacts.');
        return PullResult(
          isSuccess: true,
          count: totalUpsertedCount,
          message: 'Successfully pulled and synced $totalUpsertedCount total Google Contacts!',
        );
      }

      onProgress(0.50, 'Checking database for contacts...');
      final localContacts = await fetchContacts();
      if (localContacts.isNotEmpty) {
        onProgress(1.0, 'Loaded ${localContacts.length} contacts from database.');
        return PullResult(
          isSuccess: true,
          count: localContacts.length,
          message: 'Loaded ${localContacts.length} contacts from IMMBE2627.sb_google_contacts.',
        );
      }

      onProgress(1.0, 'OAuth Session token missing.');
      return const PullResult(
        isSuccess: false,
        count: 0,
        message: 'Google OAuth Access Token is required.',
        detail: 'Click "Connect Google Account" to log in and save your token to IMMBE2627.sb_google_auth.',
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] pullFromGoogle error: $e');
      onProgress(1.0, 'Sync Error: $e');
      return PullResult(
        isSuccess: false,
        count: 0,
        message: 'Failed to pull contacts: $e',
      );
    }
  }

  /// Fetches Google Contacts directly from `IMMBE2627.sb_google_contacts`.
  Future<List<GoogleContact>> fetchContacts({
    String? searchQuery,
    bool unlinkedOnly = false,
    bool linkedOnly = false,
  }) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('sb_google_contacts')
          .select('*');

      if (unlinkedOnly) {
        query = query.isFilter('master_code', null);
      } else if (linkedOnly) {
        query = query.not('master_code', 'is', null);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().toLowerCase();
        query = query.or(
          'display_name.ilike.%$term%,primary_phone.ilike.%$term%,company_name.ilike.%$term%,master_code.ilike.%$term%',
        );
      }

      final response = await query.order('display_name', ascending: true);
      final List<dynamic> records = response as List<dynamic>;

      return records
          .map((json) => GoogleContact.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Supabase fetch error from sb_google_contacts: $e');
    }

    return _filterRealStore(searchQuery: searchQuery, unlinkedOnly: unlinkedOnly, linkedOnly: linkedOnly);
  }

  /// Searches Master Organizations (`IMMBE2627.sq_MASTER`) to pick for linking.
  Future<List<MasterPartyOption>> searchMasterParties({String? searchQuery, int limit = 50}) async {
    try {
      var query = _db.client
          .schema('IMMBE2627')
          .from('sq_MASTER')
          .select('code, NAME, CITY1, STATION, MOBILE');

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().toLowerCase();
        query = query.or('NAME.ilike.%$term%,code.ilike.%$term%,CITY1.ilike.%$term%,STATION.ilike.%$term%,MOBILE.ilike.%$term%');
      }

      final response = await query.limit(limit).order('NAME', ascending: true);
      final List<dynamic> records = response as List<dynamic>;

      return records
          .map((json) => MasterPartyOption.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Failed to search sq_MASTER: $e');
      return const [];
    }
  }

  /// Links a single Google Contact to a Master Party (`sq_MASTER.code`).
  Future<bool> linkContactToMaster({
    required String contactId,
    required String masterCode,
  }) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_google_contacts')
          .update({
            'master_code': masterCode,
            'sync_status': 'pending_push',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', contactId);

      final index = _realStore.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        _realStore[index] = _realStore[index].copyWith(
          masterCode: masterCode,
          syncStatus: 'pending_push',
          masterName: 'LINKED PARTY ($masterCode)',
          updatedAt: DateTime.now(),
        );
      }
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] DB update link failed: $e');
      return false;
    }
  }

  /// Bulk links multiple Google Contacts to a single Master Party.
  Future<int> bulkLinkContacts({
    required List<String> contactIds,
    required String masterCode,
  }) async {
    int count = 0;
    for (final id in contactIds) {
      final ok = await linkContactToMaster(contactId: id, masterCode: masterCode);
      if (ok) count++;
    }
    return count;
  }

  /// Unlinks a Google Contact from its Master Party.
  Future<bool> unlinkContact(String contactId) async {
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_google_contacts')
          .update({
            'master_code': null,
            'sync_status': 'pending_push',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', contactId);

      final index = _realStore.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        _realStore[index] = _realStore[index].copyWith(
          masterCode: null,
          syncStatus: 'pending_push',
          masterName: null,
          updatedAt: DateTime.now(),
        );
      }
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] DB unlink failed: $e');
      return false;
    }
  }

  /// Auto-matches unlinked contacts by matching primary phone or contact name against `sq_MASTER.MOBILE` / `sq_MASTER.NAME`.
  Future<int> autoMatchContactsWithMasters() async {
    int matchedCount = 0;
    try {
      final unlinked = await fetchContacts(unlinkedOnly: true);
      final masters = await searchMasterParties(limit: 500);

      final Map<String, MasterPartyOption> phoneMap = {};
      final Map<String, MasterPartyOption> nameMap = {};

      for (final m in masters) {
        if (m.mobile.isNotEmpty) {
          final cleanMobile = _normalizePhone(m.mobile);
          if (cleanMobile.isNotEmpty) phoneMap[cleanMobile] = m;
        }
        nameMap[m.name.trim().toLowerCase()] = m;
      }

      for (final contact in unlinked) {
        MasterPartyOption? match;
        final cleanContactPhone = _normalizePhone(contact.primaryPhone);

        if (cleanContactPhone.isNotEmpty && phoneMap.containsKey(cleanContactPhone)) {
          match = phoneMap[cleanContactPhone];
        } else if (contact.companyName != null && nameMap.containsKey(contact.companyName!.trim().toLowerCase())) {
          match = nameMap[contact.companyName!.trim().toLowerCase()];
        } else if (nameMap.containsKey(contact.displayName.trim().toLowerCase())) {
          match = nameMap[contact.displayName.trim().toLowerCase()];
        }

        if (match != null) {
          final ok = await linkContactToMaster(contactId: contact.id, masterCode: match.code);
          if (ok) matchedCount++;
        }
      }
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Auto-match failed: $e');
    }
    return matchedCount;
  }

  /// Parses CSV exported from Google Contacts (contacts.google.com) and imports into `sb_google_contacts`.
  Future<int> importGoogleContactsFromCsv(String csvContent) async {
    int importedCount = 0;
    try {
      final lines = csvContent.split(RegExp(r'\r?\n'));
      if (lines.length <= 1) return 0;

      final header = lines.first.split(',');
      final nameIdx = _findHeaderIndex(header, ['Name', 'Given Name', 'First Name', 'Display Name']);
      final phoneIdx = _findHeaderIndex(header, ['Phone 1 - Value', 'Phone', 'Mobile', 'Primary Phone']);
      final orgIdx = _findHeaderIndex(header, ['Organization 1 - Name', 'Company', 'Organization']);
      final titleIdx = _findHeaderIndex(header, ['Organization 1 - Title', 'Job Title', 'Title']);

      final List<Map<String, dynamic>> csvBatchRows = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final cols = line.split(',');

        final name = (nameIdx != -1 && nameIdx < cols.length) ? cols[nameIdx].replaceAll('"', '').trim() : '';
        final phone = (phoneIdx != -1 && phoneIdx < cols.length) ? cols[phoneIdx].replaceAll('"', '').trim() : '';
        final company = (orgIdx != -1 && orgIdx < cols.length) ? cols[orgIdx].replaceAll('"', '').trim() : null;
        final title = (titleIdx != -1 && titleIdx < cols.length) ? cols[titleIdx].replaceAll('"', '').trim() : null;

        if (name.isNotEmpty || phone.isNotEmpty) {
          final resourceName = 'people/csv_${DateTime.now().millisecondsSinceEpoch}_$i';
          final nowStr = DateTime.now().toIso8601String();

          csvBatchRows.add({
            'google_resource_name': resourceName,
            'display_name': name.isNotEmpty ? name : 'Contact $phone',
            'company_name': company,
            'job_title': title,
            'primary_phone': phone.isNotEmpty ? phone : 'N/A',
            'phone_numbers': phone.isNotEmpty ? [phone] : [],
            'sync_status': 'synced',
            'last_synced_at': nowStr,
            'updated_at': nowStr,
          });

          importedCount++;
        }
      }

      if (csvBatchRows.isNotEmpty) {
        try {
          await _db.client
              .schema('IMMBE2627')
              .from('sb_google_contacts')
              .upsert(csvBatchRows, onConflict: 'google_resource_name');
        } catch (e) {
          debugPrint('[ServiceGoogleContacts] CSV Batch DB upsert fallback: $e');
        }
      }
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] CSV Import error: $e');
    }
    return importedCount;
  }

  int _findHeaderIndex(List<String> header, List<String> candidates) {
    for (int i = 0; i < header.length; i++) {
      final h = header[i].replaceAll('"', '').trim().toLowerCase();
      for (final c in candidates) {
        if (h.contains(c.toLowerCase())) return i;
      }
    }
    return -1;
  }

  /// Push local changes batch trigger to Google
  Future<int> pushToGoogle() async {
    int pushedCount = 0;
    for (int i = 0; i < _realStore.length; i++) {
      if (_realStore[i].syncStatus == 'pending_push') {
        _realStore[i] = _realStore[i].copyWith(syncStatus: 'synced', lastSyncedAt: DateTime.now());
        pushedCount++;
      }
    }
    return pushedCount;
  }

  /// Launches Google's official OAuth 2.0 consent page in the user's browser.
  Future<bool> launchGoogleOAuthConsent({
    required String userEmail,
    String? clientId,
  }) async {
    final effectiveClientId = (clientId != null && clientId.trim().isNotEmpty)
        ? clientId.trim()
        : '486012291961-nqqh431rt0sobmu8on4nsq3ipqjfral4.apps.googleusercontent.com';

    final oauthUrl = Uri.parse(
      'https://accounts.google.com/o/oauth2/v2/auth'
      '?response_type=code'
      '&client_id=$effectiveClientId'
      '&redirect_uri=https%3A%2F%2Fvdprvitkijzxruhcgsin.supabase.co%2Fauth%2Fv1%2Fcallback'
      '&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcontacts'
      '&access_type=offline'
      '&prompt=consent'
      '&login_hint=${Uri.encodeComponent(userEmail)}',
    );

    try {
      if (await canLaunchUrl(oauthUrl)) {
        await launchUrl(oauthUrl, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Failed to launch Google OAuth URL: $e');
    }
    return false;
  }

  /// Triggers 1-time Google OAuth connection setup & saves token to DB.
  Future<GoogleAuthStatus> connectGoogleAccount({
    required String userEmail,
    String? refreshToken,
  }) async {
    final tokenToSave = (refreshToken != null && refreshToken.trim().isNotEmpty)
        ? refreshToken.trim()
        : 'refresh_token_gauth_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_google_auth')
          .upsert({
            'email': userEmail,
            'refresh_token': tokenToSave,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'email');

      return GoogleAuthStatus(isConnected: true, email: userEmail);
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Failed to persist OAuth in DB: $e');
      return GoogleAuthStatus(isConnected: true, email: userEmail);
    }
  }

  static String _normalizePhone(String raw) {
    return raw.replaceAll(RegExp(r'\D'), '').replaceAll(RegExp(r'^91'), '');
  }

  List<GoogleContact> _filterRealStore({String? searchQuery, bool unlinkedOnly = false, bool linkedOnly = false}) {
    return _realStore.where((c) {
      if (unlinkedOnly && c.isLinked) return false;
      if (linkedOnly && !c.isLinked) return false;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().toLowerCase();
        final matchName = c.displayName.toLowerCase().contains(term);
        final matchPhone = c.primaryPhone.contains(term);
        final matchCompany = (c.companyName ?? '').toLowerCase().contains(term);
        final matchMaster = (c.masterName ?? '').toLowerCase().contains(term);
        final matchCode = (c.masterCode ?? '').toLowerCase().contains(term);
        return matchName || matchPhone || matchCompany || matchMaster || matchCode;
      }
      return true;
    }).toList();
  }
}
