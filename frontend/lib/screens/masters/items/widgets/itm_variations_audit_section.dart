/*
================================================================================
LLM CONTEXT & QUERY SPACE — ITEM SPECS, VARIATIONS & AUDIT SECTION
================================================================================
1. DOMAIN & PURPOSE:
   - Right-column sub-widget for `DiaItmAddEdit` (`dia_itm_add_edit.dart`).
   - Renders Section 4 (`domain_specs` driven by `SbItemGroupConfig.specSchema`),
     Section 5 (`variations` JSONB list with inline add/remove), and Section 6
     (`sb_item_audit_log` revision comment & recent history).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` components (`shad.OutlinedContainer`,
     `shad.TextField`, `shad.PrimaryButton`, `shad.OutlineButton`, `shad.Checkbox`,
     `shad.SecondaryBadge`, `shad.DensityGap`) and theme tokens.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Extracted from `dia_itm_add_edit.dart` to keep all module files strictly
     under 1,000 lines per Master AI Developer Rules.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None currently.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../models/masters/items/mdl_sb_item.dart';

/// [ItmVariationsAuditSection] — Renders Sections 4 (Dynamic Barrel Specs),
/// 5 (Item Variations), and 6 (Audit Trail & Revision Comment).
class ItmVariationsAuditSection extends StatelessWidget {
  final MdlSbItem draft;
  final SbItemGroupConfig? activeGroupConfig;
  final TextEditingController newVarNameCtrl;
  final TextEditingController newVarSpecCtrl;
  final TextEditingController newVarCostCtrl;
  final TextEditingController reasonCtrl;
  final List<MdlSbItemAuditLog> auditHistory;
  final ValueChanged<Map<String, dynamic>> onDomainSpecsChanged;
  final VoidCallback onAddInlineVariation;
  final ValueChanged<int> onRemoveVariationAt;

  const ItmVariationsAuditSection({
    super.key,
    required this.draft,
    required this.activeGroupConfig,
    required this.newVarNameCtrl,
    required this.newVarSpecCtrl,
    required this.newVarCostCtrl,
    required this.reasonCtrl,
    required this.auditHistory,
    required this.onDomainSpecsChanged,
    required this.onAddInlineVariation,
    required this.onRemoveVariationAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDynamicSpecsCard(theme, colors),
        const shad.DensityGap(0.75),
        _buildVariationsCard(theme, colors),
        const shad.DensityGap(0.75),
        _buildAuditReasonCard(theme, colors),
      ],
    );
  }

  Widget _buildDynamicSpecsCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.75;
    final cfg = activeGroupConfig;
    final schema = cfg?.specSchema ?? const [];

    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                shad.LucideIcons.slidersHorizontal,
                size: 15 * theme.scaling,
                color: colors.primary,
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: Text(
                  '4. Admin-Defined Barrel Specs (${cfg?.displayName ?? draft.itemGroup})',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.6),
          if (schema.isEmpty)
            Text(
              'No extra domain_specs required for this barrel.',
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
              ),
            )
          else
            ...schema.map((field) {
              final currentVal =
                  draft.domainSpecs[field.key] ?? field.defaultValue ?? '';
              return Padding(
                padding: EdgeInsets.only(bottom: 8 * theme.scaling),
                child: _buildDynamicSpecField(theme, colors, field, currentVal),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDynamicSpecField(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    SbSpecFieldDef field,
    dynamic currentVal,
  ) {
    void updateSpec(dynamic newVal) {
      final updated = Map<String, dynamic>.from(draft.domainSpecs);
      updated[field.key] = newVal;
      onDomainSpecsChanged(updated);
    }

    if (field.type == 'select' && field.options.isNotEmpty) {
      return _buildLabeledField(
        theme,
        colors,
        label: '${field.label}${field.required ? " *" : ""}',
        child: Wrap(
          spacing: 5 * theme.scaling,
          runSpacing: 5 * theme.scaling,
          children: field.options.map((opt) {
            final bool isSel = currentVal.toString() == opt;
            return isSel
                ? shad.PrimaryButton(
                    size: shad.ButtonSize.small,
                    onPressed: () {},
                    child: Text(opt),
                  )
                : shad.OutlineButton(
                    size: shad.ButtonSize.small,
                    onPressed: () => updateSpec(opt),
                    child: Text(opt),
                  );
          }).toList(),
        ),
      );
    }

    if (field.type == 'boolean') {
      final bool boolVal = currentVal == true || currentVal.toString() == 'true';
      return shad.Checkbox(
        state: boolVal
            ? shad.CheckboxState.checked
            : shad.CheckboxState.unchecked,
        onChanged: (st) => updateSpec(st == shad.CheckboxState.checked),
        trailing: Text(
          field.label,
          style: theme.typography.xSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return _buildLabeledField(
      theme,
      colors,
      label: '${field.label}${field.required ? " *" : ""}',
      child: shad.TextField(
        initialValue: currentVal.toString(),
        placeholder: Text('Enter ${field.label}...'),
        onChanged: (val) {
          if (field.type == 'number') {
            updateSpec(double.tryParse(val.trim()) ?? val.trim());
          } else {
            updateSpec(val.trim());
          }
        },
      ),
    );
  }

  Widget _buildVariationsCard(shad.ThemeData theme, shad.ColorScheme colors) {
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.75;
    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                shad.LucideIcons.gitBranch,
                size: 15 * theme.scaling,
                color: colors.primary,
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: Text(
                  '5. Item Variations (Dimensions / Ply / Microns / Specs)',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
              ),
              shad.SecondaryBadge(
                child: Text('${draft.variations.length} Variations'),
              ),
            ],
          ),
          const shad.DensityGap(0.5),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: shad.TextField(
                  controller: newVarNameCtrl,
                  placeholder: const Text('Variation (e.g. 35.25*15*30 7 PLY)'),
                ),
              ),
              const shad.DensityGap(0.35),
              Expanded(
                flex: 3,
                child: shad.TextField(
                  controller: newVarSpecCtrl,
                  placeholder: const Text('Spec / Microns'),
                ),
              ),
              const shad.DensityGap(0.35),
              Expanded(
                flex: 2,
                child: shad.TextField(
                  controller: newVarCostCtrl,
                  placeholder: const Text('Rate ₹'),
                ),
              ),
              const shad.DensityGap(0.35),
              shad.PrimaryButton(
                size: shad.ButtonSize.small,
                onPressed: onAddInlineVariation,
                child: const Icon(shad.LucideIcons.plus, size: 14),
              ),
            ],
          ),
          if (draft.variations.isNotEmpty) ...[
            const shad.DensityGap(0.5),
            SizedBox(
              height: 135 * theme.scaling,
              child: ListView.separated(
                itemCount: draft.variations.length,
                separatorBuilder: (ctx, idx) => const shad.DensityGap(0.25),
                itemBuilder: (ctx, i) {
                  final v = draft.variations[i];
                  return shad.OutlinedContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * theme.scaling,
                      vertical: 5 * theme.scaling,
                    ),
                    backgroundColor: colors.background,
                    borderColor: colors.border,
                    borderRadius: theme.borderRadiusSm,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            v.name,
                            style: theme.typography.xSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ),
                        if (v.specs.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(right: 8 * theme.scaling),
                            child: Text(
                              v.specs.values.join(' • '),
                              style: theme.typography.xSmall.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ),
                        Text(
                          '₹${v.costPrice.toStringAsFixed(2)}',
                          style: theme.typography.xSmall.copyWith(
                            fontFamily: 'JetBrains Mono',
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                        const shad.DensityGap(0.4),
                        shad.GhostButton(
                          density: shad.ButtonDensity.icon,
                          onPressed: () => onRemoveVariationAt(i),
                          child: const Icon(shad.LucideIcons.trash2, size: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditReasonCard(shad.ThemeData theme, shad.ColorScheme colors) {
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.75;
    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '6. Audit Trail & Revision Comment (sb_item_audit_log)',
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
          const shad.DensityGap(0.5),
          shad.TextField(
            controller: reasonCtrl,
            placeholder: const Text(
              'Reason for onboarding or price/spec revision (e.g. Added 7-Ply carton variations & locked HSN)...',
            ),
          ),
          if (auditHistory.isNotEmpty) ...[
            const shad.DensityGap(0.5),
            Text(
              'Recent Revision Logs (${auditHistory.length}):',
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const shad.DensityGap(0.25),
            ...auditHistory.take(3).map((log) {
              return Padding(
                padding: EdgeInsets.only(bottom: 3 * theme.scaling),
                child: Text(
                  '• [${log.changeType}] ${log.fieldName}: ${log.oldValue ?? "-"} → ${log.newValue} (${log.reasonComment})',
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    fontFamily: 'JetBrains Mono',
                    color: colors.mutedForeground,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildLabeledField(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.typography.xSmall.copyWith(
            color: colors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const shad.DensityGap(0.25),
        child,
      ],
    );
  }
}
