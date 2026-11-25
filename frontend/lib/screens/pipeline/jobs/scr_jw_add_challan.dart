/*
================================================================================
LLM CONTEXT & QUERY SPACE — JOB WORK ADD CHALLAN WORKSPACE (scr_jw_add_challan.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Dedicated `[N]` Add Flow screen body for creating Job Work Dispatches & Receipts
     (`O5–O12`) inside `DyLinearLandingCanvas` via `DyShlAdd`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Splits workspace into Flex 7 line-item table (`DyTable`), Flex 3 header form
     (`DyFormSection`), and fixed bottom totals summary strip (`112px`).
   - Uses native `shadcn_flutter` controls (`shad.TextField`, `MicroButton`,
     `shad.SecondaryBadge`, `shad.OutlinedContainer`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `IMMBE2627.sq_BILLS` and `sq_BILLDET` are read-only Airbyte mirrors; final persistence
     connects via Supabase Edge Function on Confirm.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Hook Confirm payload directly to `supabase.functions.invoke('jw_create_challan', ...)`
     once the write Edge Function is deployed.
================================================================================
*/

library;

import 'package:flutter/material.dart' hide Card, Tab, Badge, Divider;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/micro/dy_micro_button.dart';
import '../../../dynamic_ai/page/dy_action_bar.dart';
import '../../../dynamic_ai/page/dy_form_section.dart';
import '../../../dynamic_ai/page/dy_table.dart';
import '../../../dynamic_ai/shells/dy_form_canvas.dart';
import '../../../models/pipeline/mdl_jw.dart';
import 'scr_jw_analytics.dart';

/// `[N]` Add Flow Workspace for creating a Job Work Challan using `DyShlAdd`.
class JwAddChallanView extends StatefulWidget {
  final JwCategory initialCategory;
  final List<String> partyOptions;
  final List<String> qualityOptions;
  final VoidCallback onCancel;

  const JwAddChallanView({
    super.key,
    required this.initialCategory,
    required this.partyOptions,
    required this.qualityOptions,
    required this.onCancel,
  });

  @override
  State<JwAddChallanView> createState() => _JwAddChallanViewState();
}

class _JwAddChallanViewState extends State<JwAddChallanView> {
  final TextEditingController _challanNoCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  late String _selectedParty;
  late String _selectedQuality;
  final List<({String quality, int pcs, double mtrs, double rate})> _lines = [
    (quality: 'Sample Saree Lot #1', pcs: 120, mtrs: 660.0, rate: 45.0),
  ];

  @override
  void initState() {
    super.initState();
    _selectedParty = widget.partyOptions.isNotEmpty
        ? widget.partyOptions.first
        : 'Select Karigar';
    _selectedQuality = widget.qualityOptions.isNotEmpty
        ? widget.qualityOptions.first
        : 'Standard Fabric';
  }

