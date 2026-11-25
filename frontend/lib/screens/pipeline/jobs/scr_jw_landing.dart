/*
================================================================================
LLM CONTEXT & QUERY SPACE — JOB WORK LANDING SCREEN (scr_jw_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Job Work Operations (`jw`, series `O5`–`O12`,
     navigation index `7`) standardized onto `DyLandingCanvas` (`9:3` Base-12 grid)
     + `DyRegionsCanvas`.
   - Preserves `JwAddChallanView` (`scr_jw_add_challan.dart`) under a `Legacy`
     button in `PageHeader` for immediate side-by-side reference.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Covers Stitch Desp/Recd (`O5`/`O6`), Diamond Desp/Recd (`O7`/`O8`),
     Embroidery Desp/Recd (`O9`/`O10`), and Charak Desp/Recd (`O11`/`O12`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Phase 1 renders standardized blank states; Phase 2 will rebind `SrvJw`
     live queries directly into `ScrJwRegions`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Connect `jw_create_challan` Edge Function on `ScrJwForm` confirm in Phase 2.
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
import '../../../models/pipeline/mdl_jw.dart';
import 'scr_jw_add_challan.dart';

/// Linear Landing screen for Job Work (`O5–O12`).
class ScrJwLanding extends StatelessWidget {
  const ScrJwLanding({super.key});

  static final DyModuleLandingConfig _config = DyModuleLandingConfig(
    title: 'Jobs',
    moduleName: 'Job Challan',
    entityPlural: 'Challans',
    targetTable: 'IMMBE2627.sb_job_work',
    formIcon: shad.LucideIcons.briefcase,
    headerExtraActionsBuilder: (context) => [
      PageHeaderActionButton(
        label: 'Legacy',
        icon: shad.LucideIcons.history,
        onPressed: () => showDyLegacyOverlay(
          context,
          title: 'Legacy Job Work Challan Creator (scr_jw_add_challan.dart)',
          builder: (close) => JwAddChallanView(
            initialCategory: JwCategory.stitchDesp,
            partyOptions: const ['Laxmi Karigar', 'Ambaji Stitchers', 'Ganesh Embroidery'],
            qualityOptions: const ['60Gm Silk', 'Dola Silk', 'Georgette'],
            onCancel: close,
          ),
        ),
      ),
    ],
    kpis: const [
      DyRegionKpiSpec(
        title: 'OPEN WIP CHALLANS',
        subtitle: 'O5–O12 karigar dispatches',
        icon: shad.LucideIcons.briefcase,
        tone: DyKpiTone.primary,
      ),
      DyRegionKpiSpec(
        title: 'PCS WITH KARIGARS',
        subtitle: 'Stitch • Diamond • Embroidery',
        icon: shad.LucideIcons.layers,
        tone: DyKpiTone.cyan,
      ),
      DyRegionKpiSpec(
        title: 'OVERDUE > 15 DAYS',
        subtitle: 'SLA escalation queue',
        icon: shad.LucideIcons.clockAlert,
        tone: DyKpiTone.warning,
      ),
      DyRegionKpiSpec(
        title: 'EST. JOB VALUE',
        subtitle: 'Pending labor & conversion',
        icon: shad.LucideIcons.indianRupee,
        tone: DyKpiTone.indigo,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'vno', label: 'Challan #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'series', label: 'Stage', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Karigar / Jobber', flex: 2),
      DyTableColumnSpec(key: 'pcs', label: 'Pend Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'vno', label: 'Challan #', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'date', label: 'Date', flex: 1),
      DyTableColumnSpec(key: 'series', label: 'Series', flex: 1),
      DyTableColumnSpec(key: 'party', label: 'Karigar / Jobber', flex: 2),
      DyTableColumnSpec(key: 'quality', label: 'Quality', flex: 2),
      DyTableColumnSpec(key: 'despPcs', label: 'Desp Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'recdPcs', label: 'Recd Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'pendPcs', label: 'Pend Pcs', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'rate', label: 'Rate/Pc', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Stage',
    partyFilterIcon: shad.LucideIcons.workflow,
    partyOptions: const [
      'Stitch Desp (O5)',
      'Stitch Recd (O6)',
      'Diamond Desp (O7)',
      'Diamond Recd (O8)',
      'Embroidery Desp (O9)',
      'Embroidery Recd (O10)',
      'Charak Desp (O11)',
      'Charak Recd (O12)',
    ],
    millFilterLabel: 'Karigar',
    millFilterIcon: shad.LucideIcons.users,
    statusOptions: const ['Open WIP', 'Overdue >15d', 'Settled'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'party', label: 'Karigar', icon: shad.LucideIcons.users),
      DabGroupOption(id: 'stage', label: 'Stage', icon: shad.LucideIcons.workflow),
      DabGroupOption(id: 'quality', label: 'Quality', icon: shad.LucideIcons.shirt),
    ],
    taskQueues: const ['All', 'Overdue', 'Recd Mismatch'],
    reportLenses: const ['By Stage', 'By Karigar', 'Ageing'],
    addFormFields: const [
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Job Stage (O5..O12)', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Karigar / Jobber (sb_parties) *', isRequired: true),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Fabric Quality (sb_items)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Pieces Dispatched / Received'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Job Rate per Pc (₹)'),
      DyModuleFormFieldSpec(colSpan: 4, placeholder: 'Expected Return Date'),
      DyModuleFormFieldSpec(colSpan: 12, placeholder: 'Design Lot & Work Instructions'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DyModuleBlankLanding(config: _config);
  }
}
