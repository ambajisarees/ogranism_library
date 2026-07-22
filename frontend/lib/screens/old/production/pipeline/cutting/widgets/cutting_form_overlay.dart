import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../models/production/model_cutting.dart';
import '../../../../../organism_design/index.dart';
import 'cutting_form_state.dart';
import 'cutting_lot_group.dart';

/// [CuttingFormOverlay] — Overlay workspace for creating and editing Cutting Batches.
class CuttingFormOverlay extends StatefulWidget {
  final CuttingBatchSummaryModel? editBatch;
  final List<CuttingCardModel>? siblingCards;
  final VoidCallback onClose;
  final Function(Map<String, dynamic> savedResult) onSaved;

  const CuttingFormOverlay({
    super.key,
    required this.onClose,
    required this.onSaved,
    this.editBatch,
    this.siblingCards,
  });

  @override
  State<CuttingFormOverlay> createState() => _CuttingFormOverlayState();
}

class _CuttingFormOverlayState extends State<CuttingFormOverlay> {
  late final CuttingFormState _state;

  @override
  void initState() {
    super.initState();
    _state = CuttingFormState();
    _state.initialize(
      editBatch: widget.editBatch,
      siblingCards: widget.siblingCards,
    );
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CuttingFormStateProvider(
      notifier: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          final colors = OrganismTheme.colorsOf(context);
          final rollCount = _state.rollCount;

          return OrganThreePaneCanvas(
            title: widget.editBatch != null 
                ? 'Edit Batch CC-${widget.editBatch!.multiVno.toString().padLeft(4, '0')}'
                : 'Create a new Batch',
            onClose: widget.onClose,

            // ── Header Actions (Button Bar) ─────────────────────────────
            trailingAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CellButton(
                  text: 'Cancel',
                  icon: LucideIcons.x,
                  variant: CellButtonVariant.outline,
                  onPressed: _state.isSaving ? null : widget.onClose,
                ),
                const SizedBox(width: OrganismTheme.spacingSm),
                CellButton(
                  text: 'Confirm',
                  icon: LucideIcons.check,
                  variant: CellButtonVariant.primary,
                  isLoading: _state.isSaving,
                  onPressed: (rollCount > 0 && !_state.isSaving)
                      ? () async {
                          final result = await _state.saveBatch(context);
                          if (result != null) {
                            widget.onSaved(result);
                          }
                        }
                      : null,
                ),
              ],
            ),

            // ── LEFT PANE: FIFO Millrec Cards (Expanded) ──────────────────
            leftPane: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    border: Border(bottom: BorderSide(color: colors.border)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'LOT SELECTION',
                        style: OrganismTheme.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.textPrimary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      // Row 1: Select Quality autocomplete fully inline
                      Row(
                        children: [
                          Text(
                            'Select Quality',
                            style: OrganismTheme.bodySmall(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CellAutocomplete<String>(
                              isCompact: false,
                              placeholder: 'Search Quality...',
                              items: _state.qualities,
                              isMultiSelect: true,
                              selectedValues: _state.selectedQualities,
                              onSelectedValuesChanged: (qList) => _state.onQualitiesChanged(qList),
                              labelBuilder: (v) => v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OrganismTheme.spacingSm),
                      // Row 2: Select Mill, search, and Group By toggle buttons
                      Row(
                        children: [
                          Text(
                            'Select Mill',
                            style: OrganismTheme.bodySmall(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: CellAutocomplete<String>(
                              isCompact: false,
                              placeholder: _state.selectedQualities.isEmpty
                                  ? 'Select quality first'
                                  : 'Search Mill...',
                              items: _state.mills,
                              value: _state.selectedMill,
                              onChanged: (v) => _state.onMillChanged(v),
                              labelBuilder: (v) => v,
                            ),
                          ),
                          const SizedBox(width: OrganismTheme.spacingSm),
                          const Expanded(
                            flex: 2,
                            child: CellInput(
                              placeholder: 'Search lots...',
                              prefixIcon: LucideIcons.search,
                            ),
                          ),
                          const SizedBox(width: OrganismTheme.spacingSm),
                          CellToggleGroup<String>(
                            value: _state.groupBy,
                            items: const ['NONE', 'DATE', 'DESNO'],
                            itemBuilder: (v) {
                              IconData icon;
                              if (v == 'DATE') {
                                icon = LucideIcons.calendar;
                              } else if (v == 'DESNO') {
                                icon = LucideIcons.palette;
                              } else {
                                icon = LucideIcons.ban;
                              }
                              return Icon(icon, size: 16);
                            },
                            onChanged: (v) {
                              _state.updateGroupBy(v);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Card List / Groups
                Expanded(
                  child: _state.loadingAvailable
                      ? const Center(child: CircularProgressIndicator())
                      : _state.selectedQualities.isEmpty || _state.selectedMill == null
                          ? TissueEmptyState(
                              icon: LucideIcons.search,
                              title: 'Pending Selection',
                              message: 'Select Quality then Mill above to load available lots.',
                            )
                          : _state.availableTakas.isEmpty
                              ? TissueEmptyState(
                                  icon: LucideIcons.checkSquare,
                                  title: 'No Pending Lots',
                                  message: 'All rolls for selected Quality + Mill are cut.',
                                )
                              : const CuttingGroupedLotCards(),
                ),
              ],
            ),

            // ── CENTER PANE: Batch Spec Form (Fixed 340) ──────────────────
            centerPane: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPaneHeader(
                  context,
                  colors,
                  title: 'Batch Specs',
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Cut Date Selector
                          TissueFormField(
                            label: 'CUT DATE',
                            inputCell: CellDatePicker(
                              isCompact: false,
                              value: _state.batchDate,
                              onChanged: (d) {
                                setState(() => _state.batchDate = d);
                              },
                            ),
                          ),
                          const SizedBox(height: OrganismTheme.spacingLg),

                          // Batch No
                          TissueFormField(
                            label: 'BATCH NO',
                            inputCell: CellInput(
                              controller: _state.startMultiVnoController,
                              isNumeric: true,
                              placeholder: 'Auto-generating...',
                            ),
                          ),
                          const SizedBox(height: OrganismTheme.spacingLg),

                          // Cut Length
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CUT LENGTH',
                                style: OrganismTheme.labelSmall(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: OrganismTheme.spacingSm),
                              Container(
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  border: Border.all(color: colors.border),
                                  borderRadius: OrganismTheme.borderSm,
                                ),
                                child: Row(
                                  children: [5.20, 5.35, 6.00, 6.25].asMap().entries.map((entry) {
                                    final v = entry.value;
                                    final isSelected = v == _state.cutLength;
                                    final isLast = entry.key == 3;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => _state.updateCutLength(v),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected ? colors.surfaceSubtle : Colors.transparent,
                                            border: Border(
                                              right: isLast ? BorderSide.none : BorderSide(color: colors.border),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              v.toStringAsFixed(2),
                                              style: OrganismTheme.bodyMedium(context).copyWith(
                                                color: colors.textPrimary,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: OrganismTheme.spacingLg),

                          // Fresh Pieces
                          TissueFormField(
                            label: 'FRESH PCS',
                            inputCell: CellInputNumber(
                              initialValue: _state.totalFreshPcs,
                              suffix: 'PCS',
                              onChanged: (v) {
                                _state.freshPcsController.text = (v ?? 0).toInt().toString();
                              },
                            ),
                          ),
                          const SizedBox(height: OrganismTheme.spacingLg),

                          // Second Pieces
                          TissueFormField(
                            label: 'SECOND PCS',
                            inputCell: CellInputNumber(
                              initialValue: _state.totalSecondPcs,
                              suffix: 'PCS',
                              onChanged: (v) {
                                _state.secondPcsController.text = (v ?? 0).toInt().toString();
                              },
                            ),
                          ),
                          const SizedBox(height: OrganismTheme.spacingLg),

                          // Saree Weight
                          TissueFormField(
                            label: 'SAREE WEIGHT',
                            inputCell: CellInputNumber(
                              initialValue: _state.avgWtGrams,
                              suffix: 'grams',
                              onChanged: (v) {
                                _state.sareeWtController.text = (v ?? 400).toInt().toString();
                              },
                            ),
                          ),
                          const SizedBox(height: OrganismTheme.spacingLg),

                          // Fent Weight
                          TissueFormField(
                            label: 'FENT WEIGHT',
                            inputCell: CellInputNumber(
                              initialValue: _state.totalFentWt,
                              suffix: 'grams',
                              onChanged: (v) {
                                _state.fentWtController.text = (v ?? 0.0).toStringAsFixed(2);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── RIGHT PANE: Live Performance (Fixed 300) ──────────────────
            rightPane: Container(
              color: colors.surfaceSubtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPaneHeader(
                    context,
                    colors,
                    title: 'Live Performance',
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Total input meters hero
                          Container(
                            padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(OrganismTheme.radiusMd),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL RECEIVED METERS',
                                  style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_state.totalReceivedMts.toStringAsFixed(1)} Mts',
                                  style: OrganismTheme.titleLarge(context).copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Mono',
                                    fontSize: 28,
                                    color: _state.totalReceivedMts > 0 ? colors.primary : colors.textMuted,
                                  ),
                                ),
                                if (_state.selectedMill != null && _state.selectedQualities.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '$rollCount rolls · ${_state.selectedQualities.join(', ')}',
                                    style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: OrganismTheme.spacingLg),

                          _buildProgressBarRow(
                            context,
                            colors,
                            label: 'Shortage (Rec/Input)',
                            percentage: _state.shortagePct,
                            color: colors.textMuted,
                            subtitle: '${_state.totalReceivedMts.toStringAsFixed(1)} / ${_state.totalInputMts.toStringAsFixed(1)} Mts',
                          ),
                          _buildProgressBarRow(
                            context,
                            colors,
                            label: 'Fresh Recovery',
                            percentage: _state.freshPct,
                            color: colors.primary,
                            subtitle: '${_state.calculatedFreshMts.toStringAsFixed(1)} / ${_state.totalReceivedMts.toStringAsFixed(1)} Mts',
                          ),
                          _buildProgressBarRow(
                            context,
                            colors,
                            label: 'Seconds (Cut of 5)',
                            percentage: _state.secondPct,
                            color: colors.warning,
                            subtitle: '${_state.calculatedSecondMts.toStringAsFixed(1)} / ${_state.totalReceivedMts.toStringAsFixed(1)} Mts',
                          ),
                          _buildProgressBarRow(
                            context,
                            colors,
                            label: 'Fents (By Weight)',
                            percentage: _state.fentPct,
                            color: colors.error,
                            subtitle: '${_state.calculatedFentMts.toStringAsFixed(1)} / ${_state.totalReceivedMts.toStringAsFixed(1)} Mts',
                          ),

                          if (rollCount == 0) ...[
                            const SizedBox(height: OrganismTheme.spacingMd),
                            Container(
                              padding: const EdgeInsets.all(OrganismTheme.spacingSm),
                              decoration: BoxDecoration(
                                color: colors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(OrganismTheme.radiusSm),
                                border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.triangleAlert, size: 14, color: colors.warning),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Select takas to begin',
                                      style: OrganismTheme.bodySmall(context).copyWith(color: colors.warning),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaneHeader(
    BuildContext context,
    OrganismColors colors, {
    required String title,
    Widget? trailing,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: OrganismTheme.spacingMd,
        vertical: OrganismTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: OrganismTheme.bodySmall(context).copyWith(
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              letterSpacing: 1.1,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildProgressBarRow(
    BuildContext context,
    OrganismColors colors, {
    required String label,
    required double percentage,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: OrganismTheme.labelSmall(context).copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: OrganismTheme.bodySmall(context).copyWith(
                        color: colors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: OrganismTheme.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Mono',
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        CellProgressBar(
          value: percentage / 100.0,
          color: color,
        ),
        const SizedBox(height: OrganismTheme.spacingMd),
      ],
    );
  }
}
