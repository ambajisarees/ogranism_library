/*
================================================================================
LLM CONTEXT & QUERY SPACE — STRATEGY PIPELINE LANDING SCREEN (scr_str_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Production Planning & Procurement Strategy
     (`IMMBE2627.sb_strategy`, navigation index `104`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states
     prior to Phase 2 backend integration.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly adheres to `DyModuleBlankLanding` (`6 -> 10` column expansion,
     `Shift+1..4` zoom, `Shift+P/X/N/Backspace`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_strategy` staged cleanly; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Connect reorder velocity from `sq_BILLS` and open grey cover into Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Strategy (`IMMBE2627.sb_strategy`).
class ScrStrLanding extends StatelessWidget {
  const ScrStrLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Strategy',
    moduleName: 'Plan',
    entityPlural: 'Plans',
    targetTable: 'IMMBE2627.sb_strategy',
    formIcon: shad.LucideIcons.cpu,
    kpis: [
      DyRegionKpiSpec(
        title: 'ACTIVE SEASON PLANS',
        subtitle: 'Awaiting sb_strategy schema',
        icon: shad.LucideIcons.cpu,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'GREY COVER DAYS',
        subtitle: 'Mill allocation buffer',
        icon: shad.LucideIcons.layers,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'TARGET OUTPUT',
        subtitle: 'Monthly saree dispatch quota',
        icon: shad.LucideIcons.target,
        tone: DyKpiTone.success,
      ),
      DyRegionKpiSpec(
        title: 'CAPACITY ALERTS',
        subtitle: 'Mill / karigar bottlenecks',
        icon: shad.LucideIcons.triangleAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'planId', label: 'Plan #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'season', label: 'Season / Window', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Target Quality', flex: 2),
      DyTableColumnSpec(key: 'targetQty', label: 'Target Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'cover', label: 'Grey Cover', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'planId', label: 'Plan #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'season', label: 'Season / Window', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Target Quality', flex: 2),
      DyTableColumnSpec(key: 'zone', label: 'Market Zone', flex: 1),
      DyTableColumnSpec(key: 'mill', label: 'Primary Mill', flex: 2),
      DyTableColumnSpec(key: 'targetQty', label: 'Target Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'committed', label: 'WIP Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'cover', label: 'Cover %', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'sla', label: 'Horizon', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Season',
    partyFilterIcon: shad.LucideIcons.calendar,
    partyOptions: ['Festive Q3', 'Wedding Q4', 'Summer Cotton', 'Regular Staple'],
    millFilterLabel: 'Mill Allocation',
    millFilterIcon: shad.LucideIcons.factory,
    millOptions: ['Suryansh Mill', 'Mahadev Dyeing', 'Vardhman Prints'],
    statusOptions: ['On Track', 'At Risk', 'Draft'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'season', label: 'Season', icon: shad.LucideIcons.calendar),
      DabGroupOption(id: 'quality', label: 'Quality', icon: shad.LucideIcons.shirt),
    ],
    taskQueues: ['All', 'Bottlenecks', 'Approvals'],
    reportLenses: ['By Season', 'Mill Utilization', 'Variance'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Plan Code (e.g. STR-2627-Q3)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Target Fabric Quality (sb_items)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Sales Territory Focus'),
      DyModuleFormFieldSpec(colSpan: 6, placeholder: 'Planned Grey Meters / Target Pcs'),
      DyModuleFormFieldSpec(colSpan: 6, placeholder: 'Primary Mill & Process Allocation'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Procurement & Seasonal Strategy Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
