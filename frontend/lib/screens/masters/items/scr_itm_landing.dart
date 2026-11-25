/*
================================================================================
LLM CONTEXT & QUERY SPACE — ITEMS MASTER LANDING SCREEN (scr_itm_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Linear Landing workspace for Item / Fabric Quality Masters
     (`IMMBE2627.sb_items`, navigation index `2`).
   - Renders clean blank states across Metrics, Data (`6 -> 10` columns), Tasks,
     Reports, and `[N]` Add Flow while decoupling gradually from legacy `sq_QUAL`.
   - Keeps both `showItmAddEditDialog` (`dia_itm_add_edit.dart`) and
     `showAdminItemConfigModal` (`scr_admin_item_config.dart`) accessible under
     a `Legacy` dropdown button in the `PageHeader`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses `DyLinearLandingCanvas` (`9:3` Bento split) + `36px` DABs.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Old page queried `sq_QUAL` (1,016 legacy rows); migration to `sb_items` will
     run in Phase 2/3. All `dia_itm_add_edit.dart` & `widgets/` stay preserved.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Finalize item group barrels (`Finished Saree`, `Grey Fabric`, `Packing`) in Phase 2.
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
import 'dia_itm_add_edit.dart';
import 'scr_admin_item_config.dart';

/// Linear Landing screen for Items (`IMMBE2627.sb_items`).
class ScrItmLanding extends StatelessWidget {
  const ScrItmLanding({super.key});

  static final MastersBlankLandingConfig _config = MastersBlankLandingConfig(
    title: 'Items',
    moduleName: 'Item',
    entityPlural: 'Items',
    targetTable: 'IMMBE2627.sb_items',
    formIcon: shad.LucideIcons.package,
    headerExtraActionsBuilder: (context) => [
      Builder(
        builder: (btnCtx) => PageHeaderActionButton(
          label: 'Legacy',
          icon: shad.LucideIcons.history,
          onPressed: () {
            shad.showDropdown<void>(
              context: btnCtx,
              anchorAlignment: Alignment.bottomRight,
              alignment: Alignment.topRight,
              builder: (_) => shad.DropdownMenu(
                children: [
                  const shad.MenuLabel(child: Text('Legacy Item Tools')),
                  const shad.MenuDivider(),
                  shad.MenuButton(
                    leading: const Icon(shad.LucideIcons.sparkles),
                    onPressed: (_) => showItmAddEditDialog(context),
                    child: const Text('Add / Upgrade Item (sq_QUAL)'),
                  ),
                  shad.MenuButton(
                    leading: const Icon(shad.LucideIcons.slidersHorizontal),
                    onPressed: (_) => showAdminItemConfigModal(context),
                    child: const Text('Admin Barrel Config'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
    kpis: const [
      MastersKpiSpec(
        title: 'TOTAL ITEMS',
        subtitle: 'Awaiting sq_QUAL -> sb_items migration',
        icon: shad.LucideIcons.package,
        tone: DyKpiTone.primary,
      ),
      MastersKpiSpec(
        title: 'GREY FABRICS',
        subtitle: 'Raw weaving & width qualities',
        icon: shad.LucideIcons.layers,
        tone: DyKpiTone.cyan,
      ),
      MastersKpiSpec(
        title: 'FINISHED BASES',
        subtitle: 'Commercial base saree cloths',
        icon: shad.LucideIcons.shirt,
        tone: DyKpiTone.success,
      ),
      MastersKpiSpec(
        title: 'SPECS INCOMPLETE',
        subtitle: 'GSM / HSN / UOM pending',
        icon: shad.LucideIcons.triangleAlert,
        tone: DyKpiTone.warning,
      ),
    ],
    collapsedColumns: const [
      DyTableColumnSpec(key: 'code', label: 'Item Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Quality Name', flex: 2),
      DyTableColumnSpec(key: 'group', label: 'Item Barrel', flex: 1),
      DyTableColumnSpec(key: 'uom', label: 'UOM', flex: 1),
      DyTableColumnSpec(key: 'hsn', label: 'HSN / Rate', flex: 1),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    expandedColumns: const [
      DyTableColumnSpec(key: 'code', label: 'Item Code', flex: 1, isPinnedLeft: true),
      DyTableColumnSpec(key: 'name', label: 'Quality Name', flex: 2),
      DyTableColumnSpec(key: 'group', label: 'Barrel / Group', flex: 1),
      DyTableColumnSpec(key: 'clothType', label: 'Cloth Type', flex: 1),
      DyTableColumnSpec(key: 'uom', label: 'UOM', flex: 1),
      DyTableColumnSpec(key: 'gsm', label: 'GSM / Width', flex: 1),
      DyTableColumnSpec(key: 'hsn', label: 'HSN Code', flex: 1),
      DyTableColumnSpec(key: 'gst', label: 'GST %', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'compScore', label: 'Comp %', flex: 1, isNumeric: true),
      DyTableColumnSpec(key: 'status', label: 'Status', flex: 1),
    ],
    partyFilterLabel: 'Barrel',
    partyFilterIcon: shad.LucideIcons.layers,
    partyOptions: ['Finished Saree', 'Grey Fabric', 'Job Packing', 'Blouse / Lace'],
    millFilterLabel: 'Cloth Type',
    millFilterIcon: shad.LucideIcons.shirt,
    millOptions: ['Silk', 'Georgette', 'Dola', 'Chiffon', 'Viscose', 'Cotton'],
    fabricFilterLabel: 'UOM',
    fabricFilterIcon: shad.LucideIcons.ruler,
    fabricOptions: ['PCS', 'MTR', 'KG'],
    statusOptions: ['Verified', 'Needs Migration', 'Draft'],
    groupOptions: const [
      DabGroupOption(id: 'none', label: 'None', icon: shad.LucideIcons.layoutList),
      DabGroupOption(id: 'group', label: 'Barrel', icon: shad.LucideIcons.layers),
      DabGroupOption(id: 'cloth', label: 'Cloth', icon: shad.LucideIcons.shirt),
      DabGroupOption(id: 'uom', label: 'UOM', icon: shad.LucideIcons.ruler),
    ],
    taskQueues: const ['All', 'Migrate sq_QUAL', 'HSN Missing'],
    reportLenses: const ['By Barrel', 'By Cloth Type', 'Comp Coverage'],
    addFormFields: const [
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Item Code / Legacy QUAL_CODE'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Quality Display Name *'),
      MastersFormFieldSpec(colSpan: 4, placeholder: 'Item Barrel (Finished / Grey / Packing)'),
      MastersFormFieldSpec(colSpan: 3, placeholder: 'Base UOM (PCS / MTR)'),
      MastersFormFieldSpec(colSpan: 3, placeholder: 'HSN Code (e.g. 5407)'),
      MastersFormFieldSpec(colSpan: 3, placeholder: 'GST Slab % (e.g. 5%)'),
      MastersFormFieldSpec(colSpan: 3, placeholder: 'Std GSM / Width Panna'),
      MastersFormFieldSpec(colSpan: 12, placeholder: 'Yarn / Spec Notes'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MastersBlankLinearLanding(config: _config);
  }
}
