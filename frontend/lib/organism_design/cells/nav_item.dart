import 'package:flutter/material.dart';
import '../theme.dart';
import 'spatial.dart'; // Direct import for CellGap

/// [CellNavItem] — Global navigation entry atom.
///
/// Used in [NavBoat] (Sidebar/Rail). Handles selection states, 
/// responsive labeled/unlabeled transitions, and branding colors.

/// Defines the visual style of a NavItem.
enum CellNavItemVariant { standard, action }

/// A dedicated Cell for Sidebar/Rail navigation items.
/// Encapsulates the complex AnimatedSlide and state-tracking logic.
class CellNavItem extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;
  final CellNavItemVariant variant;

  const CellNavItem({
    super.key,
    this.icon,
    this.leading,
    required this.label,
    this.subtitle,
    this.trailing,
    this.isSelected = false,
    required this.isCollapsed,
    required this.onTap,
    this.variant = CellNavItemVariant.standard,
  }) : assert(icon != null || leading != null, 'Either icon or leading must be provided');

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    final bool isAction = variant == CellNavItemVariant.action;
    final Color bgColor = isSelected 
        ? colors.primary.withValues(alpha: 0.08) 
        : (isAction ? colors.surfaceSubtle : Colors.transparent);
    final Border? border = isAction 
        ? Border.all(color: colors.surfaceActive) 
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: OrganismTheme.borderMd,
        child: Container(
          height: 44, // Iconic Square feel
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: OrganismTheme.borderMd,
            border: border,
          ),
          child: Stack(
            children: [
              // 1. Fixed Leading Area (Icon or Widget)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: OrganismTheme.sidebarWidthCollapsed - 12.0, // Accounts for 6px margins
                child: Center(
                  child: leading ?? Icon(
                    icon,
                    size: OrganismTheme.iconSizeMd,
                    color: isSelected ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
              
              // 2. Sliding Extension Area (Label, Subtitle, Trailing)
              Positioned(
                left: OrganismTheme.sidebarWidthCollapsed - 12.0,
                top: 0,
                bottom: 0,
                right: 0,
                child: ClipRect(
                  child: AnimatedSlide(
                    duration: OrganismTheme.durationFast,
                    curve: OrganismTheme.curveStandard,
                    offset: isCollapsed ? const Offset(-1.0, 0) : Offset.zero,
                    child: AnimatedOpacity(
                      duration: OrganismTheme.durationFast,
                      opacity: isCollapsed ? 0.0 : 1.0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingSm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: OrganismTheme.bodyMedium(context).copyWith(
                                        color: isSelected ? colors.primary : colors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                    if (subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      DefaultTextStyle(
                                        style: OrganismTheme.labelSmall(context).copyWith(
                                          color: colors.textMuted,
                                        ),
                                        child: subtitle!,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (trailing != null) ...[
                                const SizedBox(width: OrganismTheme.spacingSm),
                                trailing!,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
