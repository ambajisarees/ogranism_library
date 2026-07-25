import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PurchaseOrdersActionPane extends StatelessWidget {
  const PurchaseOrdersActionPane({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final paneWidth = 320.0 * theme.scaling;
    final padMd = theme.density.baseContainerPadding * theme.scaling * shad.padMd;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;

    return SizedBox(
      width: paneWidth,
      child: shad.Card(
        borderColor: colors.border,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: padMd * 2, horizontal: padSm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  shad.LucideIcons.layoutGrid,
                  size: 28 * theme.scaling,
                  color: colors.mutedForeground,
                ),
                const shad.DensityGap(shad.gapMd),
                Text(
                  'Order Actions & Tracking',
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const shad.DensityGap(shad.gapSm),
                Text(
                  'This panel is reserved for order fulfillment status, vendor follow-up notes, and batch approval operations.',
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
