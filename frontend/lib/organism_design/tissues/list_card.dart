import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/box.dart';
import '../cells/spatial.dart';

/// [TissueListCard] — Universal registry row molecule.
///
/// Composes dynamic Slots ([leading], [title], [subtitle], [trailing], [footer])
/// into a standardized high-density ERP row with hover and selection physics.
class TissueListCard extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? footer;

  final bool isCompact;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback? onTap;

  const TissueListCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.footer,
    this.isCompact = true,
    this.isSelected = false,
    this.showDivider = false,
    this.onTap,
  });

  @override
  State<TissueListCard> createState() => _TissueListCardState();
}

class _TissueListCardState extends State<TissueListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    // STRICT ALIGNMENT: 16px horizontal baseline.
    final double horizPadding = OrganismTheme.spacingMd;
    // SLIGHTLY LARGER: Increased from 8 to 12 for compact, 16 for standard.
    final double vertPadding = widget.isCompact ? 12.0 : 16.0;

    Color borderColor = widget.isSelected
        ? colors.primary
        : Colors.transparent; 
    Color bgColor = widget.isSelected
        ? colors.primarySubtle
        : colors.surface;

    if (_isHovered && widget.onTap != null && !widget.isSelected) {
      borderColor = colors.border;
      bgColor = colors.surfaceHover;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(color: widget.isSelected ? borderColor : Colors.transparent),
              left: BorderSide(color: widget.isSelected ? borderColor : Colors.transparent),
              right: BorderSide(color: widget.isSelected ? borderColor : Colors.transparent),
              bottom: BorderSide(
                color: widget.isSelected ? borderColor : (widget.showDivider ? colors.stone300 : Colors.transparent),
                width: 1.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizPadding, vertical: vertPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: OrganismTheme.spacingSm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.title != null) 
                          DefaultTextStyle(
                            style: OrganismTheme.titleSmall(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            child: widget.title!,
                          ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          DefaultTextStyle(
                            style: OrganismTheme.labelSmall(context).copyWith(
                              color: colors.textMuted,
                            ),
                            child: widget.subtitle!,
                          ),
                        ]
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: OrganismTheme.spacingMd),
                    widget.trailing!,
                  ]
                ],
              ),
              if (widget.footer != null) ...[
                const SizedBox(height: OrganismTheme.spacingSm),
                widget.footer!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}