  @override
  void dispose() {
    _challanNoCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _addLine() {
    setState(() {
      _lines.add((
        quality: _selectedQuality,
        pcs: 60,
        mtrs: 330.0,
        rate: 45.0,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;

    final int totalPcs = _lines.fold(0, (s, l) => s + l.pcs);
    final double totalMtrs = _lines.fold(0.0, (s, l) => s + l.mtrs);
    final double totalAmt = _lines.fold(0.0, (s, l) => s + (l.pcs * l.rate));

    final tableRows = _lines.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final line = entry.value;
      final lineAmt = line.pcs * line.rate;
      return DyTableRowData(
        id: 'new_line_$idx',
        rowType: DyTableRowType.def,
        voucherNo: '#$idx',
        partyName: line.quality,
        data: {
          'sr': '#$idx',
          'quality': line.quality,
          'pcs': '${line.pcs}',
          'mtrs': line.mtrs.toStringAsFixed(1),
          'rate': '₹${line.rate.toStringAsFixed(2)}',
          'amount': '₹${lineAmt.toStringAsFixed(2)}',
        },
      );
    }).toList();

    return DyShlAdd(
      leftFlex: 7,
      rightFlex: 3,
      summaryHeight: 112.0,
      actionBar: DynamicActionBar(
        mode: DabMode.form,
        entityName: 'Challan Lines',
        supportedViewModes: const [],
        showFilterButtons: false,
        showSearch: false,
        autoCompleteWidget: MicroButton(
          leadingIcon: shad.LucideIcons.plus,
          label: 'Add Line Item',
          isSelected: true,
          onPressed: _addLine,
        ),
      ),
      tableWorkspace: DyTable(
        columns: const [
          DyTableColumnSpec(key: 'sr', label: 'SR', width: 70),
          DyTableColumnSpec(key: 'quality', label: 'FABRIC QUALITY', flex: 3),
          DyTableColumnSpec(
            key: 'pcs',
            label: 'PCS',
            isNumeric: true,
            textAlignment: Alignment.centerRight,
          ),
          DyTableColumnSpec(
            key: 'mtrs',
            label: 'MTRS',
            isNumeric: true,
            textAlignment: Alignment.centerRight,
          ),
          DyTableColumnSpec(
            key: 'rate',
            label: 'RATE',
            isNumeric: true,
            textAlignment: Alignment.centerRight,
          ),
          DyTableColumnSpec(
            key: 'amount',
            label: 'AMOUNT',
            isNumeric: true,
            textAlignment: Alignment.centerRight,
          ),
        ],
        rows: tableRows,
        totalRecords: tableRows.length,
        showTrailingActions: false,
      ),
      formWorkspace: DyFormSection(
        title:
            '${widget.initialCategory.displayName} (${widget.initialCategory.seriesCode})',
        leadingIcon: shad.LucideIcons.fileText,
        fields: [
          DyFormField(
            colSpan: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Karigar / Party', style: theme.typography.xSmall),
                const shad.DensityGap(shad.gapXs),
                MicroButton(
                  leadingIcon: shad.LucideIcons.user,
                  label: _selectedParty,
                  trailingIcon: shad.LucideIcons.chevronDown,
                  onPressed: () {
                    if (widget.partyOptions.isEmpty) return;
                    final nextIdx =
                        (widget.partyOptions.indexOf(_selectedParty) + 1) %
                            widget.partyOptions.length;
                    setState(
                      () => _selectedParty = widget.partyOptions[nextIdx],
                    );
                  },
                ),
              ],
            ),
          ),
          DyFormField(
            colSpan: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fabric Quality', style: theme.typography.xSmall),
                const shad.DensityGap(shad.gapXs),
                MicroButton(
                  leadingIcon: shad.LucideIcons.shirt,
                  label: _selectedQuality,
                  trailingIcon: shad.LucideIcons.chevronDown,
                  onPressed: () {
                    if (widget.qualityOptions.isEmpty) return;
                    final nextIdx =
                        (widget.qualityOptions.indexOf(_selectedQuality) + 1) %
                            widget.qualityOptions.length;
                    setState(
                      () => _selectedQuality = widget.qualityOptions[nextIdx],
                    );
                  },
                ),
              ],
            ),
          ),
          DyFormField(
            colSpan: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Challan Ref #', style: theme.typography.xSmall),
                const shad.DensityGap(shad.gapXs),
                shad.TextField(
                  controller: _challanNoCtrl,
                  placeholder: const Text('Auto / Ref'),
                ),
              ],
            ),
          ),
          DyFormField(
            colSpan: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Series Code', style: theme.typography.xSmall),
                const shad.DensityGap(shad.gapXs),
                shad.SecondaryBadge(
                  child: Text(widget.initialCategory.seriesCode),
                ),
              ],
            ),
          ),
          DyFormField(
            colSpan: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remarks / Lot Note', style: theme.typography.xSmall),
                const shad.DensityGap(shad.gapXs),
                shad.TextField(
                  controller: _remarksCtrl,
                  placeholder:
                      const Text('Stitching instructions / design notes'),
                ),
              ],
            ),
          ),
        ],
      ),
      summaryBar: shad.OutlinedContainer(
        borderColor: colors.border,
        backgroundColor: colors.card,
        borderRadius: theme.borderRadiusLg,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scaling,
          vertical: 12 * scaling,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Airbyte sq_BILLS is strictly read-only — posting connects via Supabase Edge Function on Confirm.',
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            const shad.DensityGap(shad.gapLg),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalPcs Pcs  •  ${totalMtrs.toStringAsFixed(1)} Mtr',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                ),
                Text(
                  JwAnalyticsSnapshot.formatCompactInr(totalAmt),
                  style: theme.typography.h3.copyWith(
                    fontFamily: theme.typography.mono.fontFamily,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
