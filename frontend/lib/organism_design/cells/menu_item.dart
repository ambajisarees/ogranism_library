import 'package:flutter/material.dart';
import '../theme.dart';
import 'spatial.dart';

/// [CellMenuItem] — Interactive row atom for menus.
///
/// Designed to live inside [PlasmaContextMenu], [PlasmaPopover], or custom sidebars.
/// Handles hover states and semantic iconography natively.
class CellMenuItem extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDisabled;

  const CellMenuItem({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  @override
  State<CellMenuItem> createState() => _CellMenuItemState();
}

class _CellMenuItemState extends State<CellMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    final Color fgColor = widget.isDisabled 
        ? colors.textMuted 
        : (widget.isDestructive ? colors.error : colors.textPrimary);
        
    final Color bgColor = _isHovered && !widget.isDisabled
        ? (widget.isDestructive ? colors.error.withValues(alpha: 0.1) : colors.surfaceActive)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isDisabled ? null : widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: OrganismTheme.durationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingMd,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: OrganismTheme.borderSm,
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: fgColor),
                CellGap.small,
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: OrganismTheme.bodyMedium(context).copyWith(
                    color: fgColor,
                    fontWeight: _isHovered ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                CellGap.small,
                DefaultTextStyle.merge(
                  style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted),
                  child: widget.trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
