/*
================================================================================
LLM CONTEXT & QUERY SPACE — MARKETING & CRM LANDING SCREEN (scr_mkt_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for WhatsApp CRM & Outbound Marketing
     (`IMMBE2627.sb_crm_tickets`, navigation index `107`).
   - Standardizes onto `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas`
     while keeping `CrmWorkspacePage` (`screen_crm_workspace.dart`) accessible
     under a `Legacy` button in `PageHeader` for WebView2 WhatsApp reference.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Tracks CRM pipeline stages (`Discovery`, `Intent`, `Staged`, `Completed`),
     broadcast catalog shares, and sample photo requests.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_crm_tickets` staged for Phase 2 Supabase sync; Phase 1 displays clean
     blank states.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Integrate embedded WebView2 WhatsApp trigger cleanly into Tasks/Inspector
     during Phase 2 CRM cutover.
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
import 'screen_crm_workspace.dart';

/// Linear Landing screen for Marketing & CRM (`IMMBE2627.sb_crm_tickets`).
class ScrMktLanding extends StatelessWidget {
  const ScrMktLanding({super.key});

  static final DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Marketing',
    moduleName: 'CRM Campaign',
    entityPlural: 'Tickets',
    targetTable: 'IMMBE2627.sb_crm_tickets',
    formIcon: shad.LucideIcons.userCheck,
    headerExtraActionsBuilder: (context) => [
      PageHeaderActionButton(
        label: 'Legacy',
        icon: shad.LucideIcons.history,
        onPressed: () => showDyLegacyOverlay(
          context,
          title: 'Legacy WhatsApp WebView CRM Workspace (screen_crm_workspace.dart)',
          builder: (_) => const CrmWorkspacePage(),
        ),
      ),
    ],
    kpis: const [
      DyRegionKpiSpec(
        title: 'ACTIVE CRM TICKETS',
        subtitle: 'Awaiting sb_crm_tickets bind',
        icon: shad.LucideIcons.userCheck,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'CATALOG BROADCASTS',
        subtitle: 'WhatsApp design shares',
        icon: shad.LucideIcons.send,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'ORDER CONVERSIONS',
        subtitle: 'Promoted to Sales Orders',
        icon: shad.LucideIcons.circleCheck,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'UNANSWERED INQUIRIES',
        subtitle: 'SLA response queue',
        icon: shad.LucideIcons.messageSquare,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'ticketId', label: 'Ticket #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'customer', label: 'Customer / Buyer', flex: 2),
      DyTableColumnSpec(key: 'city', label: 'City', flex: 1),
      DyTableColumnSpec(key: 'design', label: 'Design Ref', flex: 1),
      DyTableColumnSpec(key: 'qty', label: 'Est. Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'stage', label: 'Stage', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'ticketId', label: 'Ticket #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'channel', label: 'Channel', flex: 1),
      DyTableColumnSpec(key: 'customer', label: 'Customer / Buyer', flex: 2),
      DyTableColumnSpec(key: 'phone', label: 'WhatsApp', flex: 1),
      DyTableColumnSpec(key: 'city', label: 'City', flex: 1),
      DyTableColumnSpec(key: 'design', label: 'Design #', flex: 1),
      DyTableColumnSpec(key: 'cut', label: 'Cut', flex: 1),
      DyTableColumnSpec(key: 'qty', label: 'Est. Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'lastActive', label: 'Last Activity', flex: 1),
      DyTableColumnSpec(key: 'stage', label: 'Pipeline Stage', flex: 1),
    ],
    partyFilterLabel: 'Stage',
    partyFilterIcon: shad.LucideIcons.sparkles,
    partyOptions: const [
      'Incoming Discovery',
      'Intent Understanding',
      'Task Staged',
      'Completed',
    ],
    millFilterLabel: 'City',
    millFilterIcon: shad.LucideIcons.mapPin,
    statusOptions: const ['Open', 'Quoted', 'Converted'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'stage', label: 'Stage', icon: shad.LucideIcons.sparkles),
      DabGroupOption(id: 'city', label: 'City', icon: shad.LucideIcons.mapPin),
    ],
    taskQueues: const ['All', 'Follow-Up Due', 'Send Catalog'],
    reportLenses: const ['By Stage', 'By City', 'Design Demand'],
    addFormFields: const [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Party / Prospect (sb_parties) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'WhatsApp Number *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Pipeline Stage (Discovery / Intent)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Interested Design # (sb_designs)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Estimated Qty Pcs'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Assigned Executive'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Buyer Preferences & Follow-up Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DyModuleBlankLanding(config: _config);
  }
}
