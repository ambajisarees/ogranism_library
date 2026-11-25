/*
================================================================================
LLM CONTEXT & QUERY SPACE — SOURCES MASTER LANDING SCREEN (scr_src_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Supply Sources, Brokers & Mill Program Sources
     (`IMMBE2627.sb_sources`, navigation index `12`).
   - Keeps the legacy Vendor Source dialog (`showDsnAddEditDialog(..., initialTab: 0)`)
     accessible under a `Legacy` button in `PageHeader` for side-by-side
     reference while building out `sb_sources`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses `DyLinearLandingCanvas` (`9:3` Bento split) + `36px` DABs.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_sources` currently blank; Phase 2 will finalize broker/mill/finish
     purchase source fields.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Clarify unified fields across Mill Program sources vs Finish Purchase vendors.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../designs/dia_dsn_add_edit.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Sources (`IMMBE2627.sb_sources`).
class ScrSrcLanding extends StatelessWidget {
  const ScrSrcLanding({super.key});

  static final MastersBlankLandingConfig _config = MastersBlankLandingConfig(
    title: 'Sources',
    moduleName: 'Source',
    entityPlural: 'Sources',
    targetTable: 'IMMBE2627.sb_sources',
    formIcon: shad.LucideIcons.compass,
    headerExtraActionsBuilder: (context) => [
      PageHeaderActionButton(
        label: 'Legacy',
        icon: shad.LucideIcons.history,
        onPressed: () => showDsnAddEditDialog(context, initialTab: 0),
      ),
    ],
    kpis: const [
      MastersKpiSpec(
        title: 'TOTAL SOURCES',
        subtitle: 'Awaiting sb_sources build',
        icon: shad.LucideIcons.compass,
        tone: DyKpiTone.primary,
      ),
      MastersKpiSpec(
        title: 'MILL PROGRAMS',
        subtitle: 'Dyeing & printing sources',
        icon: shad.LucideIcons.flaskConical,
        tone: DyKpiTone.cyan,
      ),
      MastersKpiSpec(
        title: 'FINISH VENDORS',
        subtitle: 'Direct finish saree lots',
        icon: shad.LucideIcons.packageCheck,
        tone: DyKpiTone.success,
      ),
      MastersKpiSpec(
        title: 'UNCONVERTED LOTS',
        subtitle: 'Pending Design promotion',
        icon: shad.LucideIcons.sparkles,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'code', label: 'Source Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'type', label: 'Source Type', flex: 1),
      DyTableColumnSpec(key: 'vendor', label: 'Vendor / Mill', flex: 2),
      DyTableColumnSpec(key: 'vendorDes', label: 'Vendor Des #', flex: 1),
      DyTableColumnSpec(key: 'rate', label: 'Base Rate', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'code', label: 'Source Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'type', label: 'Origin Type', flex: 1),
      DyTableColumnSpec(key: 'vendor', label: 'Vendor / Mill', flex: 2),
      DyTableColumnSpec(key: 'vendorDes', label: 'Vendor Des #', flex: 1),
      DyTableColumnSpec(key: 'fabric', label: 'Grey Quality', flex: 2),
      DyTableColumnSpec(key: 'broker', label: 'Haste / Broker', flex: 1),
      DyTableColumnSpec(key: 'rate', label: 'Cost Rate', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'leadDays', label: 'Lead Days', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'designRef', label: 'Design Ref', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Vendor',
    partyFilterIcon: shad.LucideIcons.factory,
    partyOptions: ['Mill Program', 'Finish Purchase', 'Direct Weaver', 'Jobber Source'],
    millFilterLabel: 'Origin',
    millFilterIcon: shad.LucideIcons.compass,
    millOptions: ['Surat', 'Jetpur', 'Pali', 'Ahmedabad', 'Varanasi'],
    fabricFilterLabel: 'Link',
    fabricFilterIcon: shad.LucideIcons.palette,
    fabricOptions: ['Promoted to Design', 'Source Only'],
    statusOptions: ['Active', 'Sample Only', 'Closed'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'type', label: 'Type', icon: shad.LucideIcons.compass),
      DabGroupOption(id: 'vendor', label: 'Vendor', icon: shad.LucideIcons.factory),
      DabGroupOption(id: 'status', label: 'Status', icon: shad.LucideIcons.circleDot),
    ],
    taskQueues: const ['All', 'Promote Pending', 'Sample Review'],
    reportLenses: const ['By Vendor', 'By Origin', 'Conversion Rate'],
    addFormFields: const [
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Source Code (e.g. AAIS-402) *'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Origin Mode (MILL_PROGRAM / FINISH_PURCHASE)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Vendor / Mill (sb_parties)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Source Design #'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Base Grey Item (sb_items)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Rate / Cost Estimate'),
      MastersFormFieldSpec(colSpan: 12, placeholder: 'Origin Specifications & Haste Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MastersBlankLinearLanding(config: _config);
  }
}
