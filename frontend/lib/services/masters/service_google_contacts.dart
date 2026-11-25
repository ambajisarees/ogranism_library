/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Canonical Stage 9.1 CRM Service (`ServiceGoogleContacts`) managing OAuth,
     People API v1 sync, batch CSV upload orchestration, server-side pagination,
     and manual ERP linking for `"IMMBE2627"."sb_contacts"` and
     `"IMMBE2627"."sb_google_sync_state"`.
   - Default Google account is strictly `design.ambaji@gmail.com` (isolated from
     Ambaji ERP staff Supabase Auth logins).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Delegates stateless parsing and Google Person/CSV transformations to
     `GoogleContactsMapper` (`google_contacts_mapper.dart`).
   - Streams 400-row chunks into `"IMMBE2627"."fn_upsert_google_contacts_batch"`
     (`SECURITY DEFINER`, `60s` timeout) preserving inline ERP links.
   - Paginates via `.range(offset, offset + limit - 1)` + `CountOption.exact`
     so 7,000+ contacts browse cleanly without PostgREST's 1,000-row cap.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Exposed Supabase PostgREST schema is `"IMMBE2627"` (`public` not exposed).
   - List queries exclude heavy `raw_person`; use `fetchContactRawPerson(id)`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Auto-matching logic (`sq_MASTER` / `sq_ACGROUP`) is omitted in Stage 9.1
     per user direction; manual linking methods are active for UI inspection.
================================================================================
*/

import 'dart:async';
import 'dart:convert';
import 'dart:io' show ContentType, HttpServer, HttpStatus, InternetAddress;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/masters/model_google_contacts.dart';
import '../core/service_supabase.dart';
import 'google_contacts_mapper.dart';

part 'service_google_contacts_write.dart';

/// Filter tabs supported by paginated `sb_contacts` queries.
enum ContactsFilterMode { all, unlinked, linked, pendingPush, starred }

/// Singleton service for lossless Google Contacts import, pull & ERP linking.
class ServiceGoogleContacts {
  static final ServiceGoogleContacts _instance = ServiceGoogleContacts._internal();
  factory ServiceGoogleContacts() => _instance;
  ServiceGoogleContacts._internal();

  static const String defaultGoogleEmail = GoogleSyncStateModel.defaultEmail;
  static const String defaultClientId = GoogleSyncStateModel.defaultClientId;
  static const int _batchSize = 400;
  static const String _personFields =
      'names,nicknames,photos,phoneNumbers,emailAddresses,addresses,organizations,'
      'biographies,relations,events,birthdays,urls,memberships,userDefined,clientData,metadata';
  static const String _listColumns =
      'id,google_account_email,resource_name,etag,google_metadata,names,'
      'nicknames,photos,phone_numbers,email_addresses,addresses,organizations,'
      'biographies,relations,events,birthdays,urls,memberships,user_defined,'
      'client_data,display_name,given_name,family_name,company_name,job_title,'
      'primary_phone,primary_email,photo_url,notes_text,group_labels,phone_norms,'
      'linked_group_codes,linked_master_codes,erp_links,is_starred,is_archived,'
      'sync_status,dirty_fields,import_source,last_synced_at,created_at,updated_at';

  final SupabaseService _db = SupabaseService();
  HttpServer? _activeOAuthServer;
  bool _oauthCancelledByUser = false;

  /// Convenience passthrough for UI CSV row counting.
  static List<List<String>> parseRfc4180Csv(String input) =>
      GoogleContactsMapper.parseRfc4180Csv(input);

  // ── 1. SYNC STATE & CREDENTIALS ──────────────────────────────────────────

