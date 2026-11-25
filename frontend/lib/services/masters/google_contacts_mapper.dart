/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Pure stateless mapper and RFC-4180 parser (`GoogleContactsMapper`) backing
     `ServiceGoogleContacts` (`service_google_contacts.dart`) for Stage 9.1.
   - Transforms BOTH Google People API v1 `Person` JSON payloads and Google
     Contacts CSV exports into exact `"IMMBE2627"."sb_contacts"` JSONB + GIN
     normalized array structures (`phone_norms[]`, `group_labels[]`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `parseRfc4180Csv`: Full state-machine parser handling UTF-8 BOM, quoted
     commas, escaped `""` quotes, `\r\n`/`\n` line endings, and multiline
     quoted `Notes` / `Address` cells without line-splitting corruption.
   - `mapCsvTableToRows`: Supports both new and classic Google Contacts CSV
     headers, splits ` ::: ` multi-value cells losslessly, and synthesizes
     deterministic `csv/<anchorPhone>_<slug>` `resource_name` keys so CSV
     re-imports update idempotently without creating duplicates.
   - `normalizePhoneVariants`: Indexes Indian 10-digit mobile numbers (`9825144321`),
     leading-0 trunks, and E.164 (`+919825144321`) into `phone_norms[]`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Tombstoned contacts from Google (`metadata.deleted == true`) return minimal
     tombstone payloads (`resource_name`, `google_metadata`, `raw_person`) so
     `fn_upsert_google_contacts_batch` archives them safely.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Pure static/stateless helper class; no network or database side effects.
================================================================================
*/

import '../../models/masters/model_google_contacts.dart';

/// Pure stateless transformations for Google People API v1 & Google CSV imports.
abstract final class GoogleContactsMapper {
  /// Maps a Google People API v1 `Person` resource to an `sb_contacts` upsert row.
  static Map<String, dynamic>? mapGooglePersonToRow(
    Map<String, dynamic> person,
    Map<String, String> groupsMap,
  ) {
    final resourceName = person['resourceName']?.toString().trim() ?? '';
    if (resourceName.isEmpty) return null;

    final metadata = person['metadata'] is Map
        ? Map<String, dynamic>.from(person['metadata'] as Map)
        : <String, dynamic>{};
    if (metadata['deleted'] == true) {
      return {
        'resource_name': resourceName,
        'google_metadata': metadata,
        'raw_person': person,
      };
    }

    final names = _asMapList(person['names']);
    final nicknames = _asMapList(person['nicknames']);
    final photos = _asMapList(person['photos']);
    final phoneNumbers = _asMapList(person['phoneNumbers']);
    final emailAddresses = _asMapList(person['emailAddresses']);
    final addresses = _asMapList(person['addresses']);
    final organizations = _asMapList(person['organizations']);
    final biographies = _asMapList(person['biographies']);
    final relations = _asMapList(person['relations']);
    final events = _asMapList(person['events']);
    final birthdays = _asMapList(person['birthdays']);
    final urls = _asMapList(person['urls']);
    final memberships = _asMapList(person['memberships']);
    final userDefined = _asMapList(person['userDefined']);
    final clientData = _asMapList(person['clientData']);

    final primaryName = names.isNotEmpty ? names.first : const <String, dynamic>{};
    final givenName = primaryName['givenName']?.toString().trim();
    final familyName = primaryName['familyName']?.toString().trim();
    final rawDisplayName = primaryName['displayName']?.toString().trim() ?? '';

    final primaryOrg =
        organizations.isNotEmpty ? organizations.first : const <String, dynamic>{};
    final companyName = nonEmptyOrNull(primaryOrg['name']?.toString(), null);
    final jobTitle = nonEmptyOrNull(primaryOrg['title']?.toString(), null);

    final primaryPhoto =
        photos.isNotEmpty ? photos.first['url']?.toString().trim() : null;
    final notesText = biographies.isNotEmpty
        ? nonEmptyOrNull(biographies.first['value']?.toString(), null)
        : null;

    String? primaryPhone;
    final Set<String> phoneNorms = {};
    for (final p in phoneNumbers) {
      final rawVal = p['value']?.toString().trim() ?? '';
      final canonical = p['canonicalForm']?.toString().trim() ?? '';
      final chosen = canonical.isNotEmpty ? canonical : rawVal;
      if (chosen.isNotEmpty) {
        primaryPhone ??= chosen;
        phoneNorms.addAll(normalizePhoneVariants(rawVal));
        phoneNorms.addAll(normalizePhoneVariants(canonical));
      }
    }

    String? primaryEmail;
    for (final e in emailAddresses) {
      final val = e['value']?.toString().trim() ?? '';
      if (val.isNotEmpty) {
        primaryEmail ??= val;
      }
    }

    final Set<String> groupLabels = {};
    bool isStarred = false;
    for (final m in memberships) {
      final grp = m['contactGroupMembership'];
      if (grp is Map) {
        final rn = grp['contactGroupResourceName']?.toString() ?? '';
        final gid = grp['contactGroupId']?.toString() ?? '';
        if (gid == 'starred' || rn == 'contactGroups/starred') {
          isStarred = true;
        }
        final resolved = groupsMap[rn] ?? groupsMap['contactGroups/$gid'] ?? gid;
        if (resolved.isNotEmpty && resolved != 'myContacts') {
          groupLabels.add(resolved);
        }
      }
    }

    final joinedParts = [givenName, familyName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .trim();
    final displayName = rawDisplayName.isNotEmpty
        ? rawDisplayName
        : (joinedParts.isNotEmpty
            ? joinedParts
            : (companyName ?? primaryPhone ?? primaryEmail ?? 'Unnamed Contact'));

    return {
      'resource_name': resourceName,
      'etag': person['etag']?.toString(),
      'google_metadata': metadata,
      'names': names,
      'nicknames': nicknames,
      'photos': photos,
      'phone_numbers': phoneNumbers,
      'email_addresses': emailAddresses,
      'addresses': addresses,
      'organizations': organizations,
      'biographies': biographies,
      'relations': relations,
      'events': events,
      'birthdays': birthdays,
      'urls': urls,
      'memberships': memberships,
      'user_defined': userDefined,
      'client_data': clientData,
      'raw_person': person,
      'display_name': displayName,
      'given_name': nonEmptyOrNull(givenName, null),
      'family_name': nonEmptyOrNull(familyName, null),
      'company_name': companyName,
      'job_title': jobTitle,
      'primary_phone': primaryPhone,
      'primary_email': primaryEmail,
      'photo_url': nonEmptyOrNull(primaryPhoto, null),
      'notes_text': notesText,
      'group_labels': groupLabels.toList(),
      'phone_norms': phoneNorms.toList(),
      'is_starred': isStarred,
    };
  }

  /// State-machine RFC-4180 CSV parser handling BOM, `,`, `"`, `""`, and multiline cells.
  static List<List<String>> parseRfc4180Csv(String input) {
    final cleaned = input.startsWith('\uFEFF') ? input.substring(1) : input;
    final List<List<String>> rows = [];
    List<String> currentRow = [];
    final StringBuffer cell = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < cleaned.length; i++) {
      final ch = cleaned[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < cleaned.length && cleaned[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          cell.write(ch);
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
        } else if (ch == ',') {
          currentRow.add(cell.toString());
          cell.clear();
        } else if (ch == '\r') {
          if (i + 1 < cleaned.length && cleaned[i + 1] == '\n') i++;
          currentRow.add(cell.toString());
          cell.clear();
          rows.add(currentRow);
          currentRow = [];
        } else if (ch == '\n') {
          currentRow.add(cell.toString());
          cell.clear();
          rows.add(currentRow);
          currentRow = [];
        } else {
          cell.write(ch);
        }
      }
    }

    if (cell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(cell.toString());
      rows.add(currentRow);
    }
    return rows;
  }

  /// Maps an entire parsed CSV table into `fn_upsert_google_contacts_batch` payloads.
  static List<Map<String, dynamic>> mapCsvTableToRows(List<List<String>> table) {
    if (table.length <= 1) return const [];
    final headers = table.first.map((h) => h.trim()).toList();
    final headerIndex = <String, int>{};
    for (int i = 0; i < headers.length; i++) {
      final key = headers[i].toLowerCase();
      if (key.isNotEmpty && !headerIndex.containsKey(key)) {
        headerIndex[key] = i;
      }
    }

    final List<Map<String, dynamic>> parsedRows = [];
    final Map<String, int> seenKeys = {};

    for (int rowIdx = 1; rowIdx < table.length; rowIdx++) {
      final cols = table[rowIdx];
      if (cols.every((c) => c.trim().isEmpty)) continue;

      final rowMap = _mapCsvRowToContactPayload(
        headers: headers,
        headerIndex: headerIndex,
        cols: cols,
        seenKeys: seenKeys,
        rowIdx: rowIdx,
      );
      if (rowMap != null) parsedRows.add(rowMap);
    }
    return parsedRows;
  }

  static Map<String, dynamic>? _mapCsvRowToContactPayload({
    required List<String> headers,
    required Map<String, int> headerIndex,
    required List<String> cols,
    required Map<String, int> seenKeys,
    required int rowIdx,
  }) {
    String colVal(List<String> candidates) {
      for (final c in candidates) {
        final idx = headerIndex[c.toLowerCase()];
        if (idx != null && idx < cols.length) {
          final v = cols[idx].trim();
          if (v.isNotEmpty) return v;
        }
      }
      return '';
    }

    final givenName = colVal(['First Name', 'Given Name']);
    final middleName = colVal(['Middle Name', 'Additional Name']);
    final familyName = colVal(['Last Name', 'Family Name']);
    final fullNameCol = colVal(['Name', 'Display Name', 'File As']);
    final nickname = colVal(['Nickname']);
    final companyName =
        colVal(['Organization Name', 'Organization 1 - Name', 'Company']);
    final jobTitle =
        colVal(['Organization Title', 'Organization 1 - Title', 'Title']);
    final department = colVal(
        ['Organization Department', 'Organization 1 - Department', 'Department']);
    final notesText = colVal(['Notes', 'Biography']);
    final photoUrl = colVal(['Photo']);
    final birthday = colVal(['Birthday']);

    final List<Map<String, dynamic>> phoneObjects = [];
    final Set<String> phoneNorms = {};
    String? primaryPhone;

    for (int slot = 1; slot <= 6; slot++) {
      final rawCell = colVal([
        'Phone $slot - Value',
        if (slot == 1) 'Phone',
        if (slot == 1) 'Mobile',
        if (slot == 1) 'Primary Phone',
      ]);
      if (rawCell.isEmpty) continue;
      final label = colVal(['Phone $slot - Label', 'Phone $slot - Type']);
      for (final p in rawCell.split(' ::: ')) {
        final val = p.trim();
        if (val.isEmpty) continue;
        phoneObjects.add({
          'value': val,
          'type': label.isNotEmpty ? label.toLowerCase() : 'mobile',
          if (label.isNotEmpty) 'formattedType': label,
        });
        primaryPhone ??= val;
        phoneNorms.addAll(normalizePhoneVariants(val));
      }
    }

    final List<Map<String, dynamic>> emailObjects = [];
    String? primaryEmail;
    for (int slot = 1; slot <= 4; slot++) {
      final rawCell = colVal([
        'E-mail $slot - Value',
        if (slot == 1) 'Email',
        if (slot == 1) 'E-mail',
      ]);
      if (rawCell.isEmpty) continue;
      final label = colVal(['E-mail $slot - Label', 'E-mail $slot - Type']);
      for (final e in rawCell.split(' ::: ')) {
        final val = e.trim();
        if (val.isEmpty) continue;
        emailObjects.add({
          'value': val,
          'type': label.isNotEmpty ? label.toLowerCase() : 'work',
        });
        primaryEmail ??= val;
      }
    }

    final List<Map<String, dynamic>> addressObjects = [];
    for (int slot = 1; slot <= 2; slot++) {
      final formatted = colVal(['Address $slot - Formatted']);
      final street = colVal(['Address $slot - Street']);
      final city = colVal(['Address $slot - City']);
      final region = colVal(['Address $slot - Region']);
      final postal = colVal(['Address $slot - Postal Code']);
      final country = colVal(['Address $slot - Country']);
      final type = colVal(['Address $slot - Label', 'Address $slot - Type']);
      final combined = formatted.isNotEmpty
          ? formatted
          : [street, city, region, postal, country]
              .where((s) => s.isNotEmpty)
              .join(', ');
      if (combined.isNotEmpty) {
        addressObjects.add({
          'formattedValue': combined,
          if (street.isNotEmpty) 'streetAddress': street,
          if (city.isNotEmpty) 'city': city,
          if (region.isNotEmpty) 'region': region,
          if (postal.isNotEmpty) 'postalCode': postal,
          if (country.isNotEmpty) 'country': country,
          if (type.isNotEmpty) 'type': type.toLowerCase(),
        });
      }
    }

    final labelsCell = colVal(['Labels', 'Group Membership']);
    final Set<String> groupLabels = {};
    bool isStarred = false;
    if (labelsCell.isNotEmpty) {
      for (final rawLabel in labelsCell.split(' ::: ')) {
        final cleaned = rawLabel.replaceFirst(RegExp(r'^\*\s*'), '').trim();
        if (cleaned.isEmpty) continue;
        final lower = cleaned.toLowerCase();
        if (lower == 'starred') isStarred = true;
        if (lower != 'mycontacts' && lower != 'my contacts') {
          groupLabels.add(cleaned);
        }
      }
    }

    final List<Map<String, dynamic>> urls = [];
    final List<Map<String, dynamic>> relations = [];
    final List<Map<String, dynamic>> events = [];
    for (int slot = 1; slot <= 2; slot++) {
      final u = colVal(['Website $slot - Value']);
      if (u.isNotEmpty) {
        urls.add({
          'value': u,
          'type': colVal(['Website $slot - Label', 'Website $slot - Type']),
        });
      }
      final r = colVal(['Relation $slot - Value']);
      if (r.isNotEmpty) {
        relations.add({
          'person': r,
          'type': colVal(['Relation $slot - Label', 'Relation $slot - Type']),
        });
      }
      final ev = colVal(['Event $slot - Value']);
      if (ev.isNotEmpty) {
        events.add({
          'text': ev,
          'type': colVal(['Event $slot - Label', 'Event $slot - Type']),
        });
      }
    }

    final List<Map<String, dynamic>> userDefined = [];
    for (int slot = 1; slot <= 3; slot++) {
      final k = colVal(['Custom Field $slot - Label', 'Custom Field $slot - Type']);
      final v = colVal(['Custom Field $slot - Value']);
      if (k.isNotEmpty || v.isNotEmpty) {
        userDefined.add({'key': k, 'value': v});
      }
    }

    final constructedName = [givenName, middleName, familyName]
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    final displayName = fullNameCol.isNotEmpty
        ? fullNameCol
        : (constructedName.isNotEmpty
            ? constructedName
            : (companyName.isNotEmpty
                ? companyName
                : (primaryPhone ?? primaryEmail ?? '')));

    if (displayName.isEmpty && phoneObjects.isEmpty && emailObjects.isEmpty) {
      return null;
    }

    final effectiveDisplay =
        displayName.isNotEmpty ? displayName : 'Unnamed Contact';

    final csvResourceCol = colVal(['Resource Name', 'google_resource_name']);
    final String resourceKey;
    if (csvResourceCol.isNotEmpty) {
      resourceKey = csvResourceCol;
    } else {
      final anchorPhone = phoneNorms.isNotEmpty
          ? phoneNorms.first
          : (primaryEmail?.toLowerCase() ?? 'row_$rowIdx');
      final nameSlug = effectiveDisplay
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      final trimmedSlug =
          nameSlug.length > 40 ? nameSlug.substring(0, 40) : nameSlug;
      final base = 'csv/${anchorPhone}_$trimmedSlug';
      final count = (seenKeys[base] ?? 0) + 1;
      seenKeys[base] = count;
      resourceKey = count == 1 ? base : '${base}_$count';
    }

    final namesJson = [
      {
        'displayName': effectiveDisplay,
        if (givenName.isNotEmpty) 'givenName': givenName,
        if (middleName.isNotEmpty) 'middleName': middleName,
        if (familyName.isNotEmpty) 'familyName': familyName,
      }
    ];

    final orgsJson = (companyName.isNotEmpty || jobTitle.isNotEmpty || department.isNotEmpty)
        ? [
            {
              if (companyName.isNotEmpty) 'name': companyName,
              if (jobTitle.isNotEmpty) 'title': jobTitle,
              if (department.isNotEmpty) 'department': department,
              'current': true,
            }
          ]
        : const <Map<String, dynamic>>[];

    final rawCsvRow = <String, dynamic>{};
    for (int c = 0; c < headers.length && c < cols.length; c++) {
      final h = headers[c];
      final v = cols[c].trim();
      if (h.isNotEmpty && v.isNotEmpty) rawCsvRow[h] = v;
    }

    return {
      'resource_name': resourceKey,
      'names': namesJson,
      'nicknames': nickname.isNotEmpty ? [{'value': nickname}] : const [],
      'photos': photoUrl.isNotEmpty ? [{'url': photoUrl}] : const [],
      'phone_numbers': phoneObjects,
      'email_addresses': emailObjects,
      'addresses': addressObjects,
      'organizations': orgsJson,
      'biographies': notesText.isNotEmpty ? [{'value': notesText}] : const [],
      'relations': relations,
      'events': events,
      'birthdays': birthday.isNotEmpty ? [{'text': birthday}] : const [],
      'urls': urls,
      'memberships': groupLabels
          .map((lbl) => {
                'contactGroupMembership': {'contactGroupId': lbl}
              })
          .toList(),
      'user_defined': userDefined,
      'raw_person': {'csvSourceRow': rawCsvRow},
      'display_name': effectiveDisplay,
      'given_name': givenName.isNotEmpty ? givenName : null,
      'family_name': familyName.isNotEmpty ? familyName : null,
      'company_name': companyName.isNotEmpty ? companyName : null,
      'job_title': jobTitle.isNotEmpty ? jobTitle : null,
      'primary_phone': primaryPhone,
      'primary_email': primaryEmail,
      'photo_url': photoUrl.isNotEmpty ? photoUrl : null,
      'notes_text': notesText.isNotEmpty ? notesText : null,
      'group_labels': groupLabels.toList(),
      'phone_norms': phoneNorms.toList(),
      'is_starred': isStarred,
    };
  }

  /// Produces normalized 10-digit Indian & E.164 search keys for `phone_norms`.
  static List<String> normalizePhoneVariants(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 5) return const [];

    final Set<String> variants = {digits};
    if (digits.length == 10) {
      variants.add('+91$digits');
    } else if (digits.length == 11 && digits.startsWith('0')) {
      final local10 = digits.substring(1);
      variants.add(local10);
      variants.add('+91$local10');
    } else if (digits.length == 12 && digits.startsWith('91')) {
      final local10 = digits.substring(2);
      variants.add(local10);
      variants.add('+$digits');
    } else if (trimmed.startsWith('+')) {
      variants.add('+$digits');
    }
    return variants.toList();
  }

  static List<Map<String, dynamic>> _asMapList(Object? raw) {
    if (raw is List) {
      return raw.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    }
    return const [];
  }

  /// Shared helper: returns trimmed string or [fallback] if empty/null.
  static String nonEmptyOr(String? value, String fallback) {
    final t = value?.trim() ?? '';
    return t.isNotEmpty ? t : fallback;
  }

  /// Shared helper: returns trimmed string or [fallback] if empty/null.
  static String? nonEmptyOrNull(String? value, String? fallback) {
    final t = value?.trim() ?? '';
    if (t.isNotEmpty) return t;
    final fb = fallback?.trim() ?? '';
    return fb.isNotEmpty ? fb : null;
  }

  /// Computes deduplicated normalized search variants across all phone entries.
  static List<String> computePhoneNormsForList(List<GooglePhoneEntry> phones) {
    final Set<String> norms = {};
    for (final p in phones) {
      norms.addAll(normalizePhoneVariants(p.value));
      norms.addAll(normalizePhoneVariants(p.canonicalForm));
    }
    return norms.toList();
  }

  /// Builds a clean Google People API v1 `Person` JSON payload for `createContact`
  /// or `updateContact` (including `etag` + `metadata` when [includeEtag] is true).
  static Map<String, dynamic> buildGooglePersonWritePayload(
    GoogleContact contact, {
    bool includeEtag = true,
  }) {
    final given = contact.givenName?.trim() ?? '';
    final family = contact.familyName?.trim() ?? '';
    final display = contact.displayName.trim();

    final Map<String, dynamic> primaryName = {};
    if (given.isNotEmpty) {
      primaryName['givenName'] = given;
    } else if (family.isEmpty && display.isNotEmpty && display != 'Unnamed Contact') {
      primaryName['givenName'] = display;
    }
    if (family.isNotEmpty) {
      primaryName['familyName'] = family;
    }
    if (display.isNotEmpty && display != 'Unnamed Contact') {
      primaryName['unstructuredName'] = display;
    }

    final phonesPayload = <Map<String, dynamic>>[
      for (final p in contact.phoneList)
        if (p.value.trim().isNotEmpty || p.canonicalForm.trim().isNotEmpty)
          {
            'value': p.value.trim().isNotEmpty ? p.value.trim() : p.canonicalForm.trim(),
            'type': p.type.trim().isNotEmpty ? p.type.trim() : 'mobile',
          },
    ];

    final emailsPayload = <Map<String, dynamic>>[
      for (final e in contact.emailList)
        if (e.value.trim().isNotEmpty)
          {
            'value': e.value.trim(),
            'type': e.type.trim().isNotEmpty ? e.type.trim() : 'work',
          },
    ];

    final orgName = contact.companyName?.trim() ?? '';
    final orgTitle = contact.jobTitle?.trim() ?? '';
    final orgDept = contact.organizationList.isNotEmpty
        ? contact.organizationList.first.department.trim()
        : '';
    final orgsPayload = <Map<String, dynamic>>[
      if (orgName.isNotEmpty || orgTitle.isNotEmpty || orgDept.isNotEmpty)
        {
          if (orgName.isNotEmpty) 'name': orgName,
          if (orgTitle.isNotEmpty) 'title': orgTitle,
          if (orgDept.isNotEmpty) 'department': orgDept,
          'current': true,
        },
    ];

    final notes = contact.notesText?.trim() ?? '';
    final biosPayload = <Map<String, dynamic>>[
      if (notes.isNotEmpty) {'value': notes, 'contentType': 'TEXT_PLAIN'},
    ];

    final addressesPayload = <Map<String, dynamic>>[
      for (final a in contact.addresses)
        if ((a['formattedValue']?.toString().trim().isNotEmpty ?? false) ||
            (a['streetAddress']?.toString().trim().isNotEmpty ?? false) ||
            (a['city']?.toString().trim().isNotEmpty ?? false))
          {
            if ((a['formattedValue']?.toString().trim().isNotEmpty ?? false))
              'formattedValue': a['formattedValue'].toString().trim(),
            if ((a['streetAddress']?.toString().trim().isNotEmpty ?? false))
              'streetAddress': a['streetAddress'].toString().trim(),
            if ((a['city']?.toString().trim().isNotEmpty ?? false))
              'city': a['city'].toString().trim(),
            if ((a['region']?.toString().trim().isNotEmpty ?? false))
              'region': a['region'].toString().trim(),
            if ((a['postalCode']?.toString().trim().isNotEmpty ?? false))
              'postalCode': a['postalCode'].toString().trim(),
            if ((a['country']?.toString().trim().isNotEmpty ?? false))
              'country': a['country'].toString().trim(),
            'type': nonEmptyOr(a['type']?.toString(), 'work'),
          },
    ];

    return <String, dynamic>{
      if (includeEtag && (contact.etag?.trim().isNotEmpty ?? false))
        'etag': contact.etag!.trim(),
      if (includeEtag && contact.googleMetadata.isNotEmpty)
        'metadata': contact.googleMetadata,
      'names': primaryName.isNotEmpty ? [primaryName] : const [],
      'phoneNumbers': phonesPayload,
      'emailAddresses': emailsPayload,
      'organizations': orgsPayload,
      'addresses': addressesPayload,
      'biographies': biosPayload,
    };
  }

  /// Builds column payload for saving local edits/offline creates into `sb_contacts`.
  static Map<String, dynamic> buildLocalWriteFields(
    GoogleContact contact, {
    required String syncStatus,
  }) {
    final phoneNorms = computePhoneNormsForList(contact.phoneList);
    final primaryPhone = contact.phoneList.isNotEmpty
        ? contact.phoneList.first.preferredNumber
        : null;
    final primaryEmail = contact.emailList.isNotEmpty
        ? contact.emailList.first.value
        : null;
    final joinedName = [contact.givenName, contact.familyName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .join(' ');
    final effectiveDisplay = contact.displayName.trim().isNotEmpty &&
            contact.displayName.trim() != 'Unnamed Contact'
        ? contact.displayName.trim()
        : (joinedName.isNotEmpty
            ? joinedName
            : (nonEmptyOrNull(contact.companyName, null) ??
                primaryPhone ??
                primaryEmail ??
                'Unnamed Contact'));

    final orgsJson = [
      if ((contact.companyName?.trim().isNotEmpty ?? false) ||
          (contact.jobTitle?.trim().isNotEmpty ?? false) ||
          (contact.organizationList.isNotEmpty &&
              contact.organizationList.first.department.trim().isNotEmpty))
        {
          if (contact.companyName?.trim().isNotEmpty ?? false)
            'name': contact.companyName!.trim(),
          if (contact.jobTitle?.trim().isNotEmpty ?? false)
            'title': contact.jobTitle!.trim(),
          if (contact.organizationList.isNotEmpty &&
              contact.organizationList.first.department.trim().isNotEmpty)
            'department': contact.organizationList.first.department.trim(),
          'current': true,
        },
    ];

    final namesJson = [
      {
        if (contact.givenName?.trim().isNotEmpty ?? false)
          'givenName': contact.givenName!.trim(),
        if (contact.familyName?.trim().isNotEmpty ?? false)
          'familyName': contact.familyName!.trim(),
        'displayName': effectiveDisplay,
      }
    ];

    final notes = nonEmptyOrNull(contact.notesText, null);
    final biosJson = [
      if (notes != null) {'value': notes, 'contentType': 'TEXT_PLAIN'},
    ];

    return {
      'display_name': effectiveDisplay,
      'given_name': nonEmptyOrNull(contact.givenName, null),
      'family_name': nonEmptyOrNull(contact.familyName, null),
      'company_name': nonEmptyOrNull(contact.companyName, null),
      'job_title': nonEmptyOrNull(contact.jobTitle, null),
      'primary_phone': primaryPhone,
      'primary_email': primaryEmail,
      'notes_text': notes,
      'names': namesJson,
      'phone_numbers': contact.phoneList.map((e) => e.toJson()).toList(),
      'email_addresses': contact.emailList.map((e) => e.toJson()).toList(),
      'organizations': orgsJson,
      'addresses': contact.addresses,
      'biographies': biosJson,
      'phone_norms': phoneNorms,
      'group_labels': contact.groupLabels,
      'linked_master_codes': contact.linkedMasterCodes,
      'linked_group_codes': contact.linkedGroupCodes,
      'erp_links': contact.erpLinks.map((e) => e.toJson()).toList(),
      'is_starred': contact.isStarred,
      'sync_status': syncStatus,
      'dirty_fields': syncStatus == 'SYNCED'
          ? const <String>[]
          : const ['names', 'phone_numbers', 'email_addresses', 'organizations', 'addresses', 'biographies'],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
