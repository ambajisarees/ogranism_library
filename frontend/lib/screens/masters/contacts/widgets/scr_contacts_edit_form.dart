/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Inline Two-Way Google Contact Edit Form (`ContactTwoWayEditForm`) and shared
     `ContactEditableFieldRow` backing Region [4] (`ContactDetailInspectorBentoCard`).
   - Supports multi-phone and multi-email dynamic rows, company/job/department
     metadata, address, and biography/notes with `Save & Push to Google` (etag
     concurrency PATCH) or `Save Offline (Queue)`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` tokens (`colors.*`, `theme.density.*`,
     `theme.typography.*`, `DyColorSystem`).
   - Extracted from `scr_contacts_inspector.dart` per `GEMINI.md` Rule 2 (<1000 LOC).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Controllers are owned and disposed by `_ContactDetailInspectorBentoCardState`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Google People API caller-ID display formatting rules deferred per user.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/masters/model_google_contacts.dart';

/// Mutable form row for repeatable phones/emails inside the inline inspector editor.
class ContactEditableFieldRow {
  final TextEditingController ctrl;
  String type;

  ContactEditableFieldRow({String value = '', this.type = 'mobile'})
      : ctrl = TextEditingController(text: value);

  void dispose() => ctrl.dispose();
}

/// Inline Two-Way Google Edit form rendered inside `ContactDetailInspectorBentoCard`.
class ContactTwoWayEditForm extends StatelessWidget {
  final GoogleContact contact;
  final TextEditingController givenCtrl;
  final TextEditingController familyCtrl;
  final TextEditingController displayCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController jobTitleCtrl;
  final TextEditingController deptCtrl;
  final TextEditingController streetCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController notesCtrl;
  final List<ContactEditableFieldRow> phoneRows;
  final List<ContactEditableFieldRow> emailRows;
  final bool isSaving;
  final VoidCallback onAddPhone;
  final void Function(int idx, String type) onPhoneTypeChanged;
  final ValueChanged<int> onRemovePhone;
  final VoidCallback onAddEmail;
  final void Function(int idx, String type) onEmailTypeChanged;
  final ValueChanged<int> onRemoveEmail;
  final VoidCallback onCancel;
  final VoidCallback onSaveOffline;
  final VoidCallback onSaveAndPush;

  const ContactTwoWayEditForm({
    super.key,
    required this.contact,
    required this.givenCtrl,
    required this.familyCtrl,
    required this.displayCtrl,
    required this.companyCtrl,
    required this.jobTitleCtrl,
    required this.deptCtrl,
    required this.streetCtrl,
    required this.cityCtrl,
    required this.notesCtrl,
    required this.phoneRows,
    required this.emailRows,
    required this.isSaving,
    required this.onAddPhone,
    required this.onPhoneTypeChanged,
    required this.onRemovePhone,
    required this.onAddEmail,
    required this.onEmailTypeChanged,
    required this.onRemoveEmail,
    required this.onCancel,
    required this.onSaveOffline,
    required this.onSaveAndPush,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        shad.OutlinedContainer(
          backgroundColor:
              DyColorSystem.resolveSurface(DyColorSystem.cyan500, isDark),
          borderColor:
              DyColorSystem.resolveBorder(DyColorSystem.cyan500, isDark),
          borderRadius: BorderRadius.circular(theme.radiusSm),
          padding: EdgeInsets.all(pad * 0.8),
          child: Text(
            'Two-Way Edit Active — Saving pushes updated fields live to Google People API v1 with ETag (${contact.etag ?? 'auto'}) concurrency check.',
            style: theme.typography.xSmall,
          ),
        ),
        const shad.DensityGap(shad.gapMd),
        Row(
          children: [
            Expanded(child: _inputField(theme, colors, 'Given Name', givenCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _inputField(theme, colors, 'Family Name', familyCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _inputField(theme, colors, 'Display Name', displayCtrl)),
          ],
        ),
        const shad.DensityGap(shad.gapSm),
        Row(
          children: [
            Expanded(child: _inputField(theme, colors, 'Company / Firm', companyCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _inputField(theme, colors, 'Job Title / Role', jobTitleCtrl)),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _inputField(theme, colors, 'Department', deptCtrl)),
          ],
        ),
        const shad.DensityGap(shad.gapMd),
        Row(
          children: [
            Expanded(child: _sectionTitle('Phone Numbers', theme, colors)),
            shad.OutlineButton(
              size: shad.ButtonSize.small,
              onPressed: onAddPhone,
              child: const Text('+ Phone'),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapXs),
        for (int i = 0; i < phoneRows.length; i++) ...[
          _repeatableRow(
            theme: theme,
            row: phoneRows[i],
            types: const ['mobile', 'work', 'home', 'main'],
            hint: '+91 98251 00000',
            onTypeChanged: (v) => onPhoneTypeChanged(i, v),
            onRemove: () => onRemovePhone(i),
          ),
          const shad.DensityGap(shad.gapXs),
        ],
        const shad.DensityGap(shad.gapSm),
        Row(
          children: [
            Expanded(child: _sectionTitle('Emails', theme, colors)),
            shad.OutlineButton(
              size: shad.ButtonSize.small,
              onPressed: onAddEmail,
              child: const Text('+ Email'),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapXs),
        for (int i = 0; i < emailRows.length; i++) ...[
          _repeatableRow(
            theme: theme,
            row: emailRows[i],
            types: const ['work', 'home', 'other'],
            hint: 'name@company.com',
            onTypeChanged: (v) => onEmailTypeChanged(i, v),
            onRemove: () => onRemoveEmail(i),
          ),
          const shad.DensityGap(shad.gapXs),
        ],
        const shad.DensityGap(shad.gapSm),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _inputField(theme, colors, 'Street Address', streetCtrl),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(child: _inputField(theme, colors, 'City', cityCtrl)),
          ],
        ),
        const shad.DensityGap(shad.gapSm),
        _inputField(theme, colors, 'Notes / Google Biography', notesCtrl,
            maxLines: 2),
        const shad.DensityGap(shad.gapLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            shad.GhostButton(
              onPressed: isSaving ? null : onCancel,
              child: const Text('Cancel'),
            ),
            const shad.DensityGap(shad.gapSm),
            shad.OutlineButton(
              onPressed: isSaving ? null : onSaveOffline,
              child: const Text('Save Offline (Queue)'),
            ),
            const shad.DensityGap(shad.gapSm),
            shad.PrimaryButton(
              onPressed: isSaving ? null : onSaveAndPush,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(shad.LucideIcons.save, size: 14),
                  const shad.DensityGap(shad.gapXs),
                  Text(isSaving ? 'Pushing...' : 'Save & Push to Google'),
                ],
              ),
            ),
          ],
        ),
      ],
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

  Widget _inputField(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.typography.xSmall
                  .copyWith(color: colors.mutedForeground)),
          const shad.DensityGap(shad.gapXs),
          shad.TextField(controller: ctrl, maxLines: maxLines),
        ],
      );

  Widget _repeatableRow({
    required shad.ThemeData theme,
    required ContactEditableFieldRow row,
    required List<String> types,
    required String hint,
    required ValueChanged<String> onTypeChanged,
    required VoidCallback onRemove,
  }) =>
      Row(
        children: [
          SizedBox(
            width: 105 * theme.scaling,
            child: shad.Select<String>(
              value: types.contains(row.type) ? row.type : types.first,
              onChanged: (v) {
                if (v != null) onTypeChanged(v);
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
            child: shad.TextField(controller: row.ctrl, placeholder: Text(hint)),
          ),
          const shad.DensityGap(shad.gapXs),
          shad.IconButton.ghost(
            size: shad.ButtonSize.small,
            icon: const Icon(shad.LucideIcons.trash2, size: 13),
            onPressed: onRemove,
          ),
        ],
      );
}
