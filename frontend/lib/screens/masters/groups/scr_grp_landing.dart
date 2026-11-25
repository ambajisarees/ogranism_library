/*
================================================================================
LLM CONTEXT & QUERY SPACE — GROUPS MASTER LANDING SCREEN (scr_grp_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Account & Party Groups (`IMMBE2627.sb_groups`,
     navigation index `11`).
   - Renders clean blank states across Metrics, Data (`6 -> 10` columns), Tasks,
     Reports, and `[N]` Add Flow using `MastersBlankLinearLanding`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses `DyLinearLandingCanvas` (`9:3` Bento split) + `36px` DABs.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_groups` currently blank; Phase 2 will create hierarchy & FAS nature rules.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Define parent-child Schedule III / Trading-P&L nature tree in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Groups (`IMMBE2627.sb_groups`).
class ScrGrpLanding extends StatelessWidget {
  const ScrGrpLanding({super.key});

  static const MastersBlankLandingConfig _config = MastersBlankLandingConfig(
    title: 'Groups',
    moduleName: 'Group',
    entityPlural: 'Groups',
    targetTable: 'IMMBE2627.sb_groups',
    formIcon: shad.LucideIcons.folderTree,
    kpis: [
      MastersKpiSpec(
        title: 'TOTAL GROUPS',
        subtitle: 'Awaiting sb_groups schema',
        icon: shad.LucideIcons.folderTree,
        tone: DyKpiTone.primary,
      ),
      MastersKpiSpec(
        title: 'PRIMARY HEADS',
        subtitle: 'Balance sheet / P&L roots',
        icon: shad.LucideIcons.landmark,
        tone: DyKpiTone.indigo,
      ),
      MastersKpiSpec(
        title: 'SUB-GROUPS',
        subtitle: 'Trade debtors & creditors',
        icon: shad.LucideIcons.gitBranch,
        tone: DyKpiTone.cyan,
      ),
      MastersKpiSpec(
        title: 'LINKED PARTIES',
        subtitle: 'Assigned in sb_parties',
        icon: shad.LucideIcons.users,
        tone: DyKpiTone.success,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'code', label: 'Group Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Group Name', flex: 2),
      DyTableColumnSpec(key: 'parent', label: 'Parent Group', flex: 2),
      DyTableColumnSpec(key: 'nature', label: 'Nature', flex: 1),
      DyTableColumnSpec(key: 'partyCount', label: 'Parties', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'code', label: 'Group Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Group Name', flex: 2),
      DyTableColumnSpec(key: 'parent', label: 'Parent Group', flex: 2),
      DyTableColumnSpec(key: 'nature', label: 'FAS Nature', flex: 1),
      DyTableColumnSpec(key: 'schedule', label: 'Report Section', flex: 1),
      DyTableColumnSpec(key: 'affectsGross', label: 'Affects GP', flex: 1),
      DyTableColumnSpec(key: 'partyCount', label: 'Parties', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'sortOrder', label: 'Seq #', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'updatedAt', label: 'Updated', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Nature',
    partyFilterIcon: shad.LucideIcons.landmark,
    partyOptions: ['Assets', 'Liabilities', 'Income', 'Expenses'],
    millFilterLabel: 'Section',
    millFilterIcon: shad.LucideIcons.fileSpreadsheet,
    millOptions: ['Balance Sheet', 'Trading A/C', 'P&L A/C'],
    fabricFilterLabel: 'Scope',
    fabricFilterIcon: shad.LucideIcons.layers,
    fabricOptions: ['System Root', 'Custom User Group'],
    statusOptions: ['Active', 'Archived'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'nature', label: 'Nature', icon: shad.LucideIcons.landmark),
      DabGroupOption(id: 'parent', label: 'Parent', icon: shad.LucideIcons.folderTree),
    ],
    taskQueues: ['All', 'Unmapped', 'System'],
    reportLenses: ['By Nature', 'Hierarchy Tree', 'Party Spread'],
    addFormFields: [
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Group Name *'),
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Group Code / Alias'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Parent Group'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'FAS Nature (Assets / Liabilities / Income / Expense)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Report Section (Balance Sheet / Trading / P&L)'),
      MastersFormFieldSpec(colSpan: 12, placeholder: 'Classification Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const MastersBlankLinearLanding(config: _config);
  }
}
