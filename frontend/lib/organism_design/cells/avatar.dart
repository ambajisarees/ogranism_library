import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import 'focus.dart'; // Direct import for OrganismFocus

/// [CellAvatar] — Shape encapsulating initials parser or image.
///
/// A highly flexible visual identifier. Automatically parses initials from 
/// [name], supports [image] provider, and optional [statusColor] indicator.

/// Headless visual party/user identifier with support for images, fallbacks, statuses, and interactions.
class CellAvatar extends StatelessWidget {
  final String? name; // Nullable to allow pure image/icon variants
  final double size;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final Color? statusColor;
  final IconData? fallbackIcon;

  const CellAvatar({
    super.key, 
    this.name, 
    this.size = 32,
    this.image,
    this.onTap,
    this.statusColor,
    this.fallbackIcon = LucideIcons.user,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    // Generate initials (up to 2 chars)
    String initials = '';
    if (name != null) {
      final parts = name!.trim().split(' ').where((s) => s.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        initials += parts[0].substring(0, 1);
        if (parts.length > 1) {
          initials += parts[1].substring(0, 1);
        }
      }
    }
    
    Widget avatarCanvas;
    final img = image;

    if (img != null) {
      avatarCanvas = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: OrganismTheme.borderMd,
          image: DecorationImage(image: img, fit: BoxFit.cover),
          border: Border.all(color: colors.surfaceActive),
        ),
      );
    } else if (initials.isNotEmpty) {
      avatarCanvas = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: OrganismTheme.borderMd,
          border: Border.all(color: colors.surfaceActive),
        ),
        alignment: Alignment.center,
        child: Text(
          initials.toUpperCase(),
          style: OrganismTheme.labelLarge(context).copyWith(color: colors.textPrimary, fontSize: size * 0.35, height: 1.0),
        ),
      );
    } else {
      avatarCanvas = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: OrganismTheme.borderMd,
          border: Border.all(color: colors.surfaceActive),
        ),
        alignment: Alignment.center,
        child: Icon(fallbackIcon, size: size * 0.5, color: colors.textSecondary),
      );
    }

    Widget structuredAvatar = avatarCanvas;

    if (statusColor != null) {
      final dotSize = size * 0.25;
      structuredAvatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarCanvas,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2), // Ring to break from avatar background
              ),
            ),
          )
        ],
      );
    }

    if (onTap != null) {
      return OrganismFocus(
        onTap: onTap,
        borderRadius: OrganismTheme.borderMd,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: structuredAvatar,
          ),
        ),
      );
    }

    return structuredAvatar;
  }
}
