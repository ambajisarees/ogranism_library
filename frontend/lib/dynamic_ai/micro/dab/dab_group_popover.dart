/*
================================================================================
LLM CONTEXT & QUERY SPACE — DAB GROUP POPOVER (dab_group_popover.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Dynamic multi-level grouping popover component for DynamicActionBar (DAB).
   - Configures 1 to 4 nested grouping levels (Level 1, Level 2, Level 3, Level 4).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Options: Fabric, Date, Rate, Lotno, Despno.
   - Row layout: Left-aligned Level label -> Select MicroButton dropdown -> Remove trash button.
   - '+ Add Group' ghost button (visible when level count < 4).
   - Left-aligned compact Apply (Primary) and Cancel (Outline) buttons.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../dy_micro_button.dart';

/// Model for a grouping column option.
class DabGroupLevelOption {
  final String key;
  final String label;

  const DabGroupLevelOption({
    required this.key,
    required this.label,
  });
}

const List<DabGroupLevelOption> kAvailableGroupLevelOptions = [
  DabGroupLevelOption(key: 'quality', label: 'Fabric'),
  DabGroupLevelOption(key: 'date', label: 'Date'),
  DabGroupLevelOption(key: 'rate', label: 'Rate'),
  DabGroupLevelOption(key: 'lotNo', label: 'Lotno'),
  DabGroupLevelOption(key: 'despNo', label: 'Despno'),
];

/// [DabGroupPopover] — Multi-Level Grouping Configuration Popover.
class DabGroupPopover extends StatefulWidget {
  final List<String> initialLevels;
  final ValueChanged<List<String>> onApply;
  final VoidCallback onClose;

  const DabGroupPopover({
    super.key,
    this.initialLevels = const ['quality', 'date'],
    required this.onApply,
    required this.onClose,
  });

  @override
  State<DabGroupPopover> createState() => _DabGroupPopoverState();
}

class _DabGroupPopoverState extends State<DabGroupPopover> {
  late List<String> _activeLevels;

  @override
  void initState() {
    super.initState();
    _activeLevels = List<String>.from(
      widget.initialLevels.isNotEmpty ? widget.initialLevels : ['quality', 'date'],
    );
  }

  void _addLevel() {
    if (_activeLevels.length >= 4) return;
    for (final opt in kAvailableGroupLevelOptions) {
      if (!_activeLevels.contains(opt.key)) {
        setState(() {
          _activeLevels.add(opt.key);
        });
        return;
      }
    }
    setState(() {
      _activeLevels.add('date');
    });
  }

  void _removeLevel(int index) {
    if (index >= 0 && index < _activeLevels.length) {
      setState(() {
        _activeLevels.removeAt(index);
      });
    }
  }

  void _updateLevelKey(int index, String newKey) {
    if (index >= 0 && index < _activeLevels.length) {
      setState(() {
        _activeLevels[index] = newKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.Card(
      child: Container(
        width: 320 * theme.scaling,
        padding: EdgeInsets.all(12 * theme.scaling),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Popover Title & Close Button
            Row(
              children: [
                Icon(shad.LucideIcons.layers, size: 16 * theme.scaling, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Group By',
                  style: theme.typography.p.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                  ),
                ),
                const Spacer(),
                shad.GhostButton(
                  onPressed: widget.onClose,
                  child: const Icon(shad.LucideIcons.x, size: 14),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),

            // Grouping Levels Rows (Up to 4)
            if (_activeLevels.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No grouping applied (Flat list).',
                  style: theme.typography.small.copyWith(color: colors.mutedForeground),
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_activeLevels.length, (index) {
                  final currentKey = _activeLevels[index];
                  final activeOpt = kAvailableGroupLevelOptions.firstWhere(
                    (o) => o.key == currentKey,
                    orElse: () => DabGroupLevelOption(key: currentKey, label: currentKey),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Level ${index + 1}',
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // MicroButton Popover Selector for Level Column
                        Expanded(
                          child: Builder(
                            builder: (btnContext) => MicroButton(
                              label: activeOpt.label,
                              trailingIcon: shad.LucideIcons.chevronDown,
                              onPressed: () {
                                shad.showOverlay(
                                  btnContext,
                                  shad.PopoverConfiguration(
                                    anchorAlignment: Alignment.bottomLeft,
                                    alignment: Alignment.topLeft,
                                    offset: const Offset(0, 4),
                                    builder: (popContext) => shad.Card(
                                      child: Container(
                                        width: 160 * theme.scaling,
                                        padding: EdgeInsets.all(6 * theme.scaling),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: kAvailableGroupLevelOptions.map((opt) {
                                            final isSelected = currentKey == opt.key;
                                            return shad.GhostButton(
                                              onPressed: () {
                                                _updateLevelKey(index, opt.key);
                                                shad.closeOverlay(popContext);
                                              },
                                              child: Row(
                                                children: [
                                                  if (isSelected)
                                                    Icon(shad.LucideIcons.check, size: 14, color: colors.primary)
                                                  else
                                                    const SizedBox(width: 14),
                                                  const SizedBox(width: 8),
                                                  Text(opt.label, style: theme.typography.small),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Trash Remove Button
                        shad.GhostButton(
                          onPressed: () => _removeLevel(index),
                          child: const Icon(shad.LucideIcons.trash2, size: 14),
                        ),
                      ],
                    ),
                  );
                }),
              ),

            const shad.DensityGap(shad.gapSm),

            // "+ Add Group" Ghost Button (Hidden when 4 levels reached)
            if (_activeLevels.length < 4)
              shad.GhostButton(
                onPressed: _addLevel,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(shad.LucideIcons.plus, size: 14),
                    SizedBox(width: 6),
                    Text('Add Group'),
                  ],
                ),
              ),

            const shad.DensityGap(shad.gapMd),

            // Left-Aligned Compact Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                shad.PrimaryButton(
                  onPressed: () {
                    widget.onApply(_activeLevels);
                    widget.onClose();
                  },
                  child: const Text('Apply'),
                ),
                const SizedBox(width: 8),
                shad.OutlineButton(
                  onPressed: widget.onClose,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
