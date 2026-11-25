/*
================================================================================
LLM CONTEXT & QUERY SPACE — MEDIA MASTER LANDING SCREEN (scr_mda_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Design Photography, Colorway Cards & Digital
     Assets (`IMMBE2627.sb_media`, navigation index `10`).
   - Renders clean blank states across Metrics, Data (`6 -> 10` columns), Tasks,
     Reports, and `[N]` Add Flow using `MastersBlankLinearLanding`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses `DyLinearLandingCanvas` (`9:3` Bento split) + `36px` DABs.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_media` currently blank; Phase 2 will configure Supabase Storage buckets,
     WhatsApp catalog compression variants, and `sb_designs` FK links.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Define storage bucket retention & thumbnail CDN pipeline in Phase 2.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../../dynamic_ai/micro/dab/dab_group_switcher.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_regions_canvas.dart';

/// Linear Landing screen for Media (`IMMBE2627.sb_media`).
class ScrMdaLanding extends StatelessWidget {
  const ScrMdaLanding({super.key});

  static const MastersBlankLandingConfig _config = MastersBlankLandingConfig(
    title: 'Media',
    moduleName: 'Media Asset',
    entityPlural: 'Assets',
    targetTable: 'IMMBE2627.sb_media',
    formIcon: shad.LucideIcons.image,
    kpis: [
      MastersKpiSpec(
        title: 'TOTAL ASSETS',
        subtitle: 'Awaiting sb_media storage setup',
        icon: shad.LucideIcons.image,
        tone: DyKpiTone.primary,
      ),
      MastersKpiSpec(
        title: 'MODEL PHOTOSHOOTS',
        subtitle: 'Studio & drape catalog renders',
        icon: shad.LucideIcons.camera,
        tone: DyKpiTone.cyan,
      ),
      MastersKpiSpec(
        title: 'LINKED TO DESIGNS',
        subtitle: 'Bound to sb_designs SKUs',
        icon: shad.LucideIcons.palette,
        tone: DyKpiTone.success,
      ),
      MastersKpiSpec(
        title: 'UNTAGGED / RAW',
        subtitle: 'Needs design or shade tag',
        icon: shad.LucideIcons.tag,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: [
      DyTableColumnSpec(key: 'assetCode', label: 'Asset ID', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'fileName', label: 'File / Title', flex: 2),
      DyTableColumnSpec(key: 'mediaType', label: 'Media Type', flex: 1),
      DyTableColumnSpec(key: 'designNo', label: 'Design #', flex: 1),
      DyTableColumnSpec(key: 'shade', label: 'Shade / Set', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: [
      DyTableColumnSpec(key: 'assetCode', label: 'Asset ID', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'fileName', label: 'File Name', flex: 2),
      DyTableColumnSpec(key: 'mediaType', label: 'Type', flex: 1),
      DyTableColumnSpec(key: 'designNo', label: 'Design #', flex: 1),
      DyTableColumnSpec(key: 'itemName', label: 'Base Item', flex: 1),
      DyTableColumnSpec(key: 'shade', label: 'Shade / Variant', flex: 1),
      DyTableColumnSpec(key: 'resolution', label: 'Dimensions', flex: 1),
      DyTableColumnSpec(key: 'fileSize', label: 'Size MB', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'sharedCount', label: 'CRM Shares', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Asset Type',
    partyFilterIcon: shad.LucideIcons.image,
    partyOptions: ['Studio Model', 'Flat Lay', 'Shade Card', 'Reel Video', 'Grey Macro'],
    millFilterLabel: 'Channel',
    millFilterIcon: shad.LucideIcons.share2,
    millOptions: ['WhatsApp Catalog', 'PDF Rate Card', 'Website Feed'],
    fabricFilterLabel: 'Linkage',
    fabricFilterIcon: shad.LucideIcons.link,
    fabricOptions: ['Linked to Design', 'Orphaned'],
    statusOptions: ['Published', 'Staging', 'Archived'],
    groupOptions: [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'type', label: 'Type', icon: shad.LucideIcons.image),
      DabGroupOption(id: 'design', label: 'Design', icon: shad.LucideIcons.palette),
      DabGroupOption(id: 'status', label: 'Status', icon: shad.LucideIcons.circleDot),
    ],
    taskQueues: ['All', 'Untagged', 'Compress Queue'],
    reportLenses: ['By Type', 'Design Coverage', 'Storage Footprint'],
    addFormFields: [
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Asset Title / File Ref *'),
      MastersFormFieldSpec(colSpan: 6, placeholder: 'Media Category (Model / Shade Card / Video)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Linked Design # (sb_designs)'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Colorway / Shade Tag'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Storage Bucket Path / URL'),
      MastersFormFieldSpec(colSpan: 12, placeholder: 'Shoot & Watermark Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MastersBlankLinearLanding(config: _config);
  }
}
