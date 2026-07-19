import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'dynamic_action_row.dart';

class SortPopover extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onSelected;
  final List<DynamicActionOption> options;

  const SortPopover({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return shad.ModalContainer(
      child: SizedBox(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: options.map<Widget>((opt) {
            final isOptionSelected = selectedValue == opt.value;
            return shad.Button(
              onPressed: () {
                onSelected(opt.value);
                shad.closeOverlay(context);
              },
              style: const shad.ButtonStyle.ghost().copyWith(
                padding: (context, states, value) => EdgeInsets.symmetric(
                  vertical: 8 * theme.scaling,
                  horizontal: 8 * theme.scaling,
                ),
                mouseCursor: (context, states, value) => SystemMouseCursors.click,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (opt.icon != null) ...[
                        opt.icon!,
                        const shad.DensityGap(shad.gapSm),
                      ],
                      Text(opt.label),
                    ],
                  ),
                  if (isOptionSelected)
                    const Icon(shad.LucideIcons.check),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
