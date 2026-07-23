import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PurchaseBillsTypeToggle extends StatelessWidget {
  final String selectedType; // 'P1' (Grey) or 'J1' (Process)
  final ValueChanged<String> onTypeChanged;

  const PurchaseBillsTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isGrey = selectedType == 'P1';

    return shad.OutlinedContainer(
      borderColor: colors.border,
      backgroundColor: colors.card,
      borderRadius: theme.borderRadiusSm,
      child: Padding(
        padding: EdgeInsets.all(3 * theme.scaling),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Option 1: Grey Purchase (P1)
            isGrey
                ? shad.PrimaryButton(
                    size: shad.ButtonSize.small,
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shad.LucideIcons.package, size: 14 * theme.scaling),
                        const shad.DensityGap(shad.gapSm),
                        const Text('Grey Purchase'),
                      ],
                    ),
                  )
                : shad.OutlineButton(
                    size: shad.ButtonSize.small,
                    onPressed: () => onTypeChanged('P1'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shad.LucideIcons.package, size: 14 * theme.scaling, color: colors.mutedForeground),
                        const shad.DensityGap(shad.gapSm),
                        Text('Grey Purchase', style: TextStyle(color: colors.mutedForeground)),
                      ],
                    ),
                  ),
            SizedBox(width: 4 * theme.scaling),

            // Option 2: Process Mill Bills (J1)
            !isGrey
                ? shad.PrimaryButton(
                    size: shad.ButtonSize.small,
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shad.LucideIcons.factory, size: 14 * theme.scaling),
                        const shad.DensityGap(shad.gapSm),
                        const Text('Process Mill Bills'),
                      ],
                    ),
                  )
                : shad.OutlineButton(
                    size: shad.ButtonSize.small,
                    onPressed: () => onTypeChanged('J1'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shad.LucideIcons.factory, size: 14 * theme.scaling, color: colors.mutedForeground),
                        const shad.DensityGap(shad.gapSm),
                        Text('Process Mill Bills', style: TextStyle(color: colors.mutedForeground)),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
