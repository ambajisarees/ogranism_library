/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - `[N]` Add Flow Panel (`ContactsAddFlowPanel` + `ContactsAddFlowController`)
     for Stage 9.3 Google Contacts Workspace (`ScreenGoogleContactsSync`).
   - Renders inside `DyLinearLandingCanvas.addFlowBuilder` (`PageHeaderMode.adding`)
     to create a brand-new contact, optionally link an initial ERP Party or
     Account Group, and push directly to `design.ambaji@gmail.com` via Google
     People API `people:createContact` or save an offline `LOCAL_ONLY` draft.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Exposes `ContactsAddFlowController.buildDraftContact(accountEmail)` so parent
     `DyLinearLandingCanvas` `onConfirmAdd` and `onSaveDraftAdd` actions read the
     current form values cleanly without duplicating save logic.
   - Supports dynamic multi-phone and multi-email rows with type dropdowns
     (`mobile`, `work`, `home`, `main`).
   - Built strictly with native `shadcn_flutter` controls, `theme.density.*`
     multipliers, `theme.typography.*`, and `colors.*`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Requires at least Display Name OR Given Name OR Company OR Primary Phone;
     `GoogleContactsMapper.buildLocalWriteFields` resolves a safe fallback name.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Caller ID display-name enrichment formatting is deferred per user.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../models/masters/model_google_contacts.dart';
import '../../../../services/masters/service_google_contacts.dart';
import 'scr_contacts_group_empire.dart';

/// Mutable form row for repeatable phones/emails in Add & Inline Edit flows.
class ContactFieldRowController {
  final TextEditingController valueCtrl;
  String type;

  ContactFieldRowController({String initialValue = '', this.type = 'mobile'})
      : valueCtrl = TextEditingController(text: initialValue);

  void dispose() => valueCtrl.dispose();
}

/// Controller backing [ContactsAddFlowPanel] and parent [DyLinearLandingCanvas] saves.
class ContactsAddFlowController extends ChangeNotifier {
  final TextEditingController givenNameCtrl = TextEditingController();
  final TextEditingController familyNameCtrl = TextEditingController();
  final TextEditingController displayNameCtrl = TextEditingController();
  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController jobTitleCtrl = TextEditingController();
  final TextEditingController departmentCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  final List<ContactFieldRowController> phoneRows = [
    ContactFieldRowController(type: 'mobile'),
  ];
  final List<ContactFieldRowController> emailRows = [
    ContactFieldRowController(type: 'work'),
  ];

  final List<ErpContactLink> initialErpLinks = [];
  bool isStarred = false;

  void addPhoneRow() {
    phoneRows.add(ContactFieldRowController(type: 'mobile'));
    notifyListeners();
  }

  void removePhoneRow(int index) {
    if (phoneRows.length <= 1) {
      phoneRows.first.valueCtrl.clear();
    } else {
      phoneRows.removeAt(index).dispose();
    }
    notifyListeners();
  }

  void setPhoneType(int index, String nextType) {
    if (index >= 0 && index < phoneRows.length) {
      phoneRows[index].type = nextType;
      notifyListeners();
    }
  }

  void addEmailRow() {
    emailRows.add(ContactFieldRowController(type: 'work'));
    notifyListeners();
  }

  void removeEmailRow(int index) {
    if (emailRows.length <= 1) {
      emailRows.first.valueCtrl.clear();
    } else {
      emailRows.removeAt(index).dispose();
    }
    notifyListeners();
  }

  void setEmailType(int index, String nextType) {
    if (index >= 0 && index < emailRows.length) {
      emailRows[index].type = nextType;
      notifyListeners();
    }
  }

  void addInitialErpLink(ErpContactLink link) {
    initialErpLinks.removeWhere(
      (e) => e.kind == link.kind && e.code == link.code,
    );
    initialErpLinks.add(link);
    notifyListeners();
  }

  void removeInitialErpLink(ErpContactLink link) {
    initialErpLinks.removeWhere(
      (e) => e.kind == link.kind && e.code == link.code,
    );
    notifyListeners();
  }

  void toggleStarred() {
    isStarred = !isStarred;
    notifyListeners();
  }

