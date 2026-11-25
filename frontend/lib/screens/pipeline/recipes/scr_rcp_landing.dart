/*
================================================================================
LLM CONTEXT & QUERY SPACE — RECIPES PIPELINE LANDING SCREEN (scr_rcp_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Dyeing, Printing & Finishing Recipes
     (`IMMBE2627.sb_recipes`, navigation index `103`).
   - Uses `DyLandingCanvas` (`9:3` Base-12 grid) + `DyRegionsCanvas` blank states
     prior to Phase 2 backend integration.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly adheres to `DyModuleBlankLanding` (`6 -> 10` column expansion,
     `Shift+1..4` zoom, `Shift+P/X/N/Backspace`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_recipes` schema staged; zero live Supabase queries in Phase 1.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Link standard dyeing shade cards and chemical recipes to `sb_designs` in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Recipes (`IMMBE2627.sb_recipes`).
class ScrRcpLanding extends StatelessWidget {
  const ScrRcpLanding({super.key});

  static const DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Recipes',
    moduleName: 'Recipe',
    entityPlural: 'Recipes',
    targetTable: 'IMMBE2627.sb_recipes',
    formIcon: shad.LucideIcons.flaskConical,
    kpis: [
      DyRegionKpiSpec(
        title: 'TOTAL RECIPES',
        subtitle: 'Awaiting sb_recipes schema',
        icon: shad.LucideIcons.flaskConical,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'DYEING & PADDING',
        subtitle: 'Shade & solid color formulas',
        icon: shad.LucideIcons.droplets,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'DIGITAL / MILL PRINT',
        subtitle: 'Matching sets & screen masters',
        icon: shad.LucideIcons.palette,
        tone: DyKpiTone.indigo,
      ),
      DyRegionKpiSpec(
        title: 'COSTING PENDING',
        subtitle: 'Rate & shrinkage review',
        icon: shad.LucideIcons.percent,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'code', label: 'Recipe #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Recipe Name', flex: 2),
      DyTableColumnSpec(key: 'process', label: 'Process Type', flex: 1),
      DyTableColumnSpec(key: 'fabric', label: 'Base Quality', flex: 2),
      DyTableColumnSpec(key: 'shrink', label: 'Std Shrink %', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'code', label: 'Recipe #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Recipe Name', flex: 2),
      DyTableColumnSpec(key: 'process', label: 'Process Type', flex: 1),
      DyTableColumnSpec(key: 'fabric', label: 'Base Quality', flex: 2),
      DyTableColumnSpec(key: 'mill', label: 'Preferred Mill', flex: 2),
      DyTableColumnSpec(key: 'matching', label: 'Matchings', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'shrink', label: 'Shrink %', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'rate', label: 'Est. Rate', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'leadDays', label: 'SLA Days', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Process',
    partyFilterIcon: shad.LucideIcons.flaskConical,
    partyOptions: ['Dyeing', 'Digital Print', 'Mill Print', 'Discharge', 'Foil / Zari'],
    millFilterLabel: 'Base Quality',
    millFilterIcon: shad.LucideIcons.shirt,
    millOptions: ['60Gm Silk', 'Georgette', 'Dola Silk', 'Viscose'],
    fabricFilterLabel: 'Mill',
    fabricFilterIcon: shad.LucideIcons.factory,
    fabricOptions: ['Suryansh Mill', 'Vardhman Prints', 'Mahadev Dyeing'],
    statusOptions: ['Approved', 'Sampling', 'Deprecated'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'process', label: 'Process', icon: shad.LucideIcons.flaskConical),
      DabGroupOption(id: 'fabric', label: 'Quality', icon: shad.LucideIcons.shirt),
    ],
    taskQueues: ['All', 'Cost Review', 'Lab Dip Pending'],
    reportLenses: ['By Process', 'Shrinkage Variance', 'Cost Matrix'],
    addFormFields: [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Recipe Code (e.g. RCP-001)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Recipe Title *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Process (Dyeing / Digital Print / Foil)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Base Grey Quality (sb_items)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Std Shrinkage %'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Estimated Process Rate (₹/Mtr)'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Colorway Matching & Finishing Instructions'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const DyModuleBlankLanding(config: _config);
  }
}
