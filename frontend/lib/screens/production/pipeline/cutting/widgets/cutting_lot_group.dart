import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../organism_design/index.dart';

import 'cutting_form_state.dart';

/// [CuttingGroupedLotCards] — Renders the list of available lot rolls grouped by Rate, Date, or Design.
class CuttingGroupedLotCards extends StatelessWidget {
  const CuttingGroupedLotCards({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CuttingFormState.of(context);
    final colors = OrganismTheme.colorsOf(context);

    // Group available takas by selected groupBy criteria
    final Map<String, List<Map<String, dynamic>>> groupedTakas = {};
    for (final card in state.availableTakas) {
      final double jobRate = (card['JOBRATE'] as num?)?.toDouble() ??
          (card['jobrate'] as num?)?.toDouble() ??
          0.0;
      final String rateStr = 'Rate: ₹${jobRate.toStringAsFixed(2)}';

      String groupName;
      if (state.groupBy == 'DATE') {
        final ddateStr = card['DDATE'] != null
            ? card['DDATE'].toString().split('T')[0]
            : 'N/A';
        groupName = '$rateStr · $ddateStr';
      } else if (state.groupBy == 'DESNO') {
        final desNo = card['SAREEDES']?.toString() ?? 'N/A';
        groupName = '$rateStr · Design #$desNo';
      } else {
        groupName = rateStr;
      }

      groupedTakas.putIfAbsent(groupName, () => []).add(card);
    }

    if (groupedTakas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: TissueEmptyState(
          icon: LucideIcons.layers,
          title: 'No Available Rolls',
          message: 'No available rolls match the selected Quality and Mill.',
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: groupedTakas.entries.map((entry) {
        final groupName = entry.key;
        final groupItems = entry.value;
        final isExpanded = state.expandedGroups[groupName] ?? true;

        // Retrieve job rate and details from first item to build group header title
        final firstItem = groupItems.first;
        final double jobRate = (firstItem['JOBRATE'] as num?)?.toDouble() ??
            (firstItem['jobrate'] as num?)?.toDouble() ??
            0.0;
        
        String groupTitle = '${groupItems.length} roll${groupItems.length == 1 ? "" : "s"} · Rate: ₹${jobRate.toStringAsFixed(2)}';
        if (state.groupBy == 'DATE') {
          final ddateStr = firstItem['DDATE'] != null
              ? firstItem['DDATE'].toString().split('T')[0]
              : 'N/A';
          groupTitle += ' · $ddateStr';
        } else if (state.groupBy == 'DESNO') {
          final desNo = firstItem['SAREEDES']?.toString() ?? 'N/A';
          groupTitle += ' · Design #$desNo';
        }

        final allSelected = groupItems.isNotEmpty &&
            groupItems.every((item) =>
                state.selectedTakaRows.any((sel) => sel['CARDNO'] == item['CARDNO']));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: OrganismTheme.spacingMd,
                vertical: OrganismTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                border: Border(
                  top: BorderSide(color: colors.border),
                  bottom: BorderSide(color: colors.border),
                ),
              ),
              child: Row(
                children: [
                  CellCheckbox(
                    value: allSelected,
                    onChanged: (val) {
                      state.selectTakaGroup(groupItems, val);
                    },
                  ),
                  const SizedBox(width: OrganismTheme.spacingSm),
                  Expanded(
                    child: Text(
                      groupTitle,
                      style: OrganismTheme.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isExpanded
                          ? LucideIcons.chevronDown
                          : LucideIcons.chevronRight,
                      size: 18,
                      color: colors.textMuted,
                    ),
                    onPressed: () => state.toggleGroupExpansion(groupName),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: OrganismTheme.spacingMd,
                  crossAxisSpacing: OrganismTheme.spacingMd,
                  childAspectRatio: 1.05,
                ),
                itemCount: groupItems.length,
                itemBuilder: (context, index) {
                  final card = groupItems[index];
                  final cardNo = (card['CARDNO'] as num?)?.toInt() ?? 0;
                  final lot = card['LOT'] as String? ?? 'N/A';
                  final rmts = (card['PMTS'] as num?)?.toDouble() ??
                      (card['WMTS'] as num?)?.toDouble() ??
                      (card['RMTS'] as num?)?.toDouble() ??
                      0.0;
                  final rpcs = (card['RPCS'] as num?)?.toInt() ?? 0;
                  final ddateVal = card['DDATE'];
                  final isChecked = state.selectedTakaRows
                      .any((row) => (row['CARDNO'] as num?)?.toInt() == cardNo);

                  // Days ago calculation
                  String daysAgoText = 'N/A';
                  if (ddateVal != null) {
                    try {
                      final date = DateTime.parse(ddateVal.toString());
                      final diff = DateTime.now().difference(date).inDays;
                      if (diff <= 0) {
                        daysAgoText = 'Today';
                      } else if (diff == 1) {
                        daysAgoText = '1 day ago';
                      } else {
                        daysAgoText = '$diff days ago';
                      }
                    } catch (_) {}
                  }

                  return GestureDetector(
                    onTap: () => state.toggleTakaRow(card, cardNo, isChecked),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? colors.primary.withOpacity(0.08)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(OrganismTheme.radiusSm),
                        border: Border.all(
                          color: isChecked ? colors.primary : colors.border,
                          width: isChecked ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CellCheckbox(
                                  value: isChecked,
                                  onChanged: (val) => state.toggleTakaRow(card, cardNo, isChecked),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(OrganismTheme.radiusSm),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Text(
                                  '$cardNo',
                                  style: OrganismTheme.bodySmall(context).copyWith(
                                    fontFamily: 'Mono',
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lot',
                                style: OrganismTheme.bodySmall(context).copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                              Text(
                                lot,
                                style: OrganismTheme.bodyMedium(context).copyWith(
                                  fontFamily: 'Mono',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mts',
                                style: OrganismTheme.labelSmall(context).copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                              Text(
                                'Pcs',
                                style: OrganismTheme.labelSmall(context).copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rmts.toStringAsFixed(1),
                                style: OrganismTheme.bodyMedium(context).copyWith(
                                  fontFamily: 'Mono',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$rpcs',
                                style: OrganismTheme.bodyMedium(context).copyWith(
                                  fontFamily: 'Mono',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 8),
                          Text(
                            daysAgoText,
                            textAlign: TextAlign.center,
                            style: OrganismTheme.bodySmall(context).copyWith(
                              fontStyle: FontStyle.italic,
                              color: colors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      }).toList(),
    );
  }
}