  void reset() {
    givenNameCtrl.clear();
    familyNameCtrl.clear();
    displayNameCtrl.clear();
    companyCtrl.clear();
    jobTitleCtrl.clear();
    departmentCtrl.clear();
    cityCtrl.clear();
    addressCtrl.clear();
    notesCtrl.clear();
    for (final p in phoneRows) {
      p.dispose();
    }
    for (final e in emailRows) {
      e.dispose();
    }
    phoneRows
      ..clear()
      ..add(ContactFieldRowController(type: 'mobile'));
    emailRows
      ..clear()
      ..add(ContactFieldRowController(type: 'work'));
    initialErpLinks.clear();
    isStarred = false;
    notifyListeners();
  }

  bool get hasMinimumIdentity =>
      displayNameCtrl.text.trim().isNotEmpty ||
      givenNameCtrl.text.trim().isNotEmpty ||
      familyNameCtrl.text.trim().isNotEmpty ||
      companyCtrl.text.trim().isNotEmpty ||
      phoneRows.any((p) => p.valueCtrl.text.trim().isNotEmpty);

  /// Materializes a [GoogleContact] draft ready for `createContactAndPush`.
  GoogleContact buildDraftContact({
    String accountEmail = ServiceGoogleContacts.defaultGoogleEmail,
  }) {
    final given = givenNameCtrl.text.trim();
    final family = familyNameCtrl.text.trim();
    final combined =
        [given, family].where((s) => s.isNotEmpty).join(' ').trim();
    final phones = [
      for (final p in phoneRows)
        if (p.valueCtrl.text.trim().isNotEmpty)
          GooglePhoneEntry(
            value: p.valueCtrl.text.trim(),
            type: p.type,
          ),
    ];
    final emails = [
      for (final e in emailRows)
        if (e.valueCtrl.text.trim().isNotEmpty)
          GoogleEmailEntry(
            value: e.valueCtrl.text.trim(),
            type: e.type,
          ),
    ];
    final company = companyCtrl.text.trim();
    final jobTitle = jobTitleCtrl.text.trim();
    final dept = departmentCtrl.text.trim();
    final city = cityCtrl.text.trim();
    final street = addressCtrl.text.trim();
    final formattedAddr =
        [street, city].where((s) => s.isNotEmpty).join(', ').trim();

    final effectiveDisplay = displayNameCtrl.text.trim().isNotEmpty
        ? displayNameCtrl.text.trim()
        : (combined.isNotEmpty
            ? combined
            : (company.isNotEmpty
                ? company
                : (phones.isNotEmpty
                    ? phones.first.value
                    : 'New ERP Contact')));

    final now = DateTime.now();
    return GoogleContact(
      id: '',
      googleAccountEmail: accountEmail,
      resourceName: 'local/${now.millisecondsSinceEpoch}',
      displayName: effectiveDisplay,
      givenName: given.isNotEmpty ? given : null,
      familyName: family.isNotEmpty ? family : null,
      companyName: company.isNotEmpty ? company : null,
      jobTitle: jobTitle.isNotEmpty ? jobTitle : null,
      primaryPhone: phones.isNotEmpty ? phones.first.value : 'N/A',
      primaryEmail: emails.isNotEmpty ? emails.first.value : null,
      notesText: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
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
      linkedGroupCodes: initialErpLinks
          .where((l) => l.kind == 'GROUP')
          .map((l) => l.code)
          .toList(),
      linkedMasterCodes: initialErpLinks
          .where((l) => l.kind != 'GROUP')
          .map((l) => l.code)
          .toList(),
      erpLinks: List<ErpContactLink>.from(initialErpLinks),
      isStarred: isStarred,
      syncStatus: 'LOCAL_ONLY',
      importSource: 'ERP_MANUAL',
      lastSyncedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  void dispose() {
    givenNameCtrl.dispose();
    familyNameCtrl.dispose();
    displayNameCtrl.dispose();
    companyCtrl.dispose();
    jobTitleCtrl.dispose();
    departmentCtrl.dispose();
    cityCtrl.dispose();
    addressCtrl.dispose();
    notesCtrl.dispose();
    for (final p in phoneRows) {
      p.dispose();
    }
    for (final e in emailRows) {
      e.dispose();
    }
    super.dispose();
  }
}

/// Full-canvas native `shadcn_flutter` form rendered inside `DyLinearLandingCanvas` `[N]` mode.
class ContactsAddFlowPanel extends StatelessWidget {
  final ContactsAddFlowController controller;
  final ServiceGoogleContacts service;
  final String? errorBanner;
  final VoidCallback onCancel;

  const ContactsAddFlowPanel({
    super.key,
    required this.controller,
    required this.service,
    this.errorBanner,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: pad * 2),
          child: shad.OutlinedContainer(
            backgroundColor: colors.card,
            borderColor: colors.border,
            borderRadius: theme.borderRadiusLg,
            padding: EdgeInsets.all(pad * 1.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(shad.LucideIcons.userPlus,
                        size: 18 * theme.scaling, color: colors.primary),
                    const shad.DensityGap(shad.gapSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Contact & Sync to design.ambaji@gmail.com',
                            style: theme.typography.h4,
                          ),
                          Text(
                            'Confirm pushes live via Google People API createContact; Draft saves offline as LOCAL_ONLY.',
                            style: theme.typography.xSmall
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: controller.toggleStarred,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            shad.LucideIcons.star,
                            size: 14 * theme.scaling,
                            color: controller.isStarred
                                ? colors.primary
                                : colors.mutedForeground,
                          ),
                          const shad.DensityGap(shad.gapXs),
                          Text(controller.isStarred ? 'Starred' : 'Star'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (errorBanner != null && errorBanner!.isNotEmpty) ...[
                  const shad.DensityGap(shad.gapMd),
                  shad.OutlinedContainer(
                    backgroundColor: colors.destructive.withAlpha(24),
                    borderColor: colors.destructive,
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                    padding: EdgeInsets.all(pad),
                    child: Text(
                      errorBanner!,
                      style: theme.typography.xSmall
                          .copyWith(color: colors.destructive),
                    ),
                  ),
                ],
                const shad.DensityGap(shad.gapLg),
                _twoColRow(
                  _labeledField(theme, colors, 'Given Name',
                      controller.givenNameCtrl, 'e.g. Rajesh'),
                  _labeledField(theme, colors, 'Family Name',
                      controller.familyNameCtrl, 'e.g. Agarwal'),
                ),
                const shad.DensityGap(shad.gapMd),
                _twoColRow(
                  _labeledField(theme, colors, 'Display Name (Override)',
                      controller.displayNameCtrl, 'Auto-built if blank'),
                  _labeledField(theme, colors, 'Company / Firm Name',
                      controller.companyCtrl, 'e.g. Ambaji Silk Creations'),
                ),
                const shad.DensityGap(shad.gapMd),
                _twoColRow(
                  _labeledField(theme, colors, 'Role / Title',
                      controller.jobTitleCtrl, 'e.g. Proprietor / Buyer'),
                  _labeledField(theme, colors, 'Department',
                      controller.departmentCtrl, 'e.g. Purchasing'),
                ),
                const shad.DensityGap(shad.gapLg),
                _sectionHeader(
                  theme,
                  colors,
                  'Phone Numbers (${controller.phoneRows.length})',
                  actionLabel: '+ Add Phone',
                  onAction: controller.addPhoneRow,
                ),
                const shad.DensityGap(shad.gapXs),
                for (int i = 0; i < controller.phoneRows.length; i++) ...[
                  _repeatableRow(
                    theme: theme,
                    row: controller.phoneRows[i],
                    placeholder: '+91 98251 00000',
                    types: const ['mobile', 'work', 'home', 'main'],
                    onTypeChanged: (val) => controller.setPhoneType(i, val),
                    onRemove: () => controller.removePhoneRow(i),
                  ),
                  const shad.DensityGap(shad.gapXs),
                ],
                const shad.DensityGap(shad.gapMd),
                _sectionHeader(
                  theme,
                  colors,
                  'Email Addresses (${controller.emailRows.length})',
                  actionLabel: '+ Add Email',
                  onAction: controller.addEmailRow,
                ),
                const shad.DensityGap(shad.gapXs),
                for (int i = 0; i < controller.emailRows.length; i++) ...[
                  _repeatableRow(
                    theme: theme,
                    row: controller.emailRows[i],
                    placeholder: 'accounts@firm.com',
                    types: const ['work', 'home', 'other'],
                    onTypeChanged: (val) => controller.setEmailType(i, val),
                    onRemove: () => controller.removeEmailRow(i),
                  ),
                  const shad.DensityGap(shad.gapXs),
                ],
                const shad.DensityGap(shad.gapMd),
                _twoColRow(
                  _labeledField(theme, colors, 'Street Address',
                      controller.addressCtrl, 'Market / Ring Road address'),
                  _labeledField(
                      theme, colors, 'City', controller.cityCtrl, 'Surat'),
                ),
                const shad.DensityGap(shad.gapMd),
                _labeledField(theme, colors, 'Notes / Google Biography',
                    controller.notesCtrl, 'Internal remarks & notes...',
                    maxLines: 3),
                const shad.DensityGap(shad.gapLg),
                _sectionHeader(
                  theme,
                  colors,
                  'Initial ERP Party / Account Group Links (${controller.initialErpLinks.length})',
                  actionLabel: '+ Link Party / Group',
                  onAction: () async {
                    final link = await showContactsErpLinkPickerModal(
                      context: context,
                      contactName: controller.displayNameCtrl.text.trim().isNotEmpty
                          ? controller.displayNameCtrl.text.trim()
                          : 'New Contact',
                      service: service,
                    );
                    if (link != null) controller.addInitialErpLink(link);
                  },
                ),
                const shad.DensityGap(shad.gapXs),
                if (controller.initialErpLinks.isEmpty)
                  Text(
                    'Optional — link to one or more sq_MASTER parties or sq_ACGROUP account groups now or later.',
                    style: theme.typography.xSmall
                        .copyWith(color: colors.mutedForeground),
                  )
                else
                  Wrap(
                    spacing: 8 * theme.scaling,
                    runSpacing: 8 * theme.scaling,
                    children: [
                      for (final link in controller.initialErpLinks)
                        shad.OutlineButton(
                          size: shad.ButtonSize.small,
                          onPressed: () => controller.removeInitialErpLink(link),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Focus(
                                canRequestFocus: false,
                                skipTraversal: true,
                                descendantsAreFocusable: false,
                                child: shad.PrimaryBadge(
                                  child: Text('${link.kind} • ${link.role}'),
                                ),
                              ),
                              const shad.DensityGap(shad.gapXs),
                              Text('${link.name} (${link.code})'),
                              const shad.DensityGap(shad.gapXs),
                              const Icon(shad.LucideIcons.x, size: 12),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _twoColRow(Widget left, Widget right) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const shad.DensityGap(shad.gapMd),
          Expanded(child: right),
        ],
      );

  Widget _labeledField(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.mutedForeground,
            ),
          ),
          const shad.DensityGap(shad.gapXs),
          shad.TextField(
            controller: ctrl,
            maxLines: maxLines,
            placeholder: Text(hint),
          ),
        ],
      );

  Widget _sectionHeader(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String title, {
    required String actionLabel,
    required VoidCallback onAction,
  }) =>
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.mutedForeground,
              ),
            ),
          ),
          shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      );

  Widget _repeatableRow({
    required shad.ThemeData theme,
    required ContactFieldRowController row,
    required String placeholder,
    required List<String> types,
    required ValueChanged<String> onTypeChanged,
    required VoidCallback onRemove,
  }) =>
      Row(
        children: [
          SizedBox(
            width: 110 * theme.scaling,
            child: shad.Select<String>(
              value: types.contains(row.type) ? row.type : types.first,
              onChanged: (val) {
                if (val != null) onTypeChanged(val);
              },
              itemBuilder: (ctx, v) => Text(v),
              popup: shad.SelectPopup(
                items: shad.SelectItemList(
                  children: [
                    for (final t in types)
                      shad.SelectItemButton(value: t, child: Text(t)),
                  ],
                ),
              ).call,
            ),
          ),
          const shad.DensityGap(shad.gapSm),
          Expanded(
            child: shad.TextField(
              controller: row.valueCtrl,
              placeholder: Text(placeholder),
            ),
          ),
          const shad.DensityGap(shad.gapXs),
          shad.IconButton.ghost(
            size: shad.ButtonSize.small,
            icon: const Icon(shad.LucideIcons.trash2, size: 14),
            onPressed: onRemove,
          ),
        ],
      );
}
