/// LLM NOTE: DabStatusPopover
/// - Level: DAB Popover Widget
/// - Purpose: Document status filter popover checklist for DynamicActionBar providing PENDING, COMPLETED, and IN_PROCESS multi-selection.
/// - Widget Composition: shad.Card -> Column(Checklist items with shad.Checkbox).

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Status Selection Popover:
/// Straightforward options checklist for PENDING, COMPLETED, IN_PROCESS
class DabStatusPopover extends StatefulWidget {
  final Set<String> selectedStatuses;
  final ValueChanged<Set<String>> onChanged;

  const DabStatusPopover({
    super.key,
    required this.selectedStatuses,
    required this.onChanged,
  });

  @override
  State<DabStatusPopover> createState() => _DabStatusPopoverState();
}

class _DabStatusPopoverState extends State<DabStatusPopover> {
  late Set<String> _currentStatuses;

  @override
  void initState() {
    super.initState();
    _currentStatuses = Set.from(widget.selectedStatuses);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final statuses = [
      'PENDING',
      'COMPLETED',
      'IN_PROCESS',
    ];

    return shad.Card(
      padding: EdgeInsets.all(8 * theme.scaling),
      child: SizedBox(
        width: 180 * theme.scaling,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: statuses.map((status) {
            final isChecked = _currentStatuses.contains(status);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    _currentStatuses.remove(status);
                  } else {
                    _currentStatuses.add(status);
                  }
                });
                widget.onChanged(_currentStatuses);
              },
              child: Container(
                color: isChecked ? colors.accent.withAlpha(100) : const Color(0x00000000),
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * theme.scaling,
                  vertical: 6 * theme.scaling,
                ),
                child: Row(
                  children: [
                    shad.Checkbox(
                      state: isChecked ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
                      onChanged: (state) {
                        setState(() {
                          if (state == shad.CheckboxState.checked) {
                            _currentStatuses.add(status);
                          } else {
                            _currentStatuses.remove(status);
                          }
                        });
                        widget.onChanged(_currentStatuses);
                      },
                    ),
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      status,
                      style: theme.typography.textSmall.copyWith(
                        fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                        color: colors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
