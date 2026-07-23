import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/card_avatar.dart';

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

  // Registry-specific parameters
  final DateTime? registryDate;
  final String? registryTitle;
  final String? registrySubtitle;
  final String? registryBadgeText;
  final String? registryMetricText;
  final Widget? registrySubtitleWidget;
  final Color? badgeColor;
  final bool isRegistryVariant;

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
  }) : isRegistryVariant = false,
       registryDate = null,
       registryTitle = null,
       registrySubtitle = null,
       registryBadgeText = null,
       registryMetricText = null,
       registrySubtitleWidget = null,
       badgeColor = null;

  const TissueListCard.registry({
    super.key,
    required this.registryDate,
    required this.registryTitle,
    this.registrySubtitle,
    required this.registryBadgeText,
    required this.registryMetricText,
    this.registrySubtitleWidget,
    this.badgeColor,
    this.isSelected = false,
    this.showDivider = true,
    this.onTap,
  }) : isRegistryVariant = true,
       isCompact = false,
       leading = null,
       title = null,
       subtitle = null,
       trailing = null,
       footer = null;

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
          child: widget.isRegistryVariant
              ? _buildRegistryLayout(context, colors)
              : _buildStandardLayout(context, colors),
        ),
      ),
    );
  }

  Widget _buildStandardLayout(BuildContext context, OrganismColors colors) {
    return Column(
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
    );
  }

  Widget _buildRegistryLayout(BuildContext context, OrganismColors colors) {
    final activeBadgeColor = widget.badgeColor ?? colors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Column 1: Date avatar (Medium size 44 variant)
        if (widget.registryDate != null)
          CellCardAvatar(
            date: widget.registryDate!,
            sizeVariant: CellCardAvatarSize.medium,
          ),
        const SizedBox(width: 12),
        
        // Column 2: Title and Subtitle/Widget (uppercase bold monospace text)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.registryTitle != null)
                Text(
                  widget.registryTitle!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OrganismTheme.bodyMedium(context).copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected ? colors.primary : colors.textPrimary,
                  ),
                ),
              if (widget.registrySubtitleWidget != null) ...[
                const SizedBox(height: 4),
                widget.registrySubtitleWidget!,
              ] else if (widget.registrySubtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.registrySubtitle!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OrganismTheme.labelMedium(context).copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    color: widget.isSelected ? colors.primary.withValues(alpha: 0.8) : colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Column 3: High-density Badge and Monospace metric
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.registryBadgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: activeBadgeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: activeBadgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  widget.registryBadgeText!,
                  style: OrganismTheme.labelMedium(context).copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.bold,
                    color: activeBadgeColor,
                  ),
                ),
              ),
            if (widget.registryMetricText != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.registryMetricText!,
                style: OrganismTheme.bodySmall(context).copyWith(
                  fontFamily: 'JetBrainsMono',
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
