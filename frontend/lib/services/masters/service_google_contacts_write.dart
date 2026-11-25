/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Two-way Google People API v1 write extension (`ServiceGoogleContactsWriteExt`)
     for `ServiceGoogleContacts` (`service_google_contacts.dart`):
       1) `updateContactAndPush`: Live `PATCH ...:updateContact` with `etag`
          optimistic concurrency + automatic stale-etag retry once.
       2) `createContactAndPush`: Live `POST .../v1/people:createContact` and
          local offline fallback (`LOCAL_ONLY`).
       3) `pushPendingContactsToGoogle`: Drains all `PENDING_PUSH` and
          `LOCAL_ONLY` rows to `design.ambaji@gmail.com`.
       4) `modifyContactGroupMembership`: Toggles Google Contact Labels live
          via `POST /v1/{contactGroup}/members:modify`.
       5) `fetchContactKpiCounts` & `fetchSisterPartiesForContact`: Stage 9.3
          KPI counts and Owned Account Group (`sq_ACGROUP` -> `sq_MASTER`)
          sister-firm rollup.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - After Google returns HTTP 200 on `:updateContact`, re-upserts via
     `fn_upsert_google_contacts_batch` and explicitly clears `sync_status` to
     `'SYNCED'` & `dirty_fields` to `'{}'` because the RPC preserves prior
     `PENDING_PUSH` flags on pull.
   - Leaves `sq_MASTER` and `sq_ACGROUP` strictly read-only.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Always check `if (res.statusCode == 401)` -> refresh OAuth token & retry
     once; on `400 / 409 / 412` stale `etag`, fetch latest `metadata` & retry.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Display-name Caller ID enrichment formatting rules are deferred per user.
================================================================================
*/

part of 'service_google_contacts.dart';

