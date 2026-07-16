import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'skeleton.dart';

/// [CellImage] — Network image wrapper handling loading skeletons and error fallbacks.
///
/// Designed to seamlessly load generic grid thumbnails or product previews without LayoutJumps.
class CellImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CellImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final border = borderRadius ?? OrganismTheme.borderSm;

    return ClipRRect(
      borderRadius: border,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child; // Fully loaded
          // Skeleton loader matching the expected image footprint
          return CellSkeleton(
            width: width,
            height: height,
            borderRadius: border,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Muted fallback container on HTTP 404 or image decode errors
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: border,
              border: Border.all(color: colors.borderSubtle),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.imageOff,
                  color: colors.textMuted,
                  size: 24, // Standard visual anchor
                ),
                const SizedBox(height: 4),
                Text(
                  'No Image',
                  style: OrganismTheme.bodySmall(context).copyWith(
                    color: colors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
