/*
================================================================================
LLM CONTEXT & QUERY SPACE — DESIGNS MASTER LANDING SCREEN (scr_dsn_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Commercial Saree Designs
     (`IMMBE2627.sb_designs`, navigation index `3`).
   - Keeps the legacy Commercial Design modal (`showDsnAddEditDialog(..., initialTab: 1)`)
     accessible under a `Legacy` button in `PageHeader` while rendering clean
     4-Region Bento blank states prior to Phase 2 backend expansion.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses `DyLinearLandingCanvas` (`9:3` Bento split) + `36px` DABs.
   - Replaces the legacy `DyShlDetails` 4-tab view while keeping `dia_dsn_add_edit.dart`
     preserved on disk for reference.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_designs` currently holds only 3 test entries; Phase 2/3 will enrich &
     wire `sb_designs` + `sb_sources` + `sb_media` links directly into these 4 regions.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Confirm SKU / design code numbering convention (`D-XXXX`) in Phase 2.
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
import 'dia_dsn_add_edit.dart';

/// Linear Landing screen for Designs (`IMMBE2627.sb_designs`).
class ScrDsnLanding extends StatelessWidget {
  const ScrDsnLanding({super.key});

  static final MastersBlankLandingConfig _config = MastersBlankLandingConfig(
    title: 'Designs',
    moduleName: 'Design',
    entityPlural: 'Designs',
    targetTable: 'IMMBE2627.sb_designs',
    formIcon: shad.LucideIcons.palette,
    headerExtraActionsBuilder: (context) => [
      PageHeaderActionButton(
        label: 'Legacy',
        icon: shad.LucideIcons.history,
        onPressed: () => showDsnAddEditDialog(context, initialTab: 1),
      ),
    ],
    kpis: const [
      MastersKpiSpec(
        title: 'TOTAL DESIGNS',
        subtitle: 'Awaiting Phase 2 sb_designs build',
        icon: shad.LucideIcons.palette,
        tone: DyKpiTone.primary,
      ),
      MastersKpiSpec(
        title: 'PRINTED SAREES',
        subtitle: 'Digital & mill print SKUs',
        icon: shad.LucideIcons.sparkles,
        tone: DyKpiTone.cyan,
      ),
      MastersKpiSpec(
        title: 'DYED & TOP-DYED',
        subtitle: 'Plain & jacquard dyed SKUs',
        icon: shad.LucideIcons.droplets,
        tone: DyKpiTone.indigo,
      ),
      MastersKpiSpec(
        title: 'INCOMPLETE SPECS',
        subtitle: 'Missing photo or comp_score',
        icon: shad.LucideIcons.listChecks,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'designNo', label: 'Design #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Design Name', flex: 2),
      DyTableColumnSpec(key: 'sareeType', label: 'Process Type', flex: 1),
      DyTableColumnSpec(key: 'parentItem', label: 'Parent Item', flex: 2),
      DyTableColumnSpec(key: 'sellRate', label: 'Rate ₹', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'designNo', label: 'Design #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Design Name', flex: 2),
      DyTableColumnSpec(key: 'sareeType', label: 'Type', flex: 1),
      DyTableColumnSpec(key: 'parentItem', label: 'Parent Item (sb_items)', flex: 2),
      DyTableColumnSpec(key: 'sourceCode', label: 'Active Source', flex: 1),
      DyTableColumnSpec(key: 'cut', label: 'Cut Spec', flex: 1),
      DyTableColumnSpec(key: 'sellRate', label: 'Catalog Rate', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'compScore', label: 'Comp %', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'mediaCount', label: 'Photos', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Saree Type',
    partyFilterIcon: shad.LucideIcons.sparkles,
    partyOptions: ['Printed', 'Dyed', 'Top-Dyed', 'Embroidered'],
    millFilterLabel: 'Base Item',
    millFilterIcon: shad.LucideIcons.package,
    millOptions: ['60Gm Silk', 'Georgette', 'Dola Silk', 'Chiffon', 'Organza'],
    fabricFilterLabel: 'Source',
    fabricFilterIcon: shad.LucideIcons.compass,
    fabricOptions: ['Mill Program', 'Finish Purchase'],
    statusOptions: ['Launch Ready', 'Draft', 'Discontinued'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'type', label: 'Type', icon: shad.LucideIcons.sparkles),
      DabGroupOption(id: 'item', label: 'Item', icon: shad.LucideIcons.package),
      DabGroupOption(id: 'status', label: 'Status', icon: shad.LucideIcons.circleDot),
    ],
    taskQueues: const ['All', 'Spec Pending', 'Photo Missing'],
    reportLenses: const ['By Type', 'By Base Item', 'Comp Score'],
    addFormFields: const [
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Commercial Design # (e.g. D-9042) *'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Design Title / Collection'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Saree Type (Printed / Dyed / Top-Dyed)'),
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Parent Base Item (sb_items) *'),
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Active Vendor Source (sb_sources)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Standard Cut (e.g. 5.50 + 0.80)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Catalog Selling Rate ₹'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Launch Season / Shade Count'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MastersBlankLinearLanding(config: _config);
  }
}
