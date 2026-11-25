/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Region [4] (`Flex 8`) Person 360° Inspector & Inline Two-Way Editor
     (`ContactDetailInspectorBentoCard`) for Stage 9.3 Google Contacts Workspace.
   - Supports View Mode <-> Inline Edit Mode (`[E]`) with Google Label toggling
     (`modifyContactGroupMembership`), M:N ERP Party & Group link management,
     and lazy lossless raw JSON inspection (`fetchContactRawPerson`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` widgets, `theme.density.*`,
     `theme.typography.*`, `colors.*`, and `DyColorSystem`.
   - Delegates the inline edit form tree to `ContactTwoWayEditForm`
     (`scr_contacts_edit_form.dart`) to keep each Dart module well under 1000 lines.
   - Wraps all badge chips in `Focus(canRequestFocus: false, skipTraversal: true,
     descendantsAreFocusable: false)` per `GEMINI.md` Rule 8.
   - Always checks `if (!mounted) return;` after awaits.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `raw_person` is loaded lazily only on demand via `Inspect Lossless Raw JSON`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Caller ID display-name enrichment formatting rules deferred per user.
================================================================================
*/

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/masters/model_google_contacts.dart';
import '../../../../services/masters/service_google_contacts.dart';
import 'scr_contacts_bento_cards.dart';
import 'scr_contacts_edit_form.dart';

/// Region [4] (`Flex 8`): Lossless Person 360° Inspector & Two-Way Google Editor.
class ContactDetailInspectorBentoCard extends StatefulWidget {
  final GoogleContact? contact;
  final Map<String, String> contactGroupsMap;
  final ServiceGoogleContacts service;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;
  final VoidCallback onContactUpdated;
  final VoidCallback onRequestLinkErp;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const ContactDetailInspectorBentoCard({
    super.key,
    required this.contact,
    required this.contactGroupsMap,
    required this.service,
    required this.isEditing,
    required this.onEditingChanged,
    required this.onContactUpdated,
    required this.onRequestLinkErp,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  State<ContactDetailInspectorBentoCard> createState() =>
      _ContactDetailInspectorBentoCardState();
}

class _ContactDetailInspectorBentoCardState
    extends State<ContactDetailInspectorBentoCard> {
  final TextEditingController _displayCtrl = TextEditingController();
  final TextEditingController _givenCtrl = TextEditingController();
  final TextEditingController _familyCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _jobTitleCtrl = TextEditingController();
  final TextEditingController _deptCtrl = TextEditingController();
  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  final List<ContactEditableFieldRow> _phoneRows = [];
  final List<ContactEditableFieldRow> _emailRows = [];

  Map<String, dynamic>? _rawPerson;
  bool _loadingRaw = false;
  bool _isSaving = false;
  PullResult? _saveFeedback;

  @override
  void initState() {
    super.initState();
    _syncControllersFromContact(widget.contact);
  }

  @override
  void didUpdateWidget(covariant ContactDetailInspectorBentoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final contactChanged = oldWidget.contact?.id != widget.contact?.id;
    if (contactChanged) {
      _rawPerson = null;
      _loadingRaw = false;
      _saveFeedback = null;
      if (widget.isEditing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onEditingChanged(false);
        });
      }
      _syncControllersFromContact(widget.contact);
    } else if (!oldWidget.isEditing && widget.isEditing) {
      _saveFeedback = null;
      _syncControllersFromContact(widget.contact);
    }
  }

  @override
  void dispose() {
    _displayCtrl.dispose();
    _givenCtrl.dispose();
    _familyCtrl.dispose();
    _companyCtrl.dispose();
    _jobTitleCtrl.dispose();
    _deptCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    for (final r in _phoneRows) {
      r.dispose();
    }
    for (final r in _emailRows) {
      r.dispose();
    }
    super.dispose();
  }

  void _syncControllersFromContact(GoogleContact? c) {
    for (final r in _phoneRows) {
      r.dispose();
    }
    for (final r in _emailRows) {
      r.dispose();
    }
    _phoneRows.clear();
    _emailRows.clear();

    if (c == null) {
      _displayCtrl.clear();
      _givenCtrl.clear();
      _familyCtrl.clear();
      _companyCtrl.clear();
      _jobTitleCtrl.clear();
      _deptCtrl.clear();
      _streetCtrl.clear();
      _cityCtrl.clear();
      _notesCtrl.clear();
      return;
    }

    _displayCtrl.text = c.displayName == 'Unnamed Contact' ? '' : c.displayName;
    _givenCtrl.text = c.givenName ?? '';
    _familyCtrl.text = c.familyName ?? '';
    _companyCtrl.text = c.companyName ?? '';
    _jobTitleCtrl.text = c.jobTitle ?? '';
    _deptCtrl.text =
        c.organizationList.isNotEmpty ? c.organizationList.first.department : '';
    final addr = c.addresses.isNotEmpty ? c.addresses.first : const {};
    _streetCtrl.text = addr['streetAddress']?.toString() ??
        addr['formattedValue']?.toString() ??
        '';
    _cityCtrl.text = addr['city']?.toString() ?? '';
    _notesCtrl.text = c.notesText ?? '';

    if (c.phoneList.isEmpty) {
      _phoneRows.add(ContactEditableFieldRow(type: 'mobile'));
    } else {
      for (final p in c.phoneList) {
        _phoneRows.add(ContactEditableFieldRow(
          value: p.value.isNotEmpty ? p.value : p.canonicalForm,
          type: p.type.isNotEmpty ? p.type : 'mobile',
        ));
      }
    }

    if (c.emailList.isEmpty) {
      _emailRows.add(ContactEditableFieldRow(type: 'work'));
    } else {
      for (final e in c.emailList) {
        _emailRows.add(ContactEditableFieldRow(
          value: e.value,
          type: e.type.isNotEmpty ? e.type : 'work',
        ));
      }
    }
  }

  GoogleContact _buildEditedContact(GoogleContact base) {
    final given = _givenCtrl.text.trim();
    final family = _familyCtrl.text.trim();
    final combined = [given, family].where((s) => s.isNotEmpty).join(' ').trim();
    final company = _companyCtrl.text.trim();
    final jobTitle = _jobTitleCtrl.text.trim();
    final dept = _deptCtrl.text.trim();
    final street = _streetCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    final phones = [
      for (final p in _phoneRows)
        if (p.ctrl.text.trim().isNotEmpty)
          GooglePhoneEntry(value: p.ctrl.text.trim(), type: p.type),
    ];
    final emails = [
      for (final e in _emailRows)
        if (e.ctrl.text.trim().isNotEmpty)
          GoogleEmailEntry(value: e.ctrl.text.trim(), type: e.type),
    ];

    final effectiveDisplay = _displayCtrl.text.trim().isNotEmpty
        ? _displayCtrl.text.trim()
        : (combined.isNotEmpty
            ? combined
            : (company.isNotEmpty
                ? company
                : (phones.isNotEmpty ? phones.first.value : base.displayName)));

    final formattedAddr =
        [street, city].where((s) => s.isNotEmpty).join(', ').trim();

    return base.copyWith(
      displayName: effectiveDisplay,
      givenName: given,
      familyName: family,
      companyName: company,
      jobTitle: jobTitle,
      primaryPhone: phones.isNotEmpty ? phones.first.value : 'N/A',
      primaryEmail: emails.isNotEmpty ? emails.first.value : '',
      notesText: notes,
      phoneList: phones,
      emailList: emails,
      organizationList: [
        if (company.isNotEmpty || jobTitle.isNotEmpty || dept.isNotEmpty)
          GoogleOrganizationEntry(
            name: company,
            title: jobTitle,
            department: dept,
          ),
      ],
      addresses: [
        if (formattedAddr.isNotEmpty)
          {
            'formattedValue': formattedAddr,
            if (street.isNotEmpty) 'streetAddress': street,
            if (city.isNotEmpty) 'city': city,
            'type': 'work',
          },
      ],
    );
  }

  Future<void> _saveChanges({required bool pushImmediately}) async {
    final base = widget.contact;
    if (base == null || _isSaving) return;
    setState(() {
      _isSaving = true;
      _saveFeedback = null;
    });
    final updated = _buildEditedContact(base);
    final res = await widget.service.updateContactAndPush(
      updated: updated,
      pushImmediately: pushImmediately,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _saveFeedback = res;
    });
    if (res.isSuccess) {
      widget.onEditingChanged(false);
    }
    widget.onContactUpdated();
  }

  Future<void> _toggleGoogleLabel(
    GoogleContact contact,
    String groupResourceName,
    bool add,
  ) async {
    final res = await widget.service.modifyContactGroupMembership(
      contact: contact,
      groupResourceName: groupResourceName,
      add: add,
    );
    if (!mounted) return;
    setState(() => _saveFeedback = res);
    if (res.isSuccess) widget.onContactUpdated();
  }

  Future<void> _loadRawJson(String contactId) async {
    setState(() => _loadingRaw = true);
    final raw = await widget.service.fetchContactRawPerson(contactId);
    if (!mounted) return;
    setState(() {
      _rawPerson = raw;
      _loadingRaw = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final contact = widget.contact;

    return DyBentoCard(
      title: 'Person 360° Inspector & Two-Way Editor',
      subtitle: contact != null
          ? (widget.isEditing ? 'Editing live Google Contact' : contact.resourceName)
          : 'Select a contact from Region [2]',
      icon: shad.LucideIcons.contact,
      regionNumber: 4,
      isZoomed: widget.isZoomed,
      onToggleZoom: widget.onToggleZoom,
      expandBody: true,
      headerTrailing: contact == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: widget.onRequestLinkErp,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      ContactsShiftKeyCap(letter: 'L'),
                      Icon(shad.LucideIcons.link, size: 12),
                      shad.DensityGap(shad.gapXs),
                      Text('Link ERP'),
                    ],
                  ),
                ),
                const shad.DensityGap(shad.gapXs),
                widget.isEditing
                    ? shad.OutlineButton(
                        size: shad.ButtonSize.small,
                        onPressed: () {
                          _syncControllersFromContact(contact);
                          widget.onEditingChanged(false);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            ContactsShiftKeyCap(letter: 'E'),
                            Icon(shad.LucideIcons.x, size: 12),
                            shad.DensityGap(shad.gapXs),
                            Text('Cancel'),
                          ],
                        ),
                      )
                    : shad.PrimaryButton(
                        size: shad.ButtonSize.small,
                        onPressed: () {
                          _syncControllersFromContact(contact);
                          widget.onEditingChanged(true);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            ContactsShiftKeyCap(letter: 'E', inverted: true),
                            Icon(shad.LucideIcons.pencil, size: 12),
                            shad.DensityGap(shad.gapXs),
                            Text('Edit & Push'),
                          ],
                        ),
                      ),
              ],
            ),
      child: contact == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(pad * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.contact,
                        size: 32 * theme.scaling, color: colors.mutedForeground),
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      'Select any contact in the directory to view, edit, or push live to Google.',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(pad * 1.15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_saveFeedback != null) ...[
                    _feedbackBanner(_saveFeedback!, theme, pad),
                    const shad.DensityGap(shad.gapMd),
                  ],
                  if (widget.isEditing)
                    ContactTwoWayEditForm(
                      contact: contact,
                      givenCtrl: _givenCtrl,
                      familyCtrl: _familyCtrl,
                      displayCtrl: _displayCtrl,
                      companyCtrl: _companyCtrl,
                      jobTitleCtrl: _jobTitleCtrl,
                      deptCtrl: _deptCtrl,
                      streetCtrl: _streetCtrl,
                      cityCtrl: _cityCtrl,
                      notesCtrl: _notesCtrl,
                      phoneRows: _phoneRows,
                      emailRows: _emailRows,
                      isSaving: _isSaving,
                      onAddPhone: () => setState(
                        () => _phoneRows.add(ContactEditableFieldRow()),
                      ),
                      onPhoneTypeChanged: (i, t) =>
                          setState(() => _phoneRows[i].type = t),
                      onRemovePhone: (i) => setState(() {
                        if (_phoneRows.length <= 1) {
                          _phoneRows.first.ctrl.clear();
                        } else {
                          _phoneRows.removeAt(i).dispose();
                        }
                      }),
                      onAddEmail: () => setState(
                        () => _emailRows.add(
                          ContactEditableFieldRow(type: 'work'),
                        ),
                      ),
                      onEmailTypeChanged: (i, t) =>
                          setState(() => _emailRows[i].type = t),
                      onRemoveEmail: (i) => setState(() {
                        if (_emailRows.length <= 1) {
                          _emailRows.first.ctrl.clear();
                        } else {
                          _emailRows.removeAt(i).dispose();
                        }
                      }),
                      onCancel: () {
                        _syncControllersFromContact(contact);
                        widget.onEditingChanged(false);
                      },
                      onSaveOffline: () => _saveChanges(pushImmediately: false),
                      onSaveAndPush: () => _saveChanges(pushImmediately: true),
                    )
                  else
                    _buildViewInspector(contact, theme, colors, pad),
                ],
              ),
            ),
    );
  }

  Widget _buildViewInspector(
    GoogleContact contact,
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double pad,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final syncColor = contact.syncStatus == 'SYNCED'
        ? DyColorSystem.emerald500
        : DyColorSystem.orange500;

    final assignableGroups = widget.contactGroupsMap.entries
        .where((e) =>
            e.value.isNotEmpty &&
            e.value != 'myContacts' &&
            !contact.groupLabels.contains(e.value))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shad.OutlinedContainer(
          backgroundColor: colors.card,
          borderColor: colors.border,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  shad.OutlinedContainer(
                    width: 38 * theme.scaling,
                    height: 38 * theme.scaling,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: colors.primary.withAlpha(24),
                    borderColor: colors.primary.withAlpha(70),
                    child: Center(
                      child: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : 'C',
                        style: theme.typography.h4.copyWith(color: colors.primary),
                      ),
                    ),
                  ),
                  const shad.DensityGap(shad.gapMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.displayName, style: theme.typography.h4),
                        if ((contact.jobTitle ?? '').isNotEmpty ||
                            (contact.companyName ?? '').isNotEmpty)
                          Text(
                            [contact.jobTitle, contact.companyName]
                                .where((s) => s != null && s.isNotEmpty)
                                .join(' @ '),
                            style: theme.typography.xSmall
                                .copyWith(color: colors.mutedForeground),
                          ),
                      ],
                    ),
                  ),
                  _isolatedBadge(
                    shad.SecondaryBadge(
                      child: Text(
                        contact.syncStatus,
                        style: theme.typography.xSmall.copyWith(
                          color: syncColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const shad.DensityGap(shad.gapSm),
              Wrap(
                spacing: 6 * theme.scaling,
                runSpacing: 6 * theme.scaling,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _isolatedBadge(
                    shad.OutlineBadge(child: Text(contact.importSource)),
                  ),
                  for (final lbl in contact.groupLabels)
                    _buildRemovableLabelChip(contact, lbl),
                  if (assignableGroups.isNotEmpty &&
                      contact.resourceName.startsWith('people/'))
                    SizedBox(
                      width: 145 * theme.scaling,
                      child: shad.Select<String>(
                        placeholder: const Text('+ Add Label'),
                        onChanged: (rn) {
                          if (rn != null) _toggleGoogleLabel(contact, rn, true);
                        },
                        itemBuilder: (ctx, rn) =>
                            Text(widget.contactGroupsMap[rn] ?? rn),
                        popup: shad.SelectPopup(
                          items: shad.SelectItemList(
                            children: [
                              for (final entry in assignableGroups)
                                shad.SelectItemButton(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                            ],
                          ),
                        ).call,
                      ),
                    ),
                ],
              ),
              const shad.DensityGap(shad.gapSm),
              _kvRow('Resource', contact.resourceName, theme, colors, mono: true),
              if (contact.etag != null && contact.etag!.isNotEmpty)
                _kvRow('ETag', contact.etag!, theme, colors, mono: true),
            ],
          ),
        ),
        const shad.DensityGap(shad.gapMd),
        _sectionTitle('Phone Numbers (${contact.phoneList.length})', theme, colors),
        const shad.DensityGap(shad.gapXs),
        shad.OutlinedContainer(
          backgroundColor: colors.card,
          borderColor: colors.border,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          padding: EdgeInsets.all(pad),
          child: contact.phoneList.isEmpty
              ? Text(
                  'No phone numbers recorded.',
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in contact.phoneList)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2 * theme.scaling),
                        child: Row(
                          children: [
                            _isolatedBadge(
                              shad.SecondaryBadge(child: Text(p.displayLabel)),
                            ),
                            const shad.DensityGap(shad.gapSm),
                            Expanded(
                              child: Text(
                                p.preferredNumber,
                                style: theme.typography.mono
                                    .copyWith(fontSize: 12 * theme.scaling),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (contact.phoneNorms.isNotEmpty) ...[
                      const shad.DensityGap(shad.gapXs),
                      shad.Divider(color: colors.border),
                      const shad.DensityGap(shad.gapXs),
                      Text(
                        'Indexed Norms: ${contact.phoneNorms.join(", ")}',
                        style: theme.typography.mono.copyWith(
                          fontSize: 10 * theme.scaling,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        const shad.DensityGap(shad.gapMd),
        if (contact.emailList.isNotEmpty ||
            contact.addresses.isNotEmpty ||
            (contact.notesText ?? '').isNotEmpty) ...[
          _sectionTitle('Emails, Address & Notes', theme, colors),
          const shad.DensityGap(shad.gapXs),
          shad.OutlinedContainer(
            backgroundColor: colors.card,
            borderColor: colors.border,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in contact.emailList)
                  _kvRow('Email (${e.type})', e.value, theme, colors),
                for (final addr in contact.addresses)
                  if (addr['formattedValue'] != null)
                    _kvRow('Address', addr['formattedValue'].toString(), theme,
                        colors),
                if ((contact.notesText ?? '').isNotEmpty) ...[
                  const shad.DensityGap(shad.gapXs),
                  Text('Notes',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground)),
                  const shad.DensityGap(shad.gapXs),
                  Text(contact.notesText!, style: theme.typography.xSmall),
                ],
              ],
            ),
          ),
          const shad.DensityGap(shad.gapMd),
        ],
        _sectionTitle(
          'M:N ERP Group & Party Links (${contact.erpLinks.length})',
          theme,
          colors,
        ),
        const shad.DensityGap(shad.gapXs),
        shad.OutlinedContainer(
          backgroundColor: colors.card,
          borderColor: colors.border,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          padding: EdgeInsets.all(pad),
          child: contact.erpLinks.isEmpty
              ? Text(
                  'Not linked to an ERP Party or Account Group yet. Click "Link ERP [L]" above.',
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground),
                )
              : Column(
                  children: [
                    for (final link in contact.erpLinks)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3 * theme.scaling),
                        child: Row(
                          children: [
                            _isolatedBadge(
                              shad.PrimaryBadge(child: Text(link.kind)),
                            ),
                            const shad.DensityGap(shad.gapXs),
                            if (link.role.isNotEmpty) ...[
                              _isolatedBadge(
                                shad.SecondaryBadge(child: Text(link.role)),
                              ),
                              const shad.DensityGap(shad.gapSm),
                            ],
                            Expanded(
                              child: Text(
                                '${link.name.isNotEmpty ? link.name : link.code} (${link.code})',
                                style: theme.typography.xSmall
                                    .copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            shad.GhostButton(
                              size: shad.ButtonSize.small,
                              onPressed: () async {
                                final ok = await widget.service.removeErpLink(
                                  contact: contact,
                                  kind: link.kind,
                                  code: link.code,
                                );
                                if (ok && mounted) widget.onContactUpdated();
                              },
                              child: const Icon(shad.LucideIcons.unlink, size: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const shad.DensityGap(shad.gapMd),
        shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: _loadingRaw ? null : () => _loadRawJson(contact.id),
          child: Text(_loadingRaw
              ? 'Loading Lossless JSON...'
              : 'Inspect Lossless Raw JSON'),
        ),
        if (_rawPerson != null) ...[
          const shad.DensityGap(shad.gapSm),
          shad.OutlinedContainer(
            backgroundColor: isDark
                ? colors.muted.withAlpha(45)
                : colors.muted.withAlpha(90),
            borderColor: colors.border,
            borderRadius: BorderRadius.circular(theme.radiusSm),
            padding: EdgeInsets.all(pad),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(_rawPerson),
              style: theme.typography.mono.copyWith(fontSize: 10 * theme.scaling),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRemovableLabelChip(GoogleContact contact, String labelName) {
    final matching =
        widget.contactGroupsMap.entries.where((e) => e.value == labelName);
    final groupRn = matching.isNotEmpty ? matching.first.key : null;
    if (groupRn == null || !contact.resourceName.startsWith('people/')) {
      return _isolatedBadge(shad.OutlineBadge(child: Text(labelName)));
    }
    return shad.OutlineButton(
      size: shad.ButtonSize.small,
      onPressed: () => _toggleGoogleLabel(contact, groupRn, false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(labelName),
          const shad.DensityGap(shad.gapXs),
          const Icon(shad.LucideIcons.x, size: 11),
        ],
      ),
    );
  }

  Widget _feedbackBanner(PullResult res, shad.ThemeData theme, double pad) {
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        res.isSuccess ? DyColorSystem.emerald500 : DyColorSystem.orange500;
    return shad.OutlinedContainer(
      backgroundColor: DyColorSystem.resolveSurface(accent, isDark),
      borderColor: DyColorSystem.resolveBorder(accent, isDark),
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: EdgeInsets.all(pad * 0.8),
      child: Text(
        res.detail != null && !res.isSuccess
            ? '${res.message} (${res.detail})'
            : res.message,
        style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) =>
      Text(
        title,
        style: theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.mutedForeground,
        ),
      );

  Widget _kvRow(
    String label,
    String value,
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    bool mono = false,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 2 * theme.scaling),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 82 * theme.scaling,
              child: Text(
                label,
                style: theme.typography.xSmall
                    .copyWith(color: colors.mutedForeground),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: (mono ? theme.typography.mono : theme.typography.xSmall)
                    .copyWith(fontSize: 12 * theme.scaling),
              ),
            ),
          ],
        ),
      );

  Widget _isolatedBadge(Widget badge) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: false,
        child: badge,
      );
}