  /// Fetches sync state strictly from `"IMMBE2627"."sb_google_sync_state"`.
  Future<GoogleSyncStateModel> getSyncState({String email = defaultGoogleEmail}) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final rows = await _db.client
          .schema('IMMBE2627')
          .from('sb_google_sync_state')
          .select(
            'email,oauth_client_id,oauth_client_secret,refresh_token,access_token,'
            'token_expires_at,next_sync_token,contact_groups_map,last_full_sync_at,'
            'last_delta_sync_at,last_push_at,total_google_contacts,'
            'is_continuous_sync_enabled,sync_health,last_error,updated_at',
          )
          .eq('email', normalizedEmail)
          .limit(1);
      final list = rows as List<dynamic>;
      if (list.isNotEmpty) {
        return GoogleSyncStateModel.fromJson(Map<String, dynamic>.from(list.first as Map));
      }
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] getSyncState failed: $e');
    }
    return GoogleSyncStateModel(email: normalizedEmail);
  }

  /// Saves Google OAuth credentials / tokens into `IMMBE2627.sb_google_sync_state`.
  /// Accepts raw `ya29...` tokens, `"Bearer ..."` strings, or OAuth Playground JSON blocks.
  Future<bool> saveGoogleCredentials({
    String email = defaultGoogleEmail,
    String? oauthClientId,
    String? oauthClientSecret,
    String? accessToken,
    String? refreshToken,
    int? expiresInSeconds,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    String? parsedAccess = accessToken;
    String? parsedRefresh = refreshToken;
    int? parsedExpires = expiresInSeconds;

    final rawAccessTrimmed = accessToken?.trim() ?? '';
    if (rawAccessTrimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(rawAccessTrimmed);
        if (decoded is Map) {
          parsedAccess = decoded['access_token']?.toString() ?? parsedAccess;
          parsedRefresh ??= decoded['refresh_token']?.toString();
          if (parsedExpires == null && decoded['expires_in'] is num) {
            parsedExpires = (decoded['expires_in'] as num).toInt();
          }
        }
      } catch (_) {}
    } else if (rawAccessTrimmed.toLowerCase().startsWith('bearer ')) {
      parsedAccess = rawAccessTrimmed.substring(7).trim();
    } else {
      parsedAccess = rawAccessTrimmed.replaceAll(RegExp(r'\s+'), '');
    }

    try {
      final existingRows = await _db.client
          .schema('IMMBE2627')
          .from('sb_google_sync_state')
          .select('oauth_client_id,oauth_client_secret,refresh_token,access_token,token_expires_at')
          .eq('email', normalizedEmail)
          .limit(1);
      final existingList = existingRows as List<dynamic>;
      final existing = existingList.isNotEmpty
          ? Map<String, dynamic>.from(existingList.first as Map)
          : <String, dynamic>{};

      final effectiveClientId = GoogleContactsMapper.nonEmptyOr(
          oauthClientId, existing['oauth_client_id']?.toString() ?? defaultClientId);
      final effectiveSecret = GoogleContactsMapper.nonEmptyOrNull(
          oauthClientSecret, existing['oauth_client_secret']?.toString());
      final effectiveRefresh = GoogleContactsMapper.nonEmptyOrNull(
          parsedRefresh, existing['refresh_token']?.toString());
      final effectiveAccess = GoogleContactsMapper.nonEmptyOrNull(
          parsedAccess, existing['access_token']?.toString());

      final expiresIso = (parsedExpires != null && parsedExpires > 0)
          ? DateTime.now().add(Duration(seconds: parsedExpires)).toIso8601String()
          : ((parsedAccess?.trim().isNotEmpty ?? false)
              ? DateTime.now().add(const Duration(minutes: 55)).toIso8601String()
              : existing['token_expires_at']?.toString());

      final hasToken = (effectiveAccess != null && effectiveAccess.isNotEmpty) ||
          (effectiveRefresh != null && effectiveRefresh.isNotEmpty);

      await _db.client.schema('IMMBE2627').from('sb_google_sync_state').upsert({
        'email': normalizedEmail,
        'oauth_client_id': effectiveClientId,
        'oauth_client_secret': effectiveSecret,
        'refresh_token': effectiveRefresh,
        'access_token': effectiveAccess,
        'token_expires_at': expiresIso,
        'sync_health': hasToken ? 'HEALTHY' : 'DISCONNECTED',
        'last_error': null,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'email');
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] saveGoogleCredentials failed: $e');
      return false;
    }
  }

  /// Clears stored Google OAuth tokens for clean re-authorization.
  Future<bool> disconnectGoogleAccount({String email = defaultGoogleEmail}) =>
      _updateSyncState(email.trim().toLowerCase(), {
        'access_token': null, 'refresh_token': null, 'token_expires_at': null,
        'sync_health': 'DISCONNECTED', 'last_error': null,
      });

  /// Cancels any active Desktop Loopback OAuth HTTP listener immediately.
  Future<void> cancelDesktopLoopbackOAuth() async {
    _oauthCancelledByUser = true;
    final srv = _activeOAuthServer;
    _activeOAuthServer = null;
    if (srv != null) {
      try {
        await srv.close(force: true);
      } catch (_) {}
    }
  }

  /// Launches clean Google OAuth 2.0 Playground (no URL hash fragment to avoid 500 error).
  Future<bool> launchOAuthPlaygroundHelper({String email = defaultGoogleEmail}) async {
    final url = Uri.parse('https://developers.google.com/oauthplayground/');
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] launchOAuthPlaygroundHelper failed: $e');
      return false;
    }
  }

  /// Standalone Desktop Loopback OAuth 2.0 flow on `http://localhost:8080` (with port-0 fallback).
  Future<PullResult> startDesktopLoopbackOAuth({
    String email = defaultGoogleEmail,
    String? clientId,
    String? clientSecret,
  }) async {
    if (kIsWeb) {
      return const PullResult(
        isSuccess: false, count: 0,
        message: 'Desktop Loopback OAuth requires Windows/Desktop client.',
        detail: 'Use Option B (OAuth Playground Token) or Import Google CSV.',
      );
    }

    await cancelDesktopLoopbackOAuth();
    _oauthCancelledByUser = false;

    final normalizedEmail = email.trim().toLowerCase();
    final stateModel = await getSyncState(email: normalizedEmail);
    final effectiveClientId = GoogleContactsMapper.nonEmptyOr(clientId, stateModel.oauthClientId);

    HttpServer? server;
    try {
      String redirectUri;
      try {
        server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080, shared: true);
        redirectUri = 'http://localhost:8080';
      } catch (_) {
        server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        redirectUri = 'http://127.0.0.1:${server.port}';
      }
      _activeOAuthServer = server;

      final verifier = _generateCodeVerifier();
      final oauthState = _generateCodeVerifier(length: 24);
      if (clientId != null || clientSecret != null) {
        await saveGoogleCredentials(
          email: normalizedEmail, oauthClientId: effectiveClientId, oauthClientSecret: clientSecret,
        );
      }

      final authUri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'response_type': 'code',
        'client_id': effectiveClientId,
        'redirect_uri': redirectUri,
        'scope': 'https://www.googleapis.com/auth/contacts',
        'access_type': 'offline',
        'prompt': 'consent',
        'include_granted_scopes': 'true',
        'login_hint': normalizedEmail,
        'code_challenge': verifier,
        'code_challenge_method': 'plain',
        'state': oauthState,
      });

      final launched = await launchUrl(authUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await cancelDesktopLoopbackOAuth();
        return const PullResult(isSuccess: false, count: 0, message: 'Could not open system browser for Google OAuth.');
      }

      String? authCode;
      String? authError;

      await for (final request in server.timeout(const Duration(minutes: 3))) {
        final params = request.uri.queryParameters;
        if (request.uri.path == '/favicon.ico' ||
            (!params.containsKey('code') && !params.containsKey('error'))) {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          continue;
        }
        authError = params['error'];
        if (params['state'] != oauthState) {
          authError = 'OAuth state mismatch';
        } else {
          authCode = params['code'];
        }
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.html;
        request.response.write(
          authCode != null
              ? '<html><body style="font-family:sans-serif;padding:32px;"><h2>Ambaji Sarees ERP Connected</h2><p>Authorized <b>$normalizedEmail</b>. You may close this tab.</p></body></html>'
              : '<html><body style="font-family:sans-serif;padding:32px;"><h2>Authorization Incomplete</h2><p>Error: ${authError ?? "Cancelled"}.</p></body></html>',
        );
        await request.response.close();
        break;
      }

      await _closeActiveOAuthServer();
      if (_oauthCancelledByUser) {
        return const PullResult(isSuccess: false, count: 0, message: 'Browser OAuth wait cancelled.');
      }
      if (authError != null || authCode == null || authCode.isEmpty) {
        return PullResult(isSuccess: false, count: 0, message: 'Google OAuth cancelled or failed (${authError ?? "no code"}).');
      }

      return await _exchangeAuthorizationCode(
        email: normalizedEmail, code: authCode, codeVerifier: verifier,
        redirectUri: redirectUri, clientId: effectiveClientId, clientSecret: clientSecret,
      );
    } on TimeoutException {
      await _closeActiveOAuthServer();
      return const PullResult(isSuccess: false, count: 0, message: 'Google OAuth timed out waiting for browser consent (3 mins).');
    } catch (e) {
      await _closeActiveOAuthServer();
      if (_oauthCancelledByUser) {
        return const PullResult(isSuccess: false, count: 0, message: 'Browser OAuth wait cancelled.');
      }
      debugPrint('[ServiceGoogleContacts] Loopback OAuth error: $e');
      return PullResult(isSuccess: false, count: 0, message: 'Desktop OAuth failed: $e');
    }
  }

  Future<void> _closeActiveOAuthServer() async {
    final srv = _activeOAuthServer;
    _activeOAuthServer = null;
    if (srv != null) {
      try {
        await srv.close(force: true);
      } catch (_) {}
    }
  }

  Future<PullResult> _exchangeAuthorizationCode({
    required String email,
    required String code,
    required String codeVerifier,
    required String redirectUri,
    required String clientId,
    String? clientSecret,
  }) async {
    try {
      final rows = await _db.client
          .schema('IMMBE2627')
          .from('sb_google_sync_state')
          .select('oauth_client_secret')
          .eq('email', email)
          .limit(1);
      final list = rows as List<dynamic>;
      final storedSecret = list.isNotEmpty
          ? list.first['oauth_client_secret']?.toString().trim()
          : null;
      final effectiveSecret =
          GoogleContactsMapper.nonEmptyOrNull(clientSecret, storedSecret);

      if (effectiveSecret == null || effectiveSecret.isEmpty) {
        final fnRes = await _db.client.functions.invoke('google-contacts-sync', body: {
          'action': 'exchange_oauth_code',
          'email': email,
          'code': code,
          'codeVerifier': codeVerifier,
          'redirectUri': redirectUri,
          'oauthClientId': clientId,
        });
        final data = fnRes.data;
        if (fnRes.status == 200 && data is Map && data['success'] == true) {
          return PullResult(isSuccess: true, count: 0, message: 'Connected $email via Google OAuth!');
        }
        return PullResult(
          isSuccess: false,
          count: 0,
          message: 'Google OAuth token exchange failed.',
          detail: (data is Map ? data['error']?.toString() : null) ??
              'Provide an OAuth Client Secret or paste an Access Token directly.',
        );
      }

      final decoded = await _postGoogleTokenEndpoint({
        'code': code,
        'client_id': clientId,
        'client_secret': effectiveSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
        'code_verifier': codeVerifier,
      });
      final accessToken = decoded?['access_token']?.toString();
      if (decoded == null || accessToken == null || accessToken.isEmpty) {
        return PullResult(
          isSuccess: false,
          count: 0,
          message: 'Google token exchange failed.',
          detail: decoded?['error_description']?.toString() ?? decoded?['error']?.toString(),
        );
      }

      await saveGoogleCredentials(
        email: email,
        oauthClientId: clientId,
        oauthClientSecret: effectiveSecret,
        accessToken: accessToken,
        refreshToken: decoded['refresh_token']?.toString(),
        expiresInSeconds:
            decoded['expires_in'] is num ? (decoded['expires_in'] as num).toInt() : 3600,
      );
      return PullResult(isSuccess: true, count: 0, message: 'Connected $email cleanly via Desktop OAuth!');
    } catch (e) {
      return PullResult(isSuccess: false, count: 0, message: 'Token exchange error: $e');
    }
  }

  Future<String?> _resolveValidAccessToken({required String email, bool forceRefresh = false}) async {
    try {
      final rows = await _db.client
          .schema('IMMBE2627')
          .from('sb_google_sync_state')
          .select('oauth_client_id,oauth_client_secret,refresh_token,access_token,token_expires_at')
          .eq('email', email)
          .limit(1);
      final list = rows as List<dynamic>;
      if (list.isEmpty) return null;

      final row = Map<String, dynamic>.from(list.first as Map);
      final currentAccess = row['access_token']?.toString().trim() ?? '';
      final refreshToken = row['refresh_token']?.toString().trim() ?? '';
      final clientId =
          GoogleContactsMapper.nonEmptyOr(row['oauth_client_id']?.toString(), defaultClientId);
      final clientSecret = row['oauth_client_secret']?.toString().trim() ?? '';
      final exp = row['token_expires_at'] != null
          ? DateTime.tryParse(row['token_expires_at'].toString())
          : null;

      final valid = currentAccess.isNotEmpty &&
          !forceRefresh &&
          (exp == null || DateTime.now().isBefore(exp.subtract(const Duration(minutes: 2))));
      if (valid) return currentAccess;
      if (refreshToken.isEmpty) return currentAccess.isNotEmpty && !forceRefresh ? currentAccess : null;

      if (clientSecret.isNotEmpty) {
        final json = await _postGoogleTokenEndpoint({
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        });
        final newAccess = json?['access_token']?.toString();
        if (json != null && newAccess != null && newAccess.isNotEmpty && json['error'] == null) {
          await saveGoogleCredentials(
            email: email,
            accessToken: newAccess,
            expiresInSeconds: json['expires_in'] is num ? (json['expires_in'] as num).toInt() : 3600,
          );
          return newAccess;
        }
      } else {
        final fnRes = await _db.client.functions
            .invoke('google-contacts-sync', body: {'action': 'refresh_token', 'email': email});
        final data = fnRes.data;
        if (fnRes.status == 200 && data is Map && data['access_token'] != null) {
          return data['access_token'].toString();
        }
      }
      return currentAccess.isNotEmpty ? currentAccess : null;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] _resolveValidAccessToken failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _postGoogleTokenEndpoint(Map<String, String> body) async {
    final res = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    final decoded = jsonDecode(res.body);
    return decoded is Map<String, dynamic>
        ? (res.statusCode == 200 ? decoded : {'error': decoded['error'], 'error_description': decoded['error_description'] ?? 'HTTP ${res.statusCode}'})
        : null;
  }

  // ── 2. LIVE GOOGLE PEOPLE API v1 PULL (7,000+ PAGINATED + SYNC TOKEN) ─────

  /// Pulls contacts + labels from Google People API v1 in 1,000-row pages
  /// and batch-upserts in 400-row chunks via `fn_upsert_google_contacts_batch`.
  Future<PullResult> pullFromGoogleWithProgress({
    String email = defaultGoogleEmail,
    bool forceFullSync = false,
    required void Function(double progress, String stepMessage) onProgress,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      onProgress(0.05, 'Checking OAuth session for $normalizedEmail...');
      String? token = await _resolveValidAccessToken(email: normalizedEmail);
      if (token == null || token.isEmpty) {
        return PullResult(
          isSuccess: false,
          count: 0,
          message: 'Google OAuth authorization required for $normalizedEmail.',
          detail: 'Click "Connect Google Account" to authorize or paste an Access Token, or use Import Google CSV.',
        );
      }

      await _updateSyncState(normalizedEmail, {'sync_health': 'SYNCING', 'last_error': null});
      onProgress(0.10, 'Fetching Google Contact Labels...');
      var groupsMap = await _fetchContactGroupsMap(token);
      if (groupsMap == null) {
        final refreshed = await _resolveValidAccessToken(email: normalizedEmail, forceRefresh: true);
        if (refreshed != null && refreshed.isNotEmpty) {
          token = refreshed;
          groupsMap = await _fetchContactGroupsMap(token);
        }
      }

      final state = await getSyncState(email: normalizedEmail);
      final effectiveGroupsMap = groupsMap ?? state.contactGroupsMap;
      if (effectiveGroupsMap.isNotEmpty) {
        await _updateSyncState(normalizedEmail, {'contact_groups_map': effectiveGroupsMap});
      }

      final String? syncToken = forceFullSync ? null : state.nextSyncToken;
      final isDeltaRun = syncToken != null && syncToken.isNotEmpty;
      var pullOutcome = await _executeConnectionsPullLoop(
        email: normalizedEmail, accessToken: token, syncToken: syncToken,
        groupsMap: effectiveGroupsMap, onProgress: onProgress,
      );

      if (pullOutcome.needsFullReset) {
        onProgress(0.18, 'Google sync cursor expired (410) — switching to Full Pull...');
        await _updateSyncState(normalizedEmail, {'next_sync_token': null});
        pullOutcome = await _executeConnectionsPullLoop(
          email: normalizedEmail, accessToken: token, syncToken: null,
          groupsMap: effectiveGroupsMap, onProgress: onProgress,
        );
        return await _finalizeGooglePullState(
          email: normalizedEmail, isDeltaRun: false, outcome: pullOutcome, onProgress: onProgress,
        );
      }

      return await _finalizeGooglePullState(
        email: normalizedEmail, isDeltaRun: isDeltaRun, outcome: pullOutcome, onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] pullFromGoogleWithProgress error: $e');
      await _recordSyncError(normalizedEmail, e.toString());
      onProgress(1.0, 'Sync error: $e');
      return PullResult(isSuccess: false, count: 0, message: 'Failed to sync contacts from Google.', detail: e.toString());
    }
  }

  Future<Map<String, String>?> _fetchContactGroupsMap(String accessToken) async {
    try {
      final Map<String, String> map = {};
      String? pageToken;
      do {
        final uri = Uri.https('people.googleapis.com', '/v1/contactGroups', {
          'pageSize': '1000',
          if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
        });
        final res = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $accessToken', 'Accept': 'application/json'},
        );
        if (res.statusCode == 401) return null;
        if (res.statusCode != 200) break;

        final json = jsonDecode(res.body) as Map<String, dynamic>;
        for (final g in (json['contactGroups'] as List<dynamic>? ?? const [])) {
          if (g is! Map) continue;
          final rn = g['resourceName']?.toString() ?? '';
          final name = g['formattedName']?.toString().trim() ?? g['name']?.toString().trim() ?? '';
          if (rn.isNotEmpty && name.isNotEmpty) map[rn] = name;
        }
        pageToken = json['nextPageToken']?.toString();
      } while (pageToken != null && pageToken.isNotEmpty);
      return map;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] _fetchContactGroupsMap error: $e');
      return {};
    }
  }

  Future<_GooglePullLoopResult> _executeConnectionsPullLoop({
    required String email,
    required String accessToken,
    required String? syncToken,
    required Map<String, String> groupsMap,
    required void Function(double progress, String stepMessage) onProgress,
  }) async {
    String token = accessToken;
    String? pageToken;
    String? latestNextSyncToken;
    int pageNumber = 1;
    int totalUpserted = 0;
    int totalDeleted = 0;

    do {
      final pct = (0.15 + (pageNumber * 0.08)).clamp(0.15, 0.88);
      onProgress(pct, 'Fetching Google page $pageNumber ($totalUpserted synced so far)...');

      final uri = Uri.https('people.googleapis.com', '/v1/people/me/connections', {
        'pageSize': '1000',
        'personFields': _personFields,
        'requestSyncToken': 'true',
        if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
        if (syncToken != null && syncToken.isNotEmpty) 'syncToken': syncToken,
      });

      var response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 401) {
        final refreshed = await _resolveValidAccessToken(email: email, forceRefresh: true);
        if (refreshed != null && refreshed.isNotEmpty && refreshed != token) {
          token = refreshed;
          response = await http.get(
            uri,
            headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
          );
        }
      }
      if (response.statusCode == 410 && syncToken != null) {
        return const _GooglePullLoopResult(needsFullReset: true);
      }
      if (response.statusCode != 200) {
        return _GooglePullLoopResult(
          errorMessage: 'Google People API HTTP ${response.statusCode}: ${response.body}',
          upsertedCount: totalUpserted,
          deletedCount: totalDeleted,
        );
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final connections = payload['connections'] as List<dynamic>? ?? const [];
      pageToken = payload['nextPageToken']?.toString();
      if (payload['nextSyncToken'] != null) {
        latestNextSyncToken = payload['nextSyncToken']?.toString();
      }

      if (connections.isNotEmpty) {
        final mappedRows = connections
            .whereType<Map>()
            .map((m) => GoogleContactsMapper.mapGooglePersonToRow(
                Map<String, dynamic>.from(m), groupsMap))
            .whereType<Map<String, dynamic>>()
            .toList();

        for (int i = 0; i < mappedRows.length; i += _batchSize) {
          final chunk = mappedRows.sublist(i, min(i + _batchSize, mappedRows.length));
          final rpcRes = await _callUpsertBatchRpc(
            rows: chunk,
            accountEmail: email,
            importSource: 'GOOGLE_API',
          );
          totalUpserted += rpcRes.upserted;
          totalDeleted += rpcRes.deleted;
        }
      }
      pageNumber++;
    } while (pageToken != null && pageToken.isNotEmpty);

    return _GooglePullLoopResult(
      upsertedCount: totalUpserted,
      deletedCount: totalDeleted,
      nextSyncToken: latestNextSyncToken,
    );
  }

  Future<PullResult> _finalizeGooglePullState({
    required String email,
    required bool isDeltaRun,
    required _GooglePullLoopResult outcome,
    required void Function(double progress, String stepMessage) onProgress,
  }) async {
    if (outcome.errorMessage != null) {
      await _recordSyncError(email, outcome.errorMessage!);
      onProgress(1.0, 'Sync notice: ${outcome.errorMessage}');
      return PullResult(
        isSuccess: false, count: outcome.upsertedCount, deletedCount: outcome.deletedCount,
        message: 'Google API returned an error.', detail: outcome.errorMessage,
      );
    }

    final nowIso = DateTime.now().toIso8601String();
    await _updateSyncState(email, {
      'sync_health': 'HEALTHY',
      'last_error': null,
      if (outcome.nextSyncToken != null && outcome.nextSyncToken!.isNotEmpty)
        'next_sync_token': outcome.nextSyncToken,
      if (isDeltaRun) 'last_delta_sync_at': nowIso else 'last_full_sync_at': nowIso,
    });

    final stateAfter = await getSyncState(email: email);
    onProgress(1.0, 'Completed! Synced ${outcome.upsertedCount} contacts (${stateAfter.totalGoogleContacts} total active).');
    return PullResult(
      isSuccess: true, count: outcome.upsertedCount, deletedCount: outcome.deletedCount,
      message: 'Synced ${outcome.upsertedCount} contacts from $email (${stateAfter.totalGoogleContacts} active in ERP).',
    );
  }

  // ── 3. CSV BATCH IMPORTER & SHARED RPC DISPATCH ──────────────────────────

  /// Parses an official Google Contacts CSV export and streams 400-row chunks to RPC.
  Future<PullResult> importGoogleContactsCsvWithProgress({
    required String csvContent,
    String accountEmail = defaultGoogleEmail,
    required void Function(double progress, String stepMessage) onProgress,
  }) async {
    final normalizedEmail = accountEmail.trim().toLowerCase();
    try {
      onProgress(0.05, 'Parsing Google Contacts CSV (RFC-4180)...');
      final parsedRows = GoogleContactsMapper.mapCsvTableToRows(GoogleContactsMapper.parseRfc4180Csv(csvContent));
      if (parsedRows.isEmpty) {
        return const PullResult(isSuccess: false, count: 0, message: 'No valid contact rows detected in the selected CSV.');
      }

      int totalUpserted = 0;
      final totalChunks = (parsedRows.length / _batchSize).ceil();
      for (int i = 0; i < parsedRows.length; i += _batchSize) {
        final chunkIndex = (i ~/ _batchSize) + 1;
        final end = min(i + _batchSize, parsedRows.length);
        onProgress(
          (0.15 + ((chunkIndex / max(totalChunks, 1)) * 0.80)).clamp(0.15, 0.95),
          'Uploading batch $chunkIndex/$totalChunks ($end / ${parsedRows.length} contacts)...',
        );
        final res = await _callUpsertBatchRpc(
          rows: parsedRows.sublist(i, end), accountEmail: normalizedEmail, importSource: 'GOOGLE_CSV',
        );
        totalUpserted += res.upserted;
      }

      final stateAfter = await getSyncState(email: normalizedEmail);
      onProgress(1.0, 'Imported $totalUpserted contacts into IMMBE2627.sb_contacts!');
      return PullResult(
        isSuccess: true, count: totalUpserted,
        message: 'Imported $totalUpserted contacts from Google CSV (${stateAfter.totalGoogleContacts} total active).',
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] CSV import error: $e');
      onProgress(1.0, 'CSV import failed: $e');
      return PullResult(isSuccess: false, count: 0, message: 'Failed to import CSV: $e');
    }
  }

  Future<_BatchRpcOutcome> _callUpsertBatchRpc({
    required List<Map<String, dynamic>> rows,
    required String accountEmail,
    required String importSource,
  }) async {
    final res = await _db.client.schema('IMMBE2627').rpc('fn_upsert_google_contacts_batch', params: {
      'p_rows': rows, 'p_account_email': accountEmail, 'p_import_source': importSource,
    });
    if (res is Map) {
      return _BatchRpcOutcome(
        upserted: res['upserted'] is num ? (res['upserted'] as num).toInt() : rows.length,
        deleted: res['deleted'] is num ? (res['deleted'] as num).toInt() : 0,
      );
    }
    return _BatchRpcOutcome(upserted: rows.length, deleted: 0);
  }

  // ── 4. PAGINATED QUERIES & MANUAL ERP LINKS ──────────────────────────────

  /// Fetches a single server-side page of `IMMBE2627.sb_contacts`.
  Future<ContactsPageResult> fetchContactsPage({
    String accountEmail = defaultGoogleEmail,
    String? searchQuery,
    ContactsFilterMode filterMode = ContactsFilterMode.all,
    String? groupLabel,
    int offset = 0,
    int limit = 100,
  }) async {
    final normalizedEmail = accountEmail.trim().toLowerCase();
    try {
      dynamic countQuery = _applyFilters(_baseContactsQuery('id', normalizedEmail),
          searchQuery: searchQuery, filterMode: filterMode, groupLabel: groupLabel);
      dynamic dataQuery = _applyFilters(_baseContactsQuery(_listColumns, normalizedEmail),
          searchQuery: searchQuery, filterMode: filterMode, groupLabel: groupLabel);
      final countRes = await countQuery.count(CountOption.exact);
      final response = await dataQuery.order('display_name', ascending: true).range(offset, offset + limit - 1);
      final items = (response as List<dynamic>)
          .map((e) => GoogleContact.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return ContactsPageResult(items: items, totalCount: countRes.count, offset: offset, limit: limit);
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] fetchContactsPage error: $e');
      return ContactsPageResult(
        items: const [], totalCount: 0, offset: offset, limit: limit, error: _db.handleDbError(e),
      );
    }
  }

  dynamic _baseContactsQuery(String columns, String normalizedEmail) => _db.client
      .schema('IMMBE2627')
      .from('sb_contacts')
      .select(columns)
      .eq('google_account_email', normalizedEmail)
      .neq('sync_status', 'DELETED_ON_GOOGLE');

  dynamic _applyFilters(dynamic query, {String? searchQuery, required ContactsFilterMode filterMode, String? groupLabel}) {
    var q = query;
    switch (filterMode) {
      case ContactsFilterMode.unlinked:
        q = q.eq('linked_master_codes', '{}').eq('linked_group_codes', '{}');
      case ContactsFilterMode.linked:
        q = q.or('linked_master_codes.neq.{},linked_group_codes.neq.{}');
      case ContactsFilterMode.pendingPush:
        q = q.inFilter('sync_status', const ['PENDING_PUSH', 'LOCAL_ONLY']);
      case ContactsFilterMode.starred:
        q = q.eq('is_starred', true);
      case ContactsFilterMode.all:
        break;
    }
    if (groupLabel != null && groupLabel.trim().isNotEmpty && groupLabel != 'ALL') {
      q = q.contains('group_labels', [groupLabel.trim()]);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final safeTerm = searchQuery.trim().replaceAll(RegExp(r'[(),]'), ' ').trim();
      if (safeTerm.isNotEmpty) {
        final digitsOnly = safeTerm.replaceAll(RegExp(r'\D'), '');
        final orParts = <String>[
          'display_name.ilike.%$safeTerm%', 'primary_phone.ilike.%$safeTerm%',
          'company_name.ilike.%$safeTerm%', 'primary_email.ilike.%$safeTerm%', 'notes_text.ilike.%$safeTerm%',
        ];
        if (digitsOnly.length >= 6) {
          final tail10 = digitsOnly.length >= 10 ? digitsOnly.substring(digitsOnly.length - 10) : digitsOnly;
          orParts.add('phone_norms.cs.{$tail10}');
        }
        q = q.or(orParts.join(','));
      }
    }
    return q;
  }

  /// Fetches lightweight `raw_person` JSON on demand for inspector view.
  Future<Map<String, dynamic>?> fetchContactRawPerson(String contactId) async {
    try {
      final rows = await _db.client.schema('IMMBE2627').from('sb_contacts').select('raw_person').eq('id', contactId).limit(1);
      final list = rows as List<dynamic>;
      if (list.isNotEmpty && list.first['raw_person'] is Map) {
        return Map<String, dynamic>.from(list.first['raw_person'] as Map);
      }
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] fetchContactRawPerson failed: $e');
    }
    return null;
  }

  Future<List<T>> _searchErpLookup<T>({
    required String table,
    required String columns,
    required List<String> searchColumns,
    String? searchQuery,
    required int limit,
    required T Function(Map<String, dynamic>) mapper,
  }) async {
    try {
      dynamic query = _db.client.schema('IMMBE2627').from(table).select(columns);
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().replaceAll(RegExp(r'[(),]'), ' ').trim();
        if (term.isNotEmpty) {
          query = query.or(searchColumns.map((c) => '$c.ilike.%$term%').join(','));
        }
      }
      final response = await query.order('NAME', ascending: true).limit(limit);
      return (response as List<dynamic>)
          .map((j) => mapper(Map<String, dynamic>.from(j as Map)))
          .toList();
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] Lookup $table failed: $e');
      return const [];
    }
  }

  Future<List<MasterPartyOption>> searchMasterParties({String? searchQuery, int limit = 50}) =>
      _searchErpLookup<MasterPartyOption>(
        table: 'sq_MASTER',
        columns: 'code,NAME,GCODE,CITY1,STATION,MOBILE',
        searchColumns: const ['NAME', 'code', 'CITY1', 'STATION', 'MOBILE'],
        searchQuery: searchQuery,
        limit: limit,
        mapper: MasterPartyOption.fromJson,
      );

  Future<List<AccountGroupOption>> searchAccountGroups({String? searchQuery, int limit = 50}) =>
      _searchErpLookup<AccountGroupOption>(
        table: 'sq_ACGROUP',
        columns: 'gcode,NAME,CITY1,CONTACT,MOBILE',
        searchColumns: const ['NAME', 'gcode', 'CITY1', 'MOBILE'],
        searchQuery: searchQuery,
        limit: limit,
        mapper: AccountGroupOption.fromJson,
      );

  Future<bool> addErpLink({required GoogleContact contact, required ErpContactLink link}) async {
    if (link.code.trim().isEmpty) return false;
    final masterCodes = <String>{...contact.linkedMasterCodes};
    final groupCodes = <String>{...contact.linkedGroupCodes};
    if (link.kind == 'GROUP') {
      groupCodes.add(link.code);
    } else {
      masterCodes.add(link.code);
    }
    final links = [
      ...contact.erpLinks.where((l) => !(l.kind == link.kind && l.code == link.code)),
      link,
    ];
    return _persistContactLinks(
      contactId: contact.id, masterCodes: masterCodes.toList(), groupCodes: groupCodes.toList(), links: links,
    );
  }

  Future<bool> removeErpLink({required GoogleContact contact, required String kind, required String code}) =>
      _persistContactLinks(
        contactId: contact.id,
        masterCodes: contact.linkedMasterCodes.where((c) => !(kind == 'PARTY' && c == code)).toList(),
        groupCodes: contact.linkedGroupCodes.where((c) => !(kind == 'GROUP' && c == code)).toList(),
        links: contact.erpLinks.where((l) => !(l.kind == kind && l.code == code)).toList(),
      );

  Future<bool> _persistContactLinks({
    required String contactId,
    required List<String> masterCodes,
    required List<String> groupCodes,
    required List<ErpContactLink> links,
  }) async {
    try {
      await _db.client.schema('IMMBE2627').from('sb_contacts').update({
        'linked_master_codes': masterCodes,
        'linked_group_codes': groupCodes,
        'erp_links': links.map((e) => e.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', contactId);
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] _persistContactLinks failed: $e');
      return false;
    }
  }

  Future<bool> _updateSyncState(String email, Map<String, dynamic> fields) async {
    try {
      await _db.client.schema('IMMBE2627').from('sb_google_sync_state').update({
        ...fields,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('email', email);
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] _updateSyncState failed: $e');
      return false;
    }
  }

  Future<void> _recordSyncError(String email, String message) async {
    final truncated = message.length > 500 ? message.substring(0, 500) : message;
    await _updateSyncState(email, {'sync_health': 'ERROR', 'last_error': truncated});
  }

  static String _generateCodeVerifier({int length = 64}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}

class _GooglePullLoopResult {
  final int upsertedCount, deletedCount;
  final String? nextSyncToken, errorMessage;
  final bool needsFullReset;

  const _GooglePullLoopResult({
    this.upsertedCount = 0, this.deletedCount = 0,
    this.nextSyncToken, this.errorMessage, this.needsFullReset = false,
  });
}

class _BatchRpcOutcome {
  final int upserted, deleted;
  const _BatchRpcOutcome({required this.upserted, required this.deleted});
}
