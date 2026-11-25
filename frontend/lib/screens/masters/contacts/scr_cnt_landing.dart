/*
================================================================================
LLM CONTEXT & QUERY SPACE — CONTACTS MASTER LANDING SCREEN (scr_cnt_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Contacts & Directory Sync
     (`IMMBE2627.sb_contacts`, navigation index `111`).
   - Provides clean 4-Region Bento blank state with a `Legacy` button in the
     `PageHeader` that opens the existing `ScreenGoogleContactsSync` reference
     workspace in a full dialog overlay (`screen_google_contacts_sync.dart` and
     all `contacts/widgets/` files remain preserved).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses `DyLinearLandingCanvas` (`9:3` Bento split) + `36px` DABs.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_contacts` already holds imported Google records; Phase 2/3 will rewire
     them directly into these 4 regions cleanly.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Keep `screen_google_contacts_sync.dart` + `contacts/widgets/` until Phase 3
     cutover finishes.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';
import 'screen_google_contacts_sync.dart';

/// Linear Landing screen for Contacts (`IMMBE2627.sb_contacts`).
class ScrCntLanding extends StatelessWidget {
  const ScrCntLanding({super.key});

  static final DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Contacts',
    moduleName: 'Contact',
    entityPlural: 'Contacts',
    targetTable: 'IMMBE2627.sb_contacts',
    formIcon: shad.LucideIcons.contact,
    headerExtraActionsBuilder: (context) => [
      PageHeaderActionButton(
        label: 'Legacy',
        icon: shad.LucideIcons.history,
        onPressed: () => showDyLegacyOverlay(
          context,
          title:
              'Legacy Google Contacts Sync Reference (screen_google_contacts_sync.dart)',
          builder: (_) => const ScreenGoogleContactsSync(),
        ),
      ),
    ],
    kpis: const [
      MastersKpiSpec(
        title: 'TOTAL CONTACTS',
        subtitle: 'Awaiting Phase 2 view binding',
        icon: shad.LucideIcons.contact,
        tone: DyKpiTone.primary,
      ),
      MastersKpiSpec(
        title: 'GOOGLE SYNCED',
        subtitle: 'design.ambaji@gmail.com',
        icon: shad.LucideIcons.refreshCw,
        tone: DyKpiTone.success,
      ),
      MastersKpiSpec(
        title: 'PARTY LINKED',
        subtitle: 'Mapped to sb_parties',
        icon: shad.LucideIcons.link,
        tone: DyKpiTone.indigo,
      ),
      MastersKpiSpec(
        title: 'PENDING PUSH',
        subtitle: 'Local edits queued',
        icon: shad.LucideIcons.cloudUpload,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'name', label: 'Contact Name', flex: 2, isPinnedLeft: true),
      DyTableColumnSpec(key: 'phone', label: 'Primary Phone', flex: 1),
      DyTableColumnSpec(key: 'company', label: 'Company / Org', flex: 2),
      DyTableColumnSpec(key: 'party', label: 'Linked Party', flex: 1),
      DyTableColumnSpec(key: 'city', label: 'City', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Sync State', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'name', label: 'Display Name', flex: 2, isPinnedLeft: true),
      DyTableColumnSpec(key: 'phone', label: 'Mobile', flex: 1),
      DyTableColumnSpec(key: 'altPhone', label: 'Work Phone', flex: 1),
      DyTableColumnSpec(key: 'email', label: 'Email', flex: 2),
      DyTableColumnSpec(key: 'company', label: 'Company', flex: 1),
      DyTableColumnSpec(key: 'jobTitle', label: 'Designation', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Linked Party', flex: 1),
      DyTableColumnSpec(key: 'group', label: 'Label / Group', flex: 1),
      DyTableColumnSpec(key: 'city', label: 'City', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Sync State', flex: 1),
    ],
    partyFilterLabel: 'Link Status',
    partyFilterIcon: shad.LucideIcons.link,
    partyOptions: ['Linked Party', 'Unlinked', 'Multiple Parties'],
    millFilterLabel: 'Google Label',
    millFilterIcon: shad.LucideIcons.tag,
    millOptions: ['Suppliers', 'Customers', 'Karigars', 'Brokers', 'Mills', 'Staff'],
    fabricFilterLabel: 'Channel',
    fabricFilterIcon: shad.LucideIcons.smartphone,
    fabricOptions: ['WhatsApp Verified', 'Phone Only', 'Has Email'],
    statusOptions: ['Synced', 'Pending Push', 'Local Only'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'company', label: 'Company', icon: shad.LucideIcons.building2),
      DabGroupOption(id: 'city', label: 'City', icon: shad.LucideIcons.mapPin),
      DabGroupOption(id: 'status', label: 'Sync', icon: shad.LucideIcons.refreshCw),
    ],
    taskQueues: const ['All', 'Unlinked', 'Push Queue'],
    reportLenses: const ['By Label', 'By City', 'Sync Health'],
    addFormFields: const [
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Full Display Name *'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Primary Mobile / WhatsApp *'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Company / Firm'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Email Address'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Job Title / Role'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'City / Location'),
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Link to ERP Party (sb_parties)'),
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MastersBlankLinearLanding(config: _config);
  }
}
