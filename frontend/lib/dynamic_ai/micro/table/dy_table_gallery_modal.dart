/// LLM NOTE: DyTable Gallery Lightbox Modal
/// - Level: Micro Component Overlay
/// - Purpose: Image preview lightbox dialog for fabric designs and voucher media thumbnails.

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DyTableGalleryModal extends StatelessWidget {
  final String title;
  final String? imagePath;

  const DyTableGalleryModal({
    super.key,
    required this.title,
    this.imagePath,
  });

  static void show(BuildContext context, {required String title, String? imagePath}) {
    shad.showOverlay(
      context,
      shad.PopoverConfiguration(
        anchorAlignment: Alignment.center,
        alignment: Alignment.center,
        builder: (context) => DyTableGalleryModal(title: title, imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.Card(
      padding: EdgeInsets.all(16 * theme.scaling),
      child: SizedBox(
        width: 360 * theme.scaling,
        height: 280 * theme.scaling,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.foreground,
                    ),
                  ),
                ),
                shad.IconButton.ghost(
                  icon: Icon(
                    shad.LucideIcons.x,
                    size: 16 * theme.scaling,
                  ),
                  onPressed: () => shad.closeOverlay(context),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.muted,
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  border: Border.all(color: colors.border),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        shad.LucideIcons.image,
                        size: 48 * theme.scaling,
                        color: colors.mutedForeground,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Fabric Design Lightbox View',
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