/// Stage 9.3 Two-Way Google Push, KPI & Sister-Firm Rollup extension.
extension ServiceGoogleContactsWriteExt on ServiceGoogleContacts {
  /// Updates local `sb_contacts` immediately and optionally pushes live via
  /// Google People API v1 `PATCH :updateContact` with `etag` concurrency guard.
  Future<PullResult> updateContactAndPush({
    required GoogleContact updated,
    bool pushImmediately = true,
  }) async {
    final normalizedEmail = updated.googleAccountEmail.trim().toLowerCase();
    try {
      final localFields = GoogleContactsMapper.buildLocalWriteFields(
        updated,
        syncStatus: 'PENDING_PUSH',
      );
      if (updated.id.isNotEmpty) {
        await _db.client
            .schema('IMMBE2627')
            .from('sb_contacts')
            .update(localFields)
            .eq('id', updated.id);
      }

      if (!pushImmediately) {
        return const PullResult(
          isSuccess: true,
          count: 1,
          message: 'Saved locally & queued for Google Push.',
        );
      }

      if (!updated.resourceName.startsWith('people/')) {
        return await createContactAndPush(draft: updated, pushImmediately: true);
      }

      String? token = await _resolveValidAccessToken(email: normalizedEmail);
      if (token == null || token.isEmpty) {
        return const PullResult(
          isSuccess: true,
          count: 1,
          message: 'Saved locally (offline). Connect Google OAuth to push.',
        );
      }

      var effectiveContact = updated;
      if ((effectiveContact.etag ?? '').trim().isEmpty) {
        final refreshedMeta =
            await _fetchRemoteContactMetadata(effectiveContact.resourceName, token);
        if (refreshedMeta != null) {
          effectiveContact = effectiveContact.copyWith(
            etag: refreshedMeta['etag']?.toString(),
            googleMetadata: refreshedMeta['metadata'] is Map
                ? Map<String, dynamic>.from(refreshedMeta['metadata'] as Map)
                : effectiveContact.googleMetadata,
          );
        }
      }

      final uri = Uri.https(
        'people.googleapis.com',
        '/v1/${effectiveContact.resourceName}:updateContact',
        {
          'updatePersonFields':
              'names,phoneNumbers,emailAddresses,organizations,addresses,biographies',
          'personFields': ServiceGoogleContacts._personFields,
        },
      );

      var res = await _sendAuthorizedWrite(
        method: 'PATCH',
        uri: uri,
        token: token,
        body: GoogleContactsMapper.buildGooglePersonWritePayload(
          effectiveContact,
          includeEtag: true,
        ),
      );

      if (res.statusCode == 401) {
        final refreshed =
            await _resolveValidAccessToken(email: normalizedEmail, forceRefresh: true);
        if (refreshed != null && refreshed.isNotEmpty) {
          token = refreshed;
          res = await _sendAuthorizedWrite(
            method: 'PATCH',
            uri: uri,
            token: token,
            body: GoogleContactsMapper.buildGooglePersonWritePayload(
              effectiveContact,
              includeEtag: true,
            ),
          );
        }
      }

      if (res.statusCode == 400 || res.statusCode == 409 || res.statusCode == 412) {
        final freshMeta =
            await _fetchRemoteContactMetadata(effectiveContact.resourceName, token);
        if (freshMeta != null && freshMeta['etag'] != null) {
          effectiveContact = effectiveContact.copyWith(
            etag: freshMeta['etag'].toString(),
            googleMetadata: freshMeta['metadata'] is Map
                ? Map<String, dynamic>.from(freshMeta['metadata'] as Map)
                : effectiveContact.googleMetadata,
          );
          res = await _sendAuthorizedWrite(
            method: 'PATCH',
            uri: uri,
            token: token,
            body: GoogleContactsMapper.buildGooglePersonWritePayload(
              effectiveContact,
              includeEtag: true,
            ),
          );
        }
      }

      if (res.statusCode != 200) {
        return PullResult(
          isSuccess: false,
          count: 0,
          message: 'Saved locally, but Google Push failed (HTTP ${res.statusCode}).',
          detail: res.body,
        );
      }

      final personJson = jsonDecode(res.body) as Map<String, dynamic>;
      final syncState = await getSyncState(email: normalizedEmail);
      final mappedRow = GoogleContactsMapper.mapGooglePersonToRow(
        personJson,
        syncState.contactGroupsMap,
      );
      if (mappedRow != null) {
        await _callUpsertBatchRpc(
          rows: [mappedRow],
          accountEmail: normalizedEmail,
          importSource: 'GOOGLE_API',
        );
        await _db.client
            .schema('IMMBE2627')
            .from('sb_contacts')
            .update({
              'sync_status': 'SYNCED',
              'dirty_fields': const <String>[],
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('resource_name', effectiveContact.resourceName);
      }

      await _updateSyncState(normalizedEmail, {
        'last_push_at': DateTime.now().toUtc().toIso8601String(),
      });

      return PullResult(
        isSuccess: true,
        count: 1,
        message: 'Updated "${effectiveContact.displayName}" on Google Contacts.',
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] updateContactAndPush error: $e');
      return PullResult(
        isSuccess: false,
        count: 0,
        message: 'Update failed: $e',
      );
    }
  }

  /// Creates a new contact in Google Contacts (`POST people:createContact`) or saves
  /// offline as `LOCAL_ONLY` in `"IMMBE2627"."sb_contacts"`.
  Future<PullResult> createContactAndPush({
    required GoogleContact draft,
    bool pushImmediately = true,
  }) async {
    final normalizedEmail = draft.googleAccountEmail.trim().toLowerCase();
    try {
      String? token = pushImmediately
          ? await _resolveValidAccessToken(email: normalizedEmail)
          : null;

      if (pushImmediately && token != null && token.isNotEmpty) {
        final uri = Uri.https(
          'people.googleapis.com',
          '/v1/people:createContact',
          {'personFields': ServiceGoogleContacts._personFields},
        );
        final payload = GoogleContactsMapper.buildGooglePersonWritePayload(
          draft,
          includeEtag: false,
        );
        var res = await _sendAuthorizedWrite(
          method: 'POST',
          uri: uri,
          token: token,
          body: payload,
        );
        if (res.statusCode == 401) {
          final refreshed = await _resolveValidAccessToken(
            email: normalizedEmail,
            forceRefresh: true,
          );
          if (refreshed != null && refreshed.isNotEmpty) {
            token = refreshed;
            res = await _sendAuthorizedWrite(
              method: 'POST',
              uri: uri,
              token: token,
              body: payload,
            );
          }
        }

        if (res.statusCode == 200) {
          final personJson = jsonDecode(res.body) as Map<String, dynamic>;
          final syncState = await getSyncState(email: normalizedEmail);
          final mappedRow = GoogleContactsMapper.mapGooglePersonToRow(
            personJson,
            syncState.contactGroupsMap,
          );
          if (mappedRow != null) {
            mappedRow['linked_group_codes'] = draft.linkedGroupCodes;
            mappedRow['linked_master_codes'] = draft.linkedMasterCodes;
            mappedRow['erp_links'] =
                draft.erpLinks.map((e) => e.toJson()).toList();
            mappedRow['is_starred'] = draft.isStarred;
            await _callUpsertBatchRpc(
              rows: [mappedRow],
              accountEmail: normalizedEmail,
              importSource: 'GOOGLE_API',
            );
            final newResource = mappedRow['resource_name']?.toString() ?? '';
            if (newResource.isNotEmpty) {
              await _db.client
                  .schema('IMMBE2627')
                  .from('sb_contacts')
                  .update({
                    'sync_status': 'SYNCED',
                    'dirty_fields': const <String>[],
                  })
                  .eq('resource_name', newResource);
            }
            if (draft.id.isNotEmpty && !draft.resourceName.startsWith('people/')) {
              await _db.client
                  .schema('IMMBE2627')
                  .from('sb_contacts')
                  .delete()
                  .eq('id', draft.id);
            }
            await _updateSyncState(normalizedEmail, {
              'last_push_at': DateTime.now().toUtc().toIso8601String(),
            });
            return PullResult(
              isSuccess: true,
              count: 1,
              message: 'Created "${mappedRow['display_name']}" & synced to Google.',
            );
          }
        } else if (pushImmediately) {
          await _saveOfflineContactDraft(draft, normalizedEmail);
          return PullResult(
            isSuccess: false,
            count: 0,
            message: 'Saved offline draft; Google returned HTTP ${res.statusCode}.',
            detail: res.body,
          );
        }
      }

      await _saveOfflineContactDraft(draft, normalizedEmail);
      return const PullResult(
        isSuccess: true,
        count: 1,
        message: 'Saved contact locally (LOCAL_ONLY) & queued for Google Push.',
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] createContactAndPush error: $e');
      return PullResult(isSuccess: false, count: 0, message: 'Create failed: $e');
    }
  }

  Future<void> _saveOfflineContactDraft(
    GoogleContact draft,
    String normalizedEmail,
  ) async {
    final localResource = draft.resourceName.trim().isNotEmpty
        ? draft.resourceName.trim()
        : 'local/${DateTime.now().millisecondsSinceEpoch}';
    final fields = GoogleContactsMapper.buildLocalWriteFields(
      draft,
      syncStatus: localResource.startsWith('people/') ? 'PENDING_PUSH' : 'LOCAL_ONLY',
    );
    await _db.client.schema('IMMBE2627').from('sb_contacts').upsert({
      'google_account_email': normalizedEmail,
      'resource_name': localResource,
      'import_source': 'ERP_MANUAL',
      ...fields,
    }, onConflict: 'resource_name');
  }

  /// Pushes all `PENDING_PUSH` and `LOCAL_ONLY` rows to Google People API v1.
  Future<PullResult> pushPendingContactsToGoogle({
    String email = ServiceGoogleContacts.defaultGoogleEmail,
    void Function(double progress, String stepMessage)? onProgress,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      onProgress?.call(0.05, 'Checking pending local edits for $normalizedEmail...');
      final rows = await _db.client
          .schema('IMMBE2627')
          .from('sb_contacts')
          .select(ServiceGoogleContacts._listColumns)
          .eq('google_account_email', normalizedEmail)
          .inFilter('sync_status', const ['PENDING_PUSH', 'LOCAL_ONLY'])
          .limit(500);

      final contacts = (rows as List<dynamic>)
          .map((e) => GoogleContact.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (contacts.isEmpty) {
        onProgress?.call(1.0, 'All contacts are already synced with Google.');
        return const PullResult(
          isSuccess: true,
          count: 0,
          message: 'No pending local edits in push queue.',
        );
      }

      int pushed = 0;
      String? lastErr;
      for (int i = 0; i < contacts.length; i++) {
        final c = contacts[i];
        onProgress?.call(
          ((i + 1) / contacts.length).clamp(0.1, 0.95),
          'Pushing ${i + 1}/${contacts.length}: ${c.displayName}...',
        );
        final res = c.resourceName.startsWith('people/')
            ? await updateContactAndPush(updated: c, pushImmediately: true)
            : await createContactAndPush(draft: c, pushImmediately: true);
        if (res.isSuccess) {
          pushed++;
        } else {
          lastErr = res.detail ?? res.message;
        }
      }

      onProgress?.call(1.0, 'Pushed $pushed / ${contacts.length} contacts to Google.');
      return PullResult(
        isSuccess: pushed == contacts.length || pushed > 0,
        count: pushed,
        message: 'Pushed $pushed of ${contacts.length} pending contacts to Google.',
        detail: lastErr,
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] pushPendingContactsToGoogle error: $e');
      return PullResult(isSuccess: false, count: 0, message: 'Push failed: $e');
    }
  }

  /// Adds or removes a contact from a Google Contact Group label via People API v1.
  Future<PullResult> modifyContactGroupMembership({
    required GoogleContact contact,
    required String groupResourceName,
    required bool add,
  }) async {
    final normalizedEmail = contact.googleAccountEmail.trim().toLowerCase();
    if (!contact.resourceName.startsWith('people/')) {
      return const PullResult(
        isSuccess: false,
        count: 0,
        message: 'Push this local contact to Google before assigning Google Labels.',
      );
    }
    try {
      var token = await _resolveValidAccessToken(email: normalizedEmail);
      if (token == null || token.isEmpty) {
        return const PullResult(
          isSuccess: false,
          count: 0,
          message: 'Connect Google OAuth first to update Google Labels.',
        );
      }
      final uri = Uri.https(
        'people.googleapis.com',
        '/v1/$groupResourceName/members:modify',
      );
      var res = await _sendAuthorizedWrite(
        method: 'POST',
        uri: uri,
        token: token,
        body: {
          if (add) 'resourceNamesToAdd': [contact.resourceName],
          if (!add) 'resourceNamesToRemove': [contact.resourceName],
        },
      );
      if (res.statusCode == 401) {
        final refreshed = await _resolveValidAccessToken(
          email: normalizedEmail,
          forceRefresh: true,
        );
        if (refreshed != null && refreshed.isNotEmpty) {
          token = refreshed;
          res = await _sendAuthorizedWrite(
            method: 'POST',
            uri: uri,
            token: token,
            body: {
              if (add) 'resourceNamesToAdd': [contact.resourceName],
              if (!add) 'resourceNamesToRemove': [contact.resourceName],
            },
          );
        }
      }
      if (res.statusCode != 200) {
        return PullResult(
          isSuccess: false,
          count: 0,
          message: 'Google label update failed (HTTP ${res.statusCode}).',
          detail: res.body,
        );
      }

      final getUri = Uri.https(
        'people.googleapis.com',
        '/v1/${contact.resourceName}',
        {'personFields': ServiceGoogleContacts._personFields},
      );
      final personRes = await http.get(
        getUri,
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (personRes.statusCode == 200) {
        final state = await getSyncState(email: normalizedEmail);
        final mapped = GoogleContactsMapper.mapGooglePersonToRow(
          jsonDecode(personRes.body) as Map<String, dynamic>,
          state.contactGroupsMap,
        );
        if (mapped != null) {
          await _callUpsertBatchRpc(
            rows: [mapped],
            accountEmail: normalizedEmail,
            importSource: 'GOOGLE_API',
          );
        }
      }
      return PullResult(
        isSuccess: true,
        count: 1,
        message: add ? 'Added Google Label.' : 'Removed Google Label.',
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] modifyContactGroupMembership error: $e');
      return PullResult(isSuccess: false, count: 0, message: 'Label error: $e');
    }
  }

  /// Flips `is_starred` on `sb_contacts` (and updates `contactGroups/starred` when online).
  Future<bool> toggleStarContact(GoogleContact contact) async {
    final next = !contact.isStarred;
    try {
      await _db.client
          .schema('IMMBE2627')
          .from('sb_contacts')
          .update({
            'is_starred': next,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', contact.id);

      if (contact.resourceName.startsWith('people/')) {
        unawaited(
          modifyContactGroupMembership(
            contact: contact,
            groupResourceName: 'contactGroups/starred',
            add: next,
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] toggleStarContact failed: $e');
      return false;
    }
  }

  /// Persists the Continuous 5-Minute Delta Sync toggle in `sb_google_sync_state`.
  Future<bool> toggleContinuousSync({
    required bool enabled,
    String email = ServiceGoogleContacts.defaultGoogleEmail,
  }) =>
      _updateSyncState(
        email.trim().toLowerCase(),
        {'is_continuous_sync_enabled': enabled},
      );

  Future<int> _execCount(dynamic query) async {
    final res = await query.count(CountOption.exact);
    return (res.count as num).toInt();
  }

  /// Fast parallel count query for the 4 KPI metric cards in Region [1].
  Future<ContactsKpiCounts> fetchContactKpiCounts({
    String email = ServiceGoogleContacts.defaultGoogleEmail,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final results = await Future.wait<int>([
        _execCount(_baseContactsQuery('id', normalizedEmail)),
        _execCount(
          _baseContactsQuery('id', normalizedEmail)
              .or('linked_master_codes.neq.{},linked_group_codes.neq.{}'),
        ),
        _execCount(
          _baseContactsQuery('id', normalizedEmail)
              .eq('linked_master_codes', '{}')
              .eq('linked_group_codes', '{}'),
        ),
        _execCount(
          _baseContactsQuery('id', normalizedEmail)
              .inFilter('sync_status', const ['PENDING_PUSH', 'LOCAL_ONLY']),
        ),
        _execCount(
          _baseContactsQuery('id', normalizedEmail).eq('is_starred', true),
        ),
      ]);
      return ContactsKpiCounts(
        totalActive: results[0],
        linkedCount: results[1],
        unlinkedCount: results[2],
        pendingPushCount: results[3],
        starredCount: results[4],
      );
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] fetchContactKpiCounts error: $e');
      return const ContactsKpiCounts();
    }
  }

  /// Resolves linked `sq_ACGROUP` parents & all sister `sq_MASTER` firms sharing `GCODE`.
  Future<ContactGroupEmpireRollup> fetchSisterPartiesForContact(
    GoogleContact contact,
  ) async {
    final directMasters = contact.linkedMasterCodes
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toSet();
    final directGroups = contact.linkedGroupCodes
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toSet();

    if (directMasters.isEmpty && directGroups.isEmpty) {
      return const ContactGroupEmpireRollup();
    }

    try {
      final Set<String> resolvedGroupCodes = {...directGroups};
      if (directMasters.isNotEmpty) {
        final masterRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_MASTER')
            .select('code,GCODE')
            .inFilter('code', directMasters.toList());
        for (final row in (masterRows as List<dynamic>)) {
          final g = row['GCODE']?.toString().trim() ?? '';
          if (g.isNotEmpty) resolvedGroupCodes.add(g);
        }
      }

      List<AccountGroupOption> groups = const [];
      if (resolvedGroupCodes.isNotEmpty) {
        final grpRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_ACGROUP')
            .select('gcode,NAME,CITY1,CONTACT,MOBILE')
            .inFilter('gcode', resolvedGroupCodes.toList())
            .order('NAME', ascending: true);
        groups = (grpRows as List<dynamic>)
            .map((j) => AccountGroupOption.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
      }

      final Map<String, SisterPartySummary> byCode = {};
      if (resolvedGroupCodes.isNotEmpty) {
        final grpPartyRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_MASTER')
            .select('code,NAME,GCODE,CITY1,STATION,MOBILE,ADATIYA,crdays,FLASH_RMK')
            .inFilter('GCODE', resolvedGroupCodes.toList())
            .order('NAME', ascending: true)
            .limit(60);
        for (final j in (grpPartyRows as List<dynamic>)) {
          final item = SisterPartySummary.fromJson(
            Map<String, dynamic>.from(j as Map),
            directMasterCodes: directMasters,
          );
          if (item.code.isNotEmpty) byCode[item.code] = item;
        }
      }

      final missingDirect =
          directMasters.where((c) => !byCode.containsKey(c)).toList();
      if (missingDirect.isNotEmpty) {
        final directRows = await _db.client
            .schema('IMMBE2627')
            .from('sq_MASTER')
            .select('code,NAME,GCODE,CITY1,STATION,MOBILE,ADATIYA,crdays,FLASH_RMK')
            .inFilter('code', missingDirect)
            .order('NAME', ascending: true);
        for (final j in (directRows as List<dynamic>)) {
          final item = SisterPartySummary.fromJson(
            Map<String, dynamic>.from(j as Map),
            directMasterCodes: directMasters,
          );
          if (item.code.isNotEmpty) byCode[item.code] = item;
        }
      }

      final sisterParties = byCode.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return ContactGroupEmpireRollup(groups: groups, sisterParties: sisterParties);
    } catch (e) {
      debugPrint('[ServiceGoogleContacts] fetchSisterPartiesForContact error: $e');
      return ContactGroupEmpireRollup(error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> _fetchRemoteContactMetadata(
    String resourceName,
    String token,
  ) async {
    final uri = Uri.https(
      'people.googleapis.com',
      '/v1/$resourceName',
      {'personFields': 'metadata'},
    );
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return null;
  }

  Future<http.Response> _sendAuthorizedWrite({
    required String method,
    required Uri uri,
    required String token,
    required Map<String, dynamic> body,
  }) {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    final encoded = jsonEncode(body);
    if (method == 'PATCH') {
      return http.patch(uri, headers: headers, body: encoded);
    }
    return http.post(uri, headers: headers, body: encoded);
  }
}
