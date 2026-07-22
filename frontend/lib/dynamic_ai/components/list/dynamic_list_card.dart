import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicListItem {
  final String? status;
  final String date;
  final String title;
  final String indexNumber;
  final String subtitle;
  final String infoNumber;

  const DynamicListItem({
    this.status,
    required this.date,
    required this.title,
    required this.indexNumber,
    required this.subtitle,
    required this.infoNumber,
  });
}

class DynamicListCard extends StatefulWidget {
  final DynamicListItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const DynamicListCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DynamicListCard> createState() => _DynamicListCardState();
}

class _DynamicListCardState extends State<DynamicListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    
    // Styling states
    final background = widget.isSelected
        ? colors.accent
        : (_isHovered ? colors.accent.withValues(alpha: 0.5) : Colors.transparent);
        
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
          decoration: BoxDecoration(
            color: background,
            border: Border(
              bottom: BorderSide(
                color: colors.border,
                width: 1.0,
              ),
              left: BorderSide(
                color: widget.isSelected ? colors.primary : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Optional Status Chip -> Spacer -> Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.item.status != null) ...[
                    _buildStatusBadge(widget.item.status!),
                  ] else ...[
                    const SizedBox.shrink(),
                  ],
                  const Spacer(),
                  Text(
                    widget.item.date,
                    style: theme.typography.xSmall.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
              const shad.DensityGap(shad.gapSm),
              
              // Row 2: Title -> Spacer -> Index Number
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: theme.typography.textSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const shad.DensityGap(shad.gapSm),
                  Text(
                    widget.item.indexNumber,
                    style: theme.typography.textSmall.copyWith(
                      fontFamily: theme.typography.mono.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const shad.DensityGap(shad.gapXs),
              
              // Row 3: Subtitle -> Spacer -> Info No
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.subtitle,
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const shad.DensityGap(shad.gapSm),
                  Text(
                    'Info No: ${widget.item.infoNumber}',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    // Generate different badge types depending on status
    switch (status.toLowerCase()) {
      case 'active':
        return const shad.PrimaryBadge(
          child: Text('Active'),
        );
      case 'pending':
        return const shad.SecondaryBadge(
          child: Text('Pending'),
        );
      case 'completed':
        return const shad.OutlineBadge(
          child: Text('Completed'),
        );
      default:
        return shad.SecondaryBadge(
          child: Text(status),
        );
    }
  }
}
